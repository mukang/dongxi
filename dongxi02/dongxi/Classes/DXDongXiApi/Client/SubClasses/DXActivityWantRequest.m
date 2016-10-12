//
//  DXActivityWantRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityWantRequest.h"

@implementation DXActivityWantRequest

- (void)setActivity_id:(NSString *)activity_id {
    _activity_id = activity_id;
    
    [self setValue:activity_id forParam:@"activity_id"];
}

@end
