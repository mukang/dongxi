//
//  DXCollapseTextView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollapseTextView.h"


@interface DXCollapseTextView ()

@property (nonatomic) UIView * introContainer;
@property (nonatomic) DXMutiLineLabel * visibleLabel;
@property (nonatomic) UIImageView * dotImageView;

@property (nonatomic) UIView * fullContainer;
@property (nonatomic) DXMutiLineLabel * hiddenLabel;

@property (nonatomic) NSString * abstractText;

@property (nonatomic) CGFloat textSideMargin;
@property (nonatomic) CGFloat textLineSpace;

@property (nonatomic) NSArray * introOnlyConstraints;
@property (nonatomic) NSArray * fullOnlyConstraints;

@property (nonatomic) BOOL constraintsInstalled;

@end



@implementation DXCollapseTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.textSideMargin = DXRealValue(35.0f);
        self.textLineSpace = DXRealValue(6.0f);
        self.constraintsInstalled = NO;
        
        [self setupSubviews];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.constraintsInstalled) {
        [self setupConstraints];
        self.constraintsInstalled = YES;
    }
    
    if (self.showFull) {
        [self removeConstraints:_introOnlyConstraints];
        [self addConstraints:_fullOnlyConstraints];
    } else {
        [self removeConstraints:_fullOnlyConstraints];
        [self addConstraints:_introOnlyConstraints];
    }
    
    [super updateConstraints];
}

- (void)setupSubviews {
    _introContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _introContainer.translatesAutoresizingMaskIntoConstraints = NO;

    _visibleLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    _visibleLabel.font = [DXFont dxDefaultFontWithSize:15];
    _visibleLabel.textColor = DXRGBColor(72, 72, 72);
    _visibleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    _dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"6point_detail"]];
    _dotImageView.translatesAutoresizingMaskIntoConstraints = NO;

    _moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_moreButton setImage:[UIImage imageNamed:@"button_viewall_normal"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.translatesAutoresizingMaskIntoConstraints = NO;

    _fullContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _fullContainer.hidden = YES;
    _fullContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    _hiddenLabel = [[DXMutiLineLabel alloc] initWithFrame:CGRectZero];
    _hiddenLabel.font = [DXFont dxDefaultFontWithSize:15];
    _hiddenLabel.textColor = DXRGBColor(72, 72, 72);
    _hiddenLabel.translatesAutoresizingMaskIntoConstraints = NO;

    _hideButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_hideButton setImage:[UIImage imageNamed:@"button_pick_up"] forState:UIControlStateNormal];
    [_hideButton addTarget:self action:@selector(hideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _hideButton.translatesAutoresizingMaskIntoConstraints = NO;
    

    [_introContainer addSubview:_visibleLabel];
    [_introContainer addSubview:_dotImageView];
    [_introContainer addSubview:_moreButton];
    [self addSubview:_introContainer];
    [_fullContainer addSubview:_hiddenLabel];
    [_fullContainer addSubview:_hideButton];
    [self addSubview:_fullContainer];
    
    [self setNeedsUpdateConstraints];
}

- (void)setupConstraints {
    [self removeConstraints:self.constraints];
    
    CGSize textSize = [self sizeForText:self.text withExactLines:3 andEstimatedWidth:self.bounds.size.width - _textSideMargin * 2];
    _textSideMargin = (self.bounds.size.width - textSize.width) / 2;
    
    CGSize fullTextSize = [self sizeForText:self.hiddenLabel.text withExactLines:0 andEstimatedWidth:self.bounds.size.width - _textSideMargin * 2];

    NSDictionary * views = @{
                             @"introContainer"  : _introContainer,
                             @"visibleLabel"    : _visibleLabel,
                             @"dotImageView"    : _dotImageView,
                             @"moreButton"      : _moreButton,
                             @"fullContainer"   : _fullContainer,
                             @"hiddenLabel"     : _hiddenLabel,
                             @"hideButton"      : _hideButton
                             };
    NSDictionary * metrics = @{
                               @"textSideMargin"    : @(_textSideMargin),
                               @"textLineSpace"     : @(_textLineSpace),
                               @"textHeight"        : @(textSize.height),
                               @"fullTextHeight"    : @(fullTextSize.height)
                               };
    NSArray * visualFormats = @[
                                @"H:|-textSideMargin-[introContainer]-textSideMargin-|",
                                @"H:|[visibleLabel]|",
                                @"H:|-textSideMargin-[fullContainer]-textSideMargin-|",
                                @"H:|[hiddenLabel]|",
                                @"H:[hideButton]|",
                                @"V:|[introContainer]",
                                @"V:|[visibleLabel(==textHeight)]-16-[dotImageView]-16-[moreButton]|",
                                @"V:[visibleLabel]-textLineSpace-[fullContainer]",
                                @"V:|[hiddenLabel(==fullTextHeight)]-16-[hideButton]|"
                                ];
    for (NSString * vf in visualFormats) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dotImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_introContainer
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_moreButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_introContainer
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    
    _introOnlyConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[introContainer]-20-|"
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:views];
    _fullOnlyConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fullContainer]|"
                                                                   options:0
                                                                   metrics:metrics
                                                                     views:views];
}

#pragma mark - 属性方法

- (void)setText:(NSString *)text {
    _text = text;
    
    if (text == nil) {
        self.moreButton.hidden = YES;
        self.dotImageView.hidden = YES;
        self.fullContainer.hidden = YES;
        return;
    }
    
    NSString * abstractText = [self getAbstractOfText:text maxLines:3 width:self.bounds.size.width - self.textSideMargin * 2];
    self.abstractText = abstractText;
    
    if (abstractText.length >= text.length) {
        self.visibleLabel.attributedText = [self attributedTextForText:text];
        self.moreButton.hidden = YES;
        self.dotImageView.hidden = YES;
        self.fullContainer.hidden = YES;
    } else {
        self.visibleLabel.attributedText = [self attributedTextForText:abstractText];
        if (!self.showFull) {
            self.moreButton.hidden = NO;
            self.dotImageView.hidden = NO;
            self.fullContainer.hidden = YES;
        } else {
            self.moreButton.hidden = YES;
            self.dotImageView.hidden = YES;
            self.fullContainer.hidden = NO;
        }
    }
    
    self.hiddenLabel.attributedText = [self attributedTextForText:[self.text substringFromIndex:abstractText.length]];
    
    self.constraintsInstalled = NO;
    [self setNeedsUpdateConstraints];
}

- (void)setShowFull:(BOOL)showFull {
    _showFull = showFull;

    if (self.abstractText.length >= self.text.length) {
        return;
    }
    
    if (showFull) {
        self.fullContainer.hidden = NO;
        self.moreButton.hidden = YES;
        self.dotImageView.hidden = YES;
        
        self.fullContainer.alpha = 0;
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.fullContainer.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    } else {        
        self.moreButton.hidden = NO;
        self.dotImageView.hidden = NO;
        self.fullContainer.hidden = YES;
    }
    
    [self setNeedsUpdateConstraints];
}


- (NSAttributedString *)attributedTextForText:(NSString *)text {
    NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = self.textLineSpace;
    NSDictionary * textAttributes = @{
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSFontAttributeName           : [DXFont fontWithName:DXCommonFontName size:15],
                                      NSForegroundColorAttributeName: DXRGBColor(72, 72, 72)
                                      };
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:textAttributes];
    return attributedText;
}

#pragma mark - Button Action

- (void)moreButtonTapped:(UIButton *)button {
    [self setShowFull:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collapseTextView:willChangeState:)]) {
        [self.delegate collapseTextView:self willChangeState:NO];
    }
}

- (void)hideButtonTapped:(UIButton *)button {
    [self setShowFull:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collapseTextView:willChangeState:)]) {
        [self.delegate collapseTextView:self willChangeState:YES];
    }
}


#pragma mark - 尺寸预估


/**
 *  在指定了最大行数的情况下和宽度的情况下，得到指定文字的摘要
 *
 *  @param text  要获取摘要的文字
 *  @param lines 最大行数
 *  @param width 指定宽度
 *
 *  @return 文字摘要
 */
- (NSString *)getAbstractOfText:(NSString *)text maxLines:(NSUInteger)lines width:(CGFloat)width {
    CGSize maxSize = [self sizeForText:text withExactLines:lines andEstimatedWidth:width];
    NSInteger startIndex = 20;
    if (text.length <= 20) {
        startIndex = text.length / 2;
    }
    NSInteger lastIndex = startIndex;
    NSString * substring = [text substringToIndex:startIndex];
    CGSize size = [self sizeForText:substring maxLines:lines+1 andEstimatedWidth:width];
    if (size.height <= maxSize.height) {
        for (NSInteger i = startIndex; i <= text.length; i++) {
            substring = [text substringToIndex:i];
            size = [self sizeForText:substring maxLines:lines+1 andEstimatedWidth:width];
            if (size.height <= maxSize.height) {
                lastIndex = i;
            } else {
                break;
            }
        }
    } else {
        for (NSInteger i = startIndex; i >= 0; i--) {
            substring = [text substringToIndex:i];
            size = [self sizeForText:substring maxLines:lines+1 andEstimatedWidth:width];
            if (size.height > maxSize.height) {
                lastIndex = i;
            } else {
                break;
            }
        }
    }
    return [text substringToIndex:lastIndex];
}


/**
 *  计算文字在预估宽度内，不多不少恰好满足指定行数时所需的尺寸
 *
 *  @param lines 行数
 *  @param width 预估宽度，得到的尺寸的宽度实际可能比这小
 *
 *  @return 尺寸
 */
- (CGSize)sizeForText:(NSString *)text withExactLines:(NSUInteger)lines andEstimatedWidth:(CGFloat)width {
    if (text == nil) {
        return CGSizeMake(width, DXRealValue(100));
    }
    
    CGSize size;
    if (lines > 0) {
        size = [self sizeForText:text maxLines:lines andEstimatedWidth:width];
    } else {
        size = [self sizeForText:text maxLines:0 andEstimatedWidth:width];
    }
    
    if (fabs(size.width-width) > DXRealValue(15)) {
        size.width = width;
    }
    return size;
}


/**
 *  在给定最大行数和预估宽度的情况下，计算指定文本的尺寸
 *
 *  @param text  要计算估算的文本
 *  @param lines 最大行数
 *  @param width 预估宽度，得到的尺寸的宽度实际可能比这小
 *
 *  @return 指定文本实际所需的尺寸
 */
- (CGSize)sizeForText:(NSString *)text maxLines:(NSUInteger)lines andEstimatedWidth:(CGFloat)width {
    UILabel* testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    testLabel.attributedText = [self attributedTextForText:text];
    return [testLabel textRectForBounds:CGRectMake(0, 0, width, CGFLOAT_MAX) limitedToNumberOfLines:lines].size;
}


@end
