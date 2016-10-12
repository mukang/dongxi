//
//  DXPhotoFilterIntensityBar.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DXPhotoFilterIntensityBarDelegate;


@interface DXPhotoFilterIntensityBar : UIView

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat initialValue;
@property (nonatomic, assign) NSInteger maxValue;
@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, weak) id <DXPhotoFilterIntensityBarDelegate> delegate;

- (void)revert;

@end



@protocol DXPhotoFilterIntensityBarDelegate <NSObject>

@optional
- (void)intensityBar:(DXPhotoFilterIntensityBar *)intensityBar didChangeValue:(CGFloat)value;

@end
