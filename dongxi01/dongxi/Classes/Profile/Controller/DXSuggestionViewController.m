//
//  DXSuggestionViewController.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSuggestionViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "DXDongXiApi.h"
#import "UIImage+Extension.h"


@interface DXSuggestionViewController ()<UITextViewDelegate, UIScrollViewDelegate>

//意见反馈text
@property(nonatomic,strong) UITextView *textView;

//联系方式text
@property(nonatomic,strong) UITextView *contactTextView;

//占位字1
@property(nonatomic,strong) UILabel *placeHolderL;

//占位字2
@property(nonatomic,strong) UILabel *placeHolderC;

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, assign) CGRect currentKeyboardFrame;

@end

@implementation DXSuggestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_SettingsFeedback;

    self.title = @"意见反馈";
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    
    UIBarButtonItem * sendItem = [[UIBarButtonItem alloc] init];
    [sendItem setTitle:@"发送"];
    [sendItem setTarget:self];
    [sendItem setAction:@selector(sendItemTapped:)];
    self.navigationItem.rightBarButtonItem = sendItem;
    
    [self setupContent];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -  设置内容

- (void)setupContent {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAlwaysBounceVertical:YES];
    [_scrollView setContentSize:self.view.bounds.size];
    [_scrollView setDelegate:self];
    [self.view addSubview:_scrollView];
    
    UITapGestureRecognizer * tapToDismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewTapGesture:)];
    [_scrollView addGestureRecognizer:tapToDismissKeyboard];
    
    // 文字距输入框四周的间距
    CGFloat margin = DXRealValue(13);
    
    //分割线
    UIView *lineV1 = [[UIView alloc]initWithFrame:CGRectMake(0, DXRealValue(251), DXScreenWidth, 1)];
    lineV1.backgroundColor = DXRGBColor(222, 222, 222);
    [_scrollView addSubview:lineV1];
    
    // 输入框
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(DXRealValue(13), DXRealValue(13), DXScreenWidth - DXRealValue(26), DXRealValue(222))];
    textView.returnKeyType = UIReturnKeyDefault;
    textView.layer.cornerRadius = 4;
    textView.layer.borderColor = (__bridge CGColorRef)(DXRGBColor(172, 172, 172));
    textView.layer.borderWidth = 1;
    textView.alwaysBounceVertical = YES;
    textView.alwaysBounceHorizontal = NO;
    textView.textColor = DXRGBColor(72, 72, 72);
    textView.font = [UIFont systemFontOfSize:DXRealValue(15)];
    textView.textContainerInset = UIEdgeInsetsMake(margin, margin - 5, margin, margin - 5);
    textView.delegate = self;
    [_scrollView addSubview:textView];
    _textView = textView;
    
    // 占位文字
    UILabel *placeHolderL = [[UILabel alloc] init];
    placeHolderL.text = @"请输入您的想法...";
    placeHolderL.textColor = DXRGBColor(143, 143, 143);
    placeHolderL.font = [UIFont systemFontOfSize:DXRealValue(15)];
    [placeHolderL sizeToFit];
    placeHolderL.origin = CGPointMake(margin, margin);
    [_textView addSubview:placeHolderL];
    _placeHolderL = placeHolderL;

    
    // 输入框
    UITextView *conectTextView = [[UITextView alloc] initWithFrame:CGRectMake(DXRealValue(13), DXRealValue(194) + 64, DXScreenWidth - DXRealValue(26), DXRealValue(41))];
    conectTextView.returnKeyType = UIReturnKeySend;
    conectTextView.layer.cornerRadius = 4;
    conectTextView.layer.borderColor = (__bridge CGColorRef)(DXRGBColor(172, 172, 172));
    conectTextView.layer.borderWidth = 1;
    conectTextView.alwaysBounceVertical = YES;
    conectTextView.alwaysBounceHorizontal = NO;
    conectTextView.textColor = DXRGBColor(72, 72, 72);
    conectTextView.font = [UIFont systemFontOfSize:DXRealValue(15)];
    conectTextView.textContainerInset = UIEdgeInsetsMake(margin, margin - 5, margin, margin - 5);
    conectTextView.delegate = self;
    [_scrollView addSubview:conectTextView];
    _contactTextView = conectTextView;
    
    // 占位文字
    UILabel *placeHolderC = [[UILabel alloc] init];
    placeHolderC.text = @"请留下您的联系方式（QQ，微信，邮箱）";
    placeHolderC.textColor = DXRGBColor(143, 143, 143);
    placeHolderC.font = [UIFont systemFontOfSize:DXRealValue(15)];
    [placeHolderC sizeToFit];
    placeHolderC.origin = CGPointMake(margin, margin);
    [_contactTextView addSubview:placeHolderC];
    _placeHolderC = placeHolderC;

    
    //分割线
    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(0, DXRealValue(194) + 64, DXScreenWidth, 0.5)];
    lineV.backgroundColor = DXRGBColor(222, 222, 222);
    [_scrollView addSubview:lineV];
    
}

#pragma mark - 事件

/**
 *  发送按钮点击事件
 *
 *  @param sender 事件调用方
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)sendItemTapped:(UIBarButtonItem *)sender {
    [self checkAndSendFeedback];
}

/**
 *  检查意见反馈内容，然后提前
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)checkAndSendFeedback {
    NSString * feedbackText = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * feedbackContact = [self.contactTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (feedbackText == nil || [feedbackText isEqualToString:@""]) {
        self.textView.text = @"";
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"请留下反馈内容" fromController:self];
        [notice show];
        return;
    }
    
    if (feedbackContact == nil || [feedbackContact isEqualToString:@""]) {
        self.contactTextView.text = @"";
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"请留下您的联系方式" fromController:self];
        [notice show];
        return;
    }
    
    __weak DXSuggestionViewController * weakSelf = self;
    DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"正在提交..." fromController:self];
    notice.disableAutoDismissed = YES;
    [notice show];
    DXUserFeedback * feedback = [[DXUserFeedback alloc] init];
    feedback.contact = feedbackContact;
    feedback.txt = feedbackText;
    [[DXDongXiApi api] sendUserFeeback:feedback result:^(BOOL success, NSError *error) {
        if (success) {
            [notice updateMessage:@"感谢您的意见反馈:)"];
            [notice dismiss:YES completion:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [notice updateMessage:@"提交失败，请稍后再试"];
            [notice dismiss:YES];
        }
    }];
}


#pragma mark - 代理方法

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self updateScrollViewOffsetWithKeyboardFrame:self.currentKeyboardFrame];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView == _textView) {
        
        _placeHolderL.hidden = textView.text.length;
    }
    if (textView == _contactTextView) {
        _placeHolderC.hidden = _contactTextView.text.length;

    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.contactTextView) {
        if ([text isEqualToString:@"\n"]) {
            [self checkAndSendFeedback];
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [_textView resignFirstResponder];
    [_contactTextView resignFirstResponder];
}

#pragma mark - Gesture 

- (void)handleScrollViewTapGesture:(UITapGestureRecognizer *)gesture {
    [_textView resignFirstResponder];
    [_contactTextView resignFirstResponder];
}


#pragma mark - Notification

- (void)handleKeyboardWillChangeFrameNotification:(NSNotification *)noti {
    if ([self.contactTextView isFirstResponder]) {
        CGRect kbEndFrame = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.currentKeyboardFrame = kbEndFrame;
        [self updateScrollViewOffsetWithKeyboardFrame:kbEndFrame];
    }
}

#pragma mark -

- (void)updateScrollViewOffsetWithKeyboardFrame:(CGRect)kbFrame {
    if (CGRectEqualToRect(kbFrame, CGRectZero)) {
        return;
    }
    
    CGRect textViewFrame;
    if ([self.contactTextView isFirstResponder]) {
        textViewFrame = [self.scrollView convertRect:self.contactTextView.frame toView:self.scrollView];
    } else if ([self.textView isFirstResponder]) {
        textViewFrame = [self.scrollView convertRect:self.textView.frame toView:self.scrollView];
    } else {
        return;
    }
    
    const CGFloat navbarPlusStatusbarHeight = 64;
    CGFloat kbTop = CGRectGetMinY(kbFrame) - navbarPlusStatusbarHeight;
    CGFloat textViewBottom = CGRectGetMaxY(textViewFrame);
    if (kbTop < textViewBottom) {
        CGFloat deltaY = textViewBottom - kbTop + 10;
        CGPoint scrollOffset = self.scrollView.contentOffset;
        scrollOffset.y += deltaY;
        [self.scrollView setContentOffset:scrollOffset animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}


@end
