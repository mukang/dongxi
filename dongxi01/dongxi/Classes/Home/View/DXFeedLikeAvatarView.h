//
//  DXFeedLikeAvatarView.h
//  dongxi
//
//  Created by 穆康 on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTimelineFeed;

@interface DXFeedLikeAvatarView : UIView

/** feed */
@property (nonatomic, strong) DXTimelineFeed *feed;

/**
 *  视图高度
 */
+ (CGFloat)heightForLikeAvatarViewWithFeed:(DXTimelineFeed *)feed;

@end
