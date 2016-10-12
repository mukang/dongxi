//
//  DXChatViewCell.h
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatViewBaseCell.h"
#import "DXChatTextBubbleView.h"
#import "DXChatAudioBubbleView.h"
@class DXChatViewCell;

@protocol DXChatViewCellDelegate <NSObject>

@optional

- (void)chatViewCell:(DXChatViewCell *)cell replyBtnDidClickWithChatMessage:(DXChatMessage *)chatMessage;

@end

@interface DXChatViewCell : DXChatViewBaseCell

@property (nonatomic, weak) id<DXChatViewCellDelegate> delegate;

@end
