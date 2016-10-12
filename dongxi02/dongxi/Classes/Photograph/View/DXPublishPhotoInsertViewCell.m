//
//  DXPublishPhotoInsertViewCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishPhotoInsertViewCell.h"

@implementation DXPublishPhotoInsertViewCell {
    UIImageView * insertImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage * insertImage = [UIImage imageNamed:@"button_photo_released_add"];
        insertImageView = [[UIImageView alloc] initWithImage:insertImage];
        insertImageView.frame = CGRectMake(0, 0, DXRealValue(insertImage.size.width), DXRealValue(insertImage.size.height));
        insertImageView.center = (CGPoint){CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2};
        insertImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:insertImageView];
    }
    return self;
}

@end
