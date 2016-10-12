//
//  DXUnReadInfo.h
//  dongxi
//
//  Created by 穆康 on 15/11/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUnReadMessageWrapper.h"
#import "DXSingleton.h"

@interface DXUnReadInfo : NSObject

DXSingletonInterface(UnReadInfo)

- (NSInteger)unReadMessageCount;

- (BOOL)addUnReadMessageWithType:(DXUnReadMessageType)type;

- (BOOL)removeUnReadMessageWithType:(DXUnReadMessageType)type;

- (BOOL)cleanAllUnReadMessage;

@end
