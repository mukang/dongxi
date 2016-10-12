//
//  DXProfileContentViewController.h
//  dongxi
//
//  Created by 穆康 on 15/8/25.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXTabBarView.h"
#import "DXDongXiApi.h"

@protocol DXProfileContentViewControllerDelegate;


typedef enum : NSUInteger {
    /** 我参与的 */
    DXProfileContentVCTypeJoin = 0,
    /** 我收藏的 */
    DXProfileContentVCTypeCollect
    
} DXProfileContentVCType;



@interface DXProfileContentViewController : UIViewController

@property(nonatomic, copy) NSString *uid;

@property (nonatomic, assign) DXProfileContentVCType type;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, weak) id<DXProfileContentViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL shouldScrollToTop;

/** 是否刷新完毕 */
@property (nonatomic, assign, getter=isRefreshCompletion) BOOL refreshCompletion;

/** 刷新数据 */
- (void)loadNewData;

@end




@protocol DXProfileContentViewControllerDelegate <NSObject>

@optional
- (void)contentController:(DXProfileContentViewController *)contentController didScroll:(UIScrollView *)scrollView;

- (void)contentController:(DXProfileContentViewController *)contentController DidEndDragging:(UIScrollView *)scrollView;

- (void)contentControllerDidEndRefresh:(DXProfileContentViewController *)contentController;

@end
