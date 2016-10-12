//
//  DXCommentCreateRequest.m
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCommentCreateRequest.h"

@implementation DXCommentCreateRequest

- (void)setCommentPost:(NSDictionary *)commentPost {
    _commentPost = commentPost;
    for (NSString *name in commentPost) {
        [self setValue:[commentPost objectForKey:name] forParam:name];
    }
}

@end
