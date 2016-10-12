//
//  DXEventCommentViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXEventCommentViewController.h"
#import "DXEventCommentView.h"
#import "DXScreenNotice.h"

#import "DXDongXiApi.h"
#import "DXShareView.h"


NSString * const DXEventCommentNeedRefreshNotification  = @"DXEventCommentNeedRefreshNotification";


@interface DXEventCommentViewController () <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic) UIScrollView * scrollView;
@property (nonatomic) DXEventCommentView * commentView;
@property (nonatomic) DXDongXiApi * api;
@property (nonatomic) DXScreenNotice * notice;

@end


@implementation DXEventCommentViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_ActivityComment;
    
    self.view.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.title = @"评分";
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.api = [DXDongXiApi api];
    
    [self setupSubviews];
    
    self.commentView.titleLabel.text = self.activity.activity;
    self.commentView.textView.text = self.activity.my_comment;
    self.commentView.stars = self.activity.is_join ? self.activity.my_star : 0;
    self.commentView.placeholder = @"留下你想说的话...";
    [self.commentView.submitButton addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView.submitAndShareButton addTarget:self action:@selector(submitAndShareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentView.textView.returnKeyType = UIReturnKeyDone;
    self.commentView.textView.delegate = self;
    
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)setupSubviews {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentInset = UIEdgeInsetsMake(DXRealValue(20.0/3), 0, 0, 0);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(DXRealValue(20.0/3), 0, 0, 0);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    CGRect commentViewFrame = CGRectMake(0, 0, DXScreenWidth, 0);
    self.commentView = [[DXEventCommentView alloc] initWithFrame:commentViewFrame];
    commentViewFrame.size.height = [self.commentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    self.commentView.frame = commentViewFrame;
    [self.scrollView addSubview:self.commentView];
    
    [self.scrollView setContentSize:CGSizeMake(DXScreenWidth, commentViewFrame.size.height)];
}

#pragma mark -

- (DXScreenNotice *)notice {
    if (nil == _notice) {
        _notice = [[DXScreenNotice alloc] initWithMessage:@"" fromController:self];
        _notice.disableAutoDismissed = YES;
    }
    return _notice;
}


#pragma mark - Notification Actions

- (void)keyboardWillShow:(NSNotification *)noti {
    UIViewAnimationCurve curve = [[noti.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEndFrame = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect textViewFrame = [self.navigationController.view convertRect:self.commentView.textView.frame fromView:self.commentView.textView];
    textViewFrame = CGRectInset(textViewFrame, 0, -20);
    
    CGRect intersect = CGRectIntersection(keyboardEndFrame, textViewFrame);
    if (!CGRectEqualToRect(intersect, CGRectNull)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationBeginsFromCurrentState:YES];

        self.scrollView.contentOffset = CGPointMake(0, intersect.size.height);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    self.scrollView.contentOffset = CGPointMake(0, -DXRealValue(20.0/3));
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentView.textView resignFirstResponder];
}

#pragma mark - Button Actions 

- (IBAction)submitButtonTapped:(UIButton *)sender {
    typeof(self) __weak weakSelf = self;
    [self submitActivityRemark:^(BOOL succes){
        if (succes) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)submitAndShareButtonTapped:(UIButton *)sender {
    [self submitActivityRemark:^(BOOL succes) {
        if (succes) {
            [self shareAppToFriend];
        }
    }];
}

#pragma mark - Private Methods
- (void)submitActivityRemark:(void(^)(BOOL succes))resultBlock {
    NSString * activityID = self.activity.activity_id;
    NSUInteger stars = self.commentView.stars;
    NSString * text = self.commentView.textView.text;
    
    if (stars == 0) {
        self.notice.disableAutoDismissed = NO;
        [self.notice updateMessage:@"请给个评分吧"];
        [self.notice show];
        return;
    }
    
    if (!text || text.length == 0) {
        self.notice.disableAutoDismissed = NO;
        [self.notice updateMessage:@"请写点评论吧"];
        [self.notice show];
        return;
    }
    
    self.notice.disableAutoDismissed = YES;
    [self.notice updateMessage:@"提交中..."];
    [self.notice show];
    
    __weak DXEventCommentViewController * weakSelf = self;

    [self.api remarkOnActivity:activityID stars:stars text:text result:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf.notice updateMessage:@"评分成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:DXEventCommentNeedRefreshNotification object:nil];
        } else {
            NSString * reason = error.localizedDescription ? error.localizedDescription : @"请重试";
            NSString * message = [NSString stringWithFormat:@"提交失败，%@", reason];
            [weakSelf.notice updateMessage:message];
            [weakSelf.notice setTapToDismissEnabled:YES completion:nil];
        }
        
        [weakSelf.notice dismiss:YES completion:nil];
        
        if (resultBlock) {
            resultBlock(success);
        }
    }];
}


- (void)shareAppToFriend {
    UIImage * appIcon = [UIImage imageNamed:@"AppIcon60x60"];
    NSData * compressedAppIconData = UIImageJPEGRepresentation(appIcon, 0.5);
    NSData * rawAppIconData = UIImageJPEGRepresentation(appIcon, 1);
    
    NSMutableString * ratingString = [NSMutableString string];
    for (int i = 0; i < 5; i++) {
        if (i < self.commentView.stars) {
            [ratingString appendString:@"★"];
        } else {
            [ratingString appendString:@"☆"];
        }
    }
    
    NSString * shareTitle = [NSString stringWithFormat:@"我去过这个活动 %@%@",ratingString, self.activity.activity];
    NSString * shareDesc = self.activity.detail.intro;
    
    DXShareView * shareView = [[DXShareView alloc] initWithType:DXShareViewTypeShareOnly fromController:self];
    DXWeChatShareInfo * wechatShareInfo = [[DXWeChatShareInfo alloc] init];
    wechatShareInfo.title = shareTitle;
    wechatShareInfo.desc = shareDesc;
    wechatShareInfo.url = [NSString stringWithFormat:DXMobilePageActivityURLFormat, self.activity.activity_id];
    wechatShareInfo.photoData = compressedAppIconData;
    shareView.weChatShareInfo = wechatShareInfo;
    
    DXWeiboShareInfo * weiboShareInfo = [[DXWeiboShareInfo alloc] init];
    weiboShareInfo.title = shareTitle;
    weiboShareInfo.url = [NSString stringWithFormat:DXMobilePageActivityURLFormat, self.activity.activity_id];
    weiboShareInfo.photoData = rawAppIconData;
    shareView.weiboShareInfo = weiboShareInfo;
    
    [shareView show];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

@end
