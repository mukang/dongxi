//
//  DXUserCouponUseRequest.h
//  dongxi
//
//  Created by 穆康 on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXUserCouponUseRequest : DXClientRequest

@property (nonatomic, copy) NSString *code;

@end
