//
//  DXSearchHotKeywordsCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/20.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchHotKeywordsCell.h"

@interface DXSearchHotKeywordsCell ()

@property (nonatomic, weak) UILabel *keywordsLabel;

@end

@implementation DXSearchHotKeywordsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *keywordsLabel = [[UILabel alloc] init];
    keywordsLabel.textColor = DXRGBColor(143, 143, 143);
    keywordsLabel.font = [DXFont dxDefaultBoldFontWithSize:40/3.0];
    [self.contentView addSubview:keywordsLabel];
    self.keywordsLabel = keywordsLabel;
}

- (void)setHotKeywords:(DXSearchHotKeywords *)hotKeywords {
    _hotKeywords = hotKeywords;
    
    self.keywordsLabel.text = hotKeywords.keyword;
    [self.keywordsLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.keywordsLabel.x = DXRealValue(13);
    self.keywordsLabel.y = self.contentView.height - self.keywordsLabel.height;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = DXRGBColor(222, 222, 222);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
