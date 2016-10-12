//
//  DXMessageModelManager.h
//  dongxi
//
//  Created by 穆康 on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXMessageModel.h"

@interface DXMessageModelManager : NSObject

+ (id)modelWithMessage:(EMMessage *)message;

@end
