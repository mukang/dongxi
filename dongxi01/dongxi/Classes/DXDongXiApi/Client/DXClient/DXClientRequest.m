//
//  DXClientRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"
#import "DXClientResponse.h"
#import "DXClient.h"
#import "DXFunctions.h"


@interface DXClientRequest ()

@property (nonatomic, strong) NSString * requestIdentifier;
@property (nonatomic, strong) NSMutableDictionary * requestParams;
@property (nonatomic, strong) NSMutableArray * requestFiles;
@property (nonatomic, strong) NSString * apiName;

@end

@implementation DXClientRequest

#pragma mark - Public Methods

+ (instancetype)requestWithApi:(NSString *)apiName {
    NSParameterAssert(apiName != nil);
    
    NSString * requestClassName = [[self class] requestClassNameForApi:apiName];
    Class requestClass = NSClassFromString(requestClassName);
    NSAssert(requestClass != nil, @"未找到名为%@的类", requestClassName);
    
    return [[requestClass alloc] initWithApiName:apiName];
}

#pragma mark - Protocol DXClientRequest

- (void)setValue:(id)value forParam:(NSString *)name {
    if (name != nil && value != nil) {
        [self.requestParams setObject:value forKey:name];
    }
}

- (id)valueForParam:(NSString *)name {
    return [self.requestParams objectForKey:name];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self setValue:value forParam:key];
}

- (id)valueForKey:(NSString *)key {
    return [self valueForParam:key];
}

- (NSDictionary *)params {
    return [self.requestParams copy];
}

- (void)addFile:(NSURL *)fileURL {
    NSAssert([fileURL isFileURL], @"只能添加本地文件");
    [self.requestFiles addObject:fileURL];
}

- (NSArray *)files {
    return [self.requestFiles copy];
}

- (NSString *)httpMethod {
    if (self.HTTPMethod) {
        return self.HTTPMethod;
    }
    return @"POST";
}

#pragma mark - Private Methods

- (instancetype)initWithApiName:(NSString *)apiName {
    if (self = [super init]) {
        self.apiName = apiName;
        self.requestIdentifier = [[self class] createIdentifier];
        self.timeout = 20;
    }
    return self;
}

+ (NSString *)createIdentifier {
    NSDate * now = [NSDate date];
    int random = arc4random() % 1000;
    NSString * randomString = [NSString stringWithFormat:@"%lu%03d", (unsigned long)[now timeIntervalSince1970], random];
    return DXDigestMD5(randomString);
}

+ (NSString *)requestClassNameForApi:(NSString *)apiName {
    NSArray * nameParts = [apiName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/_"]];
    NSMutableArray * camelizedNameParts = [NSMutableArray array];
    for (NSString * part in nameParts) {
        [camelizedNameParts addObject:[part capitalizedString]];
    }
    return [NSString stringWithFormat:DXCLIENT_REQUEST_CLASS_FORMAT, [camelizedNameParts componentsJoinedByString:@""]];
}

#pragma mark - Override Methods

- (NSMutableDictionary *)requestParams {
    if (nil == _requestParams) {
        _requestParams = [NSMutableDictionary dictionary];
    }
    return _requestParams;
}

- (NSMutableArray *)requestFiles {
    if (nil == _requestFiles) {
        _requestFiles = [NSMutableArray array];
    }
    return _requestFiles;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"request: %@, files: %@", self.params, self.files];
}

- (NSString *)description {
   
    return [self debugDescription];
}


@end
