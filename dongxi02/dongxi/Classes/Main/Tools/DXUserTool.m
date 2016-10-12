//
//  DXUserTool.m
//  dongxi
//
//  Created by 穆康 on 15/8/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#define DXUserPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.data"]

#import "DXUserTool.h"

@implementation DXUserTool

+ (void)save:(DXUser *)user {
    
    [NSKeyedArchiver archiveRootObject:user toFile:DXUserPath];
}

+ (DXUser *)user {
    
    DXUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:DXUserPath];
    
//    NSTimeInterval nowtime = [NSDate date].timeIntervalSince1970;
//    
//    if (nowtime > user.validtime) {
//        return nil;
//    }
    
    return user;
}

@end
