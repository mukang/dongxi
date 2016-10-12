//
//  DXRichTextView.m
//  dongxi
//
//  Created by 穆康 on 15/10/14.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRichTextView.h"
#import "RegexKitLite.h"
#import "DXTextPart.h"

#define defaultTextColor   [UIColor blackColor]
#define defaultTextFont    [UIFont systemFontOfSize:15]

CGFloat const richTextViewPadding = 2;
static NSInteger const coverTag = 1008;

@interface DXRichTextView ()

/** 保存所有特殊字符串模型的数组 */
@property (nonatomic, strong) NSMutableArray *specialParts;

@property (nonatomic, strong) DXTextPart *currentTextPart;

@property (nonatomic, assign) BOOL isContain;

@end

@implementation DXRichTextView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.editable = NO;
//        self.selectable = NO;
        self.scrollEnabled = NO;
        self.textContainerInset = UIEdgeInsetsMake(richTextViewPadding, -5, richTextViewPadding, -5);
    }
    return self;
}

- (void)setRichText:(NSString *)richText {
    
    _richText = richText;
    
    // 正则表达式匹配 话题、用户昵称
    NSString *topicPattern = @"#\\w+#";
    NSString *atPattern = @"@\\w+";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@", topicPattern, atPattern];
    
    // 定义数组记录字符串中所有的碎片
    NSMutableArray *specials = [NSMutableArray array];
    
    // 获取匹配的字符串
    [richText enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        DXTextPart *part = [[DXTextPart alloc] init];
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        part.special = YES;
        
        if ([part.text hasPrefix:@"@"]) {
            part.textType = DXRichTextTypeNick;
        } else if ([part.text hasPrefix:@"#"]) {
            part.textType = DXRichTextTypeTopic;
        }
        
        [specials addObject:part];
    }];
    
    // 获取不匹配的字符串
    [richText enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        DXTextPart *part = [[DXTextPart alloc] init];
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        part.special = NO;
        
        [specials addObject:part];
    }];
    
    // 对数组进行排序
    [specials sortUsingComparator:^NSComparisonResult(DXTextPart *obj1, DXTextPart *obj2) {
        
        if (obj1.range.location < obj2.range.location) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    
    // 通过数组中的碎片生成带属性的字符串
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    
    for (DXTextPart *part in specials) {
        
        NSMutableAttributedString *temp = nil;
        
        if (part.isSpecial) {
            UIColor *textColor = self.specialTextColor ? self.specialTextColor : defaultTextColor;
            temp = [[NSMutableAttributedString alloc] initWithString:part.text attributes:@{NSForegroundColorAttributeName: textColor}];
            [self.specialParts addObject:part];
        } else {
            UIColor *textColor = self.nomalTextColor ? self.nomalTextColor : defaultTextColor;
            temp = [[NSMutableAttributedString alloc] initWithString:part.text attributes:@{NSForegroundColorAttributeName: textColor}];
        }
        [str appendAttributedString:temp];
    }
    
    UIFont *textFont = self.richTextFont ? self.richTextFont : defaultTextFont;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:self.textLineSpace];
    [str addAttributes:@{
                         NSFontAttributeName: textFont,
                         NSParagraphStyleAttributeName: paragraphStyle
                         } range:NSMakeRange(0, richText.length)];
    
    self.attributedText = str;
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    NSString *str = self.richText;
    UIFont *textFont = self.richTextFont ? self.richTextFont : defaultTextFont;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:self.textLineSpace];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attStr addAttributes:@{
                            NSFontAttributeName: textFont,
                            NSParagraphStyleAttributeName: paragraphStyle
                            } range:NSMakeRange(0, str.length)];
    CGFloat textH = [attStr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    return CGSizeMake(size.width, textH + richTextViewPadding * 2.0);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 获取手指点击位置
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    
    self.isContain = NO;
    
    for (DXTextPart *part in self.specialParts) {
        
        self.selectedRange = part.range;
        NSArray *rects = [self selectionRectsForRange:self.selectedTextRange];
        // 一定要加上这句！一定要加上这句！一定要加上这句！重要的事情说三遍！！！
        self.selectedRange = NSMakeRange(0, 0);
        
        for (UITextSelectionRect *selectionRect in rects) {
            
            if (CGRectContainsPoint(selectionRect.rect, point)) {
                self.isContain = YES;
                self.currentTextPart = part;
                break;
            }
        }
        
        if (self.isContain) {
            
            for (UITextSelectionRect *selectionRect in rects) {
                if (selectionRect.rect.size.width == 0 ||
                    selectionRect.rect.size.height == 0) {
                    continue;
                }
                // 创建一个蒙版盖住选中的范围
                UIView *cover = [[UIView alloc] init];
                cover.tag = coverTag;
                cover.backgroundColor = DXRGBColor(240, 240, 240);
                cover.frame = selectionRect.rect;
                cover.layer.cornerRadius = 3;
                [self insertSubview:cover atIndex:0];
            }
            break;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UIView *view in self.subviews) {
        if (view.tag == coverTag) {
            [view removeFromSuperview];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf handleTapEvents];
    });
}

- (void)handleTapEvents {
    
    for (UIView *view in self.subviews) {
        if (view.tag == coverTag) {
            [view removeFromSuperview];
        }
    }
    if (self.isContain) {
        switch (self.currentTextPart.textType) {
            case DXRichTextTypeNick:
                if (self.richTextDelegate && [self.richTextDelegate respondsToSelector:@selector(richTextView:didTapNick:)]) {
                    NSString *nick = [self.currentTextPart.text substringWithRange:NSMakeRange(1, self.currentTextPart.text.length - 1)];
                    [self.richTextDelegate richTextView:self didTapNick:nick];
                }
                break;
            case DXRichTextTypeTopic:
                if (self.richTextDelegate && [self.richTextDelegate respondsToSelector:@selector(richTextView:didTapTopic:)]) {
                    NSString *topic = [self.currentTextPart.text substringWithRange:NSMakeRange(1, self.currentTextPart.text.length - 2)];
                    [self.richTextDelegate richTextView:self didTapTopic:topic];
                }
                break;
                
            default:
                break;
        }
    }
}

+ (CGFloat)heightForRichTextViewWithRichText:(NSString *)richText textFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing textWidth:(CGFloat)width {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:richText];
    [attStr addAttributes:@{
                            NSFontAttributeName: font,
                            NSParagraphStyleAttributeName: paragraphStyle
                            } range:NSMakeRange(0, richText.length)];
    CGFloat textH = [attStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    return textH + richTextViewPadding * 2.0f;
}

#pragma mark - 懒加载

- (NSMutableArray *)specialParts {
    
    if (_specialParts == nil) {
        _specialParts = [NSMutableArray array];
    }
    return _specialParts;
}

@end
