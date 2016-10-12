//
//  DXTag.h
//  dongxi
//
//  Created by 穆康 on 16/1/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTag : NSObject

/** 标签ID */
@property (nonatomic, copy) NSString *ID;
/** 标签名字 */
@property (nonatomic, copy) NSString *name;
/** 标签状态 0未关注 1已关注 */
@property (nonatomic, assign) NSInteger status;

@end
