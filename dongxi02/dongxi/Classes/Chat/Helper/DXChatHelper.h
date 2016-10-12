//
//  DXChatHelper.h
//  dongxi
//
//  Created by 穆康 on 16/4/7.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMobSDK/EaseMob.h>
#import "DXSingleton.h"

extern NSString *const kMessageID;
extern NSString *const kMessageOtherUid;
extern NSString *const kMessageError;
extern NSString *const kMessageCount;
extern NSString *const DXChatWillAutoLoginNotification;
extern NSString *const DXChatDidAutoLoginNotification;
extern NSString *const DXChatDidLoginNotification;
extern NSString *const DXChatDidLogoffNotification;
extern NSString *const DXChatDidSendMessageNotification;
extern NSString *const DXChatDidReceiveMessageNotification;
extern NSString *const DXChatDidReceiveOfflineMessagesNotification;
extern NSString *const DXChatDidReceiveMessageSendStateNotification;
extern NSString *const DXChatDidMessageAttachmentsStatusChangedNotification;
extern NSString *const DXChatUnreadMessageCountDidChangeNotification;

@interface DXChatHelper : NSObject
DXSingletonInterface(Helper)

/**
 *  初始化环信SDK
 */
- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig;

#pragma mark - 发送消息
/**
 *  发送文字
 */
- (DXChatMessage *)sendTextMessage:(NSString *)text
                            to:(NSString *)to
                   messageType:(EMMessageType)messageType
             requireEncryption:(BOOL)requireEncryption
                    messageExt:(NSDictionary *)messageExt;

/**
 *  发送语音
 */
- (DXChatMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                    duration:(NSInteger)duration
                                          to:(NSString *)to
                                 messageType:(EMMessageType)messageType
                           requireEncryption:(BOOL)requireEncryption
                                  messageExt:(NSDictionary *)messageExt
                                    progress:(id<IEMChatProgressDelegate>)progress;

#pragma mark - 重新发送消息
/**
 *  重新发送消息
 */
- (void)resendChatMessage:(DXChatMessage *)chatMessage;

#pragma mark - 加载消息
/**
 *  获取多条消息
 */
- (void)fetchChatMessagesByUserID:(NSString *)userID messageID:(NSString *)messageID timestamp:(long long)timestamp limit:(NSUInteger)limit result:(void(^)(NSArray *chatMessages, NSError *error))resultBlock;

/**
 *  获取一条消息
 */
- (void)fetchChatMessagesByUserID:(NSString *)userID messageID:(NSString *)messageID result:(void(^)(DXChatMessage *chatMessage, NSError *error))resultBlock;

#pragma mark - 加载附件
/**
 *  加载附件
 */
- (void)downloadMessageAttachments:(DXChatMessage *)chatMessage;

#pragma mark - 更新消息
/**
 *  标记该私聊对象下所有消息为已读
 */
- (void)markAllChatMessagesAsReadByUserID:(NSString *)userID;

- (void)markChatMessageAudioIsPlayedWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID;

@end
