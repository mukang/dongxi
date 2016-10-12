//
//  DXScreenNotice.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DXScreenNoticeDidShowNotification;
extern NSString * const DXScreenNoticeDidDismissNotification;


@interface DXScreenNotice : UIView

@property (nonatomic, assign) BOOL disableAutoDismissed;
@property (nonatomic, strong) NSDictionary * userInfo;

- (instancetype)initWithMessage:(NSString *)message fromController:(UIViewController *)controller;
- (void)show;
- (void)dismiss:(BOOL)animated;
- (void)dismiss:(BOOL)animated completion:(void(^)(void))completion;
- (void)updateMessage:(NSString *)message;
- (void)setTapToDismissEnabled:(BOOL)enabled completion:(void(^)(void))completion;

@end



