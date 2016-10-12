//
//  DXWeChatShareInfo.m
//  dongxi
//
//  Created by 穆康 on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWeChatShareInfo.h"

@implementation DXWeChatShareInfo

- (NSString *)title {
    
    NSInteger len = [_title length];
    
    if (len > 500) {
        
        NSString *tempStr = [_title substringToIndex:500];
        _title = [NSString stringWithFormat:@"%@...", tempStr];
    }
    
    return _title;
}

- (NSString *)desc {
    
    NSInteger len = [_desc length];
    
    if (len > 1000) {
        
        NSString *tempStr = [_desc substringToIndex:1000];
        _desc = [NSString stringWithFormat:@"%@...", tempStr];
    }
    
    return _desc;
}

@end
