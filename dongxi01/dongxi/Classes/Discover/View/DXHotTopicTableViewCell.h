//
//  DXHotTopicTableViewCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXHotTopicTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel * topicLabel;
/** 副标题 */
@property (nonatomic, strong) UILabel *subTitleLabel;
/** 活跃度 */
@property (nonatomic, strong) UILabel *activenessLabel;
/** 是否收藏 */
@property (nonatomic, assign) BOOL isCollected;
/** 是否是有奖话题 */
@property (nonatomic, assign) BOOL hasPrize;
/** 活跃度 */
@property (nonatomic, assign) NSUInteger activeness;

@property (nonatomic, strong) UIImageView * coverImageView;

@end
