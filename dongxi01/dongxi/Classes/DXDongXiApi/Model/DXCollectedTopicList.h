//
//  DXCollectedTopicList.h
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXCollectedTopicList : NSObject

/** 获取到的收藏话题个数 */
@property (nonatomic, assign) NSInteger count;
/** 是否有更多的收藏话题 */
@property (nonatomic, assign) BOOL more;
/** 收藏话题列表 */
@property (nonatomic, strong) NSArray *list;

@end
