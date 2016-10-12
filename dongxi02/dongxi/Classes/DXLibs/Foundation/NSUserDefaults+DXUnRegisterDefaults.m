//
//  NSUserDefaults+DXUnRegisterDefaults.m
//  dongxi
//
//  Created by Xu Shiwen on 16/3/17.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "NSUserDefaults+DXUnRegisterDefaults.h"

@implementation NSUserDefaults (DXUnRegisterDefaults)

- (void)unregisterDefaultForKey:(NSString *)defaultName {
    NSDictionary *registeredDefaults = [[NSUserDefaults standardUserDefaults] volatileDomainForName:NSRegistrationDomain];
    if ([registeredDefaults objectForKey:defaultName] != nil) {
        NSMutableDictionary *mutableCopy = [NSMutableDictionary dictionaryWithDictionary:registeredDefaults];
        [mutableCopy removeObjectForKey:defaultName];
        [self replaceRegisteredDefaults:[mutableCopy copy]];
    }
}

- (void)replaceRegisteredDefaults:(NSDictionary *)dictionary {
    [[NSUserDefaults standardUserDefaults] setVolatileDomain:dictionary forName:NSRegistrationDomain];
}

@end
