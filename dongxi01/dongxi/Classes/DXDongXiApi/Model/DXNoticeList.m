//
//  DXNoticeList.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoticeList.h"
#import "DXNotice.h"

@implementation DXNoticeList

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXNotice class]};
}


@end
