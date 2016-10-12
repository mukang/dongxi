//
//  DXAboutUsViewController.m
//  dongxi
//
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXAboutUsViewController.h"
#import "DXAppVersionView.h"
#import "DXAppVersionViewCell.h"
#import "DXProfileSettingBaseCell.h"

#import "DXPrivacyPolicyViewController.h"
#import "DXUserAgreementViewController.h"
#import "DXApplyVerfiyViewController.h"

#import "DXDongXiApi.h"

@interface DXAboutUsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) DXAppVersionView * appVersionView;

@end

@implementation DXAboutUsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorColor = DXRGBColor(222, 222, 222);
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.tableFooterView = [[UIView alloc] init];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.tableView registerClass:[DXAppVersionViewCell class] forCellReuseIdentifier:@"DXAppVersionViewCell"];
        [self.tableView registerClass:[DXProfileSettingBaseCell class] forCellReuseIdentifier:@"DXProfileSettingBaseCell"];
        [self.view addSubview:self.tableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_About;
    
    self.title = @"关于东西";
    self.view.backgroundColor = DXRGBColor(243, 243, 243);
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        // 未登陆状态不显示“申请东西认证”
        if ([[DXDongXiApi api] needLogin]) {
            return 2;
        } else {
            return 3;
        }
    } else {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DXAppVersionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXAppVersionViewCell" forIndexPath:indexPath];
        return cell;
    }
    
    if (indexPath.section == 1) {
        DXProfileSettingBaseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXProfileSettingBaseCell" forIndexPath:indexPath];
        cell.showMoreView = YES;
        switch (indexPath.row) {
            case 0:
                cell.settingTextLabel.text = @"隐私声明";
                break;
            case 1:
                cell.settingTextLabel.text = @"服务协议";
                break;
            case 2:
                cell.settingTextLabel.text = @"申请东西认证";
                break;
            default:
                break;
        }
        return cell;
    }
    
    return nil;
}


#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return ceilf(DXRealValue(388));
    } else if (indexPath.section == 1) {
        return ceilf(DXRealValue(62));
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        UIViewController * nextViewController = nil;
        switch (indexPath.row) {
            case 0:
                nextViewController = [[DXPrivacyPolicyViewController alloc] init];
                break;
            case 1:
                nextViewController = [[DXUserAgreementViewController alloc] init];
                break;
            case 2:
                nextViewController = [[DXApplyVerfiyViewController alloc] init];
                break;
            default:
                break;
        }
        if (nextViewController) {
            [self.navigationController pushViewController:nextViewController animated:YES];
        }
    }
}


@end
