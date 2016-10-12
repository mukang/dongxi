//
//  DXActivityAttendCommentHeaderCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXActivityAttendCommentHeaderCell.h"

@interface DXActivityAttendCommentHeaderCell ()

@property (nonatomic) UILabel * attendCountLabel;
@property (nonatomic) UILabel * commentCountLabel;
@property (nonatomic) UIImageView * commentBorderView;
@property (nonatomic) UIView * borderView;

@end

@implementation DXActivityAttendCommentHeaderCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.attendCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.attendCountLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.attendCountLabel.textColor = DXRGBColor(143, 143, 143);
    self.attendCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.commentBorderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border_comment_number"]];
    self.commentBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.commentCountLabel.text = @"0条评论";
    self.commentCountLabel.font = [DXFont fontWithName:DXCommonFontName size:15];
    self.commentCountLabel.textColor = DXCommonColor;
    self.commentCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.borderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.borderView.backgroundColor = DXRGBColor(222, 222, 222);
    self.borderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.attendCountLabel];
    [self.contentView addSubview:self.commentBorderView];
    [self.contentView addSubview:self.commentCountLabel];
    [self.contentView addSubview:self.borderView];
}

- (void)setupConstraints {
    // attendCountLabel水平居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.attendCountLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    // attendCountLabel垂直居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.attendCountLabel
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.contentView
                                                    attribute:NSLayoutAttributeCenterY
                                                   multiplier:1 constant:0]];
    // commentBorderView垂直居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commentBorderView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    // commentBorderView右边距13
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commentBorderView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-13]];
    // commentBorderView与commentCountLabel水平居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commentBorderView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.commentCountLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    // commentBorderView的宽=commentCountLabel的宽+24
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commentBorderView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.commentCountLabel
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1 constant:24]];
    // commentCountLabel的高<=commentBorderView的高
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commentCountLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:self.commentBorderView
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1 constant:24]];
    // commentCountLabel垂直居中
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.commentCountLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    // borderView两端对齐
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    // borderView两端对齐
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    // borderView底部对齐
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    // borderView高度为0.5
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:0.5]];

}

- (void)setAttendCount:(NSUInteger)attendCount {
    _attendCount = attendCount;
    
    NSString * countText = [NSString stringWithFormat:@"%lu", (unsigned long)attendCount];
    NSMutableAttributedString * attendText =  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@人去过", countText]];
    [attendText addAttribute:NSFontAttributeName
                       value:[DXFont fontWithName:DXCommonFontName
                                             size:20]
                       range:NSMakeRange(0, countText.length)];
    [attendText addAttribute:NSForegroundColorAttributeName
                       value:DXRGBColor(72, 72, 72)
                       range:NSMakeRange(0, countText.length)];
    self.attendCountLabel.attributedText = attendText;
}

- (void)setCommentCount:(NSUInteger)commentCount {
    _commentCount = commentCount;
    self.commentCountLabel.text = [NSString stringWithFormat:@"%lu条评论", (unsigned long)commentCount];
}

@end
