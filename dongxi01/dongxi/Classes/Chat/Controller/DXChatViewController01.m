//
//  DXChatViewController01.m
//  dongxi
//
//  Created by 穆康 on 16/4/7.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatViewController01.h"

#import "DXChatHelper.h"

#import "UIBarButtonItem+Extension.h"

#import "DXChatToolBar.h"
#import "DXChatRecordView.h"

// 一次请求的最多消息数
static const int kPageCount = 20;

@interface DXChatViewController01 ()
<
UITableViewDataSource,
UITableViewDelegate,
DXChatToolBarDelegate,
DXChatRecordViewDelegate
>
{
    __weak DXChatViewController01 *weakSelf;
}

/** 私聊对象 */
@property (nonatomic, copy) NSString *chatter;
/** 私聊工具 */
@property (nonatomic, strong) DXChatHelper *chatHelper;
/** 内容视图 */
@property (nonatomic, weak) UITableView *tableView;
/** 底部工具栏 */
@property (nonatomic, weak) DXChatToolBar *chatToolBar;
/** 录音视图 */
@property (nonatomic, weak) DXChatRecordView *recordView;
/** 正在播放音频 */
@property (nonatomic, assign) BOOL isPlayingAudio;
/** 滚动到底部 */
@property (nonatomic, assign) BOOL isScrollToBottom;
/** 是否设置了frame */
@property (nonatomic, assign) BOOL contentFrameSetted;

@end

@implementation DXChatViewController01

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dt_pageName = DXDataTrackingPage_PrivateChat;
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    
    self.chatter = [NSString stringWithFormat:@"cuser%@", self.other_user.uid];
    self.isPlayingAudio = NO;
    self.isScrollToBottom = YES;
    self.contentFrameSetted = NO;
    [self.chatHelper markAllChatMessagesAsReadByUserID:self.other_user.uid];
    
    [self setupNav];
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 设置内容尺寸
    if (self.contentFrameSetted == NO) {
        [self setupContentFrames];
        self.contentFrameSetted = YES;
    }
    
//    [self registNotification];
    
    if (self.isScrollToBottom) {
        [self scrollViewToBottom:NO];
    }
    else{
        self.isScrollToBottom = YES;
    }
}

/**
 *  设置导航栏
 */
- (void)setupNav {
    
    self.title = self.other_user.nick;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
}

/**
 *  设置内容
 */
- (void)setupContent {
    
    // 内容视图
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = DXRGBColor(222, 222, 222);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 工具栏
    DXChatToolBar *chatToolBar = [[DXChatToolBar alloc] init];
    chatToolBar.delegate = self;
    [self.view addSubview:chatToolBar];
    self.chatToolBar = chatToolBar;
    
    // 录音视图
    DXChatRecordView *recordView = [[DXChatRecordView alloc] init];
    recordView.delegate = self;
    [self.view addSubview:recordView];
    self.recordView = recordView;
}

/**
 *  设置内容尺寸
 */
- (void)setupContentFrames {
    
    self.view.frame = CGRectMake(0, 0, DXScreenWidth, DXScreenHeight - 64);
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 49);
    
    CGFloat toolBarW = self.view.width;
    CGFloat toolBarH = 49;
    CGFloat toolBarX = 0;
    CGFloat toolBarY = self.view.height - toolBarH;
    self.chatToolBar.frame = CGRectMake(toolBarX, toolBarY, toolBarW, toolBarH);
    
    self.recordView.frame = CGRectMake(0, self.view.height, self.view.width, 225);
}

/**
 *  滚动到最底部
 */
- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载

- (DXChatHelper *)chatHelper {
    if (_chatHelper == nil) {
        _chatHelper = [DXChatHelper sharedHelper];
    }
    return _chatHelper;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
