//
//  DXUnReadMessage.h
//  dongxi
//
//  Created by 穆康 on 15/11/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DXUnReadMessageType) {
    DXUnReadMessageTypeComment,
    DXUnReadMessageTypeLike,
    DXUnReadMessageTypeNotice,
    DXUnReadMessageTypeChat
};

@interface DXUnReadMessage : NSObject

/** 未读的消息类型 */
@property (nonatomic, assign) DXUnReadMessageType type;



@end
