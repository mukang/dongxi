//
//  DXProfileViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileViewController.h"
#import "DXAnonymousProfileViewController.h"
#import "UIImage+Extension.h"
#import "DXTabBarView.h"
#import "DXProfileContentViewController.h"
#import "DXDongXiApi.h"
#import "DXSettingViewController.h"
#import "DXProfileCoverUpdateViewController.h"
#import "DXProfileUpdateViewController.h"
#import "DXFansViewController.h"
#import "DXFollowViewController.h"
#import "DXLoginViewController.h"
#import <UIImageView+WebCache.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DXPhotoTakerController.h"
#import "DXProfileHeaderView.h"
#import "DXCacheFileManager.h"
#import "DXUserInfoManager.h"
#import "DXNavigationTitleView.h"
#import "DXChatViewController.h"

#define kProfileCoverImageHeight    DXRealValue(272)     // 背景图片的原始高度
#define kProfileCoverImageMinHeight 64                   // 背景图片的最小高度
#define kProfileTabBarHeight        DXRealValue(44)      // 标签栏的高度
#define kProfileHeadViewSideMargin  DXRealValue(44)


typedef enum : NSUInteger {
    DXProfileStateMyProfile = 0,
    DXProfileStateOthersProfile,
    DXProfileStateMyProfileWithoutTabBar,
} DXProfileState;


@interface DXProfileViewController () <DXTabBarViewDelegate,UIGestureRecognizerDelegate,DXPhotoTakerControllerDelegate,UINavigationControllerDelegate, DXProfileContentViewControllerDelegate>

/** 导航栏标题视图 */
@property (nonatomic, strong) DXNavigationTitleView *titleView;
/** 头部选择视图 */
@property (nonatomic, weak) DXProfileHeaderView * headerView;
/** 头像 */
@property (nonatomic, weak) UIImageView *avatarView;

/** 更换封面的底部选择视图 */
@property (nonatomic ,weak) UIView * coverImageOptionView;
/** 更换头像的底部选择视图 */
@property (nonatomic ,weak) UIView * avatarImageOptionView;
/** 背景图片 */
@property (nonatomic, weak) UIImageView * coverImageView;
/** 背景图片灰色蒙板 */
@property (nonatomic, weak) UIImageView * filterImageView;
/** 标签栏 */
@property (nonatomic, weak) DXTabBarView * switchTabBarView;
/** 设置按钮 */
@property (nonatomic, weak) UIButton * settingButton;

/** 子视图控制器：我参与的 */
@property (nonatomic, strong) DXProfileContentViewController *publishedFeedsViewController;
/** 子视图控制器：我收藏的 */
@property (nonatomic, strong) DXProfileContentViewController *savedFeedsViewController;
/** 当前的子视图控制器 */
@property (nonatomic, weak) DXProfileContentViewController * currentFeedsViewController;

@property (nonatomic, strong) DXAnonymousProfileViewController * anonymousProfileViewController;

/** 视图是否展开 */
@property(nonatomic,assign) BOOL isCoverOpen;
/** 头像视图是否展开 */
@property(nonatomic,assign) BOOL isAvatarOpen;


@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, strong) DXUserProfile *userProfile;
@property (nonatomic, assign) DXProfileState profileState;
@property (nonatomic, strong) UIBarButtonItem * settingButtonItem;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIBarButtonItem * activityBarItem;
@property (nonatomic, strong) UITapGestureRecognizer * avatarTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer * coverTapGesture;
@property (nonatomic, assign) BOOL needsLightContentStatusBar;
@property (nonatomic, assign) BOOL needsReupdateStatusBar;
@property (nonatomic, assign) BOOL bigAvatarLoading;
@property (nonatomic, assign) BOOL bigAvatarLoaded;
@property (nonatomic, assign) BOOL pageLoaded;
@property (nonatomic, assign) BOOL pageLoading;
@property (nonatomic, assign) BOOL showAnonymousController;

/** 是否刷新完毕 */
@property (nonatomic, assign, getter=isRefreshCompletion) BOOL refreshCompletion;

@end

@implementation DXProfileViewController


#pragma mark - 生命周期方法

- (instancetype)initWithControllerType:(DXProfileViewControllerType)controllerType {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _controllerType = controllerType;
        if (controllerType == DXProfileViewControllerLoginUser) {
            self.uid = [DXDongXiApi api].currentUserSession.uid;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUserDidLogoutNotification:) name:DXDongXiApiNotificationUserDidLogout object:nil];
    }
    return self;
}

- (UIViewController *)initWithRouteParams:(NSDictionary *)params {
    self = [[[self class] alloc] initWithControllerType:DXProfileViewControllerUserUID];
    if (self) {
        self.uid = [params objectForKey:@"uid"];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"请使用-[DXProfileViewController initWithControllerType:]来初始化");
    return nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSAssert(NO, @"请使用-[DXProfileViewController initWithControllerType:]来初始化");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 下拉刷新指示器
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
    
    [self setupNavBar];
    [self setupNavigationPopItem];
    [self setupSubviews];
    
    [self checkAndUpdateProfileState];
    [self setupChildVC];
    
    if (self.controllerType == DXProfileViewControllerLoginUser && [[DXDongXiApi api] needLogin]) {
        [self setShowAnonymousController:YES];
    } else {
        //网络请求
        [self loadPageIfNeeded];
    }
    
    //注册监听者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveProfileDidUpdateNotification:) name:DXProfileDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveProfileCoverDidUpdateNotification:) name:DXProfileCoverDidUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /* 使用其他方法更新
    if (self.controllerType == DXProfileViewControllerLoginUser && ![[DXDongXiApi api] needLogin]) {
        DXUserSession *session = [[DXDongXiApi api] currentUserSession];
        self.titleView.title = session.nick;
        self.titleView.gender = session.gender;
        self.navigationItem.titleView = self.titleView;
    }
     */

    if (![self.api needLogin]) {
        [self loadPageIfNeeded];
    }
    
    [self updateNavigationBarAlpha];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (self.needsReupdateStatusBar) {
        [self updateNavigationBarAlpha];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.currentFeedsViewController.tableView setContentOffset:self.currentFeedsViewController.tableView.contentOffset animated:NO];
    
    //判断是否有Controller以modal形式展现导致当前视图消失
    NSArray * childViewControllers = self.navigationController.childViewControllers;
    if ([childViewControllers lastObject] != self) {
        [self restoreNavBarAppearance];
    } else {
        self.needsReupdateStatusBar = YES;
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.userProfile) {
        [self.userProfile removeObserver:self forKeyPath:@"fans"];
        [self.userProfile removeObserver:self forKeyPath:@"follows"];
        [self.userProfile removeObserver:self forKeyPath:@"relations"];
    }
}


#pragma mark - 初始化

- (void)setupNavBar {
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    
    DXNavigationTitleView *titleView = [[DXNavigationTitleView alloc] init];
    self.titleView = titleView;
}

- (void)setupNavigationPopItem {
    if (self.navigationController.childViewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    }
}

- (void)setupSubviews{
    CGFloat screenWidth = DXScreenWidth;
    CGFloat screenHeight = DXScreenHeight;
    
    // 背景图片
    UIImageView *coverImageView = [[UIImageView alloc] init];
    coverImageView.userInteractionEnabled = YES;
    coverImageView.frame = CGRectMake(0, 0, DXScreenWidth, kProfileCoverImageHeight);
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    coverImageView.layer.masksToBounds = YES;
    coverImageView.backgroundColor = DXRGBColor(177, 177, 177);
    coverImageView.userInteractionEnabled = YES;
    [self.view addSubview:coverImageView];
    self.coverImageView = coverImageView;
    
    // 添加头部视图
    CGRect headerViewFrame = CGRectMake(0, 0, screenWidth, kProfileCoverImageHeight + kProfileTabBarHeight);
    DXProfileHeaderView *headerView = [[DXProfileHeaderView alloc] initWithFrame:headerViewFrame];
    headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headerView];
    
    // 头像点击事件
    _avatarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTapGesture:)];
    [headerView.avatarView addGestureRecognizer:_avatarTapGesture];
    
    // 私聊、关注按钮事件
    [headerView.chatButton addTarget:self action:@selector(chatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView.followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 关注数量标签事件
    UITapGestureRecognizer * followLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFollowsLabelTapGesture:)];
    [headerView.followLabel addGestureRecognizer:followLabelTapGesture];
    
    // 粉丝数量标签事件
    UITapGestureRecognizer * fansLabelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFansLabelTapGesture:)];
    [headerView.fansLabel addGestureRecognizer:fansLabelTapGesture];
    
    // 切换标签栏代理
    headerView.switchTabBarView.delegate = self;
    
    self.headerView = headerView;
    self.avatarView = headerView.avatarView;
    self.switchTabBarView = headerView.switchTabBarView;
    
    //头部背景图点击
    _coverTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCoverTapGesture:)];
    _coverTapGesture.numberOfTouchesRequired = 1;
    _coverTapGesture.numberOfTapsRequired = 1;
    _coverTapGesture.delegate = self;
    [self.coverImageView addGestureRecognizer:_coverTapGesture];
    
    //背景图滤镜
    UIImageView *filterImageView = [[UIImageView alloc]init];
    filterImageView.frame = self.coverImageView.frame;
    filterImageView.hidden = YES;
    [filterImageView setImage:[UIImage imageNamed:@"Personal_bg_shadow"]];
    [self.coverImageView addSubview:filterImageView];
    self.filterImageView = filterImageView;
    
    //底部选择视图
    UIView *coverImageOptionView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight - DXRealValue(414))];
    coverImageOptionView.backgroundColor = [UIColor whiteColor];
    
    //创建更换背景图Btn
    UIButton *coverChangeBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth - DXRealValue(307))/2, DXRealValue(60), DXRealValue(307), DXRealValue(45))];
    [coverChangeBtn setBackgroundImage:[UIImage imageNamed:@"button_personal_bg1"] forState:UIControlStateNormal];
    [coverChangeBtn setTitle:@"更换封面图" forState:UIControlStateNormal];
    [coverChangeBtn.titleLabel setFont:[UIFont fontWithName:DXCommonFontName size:DXRealValue(18)]];
    [coverChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [coverChangeBtn addTarget:self action:@selector(coverChangeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //创建取消Btn
    UIButton *coverChangeCancelBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth - DXRealValue(307))/2, DXRealValue(130), DXRealValue(307), DXRealValue(45))];
    [coverChangeCancelBtn setBackgroundImage:[UIImage imageNamed:@"button_personal_bg2"] forState:UIControlStateNormal];
    [coverChangeCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [coverChangeCancelBtn.titleLabel setFont:[UIFont fontWithName:DXCommonFontName size:DXRealValue(18)]];
    [coverChangeCancelBtn setTitleColor:DXRGBColor(120, 201, 255) forState:UIControlStateNormal];
    [coverChangeCancelBtn addTarget:self action:@selector(coverChangeCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:coverImageOptionView];
    [coverImageOptionView addSubview:coverChangeBtn];
    [coverImageOptionView addSubview:coverChangeCancelBtn];
    self.coverImageOptionView = coverImageOptionView;

    //更换头像的底部选择视图
    UIView *avatarImageOptionView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight - DXRealValue(414))];
    avatarImageOptionView.backgroundColor = [UIColor whiteColor];
    
    //创建更换头像Btn
    UIButton *avatarChangeBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth - DXRealValue(307))/2, DXRealValue(60), DXRealValue(307), DXRealValue(45))];
    [avatarChangeBtn setBackgroundImage:[UIImage imageNamed:@"button_personal_bg1"] forState:UIControlStateNormal];
    [avatarChangeBtn setTitle:@"更换头像" forState:UIControlStateNormal];
    [avatarChangeBtn.titleLabel setFont:[UIFont fontWithName:DXCommonFontName size:DXRealValue(18)]];
    [avatarChangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [avatarChangeBtn addTarget:self action:@selector(avatarChangeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [avatarImageOptionView addSubview:avatarChangeBtn];
    
    //创建取消Btn
    UIButton *avatarChangeCancelBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth - DXRealValue(307))/2, DXRealValue(130), DXRealValue(307), DXRealValue(45))];
    [avatarChangeCancelBtn setBackgroundImage:[UIImage imageNamed:@"button_personal_bg2"] forState:UIControlStateNormal];
    [avatarChangeCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [avatarChangeCancelBtn.titleLabel setFont:[UIFont fontWithName:DXCommonFontName size:DXRealValue(18)]];
    [avatarChangeCancelBtn setTitleColor:DXRGBColor(120, 201, 255) forState:UIControlStateNormal];
    [avatarChangeCancelBtn addTarget:self action:@selector(avatarCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [avatarImageOptionView addSubview:avatarChangeCancelBtn];
    [self.view addSubview:avatarImageOptionView];
    self.avatarImageOptionView = avatarImageOptionView;
}

#pragma mark - 状态栏

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    /**
     * iOS8下设备横向模式会默认隐藏状态栏，但测试时发现
     * 在某些时候竖向模式也会出现状态栏被隐藏的问题
     */
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.needsLightContentStatusBar ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setNeedsLightContentStatusBar:(BOOL)needsLightContentStatusBar {
    BOOL statusBarNeedsUpdate = (needsLightContentStatusBar != _needsLightContentStatusBar);
    _needsLightContentStatusBar = needsLightContentStatusBar;
    
    if (statusBarNeedsUpdate) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - 属性

- (DXDongXiApi *)api {
    if (nil == _api) {
        _api = [DXDongXiApi api];
    }
    return _api;
}

- (DXAnonymousProfileViewController *)anonymousProfileViewController {
    if (nil == _anonymousProfileViewController) {
        _anonymousProfileViewController = [[DXAnonymousProfileViewController alloc] init];
    }
    return _anonymousProfileViewController;
}

- (BOOL)visitingOthersProfile {
    if (self.uid != nil && ![self.uid isEqualToString:self.api.currentUserSession.uid]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasPreviousController {
    return self.navigationController.childViewControllers.count > 1;
}

- (void)checkAndUpdateProfileState {
    self.switchTabBarView.hidden = NO;
    self.filterImageView.hidden = NO;
    
    if ([self visitingOthersProfile]) {
        [self.switchTabBarView setName:@"Ta参与的" atTabIndex:0];
        [self.switchTabBarView setName:@"Ta收藏的" atTabIndex:1];
        self.profileState = DXProfileStateOthersProfile;
    } else {
        if ([self hasPreviousController]) {
            self.profileState = DXProfileStateMyProfileWithoutTabBar;
        } else {
            self.profileState = DXProfileStateMyProfile;
        }
    }
}

- (void)setProfileState:(DXProfileState)profileState {
    _profileState = profileState;
    
    switch (profileState) {
        case DXProfileStateMyProfileWithoutTabBar:
        case DXProfileStateMyProfile:
            self.settingButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Personal_set"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(settingButtonTapped:)];
            self.navigationItem.rightBarButtonItem = self.settingButtonItem;
            self.avatarTapGesture.enabled = YES;
            self.coverTapGesture.enabled = YES;
            break;
        case DXProfileStateOthersProfile: {
            self.settingButtonItem = nil;
            self.avatarTapGesture.enabled = NO;
            self.coverTapGesture.enabled = NO;
        }
            break;
        
        default:
            break;
    }
}

- (void)setUserProfile:(DXUserProfile *)userProfile {
    if (_userProfile) {
        [_userProfile removeObserver:self forKeyPath:@"fans"];
        [_userProfile removeObserver:self forKeyPath:@"follows"];
        [_userProfile removeObserver:self forKeyPath:@"relations"];
    }
    
    _userProfile = userProfile;
    
    [_userProfile addObserver:self forKeyPath:@"fans" options:NSKeyValueObservingOptionNew context:nil];
    [_userProfile addObserver:self forKeyPath:@"follows" options:NSKeyValueObservingOptionNew context:nil];
    [_userProfile addObserver:self forKeyPath:@"relations" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark 更新资料数据

- (void)fetchProfileData {
    [self fetchProfileDataWithCompletion:nil];;
}

- (void)fetchProfileDataWithCompletion:(void(^)(BOOL))completion {
    __weak DXProfileViewController * weakSelf = self;
    
    if (self.controllerType == DXProfileViewControllerLoginUser || self.controllerType == DXProfileViewControllerUserUID) {
        NSString * uid = nil;
        if (self.controllerType == DXProfileViewControllerLoginUser) {
            uid = [DXDongXiApi api].currentUserSession.uid;
        } else {
            uid = self.uid;
        }
        
        self.publishedFeedsViewController.uid = uid;
        self.savedFeedsViewController.uid = uid;

        [self.api getProfileOfUser:uid result:^(DXUserProfile *profile, NSError *error) {
            if (profile) {
                [weakSelf updateProfileViewControllerWithProfile:profile];
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                [DXUserInfoManager getNewestAvatarWithCurrentAvatar:profile.avatar updateTime:now forUID:uid];
                [DXUserInfoManager getNewestNicknameWithCurrentNickname:profile.username updateTime:now forUID:uid];
            } else {
                [weakSelf updateProfileViewControllerWithProfile:nil];
                
                if (weakSelf.controllerType != DXProfileViewControllerLoginUser) {
                    NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后重试";
                    NSString * message = [NSString stringWithFormat:@"无法获取数据，%@", reason];
                    DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                    [alert setMessage:message];
                    [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }]];
                    [alert showInController:weakSelf animated:YES completion:nil];
                }
            }
            
            if (completion) {
                completion(profile != nil);
            }
        }];
    } else {
        [self.api getProfileOfUserByNick:self.nick result:^(DXUserProfile *profile, NSError *error) {
            if (profile) {
                weakSelf.publishedFeedsViewController.uid = profile.uid;
                weakSelf.savedFeedsViewController.uid = profile.uid;
                [weakSelf updateProfileViewControllerWithProfile:profile];
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                [DXUserInfoManager getNewestAvatarWithCurrentAvatar:profile.avatar updateTime:now forUID:profile.uid];
                [DXUserInfoManager getNewestNicknameWithCurrentNickname:profile.username updateTime:now forUID:profile.uid];
            } else {
                if (error) {
                    DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                    NSString * noticeTitle = @"未能获取昵称所对应的用户信息";
                    if (error.localizedDescription) {
                        noticeTitle = error.localizedDescription;
                    }
                    [alert setTitle:noticeTitle];
                    [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleCancel handler:^(DXCompatibleAlertAction *action) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }]];
                    [alert showInController:weakSelf animated:YES completion:nil];
                }
            }
            
            if (completion) {
                completion(profile != nil);
            }
        }];
    }
}

- (void)loadPageIfNeeded {
    if (self.pageLoaded == NO && self.pageLoading == NO) {
        self.pageLoading = YES;
        __weak DXProfileViewController * weakSelf = self;
        [self fetchProfileDataWithCompletion:^(BOOL success) {
            if (success) {
                weakSelf.pageLoaded = YES;
            }
            weakSelf.pageLoading = NO;
        }];
    }
}

- (void)updateProfileViewControllerWithProfile:(DXUserProfile *)profile {
    self.userProfile = profile;
    self.uid = profile.uid;
    self.headerView.profile = profile;
    self.bigAvatarLoaded = NO;
    
    self.titleView.title = profile.username;
    self.titleView.gender = profile.gender;
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = self.titleView;
    
    NSURL *coverURL = [NSURL URLWithString:profile.cover];
    UIImage * currentCover = self.coverImageView.image;
    if (currentCover) {
        [self.coverImageView sd_setImageWithURL:coverURL placeholderImage:currentCover options:SDWebImageRetryFailed];
    } else {
        [self.coverImageView sd_setImageWithURL:coverURL placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    [self checkAndUpdateProfileState];
}



- (void)loadBigAvatarIfNeeded {
    if (!self.bigAvatarLoaded && !self.bigAvatarLoading) {
        self.bigAvatarLoading = YES;
        __weak DXProfileViewController * weakSelf = self;
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:self.userProfile.big_avatar] placeholderImage:self.avatarView.image  options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            weakSelf.bigAvatarLoading = NO;
            if (image) {
                weakSelf.bigAvatarLoaded = YES;
            }
        }];
        /** 如果两秒后仍然在加载，则允许重新加载 */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.bigAvatarLoading) {
                weakSelf.bigAvatarLoading = NO;
            }
        });
    }
}

- (void)submitNewAvatar:(UIImage *)avatar {
    if (avatar) {
        typeof(_avatarView) __weak weakAvatarView = _avatarView;
        
        DXScreenNotice * screenNotice = [[DXScreenNotice alloc] initWithMessage:@"正在上传头像.." fromController:self];
        screenNotice.disableAutoDismissed = YES;
        [screenNotice show];
        
        __weak DXProfileViewController * weakSelf = self;
        NSData * data = UIImageJPEGRepresentation(avatar, 0.6);
        
        DXCacheFileManager * fileManager = [DXCacheFileManager sharedManager];
        DXCacheFile * avatarFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeImageCache];
        avatarFile.extension = @"jpg";
        avatarFile.deleteWhenAppLaunch = YES;
        NSError * tempFileSaveError = nil;
        if ([fileManager saveData:data toFile:avatarFile error:&tempFileSaveError]) {
            [self.api changeAvatar:avatarFile.url result:^(BOOL success, NSString *url, NSError *error) {
                if (success) {
                    weakAvatarView.image = avatar;
                    weakSelf.bigAvatarLoaded = NO;
                    [screenNotice updateMessage:@"头像更新成功"];
                    [screenNotice dismiss:YES completion:^{
                        [weakSelf fetchProfileData];
                    }];
                } else{
                    [screenNotice updateMessage:@"头像上传失败"];
                    [screenNotice dismiss:YES completion:nil];
                }
            }];
        } else {
            [screenNotice updateMessage:@"头像保存失败"];
            [screenNotice dismiss:YES completion:nil];
        }
    }
}


#pragma mark - 设置导航栏

- (void)restoreNavBarAppearance {
    [self updateNavBarWithAlpha:1];
}

- (void)updateNavigationBarAlpha {
    if ([self.navigationController.childViewControllers lastObject] == self) {
        CGFloat alpha = (kProfileCoverImageHeight - self.coverImageView.height) / (kProfileCoverImageHeight - kProfileCoverImageMinHeight);
        alpha = roundf(alpha * 100) / 100;
        [self updateNavBarWithAlpha:alpha];
    }
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    UIColor * tintColor = nil;
    
    if (alpha < 1) {
        [self.navigationController.navigationBar setTranslucent:YES];
    } else {
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    if (alpha > 0.7 || self.showAnonymousController) {
        tintColor = DXCommonColor;
        self.needsLightContentStatusBar = NO;
    } else {
        tintColor = [UIColor whiteColor];
        self.needsLightContentStatusBar = YES;
    }
        
    [self.navigationController.navigationBar setTintColor:tintColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                      NSForegroundColorAttributeName : tintColor
                                                                      }];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DXARGBColor(247, 250, 251, alpha)] forBarMetrics:UIBarMetricsDefault];
    
    self.titleView.titleColor = tintColor;
}

#pragma mark - 调整头部视图位置

- (void)updateHeaderFrame {
    const CGFloat originOffsetY = - (kProfileCoverImageHeight + kProfileTabBarHeight);
    CGFloat offsetY = self.currentFeedsViewController.tableView.contentOffset.y;
    CGFloat delta = offsetY - originOffsetY;
    
    CGFloat headH = kProfileCoverImageHeight - delta;
    if (headH < kProfileCoverImageMinHeight) {
        headH = kProfileCoverImageMinHeight;
    }

    self.coverImageView.height = headH;
    self.filterImageView.height = headH;
    self.headerView.y = headH - kProfileCoverImageHeight;
}

- (void)resetViews {
    CGPoint contentOffset = CGPointMake(0, -(kProfileCoverImageHeight + kProfileTabBarHeight));
    [self.currentFeedsViewController.tableView setContentOffset:contentOffset animated:NO];;
}

- (CGFloat)bottomTabBarHeight {
    CGFloat bottomTabBarHeight = (self.tabBarController.tabBar.hidden || self.hidesBottomBarWhenPushed) ? 0 : self.tabBarController.tabBar.height;
    return bottomTabBarHeight;
}

#pragma mark - 子控制器

- (void)setupChildVC {
    [self switchToChildViewController:0];
}

- (void)switchToChildViewController:(NSUInteger)index {
    if (index == 0) {
        // 我参与的
        BOOL firstTimeSetup = NO;
        if (!self.publishedFeedsViewController) {
            self.publishedFeedsViewController = [[DXProfileContentViewController alloc] init];
            self.publishedFeedsViewController.type = DXProfileContentVCTypeJoin;
            self.publishedFeedsViewController.uid = self.uid;
            self.publishedFeedsViewController.delegate = self;

            firstTimeSetup = YES;
        }
        
        if ([self.savedFeedsViewController parentViewController]) {
            [self.savedFeedsViewController willMoveToParentViewController:nil];
            [self.savedFeedsViewController.view removeFromSuperview];
            [self.savedFeedsViewController removeFromParentViewController];
        }
        
        self.currentFeedsViewController = self.publishedFeedsViewController;
        
        [self addChildViewController:self.publishedFeedsViewController];
        [self.publishedFeedsViewController didMoveToParentViewController:self];
        if (firstTimeSetup) {
            self.publishedFeedsViewController.view.frame = [UIScreen mainScreen].bounds;
            UIEdgeInsets defaultInsets = UIEdgeInsetsMake(kProfileCoverImageHeight + kProfileTabBarHeight, 0, [self bottomTabBarHeight], 0);
            self.publishedFeedsViewController.contentInset = defaultInsets;
        }
        [self.view insertSubview:self.publishedFeedsViewController.view belowSubview:self.coverImageView];
    } else {
        // 我收藏的
        BOOL firstTimeSetup = NO;
        if (!self.savedFeedsViewController) {
            self.savedFeedsViewController = [[DXProfileContentViewController alloc] init];
            self.savedFeedsViewController.type = DXProfileContentVCTypeCollect;
            self.savedFeedsViewController.uid = self.uid;
            self.savedFeedsViewController.delegate = self;
            
            firstTimeSetup = YES;
        }
        
        if ([self.publishedFeedsViewController parentViewController]) {
            [self.publishedFeedsViewController willMoveToParentViewController:nil];
            [self.publishedFeedsViewController.view removeFromSuperview];
            [self.publishedFeedsViewController removeFromParentViewController];
        }
        
        self.currentFeedsViewController = self.savedFeedsViewController;
        
        [self addChildViewController:self.savedFeedsViewController];
        [self.savedFeedsViewController didMoveToParentViewController:self];
        if (firstTimeSetup) {
            self.savedFeedsViewController.view.frame = [UIScreen mainScreen].bounds;
            UIEdgeInsets defaultInsets = UIEdgeInsetsMake(kProfileCoverImageHeight + kProfileTabBarHeight, 0, [self bottomTabBarHeight], 0);
            self.savedFeedsViewController.contentInset = defaultInsets;
        }

        [self.view insertSubview:self.savedFeedsViewController.view belowSubview:self.coverImageView];
    }
    
    
    [self updateCurrentScrollViewContentOffset];
}

- (void)updateCurrentScrollViewContentOffset {
    UITableView * tableView = self.currentFeedsViewController.tableView;

    CGFloat offsetY = 0;
    CGFloat topHeight = CGRectGetHeight(self.coverImageView.bounds) + kProfileTabBarHeight;
    CGFloat minTopHeight = kProfileCoverImageMinHeight + kProfileTabBarHeight;
    if ((topHeight - minTopHeight) > 0.5) {
        offsetY = -topHeight;
    } else {
        CGFloat headeViewBottomY = CGRectGetHeight(self.headerView.frame) + CGRectGetMinY(self.headerView.frame);
        offsetY = MAX(-headeViewBottomY, tableView.contentOffset.y);
    }
    
    CGPoint  contentOffset = CGPointMake(0, offsetY);
    [tableView setContentOffset:contentOffset];
}

- (void)scrollContentToTop {
    const CGFloat originOffsetY = - (kProfileCoverImageHeight + kProfileTabBarHeight);
    [self.currentFeedsViewController.tableView setContentOffset:CGPointMake(0, originOffsetY) animated:NO];
}

#pragma mark - 更新下拉指示器的状态

- (void)showActivityViewWithProgress:(CGFloat)progress clockwise:(BOOL)clockwise{
    if (self.navigationItem.rightBarButtonItem != self.activityBarItem) {
        self.activityView.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.activityBarItem;
    }
//    CGFloat angle = M_PI * 2 * progress;
}

- (void)restoreRightNavigationItem {
    if (self.navigationItem.rightBarButtonItem != self.settingButtonItem) {
        self.navigationItem.rightBarButtonItem = self.settingButtonItem;
        self.activityView.hidden = YES;
        [self.activityView stopAnimating];
    }
}

- (void)showActivityView {
    self.navigationItem.rightBarButtonItem = self.activityBarItem;
    [self.activityView startAnimating];
}

- (void)hideActivityView {
    if (self.isRefreshCompletion && self.currentFeedsViewController.isRefreshCompletion) {
        [self.activityView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.settingButtonItem;
    }
}

#pragma mark - <DXTabBarViewDelegate>
- (void)tabBarView:(DXTabBarView *)view didTapButtonAtIndex:(NSUInteger)index {
    [self switchToChildViewController:index];
}

#pragma mark - <DXProfileContentViewControllerDelegate>

- (void)contentController:(DXProfileContentViewController *)contentController didScroll:(UIScrollView *)scrollView {
    [self updateHeaderFrame];
    [self updateNavigationBarAlpha];
    
    if (!self.activityView.isAnimating) {
        const CGFloat originOffsetY = - (kProfileCoverImageHeight + kProfileTabBarHeight);
        CGFloat offsetY = self.currentFeedsViewController.tableView.contentOffset.y;
        CGFloat delta = originOffsetY - offsetY;
        if (delta > 5) {
            [self showActivityViewWithProgress:(delta-5)/45.0 clockwise:!scrollView.decelerating];
        } else {
            [self restoreRightNavigationItem];
        }
    }
}

- (void)contentController:(DXProfileContentViewController *)contentController DidEndDragging:(UIScrollView *)scrollView {
    
    const CGFloat originOffsetY = - (kProfileCoverImageHeight + kProfileTabBarHeight);
    CGFloat offsetY = self.currentFeedsViewController.tableView.contentOffset.y;
    CGFloat delta = offsetY - originOffsetY;
    if (delta < -50.0f && !self.activityView.isAnimating) {
        [self showActivityView];
        __weak DXProfileViewController * weakSelf = self;
        [self fetchProfileDataWithCompletion:^(BOOL success){
            weakSelf.refreshCompletion = YES;
            [weakSelf hideActivityView];
        }];
        [self.currentFeedsViewController loadNewData];
    }
}

- (void)contentControllerDidEndRefresh:(DXProfileContentViewController *)contentController {
    [self hideActivityView];
}


#pragma mark - <DXFeedPublishDelegateController>

- (void)feedPublishController:(DXFeedPublishViewController *)feedPublishController didPublishFeed:(DXTimelineFeed *)feed {
    UITabBarController * tabBarController = self.tabBarController;
    [tabBarController setSelectedViewController:self.navigationController];
    
    [self.switchTabBarView selectIndex:0];
    [self tabBarView:self.switchTabBarView didTapButtonAtIndex:0];
    
    [self.currentFeedsViewController loadNewData];
    [self scrollContentToTop];
}


#pragma mark - 头像、背景大图预览

- (void)openAvatarPreview:(BOOL)open animated:(BOOL)animated completion:(dispatch_block_t)completion {
    __weak DXProfileViewController * weakSelf = self;
    
    if (open) {
        self.isAvatarOpen = YES;
        self.currentFeedsViewController.shouldScrollToTop = NO;
        self.headerView.showAvatarOnly = YES;
        
        CGFloat fullAvatarLength = DXScreenWidth;
        CGFloat avatarLength = CGRectGetWidth(self.avatarView.bounds);
        CGFloat scale = fullAvatarLength/avatarLength;
        CGPoint offset = CGPointMake(0,
                                     fullAvatarLength/2 - self.avatarView.center.y - CGRectGetMinY(self.headerView.frame));
        
        /** 展开时显示头像原图 */
        [self loadBigAvatarIfNeeded];
        
        dispatch_block_t animationWork = ^{
            weakSelf.avatarView.transform = CGAffineTransformMake(scale, 0, 0, scale, offset.x, offset.y);
            weakSelf.avatarView.layer.cornerRadius = 0;

            weakSelf.navigationController.navigationBar.y = -64;
            weakSelf.tabBarController.tabBar.y = DXScreenHeight;
            weakSelf.avatarImageOptionView.y = DXScreenWidth;
        };
        
        dispatch_block_t animationEnd = ^{
            if (completion) {
                completion();
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:animationWork completion:^(BOOL finished) {
                if (finished) {
                    animationEnd();
                }
            }];
        } else {
            animationWork();
            animationEnd();
        }
        
    } else {
        self.isAvatarOpen = NO;
        self.currentFeedsViewController.shouldScrollToTop = YES;
        self.headerView.showAvatarOnly = NO;
        
        dispatch_block_t animationWork = ^{
            weakSelf.avatarView.transform = CGAffineTransformIdentity;
            weakSelf.avatarView.layer.cornerRadius = CGRectGetWidth(weakSelf.avatarView.bounds)/2;
            
            CGFloat offset = -(kProfileCoverImageHeight+kProfileTabBarHeight);
            [weakSelf.currentFeedsViewController.tableView setContentOffset:CGPointMake(0, offset) animated:animated];
            
            weakSelf.navigationController.navigationBarHidden = NO;
            weakSelf.navigationController.navigationBar.y = 20;
            weakSelf.tabBarController.tabBar.y = DXScreenHeight - 49;
            weakSelf.avatarImageOptionView.y = DXScreenHeight;
        };
        
        dispatch_block_t animationEnd = ^{
            if (completion) {
                completion();
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.2 animations:animationWork completion:^(BOOL finished) {
                if (finished) {
                    animationEnd();
                }
            }];
        } else {
            animationWork();
            animationEnd();
        }
        
    }
}

- (void)openCoverPreview:(BOOL)open animated:(BOOL)animated completion:(dispatch_block_t)completion {
    __weak DXProfileViewController * weakSelf = self;
    
    if (open) {
        self.isCoverOpen = YES;
        self.currentFeedsViewController.shouldScrollToTop = NO;
        
        const CGFloat fullCoverLength = DXScreenWidth;
        
        dispatch_block_t animationWork = ^{
            weakSelf.headerView.alpha = 0;
            weakSelf.coverImageOptionView.y = fullCoverLength;
            
            weakSelf.navigationController.navigationBar.y = -64;
            weakSelf.tabBarController.tabBar.y = [UIScreen mainScreen].bounds.size.height;
            
            CGFloat offset = -(DXScreenWidth+kProfileTabBarHeight);
            [weakSelf.currentFeedsViewController.tableView setContentOffset:CGPointMake(0, offset) animated:animated];
        };
        
        dispatch_block_t animationEnd = ^{
            weakSelf.headerView.alpha = 1;
            weakSelf.headerView.hidden = YES;
            if (completion) {
                completion();
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:animationWork completion:^(BOOL finished) {
                if (finished) {
                    animationEnd();
                }
            }];
        } else {
            animationWork();
            animationEnd();
        }
        
    } else {
        self.isCoverOpen = NO;
        self.currentFeedsViewController.shouldScrollToTop = YES;

        self.headerView.alpha = 0;
        self.headerView.hidden = NO;
        
        dispatch_block_t animationWork = ^{
            weakSelf.headerView.alpha = 1;
            weakSelf.coverImageOptionView.y = [UIScreen mainScreen].bounds.size.height;
            
            weakSelf.navigationController.navigationBarHidden = NO;
            weakSelf.navigationController.navigationBar.y = 20;
            weakSelf.tabBarController.tabBar.y = [UIScreen mainScreen].bounds.size.height - 49;
            
            CGFloat offset = -(kProfileCoverImageHeight+kProfileTabBarHeight);
            [weakSelf.currentFeedsViewController.tableView setContentOffset:CGPointMake(0, offset) animated:animated];
        };
        
        dispatch_block_t animationEnd = ^{
            if (completion) {
                completion();
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:animationWork completion:^(BOOL finished) {
                if (finished) {
                    animationEnd();
                }
            }];
        } else {
            animationWork();
            animationEnd();
        }
    }
}


#pragma mark - 手势/按钮事件

- (void)handleCoverTapGesture:(UITapGestureRecognizer *)gesture {
    if (self.isCoverOpen == YES) {
        [self openCoverPreview:NO animated:YES completion:nil];
    } else {
        [self openCoverPreview:YES animated:YES completion:nil];
    }
}

- (void)handleAvatarTapGesture:(UITapGestureRecognizer *)gesture {
    if (self.isAvatarOpen == NO) {
        [self openAvatarPreview:YES animated:YES completion:nil];
    } else {
        [self openAvatarPreview:NO animated:YES completion:nil];
    }
}

- (void)handleFollowsLabelTapGesture:(UITapGestureRecognizer *)gesture {
    DXFollowViewController * followVC = [[DXFollowViewController alloc] init];
    followVC.hidesBottomBarWhenPushed = YES;
    followVC.userProfile = self.userProfile;
    [self.navigationController pushViewController:followVC animated:YES];
}

- (void)handleFansLabelTapGesture:(UITapGestureRecognizer *)gesture {
    DXFansViewController * fansVC = [[DXFansViewController alloc] init];
    fansVC.hidesBottomBarWhenPushed = YES;
    fansVC.userProfile = self.userProfile;
    [self.navigationController pushViewController:fansVC animated:YES];
}

//点击设置按钮

- (void)settingButtonTapped:(UIBarButtonItem *)sender {
    DXSettingViewController *settingVC = [[DXSettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
    settingVC.userProfile = self.userProfile;
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
}


//取消更换按钮点击事件

- (void)coverChangeButtonTapped:(UIButton *)sender{
    [self openCoverPreview:NO animated:NO completion:nil];
    DXProfileCoverUpdateViewController *changeVC = [[DXProfileCoverUpdateViewController alloc]init];
    changeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:changeVC animated:YES];
}

-(void)coverChangeCancelButtonTapped:(UIButton *)sender{
    [self openCoverPreview:NO animated:YES completion:nil];
}

- (void)avatarChangeButtonTapped:(UIButton *)sender {
    [self openAvatarPreview:NO animated:NO completion:nil];
    [self showPhotoTaker];
}

- (void)avatarCancelButtonTapped:(UIButton *)sender {
    [self openAvatarPreview:NO animated:YES completion:nil];
}

- (void)chatButtonTapped:(UIButton *)sender {
    typeof(self) __weak weakSelf = self;
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才能和其他用户进行聊天，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    DXChatViewController *vc = [[DXChatViewController alloc] init];
    DXUser *other_user = [[DXUser alloc] init];
    other_user.uid = self.userProfile.uid;
    other_user.nick = self.userProfile.username;
    other_user.avatar = self.userProfile.avatar;
    other_user.verified = self.userProfile.verified;
    vc.other_user = other_user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)followButtonTapped:(UIButton *)sender {
    typeof(self) __weak weakSelf = self;
    
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可关注你感兴趣的人，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    if (self.userProfile.relations == DXUserRelationTypeFriend ||
        self.userProfile.relations == DXUserRelationTypeFollowed) {
        [self.api unfollowUser:self.uid result:^(BOOL success, DXUserRelationType relation, NSError *error) {
            if (success) {
                weakSelf.userProfile.relations = relation;
                weakSelf.userProfile.fans -= 1;
            } else {
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"取消关注失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            }
        }];
    } else {
        [self.api followUser:self.uid result:^(BOOL success, DXUserRelationType relation, NSError *error) {
            if (success) {
                weakSelf.userProfile.relations = relation;
                weakSelf.userProfile.fans += 1;
            } else {
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请稍后尝试";
                NSString * message = [NSString stringWithFormat:@"关注失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleDefault handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - Notifications

- (void)receiveProfileDidUpdateNotification:(NSNotification *)notification{
    NSArray * childControllers = self.navigationController.childViewControllers;
    UIViewController * topViewController = [childControllers lastObject];
    if (topViewController != self) {
        for (UIViewController * viewController in childControllers.reverseObjectEnumerator) {
            if ([viewController isKindOfClass:[DXSettingViewController class]]) {
                __weak DXProfileViewController * weakSelf = self;
                __weak DXSettingViewController * settingController = (DXSettingViewController *)viewController;
                [self fetchProfileDataWithCompletion:^(BOOL success){
                    settingController.userProfile = weakSelf.userProfile;
                    [[DXDongXiApi api] updateSessionAvatar:weakSelf.userProfile.avatar];
                    [settingController.tableView reloadData];
                }];
                break;
            }
        }
    } else {
        [self fetchProfileData];
    }
}

- (void)receiveProfileCoverDidUpdateNotification:(NSNotification *)notification {
    UIImage * coverImage = [notification.userInfo objectForKey:@"coverImage"];
    if (coverImage) {
        self.coverImageView.image = coverImage;
    }
}

- (void)receiveUserDidLoginNotification:(NSNotification *)noti {
    if (self.controllerType == DXProfileViewControllerLoginUser) {
        [self setShowAnonymousController:NO];
    }
    [self fetchProfileData];
}

- (void)receiveUserDidLogoutNotification:(NSNotification *)noti {
    if (self.controllerType == DXProfileViewControllerLoginUser) {
        [self scrollContentToTop];
        [self setShowAnonymousController:YES];
        
        if (![self visitingOthersProfile]) {
            self.avatarView.image = nil;
        }
    }
}

- (void)setShowAnonymousController:(BOOL)show {
    _showAnonymousController = show;
    
    if (show) {
        self.navigationItem.titleView = nil;
        
        [self addChildViewController:self.anonymousProfileViewController];
        [self.anonymousProfileViewController didMoveToParentViewController:self];
        [self.view addSubview:self.anonymousProfileViewController.view];
        [self.view bringSubviewToFront:self.anonymousProfileViewController.view];
    } else {
        [self.anonymousProfileViewController willMoveToParentViewController:nil];
        [self.anonymousProfileViewController removeFromParentViewController];
        [self.anonymousProfileViewController.view removeFromSuperview];
    }
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.userProfile) {
        self.headerView.profile = self.userProfile;
    }
}

#pragma mark - 相册/拍照

- (void)showPhotoTaker {
    DXPhotoTakerController * photoTaker = [[DXPhotoTakerController alloc] init];
    photoTaker.delegate = self;
    photoTaker.allowPhotoAdjusting = NO;
    photoTaker.enableFixedPhotoScale = YES;
    photoTaker.fixedPhotoScale = DXPhotoScale1x1;
    [self presentViewController:photoTaker animated:YES completion:nil];
}

- (void)photoTaker:(DXPhotoTakerController *)photoTaker didFinishPhoto:(UIImage *)photo {
    __weak DXProfileViewController * weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf submitNewAvatar:photo];
    }];
}


@end
