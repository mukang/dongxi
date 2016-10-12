//
//  DXRefreshAutoFooter.h
//  dongxi
//
//  Created by 穆康 on 15/11/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "MJRefreshAutoFooter.h"

@interface DXRefreshAutoFooter : MJRefreshAutoFooter

@property (nonatomic, copy) NSString * idleText;
@property (nonatomic, copy) NSString * noMoreDataText;
@property (nonatomic, copy) NSString * refreshingText;

/** 网络加载有错误 */
- (void)endRefreshingWithError;

@end
