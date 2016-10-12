//
//  DXUser.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUser.h"
#import "NSObject+DXModel.h"

@implementation DXUser

- (NSString *)description {
    return [NSString stringWithFormat:@"uid: %@, nick: %@, avatar: %@, py: %@, relations: %ld",
            self.uid,
            self.nick,
            self.avatar,
            self.py,
            (unsigned long)self.relations];
}


@end
