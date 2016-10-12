//
//  DXChatViewBaseCell.m
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatViewBaseCell.h"
#import "UIResponder+Router.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"
#import "DXAvatarView.h"

NSString *const kRouterEventHeadImageViewTapEventName = @"kRouterEventHeadImageViewTapEventName";

@interface DXChatViewBaseCell ()

@end

@implementation DXChatViewBaseCell

- (instancetype)initWithChatMessage:(DXChatMessage *)chatMessage reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = DXRGBColor(222, 222, 222);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat originX = Head_Padding;
        if (chatMessage.is_sender) {
            originX = DXScreenWidth - Head_Padding - Head_WH;
        }
        
        DXAvatarView *avatarView = [[DXAvatarView alloc] initWithFrame:CGRectMake(originX, 0, Head_WH, Head_WH)];
        [self.contentView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        [avatarView addGestureRecognizer:tap];
    }
    return self;
}

- (void)setChatMessage:(DXChatMessage *)chatMessage {
    _chatMessage = chatMessage;
    
    NSString *avatar;
    DXUserVerifiedType verifiedType;
    if (chatMessage.is_sender) {
        avatar = chatMessage.current_avatar;
        verifiedType = chatMessage.current_verified;
    } else {
        avatar = chatMessage.other_avatar;
        verifiedType = chatMessage.other_verified;
    }
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(50.0f), DXRealValue(50.0f))];
    [self.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    self.avatarView.verified = verifiedType;
    self.avatarView.certificationIconSize = DXCertificationIconSizeLarge;
}


/**
 *  点击了头像
 */
- (void)headImagePressed:(id)sender {
    
    [self routerEventWithName:kRouterEventHeadImageViewTapEventName userInfo:@{kMessage: self.chatMessage}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
    [super routerEventWithName:eventName userInfo:userInfo];
}

+ (NSString *)cellIdentifierForChatMessage:(DXChatMessage *)chatMessage {
    
    NSString *ID = @"BaseCell";
    
    if (chatMessage.is_sender) {
        ID = [ID stringByAppendingString:@"Sender"];
    } else {
        ID = [ID stringByAppendingString:@"Receiver"];
    }
    
    switch (chatMessage.type) {
        case eMessageBodyType_Text:
            ID = [ID stringByAppendingString:@"Text"];
            break;
        case eMessageBodyType_Voice:
            ID = [ID stringByAppendingString:@"Audio"];
            break;
            
        default:
            break;
    }
    
    return ID;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withChatMessage:(DXChatMessage *)chatMessage {
    return Bottom_Padding + Head_WH;
}

@end
