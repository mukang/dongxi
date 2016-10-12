//
//  DXConst.h
//  dongxi
//
//  Created by 穆康 on 15/8/4.
//  Copyright (c) 2015年 穆康. All rights reserved.
//


#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const DXName;

/** 通用字体 */
UIKIT_EXTERN NSString *const DXCommonFontName;
/** 通用粗字体 */
UIKIT_EXTERN NSString *const DXCommonBoldFontName;
/** 存放feed数据字典的key */
UIKIT_EXTERN NSString *const kFeedKey;
/** 存放feedID数据字典的key */
UIKIT_EXTERN NSString *const kFeedIDKey;
/** 点赞状态 */
UIKIT_EXTERN NSString *const kLikeStatusKey;
/** 收藏feed的通知名称 */
UIKIT_EXTERN NSString *const DXCollectionFeedNotification;
/** 取消收藏feed的通知名称 */
UIKIT_EXTERN NSString *const DXUncollectionFeedNotification;

/** 刷新消息页列表 */
UIKIT_EXTERN NSString *const DXReloadUnreadMessageNotification;

/** 需要弹出设置感兴趣标签提示 */
UIKIT_EXTERN NSString *const DXShouldShowSetLikeTagAlert;

/** 用户信息已修改 */
UIKIT_EXTERN NSString * const DXProfileDidUpdateNotification;
/** 点赞信息已改变 */
UIKIT_EXTERN NSString * const DXLikeInfoDidChangeNotification;

UIKIT_EXTERN NSString *const kMessage;
UIKIT_EXTERN NSString *const kUserID;
UIKIT_EXTERN NSString *const kUserNick;
UIKIT_EXTERN NSString *const kUserAvatar;
UIKIT_EXTERN NSString *const kUserVerified;

