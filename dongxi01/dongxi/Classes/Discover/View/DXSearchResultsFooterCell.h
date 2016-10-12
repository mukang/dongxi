//
//  DXSearchResultsFooterCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXSearchResultsFooterCell;

@protocol DXSearchResultsFooterCellDelegate <NSObject>

@optional
- (void)searchResultsFooterCell:(DXSearchResultsFooterCell *)cell didTapSearchMoreWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface DXSearchResultsFooterCell : UICollectionViewCell

/** 标题 */
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<DXSearchResultsFooterCellDelegate> delegate;

@end
