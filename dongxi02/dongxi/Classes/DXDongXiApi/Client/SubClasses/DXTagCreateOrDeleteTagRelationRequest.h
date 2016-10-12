//
//  DXTagCreateOrDeleteTagRelationRequest.h
//  dongxi
//
//  Created by 穆康 on 16/1/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTagCreateOrDeleteTagRelationRequest : DXClientRequest

/** 新增的标签id数组 */
@property (nonatomic, strong) NSArray *create_ids;
/** 删除的标签id数组 */
@property (nonatomic, strong) NSArray *delete_ids;

@end
