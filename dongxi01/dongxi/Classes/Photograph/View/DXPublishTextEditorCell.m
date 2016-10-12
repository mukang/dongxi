//
//  DXPublishTextEditorCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishTextEditorCell.h"
#import "DXTextParser.h"

@implementation DXPublishTextEditorCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textView = [[YYTextView alloc] init];
        _textView.textColor = DXRGBColor(72, 72, 72);
        _textView.font = [DXFont dxDefaultFontWithSize:50.0/3];
        _textView.placeholderText = @"请输入文字";
        _textView.placeholderTextColor = DXRGBColor(143, 143, 143);
        _textView.placeholderFont = [DXFont dxDefaultFontWithSize:50.0/3];
        _textView.textParser = [[DXTextParser alloc] init];
        [self.contentView addSubview:_textView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat horizontalMargin = DXRealValue(45.0/3);
    CGFloat verticalMargin = DXRealValue(40.0/3);
    _textView.x = horizontalMargin;
    _textView.y = verticalMargin;
    _textView.width = self.contentView.width - horizontalMargin * 2;
    _textView.height = self.contentView.height - verticalMargin * 2;;
}


@end
