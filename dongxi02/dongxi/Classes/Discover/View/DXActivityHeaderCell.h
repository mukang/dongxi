//
//  DXActivityHeaderCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXActivityHeaderCell : UICollectionViewCell

@property (nonatomic, readonly) UIView * containerView;

@property (nonatomic) UIImageView * coverImageView;
@property (nonatomic) DXMutiLineLabel * nameLabel;
@property (nonatomic) UILabel * numberLabel;
@property (nonatomic) NSUInteger stars;

@end
