//
//  DXTopicPost.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicPost.h"

@interface DXTopicPost ()

@property (nonatomic, assign) NSUInteger file_count;

@end

@implementation DXTopicPost {
    NSArray * _feedPhotoURLs;
}

- (void)setPhotoURLs:(NSArray *)photoURLs {
    _feedPhotoURLs = photoURLs;
    self.file_count = photoURLs.count;
}

- (NSArray *)photoURLs {
    return _feedPhotoURLs;
}

@end
