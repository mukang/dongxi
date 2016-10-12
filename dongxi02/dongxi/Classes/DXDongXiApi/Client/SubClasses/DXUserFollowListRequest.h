//
//  DXUserFollowListRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXUserFollowListRequest : DXClientRequest

@property (nonatomic, copy) NSString * uid;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, copy) NSString * last_id;
@property (nonatomic, assign) NSUInteger flag;

@end
