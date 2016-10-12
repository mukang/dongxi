//
//  DXActivityDetailCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXActivityDetailCell : UICollectionViewCell

@property (nonatomic) DXMutiLineLabel * timeLabel;
@property (nonatomic) DXMutiLineLabel * placeLabel;
@property (nonatomic) DXMutiLineLabel * addressLabel;
@property (nonatomic) DXMutiLineLabel * priceLabel;

@end