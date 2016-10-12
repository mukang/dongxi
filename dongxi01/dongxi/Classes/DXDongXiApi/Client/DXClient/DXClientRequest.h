//
//  DXClientRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXClient.h"
#import "DXClientConfig.h"

typedef enum : NSUInteger {
    DXClientRequestPriorityLow = 0,
    DXClientRequestPriorityHigh
} DXClientRequestPriority;

typedef NS_ENUM(NSInteger, DXClientRequestVersion) {
    DXClientRequestVersion1 = 0,
    DXClientRequestVersion2
};

#pragma mark - Protocol DXClientRequest

@class DXClientPostForm;

@protocol DXClientRequest <NSObject>

@optional

- (void)prepareToSend;

- (DXClientPostForm *)postFormForRequestData:(NSDictionary *)requestData andFiles:(NSArray *)files;

@required

- (void)setValue:(id)value forParam:(NSString *)name;

- (id)valueForParam:(NSString *)name;

- (NSDictionary *)params;

- (void)addFile:(NSURL *)fileURL;

- (NSArray *)files;

- (NSString *)httpMethod;

@end



#pragma mark - Class DXClientRequest

@interface DXClientRequest : NSObject <DXClientRequest, DXClientDelegate>

/** 请求优先级 */
@property (nonatomic, assign) DXClientRequestPriority priority;
/** 超时时长（默认值20s） */
@property (nonatomic, assign) NSTimeInterval timeout;
/** 请求版本 */
@property (nonatomic, assign) DXClientRequestVersion version;
/** 请求方式 */
@property (nonatomic, copy) NSString *HTTPMethod;

@property (nonatomic, copy) NSDictionary * userInfo;

+ (instancetype)requestWithApi:(NSString *)apiName;

- (NSString *)requestIdentifier;

- (NSString *)apiName;

@end

