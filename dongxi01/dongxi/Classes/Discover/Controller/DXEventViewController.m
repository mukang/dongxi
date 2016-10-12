//
//  DXEventViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXEventViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DXDongXiApi.h"
#import "DXExtendButton.h"
#import "DXDashTitleCollectionCell.h"
#import "DXActivityHeaderCell.h"
#import "DXActivityDetailCell.h"
#import "DXActivityWebCell.h"
#import "DXActivityWishAttendCell.h"
#import "DXActivityAttendCommentHeaderCell.h"
#import "DXActivityAttendCommentCell.h"
#import "DXActivityMyCommentCell.h"
#import "DXNoneDataCollectionViewCell.h"

#import "DXEventWishListViewController.h"
#import "DXEventCommentViewController.h"
#import "DXProfileViewController.h"
#import "DXMainNavigationController.h"
#import "DXLoginViewController.h"

#import <MJRefresh.h>

#define Event_Collection_Section_Header     0
#define Event_Collection_Section_Detail     1
#define Event_Collection_Section_Text       2
#define Event_Collection_Section_Wish       3
#define Event_Collection_Section_Comment    4


@interface DXEventViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DXActivityWishAttendCellDelegate, DXActivityAttendCommentCellDelegate, DXActivityWebCellDelegate>

@property (nonatomic) UICollectionView * collectionView;
@property (nonatomic) DXExtendButton * wishButton;
@property (nonatomic) DXExtendButton * wentButton;
@property (nonatomic) DXExtendButton * wentButtonLarge;

@property (nonatomic, strong) DXActivity * activity;

@property (nonatomic) CGFloat heightOfWebCell;
@property (nonatomic) BOOL showFullDetailText;

@property (nonatomic) DXActivityWebCell * testWebCell;
@property (nonatomic, weak) DXActivityHeaderCell * headerCell;

@property (nonatomic) DXDongXiApi * api;

@property (nonatomic, assign) BOOL firstTimeLoaded;
@property (nonatomic, copy) NSString * errorDescription;

@end

@implementation DXEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_ActivityDetail;
    
    self.view.backgroundColor = DXRGBColor(222, 222, 222);
    self.title = @"活动";
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];
    self.api = [DXDongXiApi api];
    
    [self setupSubviews];
    [self setupContraints];
    
    [self refreshPageByActvityID:self.activityID completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEventCommentNeedRefreshNotification:) name:DXEventCommentNeedRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidLoginNotification:) name:DXDongXiApiNotificationUserDidLogin object:nil];
    
    self.collectionView.mj_header = [DXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshPage)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshPage {
    typeof(self) __weak weakSelf = self;
    [self refreshPageByActvityID:self.activityID completion:^(BOOL success) {
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

- (void)refreshPageByActvityID:(NSString *)activityID completion:(void(^)(BOOL))completion {
    if (activityID) {
        __weak DXEventViewController * weakSelf = self;
        [self.api getActivityByID:activityID result:^(DXActivity *activity, NSError *error) {
            weakSelf.firstTimeLoaded = YES;
            
            if (activity) {
                weakSelf.activity = activity;
                [weakSelf refreshBottomButtons];
                
                [weakSelf estimateHeightOfWebCellWithInfo:activity completion:^(CGFloat height) {
                    weakSelf.heightOfWebCell = height;
                    if (weakSelf.showFullDetailText) {
                        [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:Event_Collection_Section_Text]];
                    }
                }];
            } else {
                if (weakSelf.activity) {
                    NSString * reason = error.localizedDescription ? error.localizedDescription : @"请重试";
                    weakSelf.errorDescription = [NSString stringWithFormat:@"活动刷新失败，%@", reason];
                    
                    DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                    [alert setMessage:weakSelf.errorDescription];
                    [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleCancel handler:nil]];
                    [alert showInController:weakSelf animated:YES completion:nil];
                } else {
                    NSString * reason = error.localizedDescription ? error.localizedDescription : @"请重试";
                    weakSelf.errorDescription = [NSString stringWithFormat:@"活动加载失败，%@", reason];
                }
            }
            
            [weakSelf.collectionView reloadData];
            
            if (completion) {
                completion(activity != nil);
            }
        }];
    }
}

- (void)updateCurrentUserAsWishUser {
    DXActivityWantUserInfo * wantUserInfo = [[DXActivityWantUserInfo alloc] init];
    wantUserInfo.uid = self.api.currentUserSession.uid;
    wantUserInfo.avatar = self.api.currentUserSession.avatar;
    wantUserInfo.nick = self.api.currentUserSession.nick;
    wantUserInfo.location = self.api.currentUserSession.location;
    wantUserInfo.verified = self.api.currentUserSession.verified;
    
    NSMutableArray * wishUsers = [self.activity.want mutableCopy];
    [wishUsers addObject:wantUserInfo];
    self.activity.want = wishUsers;
    self.activity.is_want = YES;

    self.headerCell.numberLabel.text = [NSString stringWithFormat:@"%ld人去过  %lu人想去", (long)self.activity.joined, (unsigned long)self.activity.want.count];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:Event_Collection_Section_Wish]];
}

- (void)refreshBottomButtons {
    [self updateBottomButtonsStatus];
    [self updateCollectionViewInsets];
}

- (void)estimateHeightOfWebCellWithInfo:(DXActivity *)activity completion:(void(^)(CGFloat))completion {
    self.testWebCell = [[DXActivityWebCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight)];
    self.testWebCell.showFullText = YES;
    self.testWebCell.introText = activity.detail.intro;
    self.testWebCell.fullTextHtml = activity.detail.txt;
    [self.testWebCell setNeedsLayout];
    [self.testWebCell layoutIfNeeded];
    __weak DXActivityWebCell * weakCell = self.testWebCell;
    [self.testWebCell afterWebContentLoaded:^{
        CGFloat heightOfWebCell = [weakCell getFittingHeight];
        if (completion) {
            completion(heightOfWebCell);
        }
    }];
}

- (void)setupSubviews {
    UICollectionViewFlowLayout * collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:collectionViewLayout];
    self.collectionView.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[DXDashTitleCollectionCell class] forCellWithReuseIdentifier:@"DXDashTitleCollectionCell"];
    [self.collectionView registerClass:[DXActivityHeaderCell class] forCellWithReuseIdentifier:@"DXActivityHeaderCell"];
    [self.collectionView registerClass:[DXActivityDetailCell class] forCellWithReuseIdentifier:@"DXActivityDetailCell"];
    [self.collectionView registerClass:[DXActivityWebCell class] forCellWithReuseIdentifier:@"DXActivityWebCell"];
    [self.collectionView registerClass:[DXActivityWishAttendCell class] forCellWithReuseIdentifier:@"DXActivityWishAttendCell"];
    [self.collectionView registerClass:[DXActivityAttendCommentHeaderCell class] forCellWithReuseIdentifier:@"DXActivityAttendCommentHeaderCell"];
    [self.collectionView registerClass:[DXActivityAttendCommentCell class] forCellWithReuseIdentifier:@"DXActivityAttendCommentCell"];
    [self.collectionView registerClass:[DXActivityMyCommentCell class] forCellWithReuseIdentifier:@"DXActivityMyCommentCell"];
    [self.collectionView registerClass:[DXDashTitleCollectionCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DXDashTitleCollectionCell"];
    [self.collectionView registerClass:[DXNoneDataCollectionViewCell class] forCellWithReuseIdentifier:@"DXNoneDataCollectionViewCell"];
    
    [self.view addSubview:self.collectionView];
    
    self.wentButton = [[DXExtendButton alloc] initWithFrame:CGRectZero];
    self.wentButton.hidden = YES;
    [self.wentButton setImage:[UIImage imageNamed:@"button_event_went_normal"] forState:UIControlStateNormal];
    [self.wentButton setImage:[UIImage imageNamed:@"button_event_went_click"] forState:UIControlStateHighlighted];
    [self.wentButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.wentButton.hitTestSlop = UIEdgeInsetsMake(-10, 0, -10, 0);
    [self.view addSubview:self.wentButton];
    
    [self.wentButton addTarget:self action:@selector(wentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.wishButton = [[DXExtendButton alloc] initWithFrame:CGRectZero];
    self.wishButton.hidden = YES;
    [self.wishButton setImage:[UIImage imageNamed:@"button_event_want_normal"] forState:UIControlStateNormal];
    [self.wishButton setImage:[UIImage imageNamed:@"button_event_want_click"] forState:UIControlStateHighlighted];
    [self.wishButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.wishButton.hitTestSlop = UIEdgeInsetsMake(-10, 0, -10, 0);
    [self.view addSubview:self.wishButton];
    
    [self.wishButton addTarget:self action:@selector(wishButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.wentButtonLarge = [[DXExtendButton alloc] initWithFrame:CGRectZero];
    self.wentButtonLarge.backgroundColor = DXRGBColor(185, 235, 249);
    self.wentButtonLarge.hidden = YES;
    self.wentButtonLarge.titleLabel.font = [DXFont dxDefaultFontWithSize:18];
    [self.wentButtonLarge setTitle:@"我去过" forState:UIControlStateNormal];
    [self.wentButtonLarge setTitleColor:DXRGBColor(62, 180, 187) forState:UIControlStateNormal];
    [self.wentButtonLarge setTitleColor:DXRGBColor(50, 144, 150) forState:UIControlStateHighlighted];
    [self.wentButtonLarge setBackgroundImage:[UIImage imageNamed:@"event_went_button_normal_pixel"] forState:UIControlStateNormal];
    [self.wentButtonLarge setBackgroundImage:[UIImage imageNamed:@"event_went_button_click_pixel"] forState:UIControlStateHighlighted];
    [self.wentButtonLarge setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.wentButtonLarge];
    
    [self.wentButtonLarge addTarget:self action:@selector(wentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupContraints {
    NSDictionary * views = @{
                             @"collectionView"  : self.collectionView,
                             @"wishButton"      : self.wishButton,
                             @"wentButton"      : self.wentButton,
                             @"wentButtonLarge" : self.wentButtonLarge
                             };
    NSArray * visualFormats = @[
                                @"H:|[collectionView]|",
                                @"H:|[wentButton][wishButton(wentButton)]|",
                                @"H:|[wentButtonLarge]|",
                                @"V:|[collectionView]|",
                                @"V:[wishButton]|",
                                @"V:[wentButton]|",
                                @"V:[wentButtonLarge]|"
                                ];
    for (NSString * vf in visualFormats) {
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:views];
        [self.view addConstraints:constraints];
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wentButtonLarge
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.wentButton
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wentButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.wentButton
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:150.0/621.0
                                                          constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wishButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.wishButton
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:150.0/621.0
                                                           constant:0]];
}

- (void)updateCollectionViewInsets {
    if (self.activity) {
        if (self.activity.is_join) {
            UIEdgeInsets inset = self.collectionView.contentInset;
            inset.bottom = 0;
            self.collectionView.contentInset = inset;
            
            inset = self.collectionView.scrollIndicatorInsets;
            inset.bottom = 0;
            self.collectionView.scrollIndicatorInsets = inset;
        } else {
            UIEdgeInsets inset = self.collectionView.contentInset;
            inset.bottom = CGRectGetHeight(self.wentButton.bounds);
            self.collectionView.contentInset = inset;
            
            inset = self.collectionView.scrollIndicatorInsets;
            inset.bottom = CGRectGetHeight(self.wentButton.bounds);
            self.collectionView.scrollIndicatorInsets = inset;
        }
    }
}

- (void)updateBottomButtonsStatus {
    if (self.activity) {
        if (self.activity.is_join) {
            self.wentButton.hidden = YES;
            self.wishButton.hidden = YES;
            self.wentButtonLarge.hidden = YES;
        } else {
            if (self.activity.is_want) {
                self.wentButtonLarge.hidden = NO;
                self.wentButton.hidden = YES;
                self.wishButton.hidden = YES;
            } else {
                self.wentButton.hidden = NO;
                self.wishButton.hidden = NO;
                self.wentButtonLarge.hidden = YES;
            }
        }
    }
}

#pragma mark - Cell Config

- (void)configHeaderCell:(UICollectionViewCell **)cell atIndexPath:(NSIndexPath *)indexPath {
    DXActivityHeaderCell * headerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityHeaderCell" forIndexPath:indexPath];
    [headerCell.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.activity.cover] placeholderImage:nil options:SDWebImageRetryFailed];
    headerCell.nameLabel.text = self.activity.activity;
    headerCell.numberLabel.text = [NSString stringWithFormat:@"%ld人去过  %lu人想去", (long)self.activity.joined, (unsigned long)self.activity.want.count];
    headerCell.stars = self.activity.star;
    *cell = headerCell;
}

- (void)configDetailCell:(UICollectionViewCell **)cell atIndexPath:(NSIndexPath *)indexPath {
    DXActivityDetailCell * detailCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityDetailCell" forIndexPath:indexPath];
    detailCell.timeLabel.text = self.activity.detail.time ? self.activity.detail.time : @"";
    detailCell.placeLabel.text = self.activity.detail.place ? self.activity.detail.place : @"";
    detailCell.addressLabel.text = self.activity.detail.address ? self.activity.detail.address : @"";
    detailCell.priceLabel.text = self.activity.detail.price ? self.activity.detail.price : @"";
    *cell = detailCell;
}

- (void)configTextCell:(UICollectionViewCell **)cell atIndexPath:(NSIndexPath *)indexPath {
    DXActivityWebCell * webCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityWebCell" forIndexPath:indexPath];
    webCell.showFullText = self.showFullDetailText;
    webCell.introText = self.activity.detail.intro;
    if (self.showFullDetailText) {
        webCell.fullTextHtml = self.activity.detail.txt;
    }
    webCell.delegate = self;
    *cell = webCell;
}

- (void)configWishCell:(UICollectionViewCell **)cell atIndexPath:(NSIndexPath *)indexPath {
    DXActivityWishAttendCell * wishAttendCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityWishAttendCell" forIndexPath:indexPath];
    wishAttendCell.delegate = self;
    
//    NSMutableArray * avatarURLs = [NSMutableArray array];
//    for (DXActivityWantUserInfo * wisherInfo in self.activity.want) {
//        [avatarURLs addObject:wisherInfo.avatar];
//    }
    
    wishAttendCell.wisherCount = self.activity.want.count;
    wishAttendCell.wisherAvatars = self.activity.want;
    
    *cell = wishAttendCell;
}

- (void)configCommentCell:(UICollectionViewCell **)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        DXActivityAttendCommentHeaderCell * commentHeaderCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityAttendCommentHeaderCell" forIndexPath:indexPath];
        commentHeaderCell.attendCount = self.activity.joined;
        commentHeaderCell.commentCount = self.activity.comment.count;
        *cell = commentHeaderCell;
        return;
    }
    
    if (indexPath.item == 1 && self.activity.is_join) {
        DXActivityMyCommentCell * myCommentCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityMyCommentCell" forIndexPath:indexPath];
        myCommentCell.stars = self.activity.my_star;
        [myCommentCell.detailButton addTarget:self action:@selector(myCommentDetailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        *cell = myCommentCell;
        return;
    }
    
    DXActivityAttendCommentCell * attendCommentCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXActivityAttendCommentCell" forIndexPath:indexPath];
    attendCommentCell.delegate = self;
    
    DXActivityComment * comment = [self.activity.comment objectAtIndex:indexPath.item - (self.activity.is_join ? 2 : 1)];
    
    attendCommentCell.nickLabel.text = comment.nick;
    attendCommentCell.timeLabel.text = comment.formattedTime;
    attendCommentCell.commentLabel.text = comment.txt;
    attendCommentCell.stars = comment.star;
    [attendCommentCell.avatarView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.avatar] placeholderImage:nil options:SDWebImageRetryFailed];
    attendCommentCell.avatarView.verified = comment.verified;
    attendCommentCell.avatarView.certificationIconSize = DXCertificationIconSizeMedium;
    
    *cell = attendCommentCell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.activity) {
        return 5;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.activity == nil) {
        return 1;
    }
    
    if (section == Event_Collection_Section_Comment) {
        return self.activity.comment.count + (self.activity.is_join ? 2 : 1);
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activity == nil) {
        DXNoneDataCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXNoneDataCollectionViewCell" forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    }
    
    UICollectionViewCell * cell = nil;
    switch (indexPath.section) {
        case Event_Collection_Section_Header:
            [self configHeaderCell:&cell atIndexPath:indexPath];
            self.headerCell = (DXActivityHeaderCell *)cell;
            break;
        case Event_Collection_Section_Detail:
            [self configDetailCell:&cell atIndexPath:indexPath];
            break;
        case Event_Collection_Section_Text:
            [self configTextCell:&cell atIndexPath:indexPath];
            break;
        case Event_Collection_Section_Wish:
            [self configWishCell:&cell atIndexPath:indexPath];
            break;
        case Event_Collection_Section_Comment:
            [self configCommentCell:&cell atIndexPath:indexPath];
            break;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (self.activity == nil) {
        return nil;
    }
    
    
    UICollectionReusableView * reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section == Event_Collection_Section_Detail) {
            DXDashTitleCollectionCell * titleCell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"DXDashTitleCollectionCell" forIndexPath:indexPath];
            titleCell.titleView.textLabel.text = @"活动信息";
            reusableView = titleCell;
        } else if (indexPath.section == Event_Collection_Section_Text) {
            DXDashTitleCollectionCell * titleCell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"DXDashTitleCollectionCell" forIndexPath:indexPath];
            titleCell.titleView.textLabel.text = @"活动描述";
            reusableView = titleCell;
        } else {
            reusableView = nil;
        }
    }
    
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activity == nil) {
        return CGSizeMake(DXScreenWidth, DXRealValue(120));
    }
    
    
    CGSize itemSize = CGSizeZero;
    switch (indexPath.section) {
        case Event_Collection_Section_Header: {
            DXActivityHeaderCell * headerCell = [[DXActivityHeaderCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight)];
            headerCell.nameLabel.text = self.activity.activity;
            headerCell.numberLabel.text = [NSString stringWithFormat:@"%ld人去过  %lu人想去", (long)self.activity.joined, (unsigned long)self.activity.want.count];
            headerCell.stars = self.activity.star;
            [headerCell setNeedsLayout];
            [headerCell layoutIfNeeded];
            CGFloat cellHeight =  [headerCell.containerView systemLayoutSizeFittingSize:CGSizeMake(DXScreenWidth, 0)].height;
            itemSize = CGSizeMake(DXScreenWidth, ceilf(cellHeight));
        }
            break;
        case Event_Collection_Section_Detail: {
            DXActivityDetailCell * detailCell = [[DXActivityDetailCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight)];
            detailCell.timeLabel.text = self.activity.detail.time ? self.activity.detail.time : @"";
            detailCell.placeLabel.text = self.activity.detail.place ? self.activity.detail.place : @"";
            detailCell.addressLabel.text = self.activity.detail.address ? self.activity.detail.address : @"";
            detailCell.priceLabel.text = self.activity.detail.price ? self.activity.detail.price : @"";
            [detailCell setNeedsLayout];
            [detailCell layoutIfNeeded];
            CGFloat cellHeight = [detailCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            itemSize = CGSizeMake(DXScreenWidth, ceilf(cellHeight));
        }
            break;
        case Event_Collection_Section_Text: {
            if (self.showFullDetailText && self.heightOfWebCell) {
                itemSize = CGSizeMake(DXScreenWidth, self.heightOfWebCell);
            } else {
                DXActivityWebCell * webCell = [[DXActivityWebCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, DXScreenHeight)];
                webCell.introText = self.activity.detail.intro;
                [webCell setNeedsLayout];
                [webCell layoutIfNeeded];
                CGFloat cellHeight = [webCell getFittingHeight];
                itemSize = CGSizeMake(DXScreenWidth, ceilf(cellHeight));
            }
        }
            break;
        case Event_Collection_Section_Wish: {
            DXActivityWishAttendCell * wishAttendCell = [[DXActivityWishAttendCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenHeight, 0)];
            wishAttendCell.wisherCount = self.activity.want.count;
            [wishAttendCell setNeedsLayout];
            [wishAttendCell layoutIfNeeded];
            CGFloat height = [wishAttendCell.containerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            itemSize = CGSizeMake(DXScreenWidth, ceilf(height));
        }
            break;
        case Event_Collection_Section_Comment:
            if (indexPath.item == 0) {
                itemSize =  CGSizeMake(DXScreenWidth, ceilf(DXRealValue(50)));
                break;
            }
            
            if (indexPath.item == 1 && self.activity.is_join) {
                itemSize = CGSizeMake(DXScreenWidth, ceilf(DXRealValue(80)));
                break;
            }
            
            DXActivityAttendCommentCell * commentCell = [[DXActivityAttendCommentCell alloc] initWithFrame:CGRectMake(0, 0, DXScreenWidth, 0)];
            DXActivityComment * comment = [self.activity.comment objectAtIndex:indexPath.item - (self.activity.is_join ? 2 : 1)];
            commentCell.nickLabel.text = comment.nick;
            commentCell.timeLabel.text = comment.formattedTime;
            commentCell.commentLabel.text = comment.txt;
            
            [commentCell setNeedsLayout];
            [commentCell layoutIfNeeded];
            
            CGFloat cellHeight = [commentCell.containerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            itemSize = CGSizeMake(DXScreenWidth, ceilf(cellHeight));
            break;
    }
    return itemSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.activity == nil) {
        return CGSizeZero;
    }
    
    if (section == Event_Collection_Section_Detail || section == Event_Collection_Section_Text) {
        return CGSizeMake(DXScreenWidth, DXRealValue(43.3));
    } else {
        return CGSizeZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.activity == nil) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    if (section == Event_Collection_Section_Wish || section == Event_Collection_Section_Comment) {
        return UIEdgeInsetsMake(DXRealValue(20.0/3), 0, 0, 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activity == nil) {
        return NO;
    }
    
    BOOL shouldHighlight = YES;
    switch (indexPath.section) {
        case Event_Collection_Section_Header:
            shouldHighlight = NO;
            break;
        default:
            break;
    }
    return shouldHighlight;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activity == nil) {
        return;
    }
    
    switch (indexPath.section) {
        case Event_Collection_Section_Wish:
            [self wishAttendCell:nil didSelectMoreButton:nil];
            break;
        case Event_Collection_Section_Comment: {
            if (indexPath.item == 1 && self.activity.is_join) {
                [self myCommentDetailButtonTapped:nil];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - DXActivityWebCellDelegate

- (void)webCell:(DXActivityWebCell *)cell willShowFullText:(BOOL)showFullText {
    self.showFullDetailText = showFullText;
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        if (!showFullText) {
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        } else {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
}


#pragma mark - DXActivityWishAttendCellDelegate

- (void)wishAttendCell:(DXActivityWishAttendCell *)cell didSelectAvatarAtIndex:(NSUInteger)index {
    DXActivityWantUserInfo * userInfo = [self.activity.want objectAtIndex:index];
    DXProfileViewController * profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    profileVC.uid = userInfo.uid;
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)wishAttendCell:(DXActivityWishAttendCell *)cell didSelectMoreButton:(UIView *)sender {
    DXEventWishListViewController * eventWishListVC = [DXEventWishListViewController new];
    eventWishListVC.users = self.activity.want;
    [self.navigationController pushViewController:eventWishListVC animated:YES];
}

#pragma mark - DXActivityAttendCommentCellDelegate

- (void)userDidTapAvatarInCell:(DXActivityAttendCommentCell *)cell {
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    DXActivityComment * comment = [self.activity.comment objectAtIndex:indexPath.item - (self.activity.is_join ? 2 : 1)];
    
    DXProfileViewController * profileVC = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
    profileVC.uid = comment.uid;
    [self.navigationController pushViewController:profileVC animated:YES];
}


#pragma mark - Internal Actions

- (IBAction)myCommentDetailButtonTapped:(UIButton *)sender {
    if (![self.api needLogin]) {
        DXEventCommentViewController * commentVC = [DXEventCommentViewController new];
        commentVC.activity = self.activity;
        [self.navigationController pushViewController:commentVC animated:YES];
    } else {
        DXMainNavigationController * navigationController = (DXMainNavigationController *)self.navigationController;
        [navigationController presentLoginViewIfNeeded];
    }
}

- (IBAction)wishButtonTapped:(UIButton *)sender {
    if (![self.api needLogin]) {
        __weak DXEventViewController * weakSelf = self;
        [self.api wantToJoinActivity:self.activity.activity_id result:^(BOOL success, NSError *error) {
            if (success) {
                [weakSelf updateCurrentUserAsWishUser];
                [weakSelf refreshBottomButtons];
            } else {
                NSString * reason = error.localizedDescription ? error.localizedDescription : @"请重试";
                NSString * message = [NSString stringWithFormat:@"操作失败，%@", reason];
                DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
                [alert setMessage:message];
                [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"确定" style:DXCompatibleAlertActionStyleCancel handler:nil]];
                [alert showInController:weakSelf animated:YES completion:nil];
            }
        }];
    } else {
        typeof(self) __weak weakSelf = self;
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可标记你想去的活动，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
    }
}

- (IBAction)wentButtonTapped:(UIButton *)sender {
    if (![self.api needLogin]) {
        DXEventCommentViewController * commentVC = [DXEventCommentViewController new];
        commentVC.activity = self.activity;
        [self.navigationController pushViewController:commentVC animated:YES];
    } else {
        typeof(self) __weak weakSelf = self;
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可标记你去过的活动，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
    }
}

- (void)handleEventCommentNeedRefreshNotification:(NSNotification *)noti {
    [self refreshCommentAndScrollToBottom];
}

- (void)refreshCommentAndScrollToBottom {
    __weak DXEventViewController * weakSelf = self;
    [self refreshPageByActvityID:self.activityID completion:^(BOOL success) {
        if (success) {
            UICollectionView * collectionView = weakSelf.collectionView;
            [collectionView setNeedsLayout];
            [collectionView layoutIfNeeded];
            CGPoint bottomOffset = CGPointMake(0, collectionView.contentSize.height - collectionView.bounds.size.height + collectionView.contentInset.bottom);
            [weakSelf.collectionView setContentOffset:bottomOffset animated:NO];
        }
    }];
}

- (void)onUserDidLoginNotification:(NSNotification *)noti {
    [self refreshPageByActvityID:self.activityID completion:nil];
}

@end
