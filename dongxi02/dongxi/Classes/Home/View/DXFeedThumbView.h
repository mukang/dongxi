//
//  DXFeedThumbView.h
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTimelineFeedPhoto;

@interface DXFeedThumbView : UIView

/** 是否隐藏borderView */
@property (nonatomic, assign) BOOL borderIsHidden;
/** 图片地址 */
@property (nonatomic, copy) DXTimelineFeedPhoto *photo;

@end
