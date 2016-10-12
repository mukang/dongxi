//
//  DXTopicRankingListRequest.h
//  dongxi
//
//  Created by 穆康 on 16/2/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

/**
 *  @author mukang, 16-02-18
 *
 *  话题用户积分排行榜请求
 */
@interface DXTopicRankingListRequest : DXClientRequest

@property (nonatomic, copy) NSString *topic_id;

@end
