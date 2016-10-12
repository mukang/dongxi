//
//  DXChatViewBaseCell.h
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXChatMessage.h"
#import "DXChatBaseBubbleView.h"

extern NSString *const kRouterEventHeadImageViewTapEventName;

#define Head_WH DXRealValue(50) // 头像大小
#define Head_Padding DXRealValue(13) // 头像到cell的内边距
#define Head_Bubble_Margin DXRealValue(17) // 头像与bubble的间距
#define Bottom_Padding DXRealValue(17) // 内容到cell底部的内边距

@interface DXChatViewBaseCell : UITableViewCell

/** 头像 */
@property (nonatomic, strong) DXAvatarView *avatarView;
//@property (nonatomic, strong) UIImageView *headImageView;
/** 内容区域 */
@property (nonatomic, strong) DXChatBaseBubbleView *bubbleView;

@property (nonatomic, strong) DXChatMessage *chatMessage;

- (instancetype)initWithChatMessage:(DXChatMessage *)chatMessage reuseIdentifier:(NSString *)reuseIdentifier;

/**
 *  返回cell的ID
 */
+ (NSString *)cellIdentifierForChatMessage:(DXChatMessage *)chatMessage;
/**
 *  返回cell高度
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withChatMessage:(DXChatMessage *)chatMessage;

@end
