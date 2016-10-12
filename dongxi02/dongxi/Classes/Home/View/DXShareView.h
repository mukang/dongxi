//
//  DXShareView.h
//  dongxi
//
//  Created by 穆康 on 15/10/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXWeChatShareInfo.h"
#import "DXWeiboShareInfo.h"
@class DXTimelineFeed;

typedef NS_ENUM(NSInteger, DXShareViewType) {
    DXShareViewTypeShareOnly,
    DXShareViewTypeCollectionAndShare
};

@protocol DXShareViewDelegate <NSObject>

@optional
/** 微信分享后的代理方法 */
- (void)shareViewDidReceiveWechatResponseStatus:(BOOL)success;
/** 微博分享后的代理方法 */
- (void)shareViewDidReceiveWeiboResponseStatus:(BOOL)success;

@end

@interface DXShareView : UIView

/** 需要收藏的feed */
@property (nonatomic, strong) DXTimelineFeed *feed;
/** 收藏的回调 */
@property (nonatomic, copy) dispatch_block_t collectionBlock;
/** 微信分享所需要的信息 */
@property (nonatomic, strong) DXWeChatShareInfo *weChatShareInfo;
/** 微博分享所需要的信息 */
@property (nonatomic, strong) DXWeiboShareInfo *weiboShareInfo;

@property (nonatomic, weak) id<DXShareViewDelegate> delegate;

/** 唯一的初始化方法 */
- (instancetype)initWithType:(DXShareViewType)type fromController:(UIViewController *)controller;

/** 显示视图 */
- (void)show;

@end



