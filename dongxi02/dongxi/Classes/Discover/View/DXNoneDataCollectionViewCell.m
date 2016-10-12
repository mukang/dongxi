//
//  DXDiscoverNoneUserViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/10.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoneDataCollectionViewCell.h"

@implementation DXNoneDataCollectionViewCell {
    UILabel * _textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [DXFont dxDefaultFontWithSize:15];
        _textLabel.textColor = DXRGBColor(72, 72, 72);
        [self.contentView addSubview:_textLabel];
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    _textLabel.text = text;
    const CGFloat maxWidth = CGRectGetWidth(self.bounds) - DXRealValue(30)*2;
    CGRect labelFrame = [_textLabel textRectForBounds:CGRectMake(0, 0, maxWidth, CGFLOAT_MAX) limitedToNumberOfLines:0];
    CGPoint labelOrigin = CGPointMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(labelFrame))/2,
                                      (CGRectGetHeight(self.bounds) - CGRectGetHeight(labelFrame))/2);
    labelFrame.origin = labelOrigin;
    _textLabel.frame = labelFrame;
}

@end
