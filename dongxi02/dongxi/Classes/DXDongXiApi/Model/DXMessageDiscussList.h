//
//  DXMessageDiscussList.h
//  dongxi
//
//  Created by 穆康 on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  私聊列表类，用作为DXMessageDiscuss的容器类，通过api获取的DXMessageDiscuss一般放在该类中
 */
@interface DXMessageDiscussList : NSObject

/** 本次获取到的条数 */
@property (nonatomic, assign) NSUInteger count;

/** 存放DXMessageDiscuss模型的数组 */
@property (nonatomic, strong) NSArray * list;

/** 是否还有更多，0：没有，1：有 */
@property (nonatomic, assign) BOOL more;

@end
