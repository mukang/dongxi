//
//  DXSearchResultsUserCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXSearchResultsUserCell : UICollectionViewCell

/** 关键词 */
@property (nonatomic, copy) NSString *keywords;
/** 用户 */
@property (nonatomic, strong) DXUser *user;

@end