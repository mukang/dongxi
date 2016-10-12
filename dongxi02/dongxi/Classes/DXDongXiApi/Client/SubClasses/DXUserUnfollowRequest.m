//
//  DXUserUnfollowRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserUnfollowRequest.h"

@implementation DXUserUnfollowRequest

- (void)setUid:(NSString *)uid {
    _uid = uid;
    
    [self setValue:uid forParam:@"follow_uid"];
}

@end
