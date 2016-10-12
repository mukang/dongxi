//
//  DXTagChooseView.m
//  dongxi
//
//  Created by 穆康 on 16/3/10.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagChooseView.h"
#import "DXNormalTagCell.h"

#define TagMargin   DXRealValue(12)   // cell间距
#define TagPadding  DXRealValue(18)   // cell边距
#define TagHeight   DXRealValue(34)   // cell高度

#define TagColor    DXRGBColor(109, 197, 255)

@interface DXTagChooseView () <DXNormalTagCellDelegate>


@end

@implementation DXTagChooseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    
}

- (void)setTags:(NSArray *)tags withRect:(CGRect)rect {
    
    CGFloat tempWidth = TagPadding;
    CGFloat tempHeight = TagPadding + TagHeight + TagMargin;
    CGFloat tagWidth = 0;
    
    for (int i=0; i<tags.count; i++) {
        DXTag *tag = tags[i];
        
        tagWidth = [DXNormalTagCell widthForNormalTag:tag];
        tempWidth = tempWidth + tagWidth + TagMargin;
        if (tempWidth > rect.size.width) {
            tempWidth = TagPadding + tagWidth + TagMargin;
            tempHeight = tempHeight + TagHeight + TagMargin;
        }
        
        if (tempHeight > rect.size.height) {
            NSArray *showTags = [tags subarrayWithRange:NSMakeRange(0, i)];
            [self setShowTags:showTags withRect:rect];
            if (self.delegate && [self.delegate respondsToSelector:@selector(tagChooseView:didShowTagsWithRange:)]) {
                [self.delegate tagChooseView:self didShowTagsWithRange:NSMakeRange(0, i)];
            }
            break;
        }
    }
}

- (void)setShowTags:(NSArray *)showTags withRect:(CGRect)rect {
    
    for (DXNormalTagCell *cell in self.subviews) {
        [cell removeFromSuperview];
    }
    
    CGFloat tagX = 0;
    CGFloat tagY = TagPadding;
    CGFloat tagW = 0;
    CGFloat tagH = TagHeight;
    CGFloat previousTagMaxX = 0;
    
    for (int i=0; i<showTags.count; i++) {
        DXTag *tag = showTags[i];
        
        DXNormalTagCell *cell = [[DXNormalTagCell alloc] init];
        cell.normalTag = tag;
        cell.delegate = self;
        
        tagW = [DXNormalTagCell widthForNormalTag:tag];
        
        if (previousTagMaxX == 0) {
            tagX = TagPadding;
        } else {
            tagX = previousTagMaxX + TagMargin;
        }
        
        if (tagX + tagW + TagMargin > rect.size.width) {
            tagX = TagPadding;
            tagY = tagY + tagH + TagMargin;
        }
        
        cell.frame = CGRectMake(tagX, tagY, roundf(tagW), roundf(tagH));
        previousTagMaxX = tagX + tagW;
        [self addSubview:cell];
    }
}

#pragma mark - DXNormalTagCellDelegate

- (void)normalTagCell:(DXNormalTagCell *)cell didTapTagWitNormalTag:(DXTag *)normalTag {
    
    normalTag.status = !normalTag.status;
    if (normalTag.status) {
        cell.bgView.backgroundColor = TagColor;
        cell.tagLabel.textColor = [UIColor whiteColor];
    } else {
        cell.bgView.backgroundColor = [UIColor whiteColor];
        cell.tagLabel.textColor = TagColor;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagChooseView:didTapTagWitNormalTag:)]) {
        [self.delegate tagChooseView:self didTapTagWitNormalTag:normalTag];
    }
}

@end
