//
//  DXReferUserWrapper.m
//  dongxi
//
//  Created by 穆康 on 16/5/9.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXReferUserWrapper.h"

@implementation DXReferUserWrapper

+ (NSDictionary *)objectClassInArray{
    return @{@"referUsers" : [DXUser class]};
}

@end
