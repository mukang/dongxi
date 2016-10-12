//
//  DXClient.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClient.h"
#import "DXFunctions.h"
#import "DXClientFunctions.h"
#import "DXClientConfig.h"
#import "DXClientRequest.h"
#import "DXClientRequestSigner.h"
#import "DXClientResponse.h"
#import "DXClientPostForm.h"

typedef NS_ENUM(NSUInteger, DXServerStatus) {
    DXServerStatusAnonymous = 0,
    DXServerStatusLogined
};


@interface DXClient() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionConfiguration * sessionConfig;
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) id<DXClientRequestSigner> requestSigner;
@property (nonatomic, strong) NSMutableDictionary * cachedClientRequests;
@property (nonatomic, strong) NSMutableDictionary * cachedProgressBlock;
@property (nonatomic, assign) BOOL isExecuting;

- (void)send:(DXClientRequest *)clientRequest progress:(void(^)(float percent))progressBlock completion:(void (^)(DXClientResponse *response))completionBlock;

@end


@implementation DXClient {
    dispatch_group_t _group;
}

#pragma mark - Public Methods

+ (instancetype)client {
    static dispatch_once_t onceToken;
    static DXClient * client = nil;
    dispatch_once(&onceToken, ^{
        client =  [[self alloc] init];
        [client setRequestSigner:[[DXClientRequestDefaultSigner alloc] init]];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _group = dispatch_group_create();
        _isExecuting = NO;
    }
    return self;
}

- (void)send:(DXClientRequest *)clientRequest{
    [self send:clientRequest progress:nil finish:nil];
}

- (void)send:(DXClientRequest *)clientRequest progress:(void (^)(float))progressBlock finish:(void (^)(DXClientResponse *))responseBlock {
    
    if (clientRequest.priority == DXClientRequestPriorityLow) {
        if (self.isExecuting) {
            __weak typeof(self) weakSelf = self;
            dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
                [weakSelf send:clientRequest progress:progressBlock completion:^(DXClientResponse *response) {
                    if (responseBlock) {
                        responseBlock(response);
                    }
                }];
            });
        } else {
            [self send:clientRequest progress:progressBlock completion:^(DXClientResponse *response) {
                if (responseBlock) {
                    responseBlock(response);
                }
            }];
        }
    } else {
        dispatch_group_enter(_group);
        self.isExecuting = YES;
        [self send:clientRequest progress:progressBlock completion:^(DXClientResponse *response) {
            if (responseBlock) {
                responseBlock(response);
            }
            self.isExecuting = NO;
            dispatch_group_leave(_group);
        }];
    }
}

- (void)send:(DXClientRequest *)clientRequest progress:(void (^)(float))progressBlock completion:(void (^)(DXClientResponse *))completionBlock {
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:DXCLIENT_REQUEST_URL_FORMAT, [clientRequest apiName]]];
    NSMutableURLRequest * urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setTimeoutInterval:clientRequest.timeout];
    [urlRequest setHTTPMethod:[clientRequest httpMethod]];
    
    if ([clientRequest respondsToSelector:@selector(prepareToSend)]) {
        [clientRequest prepareToSend];
    }
    
    [self prepareURLRequest:&urlRequest withClientRequest:clientRequest];
    
    if ([self.delegate respondsToSelector:@selector(client:willSentRequest:)]) {
        [self.delegate client:self willSentRequest:clientRequest];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSDictionary * dataInResponse = nil;
        if (!error) {
            NSError *serializeError = nil;
            NSDictionary * responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializeError];
            if (serializeError) {
                NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"服务器响应解析出错，响应文本为: %@, 状态码为: %zd", dataString, [(NSHTTPURLResponse *)response statusCode]);
                error = [DXClientRequestError errorWithCode:DXClientRequestErrorServerResponseNotJSON andDescription:serializeError.localizedDescription];
            } else {
                NSNumber * ret = [responseData objectForKey:@"ret"];
                if (!ret) {
                    error = [DXClientRequestError errorWithCode:DXClientRequestErrorServerInternalError andDescription:nil];
                } else {
                    if (ret.intValue >= 0) {
                        dataInResponse = [responseData objectForKey:@"response"];
                    } else {
                        switch (ret.intValue) {
                            case DXClientResponseResultSessionInvalid:
                            case DXClientResponseResultUserInvalid:
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DXClientResponseUserNeedRelogin" object:nil];
                                });
                                break;
                            default:
                                break;
                        }
                        error = [DXClientRequestError errorWithCode:DXClientRequestErrorRequestInvalid andDescription:[responseData objectForKey:@"status"]];
                    }
                }
            }
        } else {
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                DXClientRequestErrorCode errorCode = [DXClientRequestError codeFromNSURLErrorCode:error.code];
                error = [DXClientRequestError errorWithCode:errorCode andDescription:nil];
            } else {
                error = [DXClientRequestError errorWithCode:DXClientRequestErrorNetworkError andDescription:nil];
            }
            
        }
        DXClientLog(@"Client Receive Data: %@, Error: %@", dataInResponse, error);
        DXClientResponse * clientResponse = [DXClientResponse responseWithApi:clientRequest.apiName data:dataInResponse orError:error];
        [clientResponse setResponseStatusCode:[(NSHTTPURLResponse *)response statusCode]];
        if ([self.delegate respondsToSelector:@selector(client:didGetReponse:forRequest:)]) {
            [self.delegate client:self didGetReponse:clientResponse forRequest:clientRequest];
        }
        
        if (completionBlock) {
            completionBlock(clientResponse);
        }
    }];
    [self.cachedClientRequests setObject:clientRequest forKey:@(task.taskIdentifier)];
    if (progressBlock) {
        [self.cachedProgressBlock setObject:progressBlock forKey:@(task.taskIdentifier)];
    }
    
    [task resume];
}

#pragma mark - Private Methods

- (NSMutableDictionary *)cachedClientRequests {
    if (nil == _cachedClientRequests) {
        _cachedClientRequests = [NSMutableDictionary dictionary];
    }
    return _cachedClientRequests;
}

- (NSMutableDictionary *)cachedProgressBlock {
    if (nil == _cachedProgressBlock) {
        _cachedProgressBlock = [NSMutableDictionary dictionary];
    }
    return _cachedProgressBlock;
}

- (NSURLSessionConfiguration *)sessionConfig {
    if (nil == _sessionConfig) {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return _sessionConfig;
}

- (NSURLSession *)session {
    if (nil == _session) {
        _session = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:self delegateQueue:nil];
    }
    return _session;
}

- (void)prepareURLRequest:(NSMutableURLRequest **)urlRequest withClientRequest:(DXClientRequest *)clientRequest {
    
    NSDictionary *sessionInfo = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(client:prepareSignParamsWithRequest:)]) {
        sessionInfo = [self.delegate client:self prepareSignParamsWithRequest:clientRequest];
    }
    
    NSDictionary * requestParams = [self.requestSigner signParamsFromRequest:clientRequest withSessionInfo:sessionInfo];
    
    DXClientLog(@"Client Send Data: %@", requestParams);
    if ([clientRequest respondsToSelector:@selector(postFormForRequestData:andFiles:)]) {
        DXClientPostForm  * postForm = [clientRequest postFormForRequestData:requestParams andFiles:[clientRequest files]];
        NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", postForm.boundaryIdentifier];
        [*urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
        [*urlRequest setHTTPBody:[postForm getFormData]];
    } else {
        if ([[clientRequest files] count] > 0) {
            DXClientPostForm  * postForm = [self postFormForRequestData:requestParams andFiles:[clientRequest files]];
            NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", postForm.boundaryIdentifier];
            [*urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
            [*urlRequest setHTTPBody:[postForm getFormData]];
        } else {
            [*urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:nil]];
        }
    }
}

- (DXClientPostForm *)postFormForRequestData:(NSDictionary *)requestData andFiles:(NSArray *)files {
    NSAssert(requestData, @"requestData不能为nil");
    NSAssert(files.count > 0, @"files必须为数量大于0的数组");
    
    NSError * err;
    NSData * paramsData = [NSJSONSerialization dataWithJSONObject:requestData options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return nil;
    } else {
        DXClientPostForm * postForm = [DXClientPostForm new];
        [postForm addParams:paramsData name:@"json"];
        
        for (NSURL * fileURL in files) {
            @autoreleasepool {
                NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
                if (fileData) {
                    NSString * fileName = fileURL.lastPathComponent;
                    [postForm addFileData:fileData fileName:fileName];
                }
            }
        }
        return postForm;
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    DXClientRequest * clientRequest = [self.cachedClientRequests objectForKey:@(task.taskIdentifier)];
    
    if ([self.delegate respondsToSelector:@selector(client:didSendDataByPercent:forRequest:)]) {
        float percent = totalBytesSent*1.0 / totalBytesExpectedToSend;
        [self.delegate client:self didSendDataByPercent:percent forRequest:clientRequest];
    }
    
    void(^progressBlock)(float) = [self.cachedProgressBlock objectForKey:@(task.taskIdentifier)];
    if (progressBlock) {
        progressBlock(totalBytesSent*1.0 / totalBytesExpectedToSend);
    }
    
    if (totalBytesExpectedToSend == totalBytesSent) {
        [self.cachedClientRequests removeObjectForKey:@(task.taskIdentifier)];
        [self.cachedProgressBlock removeObjectForKey:@(task.taskIdentifier)];
    }
}

@end
