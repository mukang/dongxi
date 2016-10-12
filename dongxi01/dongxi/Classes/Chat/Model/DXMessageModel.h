//
//  DXMessageModel.h
//  dongxi
//
//  Created by 穆康 on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMob.h>

@interface DXMessageModel : NSObject
{
    BOOL _isPlaying;
}

@property (nonatomic) MessageBodyType type;
@property (nonatomic, readonly) MessageDeliveryState status;

@property (nonatomic) BOOL isSender;    //是否是发送者
@property (nonatomic) BOOL isRead;      //是否已读
@property (nonatomic) EMMessageType messageType;  // 消息类型（单聊，群里，聊天室）

@property (nonatomic, strong, readonly) NSString *messageId;
@property (nonatomic, strong) NSURL *headImageURL;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *username;

/** 聊天对象的头像 */
@property (nonatomic, copy) NSString *avatar;
/** 自己的头像 */
@property (nonatomic, copy) NSString *myAvatar;
/** 聊天对象的认证类型 */
@property (nonatomic, assign) DXUserVerifiedType verified;
/** 自己的认证类型 */
@property (nonatomic, assign) DXUserVerifiedType myVerified;

//text
@property (nonatomic, strong) NSString *content;

//image
@property (nonatomic) CGSize size;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic, strong) NSURL *imageRemoteURL;
@property (nonatomic, strong) NSURL *thumbnailRemoteURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *remotePath;
@property (nonatomic) NSInteger time;
@property (nonatomic, strong) EMChatVoice *chatVoice;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPlayed;

//location
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong)id<IEMMessageBody> messageBody;
@property (nonatomic, strong)EMMessage *message;

@end
