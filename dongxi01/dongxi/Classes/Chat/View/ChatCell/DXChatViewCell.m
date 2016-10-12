//
//  DXChatViewCell.m
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatViewCell.h"

#define Status_WH            20               // 菊花view的宽高
#define Status_Bubble_Margin DXRealValue(10)  // 菊花view与bubble的水平间距
#define Head_Bubble_Y_Margin DXRealValue(28)  // 头像与bubble的Y的间距

@interface DXChatViewCell ()

/** 菊花 */
@property (nonatomic, weak) UIActivityIndicatorView *activity;
/** 呈现发送状态的view */
@property (nonatomic, weak) UIView *statusView;
/** 语音未读的小红点 */
@property (nonatomic, weak) UIImageView *isUnreadView;
/** 重新发送按钮 */
@property (nonatomic, weak) UIButton *retryBtn;

@end

@implementation DXChatViewCell

- (instancetype)initWithChatMessage:(DXChatMessage *)chatMessage reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithChatMessage:chatMessage reuseIdentifier:reuseIdentifier]) {
        if (chatMessage.is_sender) {
            // 呈现发送状态的view
            UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Status_WH, Status_WH)];
            statusView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:statusView];
            self.statusView = statusView;
            
            // 菊花
            UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activity.hidden = YES;
            [statusView addSubview:activity];
            self.activity = activity;
            
            // 重新发送按钮
            UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            retryBtn.frame = CGRectMake(0, 0, Status_WH, Status_WH);
            [retryBtn setImage:[UIImage imageNamed:@"retryButton"] forState:UIControlStateNormal];
            [retryBtn addTarget:self action:@selector(didClickRetryBtn) forControlEvents:UIControlEventTouchUpInside];
            retryBtn.hidden = YES;
            [statusView addSubview:retryBtn];
            self.retryBtn = retryBtn;
        } else {
            // 未读视图
            UIImageView *isUnreadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_icon_chat"]];
            isUnreadView.size = CGSizeMake(DXRealValue(7), DXRealValue(7));
            isUnreadView.hidden = YES;
            [self.contentView addSubview:isUnreadView];
            self.isUnreadView = isUnreadView;
        }
        
        self.bubbleView = [self bubbleViewForChatMessage:chatMessage];
        [self.contentView addSubview:self.bubbleView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.bubbleView.y = self.avatarView.y + Head_Bubble_Y_Margin;
    if (self.chatMessage.is_sender) { // 自己
        self.bubbleView.x = self.avatarView.x - self.bubbleView.width - Head_Bubble_Margin;
        // 菊花
        self.statusView.x = self.bubbleView.x - Status_Bubble_Margin - Status_WH;
        self.statusView.centerY = self.bubbleView.centerY;
    } else { // 别人
        self.bubbleView.x = Head_WH + Head_Padding * 2;
        self.isUnreadView.origin = CGPointMake(CGRectGetMaxX(self.bubbleView.frame) + DXRealValue(9), self.bubbleView.y);
    }
}

- (void)setChatMessage:(DXChatMessage *)chatMessage {
    [super setChatMessage:chatMessage];
    
    if (chatMessage.is_sender) {
        
        switch (chatMessage.deliveryState) {
            case eMessageDeliveryState_Delivering:   // 正在发送
                self.retryBtn.hidden = YES;
                self.activity.hidden = NO;
                [self.activity startAnimating];
                break;
            case eMessageDeliveryState_Delivered:    // 已发送
                self.retryBtn.hidden = YES;
                self.activity.hidden = YES;
                [self.activity stopAnimating];
                break;
            case eMessageDeliveryState_Failure:      // 发送失败
                self.retryBtn.hidden = NO;
                self.activity.hidden = YES;
                [self.activity stopAnimating];
                break;
                
            default:
                break;
        }
        
    } else {
        
        if (chatMessage.type == eMessageBodyType_Voice) {
            if (chatMessage.isPlayed) {
                self.isUnreadView.hidden = YES;
            } else {
                self.isUnreadView.hidden = NO;
            }
        }
    }
    
    self.bubbleView.chatMessage = chatMessage;
    [self.bubbleView sizeToFit];
}

/**
 *  点击了重新发送按钮
 */
- (void)didClickRetryBtn {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewCell:replyBtnDidClickWithChatMessage:)]) {
        [self.delegate chatViewCell:self replyBtnDidClickWithChatMessage:self.chatMessage];
    }
}

- (DXChatBaseBubbleView *)bubbleViewForChatMessage:(DXChatMessage *)chatMessage {
    
    switch (chatMessage.type) {
        case eMessageBodyType_Text:
            return [[DXChatTextBubbleView alloc] init];
            break;
        case eMessageBodyType_Voice:
            return [[DXChatAudioBubbleView alloc] init];
            break;
            
        default:
            break;
    }
    return nil;
}

+ (CGFloat)bubbleViewHeightForChatMessage:(DXChatMessage *)chatMessage {
    
    switch (chatMessage.type) {
        case eMessageBodyType_Text:
            return [DXChatTextBubbleView heightForBubbleWithChatMessage:chatMessage];
            break;
        case eMessageBodyType_Voice:
            return [DXChatAudioBubbleView heightForBubbleWithChatMessage:chatMessage];
            break;
            
        default:
            break;
    }

    return DXRealValue(41);
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withChatMessage:(DXChatMessage *)chatMessage {
    CGFloat bubbleH = [self bubbleViewHeightForChatMessage:chatMessage];
    return Head_Bubble_Y_Margin + bubbleH + Bottom_Padding;
}

@end
