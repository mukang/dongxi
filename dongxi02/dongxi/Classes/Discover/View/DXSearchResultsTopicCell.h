//
//  DXSearchResultsTopicCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXSearchResultsTopicCell : UICollectionViewCell

/** 关键词 */
@property (nonatomic, copy) NSString *keywords;
/** 话题 */
@property (nonatomic, strong) DXTopic *topic;

@end
