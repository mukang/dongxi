//
//  DXTimelineFeed.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineFeed.h"

@implementation DXTimelineFeed

+ (NSDictionary *)objectClassInDictionary{
    return @{@"data" : [DXTimelineFeedContent class]};
}

- (void)setTime:(NSInteger)time {
    
    _time = time;
    
    _getFeedTime = [[NSDate date] timeIntervalSince1970];
}

@end


@implementation DXTimelineFeedContent

+ (NSDictionary *)objectClassInArray{
    return @{
             @"likes" : [DXTimelineFeedLiker class],
             @"tags" : [DXTimelineFeedTag class],
             @"photo" : [DXTimelineFeedPhoto class],
             @"comments" : [DXTimelineFeedComment class],
             @"content_pieces" : [DXContentPiece class]
             };
}

+ (NSDictionary *)objectClassInDictionary{
    return @{@"topic" : [DXTimelineFeedTopicInfo class]};
}

@end


@implementation DXTimelineFeedTopicInfo

- (void)setTopic_id:(NSString *)topic_id {
    _topic_id = topic_id;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *topicID = [userDefaults stringForKey:DX_DEFAULTS_KEY_DEFAULT_TOPIC_ID];
    
    if ([topic_id isEqualToString:topicID]) {
        _topic = nil;
    }
}

@end


@implementation DXTimelineFeedLiker

@end


@implementation DXTimelineFeedTag

@end


@implementation DXTimelineFeedPhoto

@end


@implementation DXTimelineFeedComment

@end
