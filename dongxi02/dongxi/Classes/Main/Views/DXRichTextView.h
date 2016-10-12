//
//  DXRichTextView.h
//  dongxi
//
//  Created by 穆康 on 15/10/14.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXRichTextView;

extern CGFloat const richTextViewPadding;

@protocol DXRichTextViewDelegate <NSObject>

@optional
/**
 *  点击了昵称
 */
- (void)richTextView:(DXRichTextView *)richTextView didTapNick:(NSString *)nick;
/**
 *  点击了话题
 */
- (void)richTextView:(DXRichTextView *)richTextView didTapTopic:(NSString *)topic;

@end

@interface DXRichTextView : UITextView

@property (nonatomic, copy) NSString *richText;

@property (nonatomic, strong) UIColor *specialTextColor;

@property (nonatomic, strong) UIColor *nomalTextColor;

@property (nonatomic, strong) UIFont *richTextFont;

@property (nonatomic, assign) CGFloat textLineSpace;

@property (nonatomic, weak) id<DXRichTextViewDelegate> richTextDelegate;

/**
 *  视图高度
 */
+ (CGFloat)heightForRichTextViewWithRichText:(NSString *)richText textFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing textWidth:(CGFloat)width;

@end
