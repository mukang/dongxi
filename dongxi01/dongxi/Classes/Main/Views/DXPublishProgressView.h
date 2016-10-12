//
//  DXPublishProgressView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DXPublishProgressViewRemoveBlock)(void);

@interface DXPublishProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) DXPublishProgressViewRemoveBlock removeBlock;

+ (instancetype)progressView;
- (void)showFromController:(UIViewController *)controller;
- (void)finish:(BOOL)success title:(NSString *)title otherMessage:(NSString *)otherMessage;

@end
