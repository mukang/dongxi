//
//  DXRegisterUserInfoViewController.m
//  dongxi
//
//  Created by 穆康 on 16/1/6.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXRegisterUserInfoViewController.h"
#import "DXRegisterUserAvatarView.h"
#import "NSString+DXConvenient.h"
#import "DXPhotoTakerController.h"
#import "DXAnimationButtonCover.h"
#import "DXCacheFileManager.h"
#import "DXButton.h"

static NSInteger const DefaultTag = 100;

@interface DXRegisterUserInfoViewController () <UITextFieldDelegate, DXPhotoTakerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) DXRegisterUserAvatarView *avatarView;

@property (nonatomic, weak) UITextField *nickField;

@property (nonatomic, weak) DXButton *genderBtn;

@property (nonatomic, weak) UIButton *commitBtn;

/** 按钮的动画遮盖 */
@property (nonatomic, weak) DXAnimationButtonCover *cover;
/** 错误提示 */
@property (nonatomic, weak) UILabel *warnL;

@property (nonatomic, strong) DXUserProfileChange *profileChange;

@end

@implementation DXRegisterUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_RegisterUserInfo;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTitleView];
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.nickField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.nickField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.nickField isFirstResponder]) {
        [self.nickField resignFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTitleView {
    
    // title
    UILabel *titleL = [[UILabel alloc] init];
    titleL.text = @"完善资料";
    titleL.textColor = DXRGBColor(72, 72, 72);
    titleL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(24)];
    [titleL sizeToFit];
    titleL.center = CGPointMake(DXScreenWidth * 0.5, DXRealValue(115.5f));
    [self.view addSubview:titleL];
}

- (void)setupContent {
    
    // 头像 ***
    DXRegisterUserAvatarView *avatarView = [[DXRegisterUserAvatarView alloc] init];
    avatarView.avatarType = DXRegisterUserAvatarTypeMale;
    CGFloat avatarViewWH = DXRealValue(242/3.0);
    avatarView.size = CGSizeMake(avatarViewWH, avatarViewWH);
    avatarView.centerX = DXScreenWidth * 0.5;
    avatarView.y = DXRealValue(470/3.0);
    [self.view addSubview:avatarView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewDidTap)];
    [avatarView addGestureRecognizer:tap];
    
    // 输入昵称 ***
    CGFloat nickIconX = DXRealValue(227/3.0);
    CGFloat nickIconY = DXRealValue(809/3.0);
    CGFloat nickIconW = DXRealValue(47/3.0);
    CGFloat nickIconH = DXRealValue(31/3.0);
    UIImageView *nickIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_user_name"]];
    nickIcon.frame = CGRectMake(nickIconX, nickIconY, nickIconW, nickIconH);
    [self.view addSubview:nickIcon];
    
    CGFloat underLineW = DXRealValue(280);
    CGFloat underLineH = 0.5;
    CGFloat underLineX = (DXScreenWidth - underLineW) * 0.5;
    CGFloat underLineY = DXRealValue(292);
    UIImageView *underLine = [[UIImageView alloc] init];
    underLine.backgroundColor = DXRGBColor(64, 189, 206);
    underLine.frame = CGRectMake(underLineX, underLineY, underLineW, underLineH);
    [self.view addSubview:underLine];
    
    CGFloat nickFieldX = DXRealValue(116);
    CGFloat nickFieldW = CGRectGetMaxX(underLine.frame) - nickFieldX;
    CGFloat nickFieldH = DXRealValue(23);
    UITextField *nickField = [[UITextField alloc] init];
    nickField.size = CGSizeMake(nickFieldW, nickFieldH);
    nickField.x = nickFieldX;
    nickField.centerY = nickIcon.centerY;
    nickField.attributedPlaceholder = [self attributedWithString:@"请输入昵称" color:DXRGBColor(143, 143, 143)];
    nickField.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    nickField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nickField.returnKeyType = UIReturnKeyDone;
    nickField.delegate = self;
    [self.view addSubview:nickField];
    
    // 性别按钮 ***
    CGFloat genderBtnW = DXRealValue(178/3.0);
    CGFloat genderBtnH = DXRealValue(26);
    CGFloat genderBtnY = CGRectGetMaxY(underLine.frame) + DXRealValue(67/3.0);
    CGFloat genderBtnPadding = DXRealValue(259/3.0);
    
    DXButton *maleBtn = [self buttonWithNormalImageName:@"register_user_male_normal" selectedImageName:@"register_user_male_selected"];
    maleBtn.selected = YES;
    maleBtn.tag = DefaultTag;
    maleBtn.frame = CGRectMake(genderBtnPadding, genderBtnY, genderBtnW, genderBtnH);
    [self.view addSubview:maleBtn];
    
    DXButton *femaleBtn = [self buttonWithNormalImageName:@"register_user_female_normal" selectedImageName:@"register_user_female_selected"];
    femaleBtn.tag = DefaultTag + 1;
    femaleBtn.size = CGSizeMake(genderBtnW, genderBtnH);
    femaleBtn.y = genderBtnY;
    femaleBtn.centerX = DXScreenWidth * 0.5;
    [self.view addSubview:femaleBtn];
    
    DXButton *otherBtn = [self buttonWithNormalImageName:@"register_user_other_normal" selectedImageName:@"register_user_other_selected"];
    otherBtn.tag = DefaultTag + 2;
    CGFloat otherBtnX = DXScreenWidth - genderBtnPadding - genderBtnW;
    otherBtn.frame = CGRectMake(otherBtnX, genderBtnY, genderBtnW, genderBtnH);
    [self.view addSubview:otherBtn];
    
    // 提交按钮 ***
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setImage:[UIImage imageNamed:@"button_commit_blue_normal"] forState:UIControlStateNormal];
    [commitBtn setImage:[UIImage imageNamed:@"button_commit_blue_click"] forState:UIControlStateHighlighted];
    [commitBtn addTarget:self action:@selector(commitBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat commitBtnW = DXRealValue(280);
    CGFloat commitBtnH = DXRealValue(44);
    CGFloat commitBtnY = CGRectGetMaxY(underLine.frame) + DXRealValue(89);
    commitBtn.size = CGSizeMake(commitBtnW, commitBtnH);
    commitBtn.y = commitBtnY;
    commitBtn.centerX = DXScreenWidth * 0.5;
    [self.view addSubview:commitBtn];
    
    // 按钮的动画遮盖 ***
    DXAnimationButtonCover *cover = [[DXAnimationButtonCover alloc] initWithFrame:commitBtn.frame];
    [self.view addSubview:cover];
    
    // 错误提示 ***
    UILabel *warnL = [[UILabel alloc] init];
    warnL.textAlignment = NSTextAlignmentCenter;
    warnL.textColor = DXRGBColor(255, 109, 119);
    warnL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(12)];
    warnL.size = CGSizeMake(commitBtn.width, 12);
    warnL.centerX = commitBtn.centerX;
    warnL.y = commitBtn.y - 20;
    warnL.hidden = YES;
    [self.view addSubview:warnL];
    
    self.avatarView = avatarView;
    self.nickField = nickField;
    self.genderBtn = maleBtn;
    self.commitBtn = commitBtn;
    self.cover = cover;
    self.warnL = warnL;
    self.profileChange.gender = @(DXUserGenderTypeMale);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"] && [self.nickField isFirstResponder]) {
        [self.nickField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.warnL.hidden == NO) {
        self.warnL.hidden = YES;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
    }
}

#pragma mark - UITextField Notification

- (void)textFieldDidChange:(NSNotification *)noti{
    UITextField *textField = (UITextField *)noti.object;
    if (textField == self.nickField) {
        const CGFloat kNameMaxLength = 8;
        NSString *toBeString = textField.text;
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制，有高亮选择的字符串，则暂不对文字进行统计和限制
        if (!position) {
            NSUInteger chineseLength = [toBeString chineseCharacterLength];
            if (chineseLength > kNameMaxLength) {
                textField.text = [toBeString stringByLimitedToChineseCharacterLength:kNameMaxLength];
            }
        }
    }
}

#pragma mark - UIKeyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGFloat keyboardY = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].origin.y;
    
    CGFloat loginBtnMaxY = CGRectGetMaxY(self.commitBtn.frame);
    
    if (loginBtnMaxY <= keyboardY) return;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.y = keyboardY - loginBtnMaxY;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    
    if (self.view.y == 0) return;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.y = 0;
    }];
}

#pragma mark - 点击头像

- (void)avatarViewDidTap {
    
    [self showPhotoTaker];
}

#pragma mark - 点击性别按钮

- (void)genderBtnDidClick:(DXButton *)btn {
    
    if (btn.tag == self.genderBtn.tag) return;
    
    btn.selected = YES;
    self.genderBtn.selected = NO;
    self.genderBtn = btn;
    
    switch (btn.tag) {
        case DefaultTag:
            self.avatarView.avatarType = DXRegisterUserAvatarTypeMale;
            self.profileChange.gender = @(DXUserGenderTypeMale);
            break;
        case DefaultTag + 1:
            self.avatarView.avatarType = DXRegisterUserAvatarTypeFemale;
            self.profileChange.gender = @(DXUserGenderTypeFemale);
            break;
        case DefaultTag + 2:
            self.avatarView.avatarType = DXRegisterUserAvatarTypeOther;
            self.profileChange.gender = @(DXUserGenderTypeOther);
            break;
            
        default:
            break;
    }
}

#pragma mark - 点击提交按钮

- (void)commitBtnDidClick {
    
    if ([self.nickField isFirstResponder]) {
        [self.nickField resignFirstResponder];
    }
    
    if (self.nickField.text.length == 0) {
        self.warnL.text = @"请填写一个昵称";
        self.warnL.hidden = NO;
        [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
    } else {
        [self commit];
    }
}

- (void)commit {
    
    self.profileChange.username = self.nickField.text;
    [self.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateLoading];
    self.view.userInteractionEnabled = YES;
    __weak typeof(self) weakSelf = self;
    
    [[DXDongXiApi api] changeProfile:self.profileChange result:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateCorrect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 设置页面可点击
                weakSelf.view.userInteractionEnabled = YES;
                
                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                    // 设置成功后的回调，通知appdelegate检查用户是否设置感兴趣标签
                    if (weakSelf.registerCompletionBlock) {
                        weakSelf.registerCompletionBlock(); 
                    }
                    if (weakSelf.isNewRegistered) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:DXShouldShowSetLikeTagAlert object:nil];
                    }
                    // 通知用户资料已更新
                    [[NSNotificationCenter defaultCenter] postNotificationName:DXProfileDidUpdateNotification object:nil];
                    // 更新头像
                    [weakSelf updateSessionAvatar];
                }];
            });
        } else {
            // 设置页面可点击
            weakSelf.view.userInteractionEnabled = YES;
            
            weakSelf.warnL.text = error.localizedDescription;
            weakSelf.warnL.hidden = NO;
            [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateWarn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.warnL.hidden = YES;
                [weakSelf.cover changeAnimationButtonCoverState:DXAnimationButtonCoverStateNomal];
            });
        }
    }];
}

/**
 *  更新头像
 */
- (void)updateSessionAvatar {
    
    DXDongXiApi *dongxiApi = [DXDongXiApi api];
    NSString *currentUid = [dongxiApi currentUserSession].uid;
    
    [dongxiApi getProfileOfUser:currentUid result:^(DXUserProfile *profile, NSError *error) {
        if (profile) {
            [dongxiApi updateSessionAvatar:profile.avatar];
        }
    }];
}

#pragma mark - 点击空白区域退出键盘

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([self.nickField isFirstResponder]) {
        [self.nickField resignFirstResponder];
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
    __weak DXRegisterUserInfoViewController * weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf submitNewAvatar:photo];
    }];
}

- (void)submitNewAvatar:(UIImage *)avatar {
    if (avatar) {
        typeof(_avatarView) __weak weakAvatarView = _avatarView;
        
        DXScreenNotice * screenNotice = [[DXScreenNotice alloc] initWithMessage:@"正在上传头像.." fromController:self];
        screenNotice.disableAutoDismissed = YES;
        [screenNotice show];
        
        NSData * data = UIImageJPEGRepresentation(avatar, 0.6);
        
        DXCacheFileManager * fileManager = [DXCacheFileManager sharedManager];
        DXCacheFile * avatarFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeImageCache];
        avatarFile.extension = @"jpg";
        avatarFile.deleteWhenAppLaunch = YES;
        NSError * tempFileSaveError = nil;
        if ([fileManager saveData:data toFile:avatarFile error:&tempFileSaveError]) {
            [[DXDongXiApi api] changeAvatar:avatarFile.url result:^(BOOL success, NSString *url, NSError *error) {
                if (success) {
                    weakAvatarView.avatarImageView.image = avatar;
                    weakAvatarView.addAvatarView.hidden = YES;
                    weakAvatarView.custom = YES;
                    [screenNotice updateMessage:@"头像更新成功"];
                    [screenNotice dismiss:YES completion:nil];
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

#pragma mark - 懒加载
- (DXUserProfileChange *)profileChange {
    
    if (_profileChange == nil) {
        _profileChange = [[DXUserProfileChange alloc] init];
    }
    return _profileChange;
}

#pragma mark - 返回性别按钮
- (DXButton *)buttonWithNormalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName {
    
    DXButton *btn = [DXButton buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(genderBtnDidClick:) forControlEvents:UIControlEventTouchDown];
    
    return btn;
}

#pragma mark - 返回NSMutableAttributedString方法
- (NSMutableAttributedString *)attributedWithString:(NSString *)string color:(UIColor *)color {
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attStr addAttributes:@{
                            NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)],
                            NSForegroundColorAttributeName: color
                            } range:NSMakeRange(0, string.length)];
    return attStr;
}

@end
