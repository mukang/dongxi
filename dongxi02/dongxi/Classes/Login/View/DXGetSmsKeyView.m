//
//  DXGetSmsKeyView.m
//  dongxi
//
//  Created by 穆康 on 15/10/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXGetSmsKeyView.h"

@interface DXGetSmsKeyView ()

@property (nonatomic, weak) UIButton *getKeyBtn;

@property (nonatomic, weak) UILabel *timeL;

@property (nonatomic, assign) NSInteger timeCount;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DXGetSmsKeyView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupWithFrame:frame];
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame {
    
    self.backgroundColor = [UIColor whiteColor];
    
    // 计时数字
    self.timeCount = 60;
    
    // 计时label
    UILabel *timeL = [[UILabel alloc] init];
    timeL.backgroundColor = DXRGBColor(207, 207, 207);
    timeL.text = [NSString stringWithFormat:@"%02zd秒后重发", self.timeCount];
    timeL.textAlignment = NSTextAlignmentCenter;
    timeL.textColor = [UIColor whiteColor];
    timeL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13)];
    [self addSubview:timeL];
    self.timeL = timeL;
    
    // 获取验证码按钮
    UIButton *getKeyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getKeyBtn.backgroundColor = [UIColor whiteColor];
    [getKeyBtn setBackgroundImage:[UIImage imageNamed:@"button_getkey"] forState:UIControlStateNormal];
    [getKeyBtn addTarget:self action:@selector(clickGetKeyBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:getKeyBtn];
    self.getKeyBtn = getKeyBtn;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.getKeyBtn.frame = self.bounds;
    
    self.timeL.frame = self.bounds;
    self.timeL.layer.cornerRadius = self.timeL.height * 0.5f;
    self.timeL.layer.masksToBounds = YES;
}

- (void)clickGetKeyBtn {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickGetSmsKeyInGetSmsKeyView:)]) {
        [self.delegate didClickGetSmsKeyInGetSmsKeyView:self];
    }
}

- (void)startCountDown {
    
    self.getKeyBtn.hidden = YES;
    
    [self addTimer];
}

- (void)changeTimeL {
    
    self.timeCount --;
    
    if (self.timeCount <= 0) {
        [self removeTimer];
        self.getKeyBtn.hidden = NO;
        self.timeCount = 60;
    }
    
    self.timeL.text = [NSString stringWithFormat:@"%02zd秒后重发", self.timeCount];
}

#pragma mark - 定时器

- (void)addTimer {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTimeL) userInfo:nil repeats:YES];
}

- (void)removeTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc {
    
    [self removeTimer];
}

@end
