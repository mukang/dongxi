//
//  DXFont.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat DXFontWeightLight;
extern const CGFloat DXFontWeightRegular;
extern const CGFloat DXFontWeightBold;

@interface DXFont : UIFont

+ (instancetype)dxDefaultFontWithSize:(CGFloat)fontSize;

+ (instancetype)dxDefaultBoldFontWithSize:(CGFloat)fontSize;

/**
 *  返回指定大小、粗细的字体对象
 *
 *  @discussion 在iOS 8.0以下系统使用该方法时，会自动无视weight变量
 *
 *  @param fontSize 字体大小
 *  @param weight   字体粗细，只能使用指定的常量，其他数值都会被当作常规粗细对待
 *
 *  @return 字体对象
 */
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight;

@end
