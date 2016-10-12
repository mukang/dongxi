//
//  DXEventCommentView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXEventCommentView.h"

@interface DXEventCommentView ()

@property (nonatomic) UIView * starsContainer;
@property (nonatomic) NSArray * starViews;
@property (nonatomic) UIView * textViewContainer;

@end

@implementation DXEventCommentView

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textView.placeHolder = placeholder;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupSubviews];
        [self setupContraints];

        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentViewTapped:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setupSubviews {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [DXFont fontWithName:DXCommonFontName size:20];
    _titleLabel.textColor = DXRGBColor(72, 72, 72);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_titleLabel];
    
    _starsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _starsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_starsContainer];
    
    UIImage * starNormal = [UIImage imageNamed:@"star_big_grew"];
    UIImage * starHighlight = [UIImage imageNamed:@"star_big_yellow"];
    for (int i = 0; i < 5; i++) {
        UIImageView * starView = [[UIImageView alloc] initWithImage:starNormal highlightedImage:starHighlight];
        starView.translatesAutoresizingMaskIntoConstraints = NO;
        [_starsContainer addSubview:starView];
        
        starView.tag = i;
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(starViewPressed:)];
        longPress.minimumPressDuration = 0;
        [starView setUserInteractionEnabled:YES];
        [starView addGestureRecognizer:longPress];
    }
    
    _starViews = self.starsContainer.subviews;
    
    _textViewContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _textViewContainer.backgroundColor = DXRGBColor(245, 245, 245);
    _textViewContainer.layer.cornerRadius = 5;
    _textViewContainer.layer.borderColor = DXRGBColor(222, 222, 222).CGColor;
    _textViewContainer.layer.borderWidth = 0.5;
    _textViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    _textView = [[DXTextView alloc] initWithFrame:CGRectZero];
    _textView.font = [DXFont dxDefaultFontWithSize:15.0];
    _textView.placeHolderFont = [DXFont dxDefaultFontWithSize:15.0];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.textViewContainer addSubview:_textView];
    [self addSubview:_textViewContainer];
    
    UIImage * submitNormalImage = [UIImage imageNamed:@"button_commit_review_normal"];
    UIImage * submitHightlightImage = [UIImage imageNamed:@"button_commit_review_click"];
    _submitButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_submitButton setImage:submitNormalImage forState:UIControlStateNormal];
    [_submitButton setImage:submitHightlightImage forState:UIControlStateHighlighted];
    _submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_submitButton];
    
    UIImage * submitAndShareNormalImage = [UIImage imageNamed:@"button_share_review_normal"];
    UIImage * submitAndShareHighlightImage = [UIImage imageNamed:@"button_share_review_click"];
    _submitAndShareButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_submitAndShareButton setImage:submitAndShareNormalImage forState:UIControlStateNormal];
    [_submitAndShareButton setImage:submitAndShareHighlightImage forState:UIControlStateHighlighted];
    _submitAndShareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_submitAndShareButton];
}

- (void)setupContraints {
    NSDictionary * views = @{
                             @"titleLabel"          : self.titleLabel,
                             @"starsContainer"      : self.starsContainer,
                             @"star0"               : self.starViews[0],
                             @"star1"               : self.starViews[1],
                             @"star2"               : self.starViews[2],
                             @"star3"               : self.starViews[3],
                             @"star4"               : self.starViews[4],
                             @"textViewContainer"   : self.textViewContainer,
                             @"textView"            : self.textView,
                             @"submitButton"        : self.submitButton,
                             @"submitAndShareButton": self.submitAndShareButton
                             };
    NSDictionary * metrics = @{
                               @"starWidth"         : @(DXRealValue(115.0/3)),
                               @"starHeight"        : @(DXRealValue(119.0/3)),
                               @"titleTop"          : @(DXRealValue(90.0/3)),
                               @"starTop"           : @(DXRealValue(240.0/3)),
                               @"submitTop"         : @(DXRealValue(1128.0/3)),
                               @"shareTop"          : @(DXRealValue(1350.0/3)),
                               @"shareBottom"       : @(DXRealValue(140.0/3)),
                               @"textTop"           : @(DXRealValue(450.0/3)),
                               @"textHeight"        : @(DXRealValue(600.0/3)),
                               @"textLeading"       : @(DXRealValue(60.0/3)),
                               @"textTrailing"      : @(DXRealValue(60.0/3))
                               };
    NSArray * visualFormats = @[
                                @"H:|-[titleLabel]-|",
                                @"H:|[star0(==starWidth)]-2-[star1(==starWidth)]-2-[star2(==starWidth)]-2-[star3(==starWidth)]-2-[star4(==starWidth)]|",
                                @"H:|-textLeading-[textViewContainer]-textTrailing-|",
                                @"H:|-10-[textView]-10-|",
                                @"V:|-titleTop-[titleLabel]",
                                @"V:|-starTop-[starsContainer]",
                                @"V:|[star0(==starHeight)]|",
                                @"V:|[star1(==starHeight)]|",
                                @"V:|[star2(==starHeight)]|",
                                @"V:|[star3(==starHeight)]|",
                                @"V:|[star4(==starHeight)]|",
                                @"V:|-textTop-[textViewContainer(==textHeight)]",
                                @"V:|-6-[textView]-6-|",
                                @"V:|-submitTop-[submitButton]",
                                @"V:|-shareTop-[submitAndShareButton]-shareBottom-|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views];
        [self addConstraints:constraints];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.starsContainer
                                                    attribute:NSLayoutAttributeCenterX
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.submitButton
                                                    attribute:NSLayoutAttributeCenterX
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.submitAndShareButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
}


- (void)hightlightStarsToIndex:(NSInteger)index {
    for (int i = 0; i < 5; i++) {
        UIImageView * starView = [self.starViews objectAtIndex:i];
        if (i <= index) {
            [starView setHighlighted:YES];
        } else {
            [starView setHighlighted:NO];
        }
    }
}

- (void)setStars:(NSUInteger)stars {
    _stars = stars;
    
    [self hightlightStarsToIndex:stars-1];
}

- (void)starViewPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self hightlightStarsToIndex:gesture.view.tag];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gesture locationInView:self.starsContainer];
        if (CGRectContainsPoint(self.starsContainer.bounds, point)) {
            for (UIImageView * starView in self.starViews) {
                point = [gesture locationInView:starView];
                if (CGRectContainsPoint(starView.bounds, point)) {
                    [self hightlightStarsToIndex:starView.tag];
                    self.stars = starView.tag+1;
                    break;
                }
            }
        } else {
            [self hightlightStarsToIndex:self.stars - 1];
        }
    }
}

- (void)commentViewTapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self.textView];
    if (!CGRectContainsPoint(self.textView.bounds, location)) {
        [self.textView resignFirstResponder];
    }
}


@end
