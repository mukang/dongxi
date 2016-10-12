//
//  DXNormalTagCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXNormalTagBackgroundView.h"
@class DXNormalTagCell;

@protocol DXNormalTagCellDelegate <NSObject>

@optional
- (void)normalTagCell:(DXNormalTagCell *)cell didTapTagWitNormalTag:(DXTag *)normalTag;

@end

@interface DXNormalTagCell : UICollectionViewCell

@property (nonatomic, strong) DXTag *normalTag;
@property (nonatomic, weak) id<DXNormalTagCellDelegate> delegate;

@property (nonatomic, weak) DXNormalTagBackgroundView *bgView;
@property (nonatomic, weak) UILabel *tagLabel;

/**
 *  返回cell宽度
 */
+ (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath withNormalTag:(DXTag *)normalTag;

/**
 *  返回cell宽度
 */
+ (CGFloat)widthForNormalTag:(DXTag *)normalTag;

@end
