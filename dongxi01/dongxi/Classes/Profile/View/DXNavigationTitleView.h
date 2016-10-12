//
//  DXNavigationTitleView.h
//  dongxi
//
//  Created by 穆康 on 16/1/5.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXUserProfile.h"

@interface DXNavigationTitleView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) DXUserGenderType gender;

@property (nonatomic, strong) UIColor *titleColor;

@end
