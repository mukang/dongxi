//
//  DXTopicTopicLikesRequest.h
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTopicTopicLikesRequest : DXClientRequest

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy) NSString *last_id;

@end
