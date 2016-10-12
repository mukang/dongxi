//
//  DXCommentList.m
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCommentList.h"
#import "DXComment.h"

@implementation DXCommentList

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [DXComment class]};
}

@end
