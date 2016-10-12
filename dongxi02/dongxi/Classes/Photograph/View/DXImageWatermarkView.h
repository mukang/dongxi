//
//  DXImageWatermarkView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DXImageWatermarkView : UIView

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) BOOL hideBorderAndButton;
@property (nonatomic, assign) CGFloat initialScale;
@property (nonatomic, assign) CGFloat minScale;
@property (nonatomic, assign) CGFloat maxScale;

- (instancetype)initWithImage:(UIImage *)image;

- (void)resetRotation;
- (CGFloat)rotation;

@end
