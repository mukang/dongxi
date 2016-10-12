//
//  DXChatToolBar.m
//  dongxi
//
//  Created by 穆康 on 15/9/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatToolBar.h"
#import "DXChatTextView.h"

/** 输入框的最小高度 */
static const CGFloat TextViewMinHeight = 35;
/** 输入框的最大高度 */
#define TextViewMaxHeight DXRealValue(125)
//static const CGFloat TextViewMaxHeight = 100;

@interface DXChatToolBar () <UITextViewDelegate>

/** 语音和文字切换按钮 */
@property (nonatomic, weak) UIButton *styleChangeButton;
/** 输入框 */
@property (nonatomic, weak) DXChatTextView *textView;
/** 上一次textView的contentSize.height */
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;

@end

@implementation DXChatToolBar

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat leftMargin = 13;
    CGFloat topMargin = 7;
    
    // 语音和文字切换按钮
    UIButton *styleChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [styleChangeButton setImage:[UIImage imageNamed:@"button_chat_voice"] forState:UIControlStateNormal];
    [styleChangeButton setImage:[UIImage imageNamed:@"voice_keyboards_icon"] forState:UIControlStateSelected];
    [styleChangeButton addTarget:self action:@selector(styleChangeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    styleChangeButton.frame = CGRectMake(leftMargin, topMargin, 35, 35);
    [self addSubview:styleChangeButton];
    self.styleChangeButton = styleChangeButton;
    
    // 调出语音和收起语音按钮
    UIButton *changeRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeRecordBtn.contentMode = UIViewContentModeCenter;
    [changeRecordBtn setImage:[UIImage imageNamed:@"up_2"] forState:UIControlStateNormal];
    [changeRecordBtn setImage:[UIImage imageNamed:@"down_2"] forState:UIControlStateSelected];
    [changeRecordBtn addTarget:self action:@selector(changeRecordBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat changeRecordBtnX = CGRectGetMaxX(styleChangeButton.frame) + leftMargin;
    CGFloat changeRecordBtnY = 0;
    CGFloat changeRecordBtnW = DXScreenWidth - changeRecordBtnX * 2.0f;
    CGFloat changeRecordBtnH = 49.0f;
    changeRecordBtn.frame = CGRectMake(changeRecordBtnX, changeRecordBtnY, changeRecordBtnW, changeRecordBtnH);
    [self addSubview:changeRecordBtn];
    changeRecordBtn.hidden = YES;
    self.changeRecordBtn = changeRecordBtn;
    
    // 输入框
    CGFloat textViewX = CGRectGetMaxX(styleChangeButton.frame) + leftMargin;
    CGFloat textViewY = topMargin;
    CGFloat textViewW = DXScreenWidth - textViewX - leftMargin;
    CGFloat textViewH = TextViewMinHeight;
    DXChatTextView *textView = [[DXChatTextView alloc] initWithFrame:CGRectMake(textViewX, textViewY, textViewW, textViewH)];
    textView.layer.borderColor = [DXRGBColor(195, 195, 195) CGColor];
    textView.layer.borderWidth = 0.3;
    textView.layer.cornerRadius = 13;
    textView.layer.masksToBounds = YES;
    textView.delegate = self;
    self.previousTextViewContentHeight = [self getTextViewContentH:textView];
    [self addSubview:textView];
    self.textView = textView;
//    DXLog(@"--> %@", NSStringFromUIEdgeInsets(textView.textContainerInset));
}

#pragma mark - 私有方法

/**
 *  获取textView的高度
 */
- (CGFloat)getTextViewContentH:(UITextView *)textView {

    return ceilf([textView sizeThatFits:textView.size].height);
}

/**
 *  TextView需要变化高度到 toHeight
 */
- (void)willShowInputTextViewToHeight:(CGFloat)toHeight {
    
    if (toHeight < TextViewMinHeight) {
        toHeight = TextViewMinHeight;
    }
    if (toHeight > TextViewMaxHeight) {
        toHeight = TextViewMaxHeight;
    }
    if (toHeight == self.previousTextViewContentHeight) {
        return;
    } else {
        CGFloat changeHeight = toHeight - self.previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        self.textView.height += changeHeight;
    }
    
    self.previousTextViewContentHeight = toHeight;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBarDidChangeFrameToHeight:)]) {
        [self.delegate chatToolBarDidChangeFrameToHeight:self.height];
    }
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.styleChangeButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            textView.text = @"";
            [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击语音和文字切换按钮
 */
- (void)styleChangeButtonDidClick:(UIButton *)btn {
    
    self.styleChangeButton.selected = !btn.selected;
    
    if (btn.selected) { // 录音
        [self.textView resignFirstResponder];
        self.textView.hidden = YES;
        [self willShowInputTextViewToHeight:35];
        self.changeRecordBtn.hidden = NO;
        self.changeRecordBtn.selected = YES;
    } else { // 文字
        [self.textView becomeFirstResponder];
        self.textView.hidden = NO;
        [self willShowInputTextViewToHeight:[self getTextViewContentH:self.textView]];
        self.changeRecordBtn.hidden = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(didStyleChangeToRecord:)]) {
        [self.delegate didStyleChangeToRecord:btn.selected];
    }
}

/**
 *  录音显示或隐藏
 */
- (void)changeRecordBtnDidClick:(UIButton *)btn {
    
    BOOL isShow = !btn.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRecordBtnStatusChangeToShow:)]) {
        [self.delegate didRecordBtnStatusChangeToShow:isShow];
    }
}

@end
