//
//  DXMessageDiscussListByUserRequest.h
//  dongxi
//
//  Created by 穆康 on 15/9/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXMessageDiscussListByUserRequest : DXClientRequest

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) NSInteger get_count;

@property (nonatomic, copy) NSString *last_id;

@end
