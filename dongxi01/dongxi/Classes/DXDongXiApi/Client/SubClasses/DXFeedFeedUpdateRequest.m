//
//  DXFeedFeedUpdateRequest.m
//  dongxi
//
//  Created by 穆康 on 16/5/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedFeedUpdateRequest.h"
#import "DXClientPostForm.h"

@implementation DXFeedFeedUpdateRequest

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

- (DXClientPostForm *)postFormForRequestData:(NSDictionary *)requestData andFiles:(NSArray *)files {
    NSError * err;
    NSData * paramsData = [NSJSONSerialization dataWithJSONObject:requestData options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return nil;
    } else {
        DXClientPostForm * postForm = [DXClientPostForm new];
        [postForm addParams:paramsData name:@"json"];
        
        for (NSURL * fileURL in files) {
            @autoreleasepool {
                NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
                if (fileData) {
                    NSString * fileName = fileURL.lastPathComponent;
                    [postForm addFileData:fileData fileName:fileName];
                }
            }
        }
        return postForm;
    }
}

@end
