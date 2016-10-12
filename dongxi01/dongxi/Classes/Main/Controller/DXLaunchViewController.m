//
//  DXLaunchViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLaunchViewController.h"

NSString * const DXNotificationLaunchWindowDidAppear    = @"DXNotificationLaunchWindowDidAppear";
NSString * const DXNotificationLaunchWindowDidDisappear = @"DXNotificationLaunchWindowDidDisappear";

@implementation DXLaunchViewController {
    UIImageView * _launchImageView;
    UIImageView * _launchLogoView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    int randIndex = arc4random()%3;
    NSString * launchImageName = [NSString stringWithFormat:@"launch_image_%d", randIndex];
    UIImage * launchImage = [UIImage imageNamed:launchImageName];
    CGFloat imageScale = launchImage.size.height / launchImage.size.width;
    CGRect imageViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) * imageScale);
    _launchImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    _launchImageView.image = launchImage;
    _launchImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_launchImageView];
    
    UIImage * launchLogo = [UIImage imageNamed:@"launch_logo"];
    CGRect logoFrame;
    logoFrame.size.width = roundf(DXRealValue(launchLogo.size.width));
    logoFrame.size.height = roundf(DXRealValue(launchLogo.size.height));
    logoFrame.origin.x = roundf(DXRealValue(6));
    logoFrame.origin.y = DXScreenHeight - logoFrame.size.height - roundf(DXRealValue(6));
    _launchLogoView = [[UIImageView alloc] initWithFrame:logoFrame];
    _launchLogoView.image = launchLogo;
    [self.view addSubview:_launchLogoView];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:DXNotificationLaunchWindowDidAppear object:nil];
    [self hideAnimated];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)hideAnimated {
    __weak typeof(self) weakSelf = self;
    __weak UIImageView * weakLauchImageView = _launchImageView;
    __weak UIImageView * weakLogoView = _launchLogoView;
    
    CGRect frame = weakLauchImageView.frame;
    CGRect frame1 = CGRectInset(frame, -8, -8);
    CGRect frame2 = CGRectInset(frame1, -20, -20);
    
    [UIView animateWithDuration:2 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakLauchImageView.frame = frame1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakLauchImageView.alpha = 0;
            weakLauchImageView.frame = frame2;
            weakLogoView.alpha = 0;
        } completion:^(BOOL finished) {
            weakSelf.launchWindow.hidden = YES;
            weakLauchImageView.alpha = 1;
            weakLogoView.alpha = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:DXNotificationLaunchWindowDidDisappear object:nil];
        }];
    }];
}



@end
