//
//  DXTopicRankHeaderView.h
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTopicDetail;

/** 用户积分排行榜视图的头部视图 */
@interface DXTopicRankHeaderView : UIView

@property (nonatomic, strong) DXTopicDetail *topicDetail;
/** 排行个数 */
@property (nonatomic, assign) NSUInteger rankNum;

@end
