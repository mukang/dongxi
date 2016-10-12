//
//  DXDiscussCreateRequest.h
//  dongxi
//
//  Created by 穆康 on 15/9/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXDiscussCreateRequest : DXClientRequest

@property (nonatomic, copy) NSString *fid;

@property (nonatomic, copy) NSString *to;

@property (nonatomic, copy) NSString *txt;

@property (nonatomic, assign) BOOL online;

@property (nonatomic, assign) NSInteger type;

@end
