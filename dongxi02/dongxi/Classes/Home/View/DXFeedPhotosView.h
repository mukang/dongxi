//
//  DXFeedPhotosView.h
//  dongxi
//
//  Created by 穆康 on 15/9/22.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXFeedPhotoView.h"
@class DXFeedPhotosView;

@protocol DXFeedPhotosViewDelegate <NSObject>

@optional

- (void)feedPhotosView:(DXFeedPhotosView *)view didTapPhotoWithPhotoView:(DXFeedPhotoView *)photoView;

@end

@interface DXFeedPhotosView : UIView

@property (nonatomic, strong) DXTimelineFeed *feed;

@property (nonatomic, weak) id<DXFeedPhotosViewDelegate> delegate;

/**
 *  视图高度
 */
+ (CGFloat)heightForPhotosViewWithFeed:(DXTimelineFeed *)feed;

@end
