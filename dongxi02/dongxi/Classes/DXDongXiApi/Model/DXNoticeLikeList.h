//
//  DXNoticeLikeList.h
//  dongxi
//
//  Created by 穆康 on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXNoticeLikeList : NSObject

/** 本次获取到的条数 */
@property (nonatomic, assign) NSUInteger count;

/** 存放DXNoticeLike模型的数组 */
@property (nonatomic, strong) NSArray * list;

/** 是否还有更多，0：没有，1：有 */
@property (nonatomic, assign) BOOL more;

@end
