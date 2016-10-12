//
//  DXReferViewCell.h
//  dongxi
//
//  Created by 穆康 on 16/5/9.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXReferViewCell : UITableViewCell

@property (nonatomic, strong) DXUser *referUser;
@property (nonatomic, strong) DXTopic *referTopic;
@property (nonatomic, assign, readonly) DXReferType referType;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier referType:(DXReferType)referType;

@end
