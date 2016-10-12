//
//  DXServerResponse.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"
#import "DXClientConfig.h"
#import <objc/runtime.h>
#import "NSObject+DXModel.h"

@interface DXClientResponse()

@property (nonatomic, strong) NSError * error;
@property (nonatomic, strong) NSDictionary * data;

@end

@implementation DXClientResponse {
    NSInteger _responseStatusCode;
}

#pragma mark - Protocol DXClientResponse

- (instancetype)initWithData:(NSDictionary *)data {
    self = [self initWithObjectDictionary:data];
    self.data = data;
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    if (self = [super init]) {
        self.error = error;
    }
    return self;
}

#pragma mark - Public Methods

+ (instancetype)responseWithApi:(NSString *)apiName data:(NSDictionary *)data orError:(NSError *)error{
    NSString * responseClassName = [[self class] responseClassNameForApi:apiName];
    Class responseClass = NSClassFromString(responseClassName);
    NSAssert(responseClass != nil, @"未找到名为%@的类", responseClassName);
    if (!error) {
        return [[responseClass alloc] initWithData:data];
    } else {
        return [[responseClass alloc] initWithError:error];
    }
}

- (void)setResponseStatusCode:(NSInteger)statusCode {
    _responseStatusCode = statusCode;
}

- (NSInteger)reponseStatusCode {
    return _responseStatusCode;
}


#pragma mark - Private Methods

+ (NSString *)responseClassNameForApi:(NSString *)apiName {
    NSArray * nameParts = [apiName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/_"]];
    NSMutableArray * camelizedNameParts = [NSMutableArray array];
    for (NSString * part in nameParts) {
        [camelizedNameParts addObject:[part capitalizedString]];
    }
    return [NSString stringWithFormat:DXCLIENT_RESPONSE_CLASS_FORMAT, [camelizedNameParts componentsJoinedByString:@""]];
}

#pragma mark - Override Methods

- (NSString *)description {
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        const char *c_propertyName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:c_propertyName encoding:[NSString defaultCStringEncoding]];
        [info setObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    free(propertyList);
    return [NSString stringWithFormat:@"%@ : %@, statusCode: %ld", [self class], info, (long)[self reponseStatusCode]];
}


@end
