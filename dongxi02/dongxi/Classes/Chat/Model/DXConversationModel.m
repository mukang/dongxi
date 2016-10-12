//
//  DXConversationModel.m
//  dongxi
//
//  Created by 穆康 on 15/11/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXConversationModel.h"

@implementation DXConversationModel

- (instancetype)initWithConversation:(EMConversation *)conversation {
    
    if (self = [super init]) {
        _conversation = conversation;
    }
    return self;
}

@end
