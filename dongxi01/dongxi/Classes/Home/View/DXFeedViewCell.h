//
//  DXFeedViewCell.h
//  dongxi
//
//  Created by 穆康 on 16/8/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXFeedViewCellDelegate;

@interface DXFeedViewCell : UICollectionViewCell

@property (nonatomic, strong) DXFeed *feed;
@property (nonatomic, weak) id<DXFeedViewCellDelegate> delegate;

/**
 *  返回cell高度
 */
+ (CGSize)collectionView:(UICollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXFeed *)feed;

@end


@protocol DXFeedViewCellDelegate <NSObject>

@optional

- (void)feedViewCell:(DXFeedViewCell *)cell didTapLikeInfoBtnWithFeed:(DXFeed *)feed;
- (void)feedViewCell:(DXFeedViewCell *)cell didTapCommentInfoBtnWithFeed:(DXFeed *)feed;
- (void)feedViewCell:(DXFeedViewCell *)cell didTapLikeBtnWithFeed:(DXFeed *)feed;
- (void)feedViewCell:(DXFeedViewCell *)cell didTapCommentBtnWithFeed:(DXFeed *)feed;
- (void)feedViewCell:(DXFeedViewCell *)cell didTapChatBtnWithFeed:(DXFeed *)feed;
- (void)feedViewCell:(DXFeedViewCell *)cell didTapShareBtnWithFeed:(DXFeed *)feed;

@end
