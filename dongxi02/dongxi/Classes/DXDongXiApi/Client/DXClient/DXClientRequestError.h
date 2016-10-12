//
//  DXClientRequestError.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DXClientRequestErrorNetworkError = 10001,
    DXClientRequestErrorNetworkNotConnected,
    DXClientRequestErrorServerResponseNotJSON,
    DXClientRequestErrorServerInternalError,
    DXClientRequestErrorRequestInvalid,
    DXClientRequestErrorNetworkCanceled,
    DXClientRequestErrorUserSessionInvalid
} DXClientRequestErrorCode;

extern NSString * const DXClientRequestErrorDomain;
extern NSString * const DXClientRequestOriginErrorDescriptionKey;

/**
 *  代表客户端请求错误的Class，继承NSError
 */
@interface DXClientRequestError : NSError

/**
 *  初始话一个错误对象
 *
 *  @param code        错误码
 *  @param description 原始错误描述
 *
 *  @return 始终返回一个DXClientRequestError实例，domain为DXClientRequestError
 */
+ (instancetype)errorWithCode:(DXClientRequestErrorCode)code andDescription:(NSString *)description;

/**
 *  根据隶属于NSURLErrorDomain的错误码，找到对应的DXClientRequestErrorCode错误码
 *
 *  @param code NSURLErrorDomain的错误码
 *
 *  @return DXClientRequestErrorCode错误码
 */
+ (DXClientRequestErrorCode)codeFromNSURLErrorCode:(NSInteger)code;

/**
 *  获取原始的错误描述
 *
 *  @return 原始错误描述，NSString对象
 */
- (NSString *)originErrorDescription;

@end
