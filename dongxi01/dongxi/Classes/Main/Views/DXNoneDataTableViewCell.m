//
//  DXNoneDataTableViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/10.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoneDataTableViewCell.h"

@implementation DXNoneDataTableViewCell {
    UILabel * _textLabel;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"NoneDataTableViewCell";
    
    DXNoneDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXNoneDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [DXFont dxDefaultFontWithSize:15];
        _textLabel.textColor = DXRGBColor(72, 72, 72);
        _textLabel.numberOfLines = 0;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_textLabel];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        self.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    
    _textLabel.text = text;
    const CGFloat maxWidth = CGRectGetWidth(self.bounds) - DXRealValue(30)*2;
    CGRect labelFrame = [_textLabel textRectForBounds:CGRectMake(0, 0, maxWidth, CGFLOAT_MAX) limitedToNumberOfLines:0];
    labelFrame.size.height += 5;
    CGPoint labelOrigin = CGPointMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(labelFrame))/2,
                                      (CGRectGetHeight(self.bounds) - CGRectGetHeight(labelFrame))/2);
    if (self.maxTextCenterY > 0 && self.maxTextCenterY < labelOrigin.y + labelFrame.size.height/2) {
        labelOrigin.y = self.maxTextCenterY - labelFrame.size.height/2;
    }
    labelFrame.origin = labelOrigin;
    _textLabel.frame = labelFrame;
}

@end
