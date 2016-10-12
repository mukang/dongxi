//
//  DXConversationModel.h
//  dongxi
//
//  Created by 穆康 on 15/11/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EMConversation;

@interface DXConversationModel : NSObject

@property (nonatomic, strong, readonly) EMConversation *conversation;

@property (nonatomic, copy) NSString *lastMessage;
@property (nonatomic, copy) NSString *lastMessageTime;
@property (nonatomic, assign) NSInteger unReadCount;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, assign) DXUserVerifiedType verified;

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end
