//
//  DXChatBaseBubbleView.m
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatBaseBubbleView.h"
#import "UIResponder+Router.h"

NSString *const kRouterEventBaseBubbleTapEventName = @"kRouterEventBaseBubbleTapEventName";

@interface DXChatBaseBubbleView ()

/** 背景图 */
@property (nonatomic, weak) UIImageView *bgImageView;

@end

@implementation DXChatBaseBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *bgImageView = [[UIImageView alloc] init];
        bgImageView.userInteractionEnabled = YES;
        bgImageView.multipleTouchEnabled = YES;
        bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:bgImageView];
        self.bgImageView = bgImageView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setChatMessage:(DXChatMessage *)chatMessage {
    _chatMessage = chatMessage;
    
    BOOL isOther = !chatMessage.is_sender;
    NSString *imageName = isOther ? @"bg_chat_other" : @"bg_chat_myself";
    NSInteger leftCapWidth = isOther ? BUBBLE_LEFT_LEFT_CAP_WIDTH : BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight = BUBBLE_TOP_CAP_HEIGHT;
    self.bgImageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithChatMessage:(DXChatMessage *)chatMessage {
    return DXRealValue(41);
}

- (void)bubbleViewPressed:(id)sender {
    
    [self routerEventWithName:kRouterEventBaseBubbleTapEventName userInfo:@{kMessage: self.chatMessage}];
}

@end
