//
//  DXDiscoverUserWrapper.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXDiscoverUserWrapper : NSObject

@property (nonatomic, assign) NSInteger count;

/*! DXDiscoverUser对象数组 */
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, assign) BOOL more;

@end
