//
//  DXFeedPhotoContainerView.h
//  dongxi
//
//  Created by 穆康 on 16/8/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXFeedPhotoView;
@protocol DXFeedPhotoContainerViewDelegate;

@interface DXFeedPhotoContainerView : UIView

@property (nonatomic, strong) DXFeed *feed;
@property (nonatomic, weak) id<DXFeedPhotoContainerViewDelegate> delegate;

@end


@protocol DXFeedPhotoContainerViewDelegate <NSObject>

@optional

- (void)feedPhotoContainerView:(DXFeedPhotoContainerView *)view didTapPhotoView:(DXFeedPhotoView *)photoView;

@end
