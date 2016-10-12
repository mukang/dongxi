//
//  DXNoticeCommentList.m
//  dongxi
//
//  Created by 穆康 on 15/11/4.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoticeCommentList.h"
#import "DXNoticeCommentWrapper.h"

@implementation DXNoticeCommentList

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXNoticeCommentWrapper class]};
}

@end
