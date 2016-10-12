//
//  DXSettingViewController.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSettingViewController.h"

#import "DXProfileSettingNameCell.h"
#import "DXProfileSettingTagsCell.h"
#import "DXProfileSettingPasswordCell.h"
#import "DXProfileSettingNotificationCell.h"
#import "DXProfileSettingCacheClearCell.h"
#import "DXProfileSettingShareCell.h"
#import "DXProfileSettingAppRemarkCell.h"
#import "DXProfileSettingAboutUsCell.h"
#import "DXProfileSettingFeedbackCell.h"
#import "DXProfileSettingLogoutCell.h"

#import "DXDongXiApi.h"
#import "DXShareView.h"

#import "DXProfileViewController.h"
#import "DXLoginViewController.h"
#import "DXHomeViewController.h"
#import "DXPasswordChangeViewController.h"
#import "DXProfileUpdateViewController.h"
#import "DXSuggestionViewController.h"
#import "DXAboutUsViewController.h"
#import "DXTagViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import <EaseMob.h>

@interface DXSettingViewController ()

@property (nonatomic, assign) BOOL notificationOn;
@property (nonatomic, assign) BOOL notificationSoundOn;

@end

typedef enum : NSUInteger {
    kDXProfileSettingSectionName = 0,
    kDXProfileSettingSectionNotification,
    kDXProfileSettingSectionOthers,
    kDXProfileSettingSectionChangePassword,
    kDXProfileSettingSectionLogout
} kDXProfileSettingSection;

@implementation DXSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_Settings;
    
    self.title = @"设置";

    [self.tableView registerClass:[DXProfileSettingNameCell class] forCellReuseIdentifier:@"DXProfileSettingNameCell"];
    [self.tableView registerClass:[DXProfileSettingTagsCell class] forCellReuseIdentifier:@"DXProfileSettingTagsCell"];
    [self.tableView registerClass:[DXProfileSettingPasswordCell class] forCellReuseIdentifier:@"DXProfileSettingPasswordCell"];
    [self.tableView registerClass:[DXProfileSettingNotificationCell class] forCellReuseIdentifier:@"DXProfileSettingNotificationCell"];
    [self.tableView registerClass:[DXProfileSettingCacheClearCell class] forCellReuseIdentifier:@"DXProfileSettingCacheClearCell"];
    [self.tableView registerClass:[DXProfileSettingShareCell class] forCellReuseIdentifier:@"DXProfileSettingShareCell"];
    [self.tableView registerClass:[DXProfileSettingAppRemarkCell class] forCellReuseIdentifier:@"DXProfileSettingAppRemarkCell"];
    [self.tableView registerClass:[DXProfileSettingAboutUsCell class] forCellReuseIdentifier:@"DXProfileSettingAboutUsCell"];
    [self.tableView registerClass:[DXProfileSettingFeedbackCell class] forCellReuseIdentifier:@"DXProfileSettingFeedbackCell"];
    [self.tableView registerClass:[DXProfileSettingLogoutCell class] forCellReuseIdentifier:@"DXProfileSettingLogoutCell"];
    self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.separatorColor = DXRGBColor(221, 221, 221);
    
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    
    //设置整个tableView的footerView
    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    footerV.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.tableFooterView = footerV;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self checkAndUpdateNotificationSettings];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)setNotificationOn:(BOOL)notificationOn {
    if (_notificationOn == notificationOn) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDXProfileSettingSectionNotification] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    _notificationOn = notificationOn;
}

- (void)setNotificationSoundOn:(BOOL)notificationSoundOn {
    if (_notificationSoundOn == notificationSoundOn) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDXProfileSettingSectionNotification] withRowAnimation:UITableViewRowAnimationNone];
    }

    _notificationSoundOn = notificationSoundOn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kDXProfileSettingSectionName) {
        if ([[DXDongXiApi api] needLogin]) {
            return 0;
        } else {
            return 2;
        }
    } else if (section == kDXProfileSettingSectionNotification){
        return 2;
    } else if (section == kDXProfileSettingSectionOthers){
        return 5;
    } else {
        // “修改密码”和“退出”区域
        if ([[DXDongXiApi api] needLogin]) {
            return 0;
        } else {
            return 1;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * currentCell = nil;
    
    if (indexPath.section == kDXProfileSettingSectionName) {
        if (indexPath.row == 0) {
            DXProfileSettingNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingNameCell" forIndexPath:indexPath];
            if (self.userProfile) {
                cell.nameLabel.text = self.userProfile.username;
            } else {
                cell.nameLabel.text = [DXDongXiApi api].currentUserSession.nick;
            }
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userProfile.avatar]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            currentCell = cell;
        } else {
            DXProfileSettingTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingTagsCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            currentCell = cell;
        }
    } else if(indexPath.section == kDXProfileSettingSectionNotification){
        DXProfileSettingNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingNotificationCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell.settingIconView setImage:[UIImage imageNamed:@"set_notice"]];
            [cell.settingTextLabel setText:@"消息推送"];
            [cell.settingSwitch addTarget:self action:@selector(notificationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.settingSwitch.on = self.notificationOn;
        }else{
            [cell.settingIconView setImage:[UIImage imageNamed:@"set_voice"]];
            [cell.settingTextLabel setText:@"声音提醒"];
            [cell.settingSwitch addTarget:self action:@selector(notificationSoundSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.settingSwitch.on = self.notificationSoundOn;
        }
        currentCell = cell;
    } else if (indexPath.section == kDXProfileSettingSectionOthers){
        if (indexPath.row == 0) {
            currentCell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingCacheClearCell" forIndexPath:indexPath];
        } else if(indexPath.row == 1){
            currentCell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingShareCell" forIndexPath:indexPath];
        } else if(indexPath.row == 2){
            currentCell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingAppRemarkCell" forIndexPath:indexPath];
        } else if (indexPath.row == 3){
            currentCell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingAboutUsCell" forIndexPath:indexPath];
        } else {
            currentCell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingFeedbackCell" forIndexPath:indexPath];
        }
    } else if (indexPath.section == kDXProfileSettingSectionChangePassword) {
        currentCell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingPasswordCell" forIndexPath:indexPath];
    } else {
        DXProfileSettingLogoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingLogoutCell" forIndexPath:indexPath];
        [cell.logoutButton addTarget:self action:@selector(logoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        currentCell = cell;
    }
    return currentCell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return DXRealValue(6.6);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return DXRealValue(62);
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kDXProfileSettingSectionName) {
        if (indexPath.row == 0) {
            if (self.userProfile) {
                DXProfileUpdateViewController *userDataViewController = [[DXProfileUpdateViewController alloc] init];
                userDataViewController.userProfile = self.userProfile;
                [self.navigationController pushViewController:userDataViewController animated:YES];
            } else {
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setTitle:@"无法修改"];
                [alert setMessage:@"未能获取你的信息"];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"好" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:self animated:YES completion:nil];
            }
        } else {
            DXTagViewController *vc = [[DXTagViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == kDXProfileSettingSectionOthers){
        if (indexPath.row == 0) {
            [self clearAppCache];
        }
        
        if (indexPath.row == 1) {
            [self shareAppToFriend];
        }
        
        if (indexPath.row == 2) {
            [self rateOurApp];
        }
        
        if (indexPath.row == 3) {
            DXAboutUsViewController *aboutUsVC = [[DXAboutUsViewController alloc] init];
            [self.navigationController pushViewController:aboutUsVC animated:YES];
        }
        if (indexPath.row == 4) {
            DXSuggestionViewController *suggesVC = [[DXSuggestionViewController alloc] init];
            [self.navigationController pushViewController:suggesVC animated:YES];
        }
    }
    
    if (indexPath.section == kDXProfileSettingSectionChangePassword) {
        DXPasswordChangeViewController * passwordChangeViewController = [[DXPasswordChangeViewController alloc] init];
        [self.navigationController pushViewController:passwordChangeViewController animated:YES];
    }
    
    if (indexPath.section == kDXProfileSettingSectionLogout){
        [self logoutConfirm];
    }
}


#pragma mark - 注销

- (IBAction)logoutButtonTapped:(id)sender {
    [self logoutConfirm];
}

- (void)logoutConfirm {
    __weak DXSettingViewController * weakSelf = self;
    
    DXCompatibleAlert * logoutConfirmAlert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    logoutConfirmAlert.title = @"确定退出登录吗？";
    DXCompatibleAlertAction * confirmAction = [DXCompatibleAlertAction actionWithTitle:@"确定"
                                                                                 style:DXCompatibleAlertActionStyleDefault
                                                                               handler:^(DXCompatibleAlertAction *action) {
                                                                                   [weakSelf logout];
                                                                               }];
    DXCompatibleAlertAction * cancelAction = [DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil];
    [logoutConfirmAlert addAction:confirmAction];
    [logoutConfirmAlert addAction:cancelAction];
    [logoutConfirmAlert showInController:self animated:YES completion:nil];
}

- (void)logout {
    UITabBarController * tabController = self.tabBarController;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [tabController setSelectedIndex:0];
    
    [[DXDongXiApi api] logoutWithResult:nil];
}

#pragma mark - Handle Notification

- (void)applicationWillEnterForeground:(NSNotification *)noti {
    [self checkAndUpdateNotificationSettings];
}

#pragma mark - 缓存


- (void)clearAppCache {
    DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"正在计算缓存.." fromController:self];
    notice.disableAutoDismissed = YES;
    [notice show];
    __weak DXScreenNotice * weakNotice = notice;
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        [weakNotice updateMessage:@"正在清理缓存"];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [weakNotice updateMessage:[NSString stringWithFormat:@"已清理%.2fM缓存", totalSize/1e6]];
            [weakNotice dismiss:YES];
        }];
    }];
}

#pragma mark - 分享

- (void)shareAppToFriend {
    UIImage * appIcon = [UIImage imageNamed:@"AppIcon60x60"];
    NSData * compressedAppIconData = UIImageJPEGRepresentation(appIcon, 0.5);
    
    NSString * weiboImageName = [NSString stringWithFormat:@"weibo_share_%d", arc4random()%4 + 1];
    NSString * weiboImagePath = [[NSBundle mainBundle] pathForResource:weiboImageName ofType:@"jpg"];
    NSData * weiboImageData = [NSData dataWithContentsOfFile:weiboImagePath];
    
    NSString * title = @"分享「东西 - 一个收集癖、集物控的交友社区」";
    
    DXShareView * shareView = [[DXShareView alloc] initWithType:DXShareViewTypeShareOnly fromController:self];
    DXWeChatShareInfo * wechatShareInfo = [[DXWeChatShareInfo alloc] init];
    wechatShareInfo.title = title;
    wechatShareInfo.desc = @"东西 - 收集一切生活趣味";
    wechatShareInfo.url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DXDongXiAppStoreURL"];
    wechatShareInfo.photoData = compressedAppIconData;
    shareView.weChatShareInfo = wechatShareInfo;
    
    DXWeiboShareInfo * weiboShareInfo = [[DXWeiboShareInfo alloc] init];
    weiboShareInfo.title = title;
    weiboShareInfo.url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DXDongXiAppStoreURL"];
    weiboShareInfo.photoData = weiboImageData;
    shareView.weiboShareInfo = weiboShareInfo;
    
    [shareView show];
}

#pragma mark - 评价

- (void)rateOurApp {
    NSString * appleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DXDongXiAppleID"];
    NSString * urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appleID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - 通知

- (void)checkAndUpdateNotificationSettings {
    self.notificationOn = [self isNotificationEnabledInAppSettings];
    self.notificationSoundOn = [self isNotificationSoundEnabledInAppSettings];
}

- (BOOL)isNotificationEnabledInAppSettings {
    UIApplication * app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings * settings = [app currentUserNotificationSettings];
        return settings.types != UIUserNotificationTypeNone;
    } else {
        UIRemoteNotificationType notiType = [app enabledRemoteNotificationTypes];
        return notiType != UIRemoteNotificationTypeNone;
    }
}

- (BOOL)isNotificationSoundEnabledInAppSettings {
    UIApplication * app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings * settings = [app currentUserNotificationSettings];
        return settings.types & UIUserNotificationTypeSound;
    } else {
        UIRemoteNotificationType notiType = [app enabledRemoteNotificationTypes];
        return notiType & UIRemoteNotificationTypeSound;
    }
}

- (IBAction)notificationSwitchChanged:(UISwitch *)sender {
    sender.on = !sender.on;
    [self openAppSettingCenter];
}

- (IBAction)notificationSoundSwitchChanged:(UISwitch *)sender {
    sender.on = !sender.on;
    [self openAppSettingCenter];
}

- (BOOL)openAppSettingCenter {
    if (&UIApplicationOpenSettingsURLString != NULL) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    } else {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@"请前往设置中心进行设置"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"好的" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert showInController:self animated:YES completion:nil];
        return NO;
    }
}

@end
