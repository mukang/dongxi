//
//  DXNormalTagCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNormalTagCell.h"

// 标签的颜色
//#define TagColor(s)         [UIColor colorWithRed:109/255.0*(s) green:197/255.0*(s) blue:255/255.0*(s) alpha:1.0]
#define TagColor            DXRGBColor(109, 197, 255)
#define TagLabelFont        [DXFont dxDefaultFontWithSize:16]   // 标签字体
#define TagLabelPadding     DXRealValue(11)                     // 标签在背景图中的左右偏移

@interface DXNormalTagCell ()

@end

@implementation DXNormalTagCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    DXNormalTagBackgroundView *bgView = [[DXNormalTagBackgroundView alloc] init];
    [self.contentView addSubview:bgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidTap)];
    [bgView addGestureRecognizer:tap];
    
    UILabel *tagLabel = [[UILabel alloc] init];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.font = TagLabelFont;
    [bgView addSubview:tagLabel];
    
    self.bgView = bgView;
    self.tagLabel = tagLabel;
}

- (void)setNormalTag:(DXTag *)normalTag {
    _normalTag = normalTag;
    
    self.tagLabel.text = normalTag.name;
    [self.tagLabel sizeToFit];
    
    if (normalTag.status) {
        self.bgView.backgroundColor = TagColor;
        self.tagLabel.textColor = [UIColor whiteColor];
    } else {
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.tagLabel.textColor = TagColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = self.contentView.bounds;
    self.bgView.layer.cornerRadius = self.bgView.height / 3;
    self.bgView.layer.masksToBounds = YES;
    [self.bgView setNeedsDisplay];
    
    self.tagLabel.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.5);
}

- (void)tagDidTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(normalTagCell:didTapTagWitNormalTag:)]) {
        [self.delegate normalTagCell:self didTapTagWitNormalTag:self.normalTag];
    }
}

+ (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath withNormalTag:(DXTag *)normalTag {
    
    NSDictionary *attributes = @{NSFontAttributeName: TagLabelFont};
    CGSize tagLabelSize = [normalTag.name sizeWithAttributes:attributes];
    
    return TagLabelPadding * 2 + tagLabelSize.width;
}

+ (CGFloat)widthForNormalTag:(DXTag *)normalTag {
    
    NSDictionary *attributes = @{NSFontAttributeName: TagLabelFont};
    CGSize tagLabelSize = [normalTag.name sizeWithAttributes:attributes];
    
    return TagLabelPadding * 2 + tagLabelSize.width;
}

@end
