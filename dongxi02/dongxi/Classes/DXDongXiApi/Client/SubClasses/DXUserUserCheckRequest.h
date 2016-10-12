//
//  DXUserUserCheckRequest.h
//  dongxi
//
//  Created by 穆康 on 16/2/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXUserUserCheckRequest : DXClientRequest

/** 检查类型 */
@property (nonatomic, assign) DXUserCheckType type;
/** build版本号 */
@property (nonatomic, assign) NSUInteger build;

@end
