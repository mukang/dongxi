//
//  DXChatMessageManager.h
//  dongxi
//
//  Created by 穆康 on 16/4/5.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXChatMessage.h"
#import "DXLatestMessage.h"
#import "DXSingleton.h"

@interface DXChatMessageManager : NSObject

DXSingletonInterface(Manager)

@property (nonatomic, copy, readonly) NSString *baseDirectoryPath;
@property (nonatomic, copy, readonly) NSString *audioDirectoryPath;

/**
 *  通过从服务器获取的字典数据，生成chatMessage模型
 *
 *  @param dict 字典数据
 *
 *  @return chatMessage模型
 */
- (DXChatMessage *)chatMessageWithDict:(NSDictionary *)dict;

/**
 *  通过从友盟获取的message，生成chatMessage模型
 *
 *  @param message 友盟的message
 *
 *  @return chatMessage模型
 */
- (DXChatMessage *)chatMessageWithMessage:(EMMessage *)message;

#pragma mark - *** 消息相关 ***

#pragma mark - 存储
/**
 *  插入一条消息到数据库
 *
 *  @param chatMessage 消息
 *  @param resultBlock 结果回调
 */
- (void)saveChatMessageToDB:(DXChatMessage *)chatMessage result:(void(^)(BOOL success, NSString *messageID))resultBlock;

/**
 *  插入多条消息到数据库
 *
 *  @param chatMessages 消息数组
 *  @param resultBlock  结果回调
 */
- (void)saveChatMessagesToDB:(NSArray *)chatMessages result:(void(^)(BOOL success, NSError *error))resultBlock;

#pragma mark - 读取
/**
 *  根据私聊对象和消息id，从数据库获取一条消息
 *
 *  @param otherUid    私聊对象的id
 *  @param messageID   消息id
 *  @param resultBlock 结果回调
 */
- (void)readChatMessageFromDBWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID result:(void(^)(DXChatMessage *chatMessage, NSError *error))resultBlock;

/**
 *  根据私聊对象，从数据库获取多条聊天消息
 *
 *  @param otherUid    私聊对象的id
 *  @param time        消息时间，根据时间获取之前的消息，如果不知道时间，则填0
 *  @param limit       获取消息的条数
 *  @param resultBlock 结果回调
 */
- (void)readChatMessagesFromDBWithOtherUid:(NSString *)otherUid time:(long long)time limit:(NSUInteger)limit result:(void(^)(NSArray *chatMessages, NSError *error))resultBlock;

#pragma mark - 更新
/**
 *  更新数据库中消息的发送状态
 *
 *  @param chatMessage 消息
 *  @param resultBlock 结果回调
 */
- (void)updateChatMessageDeliveryStateToDBWithChatMessage:(DXChatMessage *)chatMessage result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  更新数据库中消息的发送状态
 *
 *  @param otherUid    聊天对象的id
 *  @param messageID   消息id
 *  @param resultBlock 回调结果
 */
- (void)updateChatMessageDeliveryStateIsFailureToDBWithOtherUid:(NSString *)otherUid messsageID:(NSString *)messageID result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  更新数据库中接收到的消息的附件下载状态
 *
 *  @param chatMessage 消息
 *  @param resultBlock 结果回调
 */
- (void)updateAttachmentDownloadStatusToDBWithChatMessage:(DXChatMessage *)chatMessage result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  根据私聊对象和消息id，更新消息的状态为已读
 *
 *  @param otherUid    私聊对象的id
 *  @param messageID   消息id
 *  @param resultBlock 结果回调
 */
- (void)updateChatMessageAsReadToDBWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  更新私聊对象发送给当前用户所有消息状态为已读
 *
 *  @param otherUid    私聊对象的id
 *  @param resultBlock 结果回调
 */
- (void)updateAllChatMessagesAsReadToDBWithOtherUid:(NSString *)otherUid result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  更新语音消息为已经播放
 *
 *  @param otherUid    私聊对象的id
 *  @param messageID   消息id
 *  @param resultBlock 结果回调
 */
- (void)updateChatMessageAudioIsPlayedWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID result:(void(^)(BOOL success, NSError *error))resultBlock;

#pragma mark - *** 最近联系人相关 ***

/**
 *  查找当前用户所有会话的最新一条消息
 *
 *  @param resultBlock 回调结果
 */
- (void)readLatestMessages:(void(^)(NSArray *latestMessages, NSError *error))resultBlock;

/**
 *  通过最新消息列表读取每个会话的未读条数
 *
 *  @param latestMessages 最新消息列表
 *  @param resultBlock    回调结果
 */
- (void)readUnreadMessagesCountsWithLatestMessages:(NSArray *)latestMessages result:(void(^)(NSArray *latestMessages, NSError *error))resultBlock;

- (void)checkHadUnreadMessages:(void(^)(BOOL had, NSError *error))resultBlock;

#pragma mark - *** 删除会话 ***
/**
 *  删除会话
 *
 *  @param othetUid    聊天用户的id
 *  @param resultBlock 回调结果
 */
- (void)deleteConversationWithOtherUid:(NSString *)othetUid result:(void(^)(BOOL success, NSError *error))resultBlock;

@end
