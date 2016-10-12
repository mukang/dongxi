//
//  DXNoneDataTableViewCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/12/10.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXNoneDataTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString * text;

@property (nonatomic, assign) CGFloat maxTextCenterY;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
