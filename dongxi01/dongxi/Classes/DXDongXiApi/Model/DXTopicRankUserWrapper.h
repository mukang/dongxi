//
//  DXTopicRankUserWrapper.h
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 话题用户积分排行榜 */
@interface DXTopicRankUserWrapper : NSObject

/** 排行榜的限制人数 */
@property (nonatomic, assign) NSUInteger limit;
/** 排行榜 */
@property (nonatomic, strong) NSArray *list;

@end
