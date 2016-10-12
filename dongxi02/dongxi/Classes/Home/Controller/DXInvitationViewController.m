//
//  DXInvitationViewController.m
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "DXInvitationViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "DXInvitationPromptsCell.h"
#import "DXInvitationCodeCell.h"
#import "DXDongXiApi.h"
#import "DXShareInvitationCodeView.h"
#import "WXApiManager.h"
#import "DXArchiveService.h"

@interface DXInvitationViewController () <DXInvitationCodeCellDelegate, DXShareInvitationCodeViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, WXApiManagerDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
/** 当前选中的邀请码的序号 */
@property (nonatomic, assign) NSInteger currentCouponIndex;
/** 蒙板 */
@property (nonatomic, weak) UIView *coverV;
/** 分享视图 */
@property (nonatomic, weak) DXShareInvitationCodeView *shareInvitationCodeView;

@property (nonatomic, copy) NSString *currentUid;

@property (nonatomic, strong) DXArchiveService *archiveService;

@property (nonatomic, strong) DXUserCouponWrapper *couponWrapper;

@end

@implementation DXInvitationViewController {
    __weak DXInvitationViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    [WXApiManager sharedManager].delegate = self;
    self.tableView.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 设置导航栏
    [self setupNavBar];
    
    // 加载数据
    [self reloadData];
}

- (void)dealloc {
    [WXApiManager sharedManager].delegate = nil;
}

/**
 *  设置导航栏
 */
- (void)setupNavBar {
    
    self.title = @"邀请";
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
}

- (void)reloadData {
    
    [self.dataList removeAllObjects];
    DXUserCouponWrapper *couponWrapper = [self loadArchivedInvitationCode];
    
    [self.dataList addObjectsFromArray:couponWrapper.list];
    
    if (couponWrapper.availableCount) {
        [self.tableView reloadData];
    } else {
        [self loadNetData];
    }
}

- (void)loadNetData {
    
    [[DXDongXiApi api] getUserCouponList:^(DXUserCouponWrapper *couponWrapper, NSError *error) {
        if (couponWrapper.list.count) {
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, couponWrapper.list.count)];
            [weakSelf.dataList insertObjects:couponWrapper.list atIndexes:indexSet];
            
            weakSelf.couponWrapper.availableCount = couponWrapper.list.count;
            weakSelf.couponWrapper.list = weakSelf.dataList;
            
            [weakSelf.archiveService archiveObject:weakSelf.couponWrapper ForLoginUser:self.currentUid];
        }
        
        [weakSelf.tableView reloadData];
    }];
}

- (DXUserCouponWrapper *)loadArchivedInvitationCode {
    
    NSString *couponWrapperName = NSStringFromClass([DXUserCouponWrapper class]);
    DXUserCouponWrapper *couponWrapper = [self.archiveService unarchiveObject:couponWrapperName ForLoginUser:self.currentUid];
    return couponWrapper;
}

#pragma mark - 数据源代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else {
        return self.dataList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        DXInvitationPromptsCell *cell = [DXInvitationPromptsCell cellWithTableView:tableView];
        return cell;
    } else {
        DXInvitationCodeCell *cell = [DXInvitationCodeCell cellWithTableView:tableView];
        DXUserCoupon *coupon = self.dataList[indexPath.row];
        cell.coupon = coupon;
        cell.couponIndex = indexPath.row;
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return DXRealValue(221.0f / 3.0f);
    } else {
        return DXRealValue(350.0f / 3.0f);
    }
}

#pragma mark - DXInvitationCodeCellDelegate

- (void)invitationCodeCell:(DXInvitationCodeCell *)cell shareInvitationCodeWithCouponIndex:(NSInteger)couponIndex {
    
    self.currentCouponIndex = couponIndex;
    DXUserCoupon *coupon = self.dataList[couponIndex];
    [self showShareInvitationCodeViewWithCode:coupon.coupon_id];
}

#pragma mark - DXShareInvitationCodeViewDelegate

- (void)didClickCancellBtnInShareInvitationCodeView:(DXShareInvitationCodeView *)view {
    
    [self dismissShareInvitationCodeView];
}

- (void)didTapSmsBtnInShareInvitationCodeView:(DXShareInvitationCodeView *)view {
    
    DXUserCoupon *coupon = self.dataList[self.currentCouponIndex];
    [self sendSmsWithInvitationCode:coupon.coupon_id];
}

- (void)didTapEmailBtnInShareInvitationCodeView:(DXShareInvitationCodeView *)view {
    
    DXUserCoupon *coupon = self.dataList[self.currentCouponIndex];
    [self sendEmailWithInvitationCode:coupon.coupon_id];
}

- (void)shareInvitationCodeView:(DXShareInvitationCodeView *)view didTapWechatBtnWithSence:(int)sence {
    
    DXUserCoupon *coupon = self.dataList[self.currentCouponIndex];
    [self sendWechatWithInvitationCode:coupon.coupon_id scene:sence];
}

#pragma mark - 需要分享的内容

- (NSString *)shareBodyWithInvitationCode:(NSString *)code {
    
    NSString *nick = [[DXDongXiApi api] currentUserSession].nick;
    NSString * appStoreURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"DXDongXiAppStoreURL"];
    
    NSString *body = [NSString stringWithFormat:@"%@分享给你一个【东西】收集社区的邀请码：%@。欢迎打开观世界的门，来到东西！立即开启你的探索之旅 %@", nick, code, appStoreURL];

    return body;
}

#pragma mark - 通过短信发送验证码

- (void)sendSmsWithInvitationCode:(NSString *)code {
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        NSString *body = [self shareBodyWithInvitationCode:code];
        vc.body = body;
        vc.messageComposeDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self showNoticeWithMessage:@"您的设备不支持发短信，需要您配置短信"];
    }
}

#pragma mark - 通过邮件发送验证码

- (void)sendEmailWithInvitationCode:(NSString *)code {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        [vc setSubject:@"标题"];
        [vc setMessageBody:[self shareBodyWithInvitationCode:code] isHTML:NO];
        vc.mailComposeDelegate = self;
        if (vc) {
            [self presentViewController:vc animated:YES completion:nil];
        }
    } else {
        [self showNoticeWithMessage:@"您的设备不支持发邮件，需要您配置邮件"];
    }
}

#pragma mark - 通过微信发送验证码

- (void)sendWechatWithInvitationCode:(NSString *)code scene:(int)scene {
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = [self shareBodyWithInvitationCode:code];
    req.bText = YES;
    req.scene = scene;
    if (![WXApi sendReq:req]) {
        [self showNoticeWithMessage:@"分享失败，请重试"];
    };
}

#pragma mark - <MFMessageComposeViewControllerDelegate>

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultSent) {
        [self showSuccessNotice];
    }
}

#pragma mark - <MFMailComposeViewControllerDelegate>

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) {
        [self showSuccessNotice];
    }
}

#pragma mark - <WXApiManagerDelegate>

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    
    if (response.errCode == WXSuccess) {
        [self showSuccessNotice];
    }
}

#pragma mark - 显示提示信息

- (void)showNoticeWithMessage:(NSString *)message {
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    alert.title = @"提示";
    alert.message = message;
    DXCompatibleAlertAction *action = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        
    }];
    [alert addAction:action];
    [alert showInController:self animated:YES completion:nil];
}

- (void)showSuccessNotice {
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    alert.title = @"提示";
    alert.message = @"邀请码发送成功";
    DXCompatibleAlertAction *action = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        [weakSelf dismissShareInvitationCodeView];
        // 邀请码发送成功
        [weakSelf invitationCodeIsSendOut];
    }];
    [alert addAction:action];
    [alert showInController:self animated:YES completion:nil];
}

#pragma mark - 邀请码发送成功

- (void)invitationCodeIsSendOut {
    
    DXUserCoupon *coupon = self.dataList[self.currentCouponIndex];
    coupon.share = YES;
    [self.dataList removeObjectAtIndex:self.currentCouponIndex];
    [self.dataList addObject:coupon];
    
    self.couponWrapper.availableCount -= 1;
    self.couponWrapper.list = self.dataList;
    
    [self.archiveService archiveObject:self.couponWrapper ForLoginUser:self.currentUid];
    
    [[DXDongXiApi api] sendUserCouponWithCode:coupon.coupon_id result:^(BOOL success, NSError *error) {
        if (success) {
            DXLog(@"%@邀请码已经发送", coupon.coupon_id);
        }
    }];
    
    [self reloadData];
}

#pragma mark - 显示分享邀请码视图
- (void)showShareInvitationCodeViewWithCode:(NSString *)code {
    
    // 创建遮盖
    UIButton *coverV = [UIButton buttonWithType:UIButtonTypeCustom];
    coverV.backgroundColor = [UIColor blackColor];
    coverV.alpha = 0.0;
    [coverV addTarget:self action:@selector(dismissShareInvitationCodeView) forControlEvents:UIControlEventTouchUpInside];
    coverV.frame = [UIScreen mainScreen].bounds;
    [self.navigationController.view addSubview:coverV];
    self.coverV = coverV;
    
    // 创建分享页
    CGFloat shareViewW = DXScreenWidth;
    CGFloat shareViewH = DXRealValue(170);
    CGFloat shareViewY = DXScreenHeight;
    DXShareInvitationCodeView *shareInvitationCodeView = [[DXShareInvitationCodeView alloc] initWithFrame:CGRectMake(0, shareViewY, shareViewW, shareViewH)];
    shareInvitationCodeView.delegate = self;
    [self.navigationController.view addSubview:shareInvitationCodeView];
    self.shareInvitationCodeView = shareInvitationCodeView;
    
    [UIView animateWithDuration:0.2 animations:^{
        coverV.alpha = 0.2;
        shareInvitationCodeView.y = DXScreenHeight - shareInvitationCodeView.height;
    }];
}

#pragma mark - 退出分享邀请码视图
- (void)dismissShareInvitationCodeView {
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.shareInvitationCodeView.y = DXScreenHeight;
        weakSelf.coverV.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf.coverV removeFromSuperview];
        [weakSelf.shareInvitationCodeView removeFromSuperview];
    }];
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载

- (NSMutableArray *)dataList {
    
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSString *)currentUid {
    
    if (_currentUid == nil) {
        _currentUid = [[DXDongXiApi api] currentUserSession].uid;
    }
    return _currentUid;
}

- (DXArchiveService *)archiveService {
    
    if (_archiveService == nil) {
        _archiveService = [DXArchiveService sharedService];
    }
    return _archiveService;
}

- (DXUserCouponWrapper *)couponWrapper {
    
    if (_couponWrapper == nil) {
        _couponWrapper = [[DXUserCouponWrapper alloc] init];
    }
    return _couponWrapper;
}

@end
