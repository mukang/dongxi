//
//  DXTimelineFeed+User.h
//  dongxi
//
//  Created by 穆康 on 15/11/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTimelineFeed.h"

@interface DXTimelineFeed (User)

/**
 *  是否是当前登录用户发布的
 */
- (BOOL)isPublishedByCurrentLoginUser;

@end
