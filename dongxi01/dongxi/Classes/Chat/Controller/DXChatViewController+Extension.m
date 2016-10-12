//
//  DXChatViewController+Extension.m
//  dongxi
//
//  Created by 穆康 on 15/9/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatViewController+Extension.h"

@implementation DXChatViewController (Extension)

- (void)registerBecomeActive {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didBecomeActive {
    
    [self reloadData];
}

@end
