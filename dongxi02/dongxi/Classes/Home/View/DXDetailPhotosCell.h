//
//  DXDetailPhotosCell.h
//  dongxi
//
//  Created by 穆康 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTimelineFeed;

@interface DXDetailPhotosCell : UITableViewCell

@property (nonatomic, strong) DXTimelineFeed *feed;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withFeed:(DXTimelineFeed *)feed;

@end
