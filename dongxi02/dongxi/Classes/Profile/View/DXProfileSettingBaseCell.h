//
//  DXProfileSettingBaseCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXProfileSettingBaseCell : UITableViewCell

@property (nonatomic, strong, readonly) UIImageView * settingIconView;
@property (nonatomic, strong) UILabel * settingTextLabel;

@property (nonatomic, assign) BOOL showMoreView;

@end
