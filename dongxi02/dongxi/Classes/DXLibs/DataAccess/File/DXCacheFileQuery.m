//
//  DXCacheFileQuery.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCacheFileQuery.h"

@implementation DXCacheFileQuery

- (void)setName:(NSString *)name {
    _name = [self trimPathString:name returnNilIfEmpty:YES];
}

- (void)setExtension:(NSString *)extension {
    _extension = [self trimPathString:extension returnNilIfEmpty:YES];
}

- (void)setRelativePath:(NSString *)relativePath {
    _relativePath = [self trimPathString:relativePath returnNilIfEmpty:YES];
}

- (NSString *)trimPathString:(NSString *)pathString returnNilIfEmpty:(BOOL)returnNilIfEmpty {
    pathString = [pathString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    pathString = [pathString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    if (pathString.length == 0 && returnNilIfEmpty) {
        return nil;
    } else {
        return pathString;
    }
}

@end
