//
//  DXMessageCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXMessageCell : UITableViewCell

/**
 *  头像
 */
@property (nonatomic, weak) UIImageView *iconImageV;
/**
 *  标题
 */
@property (nonatomic, weak) UILabel *titleL;
/**
 *  分割线
 */
@property (nonatomic, weak) UIView *separatorV;
/**
 *  有未读信息
 */
@property (nonatomic, assign) BOOL hasUnReadMessage;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
