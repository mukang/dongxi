//
//  NSObject+Extension.m
//  webView.url-Demo
//
//  Created by 穆康 on 16/6/28.
//  Copyright © 2016年 穆康. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects {
    
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    
    if (signature == nil) {
        [NSException raise:@"严重错误" format:@"(%@)方法找不到", NSStringFromSelector(selector)];
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    
    NSInteger paramsCount = signature.numberOfArguments - 2;
    paramsCount = MIN(paramsCount, objects.count);
    for (NSInteger i=0; i<paramsCount; i++) {
        id object = objects[i];
        if ([object isKindOfClass:[NSNull class]]) continue;
        [invocation setArgument:&object atIndex:i+2];
    }
    
    [invocation invoke];
    
    id returnValue = nil;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&returnValue];
    }
    
    return returnValue;
}

@end
