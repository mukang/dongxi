//
//  DXSearchResultsPhotosCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXSearchResultsPhotosCell;

@protocol DXSearchResultsPhotosCellDelegate <NSObject>

@optional
- (void)searchResultsPhotosCell:(DXSearchResultsPhotosCell *)cell didTapPhotoWithFeed:(DXTimelineFeed *)feed;

@end

@interface DXSearchResultsPhotosCell : UICollectionViewCell

@property (nonatomic, strong) NSArray *feeds;

@property (nonatomic, weak) id<DXSearchResultsPhotosCellDelegate> delegate;

@end
