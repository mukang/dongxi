//
//  DXServerResponse.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXClientRequestError.h"

@protocol DXClientResponse <NSObject>

@required
- (instancetype)initWithData:(NSDictionary *)data;
- (instancetype)initWithError:(NSError *)error;
- (NSError *)error;
- (NSDictionary *)data;

@end


@interface DXClientResponse : NSObject <DXClientResponse>

+ (instancetype)responseWithApi:(NSString *)apiName data:(NSDictionary *)data orError:(NSError *)error;

- (void)setResponseStatusCode:(NSInteger)statusCode;

- (NSInteger)reponseStatusCode;

@end
