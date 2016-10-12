//
//  DXPublishPhotoViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishPhotoViewCell.h"

@implementation DXPublishPhotoViewCell {
    UIButton * _deleteButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_photoView];
        
        const CGFloat photoCellMargin = DXRealValue(15.0/3);
        
        UIImage * deleteImage = [UIImage imageNamed:@"publish_photo_delete"];
        CGFloat deleteButtonX = -photoCellMargin;
        CGFloat deleteButtonY = -photoCellMargin;
        CGFloat deleteButtonWidth = roundf(DXRealValue(deleteImage.size.width));
        CGFloat deleteButtonHeight = roundf(DXRealValue(deleteImage.size.height));
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(deleteButtonX, deleteButtonY, deleteButtonWidth, deleteButtonHeight)];
        [_deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_deleteButton];
    }
    return self;
}

- (void)deleteButtonTapped:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonTappedInCell:)]) {
        [self.delegate deleteButtonTappedInCell:self];
    }
}

@end
