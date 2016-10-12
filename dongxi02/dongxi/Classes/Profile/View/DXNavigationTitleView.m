//
//  DXNavigationTitleView.m
//  dongxi
//
//  Created by 穆康 on 16/1/5.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNavigationTitleView.h"

#define GenderImageMale     [UIImage imageNamed:@"personal_male"]
#define GenderImageFemale   [UIImage imageNamed:@"personal_female"]
#define GenderImageOther    [UIImage imageNamed:@"personal_other"]

static CGFloat const Margin           = 2;
static CGFloat const GenderImageViewW = 13;

@interface DXNavigationTitleView ()

/** 标题 */
@property (nonatomic, weak) UILabel *titleLabel;
/** 性别图标 */
@property (nonatomic, weak) UIImageView *genderImageView;

@end

@implementation DXNavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:18];
    [self addSubview:titleLabel];
    
    UIImageView *genderImageView = [[UIImageView alloc] init];
    [self addSubview:genderImageView];
    
    self.titleLabel = titleLabel;
    self.genderImageView = genderImageView;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
    
    [self sizeToFit];
}

- (void)setGender:(DXUserGenderType)gender {
    _gender = gender;
    
    switch (gender) {
        case DXUserGenderTypeMale:
            self.genderImageView.image = GenderImageMale;
            break;
        case DXUserGenderTypeFemale:
            self.genderImageView.image = GenderImageFemale;
            break;
            
        default:
            self.genderImageView.image = GenderImageOther;
            break;
    }
    
    [self sizeToFit];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    
    self.titleLabel.textColor = titleColor;
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    [self.titleLabel sizeToFit];
    
    CGFloat width = self.titleLabel.width + (GenderImageViewW + Margin) * 2;
    CGFloat height = self.titleLabel.height;
    
    return CGSizeMake(width, height);
}
    

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.origin = CGPointMake(GenderImageViewW + Margin, 0);
    
    self.genderImageView.size = CGSizeMake(13, 13);
    self.genderImageView.x = CGRectGetMaxX(self.titleLabel.frame) + Margin;
    self.genderImageView.centerY = self.titleLabel.centerY;
}

@end
