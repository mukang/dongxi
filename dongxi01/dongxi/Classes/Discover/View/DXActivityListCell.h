//
//  DXActivityListCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXActivityListCell : UICollectionViewCell

@property (nonatomic) UIImageView * coverImageView;
@property (nonatomic) UILabel * nameLabel;
@property (nonatomic) UILabel * infoLabel;
@property (nonatomic) UILabel * descriptionLabel;

@property (nonatomic) NSString * typeAndPlace;
@property (nonatomic) NSString * time;

/** 分割线 */
@property (nonatomic, strong) UIView *separateView;
/** 关键词 */
@property (nonatomic, copy) NSString *keywords;

@end
