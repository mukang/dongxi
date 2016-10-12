//
//  NSString+DXConvenient.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  NSString的一些便捷方法的Category
 */
@interface NSString (DXConvenient)

/**
 *  检查字符串是否由空白字符（不包含换行符）组成
 *
 *  @return 如果由空白字符组成返回YES，否则返回NO
 */
- (BOOL)isWhiteSpaces;

/**
 *  检查字符串是否由空白字符（包含换行符）组成
 *
 *  @return 如果由空白字符组成返回YES，否则返回NO
 */
- (BOOL)isWhiteSpacesAndNewLines;

/**
 *  得到中文字数，其中2个英文字符累计1个中文字符，不满2个也算1个
 *
 *  @return 中文字数个数
 */
- (NSUInteger)chineseCharacterLength;


/**
 *  根据指定的中文字数，对当前NSString对象进行截断
 *
 *  @param length 中文字数，其计算规则见-[NSString chineseCharacterLength]
 *
 *  @return 返回截断后的字符串（如果有必要截断的话）
 */
- (NSString *)stringByLimitedToChineseCharacterLength:(NSUInteger)cLength;

@end
