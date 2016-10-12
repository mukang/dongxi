//
//  DXTextPart.h
//  dongxi
//
//  Created by 穆康 on 15/10/14.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DXRichTextType) {
    DXRichTextTypeNick = 0,                    // 昵称
    DXRichTextTypeTopic                        // 话题
};

@interface DXTextPart : NSObject

/**
 *  正文的一部分
 */
@property (nonatomic, copy) NSString *text;
/**
 *  当前文本所在的范围
 */
@property (nonatomic, assign)  NSRange range;
/**
 *  是否是特殊字符串
 */
@property (nonatomic, assign, getter=isSpecial) BOOL special;
/**
 *  是否是表情
 */
@property (nonatomic, assign, getter=isEmotion) BOOL emotion;
/**
 *  文本类型
 */
@property (nonatomic, assign) DXRichTextType textType;

@end
