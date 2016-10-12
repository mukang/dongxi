//
//  DXTimelineTopicInviteRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTimelineTopicInviteRequest : DXClientRequest

@property (nonatomic, copy) NSString * topic_id;
@property (nonatomic, copy) NSString * uid;

@end
