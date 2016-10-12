//
//  DXProfileBioEditViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileBioEditViewController.h"
#import "NSString+DXConvenient.h"

@interface DXProfileBioEditViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) UILabel * placeHolderLabel;
@property (nonatomic, strong) UILabel * textCountLabel;
@property (nonatomic, assign) NSInteger leftTextCount;

@property (nonatomic, assign) BOOL originInteractivePopGestureEnabled;

@end

@implementation DXProfileBioEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"简介";
    self.dt_pageName = DXDataTrackingPage_SettingsBio;
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(navBackItemTapped:)];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    [doneButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:DXCommonBoldFontName size:16],
                                         NSForegroundColorAttributeName: DXCommonColor
                                         }
                              forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self setupContents];

    self.textView.text = self.bioText;
    [self updatePlaceHolder];
    [self updateTextCount];
}

- (void)setupContents {
    const CGFloat textViewTop = DXRealValue(40.0/3);
    const CGFloat textViewLeading = DXRealValue(38.0/3);
    const CGFloat textViewTrailing = textViewLeading;
    const CGFloat textViewPadding = DXRealValue(41.0/3);//内边距
    
    const CGFloat textViewWidth = DXScreenWidth - textViewLeading - textViewTrailing;
    const CGFloat textViewHeight = DXRealValue(150);
    
    const CGFloat textCountLabelWidth = textViewWidth;
    const CGFloat textCountLabelTop = textViewTop + textViewHeight + 1;
    const CGFloat textCountLabelLeading = textViewLeading;
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(textViewLeading, textViewTop, textViewWidth, textViewHeight)];
    textView.returnKeyType = UIReturnKeyDone;
    textView.layer.cornerRadius = 4;
    textView.layer.borderColor = (__bridge CGColorRef)(DXRGBColor(172, 172, 172));
    textView.layer.borderWidth = 1;
    textView.alwaysBounceVertical = YES;
    textView.alwaysBounceHorizontal = NO;
    textView.textColor = DXRGBColor(72, 72, 72);
    textView.font = [DXFont dxDefaultFontWithSize:15];
    textView.textContainerInset = UIEdgeInsetsMake(textViewPadding,textViewPadding,textViewPadding,textViewPadding);
    textView.delegate = self;
    [self.view addSubview:textView];
    
    UILabel * placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"写点自我介绍吧";
    placeHolderLabel.textColor = DXRGBColor(143, 143, 143);
    placeHolderLabel.font = [DXFont dxDefaultFontWithSize:15];
    [placeHolderLabel sizeToFit];
    placeHolderLabel.origin = CGPointMake(textViewPadding + 5, textViewPadding);
    [textView addSubview:placeHolderLabel];
    
    UILabel * textCountLabel = [[UILabel alloc] init];
    textCountLabel.font = [DXFont systemFontOfSize:10 weight:DXFontWeightLight];
    textCountLabel.textColor = DXRGBColor(72, 72, 72);
    textCountLabel.textAlignment = NSTextAlignmentRight;
    textCountLabel.text = @"32";
    [textCountLabel sizeToFit];
    const CGFloat textCountLabelHeight = CGRectGetHeight(textCountLabel.bounds);
    [textCountLabel setFrame:CGRectMake(textCountLabelLeading, textCountLabelTop, textCountLabelWidth, textCountLabelHeight)];
    [self.view addSubview:textCountLabel];
    
    self.textView = textView;
    self.placeHolderLabel = placeHolderLabel;
    self.textCountLabel = textCountLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
    self.originInteractivePopGestureEnabled = navigationController.enableInteractivePopGesture;
    navigationController.enableInteractivePopGesture = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
    navigationController.enableInteractivePopGesture = self.originInteractivePopGestureEnabled;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBioText:(NSString *)bioText {
    _bioText = bioText;
    self.textView.text = bioText;
    [self updatePlaceHolder];
    [self updateTextCount];
}

#pragma mark - 事件

- (IBAction)navBackItemTapped:(UIBarButtonItem *)sender {
    [self.textView resignFirstResponder];
    
    if (![self.textView.text isEqualToString:self.bioText]) {
        if (![self checkIfBioPrepared]) {
            __weak typeof(self) weakSelf = self;
            DXCompatibleAlert * actionSheet = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
            actionSheet.title = @"字数已超出限制";
            [actionSheet addAction:[DXCompatibleAlertAction actionWithTitle:@"继续修改" style:DXCompatibleAlertActionStyleDefault handler:nil]];
            [actionSheet addAction:[DXCompatibleAlertAction actionWithTitle:@"撤销修改" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }]];
            [actionSheet addAction:[DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil]];
            [actionSheet showInController:self animated:YES completion:nil];
        } else {
            if (self.bioDidChangeHandler) {
                self.bioDidChangeHandler(self.textView.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.bioDidChangeHandler) {
            self.bioDidChangeHandler(self.textView.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    [self checkAndSubmitChanges];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}


#pragma mark - <UITextViewDelegate>

- (void)textViewDidChange:(UITextView *)textView {
    [self updatePlaceHolder];
    [self updateTextCount];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - TextView相关显示控制

- (void)updatePlaceHolder {
    if (self.textView.text.length > 0) {
        self.placeHolderLabel.hidden = YES;
    } else {
        self.placeHolderLabel.hidden = NO;
    }
}

- (void)updateTextCount {
    NSUInteger textCount = [self.textView.text chineseCharacterLength];
    self.leftTextCount = self.maxBioTextCount - textCount;
    self.textCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.leftTextCount];
}

#pragma mark - 业务逻辑

- (BOOL)checkIfBioPrepared {
    if (self.leftTextCount >= 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)checkAndSubmitChanges {
    [self.textView resignFirstResponder];
    
    if ([self checkIfBioPrepared]) {
        if (self.bioDidChangeHandler) {
            self.bioDidChangeHandler(self.textView.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:@"字数已超出限制" fromController:self];
        [notice show];
    }
}

@end
