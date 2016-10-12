//
//  DXChatTextBubbleView.m
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatTextBubbleView.h"
#import <CoreText/CoreText.h>
#import "UIResponder+Router.h"

NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";

#define TEXTLABEL_MAX_WIDTH DXRealValue(200) // textLaebl 最大宽度

@interface DXChatTextBubbleView ()

/** 文字 */
@property (nonatomic, weak) UILabel *textLabel;
/** 解析url */
@property (nonatomic, strong) NSDataDetector *detector;
/** url匹配结果 */
@property (nonatomic, strong) NSArray *urlMatches;

@end

@implementation DXChatTextBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
        textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        textLabel.userInteractionEnabled = NO;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.chatMessage.is_sender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    } else {
        frame.origin.x = BUBBLE_ARROW_WIDTH + BUBBLE_VIEW_PADDING;
    }
    frame.origin.y = BUBBLE_VIEW_PADDING;
    
    [self.textLabel setFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize textBlockDefaultSize = CGSizeMake(TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX);
    CGSize retSize;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];//调整行间距
    retSize = [self.chatMessage.msg boundingRectWithSize:textBlockDefaultSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.textLabel.font, NSParagraphStyleAttributeName: paragraphStyle} context:nil].size;
    
    CGFloat defaultH = DXRealValue(41);
    
    if (BUBBLE_VIEW_PADDING * 2 + retSize.height > defaultH) {
        defaultH = BUBBLE_VIEW_PADDING * 2 + retSize.height;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, defaultH);
}

- (void)setChatMessage:(DXChatMessage *)chatMessage {
    [super setChatMessage:chatMessage];
    
    self.urlMatches = [self.detector matchesInString:chatMessage.msg options:0 range:NSMakeRange(0, chatMessage.msg.length)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chatMessage.msg];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, chatMessage.msg.length)];
    
    if (chatMessage.is_sender) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:DXRGBColor(102, 102, 102) range:NSMakeRange(0, chatMessage.msg.length)];
    } else {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, chatMessage.msg.length)];
    }
    
    [self.textLabel setAttributedText:attributedString];
    
    [self setHighlightedLinks];
}

/**
 *  url链接高亮显示
 */
- (void)setHighlightedLinks {
    
    NSMutableAttributedString *attributedString = [self.textLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    self.textLabel.attributedText = attributedString;
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    
    return index > range.location && index < range.location+range.length;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [self.textLabel.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [self.textLabel.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.textLabel.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.textLabel.font range:NSMakeRange(0, [self.textLabel.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.textLabel.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
         
         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
         }
         
         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = self.textLabel.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.textLabel.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.textLabel.numberOfLines > 0 ? MIN(self.textLabel.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return idx;
}

#pragma mark - public 

- (void)bubbleViewPressed:(id)sender {
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:self];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{kMessage:self.chatMessage, @"url":match.URL}];
                break;
            }
        }
    }
}

+ (CGFloat)heightForBubbleWithChatMessage:(DXChatMessage *)chatMessage {
    
    CGSize textBlockDefaultSize = CGSizeMake(TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX);
    CGSize retSize;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];//调整行间距
    retSize = [chatMessage.msg boundingRectWithSize:textBlockDefaultSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)], NSParagraphStyleAttributeName: paragraphStyle} context:nil].size;
    
    CGFloat defaultH = DXRealValue(41);
    
    if (BUBBLE_VIEW_PADDING * 2 + retSize.height > defaultH) {
        defaultH = BUBBLE_VIEW_PADDING * 2 + retSize.height;
    }
    
    return defaultH;
}

@end
