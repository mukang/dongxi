//
//  DXChatMessage.h
//  dongxi
//
//  Created by 穆康 on 16/4/5.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMobSDK/EaseMob.h>

typedef NS_ENUM(NSInteger, DXChatMessageSourceType) {
    DXChatMessageSourceTypeEaseMod = 0,
    DXChatMessageSourceTypeNetwork
};

@interface DXChatMessage : NSObject

/** 当前用户 */
@property (nonatomic, copy) NSString *current_uid;
@property (nonatomic, copy) NSString *current_nick;
@property (nonatomic, copy) NSString *current_avatar;
@property (nonatomic, assign) DXUserVerifiedType current_verified;
/** 别人 */
@property (nonatomic, copy) NSString *other_uid;
@property (nonatomic, copy) NSString *other_nick;
@property (nonatomic, copy) NSString *other_avatar;
@property (nonatomic, assign) DXUserVerifiedType other_verified;
/** 是否是发送者 */
@property (nonatomic, assign) BOOL is_sender;
/** 是否已读 */
@property (nonatomic, assign) BOOL is_read;
/** 消息的发送状态，发送的消息有值  */
@property (nonatomic, assign) MessageDeliveryState deliveryState;
/** 消息类型 */
@property (nonatomic, assign) MessageBodyType type;
/** 聊天类型 */
@property (nonatomic, assign) EMMessageType chat_type;
/** 消息的发送时间， 由环信提供 */
@property (nonatomic, assign) long long time;
/** 该条消息的ID， 由环信提供 */
@property (nonatomic, copy) NSString *msg_id;
/** 消息正文，如果不是文本消息，该字段为空 */
@property (nonatomic, copy) NSString *msg;
/** 语音消息的时长， 如果不是语音消息， 该字段为0 */
@property (nonatomic, assign) NSUInteger length;
/** 消息的备份url，非文本消息才能使用， 文本消息，该字段为NULL */
@property (nonatomic, copy) NSString *url;
/** 消息备份的本地路径，非文本消息才能使用， 文本消息，该字段为NULL */
@property (nonatomic, copy) NSString *localPath;
/** 消息文件的名称， 非文本消息才能使用， 文本消息， 该字段为NULL */
@property (nonatomic, copy) NSString *file_name;
/** 是否正在播放 */
@property (nonatomic, assign) BOOL isPlaying;
/** 是否已播放 */
@property (nonatomic, assign) BOOL isPlayed;
/** 文件上传到服务器后返回的文件id */
@property (nonatomic, copy) NSString *file_id;
/** 附件下载状态，非文本类型有值 */
@property (nonatomic, assign)EMAttachmentDownloadStatus attachmentDownloadStatus;
/** 信息来源 */
@property (nonatomic, assign) DXChatMessageSourceType sourceType;


@property (nonatomic, strong) EMMessage *message;

@end
