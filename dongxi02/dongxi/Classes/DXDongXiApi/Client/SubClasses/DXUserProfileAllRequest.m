//
//  DXUserProfileAllRequest.m
//  dongxi
//
//  Created by 穆康 on 15/10/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserProfileAllRequest.h"

@implementation DXUserProfileAllRequest

- (void)setUid_all:(NSArray *)uid_all {
    
    _uid_all = uid_all;
    
    if (uid_all) {
        [self setValue:uid_all forParam:@"uid_all"];
    }
}

@end
