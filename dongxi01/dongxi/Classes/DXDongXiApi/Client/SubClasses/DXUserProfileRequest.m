//
//  DXUserProfileRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserProfileRequest.h"

@implementation DXUserProfileRequest

- (void)setUid:(NSString *)uid {
    _uid = uid;
    [self setValue:uid forParam:@"uid"];
}

@end