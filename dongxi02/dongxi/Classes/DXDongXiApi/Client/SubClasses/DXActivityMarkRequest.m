//
//  DXActivityMarkRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityMarkRequest.h"

@implementation DXActivityMarkRequest

- (void)setActivity_id:(NSString *)activity_id {
    _activity_id = activity_id;
    
    [self setValue:activity_id forParam:@"activity_id"];
}

- (void)setStar:(NSUInteger)star {
    _star = star;
    
    [self setValue:@(star) forParam:@"star"];
}

- (void)setTxt:(NSString *)txt {
    _txt = txt;
    
    [self setValue:txt forParam:@"txt"];
}

@end
