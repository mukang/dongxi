//
//  DXTopicCancelTopicLikeRequest.m
//  dongxi
//
//  Created by 穆康 on 16/1/28.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicCancelTopicLikeRequest.h"

@implementation DXTopicCancelTopicLikeRequest

- (void)setTopic_id:(NSString *)topic_id {
    _topic_id = topic_id;
    if (topic_id) {
        [self setValue:topic_id forParam:@"topic_id"];
    }
}

@end
