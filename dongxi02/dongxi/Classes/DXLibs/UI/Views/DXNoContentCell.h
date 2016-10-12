//
//  DXNoContentCell.h
//  dongxi
//
//  Created by 穆康 on 15/12/4.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//  提示cell

#import <UIKit/UIKit.h>

@interface DXNoContentCell : UITableViewCell

/** 需要显示的提示内容 */
@property (nonatomic, copy) NSString *notice;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
