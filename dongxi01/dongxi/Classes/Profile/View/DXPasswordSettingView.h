//
//  DXPasswordSettingView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXPasswordSettingView : UIView

@property (nonatomic, readonly, strong) UITextField * textField;

@property (nonatomic, strong) UIImage * leftImage;
@property (nonatomic, strong) UIColor * leftImageColor;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * placeHolder;

@end
