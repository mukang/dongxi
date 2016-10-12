//
//  UIViewController+DXDataMessageLabel.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/23.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DXDataMessageLabel)

@property (nonatomic) UILabel * dataMessageLabel;
@property (nonatomic) BOOL enableDataMessageLabel;
@property (nonatomic) CGFloat dataMessageLabelTopMargin;

- (void)showDataMessageLabel:(BOOL)show message:(NSString *)message;

@end
