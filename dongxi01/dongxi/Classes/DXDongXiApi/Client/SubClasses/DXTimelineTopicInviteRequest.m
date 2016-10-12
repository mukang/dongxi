//
//  DXTimelineTopicInviteRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineTopicInviteRequest.h"

@implementation DXTimelineTopicInviteRequest

- (void)setTopic_id:(NSString *)topic_id {
    _topic_id = topic_id;
    
    [self setValue:topic_id forParam:@"topic_id"];
}

- (void)setUid:(NSString *)uid {
    _uid = uid;
    
    [self setValue:uid forParam:@"uid"];
}

@end
