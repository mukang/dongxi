//
//  DXReferViewController.m
//  dongxi
//
//  Created by 穆康 on 16/5/6.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXReferViewController.h"

#import "UIImage+Extension.h"

#import "DXReferViewCell.h"

@interface DXReferViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDC;

@property (nonatomic, strong) NSArray *recentContacts;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *recentTopics;
@property (nonatomic, strong) NSArray *allTopics;

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation DXReferViewController {
    __weak DXReferViewController *weakSelf;
}

- (instancetype)initWithReferType:(DXReferType)referType {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _referType = referType;
        weakSelf = self;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"请使用-[DXReferViewController initWithReferType:]来初始化");
    return nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSAssert(NO, @"请使用-[DXReferViewController initWithReferType:]来初始化");
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.referType == DXReferTypeUser) {
        self.dt_pageName = DXDataTrackingPage_ReferUser;
    } else {
        self.dt_pageName = DXDataTrackingPage_ReferTopic;
    }
    
    [self setupNav];
    [self setupContent];
    [self loadNetData];
}

- (void)setupNav {
    
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(247, 250, 251)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:bgImage];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelBtnDidClick)];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{
                                                                    NSFontAttributeName: [UIFont fontWithName:DXCommonFontName size:17],
                                                                    NSForegroundColorAttributeName: DXCommonColor
                                                                    } forState:UIControlStateNormal];
}

- (void)setupContent {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.backgroundColor = DXRGBColor(239, 239, 239);
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    UIImage *bgImage = [UIImage imageWithColor:DXRGBColor(239, 239, 239)];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.width, DXRealValue(46))];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.backgroundImage = bgImage;
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    tableView.tableHeaderView = searchBar;
    tableView.tableFooterView = [UIView new];
    
    UISearchDisplayController *searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDC.searchResultsDelegate = self;
    searchDC.searchResultsDataSource = self;
    searchDC.delegate = self;
    
    self.tableView = tableView;
    self.searchBar = searchBar;
    self.searchDC = searchDC;
}

#pragma mark - 获取网路数据

- (void)loadNetData {
    
    if (self.referType == DXReferTypeUser) {
        [[DXDongXiApi api] getReferContacts:^(NSArray *recentContacts, NSArray *allContacts, NSError *error) {
            if (allContacts) {
                weakSelf.recentContacts = recentContacts;
                weakSelf.allContacts = allContacts;
                [weakSelf.tableView reloadData];
            }
        }];
    } else {
        [[DXDongXiApi api] getReferTopics:^(NSArray *recentTopics, NSArray *allTopics, NSError *error) {
            if (allTopics) {
                weakSelf.recentTopics = recentTopics;
                weakSelf.allTopics = allTopics;
                [weakSelf.tableView reloadData];
            }
        }];
    }
}

#pragma mark - tableView delegate and dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.tableView]) {
        if (self.referType == DXReferTypeUser) {
            if (self.recentContacts.count) {
                return self.allContacts.count + 1;
            } else {
                return self.allContacts.count;
            }
        } else {
            if (self.recentTopics.count) {
                return 2;
            } else {
                return 1;
            }
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        if (self.referType == DXReferTypeUser) {
            if (self.recentContacts.count) {
                if (section == 0) {
                    return self.recentContacts.count;
                } else {
                    DXReferUserWrapper *referUserWrapper = self.allContacts[section -1];
                    return referUserWrapper.referUsers.count;
                }
            } else {
                DXReferUserWrapper *referUserWrapper = self.allContacts[section];
                return referUserWrapper.referUsers.count;
            }
        } else {
            if (self.recentTopics.count) {
                if (section == 0) {
                    return self.recentTopics.count;
                } else {
                    return self.allTopics.count;
                }
            } else {
                return self.allTopics.count;
            }
        }
    } else {
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.referType == DXReferTypeUser) {
        static NSString *identifier = @"referUser";
        DXReferViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[DXReferViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier referType:DXReferTypeUser];
        }
        if ([tableView isEqual:self.tableView]) {
            if (self.recentContacts.count) {
                if (indexPath.section == 0) {
                    DXUser *referUser = self.recentContacts[indexPath.row];
                    cell.referUser = referUser;
                } else {
                    DXReferUserWrapper *referUserWrapper = self.allContacts[indexPath.section -1];
                    DXUser *referUser = referUserWrapper.referUsers[indexPath.row];
                    cell.referUser = referUser;
                }
            } else {
                DXReferUserWrapper *referUserWrapper = self.allContacts[indexPath.section];
                DXUser *referUser = referUserWrapper.referUsers[indexPath.row];
                cell.referUser = referUser;
            }
        } else {
            DXUser *referUser = self.searchResults[indexPath.row];
            cell.referUser = referUser;
        }
        return cell;
    } else {
        static NSString *identifier = @"referTopic";
        DXReferViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[DXReferViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier referType:DXReferTypeTopic];
        }
        if ([tableView isEqual:self.tableView]) {
            if (self.recentTopics.count) {
                if (indexPath.section == 0) {
                    DXTopic *referTopic = self.recentTopics[indexPath.row];
                    cell.referTopic = referTopic;
                } else {
                    DXTopic *referTopic = self.allTopics[indexPath.row];
                    cell.referTopic = referTopic;
                }
            } else {
                DXTopic *referTopic = self.allTopics[indexPath.row];
                cell.referTopic = referTopic;
            }
        } else {
            DXTopic *referTopic = self.searchResults[indexPath.row];
            cell.referTopic = referTopic;
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        if (self.referType == DXReferTypeUser) {
            if (self.recentContacts.count) {
                if (section == 0) {
                    return [self recentTitleViewWithTitle:@"最近联系人"];
                } else {
                    DXReferUserWrapper *referUserWrapper = self.allContacts[section -1];
                    return [self normalTitleViewWithTitle:referUserWrapper.indexID];
                }
            } else {
                DXReferUserWrapper *referUserWrapper = self.allContacts[section];
                return [self normalTitleViewWithTitle:referUserWrapper.indexID];
            }
        } else {
            if (self.recentTopics.count) {
                if (section == 0) {
                    return [self recentTitleViewWithTitle:@"最近参与的话题"];
                } else {
                    return [self normalTitleViewWithTitle:@"全部话题"];
                }
            } else {
                return [self normalTitleViewWithTitle:@"全部话题"];
            }
        }
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        if (self.recentContacts.count || self.recentTopics.count) {
            if (section == 0) {
                return DXRealValue(103/3.0);
            } else {
                return DXRealValue(23);
            }
        } else {
            return DXRealValue(23);
        }
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DXRealValue(54);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DXContentPiece *piece = [[DXContentPiece alloc] init];
    piece.type = DXContentPieceTypeRefer;
    if (self.referType == DXReferTypeUser) {
        DXUser *referUser;
        if ([tableView isEqual:self.tableView]) {
            if (self.recentContacts.count) {
                if (indexPath.section == 0) {
                    referUser = self.recentContacts[indexPath.row];
                } else {
                    DXReferUserWrapper *referUserWrapper = self.allContacts[indexPath.section - 1];
                    referUser = referUserWrapper.referUsers[indexPath.row];
                }
            } else {
                DXReferUserWrapper *referUserWrapper = self.allContacts[indexPath.section];
                referUser = referUserWrapper.referUsers[indexPath.row];
            }
        } else {
            referUser = self.searchResults[indexPath.row];
        }
        piece.refer_type = DXReferTypeUser;
        piece.refer_id = referUser.uid;
        piece.content = [NSString stringWithFormat:@"@%@", referUser.nick];
    } else {
        DXTopic *referTopic;
        if ([tableView isEqual:self.tableView]) {
            if (self.recentTopics.count) {
                if (indexPath.section == 0) {
                    referTopic = self.recentTopics[indexPath.row];
                } else {
                    referTopic = self.allTopics[indexPath.row];
                }
            } else {
                referTopic = self.allTopics[indexPath.row];
            }
        } else {
            referTopic = self.searchResults[indexPath.row];
        }
        piece.refer_type = DXReferTypeTopic;
        piece.refer_id = referTopic.topic_id;
        piece.content = [NSString stringWithFormat:@"#%@#", referTopic.topic];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(referViewController:didSelectedReferWithContentPiece:)]) {
        [self.delegate referViewController:self didSelectedReferWithContentPiece:piece];
    }
    
    [self handleCancelBtnDidClick];
}

#pragma mark - UISearchDisplayController delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString];
    
    return YES;
}

#pragma mark - 

- (void)filterContentForSearchText:(NSString*)searchText {
    NSMutableArray *tempArray = [NSMutableArray array];
    if (self.referType == DXReferTypeUser) {
        for (DXReferUserWrapper *referUserWrapper in self.allContacts) {
            for (DXUser *referUser in referUserWrapper.referUsers) {
                if ([referUser.nick containsString:searchText]) {
                    [tempArray addObject:referUser];
                }
            }
        }
    } else {
        for (DXTopic *referTopic in self.allTopics) {
            if ([referTopic.topic containsString:searchText]) {
                [tempArray addObject:referTopic];
            }
        }
    }
    self.searchResults = [tempArray copy];
}

#pragma mark - 点击按钮执行的方法

- (void)handleCancelBtnDidClick {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(referViewControllerDidDismissed)]) {
            [self.delegate referViewControllerDidDismissed];
        }
    }];
}

#pragma mark - header view

- (UIView *)recentTitleViewWithTitle:(NSString *)title {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXRealValue(103/3.0))];
    titleView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = DXRGBColor(143, 143, 143);
    titleLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(40/3.0)];
    [titleLabel sizeToFit];
    titleLabel.x = DXRealValue(13);
    titleLabel.centerY = titleView.height * 0.5;
    [titleView addSubview:titleLabel];
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(143, 143, 143);
    separateView.size = CGSizeMake(titleView.width, 0.5);
    separateView.x = 0;
    separateView.y = titleView.height - separateView.height;
    [titleView addSubview:separateView];
    return titleView;
}

- (UIView *)normalTitleViewWithTitle:(NSString *)title {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXRealValue(23))];
    titleView.backgroundColor = DXRGBColor(239, 239, 239);
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = DXRGBColor(143, 143, 143);
    titleLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(40/3.0)];
    [titleLabel sizeToFit];
    titleLabel.x = DXRealValue(13);
    titleLabel.centerY = titleView.height * 0.5;
    [titleView addSubview:titleLabel];
    return titleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
