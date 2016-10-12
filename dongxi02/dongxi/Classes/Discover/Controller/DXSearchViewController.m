//
//  DXSearchViewController.m
//  dongxi
//
//  Created by 穆康 on 16/2/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXSearchViewController.h"
#import "DXTopicViewController.h"
#import "DXProfileViewController.h"
#import "DXEventViewController.h"
#import "DXSearchMoreViewController.h"
#import "DXDetailViewController.h"

#import "UIBarButtonItem+Extension.h"
#import "UIImage+Extension.h"

#import "DXSearchHotKeywordsHeaderCell.h"
#import "DXSearchHotKeywordsCell.h"
#import "DXSearchResultsHeaderCell.h"
#import "DXSearchResultsFooterCell.h"
#import "DXSearchResultsTopicCell.h"
#import "DXSearchResultsUserCell.h"
#import "DXSearchResultsPhotosCell.h"
#import "DXActivityListCell.h"
#import "DXSearchNoResultsCell.h"

#import <UIImageView+WebCache.h>

static NSString *const IDHotKeywordsHeaderCell     = @"HotKeywordsHeaderCell";
static NSString *const IDHotKeywordsCell           = @"HotKeywordsCell";
static NSString *const IDSearchResultsHeaderCell   = @"SearchResultsHeaderCell";
static NSString *const IDSearchResultsFooterCell   = @"SearchResultsFooterCell";
static NSString *const IDSearchResultsTopicCell    = @"SearchResultsTopicCell";
static NSString *const IDSearchResultsUserCell     = @"SearchResultsUserCell";
static NSString *const IDSearchResultsPhotosCell   = @"SearchResultsPhotosCell";
static NSString *const IDActivityListCell          = @"ActivityListCell";
static NSString *const IDSearchNoResultsCell       = @"SearchNoResultsCell";

@interface DXSearchViewController ()
<
UISearchBarDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
DXSearchResultsFooterCellDelegate,
DXSearchResultsPhotosCellDelegate
>

/** 搜索框 */
@property (nonatomic, strong) UISearchBar *searchBar;
/** 关键词 */
@property (nonatomic, copy) NSString *keywords;
/** 展示热门关键词的视图 */
@property (nonatomic, weak) UICollectionView *hotKeywordsView;
/** 展示搜索结果的视图 */
@property (nonatomic, weak) UICollectionView *searchResultsView;
/** 没有搜到结果视图 */
@property (nonatomic, weak) UICollectionView *searchNoResultsView;

@property (nonatomic, strong) NSArray *hotKeywordsList;

@property (nonatomic, strong) DXSearchResults *searchResults;

@property (nonatomic, strong) NSArray *searchHeaderTitle;
@property (nonatomic, strong) NSArray *searchFooterTitle;

@property (nonatomic, assign) BOOL originInteractivePopGestureEnabled;

@end

@implementation DXSearchViewController {
    __weak DXSearchViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    weakSelf = self;
    self.dt_pageName = DXDataTrackingPage_Search;
    
    [self setupNav];
    [self setupContent];
    
    [self fetchHotKeywords];
    [self searchBarIsFirstResponder:YES];
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
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, DXScreenWidth, 44);
    searchBar.placeholder = @"搜索话题、用户和照片";
    searchBar.translucent = NO;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    [searchBar sizeToFit];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    self.navigationItem.hidesBackButton = YES;
    
    self.searchBar = searchBar;
}

- (void)setupContent {
    
    // 展示热门关键词的视图
    UICollectionViewFlowLayout *hotKeywordsLayout = [[UICollectionViewFlowLayout alloc] init];
    hotKeywordsLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (systemVersion >= 8.0) {
        hotKeywordsLayout.estimatedItemSize = CGSizeMake(DXScreenWidth, roundf(DXRealValue(25)));
    }
    hotKeywordsLayout.minimumLineSpacing = 0;
    UICollectionView *hotKeywordsView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:hotKeywordsLayout];
    hotKeywordsView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    hotKeywordsView.delegate = self;
    hotKeywordsView.dataSource = self;
    hotKeywordsView.alwaysBounceVertical = YES;
    hotKeywordsView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:hotKeywordsView];
    
    // 展示搜索结果的视图
    UICollectionViewFlowLayout *searchResultsLayout = [[UICollectionViewFlowLayout alloc] init];
    searchResultsLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    searchResultsLayout.minimumLineSpacing = 0;
    UICollectionView *searchResultsView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:searchResultsLayout];
    searchResultsView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    searchResultsView.delegate = self;
    searchResultsView.dataSource = self;
    searchResultsView.alwaysBounceVertical = YES;
    searchResultsView.backgroundColor = DXRGBColor(222, 222, 222);
    [self.view addSubview:searchResultsView];
    
    // 没有搜到结果视图
    UICollectionViewFlowLayout *searchNoResultsLayout = [[UICollectionViewFlowLayout alloc] init];
    searchNoResultsLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *searchNoResultsView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:searchNoResultsLayout];
    searchResultsView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    searchNoResultsView.delegate = self;
    searchNoResultsView.dataSource = self;
    searchNoResultsView.alwaysBounceVertical = YES;
    searchNoResultsView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchNoResultsView];
    
    [hotKeywordsView registerClass:[DXSearchHotKeywordsHeaderCell class] forCellWithReuseIdentifier:IDHotKeywordsHeaderCell];
    [hotKeywordsView registerClass:[DXSearchHotKeywordsCell class] forCellWithReuseIdentifier:IDHotKeywordsCell];
    
    [searchResultsView registerClass:[DXSearchResultsHeaderCell class] forCellWithReuseIdentifier:IDSearchResultsHeaderCell];
    [searchResultsView registerClass:[DXSearchResultsFooterCell class] forCellWithReuseIdentifier:IDSearchResultsFooterCell];
    [searchResultsView registerClass:[DXSearchResultsTopicCell class] forCellWithReuseIdentifier:IDSearchResultsTopicCell];
    [searchResultsView registerClass:[DXSearchResultsUserCell class] forCellWithReuseIdentifier:IDSearchResultsUserCell];
    [searchResultsView registerClass:[DXActivityListCell class] forCellWithReuseIdentifier:IDActivityListCell];
    [searchResultsView registerClass:[DXSearchResultsPhotosCell class] forCellWithReuseIdentifier:IDSearchResultsPhotosCell];
    [searchNoResultsView registerClass:[DXSearchNoResultsCell class] forCellWithReuseIdentifier:IDSearchNoResultsCell];
    
    self.searchHeaderTitle = @[@"相关话题", @"相关用户", @"相关活动", @"相关照片"];
    self.searchFooterTitle = @[@"查看更多相关话题", @"查看更多相关用户", @"查看更多相关文章", @"查看更多相关图片"];
    
    self.hotKeywordsView = hotKeywordsView;
    self.searchResultsView = searchResultsView;
    self.searchNoResultsView = searchNoResultsView;
}

#pragma mark - UISearchBarDelegate

/**
 *  开始编辑
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES];
    UIButton *cancelBtn = nil;
    UITextField *textField = nil;
    for (UIView *subView in [searchBar.subviews[0] subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            cancelBtn = (UIButton *)subView;
        }
        if ([subView isKindOfClass:[UITextField class]]) {
            textField = (UITextField *)subView;
        }
    }
    
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    textField.backgroundColor = DXRGBColor(222, 222, 222);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        [self fetchHotKeywords];
    }
}

/**
 *  点击了取消
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.navigationController popViewControllerAnimated:NO];
}

/**
 *  点击了搜索
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (searchBar == self.searchBar) {
        [self searchBarIsFirstResponder:NO];
    }
    self.keywords = searchBar.text;
    [self fetchSearchResults];
}

#pragma mark - searchBar是否是第一响应者
/**
 *  searchBar是否是第一响应者
 */
- (void)searchBarIsFirstResponder:(BOOL)isFirstResponder {
    
    if (isFirstResponder) {
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
        UIButton *cancelBtn = nil;
        for (UIView *subView in [self.searchBar.subviews[0] subviews]) {
            if ([subView isKindOfClass:[UIButton class]]) {
                cancelBtn = (UIButton *)subView;
            }
        }
        cancelBtn.enabled = YES;
    }
}

#pragma mark - 获取热门搜索关键词
/**
 *  获取热门搜索关键词
 */
- (void)fetchHotKeywords {
    
    [self.view bringSubviewToFront:self.hotKeywordsView];
    
    if (self.hotKeywordsList) {
        [self.hotKeywordsView reloadData];
    } else {
        [[DXDongXiApi api] getHotKeywordsListResult:^(NSArray *hotKeywordsList, NSError *error) {
            if (hotKeywordsList.count) {
                self.hotKeywordsList = hotKeywordsList;
                [self.hotKeywordsView reloadData];
            }
        }];
    }
}

#pragma mark - 获取搜索结果
/**
 *  获取搜索结果
 */
- (void)fetchSearchResults {
    
    [self.view bringSubviewToFront:self.searchResultsView];
    self.searchResults = nil;
    [self.searchResultsView reloadData];
    
    DXScreenNotice *notice = [[DXScreenNotice alloc] initWithMessage:@"正在加载..." fromController:self];
    notice.disableAutoDismissed = YES;
    [notice show];
    [[DXDongXiApi api] getSearchResultsByKeywords:self.keywords result:^(DXSearchResults *searchResults, NSError *error) {
        [notice dismiss:NO];
        // 隐藏活动的搜索
        BOOL hasResults = searchResults.topic.list.count || searchResults.user.list.count || searchResults.feed.list.count;
        if (hasResults) {
            weakSelf.searchResults = searchResults;
            [weakSelf.searchResultsView reloadData];
        } else {
            [weakSelf.view bringSubviewToFront:self.searchNoResultsView];
            [weakSelf.searchNoResultsView reloadData];
        }
    }];
}

#pragma mark - collection view dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if (collectionView == self.hotKeywordsView) {
        return 1;
    } else if (collectionView == self.searchNoResultsView) {
        return 1;
    } else {
        return 4;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == self.hotKeywordsView) {
        if (self.hotKeywordsList.count) {
            return self.hotKeywordsList.count + 1;
        }
        return 0;
    } else if (collectionView == self.searchNoResultsView) {
        return 1;
    } else {
        switch (section) {
            case 0:
            {
                NSUInteger topicCount = self.searchResults.topic.list.count;
                if (self.searchResults.topic.more) {
                    return 5;
                } else {
                    return topicCount ? topicCount + 1 : 0;
                }
            }
                break;
            case 1:
            {
                NSUInteger userCount = self.searchResults.user.list.count;
                if (self.searchResults.user.more) {
                    return 5;
                } else {
                    return userCount ? userCount + 1 : 0;
                }
            }
                break;
            case 2:
            {
                // 隐藏活动的搜索，since v1.2.0
//                NSUInteger activityCount = self.searchResults.activity.list.count;
//                if (self.searchResults.activity.more) {
//                    return 5;
//                } else {
//                    return activityCount ? activityCount + 1 : 0;
//                }
                return 0;
            }
                break;
            case 3:
            {
                NSUInteger photosCount = self.searchResults.feed.list.count;
                if (self.searchResults.feed.more) {
                    return 3;
                } else {
                    return photosCount ? 2 : 0;
                }
            }
                break;
                
            default:
                return 0;
                break;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.hotKeywordsView) {
        if (indexPath.item == 0) {
            DXSearchHotKeywordsHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDHotKeywordsHeaderCell forIndexPath:indexPath];
            return cell;
        } else {
            DXSearchHotKeywordsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDHotKeywordsCell forIndexPath:indexPath];
            DXSearchHotKeywords *hotKeywords = self.hotKeywordsList[indexPath.item - 1];
            cell.hotKeywords = hotKeywords;
            return cell;
        }
    } else if (collectionView == self.searchNoResultsView) {
        DXSearchNoResultsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchNoResultsCell forIndexPath:indexPath];
        return cell;
    } else {
        if (indexPath.item == 0) {  // 头部视图
            DXSearchResultsHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsHeaderCell forIndexPath:indexPath];
            cell.separateView.hidden = (indexPath.section == 3 ? YES : NO);
            cell.title = self.searchHeaderTitle[indexPath.section];
            return cell;
        } else if (indexPath.item == 4 || (indexPath.section == 3 && indexPath.item == 2)) {  // 尾部视图
            DXSearchResultsFooterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsFooterCell forIndexPath:indexPath];
            cell.title = self.searchFooterTitle[indexPath.section];
            cell.indexPath = indexPath;
            cell.delegate = self;
            return cell;
        } else {
            switch (indexPath.section) {
                case 0:
                {
                    DXSearchResultsTopicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsTopicCell forIndexPath:indexPath];
                    cell.keywords = self.keywords;
                    DXTopic *topic = self.searchResults.topic.list[indexPath.item - 1];
                    cell.topic = topic;
                    return cell;
                }
                    break;
                case 1:
                {
                    DXSearchResultsUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsUserCell forIndexPath:indexPath];
                    cell.keywords = self.keywords;
                    DXUser *user = self.searchResults.user.list[indexPath.item - 1];
                    cell.user = user;
                    return cell;
                }
                    break;
                case 2:
                {
                    DXActivityListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDActivityListCell forIndexPath:indexPath];
                    cell.keywords = self.keywords;
                    DXActivity *activity = self.searchResults.activity.list[indexPath.item - 1];
                    cell.separateView.hidden = NO;
                    cell.nameLabel.attributedText = [self setHighlightedString:self.keywords withOriginString:activity.activity];
                    cell.typeAndPlace = [NSString stringWithFormat:@"%@・%@", activity.typeText, activity.city];
                    cell.time = activity.days;
//                    cell.descriptionLabel.attributedText = [self setHighlightedString:self.keywords withOriginString:activity.abstract];
                    cell.descriptionLabel.text = activity.abstract;
                    UIImage * placeHolderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(100), DXRealValue(100))];
                    [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:activity.avatar] placeholderImage:placeHolderImage options:SDWebImageRetryFailed];
                    return cell;
                }
                    break;
                case 3:
                {
                    DXSearchResultsPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDSearchResultsPhotosCell forIndexPath:indexPath];
                    cell.feeds = self.searchResults.feed.list;
                    cell.delegate = self;
                    return cell;
                }
                    break;
                    
                default:
                    return nil;
                    break;
            }
        }
    }
}

#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.hotKeywordsView) {
        if (indexPath.item) {
            DXSearchHotKeywords *hotKeywords = self.hotKeywordsList[indexPath.item - 1];
            self.searchBar.text = hotKeywords.keyword;
            self.keywords = hotKeywords.keyword;
            [self searchBarIsFirstResponder:NO];
            [self fetchSearchResults];
        }
    } else if (collectionView == self.searchResultsView && indexPath.section != 3 && indexPath.item != 0 && indexPath.item != 4) {
        switch (indexPath.section) {
            case 0:
            {
                DXTopic *topic = self.searchResults.topic.list[indexPath.item - 1];
                DXTopicViewController * topicVC = [[DXTopicViewController alloc] init];
                topicVC.topicID = topic.topic_id;
                topicVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:topicVC animated:YES];
            }
                break;
            case 1:
            {
                DXUser *user = self.searchResults.user.list[indexPath.item - 1];
                DXProfileViewController *vc = [[DXProfileViewController alloc] initWithControllerType:DXProfileViewControllerUserUID];
                vc.uid = user.uid;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                DXActivity *activity = self.searchResults.activity.list[indexPath.item - 1];
                DXEventViewController * eventVC = [[DXEventViewController alloc] init];
                eventVC.activityID = activity.activity_id;
                eventVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:eventVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.hotKeywordsView) {
        if (indexPath.item == 0) {
            return CGSizeMake(DXScreenWidth, roundf(DXRealValue(37)));
        }
        return CGSizeMake(DXScreenWidth, roundf(DXRealValue(25)));
    } else if (collectionView == self.searchNoResultsView) {
        return self.view.bounds.size;
    } else {
        if (indexPath.item == 0) {
            return CGSizeMake(DXScreenWidth, roundf(DXRealValue(28)));
        } else if (indexPath.item == 4 || (indexPath.section == 3 && indexPath.item == 2)) {
            return CGSizeMake(DXScreenWidth, roundf(DXRealValue(47)));
        } else {
            switch (indexPath.section) {
                case 0:
                    return CGSizeMake(DXScreenWidth, roundf(DXRealValue(76)));
                    break;
                case 1:
                    return CGSizeMake(DXScreenWidth, roundf(DXRealValue(60)));
                case 2:
                    return CGSizeMake(DXScreenWidth, roundf(DXRealValue(100)));
                case 3:
                {
                    NSUInteger photosCount = self.searchResults.feed.list.count;
                    NSUInteger row = (photosCount - 1) / 4;
                    CGFloat margin = 2;
                    CGFloat photoWH = (DXScreenWidth - (margin * 3)) / 4.0;
                    return CGSizeMake(DXScreenWidth, roundf((photoWH + margin) * (row + 1)));
                }
                    break;
                    
                default:
                    return CGSizeZero;
                    break;
            }
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if (collectionView == self.searchResultsView) {
        UIEdgeInsets insets = UIEdgeInsetsMake(DXRealValue(20/3.0), 0, 0, 0);
        switch (section) {
            case 0:
                if (self.searchResults.topic.list.count) {
                    return insets;
                } else {
                    return UIEdgeInsetsZero;
                }
                break;
            case 1:
                if (self.searchResults.user.list.count) {
                    return insets;
                } else {
                    return UIEdgeInsetsZero;
                }
                break;
            case 2:
                if (self.searchResults.activity.list.count) {
                    return insets;
                } else {
                    return UIEdgeInsetsZero;
                }
                break;
            case 3:
                if (self.searchResults.feed.list.count) {
                    return insets;
                } else {
                    return UIEdgeInsetsZero;
                }
                break;
                
            default:
                return UIEdgeInsetsZero;
                break;
        }
    } else {
        return UIEdgeInsetsZero;
    }
}

#pragma mark - DXSearchResultsFooterCellDelegate

- (void)searchResultsFooterCell:(DXSearchResultsFooterCell *)cell didTapSearchMoreWithIndexPath:(NSIndexPath *)indexPath {
    
    DXSearchMoreType searchMoreType;
    switch (indexPath.section) {
        case 0:
            searchMoreType = DXSearchMoreTypeTopic;
            break;
        case 1:
            searchMoreType = DXSearchMoreTypeUser;
            break;
        case 2:
            searchMoreType = DXSearchMoreTypeActivity;
            break;
        default:
            searchMoreType = DXSearchMoreTypeFeed;
            break;
    }
    DXSearchMoreViewController *searchMoreVC = [[DXSearchMoreViewController alloc] initWithSearchMoreType:searchMoreType];
    searchMoreVC.keywords = self.keywords;
    searchMoreVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchMoreVC animated:YES];
}

#pragma mark - DXSearchResultsPhotosCellDelegate

- (void)searchResultsPhotosCell:(DXSearchResultsPhotosCell *)cell didTapPhotoWithFeed:(DXTimelineFeed *)feed {
    
    DXDetailViewController *vc = [[DXDetailViewController alloc] initWithControllerType:DXDetailViewControllerTypeFeed];
    vc.detailType = DXDetailTypeContent;
    vc.feed = feed;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([self.searchBar isFirstResponder]) {
        [self searchBarIsFirstResponder:NO];
    }
}

#pragma mark - 返回高亮属性字符串
/**
 *  返回高亮属性字符串
 */
- (NSAttributedString *)setHighlightedString:(NSString *)highlightedString withOriginString:(NSString *)originString {
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:originString];
    NSRange highlightedRange = [originString rangeOfString:highlightedString options:NSCaseInsensitiveSearch];
    if (highlightedRange.location != NSNotFound) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:DXCommonColor range:highlightedRange];
    }
    return [attrStr copy];
}

@end
