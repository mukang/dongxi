//
//  DXPublishPhotoViewCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXPublishPhotoViewCellDelegate;

@interface DXPublishPhotoViewCell : UICollectionViewCell

@property (nonatomic) UIImageView * photoView;

@property (nonatomic, weak) id<DXPublishPhotoViewCellDelegate> delegate;

@end


@protocol DXPublishPhotoViewCellDelegate <NSObject>

@optional
- (void)deleteButtonTappedInCell:(UICollectionViewCell *)cell;

@end