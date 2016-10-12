//
//  DXTimelineHotListRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTimelineHotListRequest : DXClientRequest

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, copy) NSString * last_id;
@property (nonatomic, assign) NSUInteger flag;
@property (nonatomic, assign) NSUInteger recommend_user_timestamp;
@property (nonatomic, assign) NSUInteger recommend_topic_timestamp;

@end
