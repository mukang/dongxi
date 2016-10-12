//
//  DXChatMessageManager.m
//  dongxi
//
//  Created by 穆康 on 16/4/5.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatMessageManager.h"
#import "DXFunctions.h"
#import <FMDB.h>

static NSString *baseDirectory = @"dxChatManager/";
static NSString *audioDirectory = @"audio/";
static NSString *fileName = @"data.db";

@implementation DXChatMessageManager
{
    FMDatabaseQueue *_dbQueue;
    DXChatMessageManager *_weakSelf;
    NSFileManager *_fileManager;
}

DXSingletonImplementation(Manager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _weakSelf = self;
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *appIdentifierPath = [cachesPath stringByAppendingPathComponent:DXGetAppIdentifier()];
        _baseDirectoryPath = [appIdentifierPath stringByAppendingPathComponent:baseDirectory];
        _audioDirectoryPath = [_baseDirectoryPath stringByAppendingPathComponent:audioDirectory];
        
        _fileManager = [NSFileManager defaultManager];
        if (![_fileManager fileExistsAtPath:_baseDirectoryPath]) {
            [_fileManager createDirectoryAtPath:_baseDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![_fileManager fileExistsAtPath:_audioDirectoryPath]) {
            [_fileManager createDirectoryAtPath:_audioDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *filePath = [_baseDirectoryPath stringByAppendingPathComponent:fileName];
        DXLog(@"dbFilePath:%@", filePath);
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        [self prepareDatabase];
    }
    return self;
}

- (void)prepareDatabase {
    
    NSString *tableSql = @"CREATE TABLE IF NOT EXISTS t_messages ("
                          "current_uid TEXT,"
                          "other_uid TEXT,"
                          "other_nick TEXT,"
                          "other_avatar TEXT,"
                          "other_verified INTEGER,"
                          "is_sender INTEGER,"
                          "is_read INTEGER,"
                          "isPlayed INTEGER,"
                          "deliveryState INTEGER,"
                          "type INTEGER,"
                          "chat_type INTEGER,"
                          "time BIGINT,"
                          "msg_id TEXT,"
                          "msg TEXT,"
                          "length INTEGER,"
                          "url TEXT,"
                          "localPath TEXT,"
                          "file_name TEXT,"
                          "attachmentDownloadStatus INTEGER,"
                          "sourceType INTEGER);";
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeStatements:tableSql];
        if (success) {
            DXLog(@"创建t_messages成功");
        } else {
            DXLog(@"创建t_messages失败");
        }
    }];
}

- (void)saveChatMessageToDB:(DXChatMessage *)chatMessage result:(void (^)(BOOL, NSString *))resultBlock {
    NSString *sql = @"INSERT INTO t_messages (current_uid, other_uid, other_nick, other_avatar, other_verified, is_sender, is_read, isPlayed, deliveryState, type, chat_type, time, msg_id, msg, length, url, localPath, file_name, attachmentDownloadStatus, sourceType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:sql,
                            chatMessage.current_uid,
                            chatMessage.other_uid,
                            chatMessage.other_nick,
                            chatMessage.other_avatar,
                            @(chatMessage.other_verified),
                            @(chatMessage.is_sender),
                            @(chatMessage.is_read),
                            @(chatMessage.isPlayed),
                            @(chatMessage.deliveryState),
                            @(chatMessage.type),
                            @(chatMessage.chat_type),
                            @(chatMessage.time),
                            chatMessage.msg_id,
                            chatMessage.msg ?: [NSNull null],
                            @(chatMessage.length),
                            chatMessage.url ?: [NSNull null],
                            chatMessage.localPath ?: [NSNull null],
                            chatMessage.file_name ?: [NSNull null],
                            @(chatMessage.attachmentDownloadStatus),
                            @(chatMessage.sourceType)];
            if (resultBlock) {
                if (success) {
                    DX_CALL_ASYNC_MQ(resultBlock(YES, chatMessage.msg_id));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, nil));
                    DXLog(@"插入消息：%@失败", chatMessage.msg_id);
                }
            }
        }];
    });
}

- (void)saveChatMessagesToDB:(NSArray *)chatMessages result:(void (^)(BOOL, NSError *))resultBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableString *sqlStr = [NSMutableString string];
        for (DXChatMessage *chatMessage in chatMessages) {
            NSString *temp = [NSString stringWithFormat:@"INSERT INTO t_messages (current_uid, other_uid, other_nick, other_avatar, other_verified, is_sender, is_read, isPlayed, deliveryState, type, chat_type, time, msg_id, msg, length, url, localPath, file_name, attachmentDownloadStatus, sourceType) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');",
                              chatMessage.current_uid,
                              chatMessage.other_uid,
                              chatMessage.other_nick,
                              chatMessage.other_avatar,
                              @(chatMessage.other_verified),
                              @(chatMessage.is_sender),
                              @(chatMessage.is_read),
                              @(chatMessage.isPlayed),
                              @(chatMessage.deliveryState),
                              @(chatMessage.type),
                              @(chatMessage.chat_type),
                              @(chatMessage.time),
                              chatMessage.msg_id,
                              chatMessage.msg,
                              @(chatMessage.length),
                              chatMessage.url,
                              chatMessage.localPath,
                              chatMessage.file_name,
                              @(chatMessage.attachmentDownloadStatus),
                              @(chatMessage.sourceType)];
            [sqlStr appendString:temp];
        }
        NSString *sql = [sqlStr copy];
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeStatements:sql];
            if (resultBlock) {
                if (success) {
                    DX_CALL_ASYNC_MQ(resultBlock(YES, nil));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, [db lastError]));
                }
            }
        }];
    });
}

- (void)readChatMessageFromDBWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID result:(void (^)(DXChatMessage *, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM t_messages WHERE current_uid = ? AND other_uid = ? AND msg_id = ?",
                               current_uid,
                               otherUid,
                               messageID];
            NSMutableArray *temp = [NSMutableArray array];
            while ([rs next]) {
                DXChatMessage *chatMessage  = [[DXChatMessage alloc] init];
                chatMessage.current_uid     = [rs stringForColumn:@"current_uid"];
                chatMessage.other_uid       = [rs stringForColumn:@"other_uid"];
                chatMessage.other_nick      = [rs stringForColumn:@"other_nick"];
                chatMessage.other_avatar    = [rs stringForColumn:@"other_avatar"];
                chatMessage.other_verified  = [rs intForColumn:@"other_verified"];
                chatMessage.is_sender       = [rs boolForColumn:@"is_sender"];
                chatMessage.is_read         = [rs boolForColumn:@"is_read"];
                chatMessage.isPlayed        = [rs boolForColumn:@"isPlayed"];
                chatMessage.deliveryState   = [rs intForColumn:@"deliveryState"];
                chatMessage.type            = [rs intForColumn:@"type"];
                chatMessage.chat_type       = [rs intForColumn:@"chat_type"];
                chatMessage.time            = [rs longLongIntForColumn:@"time"];
                chatMessage.msg_id          = [rs stringForColumn:@"msg_id"];
                chatMessage.msg             = [rs stringForColumn:@"msg"];
                chatMessage.length          = [rs intForColumn:@"length"];
                chatMessage.url             = [rs stringForColumn:@"url"];
                chatMessage.localPath       = [rs stringForColumn:@"localPath"];
                chatMessage.file_name       = [rs stringForColumn:@"file_name"];
                chatMessage.attachmentDownloadStatus = [rs intForColumn:@"attachmentDownloadStatus"];
                chatMessage.sourceType      = [rs intForColumn:@"sourceType"];
                
                [temp addObject:chatMessage];
            }
            [rs close];
            if (resultBlock) {
                DX_CALL_ASYNC_MQ(resultBlock([temp firstObject], [db lastError]));
            }
        }];
    });
}

- (void)readChatMessagesFromDBWithOtherUid:(NSString *)otherUid time:(long long)time limit:(NSUInteger)limit result:(void (^)(NSArray *, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    if (!time) {
        time = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM (SELECT * FROM t_messages WHERE current_uid = ? AND other_uid = ? AND time < ? ORDER BY time DESC LIMIT ?) AS t ORDER BY t.time",
                               current_uid,
                               otherUid,
                               [NSNumber numberWithLongLong:time],
                               [NSNumber numberWithInteger:limit]];
            NSMutableArray *temp = [NSMutableArray array];
            while ([rs next]) {
                DXChatMessage *chatMessage  = [[DXChatMessage alloc] init];
                chatMessage.current_uid     = [rs stringForColumn:@"current_uid"];
                chatMessage.other_uid       = [rs stringForColumn:@"other_uid"];
                chatMessage.other_nick      = [rs stringForColumn:@"other_nick"];
                chatMessage.other_avatar    = [rs stringForColumn:@"other_avatar"];
                chatMessage.other_verified  = [rs intForColumn:@"other_verified"];
                chatMessage.is_sender       = [rs boolForColumn:@"is_sender"];
                chatMessage.is_read         = [rs boolForColumn:@"is_read"];
                chatMessage.isPlayed        = [rs boolForColumn:@"isPlayed"];
                chatMessage.deliveryState   = [rs intForColumn:@"deliveryState"];
                chatMessage.type            = [rs intForColumn:@"type"];
                chatMessage.chat_type       = [rs intForColumn:@"chat_type"];
                chatMessage.time            = [rs longLongIntForColumn:@"time"];
                chatMessage.msg_id          = [rs stringForColumn:@"msg_id"];
                chatMessage.msg             = [rs stringForColumn:@"msg"];
                chatMessage.length          = [rs intForColumn:@"length"];
                chatMessage.url             = [rs stringForColumn:@"url"];
                chatMessage.localPath       = [rs stringForColumn:@"localPath"];
                chatMessage.file_name       = [rs stringForColumn:@"file_name"];
                chatMessage.attachmentDownloadStatus = [rs intForColumn:@"attachmentDownloadStatus"];
                chatMessage.sourceType      = [rs intForColumn:@"sourceType"];
                
                [temp addObject:chatMessage];
            }
            [rs close];
            if (resultBlock) {
                if ([db hadError]) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, [db lastError]));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(temp, nil));
                }
            }
        }];
    });
}

- (void)updateChatMessageDeliveryStateToDBWithChatMessage:(DXChatMessage *)chatMessage result:(void (^)(BOOL, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    NSString *other_uid = chatMessage.other_uid;
    NSString *msg_id = chatMessage.msg_id;
    MessageDeliveryState deliveryState = chatMessage.deliveryState;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"UPDATE t_messages SET deliveryState = ? WHERE current_uid = ? AND other_uid = ? AND msg_id = ?",
                            [NSNumber numberWithInteger:deliveryState],
                            current_uid,
                            other_uid,
                            msg_id];
            if (resultBlock) {
                if (success) {
                    DX_CALL_ASYNC_MQ(resultBlock(YES, nil));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, [db lastError]));
                }
            }
        }];
    });
}

- (void)updateChatMessageDeliveryStateIsFailureToDBWithOtherUid:(NSString *)otherUid messsageID:(NSString *)messageID result:(void (^)(BOOL, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    NSString *other_uid = otherUid;
    NSString *msg_id = messageID;
    MessageDeliveryState deliveryState = eMessageDeliveryState_Failure;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"UPDATE t_messages SET deliveryState = ? WHERE current_uid = ? AND other_uid = ? AND msg_id = ?",
                            [NSNumber numberWithInteger:deliveryState],
                            current_uid,
                            other_uid,
                            msg_id];
            if (resultBlock) {
                if (success) {
                    DX_CALL_ASYNC_MQ(resultBlock(YES, nil));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, [db lastError]));
                }
            }
        }];
    });
}

- (void)updateAttachmentDownloadStatusToDBWithChatMessage:(DXChatMessage *)chatMessage result:(void (^)(BOOL, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"UPDATE t_messages SET attachmentDownloadStatus = ?, sourceType = ? WHERE current_uid = ? AND other_uid = ? AND msg_id = ?",
                            @(chatMessage.attachmentDownloadStatus),
                            @(chatMessage.sourceType),
                            current_uid,
                            chatMessage.other_uid,
                            chatMessage.msg_id];
            if (resultBlock) {
                DX_CALL_ASYNC_MQ(resultBlock(success, [db lastError]));
            }
        }];
    });
}

- (void)updateChatMessageAsReadToDBWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID result:(void (^)(BOOL, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"UPDATE t_messages SET is_read = ? WHERE current_uid = ? AND other_uid = ? AND msg_id = ?",
                            [NSNumber numberWithInteger:1],
                            current_uid,
                            otherUid,
                            messageID];
            if (resultBlock) {
                DX_CALL_ASYNC_MQ(resultBlock(success, [db lastError]));
            }
        }];
    });
}

- (void)updateAllChatMessagesAsReadToDBWithOtherUid:(NSString *)otherUid result:(void (^)(BOOL, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"UPDATE t_messages SET is_read = ? WHERE current_uid = ? AND other_uid = ? AND is_sender = ?",
                            [NSNumber numberWithInteger:1],
                            current_uid,
                            otherUid,
                            [NSNumber numberWithInteger:0]];
            if (resultBlock) {
                DX_CALL_ASYNC_MQ(resultBlock(success, [db lastError]));
            }
        }];
    });
}

- (void)updateChatMessageAudioIsPlayedWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID result:(void (^)(BOOL, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"UPDATE t_messages SET isPlayed = ? WHERE current_uid = ? AND other_uid = ? AND msg_id = ? AND type = ?",
                            [NSNumber numberWithInteger:1],
                            current_uid,
                            otherUid,
                            messageID,
                            [NSNumber numberWithInteger:eMessageBodyType_Voice]];
            if (resultBlock) {
                DX_CALL_ASYNC_MQ(resultBlock(success, [db lastError]));
            }
        }];
    });
}

- (void)readLatestMessages:(void (^)(NSArray *, NSError *))resultBlock {
    
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM (SELECT current_uid, other_uid, other_nick, other_avatar, other_verified, is_sender, is_read, isPlayed, deliveryState, type, chat_type, msg_id, msg, length, url, localPath, file_name, attachmentDownloadStatus, sourceType, MAX(time) AS time FROM t_messages WHERE current_uid = ? GROUP BY other_uid) AS t ORDER BY t.time", current_uid];
            NSMutableArray *temp = [NSMutableArray array];
            while ([rs next]) {
                DXChatMessage *chatMessage  = [[DXChatMessage alloc] init];
                chatMessage.current_uid     = [rs stringForColumn:@"current_uid"];
                chatMessage.other_uid       = [rs stringForColumn:@"other_uid"];
                chatMessage.other_nick      = [rs stringForColumn:@"other_nick"];
                chatMessage.other_avatar    = [rs stringForColumn:@"other_avatar"];
                chatMessage.other_verified  = [rs intForColumn:@"other_verified"];
                chatMessage.is_sender       = [rs boolForColumn:@"is_sender"];
                chatMessage.is_read         = [rs boolForColumn:@"is_read"];
                chatMessage.isPlayed        = [rs boolForColumn:@"isPlayed"];
                chatMessage.deliveryState   = [rs intForColumn:@"deliveryState"];
                chatMessage.type            = [rs intForColumn:@"type"];
                chatMessage.chat_type       = [rs intForColumn:@"chat_type"];
                chatMessage.time            = [rs longLongIntForColumn:@"time"];
                chatMessage.msg_id          = [rs stringForColumn:@"msg_id"];
                chatMessage.msg             = [rs stringForColumn:@"msg"];
                chatMessage.length          = [rs intForColumn:@"length"];
                chatMessage.url             = [rs stringForColumn:@"url"];
                chatMessage.localPath       = [rs stringForColumn:@"localPath"];
                chatMessage.file_name       = [rs stringForColumn:@"file_name"];
                chatMessage.attachmentDownloadStatus = [rs intForColumn:@"attachmentDownloadStatus"];
                chatMessage.sourceType      = [rs intForColumn:@"sourceType"];
                
                DXLatestMessage *latestMessage = [[DXLatestMessage alloc] init];
                latestMessage.chatMessage = chatMessage;
                [temp addObject:latestMessage];
            }
            [rs close];
            if (resultBlock) {
                if ([db hadError]) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, [db lastError]));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(temp, nil));
                }
            }
        }];
    });
}

- (void)readUnreadMessagesCountsWithLatestMessages:(NSArray *)latestMessages result:(void (^)(NSArray *, NSError *))resultBlock {
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSMutableString *userUidsString = [[NSMutableString alloc] init];
            for (DXLatestMessage *latestMessage in latestMessages) {
                [userUidsString appendFormat:@"%@, ", latestMessage.chatMessage.other_uid];
            }
            if (userUidsString.length > 2) {
                [userUidsString deleteCharactersInRange:NSMakeRange(userUidsString.length - 2, 2)];
            }
            NSString *query = [NSString stringWithFormat:@"SELECT other_uid, COUNT(other_uid) AS unread_count FROM t_messages WHERE other_uid IN (%@) AND current_uid = %@ AND is_read = %@ GROUP BY other_uid", userUidsString, current_uid, [NSNumber numberWithInt:0]];
            FMResultSet *rs = [db executeQuery:query];
            if ([rs next]) {
                NSString *other_uid = [rs stringForColumn:@"other_uid"];
                NSInteger unread_count = [rs intForColumn:@"unread_count"];
                for (DXLatestMessage *latestMessage in latestMessages) {
                    if ([latestMessage.chatMessage.other_uid isEqualToString:other_uid]) {
                        latestMessage.unreadCount = unread_count;
                        break;
                    }
                }
            }
            [rs close];
            if (resultBlock) {
                if ([db hadError]) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, [db lastError]));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(latestMessages, nil));
                }
            }
        }];
    });
}

- (void)checkHadUnreadMessages:(void (^)(BOOL, NSError *))resultBlock {
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            int unread_count = [db intForQuery:@"SELECT COUNT(is_read) FROM t_messages WHERE current_uid = ? AND is_read = 0", current_uid];
            if (resultBlock) {
                if ([db hadError]) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, [db lastError]));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(unread_count, nil));
                }
            }
        }];
    });
}

- (void)deleteConversationWithOtherUid:(NSString *)othetUid result:(void (^)(BOOL, NSError *))resultBlock {
    NSString *current_uid = [DXDongXiApi api].currentUserSession.uid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"DELETE FROM t_messages WHERE current_uid = ? AND other_uid = ?", current_uid, othetUid];
            if (resultBlock) {
                if ([db hadError]) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, [db lastError]));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(success, nil));
                }
            }
        }];
    });
}

- (DXChatMessage *)chatMessageWithDict:(NSDictionary *)dict {
    DXChatMessage *chatMessage = [[DXChatMessage alloc] init];
    
    NSString *send_uid = [dict objectForKey:@"uid"];
    NSString *send_avatar = [dict objectForKey:@"avatar"];
    NSString *send_username = [dict objectForKey:@"username"];
    DXUserVerifiedType send_verified = [[dict objectForKey:@"verified"] integerValue];
    NSString *receive_uid = [dict objectForKey:@"other_uid"];
    NSString *receive_avatar = [dict objectForKey:@"other_avatar"];
    NSString *receive_username = [dict objectForKey:@"other_username"];
    DXUserVerifiedType receive_verified = [[dict objectForKey:@"other_verified"] integerValue];
    BOOL is_sender = [[dict objectForKey:@"is_sender"] boolValue];
    
    chatMessage.is_sender = is_sender;
    chatMessage.current_uid = is_sender ? send_uid : receive_uid;
    chatMessage.current_avatar = is_sender ? send_avatar : receive_avatar;
    chatMessage.current_nick = is_sender ? send_username : receive_username;
    chatMessage.current_verified = is_sender ? send_verified : receive_verified;
    chatMessage.other_uid = is_sender ? receive_uid : send_uid;
    chatMessage.other_avatar = is_sender ? receive_avatar : send_avatar;
    chatMessage.other_nick = is_sender ? receive_username : send_username;
    chatMessage.other_verified = is_sender ? receive_verified : send_verified;
    
    chatMessage.is_read = [dict objectForKey:@"is_read"];
    chatMessage.type = [[dict objectForKey:@"type"] integerValue];
    chatMessage.chat_type = [[dict objectForKey:@"chat_type"] integerValue];
    chatMessage.time = [[dict objectForKey:@"time"] longLongValue];
    chatMessage.msg_id = [dict objectForKey:@"msg_id"];
    chatMessage.deliveryState = eMessageDeliveryState_Delivered;
    chatMessage.sourceType = DXChatMessageSourceTypeNetwork;
    
    if (chatMessage.type == eMessageBodyType_Text) {
        chatMessage.msg = [dict objectForKey:@"msg"];
    } else {
        chatMessage.length = [[dict objectForKey:@"length"] integerValue];
        chatMessage.url = [dict objectForKey:@"url"];
        
        chatMessage.file_name = [dict objectForKey:@"file_name"];
        chatMessage.attachmentDownloadStatus = EMAttachmentNotStarted;
    }
    return chatMessage;
}

- (DXChatMessage *)chatMessageWithMessage:(EMMessage *)message {
    
    DXChatMessage *chatMessage = [[DXChatMessage alloc] init];
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    
    NSString *commonCharacters = @"cuser";
    NSString *from_uid = [message.from substringFromIndex:commonCharacters.length];
    NSString *to_uid = [message.to substringFromIndex:commonCharacters.length];
    
    NSDictionary *userInfo = [[EaseMob sharedInstance].chatManager loginInfo];
    NSString *login = [userInfo objectForKey:kSDKUsername];
    
    if ([login isEqualToString:message.from]) {
        chatMessage.current_uid = from_uid;
        chatMessage.other_uid = to_uid;
        chatMessage.is_sender = YES;
        chatMessage.deliveryState = message.deliveryState;
        chatMessage.is_read = YES;
    } else {
        chatMessage.current_uid = to_uid;
        chatMessage.other_uid = from_uid;
        chatMessage.is_sender = NO;
        chatMessage.is_read = NO;
    }
    
    if (message.ext) {
        NSDictionary *ext = message.ext;
        chatMessage.other_nick = [ext objectForKey:kUserNick];
        chatMessage.other_avatar = [ext objectForKey:kUserAvatar];
        chatMessage.other_verified = [[ext objectForKey:kUserVerified] integerValue];
    }
    
    chatMessage.type = messageBody.messageBodyType;
    chatMessage.chat_type = message.messageType;
    chatMessage.time = message.timestamp;
    chatMessage.msg_id = message.messageId;
    chatMessage.isPlaying = NO;
    chatMessage.isPlayed = NO;
    chatMessage.sourceType = DXChatMessageSourceTypeEaseMod;
    chatMessage.message = message;
    
    switch (messageBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            EMTextMessageBody *textMessageBody = (EMTextMessageBody *)messageBody;
            chatMessage.msg = textMessageBody.text;
        }
            break;
            
        case eMessageBodyType_Voice:
        {
            EMVoiceMessageBody *voiceMessageBody = (EMVoiceMessageBody *)messageBody;
            chatMessage.length = voiceMessageBody.duration;
            chatMessage.url = voiceMessageBody.remotePath;
            chatMessage.localPath = voiceMessageBody.localPath;
            chatMessage.file_name = voiceMessageBody.displayName;
            chatMessage.attachmentDownloadStatus = voiceMessageBody.attachmentDownloadStatus;
        }
            break;
            
        default:
            break;
    }
    
    return chatMessage;
}

@end
