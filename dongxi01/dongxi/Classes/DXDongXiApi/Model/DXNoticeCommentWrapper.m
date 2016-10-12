//
//  DXNoticeCommentWrapper.m
//  dongxi
//
//  Created by 穆康 on 15/11/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoticeCommentWrapper.h"
#import "DXNoticeComment.h"

@implementation DXNoticeCommentWrapper

+ (NSDictionary *)objectClassInDictionary{
    return @{@"comment" : [DXNoticeComment class]};
}

@end
