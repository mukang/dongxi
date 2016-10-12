//
//  DXNoticeList.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  消息列表类，用作为DXNotice的容器类，通过api获取的DXNotice一般放在该容易类中
 */
@interface DXNoticeList : NSObject

/** 本次获取到的条数 */
@property (nonatomic, assign) NSUInteger count;

/** 存放DXNotice模型的数组 */
@property (nonatomic, strong) NSArray * list;

/** 是否还有更多，0：没有，1：有 */
@property (nonatomic, assign) BOOL more;

@end
