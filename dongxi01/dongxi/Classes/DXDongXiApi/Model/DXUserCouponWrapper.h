//
//  DXUserCouponWrapper.h
//  dongxi
//
//  Created by 穆康 on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXUserCouponWrapper : NSObject

/*! 邀请码数组 */
@property (nonatomic, strong) NSArray *list;
/** 本组里的可用数量 */
@property (nonatomic, assign) NSInteger availableCount;

@end
