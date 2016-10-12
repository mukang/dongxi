//
//  DXClientRequestError.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequestError.h"

@implementation DXClientRequestError

NSString * const DXClientRequestErrorDomain                 = @"DXClientRequestError";
NSString * const DXClientRequestOriginErrorDescriptionKey   = @"DXClientRequestOriginErrorDescriptionKey";

+ (instancetype)errorWithCode:(DXClientRequestErrorCode)code andDescription:(NSString *)description {
    if (description) {
        return [[self alloc] initWithDomain:DXClientRequestErrorDomain
                                       code:code
                                   userInfo:@{DXClientRequestOriginErrorDescriptionKey : description}];
    } else {
        return [[self alloc] initWithDomain:DXClientRequestErrorDomain
                                       code:code
                                   userInfo:nil];
    }
}

+ (NSDictionary *)errorDefinitions {
    return @{
             @(DXClientRequestErrorNetworkError)            : @"网络状况不佳",
             @(DXClientRequestErrorNetworkNotConnected)     : @"互联网未连接",
             @(DXClientRequestErrorNetworkCanceled)         : @"已取消网络请求",
             @(DXClientRequestErrorServerResponseNotJSON)   : @"服务器响应格式不正确",
             @(DXClientRequestErrorServerInternalError)     : @"服务器出错",
             @(DXClientRequestErrorRequestInvalid)          : @"无效的请求",
             @(DXClientRequestErrorUserSessionInvalid)      : @"用户未登录或需要重新登录"
            };
}

+ (NSDictionary *)errorComments {
    return @{
             @(DXClientRequestErrorNetworkError)            : @"Network Error",
             @(DXClientRequestErrorNetworkNotConnected)     : @"Network Not Connected",
             @(DXClientRequestErrorNetworkCanceled)         : @"Network Request Canceled",
             @(DXClientRequestErrorServerResponseNotJSON)   : @"Remover Server Response Format Is Wrong",
             @(DXClientRequestErrorServerInternalError)     : @"Remote Server Error",
             @(DXClientRequestErrorRequestInvalid)          : @"Request Invalid",
             @(DXClientRequestErrorUserSessionInvalid)      : @"User Needs To Login"
             };
}

+ (DXClientRequestErrorCode)codeFromNSURLErrorCode:(NSInteger)code {
    DXClientRequestErrorCode simplifiedCode = DXClientRequestErrorNetworkError;
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            simplifiedCode = DXClientRequestErrorNetworkNotConnected;
            break;
        case NSURLErrorCancelled:
        case NSURLErrorUserCancelledAuthentication:
            simplifiedCode = DXClientRequestErrorNetworkCanceled;
            break;
        case NSURLErrorBadURL:
        case NSURLErrorUnsupportedURL:
        case NSURLErrorHTTPTooManyRedirects:
        case NSURLErrorRedirectToNonExistentLocation:
        case NSURLErrorBadServerResponse:
        case NSURLErrorUserAuthenticationRequired:
        case NSURLErrorCannotDecodeRawData:
        case NSURLErrorCannotDecodeContentData:
        case NSURLErrorCannotParseResponse:
            simplifiedCode = DXClientRequestErrorServerInternalError;
            break;
        case NSURLErrorCannotFindHost:
        case NSURLErrorZeroByteResource:
        default:
            simplifiedCode = DXClientRequestErrorNetworkError;
            break;
    }
    return simplifiedCode;
}

- (NSString *)localizedDescription {
    if ([self.userInfo objectForKey:DXClientRequestOriginErrorDescriptionKey]) {
        return [self.userInfo objectForKey:DXClientRequestOriginErrorDescriptionKey];
    } else {
        NSDictionary * errorDefinitions = [[self class] errorDefinitions];
        return [errorDefinitions objectForKey:@(self.code)];
    }
}

- (NSString *)originErrorDescription {
    return [self.userInfo objectForKey:DXClientRequestOriginErrorDescriptionKey];
}

@end
