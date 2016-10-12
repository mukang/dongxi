//
//  DXChatRecordView.m
//  dongxi
//
//  Created by 穆康 on 15/9/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatRecordView.h"
#import "EMCDDeviceManager.h"

@interface DXChatRecordView ()

/** 录音时长 */
@property (nonatomic, weak) UILabel *timeL;
/** 取消录音提示 */
@property (nonatomic, weak) UILabel *cancelRecordL;
/** 录音按钮 */
@property (nonatomic, weak) UIButton *recordBtn;
/** 显示动画的ImageView */
@property (nonatomic, weak) UIImageView *recordAnimationView;
/** 播放动画的定时器 */
@property (nonatomic, strong) NSTimer *animationTimer;
/** 录音时长的定时器 */
@property (nonatomic, strong) NSTimer *recordTimer;
/** 记录时长的数字 */
@property (nonatomic, assign) NSInteger timeNum;

@end

@implementation DXChatRecordView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    // 录音时长
    UILabel *timeL = [[UILabel alloc] init];
    timeL.text = @"按住开始说话";
    timeL.textColor = DXRGBColor(143, 143, 143);
    timeL.font = [UIFont fontWithName:DXCommonFontName size:13];
    timeL.textAlignment = NSTextAlignmentCenter;
    timeL.frame = CGRectMake(0, 3, DXScreenWidth, 13);
    [self addSubview:timeL];
    self.timeL = timeL;
    
    // 取消录音提示
    UILabel *cancelRecordL = [[UILabel alloc] init];
    cancelRecordL.text = @"向上滑动取消发送";
    cancelRecordL.textColor = DXRGBColor(143, 143, 143);
    cancelRecordL.font = [UIFont fontWithName:DXCommonFontName size:13];
    cancelRecordL.textAlignment = NSTextAlignmentCenter;
    cancelRecordL.frame = CGRectMake(0, 3, DXScreenWidth, 13);
    cancelRecordL.hidden = YES;
    [self addSubview:cancelRecordL];
    self.cancelRecordL = cancelRecordL;
    
    // 显示动画的ImageView
    UIImageView *recordAnimationView = [[UIImageView alloc] init];
    recordAnimationView.image = [UIImage imageNamed:@"recordAnimation001"];
    recordAnimationView.size = CGSizeMake(265, 47.5);
    recordAnimationView.centerX = DXScreenWidth * 0.5;
    recordAnimationView.y = 79;
    [self addSubview:recordAnimationView];
    self.recordAnimationView = recordAnimationView;
    
    // 录音按钮
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setImage:[UIImage imageNamed:@"button_input_voice"] forState:UIControlStateNormal];
    [recordBtn addTarget:self action:@selector(recordBtnTouchDown) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(recordBtnTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [recordBtn addTarget:self action:@selector(recordBtnTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(recordBtnDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [recordBtn addTarget:self action:@selector(recordBtnDragInside) forControlEvents:UIControlEventTouchDragEnter];
    recordBtn.size = CGSizeMake(111, 111);
    recordBtn.centerX = DXScreenWidth * 0.5;
    recordBtn.centerY = recordAnimationView.centerY;
    [self addSubview:recordBtn];
    self.recordBtn = recordBtn;
    
}

#pragma mark - 点击按钮执行的方法

/**
 *  录音按钮按下
 */
- (void)recordBtnTouchDown {
    
    if ([self.delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [self.delegate didStartRecordingVoiceAction:self];
    }
    
    // 开始播放动画
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(setVoiceImage) userInfo:nil repeats:YES];
    
    // 显示时长
    self.timeNum = 0;
    self.timeL.text = @"00:00";
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTimeL) userInfo:nil repeats:YES];
}

/**
 *  手指在录音按钮外部时离开
 */
- (void)recordBtnTouchUpOutside {
    
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)]) {
        [self.delegate didCancelRecordingVoiceAction:self];
    }
    
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    
    // 显示时长
    self.timeL.hidden = NO;
    self.cancelRecordL.hidden = YES;
    self.timeL.text = @"按住开始说话";
    self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation001"];
}

/**
 *  手指在录音按钮内部时离开
 */
- (void)recordBtnTouchUpInside {
    
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)]) {
        [self.delegate didFinishRecoingVoiceAction:self];
    }
    
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    
    // 显示时长
    self.timeL.hidden = NO;
    self.cancelRecordL.hidden = YES;
    self.timeL.text = @"按住开始说话";
    self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation001"];
}

/**
 *  手指移动到录音按钮外部
 */
- (void)recordBtnDragOutside {
    
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)]) {
        [self.delegate didDragOutsideAction:self];
    }
    
    // 显示提示
    self.timeL.hidden = YES;
    self.cancelRecordL.hidden = NO;
}

/**
 *  手指移动到录音按钮内部
 */
- (void)recordBtnDragInside {
    
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)]) {
        [self.delegate didDragInsideAction:self];
    }
    
    // 显示时长
    self.timeL.hidden = NO;
    self.cancelRecordL.hidden = YES;
}

#pragma mark - 设置动画

- (void)setVoiceImage {
    
    self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation001"];
    
    double voiceSound = 0;
    voiceSound = [[EMCDDeviceManager sharedInstance] emPeekRecorderVoiceMeter];
    
    if (0 < voiceSound <= 0.0625) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation001"];
    } else if (0.0625 < voiceSound <= 0.125) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation002"];
    } else if (0.125 < voiceSound <= 0.1875) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation003"];
    } else if (0.1875 < voiceSound <= 0.25) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation004"];
    } else if (0.25 < voiceSound <= 0.3125) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation005"];
    } else if (0.3125 < voiceSound <= 0.375) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation006"];
    } else if (0.375 < voiceSound <= 0.4375) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation007"];
    } else if (0.4375 < voiceSound <= 0.5) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation008"];
    } else if (0.5 < voiceSound <= 0.5625) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation009"];
    } else if (0.5625 < voiceSound <= 0.625) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation010"];
    } else if (0.625 < voiceSound <= 0.6875) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation011"];
    } else if (0.6875 < voiceSound <= 0.75) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation012"];
    } else if (0.75 < voiceSound <= 0.8125) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation013"];
    } else if (0.8125 < voiceSound <= 0.875) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation014"];
    } else if (0.875 < voiceSound <= 0.9375) {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation015"];
    } else {
        self.recordAnimationView.image = [UIImage imageNamed:@"recordAnimation016"];
    }
}

// 设置录音时长
- (void)changeTimeL {
    
    self.timeNum ++;
    
    NSInteger secondNum = self.timeNum % 60;
    NSInteger minuteNum = self.timeNum / 60;
    
    self.timeL.text = [NSString stringWithFormat:@"%02zd:%02zd", minuteNum, secondNum];
}

@end
