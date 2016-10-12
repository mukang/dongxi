//
//  DXTagCreateOrDeleteTagRelationRequest.m
//  dongxi
//
//  Created by 穆康 on 16/1/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagCreateOrDeleteTagRelationRequest.h"

@implementation DXTagCreateOrDeleteTagRelationRequest

- (void)setCreate_ids:(NSArray *)create_ids {
    _create_ids = create_ids;
    
    if (create_ids) {
        [self setValue:create_ids forParam:@"create_ids"];
    }
}

- (void)setDelete_ids:(NSArray *)delete_ids {
    _delete_ids = delete_ids;
    
    if (delete_ids) {
        [self setValue:delete_ids forParam:@"delete_ids"];
    }
}

@end
