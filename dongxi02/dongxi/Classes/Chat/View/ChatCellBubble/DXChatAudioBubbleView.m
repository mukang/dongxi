//
//  DXChatAudioBubbleView.m
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatAudioBubbleView.h"
#import "UIResponder+Router.h"

NSString *const kRouterEventAudioBubbleTapEventName = @"kRouterEventAudioBubbleTapEventName";

#define AnimationImageView_W DXRealValue(15) // 小喇叭图片宽
#define AnimationImageView_H DXRealValue(18) // 小喇叭图片高
#define AnimationImageView_BubbleView_Margin DXRealValue(14) // 小喇叭与bubble内间距
#define AnimationImageView_TimeLabel_Margin DXRealValue(10) // 时间与动画间距
#define TimeLabel_W DXRealValue(51) // 时间宽度
#define TimeLabel_H DXRealValue(20) // 时间高度
#define TimeLabel_BubbleView_Margin DXRealValue(10) // 时间与bubble（除去箭头）内间距


@interface DXChatAudioBubbleView ()

/** 动画视图 */
@property (nonatomic, weak) UIImageView *animationImageView;
/** 发送者的动画数组 */
@property (nonatomic, strong) NSArray *senderAnimationImages;
/** 接受者的动画数组 */
@property (nonatomic, strong) NSArray *recevierAnimationImages;
/** 时间 */
@property (nonatomic, weak) UILabel *timeLabel;

@end

@implementation DXChatAudioBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AnimationImageView_W, AnimationImageView_H)];
    animationImageView.animationDuration = 1.2;
    [self addSubview:animationImageView];
    self.animationImageView = animationImageView;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TimeLabel_W, TimeLabel_H)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    self.senderAnimationImages = @[
                                   [UIImage imageNamed:@"chat_voice_myself_01"],
                                   [UIImage imageNamed:@"chat_voice_myself_02"],
                                   [UIImage imageNamed:@"chat_voice_myself_03"],
                                   [UIImage imageNamed:@"chat_voice_myself_04"]
                                   ];
    
    self.recevierAnimationImages = @[
                                     [UIImage imageNamed:@"chat_voice_other_01"],
                                     [UIImage imageNamed:@"chat_voice_other_02"],
                                     [UIImage imageNamed:@"chat_voice_other_03"],
                                     [UIImage imageNamed:@"chat_voice_other_04"]
                                     ];
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat width = BUBBLE_ARROW_WIDTH + TimeLabel_BubbleView_Margin + TimeLabel_W + AnimationImageView_TimeLabel_Margin + AnimationImageView_W + AnimationImageView_BubbleView_Margin;
    CGFloat height = DXRealValue(41);
    
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.chatMessage.is_sender) {
        self.animationImageView.x = AnimationImageView_BubbleView_Margin;
        self.animationImageView.centerY = self.height * 0.5;
        self.timeLabel.x = CGRectGetMaxX(self.animationImageView.frame) + AnimationImageView_TimeLabel_Margin;
        self.timeLabel.centerY = self.height * 0.5;
    } else {
        self.timeLabel.x = BUBBLE_ARROW_WIDTH + TimeLabel_BubbleView_Margin;
        self.timeLabel.centerY = self.height * 0.5;
        self.animationImageView.x = CGRectGetMaxX(self.timeLabel.frame) + AnimationImageView_TimeLabel_Margin;
        self.animationImageView.centerY = self.height * 0.5;
    }
}

- (void)setChatMessage:(DXChatMessage *)chatMessage {
    [super setChatMessage:chatMessage];
    
    // 时间
    if (chatMessage.length) {
        self.timeLabel.text = [NSString stringWithFormat:@"%zd \"", chatMessage.length];
        if (chatMessage.is_sender) {
            self.timeLabel.textColor = DXRGBColor(102, 102, 102);
        } else {
            self.timeLabel.textColor = [UIColor whiteColor];
        }
    }
    
    // 小喇叭
    if (chatMessage.is_sender) {
        self.animationImageView.image = [UIImage imageNamed:@"chat_voice_myself_04"];
        self.animationImageView.animationImages = self.senderAnimationImages;
    } else {
        self.animationImageView.image = [UIImage imageNamed:@"chat_voice_other_04"];
        self.animationImageView.animationImages = self.recevierAnimationImages;
    }
    
    if (chatMessage.isPlaying) {
        [self startAudioAnimation];
    } else {
        [self stopAudioAnimation];
    }
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithChatMessage:(DXChatMessage *)chatMessage {
    return DXRealValue(41);
}

- (void)bubbleViewPressed:(id)sender {
    
    [self routerEventWithName:kRouterEventAudioBubbleTapEventName userInfo:@{kMessage: self.chatMessage}];
}

- (void)startAudioAnimation {
    
    [self.animationImageView startAnimating];
}

- (void)stopAudioAnimation {
    
    [self.animationImageView stopAnimating];
}

@end
