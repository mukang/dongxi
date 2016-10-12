//
//  DXTagViewController.m
//  dongxi
//
//  Created by 穆康 on 16/1/8.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagViewController.h"

#import "DXTagCollectionViewFlowLayout.h"

#import "DXNoneDataCollectionViewCell.h"
#import "DXCollectedTagCell.h"
#import "DXNormalTagCell.h"

#import "DXCollectedTagsHeaderView.h"
#import "DXAllTagsHeaderView.h"

#import "UIBarButtonItem+Extension.h"

static NSString *const NoneDataCollectionViewCellReuseID = @"NoneDataCollectionViewCell";

static NSString *const CollectedTagCellReuseID = @"CollectedTagCell";
static NSString *const CollectedTagsHeaderReuseID = @"CollectedTagsHeader";

static NSString *const NormalTagCellReuseID = @"NormalTagCell";
static NSString *const AllTagsHeaderReuseID = @"AllTagsHeader";

@interface DXTagViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DXCollectedTagCellDelegate, DXNormalTagCellDelegate>
{
    __weak DXTagViewController *weakSelf;
}

@property (nonatomic, weak) UICollectionView *collectionView;
/** 加载数据错误描述 */
@property (nonatomic, copy) NSString * errorDescription;
/** 关注的Tag数组 */
@property (nonatomic, strong) NSMutableArray *collectedTags;
/** 全部的Tag数组 */
@property (nonatomic, strong) NSMutableArray *allTags;
/** 原始的关注Tag数组 */
@property (nonatomic, strong) NSArray *originalTags;
/** 新关注的TagID的数组 */
@property (nonatomic, strong) NSMutableArray *createTagIDs;
/** 新取消关注的TagID的数组 */
@property (nonatomic, strong) NSMutableArray *deleteTagIDs;

@property (nonatomic, assign) BOOL originInteractivePopGestureEnabled;

@end

@implementation DXTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_SettingsTag;
    
    [self setupNav];
    [self setupContent];
    [self loadNetData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
    self.originInteractivePopGestureEnabled = navigationController.enableInteractivePopGesture;
    navigationController.enableInteractivePopGesture = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DXMainNavigationController * navigationController = (DXMainNavigationController * )self.navigationController;
    navigationController.enableInteractivePopGesture = self.originInteractivePopGestureEnabled;
}

- (void)setupNav {
    
    self.title = @"标签";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"button_back_navigation" target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    
    if (self.isFromAlert) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"GrayPixel"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = DXCommonColor;
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{
                                                                        NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                        NSForegroundColorAttributeName : DXCommonColor
                                                                        };
    }
}

- (void)setupContent {
    
    DXTagCollectionViewFlowLayout *layout = [[DXTagCollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[DXNoneDataCollectionViewCell class] forCellWithReuseIdentifier:NoneDataCollectionViewCellReuseID];
    [collectionView registerClass:[DXCollectedTagCell class] forCellWithReuseIdentifier:CollectedTagCellReuseID];
    [collectionView registerClass:[DXNormalTagCell class] forCellWithReuseIdentifier:NormalTagCellReuseID];
    [collectionView registerClass:[DXCollectedTagsHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectedTagsHeaderReuseID];
    [collectionView registerClass:[DXAllTagsHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:AllTagsHeaderReuseID];
}

- (void)loadNetData {
    
    [[DXDongXiApi api] getTagWrapper:^(DXTagWrapper *tagWrapper, NSError *error) {
        if (tagWrapper.collected.count) {
            [weakSelf.collectedTags removeAllObjects];
            [weakSelf.collectedTags addObjectsFromArray:tagWrapper.collected];
            weakSelf.originalTags = [weakSelf.collectedTags copy];
        }
        if (tagWrapper.all.count) {
            [weakSelf.allTags removeAllObjects];
            [weakSelf.allTags addObjectsFromArray:tagWrapper.all];
        } else {
            NSString *desc = error.localizedDescription ? error.localizedDescription : @"请重试";
            self.errorDescription = [NSString stringWithFormat:@"无法加载，%@", desc];
            [weakSelf.collectionView reloadData];
        }
        [weakSelf.collectionView reloadData];
    }];
}

#pragma mark - data source and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.allTags.count == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.allTags.count == 0) {
        return 1;
    }
    if (section == 0) {
        return self.collectedTags.count;
    } else {
        return self.allTags.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.allTags.count == 0) {
        DXNoneDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NoneDataCollectionViewCellReuseID forIndexPath:indexPath];
        cell.text = self.errorDescription;
        return cell;
    }
    
    if (indexPath.section == 0) {
        DXCollectedTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectedTagCellReuseID forIndexPath:indexPath];
        cell.collectedTag = self.collectedTags[indexPath.item];
        cell.delegate = self;
        return cell;
    } else {
        DXNormalTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NormalTagCellReuseID forIndexPath:indexPath];
        cell.normalTag = self.allTags[indexPath.item];
        cell.delegate = self;
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.allTags.count == 0) {
        return nil;
    }
    
    if (indexPath.section == 0) {
        DXCollectedTagsHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectedTagsHeaderReuseID forIndexPath:indexPath];
        return headerView;
    } else {
        DXAllTagsHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:AllTagsHeaderReuseID forIndexPath:indexPath];
        return headerView;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.allTags.count == 0) {
        return CGSizeMake(DXScreenWidth, DXRealValue(120));
    }
    
    CGFloat itemHeight = DXRealValue(34);
    CGFloat itemWidth = 0;
    if (indexPath.section == 0) {
        itemWidth = [DXCollectedTagCell collectionView:collectionView widthForItemAtIndexPath:indexPath withCollectedTag:self.collectedTags[indexPath.item]];
    } else {
        itemWidth = [DXNormalTagCell collectionView:collectionView widthForItemAtIndexPath:indexPath withNormalTag:self.allTags[indexPath.item]];
    }
    return CGSizeMake(roundf(itemWidth), roundf(itemHeight));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (self.allTags.count == 0) {
        return CGSizeZero;
    }
    
    CGFloat headerWidth = DXScreenWidth;
    CGFloat headerHeight = 0;
    if (section == 0) {
        headerHeight = DXRealValue(33);
    } else {
        headerHeight = DXRealValue(30);
    }
    return CGSizeMake(headerWidth, headerHeight);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if (self.allTags.count == 0) {
        return UIEdgeInsetsZero;
    }
    
    if (section == 0) {
        CGFloat top = DXRealValue(9);
        CGFloat left = DXRealValue(40/3);
        CGFloat bottom = DXRealValue(49/3);
        CGFloat right = left;
        return UIEdgeInsetsMake(top, left, bottom, right);
    } else {
        CGFloat top = DXRealValue(20);
        CGFloat left = DXRealValue(40/3);
        CGFloat bottom = top;
        CGFloat right = left;
        return UIEdgeInsetsMake(top, left, bottom, right);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    if (section == 0) {
        return DXRealValue(8);
    } else {
        return DXRealValue(12);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    if (section == 0) {
        return DXRealValue(11);
    } else {
        return DXRealValue(15);
    }
}


#pragma mark - DXCollectedTagCellDelegate

- (void)collectedTagCell:(DXCollectedTagCell *)cell didClickDeleteBtnWithCollectedTag:(DXTag *)collectedTag {
    
    [self unCollectedWithDongxiTag:collectedTag];
}

#pragma mark - DXNormalTagCellDelegate

- (void)normalTagCell:(DXNormalTagCell *)cell didTapTagWitNormalTag:(DXTag *)normalTag {
    
    if (normalTag.status == 0) { // 未关注
        [self collectedWithDongxiTag:normalTag];
    } else {
        [self unCollectedWithDongxiTag:normalTag];
    }
}

#pragma mark - 关注或取消关注某个标签

/**
 *  关注了某个标签
 */
- (void)collectedWithDongxiTag:(DXTag *)dongxiTag {
    
    dongxiTag.status = 1;
    [self.collectedTags addObject:dongxiTag];
    NSIndexPath *collectedIndexPath = [NSIndexPath indexPathForItem:self.collectedTags.count-1 inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[collectedIndexPath]];
    for (int i=0; i<self.allTags.count; i++) {
        DXTag *normalTag = self.allTags[i];
        if ([dongxiTag.ID isEqualToString:normalTag.ID]) {
            NSIndexPath *normalIndexPath = [NSIndexPath indexPathForItem:i inSection:1];
            [UIView performWithoutAnimation:^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[normalIndexPath]];
            }];
            break;
        }
    }
}

/**
 *  取消关注了某个标签
 */
- (void)unCollectedWithDongxiTag:(DXTag *)dongxiTag {
    
    for (int i=0; i<self.collectedTags.count; i++) {
        DXTag *collectedTag = self.collectedTags[i];
        if ([dongxiTag.ID isEqualToString:collectedTag.ID]) {
            [self.collectedTags removeObjectAtIndex:i];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
        }
    }
    for (int i=0; i<self.allTags.count; i++) {
        DXTag *normalTag = self.allTags[i];
        if ([dongxiTag.ID isEqualToString:normalTag.ID]) {
            normalTag.status = 0;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:1];
            [UIView performWithoutAnimation:^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
    }
}

#pragma mark - 返回

- (void)back {
    
    [self checkCreateTagsAndDeleteTags];
    
    if (!self.createTagIDs.count && !self.deleteTagIDs.count) {
        if (self.isFromAlert) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self submitConfirm];
    }
}

#pragma mark - 保存

- (void)save {
    
    [self checkCreateTagsAndDeleteTags];
    
    if (!self.createTagIDs.count && !self.deleteTagIDs.count) {
        if (self.isFromAlert) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self submit];
    }
}

#pragma mark - 检查增加和删除的标签

- (void)checkCreateTagsAndDeleteTags {
    
    BOOL isContainCollectedTag = NO;
    for (DXTag *collectedTag in self.collectedTags) {
        isContainCollectedTag = NO;
        for (DXTag *originTag in self.originalTags) {
            if ([originTag.ID isEqualToString:collectedTag.ID]) {
                isContainCollectedTag = YES;
                break;
            }
        }
        if (isContainCollectedTag == NO) {
            [self.createTagIDs addObject:collectedTag.ID];
        }
    }
    BOOL isContainOriginTag = NO;
    for (DXTag *originTag in self.originalTags) {
        isContainOriginTag = NO;
        for (DXTag *collectedTag in self.collectedTags) {
            if ([collectedTag.ID isEqualToString:originTag.ID]) {
                isContainOriginTag = YES;
                break;
            }
        }
        if (isContainOriginTag == NO) {
            [self.deleteTagIDs addObject:originTag.ID];
        }
    }
}

#pragma mark - 提交确认

- (void)submitConfirm {

    DXCompatibleAlert *confirm = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleActionSheet];
    [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"保存修改" style:DXCompatibleAlertActionStyleDestructive handler:^(DXCompatibleAlertAction *action) {
        [weakSelf submit];
    }]];
    [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"不保存" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    [confirm addAction:[DXCompatibleAlertAction actionWithTitle:@"取消" style:DXCompatibleAlertActionStyleCancel handler:nil]];
    [confirm showInController:self animated:YES completion:nil];
}

- (void)submit {
    
    DXScreenNotice * screenNotice = [[DXScreenNotice alloc] initWithMessage:@"正在保存中..." fromController:self];
    screenNotice.disableAutoDismissed = YES;
    [screenNotice show];
    
    __weak DXScreenNotice * weakScreenNotice = screenNotice;
    [[DXDongXiApi api] changeTagRelationWithCreateTagIDs:[self.createTagIDs copy] deleteTageIDs:[self.deleteTagIDs copy] result:^(BOOL success, NSError *error) {
        if (success) {
            [weakScreenNotice updateMessage:@"保存成功"];
            [weakScreenNotice dismiss:YES completion:^{
                if (weakSelf.isFromAlert) {
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        } else {
            NSString * errorDesc = error.localizedDescription;
            if (errorDesc) {
                [weakScreenNotice updateMessage:errorDesc];
            } else {
                [weakScreenNotice updateMessage:@"保存失败，请稍后再试"];
            }
            [weakScreenNotice dismiss:YES];
        }
    }];
}

#pragma mark - Lazy

- (NSMutableArray *)collectedTags {
    if (_collectedTags == nil) {
        _collectedTags = [[NSMutableArray alloc] init];
    }
    return _collectedTags;
}

- (NSMutableArray *)allTags {
    if (_allTags == nil) {
        _allTags = [[NSMutableArray alloc] init];
    }
    return _allTags;
}

- (NSMutableArray *)createTagIDs {
    if (_createTagIDs == nil) {
        _createTagIDs = [[NSMutableArray alloc] init];
    }
    return _createTagIDs;
}

- (NSMutableArray *)deleteTagIDs {
    if (_deleteTagIDs == nil) {
        _deleteTagIDs = [[NSMutableArray alloc] init];
    }
    return _deleteTagIDs;
}

#pragma mark - 临时假数据

- (void)setupData {
    
    DXTag *tag1 = [[DXTag alloc] init];
    tag1.ID = @"01";
    tag1.name = @"摩托车";
    tag1.status = 1;
    DXTag *tag2 = [[DXTag alloc] init];
    tag2.ID = @"02";
    tag2.name = @"摄影";
    tag2.status = 0;
    DXTag *tag3 = [[DXTag alloc] init];
    tag3.ID = @"03";
    tag3.name = @"复古情怀";
    tag3.status = 1;
    DXTag *tag4 = [[DXTag alloc] init];
    tag4.ID = @"04";
    tag4.name = @"鞋";
    tag4.status = 0;
    DXTag *tag5 = [[DXTag alloc] init];
    tag5.ID = @"05";
    tag5.name = @"植物";
    tag5.status = 1;
    DXTag *tag6 = [[DXTag alloc] init];
    tag6.ID = @"06";
    tag6.name = @"户外运动";
    tag6.status = 0;
    DXTag *tag7 = [[DXTag alloc] init];
    tag7.ID = @"07";
    tag7.name = @"健身";
    tag7.status = 1;
    DXTag *tag8 = [[DXTag alloc] init];
    tag8.ID = @"08";
    tag8.name = @"小人书";
    tag8.status = 0;
    DXTag *tag9 = [[DXTag alloc] init];
    tag9.ID = @"09";
    tag9.name = @"乐高玩具";
    tag9.status = 1;
    DXTag *tag10 = [[DXTag alloc] init];
    tag10.ID = @"10";
    tag10.name = @"娃娃";
    tag10.status = 0;
    
    [self.allTags addObjectsFromArray:@[tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8, tag9, tag10]];
    [self.collectedTags addObjectsFromArray:@[tag1, tag3, tag5, tag7, tag9]];
    self.originalTags = [self.collectedTags copy];
}

@end
