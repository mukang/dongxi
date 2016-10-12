//
//  DXChatRecord.m
//  dongxi
//
//  Created by 穆康 on 15/10/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatRecord.h"

@implementation DXChatRecord

- (void)setChatter:(NSString *)chatter {
    
    _chatter = chatter;
    
    NSString *prefix = @"cuser";
    
    _userID = [chatter substringFromIndex:prefix.length];
}

@end
