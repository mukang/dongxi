//
//  DXFeedHeaderViewV2.h
//  dongxi
//
//  Created by 穆康 on 16/8/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXFeedHeaderViewV2Delegate;

@interface DXFeedHeaderViewV2 : UICollectionReusableView

@property (nonatomic, strong) DXFeed *feed;
@property (nonatomic, assign) DXUserRelationType relation;
@property (nonatomic, weak) id<DXFeedHeaderViewV2Delegate> delegate;

@end

@protocol DXFeedHeaderViewV2Delegate <NSObject>

@optional

- (void)feedHeaderViewV2:(DXFeedHeaderViewV2 *)view didTapAvatarViewWithFeed:(DXFeed *)feed;
- (void)feedHeaderViewV2:(DXFeedHeaderViewV2 *)view didTapNickBtnWithFeed:(DXFeed *)feed;
- (void)feedHeaderViewV2:(DXFeedHeaderViewV2 *)view didTapFollowBtnWithFeed:(DXFeed *)feed;

@end
