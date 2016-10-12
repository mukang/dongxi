//
//  DXPasswordChangeViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/6.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPasswordChangeViewController.h"
#import "DXPasswordSettingView.h"
#import "DXDongXiApi.h"

@interface DXPasswordChangeViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * contentView;

@property (nonatomic, strong) DXPasswordSettingView * originPasswordSettingView;
@property (nonatomic, strong) DXPasswordSettingView * currentPasswordSettingView;
@property (nonatomic, strong) DXPasswordSettingView * currentPasswordRepeatSettingView;
@property (nonatomic, strong) UIButton * commitButton;

@end


@implementation DXPasswordChangeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_SettingsPassword;
    
    self.title = @"修改密码";
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
}

- (void)setupSubviews {
    UITapGestureRecognizer * scrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    [_scrollView addGestureRecognizer:scrollViewTapGesture];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];
    
    UIImage * lockImage = [UIImage imageNamed:@"icon_key_grew"];;
    
    _originPasswordSettingView = [[DXPasswordSettingView alloc] initWithFrame:CGRectZero];
    _originPasswordSettingView.placeHolder = @"请输入原密码";
    _originPasswordSettingView.leftImageColor = DXRGBColor(177, 177, 177);
    _originPasswordSettingView.leftImage = lockImage;
    _originPasswordSettingView.textField.returnKeyType = UIReturnKeyNext;
    _originPasswordSettingView.textField.delegate = self;
    _originPasswordSettingView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_originPasswordSettingView];
    
    _currentPasswordSettingView = [[DXPasswordSettingView alloc] initWithFrame:CGRectZero];
    _currentPasswordSettingView.placeHolder = @"请输入新密码";
    _currentPasswordSettingView.leftImageColor = DXRGBColor(120, 201, 255);
    _currentPasswordSettingView.leftImage = lockImage;
    _currentPasswordSettingView.textField.returnKeyType = UIReturnKeyNext;
    _currentPasswordSettingView.textField.delegate = self;
    _currentPasswordSettingView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_currentPasswordSettingView];
    
    _currentPasswordRepeatSettingView = [[DXPasswordSettingView alloc] initWithFrame:CGRectZero];
    _currentPasswordRepeatSettingView.placeHolder = @"请再次输入新密码";
    _currentPasswordRepeatSettingView.leftImageColor = DXRGBColor(120, 201, 255);
    _currentPasswordRepeatSettingView.leftImage = lockImage;
    _currentPasswordRepeatSettingView.textField.returnKeyType = UIReturnKeyDone;
    _currentPasswordRepeatSettingView.textField.delegate = self;
    _currentPasswordRepeatSettingView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_currentPasswordRepeatSettingView];
    
    UIImage * commitImage = [UIImage imageNamed:@"button_commit_blue_normal"];
    UIImage * commitHighlightedImage = [UIImage imageNamed:@"button_commit_blue_click"];
    _commitButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_commitButton setImage:commitImage forState:UIControlStateNormal];
    [_commitButton setImage:commitHighlightedImage forState:UIControlStateHighlighted];
    [_commitButton addTarget:self action:@selector(commitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _commitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_commitButton];
}

- (void)setupConstraints {
    NSMutableArray * visualFormats = [NSMutableArray array];
    NSMutableArray * constraints = [NSMutableArray array];
    NSMutableDictionary * metrics = [NSMutableDictionary dictionary];
    NSDictionary * views = NSDictionaryOfVariableBindings(_scrollView, _contentView, _originPasswordSettingView, _currentPasswordSettingView, _currentPasswordRepeatSettingView, _commitButton);
    
    CGFloat settingViewLeading = 202.0/3;
    CGFloat settingViewTrailing = settingViewLeading;
    CGFloat textFieldHeight = 111.0/3;
    CGFloat textFieldSpace = DXScreenHeight * 0.082;
    CGFloat originPasswordTop = DXScreenHeight * 0.144;
    CGFloat currentPasswordTop = originPasswordTop + textFieldSpace;
    CGFloat currentPasswordRepeatTop = currentPasswordTop + textFieldSpace;
    CGFloat commitButtonTop = DXScreenHeight * 0.43;
    UIImage * commitButtonImage = [_commitButton imageForState:UIControlStateNormal];
    CGFloat commitButtonWidth = DXRealValue(commitButtonImage.size.width);
    CGFloat commitButtonheight = DXRealValue(commitButtonImage.size.height);
    
    [metrics setObject:@(settingViewLeading) forKey:@"settingViewLeading"];
    [metrics setObject:@(settingViewTrailing) forKey:@"settingViewTrailing"];
    [metrics setObject:@(textFieldHeight) forKey:@"textFieldHeight"];
    [metrics setObject:@(originPasswordTop) forKey:@"originPasswordTop"];
    [metrics setObject:@(currentPasswordTop) forKey:@"currentPasswordTop"];
    [metrics setObject:@(currentPasswordRepeatTop) forKey:@"currentPasswordRepeatTop"];
    [metrics setObject:@(commitButtonTop) forKey:@"commitButtonTop"];
    [metrics setObject:@(commitButtonWidth) forKey:@"commitButtonWidth"];
    [metrics setObject:@(commitButtonheight) forKey:@"commitButtonheight"];
    
    [visualFormats addObject:@"H:|[_scrollView]|"];
    [visualFormats addObject:@"V:|[_scrollView]|"];
    
    [visualFormats addObject:@"H:|[_contentView]"];
    [visualFormats addObject:@"V:|[_contentView]"];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_contentView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_scrollView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_contentView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_scrollView
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:0]];
    
    [visualFormats addObject:@"H:|-settingViewLeading-[_originPasswordSettingView]-settingViewLeading-|"];
    [visualFormats addObject:@"V:|-originPasswordTop-[_originPasswordSettingView(==textFieldHeight)]"];
    
    [visualFormats addObject:@"H:|-settingViewLeading-[_currentPasswordSettingView]-settingViewLeading-|"];
    [visualFormats addObject:@"V:|-currentPasswordTop-[_currentPasswordSettingView(==textFieldHeight)]"];
    
    [visualFormats addObject:@"H:|-settingViewLeading-[_currentPasswordRepeatSettingView]-settingViewLeading-|"];
    [visualFormats addObject:@"V:|-currentPasswordRepeatTop-[_currentPasswordRepeatSettingView(==textFieldHeight)]"];
    
    [visualFormats addObject:@"H:[_commitButton(==commitButtonWidth)]"];
    [visualFormats addObject:@"V:|-commitButtonTop-[_commitButton(==commitButtonheight)]"];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_commitButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_contentView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0]];
    
    for (NSString * vf in visualFormats) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:metrics views:views]];
    }
    
    [self.view addConstraints:constraints];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.originPasswordSettingView.textField) {
        [self.currentPasswordSettingView.textField becomeFirstResponder];
    } else if (textField == self.currentPasswordSettingView.textField) {
        [self.currentPasswordRepeatSettingView.textField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return ![string isEqualToString:@" "];
}

#pragma mark - UIScrollView相关

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:NO];
}

- (void)scrollViewTapped:(UITapGestureRecognizer *)gesture {
    [self.view endEditing:NO];
}

#pragma mark - Button Action

- (IBAction)commitButtonTapped:(UIButton *)sender {
    [self checkAndSubmitPasswordChange];
}

#pragma mark - 业务处理

- (void)checkAndSubmitPasswordChange {
    [self.view endEditing:NO];
    
    NSString * originPassword = self.originPasswordSettingView.password;
    NSString * currentPassword = self.currentPasswordSettingView.password;
    NSString * currentPasswordRepeat = self.currentPasswordRepeatSettingView.password;
    
    if ([originPassword isEqualToString:@""]) {
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"原密码不能为空" fromController:self];
        [notice show];
        return;
    }
    
    if ([currentPassword isEqualToString:@""]) {
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"新密码不能为空" fromController:self];
        [notice show];
        return;
    }
    
    if (![currentPasswordRepeat isEqualToString:currentPassword]) {
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"新密码两次输入不一致" fromController:self];
        [notice show];
        return;
    }
    
    DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"正在修改密码" fromController:self];
    notice.disableAutoDismissed = YES;
    [notice show];
    
    __weak DXPasswordChangeViewController * weakSelf = self;
    
    DXUserPasswordChangeInfo * passwordChange = [[DXUserPasswordChangeInfo alloc] init];
    passwordChange.oldpassword = originPassword;
    passwordChange.newpassword = currentPassword;
    [[DXDongXiApi api] changePasswordWithInfo:passwordChange result:^(DXUserChangePasswordStatus status, NSError *error) {
        if (!error) {
            switch (status) {
                case DXUserChangePasswordOK: {
                    [notice updateMessage:@"密码已成功修改"];
//                    [notice setTapToDismissEnabled:YES completion:^{
//                        [weakSelf.navigationController popViewControllerAnimated:YES];
//                    }];
                    [notice dismiss:YES completion:^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }];
                }
                    break;
                case DXUserChangePasswordWrongOldPassword: {
                    [notice updateMessage:@"原密码不正确"];
                    [notice dismiss:YES];
                }
                    break;
                case DXUserChangePasswordNewPasswordIdenticalToOldOne: {
                    [notice updateMessage:@"新密码不能和原密码相同"];
                    [notice dismiss:YES];
                }
                    break;
                default: {
                    [notice updateMessage:@"修改密码出错，请重试"];
                    [notice dismiss:YES];
                }
                    break;
            }
        } else {
            [notice updateMessage:@"修改密码出错，请稍后重试"];
            [notice dismiss:YES];
        }
    }];
}

@end


