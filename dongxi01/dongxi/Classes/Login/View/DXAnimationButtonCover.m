//
//  DXAnimationButtonCover.m
//  dongxi
//
//  Created by 穆康 on 15/8/14.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAnimationButtonCover.h"
#import <POP.h>
#import <MMMaterialDesignSpinner.h>

@interface DXAnimationButtonCover ()

@property (nonatomic, weak) UIImageView *loadingView;

@property (nonatomic, weak) UIImageView *warnView;

@property (nonatomic, weak) UIImageView *correctView;

@property (nonatomic, weak) MMMaterialDesignSpinner *spinner;

@end

@implementation DXAnimationButtonCover

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.layer.cornerRadius = self.height * 0.5;
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.currentState = DXAnimationButtonCoverStateNomal;
    
    UIImageView *loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_notext_login"]];
    loadingView.frame = self.bounds;
    loadingView.layer.cornerRadius = self.height * 0.5;
    loadingView.hidden = YES;
    [self addSubview:loadingView];
    self.loadingView = loadingView;
    MMMaterialDesignSpinner *spinner = [[MMMaterialDesignSpinner alloc] init];
    spinner.size = CGSizeMake(loadingView.height * 0.618, loadingView.height * 0.618);
    spinner.center = loadingView.center;
    spinner.tintColor = [UIColor whiteColor];
    spinner.lineWidth = 2;
    spinner.userInteractionEnabled = NO;
    [loadingView addSubview:spinner];
    self.spinner = spinner;
    
    UIImageView *warnView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_warning_red"]];
    warnView.frame = CGRectMake(self.width * 0.5, 0, 0, self.height);
    warnView.layer.cornerRadius = self.height * 0.5;
    warnView.hidden = YES;
    [self addSubview:warnView];
    self.warnView = warnView;
    
    UIImageView *correctView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_successful_green"]];
    correctView.frame = CGRectMake(self.width * 0.5, 0, 0, self.height);
    correctView.layer.cornerRadius = self.height * 0.5;
    correctView.hidden = YES;
    [self addSubview:correctView];
    self.correctView = correctView;
}

- (void)changeAnimationButtonCoverState:(DXAnimationButtonState)coverState {
    
    
    POPBasicAnimation *anima = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerSize];
    anima.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, self.height)];
    anima.toValue = [NSValue valueWithCGSize:CGSizeMake(self.width, self.height)];
    anima.duration = 0.2;
    
    if (coverState == DXAnimationButtonCoverStateLoading) {
        self.hidden = NO;
        self.warnView.hidden = YES;
        self.correctView.hidden = YES;
        self.loadingView.hidden = NO;
        [self.spinner startAnimating];
    } else if (coverState == DXAnimationButtonCoverStateWarn) {
        self.hidden = NO;
        self.loadingView.hidden = YES;
        [self.spinner stopAnimating];
        self.correctView.hidden = YES;
        self.warnView.hidden = NO;
        [self.warnView.layer pop_addAnimation:anima forKey:@"warn"];
    } else if (coverState == DXAnimationButtonCoverStateCorrect) {
        self.hidden = NO;
        self.loadingView.hidden = YES;
        [self.spinner stopAnimating];
        self.warnView.hidden = YES;
        self.correctView.hidden = NO;
        [self.correctView.layer pop_addAnimation:anima forKey:@"correct"];
    } else {
        self.hidden = YES;
        self.warnView.frame = CGRectMake(self.width * 0.5, 0, 0, self.height);
    }
}



@end
