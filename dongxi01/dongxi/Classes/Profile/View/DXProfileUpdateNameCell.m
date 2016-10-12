//
//  DXProfileUpdateNameCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileUpdateNameCell.h"

@interface DXProfileUpdateNameCell ()

@end

@implementation DXProfileUpdateNameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat contentHeight = CGRectGetHeight(self.contentView.bounds);
        CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    
        CGFloat labelLeading = DXRealValue(40.0/3);
        CGFloat labelWidth = DXRealValue(182.0/3);
        
        _fieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelLeading, 0, labelWidth, contentHeight)];
        _fieldLabel.textColor = DXRGBColor(72, 72, 72);
        _fieldLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(50.0/3)];
        _fieldLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:_fieldLabel];
        
        CGFloat textFieldLeading = labelLeading + labelWidth;
        CGFloat textFieldWidth = contentWidth - textFieldLeading;
        _textField = [[DXTextField alloc] initWithFrame:CGRectMake(textFieldLeading, 0, textFieldWidth, contentHeight)];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.placeholder = @"请输入昵称";
        _textField.textColor = DXRGBColor(72, 72, 72);
        _textField.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(50.0/3)];
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:_textField];
        
    }
    return self;
}


@end
