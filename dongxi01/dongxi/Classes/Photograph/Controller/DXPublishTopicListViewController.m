//
//  DXPublishTopicListViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishTopicListViewController.h"
#import "DXDongXiApi.h"
#import "DXPublishTopicTableViewCell.h"

@interface DXPublishTopicListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView * tableView;
@property (nonatomic) DXDongXiApi * api;
@property (nonatomic) NSArray * topics;
@property (nonatomic) UIImageView * selectedImageView;
@property (nonatomic) NSIndexPath * selectedTopicIndexPath;

@end

@implementation DXPublishTopicListViewController

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"话题";
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.api = [DXDongXiApi api];
    
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    [doneButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:DXCommonBoldFontName size:16],
                                         NSForegroundColorAttributeName: DXCommonColor
                                         }
                              forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight-DXNavBarHeight-20)];
    self.tableView.separatorColor = DXRGBColor(221, 221, 221);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self.tableView registerClass:[DXPublishTopicTableViewCell class] forCellReuseIdentifier:@"DXPublishTopicTableViewCell"];
    self.tableView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
        
    __weak DXPublishTopicListViewController * weakSelf = self;
    [self.api getTopics:^(NSArray *topics, NSError *error) {
        weakSelf.topics = topics;
        [weakSelf.tableView reloadData];
        
        for (int i = 0; i < topics.count; i++) {
            DXTopic * topic = [topics objectAtIndex:i];
            if ([topic.topic_id isEqualToString:weakSelf.topicID]) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [weakSelf.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                weakSelf.selectedTopicIndexPath = indexPath;
                break;
            }
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DXPublishTopicTableViewCell" forIndexPath:indexPath];

    DXTopic * topic = [self.topics objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"#%@#", topic.topic];
    
    return cell;
}


#pragma mark - <UITableViewDelegate>


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DXRealValue(162.0/3);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedTopicIndexPath &&
        indexPath.section == self.selectedTopicIndexPath.section &&
        indexPath.row == self.selectedTopicIndexPath.row) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedTopicIndexPath = nil;
    } else {
        self.selectedTopicIndexPath = indexPath;
    }
}

#pragma mark - Button Actions

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectTopic:andTitle:)]) {
        if (!self.selectedTopicIndexPath) {
            [self.delegate userDidSelectTopic:nil andTitle:nil];
        } else {
            DXTopic * topic = [self.topics objectAtIndex:self.selectedTopicIndexPath.row];
            [self.delegate userDidSelectTopic:topic.topic_id andTitle:topic.topic];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
