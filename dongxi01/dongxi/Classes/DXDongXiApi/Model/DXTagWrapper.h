//
//  DXTagWrapper.h
//  dongxi
//
//  Created by 穆康 on 16/1/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTagWrapper : NSObject

/** 存放被收藏的Tag模型的数组 */
@property (nonatomic, strong) NSArray * collected;

/** 存放被全部的Tag模型的数组 */
@property (nonatomic, strong) NSArray * all;

@end
