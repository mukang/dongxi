//
//  DXFeed.m
//  dongxi
//
//  Created by 穆康 on 16/8/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeed.h"

@implementation DXFeed

+ (NSDictionary *)objectClassInDictionary{
    return @{
             @"recommend"   : [DXFeedRecommend class],
             @"creator"     : [DXUser class],
             @"current_user": [DXUser class]
             };
}

+ (NSDictionary *)objectClassInArray{
    return @{
             @"topics" : [DXTopic class],
             @"photos" : [DXFeedPhotoInfo class]
             };
}

@end


@implementation DXFeedPhotoInfo

@end


@implementation DXFeedRecommend

@end
