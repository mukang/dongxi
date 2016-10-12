//
//  DXUserAgreementViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserAgreementViewController.h"

@interface DXUserAgreementViewController ()

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSMutableAttributedString * userAgreementText;

@end

@implementation DXUserAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_AboutAgreement;
    
    self.title = @"服务协议";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    
    [self setupContents];
    [self.textView setAttributedText:self.userAgreementText];
}

- (void)setupContents {
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.textView];
}


- (NSMutableAttributedString *)userAgreementText {
    if (nil == _userAgreementText) {
        NSURL * fileURL = [[NSBundle mainBundle] URLForResource:@"DXUserAgreement" withExtension:@"rtf"];
        if (fileURL) {
            NSError * err = nil;
#ifdef __IPHONE_9_0
            if (DXSystemVersion >= 9) {
                _userAgreementText = [[NSMutableAttributedString alloc] initWithURL:fileURL options:@{} documentAttributes:nil error:&err];
            } else {
                _userAgreementText = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{} documentAttributes:nil error:&err];
            }
#else
            _userAgreementText = [[NSMutableAttributedString alloc] initWithFileURL:fileURL options:@{} documentAttributes:nil error:&err];
#endif
            if (err) {
                NSLog(@"user agreement file read error: %@", err);
            }
        }
    }
    return _userAgreementText;
}

@end
