//
//  DXFeedTimelineRequest.h
//  dongxi
//
//  Created by 穆康 on 16/3/8.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXFeedTimelineRequest : DXClientRequest

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, copy) NSString * last_id;
@property (nonatomic, assign) NSUInteger flag;
@property (nonatomic, copy) NSString *filter;

@end
