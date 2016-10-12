//
//  DXFeedHomeListRequest.h
//  dongxi
//
//  Created by 穆康 on 16/8/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXFeedHomeListRequest : DXClientRequest

@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, copy) NSString * last_id;
@property (nonatomic, assign) NSUInteger recommend_user_timestamp;
@property (nonatomic, assign) NSUInteger recommend_topic_timestamp;

@end
