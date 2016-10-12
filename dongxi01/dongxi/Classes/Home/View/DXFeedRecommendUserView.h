//
//  DXFeedRecommendUserView.h
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DXFeedRecommendUserViewDelegate;

@interface DXFeedRecommendUserView : UIView

@property (nonatomic, strong) DXUser *user;
@property (nonatomic, weak) id<DXFeedRecommendUserViewDelegate> delegate;

@end




@protocol DXFeedRecommendUserViewDelegate <NSObject>

@optional
- (void)feedRecommendUserView:(DXFeedRecommendUserView *)view didTapAvatarViewWithUser:(DXUser *)user;

@end
