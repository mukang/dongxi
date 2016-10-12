//
//  DXSearchResultsHeaderCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXSearchResultsHeaderCell : UICollectionViewCell

/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 分割线 */
@property (nonatomic, weak) UIView *separateView;

@end
