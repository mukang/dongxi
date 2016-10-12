//
//  DXClientRequestSigner.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXClientRequest;

#pragma mark - Protocol DXClientRequestSigner;

@protocol DXClientRequestSigner <NSObject>

- (NSDictionary *)signParamsFromRequest:(DXClientRequest *)request;

- (NSDictionary *)signParamsFromRequest:(DXClientRequest *)request withSessionInfo:(NSDictionary *)sessionInfo;

@end


@interface DXClientRequestDefaultSigner : NSObject <DXClientRequestSigner>


@end
