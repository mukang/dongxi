//
//  DXSearchUserWrapper.h
//  dongxi
//
//  Created by 穆康 on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXSearchUserWrapper : NSObject

/** 获取到的用户个数 */
@property (nonatomic, assign) NSInteger count;
/** 是否有更多的用户 */
@property (nonatomic, assign) BOOL more;
/** 用户列表 */
@property (nonatomic, strong) NSArray *list;

@end
