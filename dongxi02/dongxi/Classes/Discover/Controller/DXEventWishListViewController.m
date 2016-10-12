//
//  DXEventWishListViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXEventWishListViewController.h"
#import "DXProfileViewController.h"
#import "DXActivityWishUserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DXDongXiApi.h"

@interface DXEventWishListViewController () <UITableViewDataSource, UITableViewDelegate, DXActivityWishUserCellDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableDictionary * userProfiles;

@end

@implementation DXEventWishListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_ActivityFollowers;
    
    self.view.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.title = @"想去的人";
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    self.userProfiles = [NSMutableDictionary dictionary];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[DXActivityWishUserCell class] forCellReuseIdentifier:@"DXActivityWishUserCell"];
    [self.view addSubview:self.tableView];
}



#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DXActivityWishUserCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXActivityWishUserCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;

    DXActivityWantUserInfo * userInfo = [self.users objectAtIndex:indexPath.row];
    cell.nick = userInfo.nick;
    cell.location = userInfo.location;
    [cell.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
    cell.avatarView.verified = userInfo.verified;
    cell.avatarView.certificationIconSize = DXCertificationIconSizeLarge;

    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DXRealValue(232.0f/3);
}

#pragma mark - <DXActivityWishUserCellDelegate>

- (void)wishUserCell:(DXActivityWishUserCell *)cell didTapAvatarView:(UIImageView *)avatarView {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row < self.users.count) {
        DXActivityWantUserInfo * userInfo = [self.users objectAtIndex:indexPath.row];
        DXProfileViewController * profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
        profileVC.uid = userInfo.uid;
        [self.navigationController pushViewController:profileVC animated:YES];
    }
}

@end
