//
//  DXTopAndHotTopicList.h
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTopAndHotTopicList : NSObject

/** 获取到的热门话题个数 */
@property (nonatomic, assign) NSInteger count;
/** 是否有更多的热门话题(该字段已废弃) */
@property (nonatomic, assign) BOOL more;
/** 推荐话题列表 */
@property (nonatomic, strong) NSArray *top;
/** 热门话题列表 */
@property (nonatomic, strong) NSArray *list;

@end
