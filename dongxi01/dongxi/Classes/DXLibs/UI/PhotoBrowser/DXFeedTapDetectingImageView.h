//
//  DXFeedTapDetectingImageView.h
//  dongxi
//
//  Created by 穆康 on 16/3/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXFeedTapDetectingImageViewDelegate;

@interface DXFeedTapDetectingImageView : UIImageView

@property (nonatomic, weak) id<DXFeedTapDetectingImageViewDelegate> tapDelegate;

@end

@protocol DXFeedTapDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end
