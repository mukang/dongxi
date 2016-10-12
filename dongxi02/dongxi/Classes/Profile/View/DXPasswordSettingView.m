//
//  DXPasswordSettingView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPasswordSettingView.h"

@implementation DXPasswordSettingView {
    UIImageView * _leftImageView;
    UIView * _leftImageContainer;
    UITextField * _textField;
    UIView * _bottomLine;
    BOOL _isUsingTemplateRenderingMode;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:_textField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:_textField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:_textField];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLeftImage:(UIImage *)leftImage {
    _leftImage = leftImage;
    
    if (leftImage) {
        if (_isUsingTemplateRenderingMode) {
            leftImage = [leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _leftImageView.image = leftImage;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setLeftImageColor:(UIColor *)leftImageColor {
    _leftImageColor = leftImageColor;
    
    _leftImageView.tintColor = leftImageColor;
    if (leftImageColor) {
        if (!_isUsingTemplateRenderingMode) {
            _isUsingTemplateRenderingMode = YES;
            _leftImageView.image = [_leftImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    } else {
        _isUsingTemplateRenderingMode = NO;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    
    NSDictionary * attributes = @{
                                  NSFontAttributeName : [DXFont dxDefaultFontWithSize:17],
                                  NSForegroundColorAttributeName : DXRGBColor(143, 143, 143)
                                  };
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder
                                                                       attributes:attributes];
}

- (NSString *)password {
    return _textField.text;
}

- (void)updateConstraints {
    [self setupConstraints];
    
    [super updateConstraints];
}

- (void)setupSubviews {
    _leftImageContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _leftImageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_leftImageContainer];
    
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _leftImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_leftImageContainer addSubview:_leftImageView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.font = [DXFont dxDefaultFontWithSize:17];
    _textField.textColor = DXRGBColor(72, 72, 72);
    _textField.secureTextEntry = YES;
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textField];
    
    _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomLine.backgroundColor = DXRGBColor(208, 208, 208);
    _bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bottomLine];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self removeConstraints:self.constraints];
    
    CGFloat textFieldLeading = 124.0/3;
    NSMutableArray * visualFormats = [NSMutableArray array];
    NSMutableArray * constraints = [NSMutableArray array];
    NSMutableDictionary * metrics = [NSMutableDictionary dictionary];
    NSDictionary * views = NSDictionaryOfVariableBindings(_leftImageContainer, _leftImageView, _textField, _bottomLine);
    
    if (_leftImage) {
        CGFloat leftImageWidth = DXRealValue(_leftImage.size.width);
        CGFloat leftImageHeight = DXRealValue(_leftImage.size.height);
        
        [metrics setObject:@(textFieldLeading) forKey:@"textFieldLeading"];
        [metrics setObject:@(leftImageWidth) forKey:@"leftImageWidth"];
        [metrics setObject:@(leftImageHeight) forKey:@"leftImageHeight"];
        
        [visualFormats addObject:@"H:|[_leftImageContainer(==textFieldLeading@500)]"];
        [visualFormats addObject:@"V:|[_leftImageContainer]|"];
        [visualFormats addObject:@"H:[_leftImageView(==leftImageWidth)]"];
        [visualFormats addObject:@"V:[_leftImageView(==leftImageHeight)]"];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftImageView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_leftImageContainer
                                                            attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftImageView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_leftImageContainer
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0 constant:0]];
    } else {
        textFieldLeading = 0;
        [metrics setObject:@(textFieldLeading) forKey:@"textFieldLeading"];
    }
    
    [metrics setObject:@(DXRealValue(3.5)) forKey:@"textFieldTop"];
    [metrics setObject:@(0.5) forKey:@"bottomLineHeight"];
    
    [visualFormats addObject:@"H:|-textFieldLeading@500-[_textField]|"];
    [visualFormats addObject:@"V:|-textFieldTop-[_textField]-bottomLineHeight-|"];
    [visualFormats addObject:@"H:|[_bottomLine]|"];
    [visualFormats addObject:@"V:[_bottomLine(==bottomLineHeight)]|"];
    
    for (NSString * vf in visualFormats) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self addConstraints:constraints];
}


#pragma mark - Handle Notification

- (void)textDidBeginEditing:(NSNotification *)noti {
    _bottomLine.backgroundColor = DXRGBColor(72, 72, 72);
}

- (void)textDidEndEditing:(NSNotification *)noti {
    _bottomLine.backgroundColor = DXRGBColor(208, 208, 208);
}

- (void)textDidChange:(NSNotification *)noti {
    
}


@end
