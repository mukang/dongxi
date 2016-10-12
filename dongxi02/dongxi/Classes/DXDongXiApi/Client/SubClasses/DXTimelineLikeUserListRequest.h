//
//  DXTimelineLikeUserListRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTimelineLikeUserListRequest : DXClientRequest

@property (nonatomic, copy) NSString * fid;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, copy) NSString * last_id;
@property (nonatomic, assign) NSInteger flag;

@end
