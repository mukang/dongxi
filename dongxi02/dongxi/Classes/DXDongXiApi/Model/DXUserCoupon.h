//
//  DXUserCoupon.h
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXUserCoupon : NSObject

/** 邀请码 */
@property (nonatomic, copy) NSString *coupon_id;
/** 是否被分享 */
@property (nonatomic, assign, getter=isShared) BOOL share;

@end
