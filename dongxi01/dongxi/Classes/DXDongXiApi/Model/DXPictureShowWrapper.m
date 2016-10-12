//
//  DXPictureShowWrapper.m
//  dongxi
//
//  Created by 穆康 on 15/10/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPictureShowWrapper.h"
#import "DXPictureShow.h"

@implementation DXPictureShowWrapper

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXPictureShow class]};
}

@end
