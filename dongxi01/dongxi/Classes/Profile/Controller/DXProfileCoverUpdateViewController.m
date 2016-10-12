//
//  DXChangeImageViewController.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileCoverUpdateViewController.h"
#import "DXDongXiApi.h"
#import "DXPhotoTakerController.h"
#import "DXCacheFileManager.h"

NSString * const DXProfileCoverDidUpdateNotification = @"DXProfileCoverDidUpdateNotification";

@interface DXProfileCoverUpdateViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,DXPhotoTakerControllerDelegate>

@property(nonatomic,strong) NSMutableArray *coverImageViewArray;
@property (nonatomic, strong) UIImageView *coverImagePreviewView;
@property (nonatomic, strong) UIView *previewOptionView;

@end

@implementation DXProfileCoverUpdateViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dt_pageName = DXDataTrackingPage_ProfileCoverModify;
    
    self.navigationController.navigationBar.y = 20;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.extendedLayoutIncludesOpaqueBars = YES;//允许穿透导航栏
    self.title = @"更换封面";
    self.navigationItem.leftBarButtonItem = [DXBarButtonItem defaultSystemBackItemForController:self];

    //设置两个Btn
    [self setupBtn];
    
    //设置推荐栏
    [self setupline];
    
    //设置9张照片
    [self setupRecommenCovers];
    
    //设置预览效果
    [self setupCoverPreview];
}


//设置预览效果
-(void)setupCoverPreview{
    CGFloat screenWidth = DXScreenWidth;
    CGFloat screenHeight = DXScreenHeight;
    _coverImagePreviewView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -screenWidth, screenWidth, screenWidth)];
    _coverImagePreviewView.userInteractionEnabled = YES;
    
    [self.view addSubview:_coverImagePreviewView];
    
    UITapGestureRecognizer *previewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCoverPreviewViewTapGesture:)];
    previewTapGesture.numberOfTouchesRequired = 1;
    previewTapGesture.numberOfTapsRequired = 1;
    previewTapGesture.delegate = self;
    [_coverImagePreviewView addGestureRecognizer:previewTapGesture];
    
    _previewOptionView = [[UIView alloc] initWithFrame:CGRectMake(0,screenHeight,screenWidth, screenHeight - screenWidth)];
    _previewOptionView.backgroundColor = [UIColor whiteColor];
    
    UIButton *confirmButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - DXRealValue(307))/2, 60, DXRealValue(307), 45)];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"button_personal_bg1"] forState:UIControlStateNormal];
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(submitConfirmTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - DXRealValue(307))/2, 130, DXRealValue(307), 45)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button_personal_bg2"] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:DXRGBColor(120, 201, 255) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(submitCancelTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [_previewOptionView addSubview:confirmButton];
    [_previewOptionView addSubview:cancelButton];
    [self.view addSubview:_previewOptionView];
}


//设置两个Btn
-(void)setupBtn{
    
    //拍照上传
    UIImageView *PhotoV = [[UIImageView alloc]initWithFrame:CGRectMake(DXRealValue(75), DXRealValue(95.3) ,DXRealValue(46),DXRealValue(35))];
    
    [PhotoV setImage:[UIImage imageNamed:@"personal_bg_camera"]];
    
    [self.view addSubview:PhotoV];
    
    UIButton *PhotoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,DXRealValue(64), [UIScreen mainScreen].bounds.size.width/2,DXRealValue(116) )];
    
    [PhotoBtn addTarget:self action:@selector(photoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:PhotoBtn];
    
    //相册上传
    UIImageView *PictureV = [[UIImageView alloc]initWithFrame:CGRectMake(DXRealValue(287), DXRealValue(95.3) ,DXRealValue(46),DXRealValue(35))];
    
    [PictureV setImage:[UIImage imageNamed:@"personal_bg_picture"]];
    
    [self.view addSubview:PictureV];
    
    UIButton *PictBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2,DXRealValue(64), [UIScreen mainScreen].bounds.size.width/2, DXRealValue(116))];
    
    [PictBtn addTarget:self action:@selector(albumButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:PictBtn];
    
    //分割线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 1,DXRealValue(65) ,DXRealValue(0.5) ,DXRealValue(112))];
    
    line.backgroundColor = DXRGBColor(202, 202, 202);
    
    [self.view addSubview:line];
    
    //Label1
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(DXRealValue(78),DXRealValue(143),DXRealValue(40),DXRealValue(30))];
    
    label1.text = @"拍照上传";
    
    [label1 sizeToFit];
    
    label1.centerX = PhotoV.centerX;
    
    label1.textAlignment =  NSTextAlignmentCenter;
    
    label1.textColor = DXRGBColor(177, 177, 177);
    
    label1.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(10)];
    
    [self.view addSubview:label1];
    
    //Label2
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(DXRealValue(288),DXRealValue(143),DXRealValue(40),DXRealValue(30))];
    
    label2.text = @"相册上传";
    
    [label2 sizeToFit];
    
    label2.textColor = DXRGBColor(177, 177, 177);
    
    label2.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(10)];
    
    [self.view addSubview:label2];
}

//设置推荐栏
-(void)setupline{
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,DXRealValue(180) , [UIScreen mainScreen].bounds.size.width,DXRealValue(26))];
    
    line.backgroundColor = DXRGBColor(240, 240, 240);
    
    UILabel *labels = [[UILabel alloc]initWithFrame:CGRectMake(DXRealValue(13.3) ,DXRealValue(5), 0, 0)];
    
    labels.text = @"推荐";
    
    labels.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15)];
    
    [labels sizeToFit];
    
    labels.textColor = DXRGBColor(72, 72, 72);
    
    [self.view addSubview:line];
    
    [line addSubview:labels];

    
}

//设置9张照片
- (void)setupRecommenCovers {
    self.coverImageViewArray = [NSMutableArray array];
    CGFloat outerSpace = DXRealValue(13.3);
    CGFloat innerSpace = DXRealValue(6.6);
    
    for (int i = 0; i<9; i++) {
        
        UIImageView *coverImageView = [[UIImageView alloc]init];
        coverImageView.tag = i + 1;
        @autoreleasepool {
            NSURL * imageURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"big_%d@3x",i+1] withExtension:@"jpg"];
            UIImage * image = [UIImage imageWithContentsOfFile:imageURL.path];
            [coverImageView setImage:image];
        }
        coverImageView.contentMode = UIViewContentModeScaleToFill;
        coverImageView.userInteractionEnabled = YES;
        [self.coverImageViewArray addObject:coverImageView];
        
        int row = i/3;
        int list = i%3;
        
        coverImageView.width = (([UIScreen mainScreen].bounds.size.width)-DXRealValue(40))/3;
        coverImageView.height = (([UIScreen mainScreen].bounds.size.width)-DXRealValue(40))/3;
        coverImageView.x = outerSpace + ((([UIScreen mainScreen].bounds.size.width)-DXRealValue(40))/3 + innerSpace)*list;
        coverImageView.y = outerSpace + ((([UIScreen mainScreen].bounds.size.width)-DXRealValue(40))/3 + innerSpace)*row +DXRealValue(206) ;
        [self.view addSubview:coverImageView];

        UIImageView *selectionView = [[UIImageView alloc]init];
        [selectionView setImage:[UIImage imageNamed:@"personal_bg_pitch_on"]];
        selectionView.hidden = YES;
        selectionView.width = DXRealValue(22.5);
        selectionView.height = DXRealValue(22.5);
        selectionView.x = coverImageView.x + coverImageView.width -selectionView.width - DXRealValue(6);
        selectionView.y = coverImageView.y +coverImageView.height - selectionView.height - DXRealValue(6);
        [self.view addSubview:selectionView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCoverCellTapGesture:)];
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [coverImageView addGestureRecognizer:tapGesture];
        
    }
}

#pragma mark - 推荐图点击动画效果

- (void)handleCoverCellTapGesture:(UITapGestureRecognizer *)tapGesture{
    UIImageView * coverImageView = (UIImageView *)tapGesture.view;
    [self previewCoverImage:coverImageView.image animated:YES completion:nil];
}


- (void)handleCoverPreviewViewTapGesture:(UITapGestureRecognizer *)gesture {
    [self hideCoverImagePreview:YES completion:nil];
}

#pragma mark - 按钮点击事件

//选择视图确认点击
- (void)submitConfirmTapped {
    [self submitNewCover:self.coverImagePreviewView.image];
}

//选择视图取消点击
- (void)submitCancelTapped{
    [self hideCoverImagePreview:YES completion:nil];
}

- (void)photoButtonTapped{
    DXPhotoTakerController * photoTaker = [[DXPhotoTakerController alloc] init];
    photoTaker.delegate = self;
    photoTaker.allowPhotoAdjusting = NO;
    photoTaker.mode = DXPhotoTakerModeCameraOnly;
    photoTaker.enableFixedPhotoScale = YES;
    photoTaker.fixedPhotoScale = DXPhotoScale1x1;
    [self presentViewController:photoTaker animated:YES completion:nil];
}

- (void)albumButtonTapped{
    DXPhotoTakerController * photoTaker = [[DXPhotoTakerController alloc] init];
    photoTaker.delegate = self;
    photoTaker.allowPhotoAdjusting = NO;
    photoTaker.mode = DXPhotoTakerModeAlbumOnly;
    photoTaker.enableFixedPhotoScale = YES;
    photoTaker.fixedPhotoScale = DXPhotoScale1x1;
    [self presentViewController:photoTaker animated:YES completion:nil];
}



#pragma mark -

- (void)previewCoverImage:(UIImage *)coverImage animated:(BOOL)animated completion:(void(^)(void))completion {
    __weak DXProfileCoverUpdateViewController * weakSelf = self;

    if (coverImage) {
        self.coverImagePreviewView.image = coverImage;
    } else {
        self.coverImagePreviewView.image = nil;
    }

    if (animated) {
        self.navigationController.navigationBarHidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.navigationController.navigationBar.y = -64;
            weakSelf.previewOptionView.y = CGRectGetHeight(weakSelf.coverImagePreviewView.bounds);
            weakSelf.coverImagePreviewView.y = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                if (completion) {
                    completion();
                }
            }
        }];
    } else {
        self.navigationController.navigationBar.y = -64;
        self.previewOptionView.y = CGRectGetHeight(self.coverImagePreviewView.bounds);
        self.coverImagePreviewView.y = 0;
        if (completion) {
            completion();
        }
    }
    
    
}

- (void)hideCoverImagePreview:(BOOL)animated completion:(void(^)(void))completion {
    __weak DXProfileCoverUpdateViewController * weakSelf = self;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.navigationController.navigationBar.y = 20;
            weakSelf.coverImagePreviewView.y = -CGRectGetHeight(weakSelf.coverImagePreviewView.bounds);
            weakSelf.previewOptionView.y = DXScreenHeight;
        } completion:^(BOOL finished) {
            if (finished) {
                if (completion) {
                    completion();
                }
            }
        }];
    } else {
        self.navigationController.navigationBar.y = 20;
        self.coverImagePreviewView.y = -CGRectGetHeight(self.coverImagePreviewView.bounds);
        self.previewOptionView.y = DXScreenHeight;
        if (completion) {
            completion();
        }
    }
    
}

- (void)submitNewCover:(UIImage *)cover {
    DXScreenNotice * screenNotice = [[DXScreenNotice alloc] initWithMessage:@"正在上传封面.." fromController:self];
    screenNotice.disableAutoDismissed = YES;
    [screenNotice show];
    
    __weak DXScreenNotice * weakNotice = screenNotice;
    __weak DXProfileCoverUpdateViewController * weakSelf = self;
    NSData * data = UIImageJPEGRepresentation(cover, 0.6);
    
    DXCacheFileManager * fileManager = [DXCacheFileManager sharedManager];
    DXCacheFile * cacheFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeImageCache];
    cacheFile.extension = @"jpg";
    cacheFile.deleteWhenAppLaunch = YES;
    NSError * cacheFileError = nil;
    if ([fileManager saveData:data toFile:cacheFile error:&cacheFileError]) {
        [[DXDongXiApi api] changeCover:cacheFile.url result:^(BOOL success, NSString *url, NSError *error) {
            if (success) {
                [weakNotice updateMessage:@"封面更新成功"];
                [weakNotice dismiss:YES completion:^{
                    [weakSelf hideCoverImagePreview:NO completion:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:DXProfileCoverDidUpdateNotification object:nil userInfo:@{ @"coverImage" : cover }];
                }];
            } else{
                [weakNotice updateMessage:@"封面更新失败"];
                [weakNotice dismiss:YES completion:nil];
            }
        }];
    } else {
        [screenNotice updateMessage:@"封面保存失败"];
        [screenNotice dismiss:YES completion:nil];
    }
}

- (void)photoTaker:(DXPhotoTakerController *)photoTaker didFinishPhoto:(UIImage *)photo {
    __weak DXProfileCoverUpdateViewController * weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf previewCoverImage:photo animated:YES completion:nil];
    }];
}

@end
