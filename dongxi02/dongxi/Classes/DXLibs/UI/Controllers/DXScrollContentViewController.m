//
//  DXScrollContentViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXScrollContentViewController.h"

@implementation DXScrollContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareContentView];
}

- (void)prepareContentView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    
    _contentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_scrollView addSubview:_contentView];
}

@end
