//
//  DXMessageModel.m
//  dongxi
//
//  Created by 穆康 on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageModel.h"

@implementation DXMessageModel

- (NSString *)messageId
{
    return _message.messageId;
}

- (MessageDeliveryState)status
{
    return _message.deliveryState;
}

@end
