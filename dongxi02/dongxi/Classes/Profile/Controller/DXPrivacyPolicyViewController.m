//
//  DXPrivacyPolicyViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPrivacyPolicyViewController.h"

@interface DXPrivacyPolicyViewController ()

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSMutableAttributedString * policyText;

@end

@implementation DXPrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_AboutPrivacy;
    
    self.title = @"隐私声明";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    
    [self setupContents];
    self.textView.attributedText = self.policyText;
}

- (void)setupContents {
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.textView];
}

- (NSMutableAttributedString *)policyText {
    if (nil == _policyText) {
        NSURL * fileURL = [[NSBundle mainBundle] URLForResource:@"DXPrivacyPolicy" withExtension:@"rtf"];
        if (fileURL) {
            NSError * err = nil;
#ifdef __IPHONE_9_0
            if (DXSystemVersion >= 9) {
                _policyText = [[NSMutableAttributedString alloc] initWithURL:fileURL options:@{} documentAttributes:nil error:&err];
            } else {
                _policyText = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{} documentAttributes:nil error:&err];
            }
#else
            _policyText = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{} documentAttributes:nil error:&err];
#endif
            if (err) {
                NSLog(@"policy file read error: %@", err);
            }
        }
    }
    return _policyText;
}

@end
