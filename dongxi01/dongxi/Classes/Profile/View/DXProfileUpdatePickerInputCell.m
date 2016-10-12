//
//  DXProfileUpdatePickerInputCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileUpdatePickerInputCell.h"

@implementation DXProfileUpdatePickerInputCell {
    UIImageView * _nextImageView;
    UIToolbar * _inputToolBar;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        /** 设置分隔线样式，针对iOS [7.0, 8.0) */
        self.separatorInset = UIEdgeInsetsZero;
        
        /** 改变分隔线样式：设置layoutMargins，针对iOS (>=8.0) */
        if ([self respondsToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        
        /** 改变分隔线样式：阻止使用父视图的layoutMargins，针对iOS (>=8.0) */
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            self.preservesSuperviewLayoutMargins = NO;
        }
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.enabled = YES;
        [self prepareSubviews];
        [self prepareInputViews];
    }
    return self;
}

- (void)prepareSubviews {
    CGFloat contentHeight = CGRectGetHeight(self.contentView.bounds);
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat titleLabelLeading = DXRealValue(40.0/3);
    CGFloat titleLabelWidth = DXRealValue(182.0/3);
    CGFloat iconContainerWidth = DXRealValue(144.0/3);
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelLeading, 0, titleLabelWidth, contentHeight)];
    _titleLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    _titleLabel.textColor = DXRGBColor(72, 72, 72);
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self.contentView addSubview:_titleLabel];
    
    CGFloat contentLabelLeading = titleLabelLeading + titleLabelWidth;
    CGFloat contentLabelWidth = contentWidth - contentLabelLeading - iconContainerWidth;
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelLeading, 0, contentLabelWidth, contentHeight)];
    _contentLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    _contentLabel.textColor = DXRGBColor(72, 72, 72);
    _contentLabel.textAlignment = NSTextAlignmentRight;
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_contentLabel];
    
    UIImage * nextIcon = [UIImage imageNamed:@"set_more"];
    CGSize nextIconSize = CGSizeMake(DXRealValue(nextIcon.size.width), DXRealValue(nextIcon.size.height));
    _nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, nextIconSize.width, nextIconSize.height)];
    _nextImageView.image = nextIcon;
    _nextImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_nextImageView];
    
    [self setNeedsUpdateConstraints];
}

- (void)prepareInputViews {
    _pickerView = [[UIPickerView alloc] init];
    
    _inputToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXRealValue(40))];
    [_inputToolBar setBackgroundImage:[UIImage imageNamed:@"GrayPixel"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_inputToolBar setTranslucent:NO];
    UIBarButtonItem * inputBarFlexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                target:nil
                                                                                                action:nil];
    UIBarButtonItem * inputDoneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(inputDoneButtonTapped:)];
    [inputDoneButtonItem setTitleTextAttributes:@{
                                                  NSFontAttributeName : [DXFont dxDefaultFontWithSize:50.0/3],
                                                  NSForegroundColorAttributeName : DXCommonColor
                                                  }
                                       forState:UIControlStateNormal];
    [_inputToolBar setItems:@[inputBarFlexibleSpaceItem, inputDoneButtonItem]];
}

- (void)updateConstraints {
    [self.contentView removeConstraints:self.constraints];
    [self setupConstraints];
    [super updateConstraints];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    if (_nextImageView && _nextImageView.superview == self.contentView) {
        CGFloat nextIconTrailing = DXRealValue(56.0/3);
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nextImageView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:-nextIconTrailing]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nextImageView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]];
    }
}

- (void)inputDoneButtonTapped:(UIBarButtonItem *)sender {
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return self.enabled;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

- (UIView *)inputView {
    return _pickerView;
}

- (UIView *)inputAccessoryView {
    return _inputToolBar;
}


@end
