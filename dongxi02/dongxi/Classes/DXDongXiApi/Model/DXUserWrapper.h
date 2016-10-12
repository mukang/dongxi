//
//  DXUserWrapper.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXUserWrapper : NSObject

@property (nonatomic, assign) NSInteger count;

/*! DXUser对象数组 */
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, assign) BOOL more;


@end
