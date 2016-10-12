//
//  DXFeedPublishViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedPublishViewController.h"
#import "DXPublishPhotoListViewController.h"
#import "DXPublishTopicListViewController.h"
#import "DXLocationListViewController.h"
#import "DXLoginViewController.h"
#import "DXReferViewController.h"
#import "DXDongXiApi.h"
#import "DXTextParser.h"

#import "DXPublishTextEditorCell.h"
#import "DXPublishPhotoListViewCell.h"
#import "DXPublishLocationViewCell.h"
#import "DXPublishTopicViewCell.h"
#import "DXPublishAlbumSaveOptionCell.h"
#import "DXPublishPrivacyViewCell.h"
#import "DXPublishProgressView.h"

@interface DXFeedPublishViewController ()
<UICollectionViewDataSource
, UICollectionViewDelegateFlowLayout
, UIToolbarDelegate
, DXPublishPhotoListViewControllerDelegate
, DXPublishTopicListViewControllerDelegate
, DXLocationListViewControllerDelegate
, YYTextViewDelegate
, DXReferViewControllerDelegate
>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIBarButtonItem * cancelButtonItem;
@property (nonatomic, strong) UIBarButtonItem * publishButtonItem;

@property (nonatomic, strong) DXTopicPost * topicPost;
@property (nonatomic, strong) NSDictionary * selectedPOI;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, strong) DXPublishPhotoListViewController * photoListViewController;
@property (nonatomic, weak) DXPublishTextEditorCell * textEditorCell;
@property (nonatomic, weak) DXPublishLocationViewCell * locationCell;

@property (nonatomic, assign) BOOL textPrepared;
@property (nonatomic, assign) BOOL feedNotVisibleToOthers;
@property (nonatomic, assign) BOOL savePhotosToAlbum;

@property (nonatomic, strong) DXPublishProgressView * progressView;

@property (nonatomic, strong) NSMutableArray *contentPieces;
@property (nonatomic, assign) NSRange referRange;
@property (nonatomic, assign) BOOL isInsertText;

@end

typedef enum : NSUInteger {
    /** 文本编辑区 */
    DXFeedPublishSectionTextView = 0,
    /** 照片区 */
    DXFeedPublishSectionPhotos,
    /** 地址位置区 */
    DXFeedPublishSectionLocation,
    /** 话题设置区 */
    DXFeedPublishSectionTopic,
    /** 保存图片设置区 */
    DXFeedPublishSectionAlbumSave,
    /** 隐私设置区 */
    DXFeedPublishSectionPrivacy
} DXFeedPublishSection;


@implementation DXFeedPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    self.view.backgroundColor = DXRGBColor(0xde, 0xde, 0xde);
    
    if (self.feed) {
        self.dt_pageName = DXDataTrackingPage_PhotoEditing;
    } else {
        self.dt_pageName = DXDataTrackingPage_PhotoPublish;
    }
    
    self.isInsertText = NO;
    
    [self setupSubviews];
    
    self.progressView = [DXPublishProgressView progressView];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"GrayPixel"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"GrayPixel"]];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = DXCommonColor;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont fontWithName:DXCommonBoldFontName size:18],
                                                                    NSForegroundColorAttributeName : DXCommonColor
                                                                    };
    
    [_collectionView registerClass:[DXPublishTextEditorCell class] forCellWithReuseIdentifier:@"DXPublishTextEditorCell"];
    [_collectionView registerClass:[DXPublishPhotoListViewCell class] forCellWithReuseIdentifier:@"DXPublishPhotoListViewCell"];
    [_collectionView registerClass:[DXPublishLocationViewCell class] forCellWithReuseIdentifier:@"DXPublishLocationViewCell"];
    [_collectionView registerClass:[DXPublishTopicViewCell class] forCellWithReuseIdentifier:@"DXPublishTopicViewCell"];
    [_collectionView registerClass:[DXPublishAlbumSaveOptionCell class] forCellWithReuseIdentifier:@"DXPublishAlbumSaveOptionCell"];
    [_collectionView registerClass:[DXPublishPrivacyViewCell class] forCellWithReuseIdentifier:@"DXPublishPrivacyViewCell"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setupSubviews {
    UICollectionViewFlowLayout * collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:DXRGBColor(143, 143, 143) forState:UIControlStateNormal];
    [cancelButton setTitleColor:DXRGBColor(72, 72, 72) forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont fontWithName:DXCommonFontName size:16]; //导航栏文字不进行字体适配
    [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    _cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIButton * publishButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [publishButton setTitle:@"发布" forState:UIControlStateNormal];
    [publishButton setTitleColor:DXCommonColor forState:UIControlStateNormal];
    [publishButton setTitleColor:DXRGBColor(55, 94, 126) forState:UIControlStateHighlighted];
    publishButton.titleLabel.font = [UIFont fontWithName:DXCommonFontName size:16]; //导航栏文字不进行字体适配
    [publishButton addTarget:self action:@selector(publishButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [publishButton sizeToFit];
    _publishButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
    
    self.navigationItem.leftBarButtonItem = _cancelButtonItem;
    self.navigationItem.rightBarButtonItem = _publishButtonItem;
    
    [self.view addSubview:_collectionView];
    
    NSDictionary * subviews = @{
                                @"collectionView"   : _collectionView
                                };
    NSArray * visualFormats = @[
                                @"H:|[collectionView]|",
                                @"V:|[collectionView]|"
                                ];
    for (NSString * vf in visualFormats) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:subviews]];
    }
}

#pragma mark -

- (DXPublishPhotoListViewController *)photoListViewController {
    if (_photoListViewController == nil) {
        UICollectionViewFlowLayout * collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _photoListViewController = [[DXPublishPhotoListViewController alloc] init];
        [_photoListViewController willMoveToParentViewController:self];
        [self addChildViewController:_photoListViewController];
        _photoListViewController.delegate = self;
        _photoListViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [_photoListViewController didMoveToParentViewController:self];
        if (self.feed) {
            _photoListViewController.editingFeed = YES;
            _photoListViewController.editingPhotos = [[NSMutableArray alloc] initWithArray:self.feed.data.photo];
        }
    }
    return _photoListViewController;
}

#pragma mark -

- (void)setFeed:(DXTimelineFeed *)feed {
    _feed = feed;
    
    if (feed.data.content_pieces.count) {
        [self.contentPieces addObjectsFromArray:feed.data.content_pieces];
    } else {
        DXContentPiece *piece = [[DXContentPiece alloc] init];
        piece.type = DXContentPieceTypeNormal;
        piece.content = feed.data.text;
        [self.contentPieces addObject:piece];
    }
    
    if (feed.data.topic.topic) {
        self.topicID = feed.data.topic.topic_id;
        self.topicTitle = feed.data.topic.topic;
        if (feed.data.topic.topic_type == 3) {
            self.topicHasPrize = YES;
        }
    }
}

- (void)appendPhoto:(UIImage *)photo {
    [self.photoListViewController appendPhoto:photo];
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:DXFeedPublishSectionPhotos]];
    }];
}

- (void)saveAllPhotosToAlbum {
    for (NSURL * photoURL in self.photoListViewController.photos) {
        UIImage * photo = [UIImage imageWithContentsOfFile:photoURL.path];
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
    }
}

#pragma mark - Button Action

- (IBAction)privacyChanged:(UISwitch *)sender {
    self.feedNotVisibleToOthers = sender.on;
}

- (IBAction)albumSaveOptionChanged:(UISwitch *)sender {
    self.savePhotosToAlbum = sender.on;
}

- (IBAction)cancelButtonTapped:(UIButton *)sender {
    [self.textEditorCell.textView resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)publishButtonTapped:(UIButton *)sender {
    [self.textEditorCell.textView resignFirstResponder];
    
    if ([[DXDongXiApi api] needLogin]) {
        typeof(self) __weak weakSelf = self;
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可发布内容，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    }
    
    if (self.textEditorCell.textView.text && self.textEditorCell.textView.text.length > 0) {
        self.textPrepared = YES;
    } else {
        self.textPrepared = NO;
    }
    
    if (!self.textPrepared) {
        [[[UIAlertView alloc] initWithTitle:@"请输入文字" message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil] show];
        return;
    }
    
    if (self.photoListViewController.photos.count + self.photoListViewController.editingPhotos.count == 0) {
        [[[UIAlertView alloc] initWithTitle:@"请选取一些照片" message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil] show];
        return;
    }
    
    __weak DXFeedPublishViewController * weakSelf = self;
    
    self.cancelButtonItem.enabled = NO;
    self.publishButtonItem.enabled = NO;
    self.textEditorCell.textView.editable = NO;
    
    DXTopicPost * topicPost = [[DXTopicPost alloc] init];
    topicPost.feed_id = self.feed.fid;
    topicPost.image_ids = self.photoListViewController.editingPhotoIDs;
    topicPost.image_url = self.photoListViewController.editingPhotoURLs;
    topicPost.content_pieces = self.contentPieces;
    topicPost.topic_id = self.topicID;
    topicPost.txt = self.textEditorCell.textView.text;
    topicPost.photoURLs = self.photoListViewController.photos;
    topicPost.lock = self.feedNotVisibleToOthers;
    if (self.selectedPOI) {
        topicPost.place = [self.selectedPOI objectForKey:@"name"];
        topicPost.lat = [NSString stringWithFormat:@"%.6f", self.locationCoordinate.latitude];
        topicPost.lng = [NSString stringWithFormat:@"%.6f", self.locationCoordinate.longitude];
    }
    
    [self.progressView setProgress:0.01];
    [self.progressView showFromController:self];
    
    if (self.feed) {
        [[DXDongXiApi api] updateFeedWithPost:topicPost progress:^(float percent) {
            weakSelf.progressView.progress = percent;
        } result:^(DXTimelineFeed *feed, NSError *error) {
            weakSelf.cancelButtonItem.enabled = YES;
            weakSelf.publishButtonItem.enabled = YES;
            weakSelf.textEditorCell.textView.editable = YES;
            
            if (feed) {
                if (self.delegateController) {
                    [self.delegateController feedPublishController:weakSelf didPublishFeed:feed];
                }
                
                [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                if (weakSelf.savePhotosToAlbum) {
                    [weakSelf saveAllPhotosToAlbum];
                }
                [weakSelf.progressView finish:YES title:@"更新成功" otherMessage:nil];
            } else {
                weakSelf.progressView.removeBlock = ^{
                    NSString * noticeMessage = nil;
                    NSString * errorMessage = error.localizedDescription;
                    if (errorMessage) {
                        noticeMessage = [NSString stringWithFormat:@"更新失败，%@", errorMessage];
                    } else {
                        noticeMessage = @"更新失败，请重新尝试";
                    }
                    DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:noticeMessage fromController:weakSelf];
                    [notice setDisableAutoDismissed:YES];
                    [notice setTapToDismissEnabled:YES completion:nil];
                    [notice show];
                };
                [weakSelf.progressView finish:NO title:@"" otherMessage:nil];
            }
        }];
    } else {
        [[DXDongXiApi api] postToTopic:topicPost progress:^(float percent) {
            weakSelf.progressView.progress = percent;
        } result:^(DXTimelineFeed *feed, NSError *error) {
            weakSelf.cancelButtonItem.enabled = YES;
            weakSelf.publishButtonItem.enabled = YES;
            weakSelf.textEditorCell.textView.editable = YES;
            
            if (feed) {
                if (self.delegateController) {
                    [self.delegateController feedPublishController:weakSelf didPublishFeed:feed];
                }
                
                [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                if (weakSelf.savePhotosToAlbum) {
                    [weakSelf saveAllPhotosToAlbum];
                }
                [weakSelf.progressView finish:YES title:@"发布成功" otherMessage:nil];
            } else {
                weakSelf.progressView.removeBlock = ^{
                    NSString * noticeMessage = nil;
                    NSString * errorMessage = error.localizedDescription;
                    if (errorMessage) {
                        noticeMessage = [NSString stringWithFormat:@"发布失败，%@", errorMessage];
                    } else {
                        noticeMessage = @"发布失败，请重新尝试";
                    }
                    DXScreenNotice * notice = [[DXScreenNotice alloc] initWithMessage:noticeMessage fromController:weakSelf];
                    [notice setDisableAutoDismissed:YES];
                    [notice setTapToDismissEnabled:YES completion:nil];
                    [notice show];
                };
                [weakSelf.progressView finish:NO title:@"" otherMessage:nil];
            }
        }];
    }
}

#pragma mark - Cell Config

- (void)configTexEditorCell:(UICollectionViewCell **)cell  forItemAtIndexPath:(NSIndexPath *)indexPath {
    DXPublishTextEditorCell * textEditorCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishTextEditorCell" forIndexPath:indexPath];
//    textEditorCell.textView.viewStateTextColor = DXRGBColor(177, 177, 177);
    if (self.feed) {
        NSString *text = [NSString string];
        for (DXContentPiece *piece in self.contentPieces) {
            text = [text stringByAppendingString:piece.content];
        }
        DXTextParser *textParser = textEditorCell.textView.textParser;
        textParser.contentPieces = self.contentPieces;
        textEditorCell.textView.text = text;
    }
    textEditorCell.textView.delegate = self;
    
    self.textEditorCell = textEditorCell;
    *cell = textEditorCell;
}

- (void)configPhotoListViewCell:(UICollectionViewCell **)cell  forItemAtIndexPath:(NSIndexPath *)indexPath {
    DXPublishPhotoListViewCell * photoListViewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPhotoListViewCell" forIndexPath:indexPath];
    photoListViewCell.photoListView = self.photoListViewController.view;
    *cell = photoListViewCell;
}

- (void)configLocationViewCell:(UICollectionViewCell **)cell  forItemAtIndexPath:(NSIndexPath *)indexPath {
    DXPublishLocationViewCell * locationViewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishLocationViewCell" forIndexPath:indexPath];
    *cell = locationViewCell;
    
    self.locationCell = locationViewCell;
}

- (void)configTopicViewCell:(UICollectionViewCell **)cell  forItemAtIndexPath:(NSIndexPath *)indexPath {
    DXPublishTopicViewCell * topicViewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishTopicViewCell" forIndexPath:indexPath];
    if (self.topicID) {
        topicViewCell.textLabel.text = [NSString stringWithFormat:@"#%@#", self.topicTitle];
        if (self.topicHasPrize) {
            topicViewCell.decoratorImage = [UIImage imageNamed:@"gift"];
        }
    }
    *cell = topicViewCell;
}

- (void)configAlbumSaveOptionCell:(UICollectionViewCell **)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DXPublishAlbumSaveOptionCell * optionCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishAlbumSaveOptionCell" forIndexPath:indexPath];
    [optionCell.switchControl addTarget:self action:@selector(albumSaveOptionChanged:) forControlEvents:UIControlEventValueChanged];
    *cell = optionCell;
}

- (void)configPrivacyCell:(UICollectionViewCell **)cell  forItemAtIndexPath:(NSIndexPath *)indexPath {
    DXPublishPrivacyViewCell * privacyCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPrivacyViewCell" forIndexPath:indexPath];
    [privacyCell.switchControl addTarget:self action:@selector(privacyChanged:) forControlEvents:UIControlEventValueChanged];
    *cell = privacyCell;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.topicID) {
        return 6;
    } else {
        return 5;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = nil;
    if (self.topicID) {
        switch (indexPath.section) {
            case DXFeedPublishSectionTextView:
                [self configTexEditorCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionPhotos:
                [self configPhotoListViewCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionLocation:
                [self configLocationViewCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionTopic:
                [self configTopicViewCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionAlbumSave:
                [self configAlbumSaveOptionCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionPrivacy:
                [self configPrivacyCell:&cell forItemAtIndexPath:indexPath];
                break;
        }
    } else {
        switch (indexPath.section) {
            case DXFeedPublishSectionTextView:
                [self configTexEditorCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionPhotos:
                [self configPhotoListViewCell:&cell forItemAtIndexPath:indexPath];
                break;
            case DXFeedPublishSectionLocation:
                [self configLocationViewCell:&cell forItemAtIndexPath:indexPath];
                break;
            case 3:
                [self configAlbumSaveOptionCell:&cell forItemAtIndexPath:indexPath];
                break;
            case 4:
                [self configPrivacyCell:&cell forItemAtIndexPath:indexPath];
                break;
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;
    CGFloat itemHeight = 0;
    if (self.topicID) {
        switch (indexPath.section) {
            case DXFeedPublishSectionTextView:
                itemHeight = ceilf(DXRealValue((313-14)/3.0));
                break;
            case DXFeedPublishSectionPhotos:
                itemHeight = ceilf([self.photoListViewController viewHeightForWidth:DXScreenWidth]);
                break;
            case DXFeedPublishSectionLocation:
                itemHeight = ceilf(DXRealValue(120.0/3));
                break;
            case DXFeedPublishSectionTopic:
                itemHeight = ceilf(DXRealValue(143.0/3));
                break;
            case DXFeedPublishSectionAlbumSave:
                itemHeight = ceilf(DXRealValue(143.0/3));
                break;
            case DXFeedPublishSectionPrivacy:
                itemHeight = ceilf(DXRealValue(143.0/3));
                break;
        }
    } else {
        switch (indexPath.section) {
            case DXFeedPublishSectionTextView:
                itemHeight = ceilf(DXRealValue((313-14)/3.0));
                break;
            case DXFeedPublishSectionPhotos:
                itemHeight = ceilf([self.photoListViewController viewHeightForWidth:DXScreenWidth]);
                break;
            case DXFeedPublishSectionLocation:
                itemHeight = ceilf(DXRealValue(120.0/3));
                break;
            case 3:
                itemHeight = ceilf(DXRealValue(143.0/3));
                break;
            case 4:
                itemHeight = ceilf(DXRealValue(143.0/3));
                break;
        }
    }
    
    itemSize = CGSizeMake(DXScreenWidth, itemHeight);
    return itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {        
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == DXFeedPublishSectionLocation) {
        return UIEdgeInsetsMake(0, 0, DXRealValue(40.0/3), 0);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section == DXFeedPublishSectionTextView) {
        [self.textEditorCell.textView becomeFirstResponder];
    } else {
        [self.textEditorCell.textView resignFirstResponder];
    }
    
    // 话题区域不再支持点击 (since v1.2.0)
//    if (indexPath.section == DXFeedPublishSectionTopic) {
//        DXPublishTopicListViewController * topicListVC = [[DXPublishTopicListViewController alloc] init];
//        topicListVC.topicID = self.topicID;
//        topicListVC.delegate = self;
//        [self.navigationController pushViewController:topicListVC animated:YES];
//    }
    
    if (indexPath.section == DXFeedPublishSectionLocation) {
        DXLocationListViewController * locationListViewController = [[DXLocationListViewController alloc] init];
        locationListViewController.delegate = self;
        locationListViewController.selectedPOI = self.selectedPOI;
        [self.navigationController pushViewController:locationListViewController animated:YES];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        [self.textEditorCell.textView resignFirstResponder];
    }
}


#pragma mark - <DXPublishPhotoListViewControllerDelegate>

- (void)photosDidChangeInController:(DXPublishPhotoListViewController *)controller {
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:DXFeedPublishSectionPhotos]];
    }];
}

#pragma mark - <DXPublishTopicListViewControllerDelegate>

- (void)userDidSelectTopic:(NSString *)topicID andTitle:(NSString *)text {
    self.topicID = topicID;
    self.topicTitle = text;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:DXFeedPublishSectionTopic]];
}

#pragma mark - <DXLocationListViewControllerDelegate>

- (void)locationListViewController:(DXLocationListViewController *)controller didSelectPOI:(NSDictionary *)poi {
    if (self.locationCell) {
        NSString * poiName = [poi objectForKey:@"name"];
        [self.locationCell setLocation:poiName];
        self.selectedPOI = poi;
        self.locationCoordinate = controller.currentCoordinate;
    }
}

#pragma mark - <YYTextViewDelegate>

- (void)textViewDidChange:(YYTextView *)textView {
    
    
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    if (textView.text && textView.text.length > 0) {
        self.textPrepared = YES;
    } else {
        self.textPrepared = NO;
    }
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.isInsertText) {
        self.isInsertText = NO;
    } else {
        
        if ([text isEqualToString:@"@"]) {
            DXReferViewController *vc = [[DXReferViewController alloc] initWithReferType:DXReferTypeUser];
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            self.referRange = NSMakeRange(range.location, 1);
        }
        
        if ([text isEqualToString:@"#"]) {
            DXReferViewController *vc = [[DXReferViewController alloc] initWithReferType:DXReferTypeTopic];
            vc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            self.referRange = NSMakeRange(range.location, 1);
        }
        
        [self formatNormalContentPiecesWithText:text inRange:range];
    }
    
    return YES;
}

#pragma mark - <DXReferViewControllerDelegate>

- (void)referViewController:(DXReferViewController *)controller didSelectedReferWithContentPiece:(DXContentPiece *)contentPiece {
    
    [self formatReferContentPiecesWithContentPiece:contentPiece inRange:self.referRange];
}

- (void)referViewControllerDidDismissed {
    [self.textEditorCell.textView becomeFirstResponder];
}

#pragma mark - 构建内容块

- (void)formatNormalContentPiecesWithText:(NSString *)text inRange:(NSRange)range {
    
    if (range.length) { // 替换或删除
        NSMutableArray *tempArray = [NSMutableArray array];
        int startIndex = 0;
        NSUInteger replaceLocation = 0;
        for (int i=0; i<self.contentPieces.count; i++) {
            DXContentPiece *piece = self.contentPieces[i];
            NSRange pieceRange = [self pieceRangeWithPiece:piece];
            if (NSLocationInRange(range.location, pieceRange)) {
                [tempArray addObject:piece];
                startIndex = i;
                replaceLocation = range.location - pieceRange.location;
                break;
            }
        }
        for (int i=startIndex+1; i<self.contentPieces.count; i++) {
            DXContentPiece *piece = self.contentPieces[i];
            NSRange pieceRange = [self pieceRangeWithPiece:piece];
            if (NSLocationInRange(pieceRange.location, range)) {
                [tempArray addObject:piece];
            } else {
                break;
            }
        }
        DXContentPiece *newPiece = [[DXContentPiece alloc] init];
        newPiece.type = DXContentPieceTypeNormal;
        newPiece.content = [NSString string];
        for (DXContentPiece *piece in tempArray) {
            newPiece.content = [newPiece.content stringByAppendingString:piece.content];
        }
        newPiece.content = [newPiece.content stringByReplacingCharactersInRange:NSMakeRange(replaceLocation, range.length) withString:text];
        [self.contentPieces removeObjectsInRange:NSMakeRange(startIndex, tempArray.count)];
        if (newPiece.content.length) {
            [self.contentPieces insertObject:newPiece atIndex:startIndex];
        }
    } else { // 插入
        NSRange allTextRange = NSMakeRange(0, self.textEditorCell.textView.text.length);
        if (NSLocationInRange(range.location, allTextRange)) { // 不是在最后插入
            for (int i=0; i<self.contentPieces.count; i++) {
                DXContentPiece *piece = self.contentPieces[i];
                NSRange pieceRange = [self pieceRangeWithPiece:piece];
                if (range.location == pieceRange.location) {
                    DXContentPiece *newPiece = [[DXContentPiece alloc] init];
                    newPiece.type = DXContentPieceTypeNormal;
                    newPiece.content = text;
                    [self.contentPieces insertObject:newPiece atIndex:i];
                    break;
                } else if ((range.location > pieceRange.location) && ((range.location - pieceRange.location) < pieceRange.length)) {
                    NSRange replaceRange = NSMakeRange(range.location - pieceRange.location, 0);
                    piece.content = [piece.content stringByReplacingCharactersInRange:replaceRange withString:text];
                    piece.type = DXContentPieceTypeNormal;
                    break;
                }
            }
        } else { // 在最后插入
            DXContentPiece *piece = [self.contentPieces lastObject];
            if (piece && piece.type == DXContentPieceTypeNormal) { // 追加内容
                piece.content = [piece.content stringByAppendingString:text];
            } else { // 创建新的piece对象
                DXContentPiece *newPiece = [[DXContentPiece alloc] init];
                newPiece.type = DXContentPieceTypeNormal;
                newPiece.content = text;
                [self.contentPieces addObject:newPiece];
            }
        }
    }
    DXTextParser *textParser = self.textEditorCell.textView.textParser;
    textParser.contentPieces = self.contentPieces;
}

- (void)formatReferContentPiecesWithContentPiece:(DXContentPiece *)contentPiece inRange:(NSRange)range {
    NSMutableArray *tempArray = [NSMutableArray array];
    int startIndex = 0;
    for (int i=0; i<self.contentPieces.count; i++) {
        DXContentPiece *piece = self.contentPieces[i];
        NSRange pieceRange = [self pieceRangeWithPiece:piece];
        if (NSLocationInRange(range.location, pieceRange)) {
            startIndex = i;
            if (range.location == pieceRange.location && range.length == pieceRange.length) {
                [tempArray addObject:contentPiece];
            } else {
                DXContentPiece *firstPiece = [[DXContentPiece alloc] init];
                firstPiece.type = DXContentPieceTypeNormal;
                firstPiece.content = [piece.content substringWithRange:NSMakeRange(0, range.location - pieceRange.location)];
                DXContentPiece *lastPiece = [[DXContentPiece alloc] init];
                lastPiece.type = DXContentPieceTypeNormal;
                NSUInteger lastPieceLoc = range.location - pieceRange.location + 1;
                NSUInteger lastPieceLen = pieceRange.length - lastPieceLoc;
                lastPiece.content = [piece.content substringWithRange:NSMakeRange(lastPieceLoc, lastPieceLen)];
                if (range.location == pieceRange.location) {
                    [tempArray addObjectsFromArray:@[contentPiece, lastPiece]];
                } else if ((range.location + range.length) == (pieceRange.location + pieceRange.length)) {
                    [tempArray addObjectsFromArray:@[firstPiece, contentPiece]];
                } else {
                    [tempArray addObjectsFromArray:@[firstPiece, contentPiece, lastPiece]];
                }
            }
            break;
        }
    }
    [self.contentPieces removeObjectAtIndex:startIndex];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, tempArray.count)];
    [self.contentPieces insertObjects:tempArray atIndexes:indexSet];
    
    DXTextParser *textParser = self.textEditorCell.textView.textParser;
    textParser.contentPieces = self.contentPieces;
    
    // textView上添加相应文字
    self.isInsertText = YES;
    NSString *text = [contentPiece.content substringFromIndex:1];
    [self.textEditorCell.textView insertText:text];
    [self.textEditorCell.textView insertText:@" "];
}



- (NSRange)pieceRangeWithPiece:(DXContentPiece *)piece {
    NSInteger location = 0;
    NSInteger index = [self.contentPieces indexOfObject:piece];
    for (int i=0; i<index; i++) {
        DXContentPiece *tempPiece = self.contentPieces[i];
        location += tempPiece.content.length;
    }
    return NSMakeRange(location, piece.content.length);
}

- (NSMutableArray *)contentPieces {
    if (_contentPieces == nil) {
        _contentPieces = [[NSMutableArray alloc] init];
    }
    return _contentPieces;
}

@end
