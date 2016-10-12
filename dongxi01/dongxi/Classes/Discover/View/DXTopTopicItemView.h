//
//  DXTopTopicItemView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXTopTopicItemViewDelegate;


@interface DXTopTopicItemView : UIView

@property (nonatomic, strong) UILabel *topTypeLabel;
@property (nonatomic, strong) UILabel * topicLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView * backgroundImageView;

@property (nonatomic, weak) id<DXTopTopicItemViewDelegate> delegate;

@end



@protocol DXTopTopicItemViewDelegate <NSObject>

@optional
- (void)userDidTapTopicItemView:(DXTopTopicItemView *)itemView;

@end