//
//  DXShareView.m
//  dongxi
//
//  Created by 穆康 on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXShareView.h"
#import "DXButton.h"
#import <WeiboSDK.h>
#import <SDWebImageManager.h>
#import "DXDongXiApi.h"
#import "WXApiManager.h"
#import "WeiboManager.h"
#import "AppDelegate.h"
#import "DXLoginViewController.h"
#import <MBProgressHUD.h>

static NSString *const kRedirectURI = @"https://api.weibo.com/oauth2/default.html";
static NSInteger const defautTag = 10000;

@interface DXShareView () <WXApiManagerDelegate, WeiboManagerDelegate>

@property (nonatomic, assign) DXShareViewType type;

@property (nonatomic, weak) UIViewController *controller;

@property (nonatomic, weak) DXButton *collectionBtn;

@property (nonatomic, weak) UILabel *collectionL;

@property (nonatomic, weak) UIButton *coverV;
/** 分享到的场景 */
@property (nonatomic, copy) NSString *shareScene;

@end

@implementation DXShareView {
    __weak DXShareView *weakSelf;
}

- (instancetype)initWithType:(DXShareViewType)type fromController:(UIViewController *)controller {
    
    CGFloat shareViewX = 0.0f;
    CGFloat shareViewY = DXScreenHeight;
    CGFloat shareViewW = DXScreenWidth;
    CGFloat shareViewH = DXRealValue(170.0f);
    self = [super initWithFrame:CGRectMake(shareViewX, shareViewY, shareViewW, shareViewH)];
    
    if (self) {
        weakSelf = self;
        self.controller = controller;
        self.type = type;
        [WXApiManager sharedManager].delegate = self;
        [WeiboManager sharedManager].delegate = self;
        [self setupWithType:type];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [WXApiManager sharedManager].delegate = nil;
    [WeiboManager sharedManager].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithType:(DXShareViewType)type {
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat btnWH       = DXRealValue(50.0f);
    CGFloat btnY        = DXRealValue(26.0f);
    CGFloat btnMargin   = DXRealValue(34.0f);
    
    CGFloat leftPadding = 0.0f;
    if (type == DXShareViewTypeCollectionAndShare) {
        // 收藏
        DXButton *collectionBtn = [DXButton buttonWithType:UIButtonTypeCustom];
        [collectionBtn setImage:[UIImage imageNamed:@"button_uncollect"] forState:UIControlStateNormal];
        [collectionBtn setImage:[UIImage imageNamed:@"button_collect_normal"] forState:UIControlStateSelected];
        [collectionBtn addTarget:self action:@selector(collectionBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        collectionBtn.frame = CGRectMake(DXRealValue(56), btnY, btnWH, btnWH);
        [self addSubview:collectionBtn];
        self.collectionBtn = collectionBtn;
        
        UILabel *collectionL = [self setupLabelWithText:nil];
        collectionL.centerX = collectionBtn.centerX;
        [self addSubview:collectionL];
        self.collectionL = collectionL;
        
        leftPadding = CGRectGetMaxX(collectionBtn.frame) + btnMargin;
    } else {
        leftPadding = self.width * 0.5f - btnWH * 0.5f - btnMargin - btnWH;
    }
    
    // 微信好友
    UIButton *sessionBtn = [self setupButtonWithImageName:@"button_wechat_normal" highlightedImageName:@"button_wechat_click" disabledImageName:@"button_wechat_disabled"];
    sessionBtn.tag = defautTag;
    [sessionBtn addTarget:self action:@selector(weChatBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    sessionBtn.frame = CGRectMake(leftPadding, btnY, btnWH, btnWH);
    [self addSubview:sessionBtn];
    
    UILabel *sessionL = [self setupLabelWithText:@"微信好友"];
    sessionL.centerX = sessionBtn.centerX;
    [self addSubview:sessionL];
    
    // 朋友圈
    UIButton *timelineBtn = [self setupButtonWithImageName:@"button_friend_normal" highlightedImageName:@"button_friend_click" disabledImageName:@"button_friend_disabled"];
    timelineBtn.tag = defautTag + 1;
    [timelineBtn addTarget:self action:@selector(weChatBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    timelineBtn.frame = CGRectMake(CGRectGetMaxX(sessionBtn.frame) + btnMargin, btnY, btnWH, btnWH);
    [self addSubview:timelineBtn];
    
    UILabel *timelineL = [self setupLabelWithText:@"朋友圈"];
    timelineL.centerX = timelineBtn.centerX;
    [self addSubview:timelineL];
    
    // 微博
    UIButton *weiboBtn = [self setupButtonWithImageName:@"button_weibo_normal" highlightedImageName:@"button_weibo_click" disabledImageName:@"button_weibo_disabled"];
    [weiboBtn addTarget:self action:@selector(weiboBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    weiboBtn.frame = CGRectMake(CGRectGetMaxX(timelineBtn.frame) + btnMargin, btnY, btnWH, btnWH);
    [self addSubview:weiboBtn];
    
    UILabel *weiboL = [self setupLabelWithText:@"微博"];
    weiboL.centerX = weiboBtn.centerX;
    [self addSubview:weiboL];
    
    // 分割线
    UIView *dividerV = [[UIView alloc] init];
    dividerV.backgroundColor = DXRGBColor(208, 208, 208);
    dividerV.frame = CGRectMake(0, DXRealValue(120), DXScreenWidth, 0.5);
    [self addSubview:dividerV];
    
    // 取消按钮
    UIButton *cancellBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancellBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancellBtn setTitleColor:DXRGBColor(72, 72, 72) forState:UIControlStateNormal];
    cancellBtn.titleLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13)];
    [cancellBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    cancellBtn.frame = CGRectMake(0, DXRealValue(120), DXScreenWidth, DXRealValue(50));
    [self addSubview:cancellBtn];
    
    // 判断用户设备是否安装了微信和微博客户端
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        sessionBtn.enabled = NO;
        timelineBtn.enabled = NO;
        DXLog(@"没有安装微信客户端");
    }
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weibo://"]]) {
        weiboBtn.enabled = NO;
        DXLog(@"没有安装微博客户端");
    }
}

- (UIButton *)setupButtonWithImageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName disabledImageName:(NSString *)disabledImageName {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
    
    return btn;
}

- (UILabel *)setupLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = DXRGBColor(72, 72, 72);
    label.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(14)];
    label.size = CGSizeMake(DXRealValue(60), DXRealValue(16));
    label.y = DXRealValue(80);
    
    return label;
}

- (void)setFeed:(DXTimelineFeed *)feed {
    
    _feed = feed;
    
    if (self.type == DXShareViewTypeCollectionAndShare) {
        self.collectionBtn.selected = feed.data.is_save;
        self.collectionL.text = feed.data.is_save ? @"已收藏" : @"收藏";
    }
}

- (void)show {
    
    if (self.controller == nil) return;
    UIView *view;
    if (self.controller.tabBarController) {
        view = self.controller.tabBarController.view;
    } else {
        view = self.controller.view;
    }
    
    // 创建遮盖
    UIButton *coverV = [UIButton buttonWithType:UIButtonTypeCustom];
    coverV.backgroundColor = [UIColor blackColor];
    coverV.alpha = 0.0f;
    [coverV addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    coverV.frame = [UIScreen mainScreen].bounds;
    [view addSubview:coverV];
    self.coverV = coverV;
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.y = DXScreenHeight - self.height;
        coverV.alpha = 0.2f;
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.y = DXScreenHeight;
        weakSelf.coverV.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf.coverV removeFromSuperview];
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 点击按钮

/**
 *  点击收藏按钮
 */
- (void)collectionBtnDidClick:(DXButton *)btn {
    
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可收藏你感兴趣的内容，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf.controller presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:weakSelf.controller animated:YES completion:nil];
        return;
    }
    
    NSDictionary *userInfo = @{kFeedIDKey: self.feed.fid};
    typeof(btn) __weak weakBtn = btn;
    
    if (btn.selected) { // 取消收藏
        
        btn.selected = NO;
        self.collectionL.text = @"收藏";
        self.feed.data.is_save = NO;
        
        [[DXDongXiApi api] unsaveFeedWithFeedID:self.feed.fid result:^(BOOL success, NSError *error) {
            if (success) {
                DXLog(@"取消收藏成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:DXUncollectionFeedNotification object:nil userInfo:userInfo];
            } else {
                DXLog(@"取消收藏失败");
                weakBtn.selected = YES;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"取消收藏失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf.controller animated:YES completion:nil];
            }
        }];
        
    } else { // 收藏
        
        btn.selected = YES;
        self.collectionL.text = @"已收藏";
        self.feed.data.is_save = YES;
        
        [[DXDongXiApi api] saveFeedWithFeedID:self.feed.fid result:^(BOOL success, NSError *error) {
            if (success) {
                DXLog(@"收藏成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:DXCollectionFeedNotification object:nil userInfo:userInfo];
            } else {
                DXLog(@"收藏失败");
                weakBtn.selected = NO;
                
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"收藏失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf.controller animated:YES completion:nil];
            }
        }];
    }
    
    if (self.collectionBlock) {
        self.collectionBlock();
    }
}

/**
 *  点击分享微信好友或朋友圈按钮
 */
- (void)weChatBtnDidClick:(UIButton *)btn {
    
    int scene = (int)(btn.tag - defautTag);
    if (scene) {
        self.shareScene = @"朋友圈";
    } else {
        self.shareScene = @"微信好友";
    }
    
    if (self.weChatShareInfo.photoData) {
        [weakSelf sendMessageToWeChatWithImage:nil scene:scene];
    } else {
        NSURL *thumbUrl = [NSURL URLWithString:self.weChatShareInfo.photoUrl];
        [[SDWebImageManager sharedManager] downloadImageWithURL:thumbUrl options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            // 如果缩略图下载失败了也要允许发送
            [weakSelf sendMessageToWeChatWithImage:image scene:scene];
        }];
    }
}

- (void)sendMessageToWeChatWithImage:(UIImage *)image scene:(int)scene {
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = weakSelf.weChatShareInfo.url;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = weakSelf.weChatShareInfo.title;
    message.description = weakSelf.weChatShareInfo.desc;
    message.mediaObject = ext;
    if (image) {
        [message setThumbImage:image];
    } else {
        message.thumbData = self.weChatShareInfo.photoData;
    }
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = nil;
    req.message = message;
    req.bText = NO;
    req.scene = scene;
    if (![WXApi sendReq:req]) {
        [self showNoticeWithMessage:@"分享失败，请重试"];
    };
}

/**
 *  点击分享到微博按钮
 */
- (void)weiboBtnDidClick {
    
    self.shareScene = @"微博";
    if (self.weiboShareInfo.photoData) {
        [self sendMessageToWeiboWithImageData:self.weiboShareInfo.photoData];
    } else {
        NSURL *url = [NSURL URLWithString:self.weiboShareInfo.photoUrl];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            NSData * photoData = image ? UIImageJPEGRepresentation(image, 0.8) : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf sendMessageToWeiboWithImageData:photoData];
            });
        }];
    }
}


/**
 *  分享到微博
 */
- (void)sendMessageToWeiboWithImageData:(NSData *)imageData {
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";

    WBMessageObject *message = [WBMessageObject message];
    message.text = self.weiboShareInfo.shareText;
    
    WBImageObject *imageObj = [WBImageObject object];
    imageObj.imageData = imageData;
    
    message.imageObject = imageObj;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    
    if (![WeiboSDK sendRequest:request]) {
        [self showNoticeWithMessage:@"分享失败，请重试"];
    }
}


#pragma mark - Notifications

- (void)onUserDidLoginNotification:(NSNotification *)noti {
    [self refreshCollectionStatus:nil];
}

#pragma mark - <WXApiManagerDelegate>

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    
    if (response.errCode == WXSuccess) {
        [[DXDongXiApi api] postFeedIsSharedWithFeedID:self.feed.fid toScene:self.shareScene result:nil];
    }
    
    [self dismissAndShowHudWithSuccess:response.errCode == WXSuccess];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewDidReceiveWechatResponseStatus:)]) {
        if (response.errCode == WXSuccess) {
            [self.delegate shareViewDidReceiveWechatResponseStatus:YES];
        } else {
            [self.delegate shareViewDidReceiveWechatResponseStatus:NO];
        }
    }
}

#pragma mark - <WeiboManagerDelegate>

- (void)managerDidReceiveWeiboResponse:(WBBaseResponse *)response {
    
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        
        [[DXDongXiApi api] postFeedIsSharedWithFeedID:self.feed.fid toScene:self.shareScene result:nil];
    }
    
    [self dismissAndShowHudWithSuccess:response.statusCode == WeiboSDKResponseStatusCodeSuccess];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewDidReceiveWeiboResponseStatus:)]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [self.delegate shareViewDidReceiveWeiboResponseStatus:YES];
        } else {
            [self.delegate shareViewDidReceiveWeiboResponseStatus:NO];
        }
    }
}

#pragma mark - 分享后dismiss并给出提示信息

- (void)dismissAndShowHudWithSuccess:(BOOL)success {
    
    if (success) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.controller.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"分享成功";
        [hud hide:YES afterDelay:3];
    }
    [self dismiss];
}

#pragma mark - 显示提示信息

- (void)showNoticeWithMessage:(NSString *)message {
    
    DXCompatibleAlert *alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
    alert.title = @"提示";
    alert.message = message;
    DXCompatibleAlertAction *action = [DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        
    }];
    [alert addAction:action];
    [alert showInController:self.controller animated:YES completion:nil];
}

#pragma mark - 刷新收藏信息

- (void)refreshCollectionStatus:(void(^)(BOOL))completion {
    [[DXDongXiApi api] getFeedWithID:self.feed.fid result:^(DXTimelineFeed *feed, NSError *error) {
        if (feed) {
            weakSelf.collectionBtn.selected = feed.data.is_save;
        }
        if (completion) {
            completion(feed ? feed.data.is_save : NO);
        }
    }];
}

@end
