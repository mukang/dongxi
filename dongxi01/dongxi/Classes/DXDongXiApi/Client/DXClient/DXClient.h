//
//  DXClient.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXClientRequest;
@class DXClientResponse;
@protocol DXClientDelegate;
@protocol DXClientRequestSigner;


#pragma mark - Class DXClient

@interface DXClient : NSObject

@property (nonatomic, weak) id<DXClientDelegate> delegate;

+ (instancetype)client;

- (void)setRequestSigner:(id<DXClientRequestSigner>)signer;

- (void)send:(DXClientRequest *)clientRequest;

- (void)send:(DXClientRequest *)clientRequest progress:(void(^)(float percent))progressBlock finish:(void(^)(DXClientResponse * response))responseBlock;

@end


#pragma mark - Protocol DXClientDelegate

@protocol DXClientDelegate <NSObject>

@optional

- (NSDictionary *)client:(DXClient *)client prepareSignParamsWithRequest:(DXClientRequest *)request;

- (void)client:(DXClient *)client willSentRequest:(DXClientRequest *)request;

- (void)client:(DXClient *)client didSendDataByPercent:(float)percent forRequest:(DXClientRequest *)request;

- (void)client:(DXClient *)client didGetReponse:(DXClientResponse *)response forRequest:(DXClientRequest *)request;


@end