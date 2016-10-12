//
//  DXRecentContactCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  最近联系人cell

#import <UIKit/UIKit.h>
@class DXLatestMessage;

@interface DXRecentContactCell : UITableViewCell

@property (nonatomic, strong) DXLatestMessage *latestMessage;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
