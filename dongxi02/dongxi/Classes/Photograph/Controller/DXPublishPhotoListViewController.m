//
//  DXPublishPhotoListViewController.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPublishPhotoListViewController.h"
#import "DXPublishPhotoViewCell.h"
#import "DXPublishPhotoInsertViewCell.h"
#import "DXPhotoTakerController.h"
#import "DXImageKit.h"
#import "DXPhotoBrowser.h"
#import "DXCacheFileManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DXPublishPhotoListViewController ()
<
UICollectionViewDataSource
,UICollectionViewDelegateFlowLayout
,DXPublishPhotoViewCellDelegate
,DXPhotoTakerControllerDelegate
,UINavigationControllerDelegate
,MWPhotoBrowserDelegate
>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * collectionViewLayout;

@property (nonatomic, strong) NSMutableArray * originPhotoURLs;
@property (nonatomic, strong) NSMutableArray * previewPhotos;
@property (nonatomic, strong) NSMutableArray * browserDataSource;

@property (nonatomic, strong) DXPhotoBrowser * photoBrowser;
@property (nonatomic, strong) UIBarButtonItem * photoDeleteButtonItem;

@end

#define kDXFeedPublishMaxAttachedPhotos 7

@implementation DXPublishPhotoListViewController

- (NSArray *)photos {
    return [_originPhotoURLs copy];
}

- (NSArray *)editingPhotoIDs {
    NSMutableArray *temp = [NSMutableArray array];
    for (DXTimelineFeedPhoto *photo in self.editingPhotos) {
        [temp addObject:photo.ID];
    }
    return [temp copy];
}

- (NSArray *)editingPhotoURLs {
    NSMutableArray *temp = [NSMutableArray array];
    for (DXTimelineFeedPhoto *photo in self.editingPhotos) {
        [temp addObject:photo.url];
    }
    return [temp copy];
}

- (CGFloat)viewHeightForWidth:(CGFloat)width {
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    
    CGSize contentSize = self.collectionView.contentSize;
    return contentSize.height;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    UICollectionViewFlowLayout * collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionViewLayout = collectionViewLayout;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = NO;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view addSubview:self.collectionView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"collectionView": self.collectionView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"collectionView": self.collectionView}]];
    
    
    [self.collectionView registerClass:[DXPublishPhotoViewCell class] forCellWithReuseIdentifier:@"DXPublishPhotoViewCell"];
    [self.collectionView registerClass:[DXPublishPhotoInsertViewCell class] forCellWithReuseIdentifier:@"DXPublishPhotoInsertViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isEditingFeed) {
        if (self.editingPhotos.count + self.originPhotoURLs.count >= kDXFeedPublishMaxAttachedPhotos) {
            return self.editingPhotos.count + self.originPhotoURLs.count;
        } else {
            return self.editingPhotos.count + self.originPhotoURLs.count + 1;
        }
    } else {
        if (self.originPhotoURLs.count >= kDXFeedPublishMaxAttachedPhotos) {
            return self.originPhotoURLs.count;
        } else {
            return self.originPhotoURLs.count + 1;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (self.isEditingFeed) {
        if (indexPath.item < self.editingPhotos.count + self.photos.count || self.editingPhotos.count + self.photos.count >= kDXFeedPublishMaxAttachedPhotos) {
            DXPublishPhotoViewCell * photoViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPhotoViewCell" forIndexPath:indexPath];
            if (indexPath.item < self.editingPhotos.count) {
                DXTimelineFeedPhoto *photo = [self.editingPhotos objectAtIndex:indexPath.item];
                [photoViewCell.photoView sd_setImageWithURL:[NSURL URLWithString:photo.preview] placeholderImage:nil options:SDWebImageRetryFailed];
            } else {
                [photoViewCell.photoView setImage:[self.previewPhotos objectAtIndex:indexPath.item-self.editingPhotos.count]];
            }
            photoViewCell.delegate = self;
            cell = photoViewCell;
        } else {
            DXPublishPhotoInsertViewCell * photoInsertViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPhotoInsertViewCell" forIndexPath:indexPath];
            cell = photoInsertViewCell;
        }
    } else {
        if (indexPath.item < self.photos.count || self.photos.count >= kDXFeedPublishMaxAttachedPhotos) {
            DXPublishPhotoViewCell * photoViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPhotoViewCell" forIndexPath:indexPath];
            [photoViewCell.photoView setImage:[self.previewPhotos objectAtIndex:indexPath.item]];
            photoViewCell.delegate = self;
            cell = photoViewCell;
        } else {
            DXPublishPhotoInsertViewCell * photoInsertViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXPublishPhotoInsertViewCell" forIndexPath:indexPath];
            cell = photoInsertViewCell;
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellLength = (self.view.bounds.size.width - DXRealValue(40.0/3) * 5) / 4;
    return CGSizeMake(cellLength, cellLength);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return DXRealValue(40.0/3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return DXRealValue(40.0/3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(DXRealValue(16.0/3), DXRealValue(40.0/3), DXRealValue(35.0/3), DXRealValue(40.0/3));
}

-  (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DXPublishPhotoInsertViewCell class]]) {
        DXPhotoTakerController * photoTaker = [[DXPhotoTakerController alloc] init];
        photoTaker.delegate = self;
        [self presentViewController:photoTaker animated:YES completion:nil];
    }
    
    if ([cell isKindOfClass:[DXPublishPhotoViewCell class]]) {
        [self browsePhotosFromIndex:indexPath.item];
    }
}

#pragma mark - <DXPublishPhotoViewCellDelegate>

- (void)deleteButtonTappedInCell:(UICollectionViewCell *)cell {
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if (self.isEditingFeed) {
        if (indexPath.item < self.editingPhotos.count + self.photos.count) {
            if (indexPath.item < self.editingPhotos.count) {
                [self.editingPhotos removeObjectAtIndex:indexPath.item];
            } else {
                [self.originPhotoURLs removeObjectAtIndex:indexPath.item - self.editingPhotos.count];
                [self.previewPhotos removeObjectAtIndex:indexPath.item - self.editingPhotos.count];
            }
            [self.browserDataSource removeObjectAtIndex:indexPath.item];
            
            [self.collectionView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosDidChangeInController:)]) {
                [self.delegate photosDidChangeInController:self];
            }
        }
    } else {
        if (indexPath.item < self.photos.count) {
            [self.originPhotoURLs removeObjectAtIndex:indexPath.item];
            [self.previewPhotos removeObjectAtIndex:indexPath.item];
            [self.browserDataSource removeObjectAtIndex:indexPath.item];
            
            [self.collectionView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosDidChangeInController:)]) {
                [self.delegate photosDidChangeInController:self];
            }
        }
    }
}

#pragma mark - DXPhotoTakerControllerDelegate

- (void)photoTaker:(DXPhotoTakerController *)photoTaker didFinishPhoto:(UIImage *)photo {
    [self appendPhoto:photo];

    if (self.delegate && [self.delegate respondsToSelector:@selector(photosDidChangeInController:)]) {
        [self.delegate photosDidChangeInController:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Append New Photo

- (void)appendPhoto:(UIImage *)photo {
    if (photo) {
        NSURL * photoURL = nil;
        NSError * cacheError = nil;
        if ([self cachePhoto:photo savedURL:&photoURL error:&cacheError]) {
            [self.originPhotoURLs addObject:photoURL];
            [self.browserDataSource addObject:[[MWPhoto alloc] initWithURL:photoURL]];
            
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            CGSize thumbnailSize = [self collectionView:self.collectionView layout:self.collectionViewLayout sizeForItemAtIndexPath:indexPath];
            UIImage * thumbnail = [self getThumbnailForPhoto:photoURL andSize:thumbnailSize];
            [self.previewPhotos addObject:thumbnail];
            
            [self.collectionView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosDidChangeInController:)]) {
                [self.delegate photosDidChangeInController:self];
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:@"缓存图片出错" message:cacheError.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

#pragma mark - Append Photos

- (void)setEditingPhotos:(NSMutableArray *)editingPhotos {
    _editingPhotos = editingPhotos;
    
    for (DXTimelineFeedPhoto *photo in editingPhotos) {
        [self.browserDataSource addObject:[[MWPhoto alloc] initWithURL:[NSURL URLWithString:photo.url]]];
    }
}

#pragma mark - Photo Cache & Thumbnail

- (BOOL)cachePhoto:(UIImage *)photo savedURL:(NSURL **)fileURL error:(NSError **)error {
    BOOL success = NO;
    NSURL * localURL = nil;
    @autoreleasepool {
        DXCacheFileManager * dxFileManager = [DXCacheFileManager sharedManager];
        DXCacheFile * photoFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeImageCache];
        photoFile.extension = @"jpg";
        photoFile.deleteWhenAppLaunch = YES;
        NSData * imageData = UIImageJPEGRepresentation(photo, 0.8);
        success = [dxFileManager saveData:imageData toFile:photoFile error:error];
        if (success) {
            localURL = photoFile.url;
        }
    }
    if (fileURL) {
        *fileURL = localURL;
    }
    return success;
}

- (UIImage *)getThumbnailForPhoto:(NSURL *)photoURL andSize:(CGSize)size {
    return [DXImageKit getThumbnailForPhoto:photoURL andSize:size];
}

#pragma mark - 

- (void)browsePhotosFromIndex:(NSInteger)index {
    // DXPhotoBrowser实例无法重用
    self.photoBrowser = [[DXPhotoBrowser alloc] initWithDelegate:self];
    self.photoBrowser.dt_pageName = DXDataTrackingPage_PhotoPublishPhotoBrowser;
    self.photoBrowser.zoomPhotosToFill = NO;
    self.photoBrowser.displayActionButton = NO;
    [self.photoBrowser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:self.photoBrowser animated:YES];
}


#pragma mark - <MWPhotoBrowserDelegate>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.browserDataSource.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self.browserDataSource objectAtIndex:index];
}

#pragma mark - Actions

- (void)photoBrowserDeleteTapped:(id)sender {
    [self.photoBrowser reloadData];
}

#pragma mark - Lazy

- (NSMutableArray *)originPhotoURLs {
    if (_originPhotoURLs == nil) {
        _originPhotoURLs = [[NSMutableArray alloc] init];
    }
    return _originPhotoURLs;
}

- (NSMutableArray *)previewPhotos {
    if (_previewPhotos == nil) {
        _previewPhotos = [[NSMutableArray alloc] init];
    }
    return _previewPhotos;
}

- (NSMutableArray *)browserDataSource {
    if (_browserDataSource == nil) {
        _browserDataSource = [[NSMutableArray alloc] init];
    }
    return _browserDataSource;
}


@end
