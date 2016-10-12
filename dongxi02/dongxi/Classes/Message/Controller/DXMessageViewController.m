//
//  DXMessageViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 穆康. All rights reserved.
//

#import "DXMessageViewController.h"
#import "UIImage+Extension.h"
#import "DXMessageCell.h"
#import "DXRecentContactCell.h"
#import "DXNoneDataTableViewCell.h"
#import "DXMessageCommentViewController.h"
#import "DXMessageLikeViewController.h"
#import "DXMessageNoticeViewController.h"
#import "DXChatViewController.h"
#import <EaseMob.h>
#import "NSDate+Extension.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "DXChatRecord.h"
#import "DXMainNavigationController.h"
#import "UITabBar+Badge.h"
#import "DXUnReadInfo.h"

#import "DXChatMessageManager.h"
#import "DXChatHelper.h"

#import "DXTabBarController.h"

#import "DXAnonymousMessageViewController.h"
#import "DXLoginEaseMob.h"

@interface DXMessageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DXChatMessageManager *chatMessageManager;

@property (nonatomic, strong) NSMutableArray *latestMessages;
/** 内容视图 */
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) DXAnonymousMessageViewController *anonymousMessageVC;

@property (nonatomic, strong) NSArray *userInfos;

@end

@implementation DXMessageViewController {
    __weak DXMessageViewController *weakSelf;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_Messages;
    self.chatMessageManager = [DXChatMessageManager sharedManager];
    
    // 设置导航栏
    [self setupNav];
    
    // 设置内容
    [self setupContent];
    
    // 注册通知
    [self registerNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 设置内容视图的frame
    self.tableView.frame = self.view.bounds;
    
    if (![[DXDongXiApi api] needLogin]) {
        // 注册消息通知
        [self registerMessageNotification];
        // 获取会话列表
        [self fetchLatestMessagesFromDB];
    }
    
//    // 统计未读消息包括私聊、评论、赞和通知的消息
//    DXTabBarController *tabBarVC = (DXTabBarController *)self.tabBarController;
//    [tabBarVC checkUnreadMessage];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (![[DXDongXiApi api] needLogin]) {
        // 移除消息通知
        [self removeMessageNotification];
    }
}

- (void)dealloc {
    
    // 移除通知
    [self removeNotification];
}

#pragma mark - 获取会话列表

- (void)fetchLatestMessagesFromDB {
    
    [self.chatMessageManager readLatestMessages:^(NSArray *latestMessages, NSError *error) {
        if (latestMessages) {
            NSArray* sorte = [latestMessages sortedArrayUsingComparator:
                              ^(DXLatestMessage *obj1, DXLatestMessage* obj2){
                                  DXChatMessage *message1 = [obj1 chatMessage];
                                  DXChatMessage *message2 = [obj2 chatMessage];
                                  if(message1.time > message2.time) {
                                      return(NSComparisonResult)NSOrderedAscending;
                                  }else {
                                      return(NSComparisonResult)NSOrderedDescending;
                                  }
                              }];
            [weakSelf.chatMessageManager readUnreadMessagesCountsWithLatestMessages:sorte result:^(NSArray *latestMessages, NSError *error) {
                BOOL missUserInfo = NO;
                for (DXLatestMessage *latestMessage in latestMessages) {
                    if ([latestMessage.chatMessage.other_avatar isEqualToString:@"(null)"] || !latestMessage.chatMessage.other_avatar) {
                        missUserInfo = YES;
                        for (DXUser *user in weakSelf.userInfos) {
                            if ([user.uid isEqualToString:latestMessage.chatMessage.other_uid]) {
                                latestMessage.chatMessage.other_nick = user.nick;
                                latestMessage.chatMessage.other_avatar = user.avatar;
                                latestMessage.chatMessage.other_verified = user.verified;
                                missUserInfo = NO;
                                break;
                            }
                        }
                    }
                }
                if (missUserInfo) {
                    [weakSelf formatAndRefreshLatestMessages:latestMessages];
                } else {
                    [weakSelf.latestMessages removeAllObjects];
                    [weakSelf.latestMessages addObjectsFromArray:latestMessages];
                    [weakSelf.tableView reloadData];
                }
            }];
        }
    }];
}

#pragma mark - 设置导航栏和内容
/**
 *  设置导航栏
 */
- (void)setupNav {
    
    self.title = @"消息";
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(247, 250, 251)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:bgImage];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    
    //    self.extendedLayoutIncludesOpaqueBars = YES;
    //    self.automaticallyAdjustsScrollViewInsets = NO;
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = DXRGBColor(222, 222, 222);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[DXNoneDataTableViewCell class] forCellReuseIdentifier:@"DXNoneDataTableViewCell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    if ([[DXDongXiApi api] needLogin]) {
        [self addChildViewController:self.anonymousMessageVC];
        [self.anonymousMessageVC didMoveToParentViewController:self];
        [self.view addSubview:self.anonymousMessageVC.view];
    }
}

- (void)formatAndRefreshLatestMessages:(NSArray *)latestMessages {
    NSMutableArray *uidArray = [NSMutableArray array];
    for (DXLatestMessage *latestMessage in latestMessages) {
        [uidArray addObject:latestMessage.chatMessage.other_uid];
    }
    // 通过uid获得用户头像和昵称
    [[DXDongXiApi api] getUserInfoListWithUserIDs:uidArray result:^(DXUserWrapper *userWrapper, NSError *error) {
        if (userWrapper.list.count) {
            NSArray *users = userWrapper.list;
            for (int i=0; i<users.count; i++) {
                DXUser *user = users[i];
                DXLatestMessage *latestMessage = latestMessages[i];
                latestMessage.chatMessage.other_nick = user.nick;
                latestMessage.chatMessage.other_avatar = user.avatar;
                latestMessage.chatMessage.other_verified = user.verified;
            }
        }
        weakSelf.userInfos = userWrapper.list;
        [weakSelf.latestMessages removeAllObjects];
        [weakSelf.latestMessages addObjectsFromArray:latestMessages];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 数据源和代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 3;
    } else {
        return self.latestMessages.count ? self.latestMessages.count : 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        DXTabBarController *tabBarVC = (DXTabBarController *)self.tabBarController;
        DXMessageCell *cell = [DXMessageCell cellWithTableView:tableView];
        switch (indexPath.row) {
            case 0:
                cell.iconImageV.image = [UIImage imageNamed:@"button_news_comment"];
                cell.titleL.text = @"评论";
                cell.separatorV.hidden = NO;
                cell.hasUnReadMessage = tabBarVC.notificationDetail.comment;
                break;
            case 1:
                cell.iconImageV.image = [UIImage imageNamed:@"button_news_like"];
                cell.titleL.text = @"赞";
                cell.separatorV.hidden = NO;
                cell.hasUnReadMessage = tabBarVC.notificationDetail.like;
                break;
            case 2:
                cell.iconImageV.image = [UIImage imageNamed:@"button_news_news"];
                cell.titleL.text = @"通知";
                cell.separatorV.hidden = YES;
                cell.hasUnReadMessage = tabBarVC.notificationDetail.notice;
                break;
            default:
                break;
        }
        return cell;
    } else {
        if (self.latestMessages.count > 0) {
            DXRecentContactCell *cell = [DXRecentContactCell cellWithTableView:tableView];
            DXLatestMessage *latestMessage = self.latestMessages[indexPath.row];
            cell.latestMessage = latestMessage;
            return cell;
        } else {
            DXNoneDataTableViewCell * noneDataCell = [tableView dequeueReusableCellWithIdentifier:@"DXNoneDataTableViewCell" forIndexPath:indexPath];
//            NSArray * ramdomTexts = @[
//                                      @"没有聊天记录，快去发起一次私聊吧 ^o^",
//                                      @"没有聊天记录，也许在另外一个手机上？",
//                                      @"没有聊天记录，试试跟東西君私聊下吧 ^o^"
//                                      ];
//            noneDataCell.text = ramdomTexts[(arc4random() % ramdomTexts.count)];
            noneDataCell.text = @"没有聊天记录，快去发起一次私聊吧 ^o^";
            return noneDataCell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return DXRealValue(62);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return DXRealValue(30);
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView *headerV = [[UIView alloc] init];
        headerV.backgroundColor = DXRGBColor(240, 240, 240);
        headerV.frame = CGRectMake(0, 0, DXScreenWidth, DXRealValue(30));
        UILabel *titleL = [[UILabel alloc] init];
        titleL.text = @"最近联系人";
        titleL.textColor = DXRGBColor(102, 102, 102);
        titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
        [titleL sizeToFit];
        titleL.x = DXRealValue(13);
        titleL.centerY = headerV.height * 0.5;
        [headerV addSubview:titleL];
        return headerV;
    } else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && self.latestMessages.count > 0) {
        return YES;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DXLatestMessage *latestMessage = self.latestMessages[indexPath.row];
        [self.chatMessageManager deleteConversationWithOtherUid:latestMessage.chatMessage.other_uid result:^(BOOL success, NSError *error) {
            if (success) {
                DXLog(@"删除与%@的会话成功", latestMessage.chatMessage.other_uid);
            }
        }];
        [self.latestMessages removeObject:latestMessage];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        DXTabBarController *tabBarVC = (DXTabBarController *)self.tabBarController;
        DXUnreadMessageType type = 0;
        if (indexPath.row == 0) {
            type = DXUnreadMessageTypeComment;
            tabBarVC.notificationDetail.comment = NO;
            DXMessageCommentViewController *vc = [[DXMessageCommentViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 1) {
            type = DXUnreadMessageTypeLike;
            tabBarVC.notificationDetail.like = NO;
            DXMessageLikeViewController *vc = [[DXMessageLikeViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            type = DXUnreadMessageTypeNotice;
            tabBarVC.notificationDetail.notice = NO;
            DXMessageNoticeViewController *vc = [[DXMessageNoticeViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [[DXDongXiApi api] postUnreadMessageDidReadWithMessageType:type result:nil];
        // 统计未读消息包括私聊、评论、赞和通知的消息
        [tabBarVC checkUnreadMessage];
    } else {
        if (self.latestMessages.count == 0) {
            return;
        }
        DXLatestMessage *latestMessage = self.latestMessages[indexPath.row];
        DXUser *other_user = [[DXUser alloc] init];
        other_user.uid = latestMessage.chatMessage.other_uid;
        other_user.nick = latestMessage.chatMessage.other_nick;
        other_user.avatar = latestMessage.chatMessage.other_avatar;
        other_user.verified = latestMessage.chatMessage.other_verified;
        DXChatViewController *vc = [[DXChatViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.other_user = other_user;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 通知

- (void)registerNotification {
    
    // 当用户登出后清空整个联系人列表并显示需要登录视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDataList) name:DXDongXiApiNotificationUserDidLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAnonymousMessageVC) name:DXDongXiApiNotificationUserDidLogin object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadUnreadMessageNotification:) name:DXReloadUnreadMessageNotification object:nil];
}

- (void)removeNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXDongXiApiNotificationUserDidLogin object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXReloadUnreadMessageNotification object:nil];
}

- (void)registerMessageNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveMessageNotification:) name:DXChatDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveOfflineMessagesNotification:) name:DXChatDidReceiveOfflineMessagesNotification object:nil];
}

- (void)removeMessageNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXChatDidReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DXChatDidReceiveOfflineMessagesNotification object:nil];
}

- (void)handleDidReceiveMessageNotification:(NSNotification *)notification {
    [self fetchLatestMessagesFromDB];
}

- (void)handleDidReceiveOfflineMessagesNotification:(NSNotification *)notification {
    [self fetchLatestMessagesFromDB];
}

- (void)handleReloadUnreadMessageNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - 清空整个联系人列表

- (void)clearDataList {
    [self.latestMessages removeAllObjects];
    [self.tableView reloadData];
    
    [self addChildViewController:self.anonymousMessageVC];
    [self.anonymousMessageVC didMoveToParentViewController:self];
    [self.view addSubview:self.anonymousMessageVC.view];
    [self.view bringSubviewToFront:self.anonymousMessageVC.view];
}

- (void)removeAnonymousMessageVC {
    [DXLoginEaseMob loginEaseMobWithUserSession:[DXDongXiApi api].currentUserSession completion:^(BOOL success) {
        if (success) {
            [self fetchLatestMessagesFromDB];
        }
    }];
    
    [self.anonymousMessageVC willMoveToParentViewController:nil];
    [self.anonymousMessageVC removeFromParentViewController];
    [self.anonymousMessageVC.view removeFromSuperview];
}

#pragma mark - 懒加载

- (DXAnonymousMessageViewController *)anonymousMessageVC {
    
    if (_anonymousMessageVC == nil) {
        _anonymousMessageVC = [[DXAnonymousMessageViewController alloc] init];
    }
    return _anonymousMessageVC;
}

- (NSMutableArray *)latestMessages {
    if (_latestMessages == nil) {
        _latestMessages = [NSMutableArray array];
    }
    return _latestMessages;
}

@end
