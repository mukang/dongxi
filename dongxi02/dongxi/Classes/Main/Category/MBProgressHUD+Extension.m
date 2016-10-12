//
//  MBProgressHUD+Extension.m
//  dongxi
//
//  Created by 穆康 on 16/3/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)

+ (void)showHUDWithMessage:(NSString *)message {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
//    hud.labelFont = [DXFont dxDefaultFontWithSize:18];
    [hud hide:YES afterDelay:2.0];
}

@end
