//
//  DXMessageCommentViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageCommentViewController.h"
#import "DXMessageCommentCell.h"
#import "DXMessageCommentFeedCell.h"
#import "UIBarButtonItem+Extension.h"
#import "DXComposeViewController.h"
#import "DXDongXiApi.h"
#import <MJRefresh.h>
#import "DXDetailViewController.h"
#import "DXNoneDataTableViewCell.h"
#import "DXTopicViewController.h"

typedef void(^DXCompletionBlock)(BOOL more, NSError *error);

@interface DXMessageCommentViewController () <DXMessageCommentCellDelegate, DXMessageCommentFeedCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;
/** 错误信息描述 */
@property (nonatomic, copy) NSString *errorDesc;

@end

@implementation DXMessageCommentViewController {
    __weak DXMessageCommentViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    
    self.dt_pageName = DXDataTrackingPage_MessagesComments;
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = @"评论";
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
        DXNoticeCommentWrapper *commentWrapper = [[self.dataList firstObject] firstObject];
        ID = commentWrapper.ID;
    } else if (pullType == DXDataListPullOlderList) {
        DXNoticeCommentWrapper *commentWrapper = [[self.dataList lastObject] lastObject];
        ID = commentWrapper.ID;
    }
    
    if (ID == nil) {
        pullType = DXDataListPullFirstTime;
    }
    
    [[DXDongXiApi api] getMessageNoticeCommentList:10 pullType:pullType lastID:ID result:^(DXNoticeCommentList *commentList, NSError *error) {
        if (commentList.list.count) {
            
            NSString *currentID = [[commentList.list firstObject] fid];
            NSMutableArray *tempArray = [NSMutableArray array];
            NSMutableArray *tempWrappers = [NSMutableArray array];
            for (DXNoticeCommentWrapper *commentWrapper in commentList.list) {
                if ([commentWrapper.fid isEqualToString:currentID]) {
                    [tempWrappers addObject:commentWrapper];
                } else {
                    [tempArray addObject:tempWrappers];
                    tempWrappers = [NSMutableArray array];
                    [tempWrappers addObject:commentWrapper];
                    currentID = commentWrapper.fid;
                }
            }
            if (tempWrappers.count) {
                [tempArray addObject:tempWrappers];
            }
            
            if (pullType == DXDataListPullNewerList) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)];
                [weakSelf.dataList insertObjects:tempArray atIndexes:indexSet];
            } else {
                [weakSelf.dataList addObjectsFromArray:tempArray];
            }
            
            if (pullType == DXDataListPullFirstTime && weakSelf.tableView.mj_footer.isHidden && commentList.list.count == 10) {
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        } else {
            weakSelf.errorDesc = @"没有评论内容";
            if (error) {
                NSString *reason = error.localizedDescription ? error.localizedDescription : @"请稍后再试";
                weakSelf.errorDesc = [NSString stringWithFormat:@"加载失败，%@", reason];
                if (weakSelf.dataList.count) [MBProgressHUD showHUDWithMessage:weakSelf.errorDesc];
            }
        }
        
        [weakSelf.tableView reloadData];
        
        if (completionBlock) {
            completionBlock(commentList.more, error);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.dataList.count) {
        return self.dataList.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataList.count) {
        NSArray *tempArray = self.dataList[section];
        return tempArray.count + 1;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        NSArray *tempArray = self.dataList[indexPath.section];
        if (indexPath.row == 0) {
            DXMessageCommentFeedCell *cell = [DXMessageCommentFeedCell cellWithTableView:tableView];
            cell.delegate = self;
            cell.commentWrapper = [tempArray firstObject];
            return cell;
        } else {
            DXNoticeCommentWrapper *commentWrapper = tempArray[indexPath.row - 1];
            DXNoticeComment *comment = commentWrapper.comment;
            DXMessageCommentCell *cell = [DXMessageCommentCell cellWithTableView:tableView];
            cell.comment = comment;
            cell.feedID = commentWrapper.fid;
            cell.delegate = self;
            return cell;
        }
    } else {
        DXNoneDataTableViewCell *cell = [DXNoneDataTableViewCell cellWithTableView:tableView];
        cell.text = self.errorDesc;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataList.count) {
        if (indexPath.row == 0) {
            return DXRealValue(124.0f);
        } else {
            NSArray *tempArray = self.dataList[indexPath.section];
            DXNoticeCommentWrapper *commentWrapper = tempArray[indexPath.row - 1];
            DXNoticeComment *comment = commentWrapper.comment;
            return [DXMessageCommentCell tableView:tableView heightForRowAtIndexPath:indexPath withComment:comment];
        }
    } else {
        return DXRealValue(120);
    }
}

#pragma mark - <DXMessageCommentCellDelegate>

- (void)messageCommentCell:(DXMessageCommentCell *)cell didTapReplyBtnWithComment:(DXNoticeComment *)comment feedID:(NSString *)feedID {
    
    DXCommentTemp *temp = [[DXCommentTemp alloc] init];
    temp.feedID = feedID;
    temp.ID = comment.comment_id;
    temp.userID = comment.comment_uid;
    temp.nick = comment.comment_nick;
    
    DXComposeViewController *vc = [[DXComposeViewController alloc] init];
    vc.composeType = DXComposeTypeReply;
    vc.temp = temp;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)messageCommentCell:(DXMessageCommentCell *)cell didTapAvatarWithUserID:(NSString *)userID {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)messageCommentCell:(DXMessageCommentCell *)cell didSelectReferUserWithUserID:(NSString *)userID {
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    [nav pushToProfileViewControllerWithUserID:userID info:nil];
}

- (void)messageCommentCell:(DXMessageCommentCell *)cell didSelectReferTopicWithTopicID:(NSString *)topicID {
    DXTopicViewController *vc = [[DXTopicViewController alloc] init];
    vc.topicID = topicID;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - <DXMessageCommentFeedCellDelegate>

- (void)messageCommentFeedCell:(UITableViewCell *)cell didTapFeedViewWithFeedID:(NSString *)feedID {
    
    DXDetailViewController *vc = [[DXDetailViewController alloc] initWithControllerType:DXDetailViewControllerTypeFeedID];
    vc.feedID = feedID;
    vc.detailType = DXDetailTypeContent;
    [self.navigationController pushViewController:vc animated:YES];
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
