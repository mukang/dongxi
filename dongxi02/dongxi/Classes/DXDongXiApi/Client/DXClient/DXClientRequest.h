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

@property (nonatomic, copy) NSDictionary * userInfo;

+ (instancetype)requestWithApi:(NSString *)apiName;

- (NSString *)requestIdentifier;

- (NSString *)apiName;

@end

