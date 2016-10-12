//
//  DXAppVersionView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAppVersionView.h"
#import "DXFunctions.h"

@implementation DXAppVersionView {
    UILabel * _versionLabel;
    UIImageView * _appImageView;
    CGSize _appImageSize;
    BOOL _isConstraintSet;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubViews];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    _isConstraintSet = NO;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!_isConstraintSet) {
        [self removeConstraints:self.constraints];
        NSDictionary * viewInfo = NSDictionaryOfVariableBindings(_versionLabel, _appImageView);
        NSDictionary * metrics = @{
                                   @"appImageTop"       : @(DXRealValue(12)),
                                   @"appImageWidth"     : @(_appImageSize.width),
                                   @"appImageHeight"    : @(_appImageSize.height)
                                   };
        NSMutableArray * constraints = [NSMutableArray array];
        NSMutableArray * visualFormats = [NSMutableArray array];
        [visualFormats addObject:@"H:[_appImageView(==appImageWidth)]"];
        [visualFormats addObject:@"H:|[_versionLabel]|"];
        [visualFormats addObject:@"V:|-appImageTop-[_appImageView(==appImageHeight)][_versionLabel]"];
        for (NSString * vf in visualFormats) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:viewInfo]];
        }
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_appImageView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0]];
        [self addConstraints:constraints];
        
        _isConstraintSet = YES;
    }
    
    [super updateConstraints];
}

- (void)setupSubViews {
    UIImage * aboutUsImage = [UIImage imageNamed:@"about_bg"];
    _appImageSize = CGSizeMake(DXRealValue(aboutUsImage.size.width), DXRealValue(aboutUsImage.size.height));
    _appImageView = [[UIImageView alloc] initWithImage:aboutUsImage];
    _appImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_appImageView];
    
    _versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    _versionLabel.textColor = DXRGBColor(143, 143, 143);
    _versionLabel.font = [DXFont dxDefaultFontWithSize:40.0/3];
    _versionLabel.text = [NSString stringWithFormat:@"版本 %@", DXGetAppVersion()];
    _versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_versionLabel];
    
    [self setNeedsUpdateConstraints];
}

@end
