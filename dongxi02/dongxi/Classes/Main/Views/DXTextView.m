//
//  DXTextView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTextView.h"

@implementation DXTextView {
    UILabel * _placeHolderLabel;
    UIColor * _oldTextColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = DXRGBColor(72, 72, 72);
        self.font = [DXFont dxDefaultFontWithSize:50.0/3];
        self.placeHolderFont = [DXFont dxDefaultFontWithSize:50.0/3];
        self.placeHolderColor = DXRGBColor(143, 143, 143);
        self.textContainerInset = UIEdgeInsetsMake(2, 0, 0, 0);
        _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    }
    return self;
}

- (void)layoutSubviews {
    if (!_placeHolderLabel.superview) {
        CGFloat linePadding = self.textContainer.lineFragmentPadding;
        _placeHolderLabel.frame = CGRectMake(linePadding, 0, self.bounds.size.width, 20);
        _placeHolderLabel.text = _placeHolder;
        _placeHolderLabel.font = self.placeHolderFont;
        _placeHolderLabel.textColor = self.placeHolderColor;
        _placeHolderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_placeHolderLabel];
    } else {
        CGRect placeHolderFrame = _placeHolderLabel.frame;
        placeHolderFrame.origin.x = self.textContainer.lineFragmentPadding;
        [_placeHolderLabel setFrame:placeHolderFrame];
    }
    
    [super layoutSubviews];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    if (!text || text.length == 0) {
        _placeHolderLabel.hidden = NO;
    } else {
        _placeHolderLabel.hidden = YES;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    _placeHolderLabel.text = placeHolder;
}

- (void)setViewStateTextColor:(UIColor *)viewStateTextColor {
    _viewStateTextColor = viewStateTextColor;
    
    _oldTextColor = self.textColor;
    if ([self isFirstResponder]) {
        self.textColor = viewStateTextColor;
    }
}

- (void)setEditStateTextColor:(UIColor *)editStateTextColor {
    _editStateTextColor = editStateTextColor;

    if (![self isFirstResponder]) {
        self.textColor = editStateTextColor;
    }
}

#pragma mark -

- (void)textDidBeginEditing:(NSNotification *)noti {
    _placeHolderLabel.hidden = YES;
    
    if (self.editStateTextColor) {
        self.textColor = self.editStateTextColor;
    } else if (_oldTextColor) {
        self.textColor = _oldTextColor;
    }
}

- (void)textDidChange:(NSNotification *)noti {
    
}

- (void)textDidEndEditing:(NSNotification *)noti {
    if (!self.text || self.text.length == 0) {
        _placeHolderLabel.hidden = NO;
    } else {
        _placeHolderLabel.hidden = YES;
    }
    
    if (self.viewStateTextColor) {
        _oldTextColor = self.textColor;
        self.textColor = self.viewStateTextColor;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
