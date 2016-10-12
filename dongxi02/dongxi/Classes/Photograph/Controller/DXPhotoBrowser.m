//
//  DXPhotoBrowser.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoBrowser.h"
#import <MWPhotoBrowser/MWPhotoBrowserPrivate.h>

@implementation DXPhotoBrowser {
    UIImage * _navBarShadowImage;
    NSDictionary * _navBarTitleTextAttributes;
}

- (void)setNavBarAppearance:(BOOL)animated {
    [super setNavBarAppearance:animated];
    
    self.navigationController.navigationBar.tintColor = DXCommonColor;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
}

- (void)storePreviousNavBarAppearance {
    [super storePreviousNavBarAppearance];

    _navBarTitleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
    _navBarShadowImage = self.navigationController.navigationBar.shadowImage;
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    [super restorePreviousNavBarAppearance:animated];

    self.navigationController.navigationBar.shadowImage = _navBarShadowImage;
    self.navigationController.navigationBar.titleTextAttributes = _navBarTitleTextAttributes;
}


@end
