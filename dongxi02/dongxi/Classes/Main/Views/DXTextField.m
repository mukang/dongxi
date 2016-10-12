//
//  DXTextField.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/29.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTextField.h"

@implementation DXTextField {
    UIButton * _customClearButton;
    CGSize _customClearButtonSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _customClearButton = [[UIButton alloc] init];
        UIImage * clearImage = [UIImage imageNamed:@"set_delete"];
        [_customClearButton setImage:clearImage forState:UIControlStateNormal];
        [_customClearButton.imageView setBounds:CGRectMake(0, 0, DXRealValue(clearImage.size.width), DXRealValue(clearImage.size.height))];
        [_customClearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
        self.rightView = _customClearButton;
        
        _customClearButtonSize = CGSizeMake(DXRealValue(clearImage.size.width), DXRealValue(clearImage.size.height));
    }
    return self;
}

- (void)setClearButtonMode:(UITextFieldViewMode)clearButtonMode {
    self.rightViewMode = clearButtonMode;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    const CGFloat buttonMargin = DXRealValue(13)*2;
    
    CGFloat textFieldWidth = CGRectGetWidth(bounds);
    CGFloat textFieldHeight = CGRectGetHeight(bounds);
    CGRect buttonRect = CGRectMake(textFieldWidth-_customClearButtonSize.width-buttonMargin, 0, _customClearButtonSize.width + buttonMargin, textFieldHeight);
    
    return buttonRect;
}

- (void)clearText:(UIButton *)sender {
    self.text = @"";
    [self becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self userInfo:nil];
}

@end
