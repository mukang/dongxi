//
//  DXChatViewController.m
//  dongxi
//
//  Created by 穆康 on 16/4/25.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatViewController.h"

#import "DXChatHelper.h"
#import "DXChatMessageManager.h"

#import "UIBarButtonItem+Extension.h"
#import "NSDate+Extension.h"
#import "UIResponder+Router.h"

#import "DXChatToolBar.h"
#import "DXChatRecordView.h"

#import "DXChatTimeCell.h"
#import "DXChatViewCell.h"

#import "EMCDDeviceManager.h"
#import "EMCDDeviceManagerDelegate.h"
#import "DXMessageReadManager.h"

#import <AVFoundation/AVFoundation.h>

// 一次请求的最多消息数
static const int kPageCount = 20;

@interface DXChatViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
DXChatToolBarDelegate,
DXChatRecordViewDelegate,
DXChatViewCellDelegate,
EMCDDeviceManagerDelegate
>
{
    __weak DXChatViewController *weakSelf;
}

/** 私聊对象 */
@property (nonatomic, copy) NSString *chatter;
/** 私聊工具 */
@property (nonatomic, strong) DXChatHelper *chatHelper;
/** 内容视图 */
@property (nonatomic, weak) UITableView *tableView;
/** 底部工具栏 */
@property (nonatomic, weak) DXChatToolBar *chatToolBar;
/** 录音视图 */
@property (nonatomic, weak) DXChatRecordView *recordView;
/** 正在播放音频 */
@property (nonatomic, assign) BOOL isPlayingAudio;
/** 滚动到底部 */
@property (nonatomic, assign) BOOL isScrollToBottom;
/** 私聊页面是否隐藏 */
@property (nonatomic, assign) BOOL isInvisible;
/** 是否设置了frame */
@property (nonatomic, assign) BOOL contentFrameSetted;
/** 盛放消息的数组 */
@property (nonatomic, strong) NSMutableArray *messages;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataList;
/** 标记时间 */
@property (nonatomic, assign) long long chatTagTime;
/** 上一次最新时间 */
@property (nonatomic, assign) long long chatLastTime;
/** 第一次加载 */
@property (nonatomic, assign, getter=isFirstLoad) BOOL firstLoad;
/** 当前用户的信息 */
@property (nonatomic, strong) DXUserSession *currentUserSession;

@end

@implementation DXChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_PrivateChat;
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    
    self.chatter = [NSString stringWithFormat:@"cuser%@", self.other_user.uid];
    self.isPlayingAudio = NO;
    self.isScrollToBottom = YES;
    self.contentFrameSetted = NO;
    self.chatTagTime = 0;
    self.chatLastTime = 0;
    self.firstLoad = YES;
    self.currentUserSession = [[DXDongXiApi api] currentUserSession];
    [self.chatHelper markAllChatMessagesAsReadByUserID:self.other_user.uid];
    [[DXDongXiApi api] setMessagesAsReadByUserID:self.other_user.uid result:nil];
    
    // 设置代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    
    [self setupNav];
    [self setupContent];
    [self registerNotification];
    [self loadMessages];
    
    // 点击隐藏键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    // 添加下拉加载旧的消息
    DXRefreshHeader *header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMessages)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 设置内容尺寸
    if (self.contentFrameSetted == NO) {
        [self setupContentFrames];
        self.contentFrameSetted = YES;
    }
    
    if (self.isScrollToBottom) {
        [self scrollViewToBottom:NO];
    }
    else{
        self.isScrollToBottom = YES;
    }
    self.isInvisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.chatHelper markAllChatMessagesAsReadByUserID:self.other_user.uid];
    [[DXDongXiApi api] setMessagesAsReadByUserID:self.other_user.uid result:nil];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    self.isInvisible = YES;
    [self keyBoardHidden];
}

- (void)dealloc {
    [self removeNotification];
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
}

/**
 *  设置导航栏
 */
- (void)setupNav {
    
    self.title = self.other_user.nick;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    // 内容视图
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = DXRGBColor(222, 222, 222);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 工具栏
    DXChatToolBar *chatToolBar = [[DXChatToolBar alloc] init];
    chatToolBar.delegate = self;
    [self.view addSubview:chatToolBar];
    self.chatToolBar = chatToolBar;
    
    // 录音视图
    DXChatRecordView *recordView = [[DXChatRecordView alloc] init];
    recordView.delegate = self;
    [self.view addSubview:recordView];
    self.recordView = recordView;
}

/**
 *  设置内容尺寸
 */
- (void)setupContentFrames {
    
    self.view.frame = CGRectMake(0, 0, DXScreenWidth, DXScreenHeight - 64);
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 49);
    
    CGFloat toolBarW = self.view.width;
    CGFloat toolBarH = 49;
    CGFloat toolBarX = 0;
    CGFloat toolBarY = self.view.height - toolBarH;
    self.chatToolBar.frame = CGRectMake(toolBarX, toolBarY, toolBarW, toolBarH);
    
    self.recordView.frame = CGRectMake(0, self.view.height, self.view.width, 225);
}

#pragma mark - 加载消息
/**
 *  加载消息
 */
- (void)loadMessages {
    
    DXChatMessage *chatMessage = [self.messages firstObject];
    NSString *messageID = chatMessage.msg_id ? chatMessage.msg_id : nil;
    long long time = chatMessage.time ? chatMessage.time : ([[NSDate date] timeIntervalSince1970] * 1000 + 1);
    [self.chatHelper fetchChatMessagesByUserID:self.other_user.uid messageID:messageID timestamp:time limit:kPageCount result:^(NSArray *chatMessages, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (chatMessages.count) {
            NSInteger currentCount = 0;
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, chatMessages.count)];
            [weakSelf.messages insertObjects:chatMessages atIndexes:indexSet];
            currentCount = weakSelf.dataList.count;
            NSArray *tempArray = [weakSelf formatMessages:chatMessages];
            indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)];
            [weakSelf.dataList insertObjects:tempArray atIndexes:indexSet];
            
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataList count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }];
}

#pragma mark - 格式化消息

- (NSArray *)formatMessages:(NSArray *)messages {
    
    self.chatTagTime = 0;
    NSInteger gapTime = 0;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (DXChatMessage *chatMessage in messages) {
        gapTime = (chatMessage.time - self.chatTagTime) / 1000;
        if (ABS(gapTime) > 60) {
            NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:(chatMessage.time / 1000)];
            [tempArray addObject:[createDate formattedTime]];
            self.chatTagTime = chatMessage.time;
        }
        chatMessage.current_nick = self.currentUserSession.nick;
        chatMessage.current_avatar = self.currentUserSession.avatar;
        chatMessage.current_verified = self.currentUserSession.verified;
        chatMessage.other_nick = self.other_user.nick;
        chatMessage.other_avatar = self.other_user.avatar;
        chatMessage.other_verified = self.other_user.verified;
        [tempArray addObject:chatMessage];
        if (chatMessage.time > self.chatLastTime) {
            self.chatLastTime = chatMessage.time;
        }
    }
    return [tempArray copy];
}

- (NSArray *)formatMessage:(DXChatMessage *)message {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    long long gapTime = (message.time - self.chatLastTime) / 1000;
    if (ABS(gapTime) > 60) {
        NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:(message.time / 1000)];
        [tempArray addObject:[createDate formattedTime]];
        self.chatLastTime = message.time;
    }
    message.current_nick = self.currentUserSession.nick;
    message.current_avatar = self.currentUserSession.avatar;
    message.current_verified = self.currentUserSession.verified;
    message.other_nick = self.other_user.nick;
    message.other_avatar = self.other_user.avatar;
    message.other_verified = self.other_user.verified;
    [tempArray addObject:message];
    
    return [tempArray copy];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = self.dataList[indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        DXChatTimeCell *cell = [DXChatTimeCell cellWithTableView:tableView];
        cell.textLabel.text = (NSString *)obj;
        return cell;
    } else {
        DXChatMessage *chatMessage = (DXChatMessage *)obj;
        NSString *cellID = [DXChatViewCell cellIdentifierForChatMessage:chatMessage];
        DXChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[DXChatViewCell alloc] initWithChatMessage:chatMessage reuseIdentifier:cellID];
        }
        cell.chatMessage = chatMessage;
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = self.dataList[indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return DXRealValue(44);
    } else {
        return [DXChatViewCell tableView:self.tableView heightForRowAtIndexPath:indexPath withChatMessage:(DXChatMessage *)obj];
    }
}

#pragma mark - DXChatToolBarDelegate

/**
 *  chatToolBar高度发生变化
 */
- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight {
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.tableView.height = weakSelf.chatToolBar.y;
    }];
    [self scrollViewToBottom:NO];
}

/**
 *  是否改为发送语音状态
 */
- (void)didStyleChangeToRecord:(BOOL)changedToRecord {
    
    if (changedToRecord) {
        
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.recordView.y = weakSelf.view.height - weakSelf.recordView.height;
            weakSelf.chatToolBar.y = weakSelf.recordView.y - weakSelf.chatToolBar.height;
            weakSelf.tableView.height = weakSelf.chatToolBar.y;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.recordView.y = weakSelf.view.height;
            weakSelf.tableView.height = weakSelf.chatToolBar.y;
        }];
    }
    [self scrollViewToBottom:NO];
}

- (void)didRecordBtnStatusChangeToShow:(BOOL)isShow {
    
    if (isShow) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.recordView.y = weakSelf.view.height - weakSelf.recordView.height;
            weakSelf.chatToolBar.y = weakSelf.recordView.y - weakSelf.chatToolBar.height;
            weakSelf.tableView.height = weakSelf.chatToolBar.y;
        } completion:^(BOOL finished) {
            weakSelf.chatToolBar.changeRecordBtn.selected = isShow;
        }];
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.recordView.y = weakSelf.view.height;
            weakSelf.chatToolBar.y = weakSelf.view.height - weakSelf.chatToolBar.height;
            weakSelf.tableView.height = weakSelf.chatToolBar.y;
            weakSelf.chatToolBar.changeRecordBtn.selected = isShow;
        }];
    }
    [self scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text {
    
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

#pragma mark - DXChatRecordViewDelegate

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(DXChatRecordView *)recordView {
    
    if (self.isPlayingAudio) {
        [[EMCDDeviceManager sharedInstance] stopPlaying];
        self.isPlayingAudio = NO;
        //        [self reloadData];
        [self.tableView reloadData];
    }
    // 开始录音
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (error) {
            DXLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
        }
    }];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(DXChatRecordView *)recordView {
    
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
        } else {
            [MBProgressHUD showHUDWithMessage:@"说话时间太短"];
        }
    }];
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(DXChatRecordView *)recordView {
    
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

#pragma mark - DXChatViewCellDelegate

- (void)chatViewCell:(DXChatViewCell *)cell replyBtnDidClickWithChatMessage:(DXChatMessage *)chatMessage {
    [self.chatHelper resendChatMessage:chatMessage];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - EMCDDeviceManagerDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!self.isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - send message

- (void)sendTextMessage:(NSString *)textMessage {
    NSDictionary *ext = @{
                          kUserID       : self.currentUserSession.uid,
                          kUserNick     : self.currentUserSession.nick,
                          kUserAvatar   : self.currentUserSession.avatar,
                          kUserVerified : @(self.currentUserSession.verified)
                          };
    DXChatMessage *chatMessage = [self.chatHelper sendTextMessage:textMessage to:self.chatter messageType:eMessageTypeChat requireEncryption:NO messageExt:ext];
    [self addChatMessage:chatMessage];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath duration:(NSInteger)duration {
    NSDictionary *ext = @{
                          kUserID       : self.currentUserSession.uid,
                          kUserNick     : self.currentUserSession.nick,
                          kUserAvatar   : self.currentUserSession.avatar,
                          kUserVerified : @(self.currentUserSession.verified)
                          };
    DXChatMessage *chatMessage = [self.chatHelper sendVoiceMessageWithLocalPath:localPath duration:duration to:self.chatter messageType:eMessageTypeChat requireEncryption:NO messageExt:ext progress:nil];
    [self addChatMessage:chatMessage];
}

#pragma mark - 通知

/**
 *  注册通知
 */
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSendMessageNotification:) name:DXChatDidSendMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveMessageSendStateNotification:) name:DXChatDidReceiveMessageSendStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveMessageNotification:) name:DXChatDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveOfflineMessagesNotification:) name:DXChatDidReceiveOfflineMessagesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageAttachmentsStatusChangedNotification:) name:DXChatDidMessageAttachmentsStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

/**
 *  移除通知
 */
- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 处理通知

- (void)handleDidSendMessageNotification:(NSNotification *)notification {
    DXChatMessage *chatMessage = [notification.userInfo objectForKey:kMessage];
    if ([chatMessage.other_uid isEqualToString:self.other_user.uid]) {
        for (int i=0; i<self.dataList.count; i++) {
            id obj = self.dataList[i];
            if ([obj isKindOfClass:[DXChatMessage class]]) {
                DXChatMessage *tempMessage = (DXChatMessage *)obj;
                if ([tempMessage.message.messageId isEqualToString:chatMessage.msg_id]) {
                    tempMessage.deliveryState = chatMessage.deliveryState;
                    tempMessage.msg_id = chatMessage.msg_id;
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [[DXChatMessageManager sharedManager] saveChatMessageToDB:tempMessage result:^(BOOL success, NSString *messageID) {
                        if (success) {
                            DXLog(@"存储消息：%@成功！", chatMessage.msg_id);
                        }
                    }];
                    break;
                }
            }
        }
        for (DXChatMessage *tempMessage in self.messages) {
            if ([tempMessage.msg_id isEqualToString:chatMessage.msg_id]) {
                tempMessage.deliveryState = chatMessage.deliveryState;
                break;
            }
        }
    }
}

- (void)handleDidReceiveMessageSendStateNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *messageID = [userInfo objectForKey:kMessageID];
    NSString *other_uid = [userInfo objectForKey:kMessageOtherUid];
    EMError *error = [userInfo objectForKey:kMessageError];
    if ([other_uid isEqualToString:self.other_user.uid]) {
        for (int i=0; i<self.dataList.count; i++) {
            id obj = self.dataList[i];
            if ([obj isKindOfClass:[DXChatMessage class]]) {
                DXChatMessage *tempMessage = (DXChatMessage *)obj;
                if ([tempMessage.msg_id isEqualToString:messageID]) {
                    tempMessage.deliveryState = eMessageDeliveryState_Failure;
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.tableView endUpdates];
                    if (error && error.errorCode == EMErrorMessageContainSensitiveWords) {
                        DXLog(@"包含敏感词");
                    }
                    break;
                }
            }
        }
    }
}

- (void)handleDidReceiveMessageNotification:(NSNotification *)notification {
    NSString *messageID = [notification.userInfo objectForKey:kMessageID];
    [self.chatHelper fetchChatMessagesByUserID:self.other_user.uid messageID:messageID result:^(DXChatMessage *chatMessage, NSError *error) {
        [weakSelf addChatMessage:chatMessage];
    }];
}

- (void)handleDidReceiveOfflineMessagesNotification:(NSNotification *)notification {
    NSInteger messageCount = [[notification.userInfo objectForKey:kMessageCount] integerValue];
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    NSInteger limit = self.messages.count + messageCount;
    [self.chatHelper fetchChatMessagesByUserID:self.other_user.uid messageID:nil timestamp:timestamp limit:limit result:^(NSArray *chatMessages, NSError *error) {
        if (chatMessages.count) {
            [self.dataList removeAllObjects];
            [self.messages removeAllObjects];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, chatMessages.count)];
            [weakSelf.messages insertObjects:chatMessages atIndexes:indexSet];
            NSArray *tempArray = [weakSelf formatMessages:chatMessages];
            indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)];
            [weakSelf.dataList insertObjects:tempArray atIndexes:indexSet];
        }
        [weakSelf.tableView reloadData];
        [weakSelf scrollViewToBottom:NO];
    }];
}

- (void)handleMessageAttachmentsStatusChangedNotification:(NSNotification *)notification {
    DXChatMessage *chatMessage = [notification.userInfo objectForKey:kMessage];
    [self reloadTableViewDataWithChatMessage:chatMessage];
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self.chatHelper markAllChatMessagesAsReadByUserID:self.other_user.uid];
    [[DXDongXiApi api] setMessagesAsReadByUserID:self.other_user.uid result:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGFloat keyboardH = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
    
    [UIView animateWithDuration:duration animations:^{
        weakSelf.chatToolBar.y = weakSelf.view.height - keyboardH - weakSelf.chatToolBar.height;
        weakSelf.tableView.height = weakSelf.chatToolBar.y;
    }];
    
    [self scrollViewToBottom:NO];
}

#pragma mark - 操作页面上的数据
/**
 *  刷新某一条消息
 */
- (void)reloadTableViewDataWithChatMessage:(DXChatMessage *)chatMessage {
    if (chatMessage.other_uid == self.other_user.uid && chatMessage.attachmentDownloadStatus == EMAttachmentDownloadSuccessed) {
        for (int i=0; i<self.dataList.count; i++) {
            id obj = self.dataList[i];
            if ([obj isKindOfClass:[DXChatMessage class]]) {
                DXChatMessage *tempMessage = (DXChatMessage *)obj;
                if ([chatMessage.msg_id isEqualToString:tempMessage.msg_id]) {
                    chatMessage.current_nick = self.currentUserSession.nick;
                    chatMessage.current_avatar = self.currentUserSession.avatar;
                    chatMessage.other_nick = self.other_user.nick;
                    chatMessage.other_avatar = self.other_user.avatar;
                    [self.tableView beginUpdates];
                    [self.dataList replaceObjectAtIndex:i withObject:chatMessage];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
        for (int i=0; i<self.messages.count; i++) {
            DXChatMessage *tempMessage = self.messages[i];
            if ([chatMessage.msg_id isEqualToString:tempMessage.msg_id]) {
                [self.messages replaceObjectAtIndex:i withObject:chatMessage];
                break;
            }
        }
    }
}
/**
 *  添加一条消息到页面上
 */
- (void)addChatMessage:(DXChatMessage *)chatMessage {
    [self.messages addObject:chatMessage];
    NSArray *chatMessages = [self formatMessage:chatMessage];
    [self.dataList addObjectsFromArray:chatMessages];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataList count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
/**
 *  滚动到最底部
 */
- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    
    DXChatMessage *chatMessage = [userInfo objectForKey:kMessage];
    if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:chatMessage];
    } else if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    } else if ([eventName isEqualToString:kRouterEventHeadImageViewTapEventName]) {
        [self chatHeadImagePressed:chatMessage];
    }
}

/**
 *  语音的bubble被点击
 */
- (void)chatAudioCellBubblePressed:(DXChatMessage *)chatMessage {
    
    if (chatMessage.attachmentDownloadStatus == EMAttachmentDownloading) {
        DXLog(@"正在下载，稍后再试");
        return;
    } else if (chatMessage.attachmentDownloadStatus == EMAttachmentDownloadFailure) {
        DXLog(@"下载失败");
        [self.chatHelper downloadMessageAttachments:chatMessage];
        return;
    }
    // 播放音频
    if (chatMessage.type == eMessageBodyType_Voice) {
        // 发送已读回执
        //        if ([self shouldAckMessage:model.message read:YES]) {
        //            [self sendHasReadResponseForMessages:@[model.message]];
        //        }
        
        DXMessageReadManager *messageReadManager = [DXMessageReadManager sharedMessageReadManager];
        BOOL isPrepare = [messageReadManager prepareAudioMessage:chatMessage updateViewCompletion:^(DXChatMessage *prevAudioMessage, DXChatMessage *currentAudioMessage) {
            if (prevAudioMessage || currentAudioMessage) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:chatMessage.localPath completion:^(NSError *error) {
                [messageReadManager stopAudioMessage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        } else {
            _isPlayingAudio = NO;
        }
    }
}

/**
 *  链接被点击
 */
- (void)chatTextCellUrlPressed:(NSURL *)url {
    
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

/**
 *  点击了头像
 */
- (void)chatHeadImagePressed:(DXChatMessage *)chatMessage {
    
    NSString *userID;
    if (chatMessage.is_sender) {
        userID = [[DXDongXiApi api] currentUserSession].uid;
    } else {
        userID = self.other_user.uid;
    }
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}


#pragma mark - 点击执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  点击隐藏键盘
 */
- (void)keyBoardHidden {
    [self.chatToolBar endEditing:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.chatToolBar.y = weakSelf.view.height - weakSelf.chatToolBar.height;
        weakSelf.recordView.y = weakSelf.view.height;
        weakSelf.tableView.height = weakSelf.chatToolBar.y;
    } completion:^(BOOL finished) {
        weakSelf.chatToolBar.changeRecordBtn.selected = NO;
    }];
}

#pragma mark - 懒加载

- (DXChatHelper *)chatHelper {
    if (_chatHelper == nil) {
        _chatHelper = [DXChatHelper sharedHelper];
    }
    return _chatHelper;
}

- (NSMutableArray *)messages {
    if (_messages == nil) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
