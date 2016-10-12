//
//  DXMessageLikeViewController.m
//  dongxi
//
//  Created by 穆康 on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageLikeViewController.h"
#import "DXMessageLikeCell.h"
#import "UIBarButtonItem+Extension.h"
#import "DXDongXiApi.h"
#import "DXMainNavigationController.h"
#import <MJRefresh.h>
#import "DXDetailViewController.h"
#import "DXNoneDataTableViewCell.h"

typedef void(^DXCompletionBlock)(BOOL more, NSError *error);

@interface DXMessageLikeViewController () <DXMessageLikeCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;

/** 错误信息描述 */
@property (nonatomic, copy) NSString *errorDesc;

@end

@implementation DXMessageLikeViewController {
    __weak DXMessageLikeViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    
    self.dt_pageName = DXDataTrackingPage_MessagesLikes;
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"赞";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(backBtnDidClick)];
    
    // 添加上下拉刷新
    self.tableView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [DXRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadOldData)];
    self.tableView.mj_footer.hidden = YES;
    
    [self getNetDataFirst];
}

#pragma mark - 加载数据

- (void)getNetDataFirst {
    
    [self loadDataWithPullType:DXDataListPullFirstTime Completion:nil];
}

- (void)loadNewData {
    
    [self loadDataWithPullType:DXDataListPullNewerList Completion:^(BOOL more, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)loadOldData {
    
    [self loadDataWithPullType:DXDataListPullOlderList Completion:^(BOOL more, NSError *error) {
        DXRefreshAutoFooter *footer = (DXRefreshAutoFooter *)weakSelf.tableView.mj_footer;
        if (error) {
            [footer endRefreshingWithError];
        } else {
            if (more) {
                [footer endRefreshing];
            } else {
                footer.hidden = YES;
            }
        }
    }];
}

- (void)loadDataWithPullType:(DXDataListPullType)pullType Completion:(DXCompletionBlock)completionBlock {
    
    NSString *ID = nil;
    if (pullType == DXDataListPullNewerList) {
        DXNoticeLike *like = [self.dataList firstObject];
        ID = like.ID;
    } else if (pullType == DXDataListPullOlderList) {
        DXNoticeLike *like = [self.dataList lastObject];
        ID = like.ID;
    }
    
    if (ID == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [[DXDongXiApi api] getMessageNoticeLikeList:20 pullType:pullType lastID:ID result:^(DXNoticeLikeList *noticeLikeList, NSError *error) {
        if (noticeLikeList.list.count) {
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, noticeLikeList.list.count)];
                [weakSelf.dataList insertObjects:noticeLikeList.list atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:noticeLikeList.list];
            }
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && noticeLikeList.list.count == 20) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDesc = @"没有点赞内容";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            }
        }
        
        [weakSelf.tableView reloadData];
        
        if (completionBlock) {
            completionBlock(noticeLikeList.more, error);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.dataList.count) {
        return self.dataList.count;
    } else {
        return 1;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        DXMessageLikeCell *cell = [DXMessageLikeCell cellWithTableView:tableView];
        DXNoticeLike *like = self.dataList[indexPath.row];
        cell.like = like;
        cell.delegate = self;
        return cell;
    } else {
        DXNoneDataTableViewCell *cell = [DXNoneDataTableViewCell cellWithTableView:tableView];
        cell.text = self.errorDesc;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        return DXRealValue(80);
    } else {
        return DXRealValue(120);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DXNoticeLike *like = self.dataList[indexPath.row];
        [[DXDongXiApi api] deleteMessageNoticeOrLikeByID:like.ID result:^(BOOL success, NSError *error) {
            if (success) {
                DXLog(@"点赞删除成功");
            }
        }];
        [self.dataList removeObjectAtIndex:indexPath.row];
        if (self.dataList.count) {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        DXNoticeLike *like = self.dataList[indexPath.row];
        DXDetailViewController *vc = [[DXDetailViewController alloc] initWithControllerType:DXDetailViewControllerTypeFeedID];
        vc.detailType = DXDetailTypeContent;
        vc.feedID = like.fid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DXMessageLikeCellDelegate

- (void)didTapAvatarInMessageLikeCellWithUserID:(NSString *)userID {
    
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

#pragma mark - 点击按钮执行的方法

/**
 *  点击返回按钮
 */
- (void)backBtnDidClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载

- (NSMutableArray *)dataList {
    
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
