//
//  DXTopicTopicsRequest.h
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTopicTopicsRequest : DXClientRequest

/** (该字段暂时废弃) */
@property (nonatomic, assign) NSInteger flag;
/** (该字段暂时废弃) */
@property (nonatomic, assign) NSInteger count;
/** (该字段暂时废弃) */
@property (nonatomic, copy) NSString *last_id;

@end
