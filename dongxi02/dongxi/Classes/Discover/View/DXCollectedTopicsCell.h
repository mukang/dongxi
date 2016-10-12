//
//  DXCollectedTopicsCell.h
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXCollectedTopicsCell;

@protocol DXCollectedTopicsCellDelegate <NSObject>

@optional
- (void)collectedTopicsCell:(DXCollectedTopicsCell *)cell didTapTopicPhotoWithTopic:(DXTopic *)topic;

@end

@interface DXCollectedTopicsCell : UITableViewCell

@property (nonatomic, strong) NSArray *collectedTopics;

@property (nonatomic, weak) id<DXCollectedTopicsCellDelegate> delegate;

@end
