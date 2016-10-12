//
//  DXImagePlayerViewController.m
//  dongxi
//
//  Created by 穆康 on 15/8/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXImagePlayerViewController.h"
#import "DXWebViewController.h"
#import <UIImageView+WebCache.h>
#import "DXDongXiApi.h"
#import "DXMainNavigationController.h"

NSString *imagePath01 = @"http://img4q.duitang.com/uploads/item/201507/13/20150713094419_v3RrA.thumb.700_0.jpeg";
NSString *imagePath02 = @"http://img5q.duitang.com/uploads/item/201507/20/20150720105639_dS4RK.thumb.700_0.jpeg";
NSString *imagePath03 = @"http://pic72.nipic.com/file/20150714/8684504_111403301398_2.jpg";
NSString *imagePath04 = @"http://img5q.duitang.com/uploads/item/201507/13/20150713091339_xvkNZ.thumb.700_0.jpeg";

static const NSInteger plusNum    = 2;  // 需要加上的数
static const NSInteger imageCount = 3;  // 图片数量

@interface DXImagePlayerViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIPageControl *pageControl;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation DXImagePlayerViewController

#pragma mark - 初始化
- (NSMutableArray *)imageUrls {
    
    if (_imageUrls == nil) {
        _imageUrls = [NSMutableArray array];
    }
    return _imageUrls;
}

- (NSMutableArray *)imageArray {
    
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imageUrls addObjectsFromArray:@[[NSURL URLWithString:imagePath01], [NSURL URLWithString:imagePath02], [NSURL URLWithString:imagePath03], [NSURL URLWithString:imagePath04]]];
    
    [self setupImagePlayer];
    
    [self setupImagePlayerContent];
    
    [self addTimer];
}

- (void)dealloc {
    
    [self removeTimer];
}

- (void)setupImagePlayer {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.frame = CGRectMake(0, 0, DXScreenWidth, DXRealValue(140));
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPage = 0;
    pageControl.centerX = DXScreenWidth * 0.5;
    pageControl.centerY = DXRealValue(130);
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)setPictureShowWrapper:(DXPictureShowWrapper *)pictureShowWrapper {
    
    _pictureShowWrapper = pictureShowWrapper;
    
    self.dataList = self.pictureShowWrapper.list;
    
    for (NSInteger i=0; i<imageCount+plusNum; i++) {
        
        UIImageView *imageView = self.imageArray[i];
        NSInteger imageIndex;
        if (i == 0) {
            imageIndex = imageCount - 1;
        } else if (i == imageCount + 1) {
            imageIndex = 0;
        } else {
            imageIndex = i - 1;
        }
        DXPictureShow *show = self.dataList[imageIndex];
        NSURL *url = [NSURL URLWithString:show.cover];
        [imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed];
    }
}

- (void)setupImagePlayerContent {
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * (imageCount + plusNum), 0);
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0) animated:NO];
    
    self.pageControl.numberOfPages = imageCount;
    
    for (NSInteger i=0; i<imageCount + plusNum; i++) {
        
        CGFloat imageW = self.scrollView.width;
        CGFloat imageH = self.scrollView.height;
        CGFloat imageX = imageW * i;
        NSInteger imageIndex;
        if (i == 0) {
            imageIndex = imageCount - 1;
        } else if (i == imageCount + 1) {
            imageIndex = 0;
        } else {
            imageIndex = i - 1;
        }
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(imageX, 0, imageW, imageH);
        [imageView setTag:imageIndex];
        [imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.scrollView addSubview:imageView];
        [self.imageArray addObject:imageView];
    }
}

#pragma mark - 定时器

- (void)addTimer {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}

- (void)removeTimer {
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 定时器执行的方法

- (void)nextImage {
    
    NSInteger imageCount = self.dataList.count;
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.width;
    
    if (currentPage == 0) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * imageCount, 0) animated:NO];
        currentPage = imageCount - 1;
    } else if (currentPage == imageCount + 1) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0) animated:NO];
        currentPage = 1;
    }
    
    currentPage ++;
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * currentPage, 0) animated:YES];
}

#pragma mark - delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger imageCount = self.dataList.count;
    NSInteger currentPage = scrollView.contentOffset.x / scrollView.width;
    
    if (currentPage == 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.width * imageCount, 0) animated:NO];
        self.pageControl.currentPage = imageCount - 1;
    } else if (currentPage == imageCount + 1) {
        [scrollView setContentOffset:CGPointMake(scrollView.width, 0) animated:NO];
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = currentPage - 1;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    NSInteger imageCount = self.dataList.count;
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.width;
    
    if (currentPage == imageCount + 1) {
        currentPage = 1;
    }
    
    self.pageControl.currentPage = currentPage - 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self removeTimer];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    [self addTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击手势

- (void)imageViewTapped:(UITapGestureRecognizer *)gesture {
    
    if (self.dataList.count == 0) return;
    
    UIView * imageView = gesture.view;
    NSInteger index = imageView.tag;
    
    DXPictureShow *show = self.dataList[index];
    DXMainNavigationController *nav = (DXMainNavigationController *)self.navigationController;
    
    if (show.type == 1) { // 跳转到话题页
        
        [nav pushToTopicViewControllerWithTopicID:show.url info:nil];
        
    } else { // 跳转到h5页面
        
        NSURL * testURL = [NSURL URLWithString:show.url];
        DXWebViewController * webVC = [[DXWebViewController alloc] init];
        webVC.url = testURL;
        webVC.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:webVC animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
