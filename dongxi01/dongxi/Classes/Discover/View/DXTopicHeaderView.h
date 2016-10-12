//
//  DXTopicHeaderView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXButton.h"

@protocol DXTopicHeaderViewDelegate;

@interface DXTopicHeaderView : UIView

@property (nonatomic, strong) UIImageView * coverImageView;
@property (nonatomic, strong) DXAvatarView * avatarView;
@property (nonatomic, strong) UILabel * topicLabel;
/** 副标题 */
@property (nonatomic, strong) UILabel * subTitleLabel;
/** 是否是有奖话题 */
@property (nonatomic, assign) BOOL hasPrize;
/** 排行榜 */
@property (nonatomic, strong) NSArray *rank;
@property (nonatomic, strong) UILabel * nickLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) NSString * topicText;
@property (nonatomic, strong) DXButton *collectedBtn;

@property (nonatomic, weak) id<DXTopicHeaderViewDelegate> delegate;

@end


@protocol DXTopicHeaderViewDelegate <NSObject>

@optional
- (void)textDidChangeInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView;

- (void)rankViewDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView;

- (void)avatarDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView;

- (void)collectedBtnDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView;

- (void)discussBtnDidTapInTopicHeaderView:(DXTopicHeaderView *)topicHeaderView;

@end