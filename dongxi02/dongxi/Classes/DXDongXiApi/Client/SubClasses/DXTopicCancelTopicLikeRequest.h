//
//  DXTopicCancelTopicLikeRequest.h
//  dongxi
//
//  Created by 穆康 on 16/1/28.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTopicCancelTopicLikeRequest : DXClientRequest

@property (nonatomic, copy) NSString *topic_id;

@end
