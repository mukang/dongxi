//
//  DXReferViewController.h
//  dongxi
//
//  Created by 穆康 on 16/5/6.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXReferViewControllerDelegate;
@interface DXReferViewController : UIViewController

@property (nonatomic, assign, readonly) DXReferType referType;
@property (nonatomic, weak) id<DXReferViewControllerDelegate> delegate;

/** 唯一的初始化方法 */
- (instancetype)initWithReferType:(DXReferType)referType;

@end

@protocol DXReferViewControllerDelegate <NSObject>

- (void)referViewController:(DXReferViewController *)controller didSelectedReferWithContentPiece:(DXContentPiece *)contentPiece;

@optional
- (void)referViewControllerDidDismissed;

@end
