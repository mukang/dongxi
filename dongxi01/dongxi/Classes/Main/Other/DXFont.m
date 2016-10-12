//
//  DXFont.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFont.h"

const CGFloat DXFontWeightLight         = -0.5f;
const CGFloat DXFontWeightRegular       = 0;
const CGFloat DXFontWeightBold          = 0.5f;

@implementation DXFont

+ (instancetype)fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (screenWidth < 414) {
        fontSize = fontSize * screenWidth / 414.0;
    }
    id font = [super fontWithName:fontName size:fontSize];
    return font;
}


+ (UIFont *)systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (screenWidth < 414) {
        fontSize = fontSize * screenWidth / 414.0;
    }
    
    if (&UIFontWeightThin != NULL) {
        if (weight == DXFontWeightLight) {
            weight = UIFontWeightLight;
        } else if (weight == DXFontWeightBold) {
            weight = UIFontWeightBold;
        } else {
            weight = UIFontWeightRegular;
        }
        return [super systemFontOfSize:fontSize weight:weight];
    } else {
        UIFont * systemFont = [UIFont systemFontOfSize:fontSize];
        return systemFont;
    }
}

+ (instancetype)dxDefaultFontWithSize:(CGFloat)fontSize {
    return (DXFont *)[[self class] fontWithName:@"FZLTXHJW--GB1-0" size:fontSize];
}

+ (instancetype)dxDefaultBoldFontWithSize:(CGFloat)fontSize {
    return (DXFont *)[[self class] fontWithName:@"FZLTHJW--GB1-0" size:fontSize];
}

@end
