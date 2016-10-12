//
//  DXFeedRecommendUserCell.h
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DXFeedRecommendUserCellDelegate;

@interface DXFeedRecommendUserCell : UITableViewCell

@property (nonatomic, strong) DXTimelineRecommendation *recommendation;
@property (nonatomic, weak) id<DXFeedRecommendUserCellDelegate> delegate;

@end



@protocol DXFeedRecommendUserCellDelegate <NSObject>

@optional
- (void)feedRecommendUserCell:(DXFeedRecommendUserCell *)cell didTapAvatarViewWithUser:(DXUser *)user;

@end
