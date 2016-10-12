//
//  DXTimelineTopicFansListRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTimelineTopicFansListRequest : DXClientRequest

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy) NSString *last_id;

@property (nonatomic, copy) NSString *topic_id;

@end
