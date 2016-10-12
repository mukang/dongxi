//
//  DXChatHelper.m
//  dongxi
//
//  Created by 穆康 on 16/4/7.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatHelper.h"
#import "DXChatMessageManager.h"

NSString *const kMessageID = @"kMessageID";
NSString *const kMessageOtherUid = @"kMessageOtherUid";
NSString *const kMessageError = @"kMessageError";
NSString *const kMessageCount = @"kMessageCount";
NSString *const DXChatWillAutoLoginNotification             = @"DXChatWillAutoLoginNotification";
NSString *const DXChatDidAutoLoginNotification              = @"DXChatDidAutoLoginNotification";
NSString *const DXChatDidLoginNotification                  = @"DXChatDidLoginNotification";
NSString *const DXChatDidLogoffNotification                 = @"DXChatDidLogoffNotification";
NSString *const DXChatDidSendMessageNotification            = @"DXChatDidSendMessageNotification";
NSString *const DXChatDidReceiveMessageNotification         = @"DXChatDidReceiveMessageNotification";
NSString *const DXChatDidReceiveOfflineMessagesNotification = @"DXChatDidReceiveOfflineMessagesNotification";
NSString *const DXChatDidReceiveMessageSendStateNotification = @"DXChatDidReceiveMessageSendStateNotification";
NSString *const DXChatDidMessageAttachmentsStatusChangedNotification = @"DXChatDidMessageAttachmentsStatusChangedNotification";
NSString *const DXChatUnreadMessageCountDidChangeNotification = @"DXChatUnreadMessageCountDidChangeNotification";

@interface DXChatHelper () <EMChatManagerDelegate>

@property (nonatomic, strong) DXChatMessageManager *chatMessageManager;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation DXChatHelper
DXSingletonImplementation(Helper)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    
    //注册AppDelegate默认回调监听
    [self setupAppDelegateNotifications];
    
    // 注册apns
    [self registerApnsWithAplication:application];
    
    //注册easemob sdk
    [[EaseMob sharedInstance] registerSDKWithAppKey:appkey
                                       apnsCertName:apnsCertName
                                        otherConfig:otherConfig];
    
    // 注册环信监听
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //启动easemob sdk
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - app delegate notifications
// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupAppDelegateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

#pragma mark - 注册apns
- (void)registerApnsWithAplication:(UIApplication *)application {
    
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - EMChatManagerLoginDelegate

- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    
    if (error) {
        DXLog(@"环信将要自动登录失败");
    } else {
        DXLog(@"环信将要自动登录成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:DXChatWillAutoLoginNotification object:nil];
    }
}

- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    
    if (error) {
        DXLog(@"环信自动登录失败");
    } else {
        DXLog(@"环信自动登录成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidAutoLoginNotification object:nil];
    }
}

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    
    if (error) {
        DXLog(@"环信登录失败");
    } else {
        DXLog(@"环信登录成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidLoginNotification object:nil];
    }
}

- (void)didLogoffWithError:(EMError *)error {
    
    if (error) {
        DXLog(@"用户注销环信失败");
    } else {
        DXLog(@"用户注销环信成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidLogoffNotification object:nil];
    }
}

#pragma mark - EMChatManagerChatDelegate

- (void)willSendMessage:(EMMessage *)message error:(EMError *)error {
    
}

- (void)didSendMessage:(EMMessage *)message error:(EMError *)error {
    DXChatMessage *chatMessage = [self.chatMessageManager chatMessageWithMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidSendMessageNotification object:nil userInfo:@{kMessage: chatMessage}];
}

- (void)didReceiveMessage:(EMMessage *)message {
    
    DXChatMessage *chatMessage = [self.chatMessageManager chatMessageWithMessage:message];
    
    // 将消息存储到本地数据库
    [self.chatMessageManager saveChatMessageToDB:chatMessage result:^(BOOL success, NSString *messageID) {
        if (success) {
            // 存储成功后，发送已收到消息通知
            DXLog(@"存储接收的消息成功，msg_id：%@", chatMessage.msg_id);
            [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidReceiveMessageNotification object:nil userInfo:@{kMessageID: messageID}];
        }
    }];
    
    // 如果是文字消息，向服务器备份此消息
    if (chatMessage.type == eMessageBodyType_Text) {
        [[DXDongXiApi api] backupMessageWithChatMessage:chatMessage result:^(BOOL success, NSError *error) {
            if (success) {
                DXLog(@"文字消息备份成功");
            }
        }];
    }
}

// 接收到错误消息
- (void)didReceiveMessageId:(NSString *)messageId chatter:(NSString *)conversationChatter error:(EMError *)error {
    NSString *commonCharacters = @"cuser";
    NSString *other_uid = [conversationChatter substringFromIndex:commonCharacters.length];
    [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidReceiveMessageSendStateNotification
                                          object:nil
                                          userInfo:@{kMessageID: messageId,
                                                     kMessageOtherUid: other_uid,
                                                     kMessageError: error}];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error {
    
    DXChatMessage *chatMessage = [self.chatMessageManager chatMessageWithMessage:message];
    // 更新本地数据库语音消息的附件下载状态
    [self.chatMessageManager updateAttachmentDownloadStatusToDBWithChatMessage:chatMessage result:^(BOOL success, NSError *error) {
        if (success) {
            // 更新成功后，发送附件下载状态已更新通知
            [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidMessageAttachmentsStatusChangedNotification object:nil userInfo:@{kMessage: chatMessage}];
        }
    }];
    // 先向服务器备份语音消息附件
    if (chatMessage.attachmentDownloadStatus == EMAttachmentDownloadSuccessed && chatMessage.type == eMessageBodyType_Voice) {
        [[DXDongXiApi api] upLoadMessageFileWithFileType:chatMessage.type fileURL:[NSURL fileURLWithPath:chatMessage.localPath] result:^(NSString *fileID, NSError *error) {
            if (fileID) {
                // 附件备份成功后，向服务器备份该条语音消息
                chatMessage.file_id = fileID;
                [[DXDongXiApi api] backupMessageWithChatMessage:chatMessage result:^(BOOL success, NSError *error) {
                    if (success) {
                        DXLog(@"语音消息备份到服务器成功");
                    }
                }];
            }
        }];
    }
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
    
    NSMutableArray *chatMessages = [NSMutableArray array];
    for (EMMessage *message in offlineMessages) {
        DXChatMessage *chatMessage = [self.chatMessageManager chatMessageWithMessage:message];
        // 如果是文字消息，向服务器备份此消息
        if (chatMessage.type == eMessageBodyType_Text) {
            [[DXDongXiApi api] backupMessageWithChatMessage:chatMessage result:^(BOOL success, NSError *error) {
                if (success) {
                    DXLog(@"文字消息备份成功");
                }
            }];
        }
        [chatMessages addObject:chatMessage];
    }
    
    // 批量存储消息到本地数据库
    [self.chatMessageManager saveChatMessagesToDB:chatMessages result:^(BOOL success, NSError *error) {
        if (success) {
            // 存储成功后，发送已收到离线消息通知
            [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidReceiveOfflineMessagesNotification object:@{kMessageCount: @(offlineMessages.count)}];
        }
    }];
}

#pragma mark - send message

// 发送文字消息
- (DXChatMessage *)sendTextMessage:(NSString *)text
                            to:(NSString *)toUser
                   messageType:(EMMessageType)messageType
             requireEncryption:(BOOL)requireEncryption
                    messageExt:(NSDictionary *)messageExt

{
    EMChatText *textChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:textChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:toUser bodies:[NSArray arrayWithObject:body]];
    message.requireEncryption = requireEncryption;
    message.messageType = messageType;
    message.ext = messageExt;
    EMMessage *retMessage = [[EaseMob sharedInstance].chatManager asyncSendMessage:message
                                                                          progress:nil];
    DXChatMessage *chatMessage = [self.chatMessageManager chatMessageWithMessage:retMessage];
    
    return chatMessage;
}

// 发送语音消息
- (DXChatMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                    duration:(NSInteger)duration
                                          to:(NSString *)to
                                 messageType:(EMMessageType)messageType
                           requireEncryption:(BOOL)requireEncryption
                                  messageExt:(NSDictionary *)messageExt
                                    progress:(id<IEMChatProgressDelegate>)progress
{
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:localPath displayName:@"audio"];
    chatVoice.duration = duration;
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:to bodies:[NSArray arrayWithObject:body]];
    message.requireEncryption = requireEncryption;
    message.messageType = messageType;
    message.ext = messageExt;
    EMMessage *retMessage = [[EaseMob sharedInstance].chatManager asyncSendMessage:message
                                                                          progress:progress];
    DXChatMessage *chatMessage = [self.chatMessageManager chatMessageWithMessage:retMessage];
    
    return chatMessage;
}

#pragma mark - resend message

// 重新发送消息
- (void)resendChatMessage:(DXChatMessage *)chatMessage {
    NSString *chatter = [NSString stringWithFormat:@"cuser%@", chatMessage.other_uid];
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:eConversationTypeChat];
    EMMessage *message = [conversation loadMessageWithId:chatMessage.msg_id];
    [[EaseMob sharedInstance].chatManager asyncResendMessage:message progress:nil];
}

#pragma mark - load message

// 批量获取消息
- (void)fetchChatMessagesByUserID:(NSString *)userID messageID:(NSString *)messageID timestamp:(long long)timestamp limit:(NSUInteger)limit result:(void (^)(NSArray *, NSError *))resultBlock {
    
    __weak typeof(self) weakSelf = self;
    DXChatMessageManager *manager = [DXChatMessageManager sharedManager];
    // 先从本地数据库获取
    [manager readChatMessagesFromDBWithOtherUid:userID time:timestamp limit:limit result:^(NSArray *chatMessages, NSError *error) {
        if (resultBlock) {
            if (chatMessages) {
                // 获取成功
                resultBlock(chatMessages, nil);
                for (DXChatMessage *chatMessage in chatMessages) {
                    // 如果消息附件未下载成功，下载附件消息
                    if (chatMessage.type == eMessageBodyType_Voice && chatMessage.attachmentDownloadStatus > EMAttachmentDownloadSuccessed) {
                        [weakSelf downloadMessageAttachments:chatMessage];
                    }
                }
            } else {
                resultBlock(nil, error);
                /*
                if (error.code) {
                    // 如果从本地数据库获取出错，回调结果
                    resultBlock(nil, error);
                } else {
                    // 本地数据库没有消息了，从服务器获取
                    [[DXDongXiApi api] getChatListWithUserID:userID count:limit messageID:messageID result:^(NSDictionary *data, NSError *error) {
                        if (error) {
                            resultBlock(nil, error);
                        } else {
                            // 获取成功，转化成模型
                            NSArray *dictArray = [data objectForKey:@"chat_list"];
                            NSMutableArray *tempArray = [NSMutableArray array];
                            for (NSDictionary *dict in dictArray) {
                                DXChatMessage *chatMessage = [manager chatMessageWithDict:dict];
                                [tempArray addObject:chatMessage];
                            }
                            resultBlock([tempArray copy], nil);
                            // 处理得到的消息
                            [weakSelf handleMessagesWithChatMessages:[tempArray copy]];
                        }
                    }];
                }
                */
            }
        }
    }];
}

/**
 *  处理得到的消息
 */
- (void)handleMessagesWithChatMessages:(NSArray *)chatMessages {
    
    __weak typeof(self) weakSelf = self;
    // 批量存储到本地数据库
    [self.chatMessageManager saveChatMessagesToDB:chatMessages result:^(BOOL success, NSError *error) {
        if (success) {
            DXLog(@"存储从服务器获取的消息成功！");
        } else {
            DXLog(@"存储从服务器获取的消息失败！");
        }
        // 从服务器下载消息附件
        [weakSelf fetchAttachmentsWithChatMessages:chatMessages];
    }];
}

/**
 *  下载消息附件
 */
- (void)fetchAttachmentsWithChatMessages:(NSArray *)chatMessages {
    
    __weak typeof(self) weakSelf = self;
    for (DXChatMessage *chatMessage in chatMessages) {
        if (chatMessage.type == eMessageBodyType_Voice) {
            // 下载附件
            chatMessage.attachmentDownloadStatus = EMAttachmentDownloading;
            NSURLSessionDownloadTask *downloadTask = [weakSelf.session downloadTaskWithURL:[NSURL URLWithString:chatMessage.url] completionHandler:^(NSURL *location, NSURLResponse * response, NSError * _Nullable error) {
                if (!error) {
                    // 设置附件存储路径
                    NSString *filePath = [weakSelf.chatMessageManager.audioDirectoryPath stringByAppendingPathComponent:response.suggestedFilename];
                    [weakSelf.fileManager moveItemAtPath:location.path toPath:filePath error:nil];
                    chatMessage.localPath = filePath;
                    chatMessage.attachmentDownloadStatus = EMAttachmentDownloadSuccessed;
                    
                } else {
                    chatMessage.attachmentDownloadStatus = EMAttachmentDownloadFailure;
                }
                // 更新本地数据库，消息下载状态
                [weakSelf.chatMessageManager updateAttachmentDownloadStatusToDBWithChatMessage:chatMessage result:nil];
                // 发送消息附件下载状态改变通知
                [[NSNotificationCenter defaultCenter] postNotificationName:DXChatDidMessageAttachmentsStatusChangedNotification object:nil userInfo:@{kMessage: chatMessage}];
            }];
            [downloadTask resume];
        }
    }
}

- (void)fetchChatMessagesByUserID:(NSString *)userID messageID:(NSString *)messageID result:(void (^)(DXChatMessage *, NSError *))resultBlock {
    
    [self.chatMessageManager readChatMessageFromDBWithOtherUid:userID messageID:messageID result:^(DXChatMessage *chatMessage, NSError *error) {
        if (resultBlock) {
            resultBlock(chatMessage, error);
        }
    }];
}

#pragma mark - load attachment

/**
 *  从环信下载下载附件
 */
- (void)downloadMessageAttachments:(DXChatMessage *)chatMessage {
    
    NSString *chatter = [NSString stringWithFormat:@"cuser%@", chatMessage.other_uid];
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:eConversationTypeChat];
    EMMessage *message = [conversation loadMessageWithId:chatMessage.msg_id];
    [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
}

#pragma mark - update message

- (void)markAllChatMessagesAsReadByUserID:(NSString *)userID {
    
    [self.chatMessageManager updateAllChatMessagesAsReadToDBWithOtherUid:userID result:^(BOOL success, NSError *error) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DXChatUnreadMessageCountDidChangeNotification object:nil];
            DXLog(@"私聊对象：%@，所有消息已标为已读", userID);
        }
    }];
}

- (void)markChatMessageAudioIsPlayedWithOtherUid:(NSString *)otherUid messageID:(NSString *)messageID {
    
    [self.chatMessageManager updateChatMessageAudioIsPlayedWithOtherUid:otherUid messageID:messageID result:^(BOOL success, NSError *error) {
        if (success) {
            DXLog(@"语音消息：%@，在数据库中标为已播放", messageID);
        }
    }];
}

#pragma mark - 懒加载

- (DXChatMessageManager *)chatMessageManager {
    if (_chatMessageManager == nil) {
        _chatMessageManager = [DXChatMessageManager sharedManager];
    }
    return _chatMessageManager;
}

- (NSURLSession *)session {
    if (_session == nil) {
        _session = [NSURLSession sharedSession];
    }
    return _session;
}

- (NSFileManager *)fileManager {
    if (_fileManager == nil) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

@end
