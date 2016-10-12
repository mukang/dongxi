//
//  DXBarButtonItem.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXBarButtonItem.h"

@implementation DXBarButtonItem {
    __weak UIViewController * _currentController;
}

+ (instancetype)defaultSystemBackItemForController:(UIViewController *)controller {
    DXBarButtonItem * backItem = [[[self class] alloc] init];
    [backItem setImage:[[UIImage imageNamed:@"button_back_navigation"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [backItem setStyle:UIBarButtonItemStylePlain];
    [backItem setTarget:backItem];
    [backItem setAction:@selector(backItemTapped:)];
    backItem->_currentController = controller;
    return backItem;
}

- (void)backItemTapped:(DXBarButtonItem *)sender {
    if (_currentController) {
        [_currentController.navigationController popViewControllerAnimated:YES];
    }
}

@end
