//
//  DXSearchFeedWrapper.h
//  dongxi
//
//  Created by 穆康 on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXSearchFeedWrapper : NSObject

/** 获取到的feed个数 */
@property (nonatomic, assign) NSInteger count;
/** 是否有更多的feed */
@property (nonatomic, assign) BOOL more;
/** feed列表 */
@property (nonatomic, strong) NSArray *list;

@end
