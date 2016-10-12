//
//  DXProfileUpdatePickerInputCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXProfileUpdatePickerInputCell : UITableViewCell

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * contentLabel;

@property (nonatomic, strong) UIPickerView * pickerView;
@property (nonatomic, assign) BOOL enabled;

@end
