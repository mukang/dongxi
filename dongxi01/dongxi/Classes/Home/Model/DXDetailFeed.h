//
//  DXDetailFeed.h
//  dongxi
//
//  Created by 穆康 on 15/11/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineFeed.h"
@class DXTimelineFeed;

typedef NS_ENUM(NSInteger, DXDetailFeedType) {
    DXDetailFeedTypePhoto,
    DXDetailFeedTypeText,
    DXDetailFeedTypeLocation,
    DXDetailFeedTypeLike
};

@interface DXDetailFeed : NSObject

@property (nonatomic, assign) DXDetailFeedType feedType;

@property (nonatomic, strong) DXTimelineFeed *feed;

@end
