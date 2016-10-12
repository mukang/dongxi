//
//  DXFeedRecommendTopicCell.h
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol DXFeedRecommendTopicCellDelegate;

@interface DXFeedRecommendTopicCell : UITableViewCell

@property (nonatomic, strong) DXTimelineRecommendation *recommendation;
@property (nonatomic, weak) id<DXFeedRecommendTopicCellDelegate> delegate;

@end




@protocol DXFeedRecommendTopicCellDelegate <NSObject>

@optional
- (void)feedRecommendTopicCell:(DXFeedRecommendTopicCell *)cell didTapTopicViewWithTopic:(DXTopic *)topic;

@end
