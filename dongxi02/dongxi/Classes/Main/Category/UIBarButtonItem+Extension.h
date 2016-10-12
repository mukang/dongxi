//
//  UIBarButtonItem+Extension.h
//  dongxi
//
//  Created by 邱思雨 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)

/**
 *  创建一个拥有1张图片的item
 *
 *  @param imageName 普通图片
 *  @param target    点击item后会调用target的action方法
 *  @param action    点击item后会调用target的action方法
 */
+ (instancetype)itemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
/**
 *  创建一个拥有2张图片的item
 *
 *  @param imageName     普通图片
 *  @param highlightedImageName 高亮图片
 *  @param target    点击item后会调用target的action方法
 *  @param action    点击item后会调用target的action方法
 */
+ (instancetype)itemWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName target:(id)target action:(SEL)action;
@end
