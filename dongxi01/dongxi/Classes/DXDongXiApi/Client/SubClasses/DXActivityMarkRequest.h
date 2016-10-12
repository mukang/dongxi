//
//  DXActivityMarkRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXActivityMarkRequest : DXClientRequest

@property (nonatomic, copy) NSString * activity_id;
@property (nonatomic, assign) NSUInteger star;
@property (nonatomic, copy) NSString * txt;

@end
