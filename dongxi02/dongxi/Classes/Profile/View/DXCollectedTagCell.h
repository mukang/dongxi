//
//  DXCollectedTagCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXCollectedTagCell;
@class DXTag;

@protocol DXCollectedTagCellDelegate <NSObject>

@optional
- (void)collectedTagCell:(DXCollectedTagCell *)cell didClickDeleteBtnWithCollectedTag:(DXTag *)collectedTag;

@end

@interface DXCollectedTagCell : UICollectionViewCell

@property (nonatomic, strong) DXTag *collectedTag;

@property (nonatomic, weak) id<DXCollectedTagCellDelegate> delegate;

/**
 *  返回cell宽度
 */
+ (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath withCollectedTag:(DXTag *)collectedTag;

@end
