//
//  DXTimelineCreateRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineCreateRequest.h"

@implementation DXTimelineCreateRequest

- (void)setTopicPost:(NSDictionary *)topicPost {
    _topicPost = topicPost;
    for (NSString * name in topicPost) {
        [self setValue:[topicPost objectForKey:name] forParam:name];
    }
}

- (void)setPhotoURLs:(NSArray *)photoURLs {
    for (NSURL * photoURL in photoURLs) {
        [self addFile:photoURL];
    }
}

@end
