//
//  UIBarButtonItem+Extension.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)

+ (instancetype)itemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = (CGRect){CGPointZero, button.currentImage.size};
    return [[self alloc] initWithCustomView:button];
}

+ (instancetype)itemWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName target:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = (CGRect){CGPointZero, button.currentImage.size};
    return [[self alloc] initWithCustomView:button];
}

@end
