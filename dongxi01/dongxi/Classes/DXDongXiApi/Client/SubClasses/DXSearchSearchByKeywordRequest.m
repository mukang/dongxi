//
//  DXSearchSearchByKeywordRequest.m
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchSearchByKeywordRequest.h"

@implementation DXSearchSearchByKeywordRequest

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    
    if (keyword) {
        [self setValue:keyword forParam:@"keyword"];
    }
}

@end
