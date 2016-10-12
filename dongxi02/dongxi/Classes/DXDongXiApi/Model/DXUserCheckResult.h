//
//  DXUserCheckResult.h
//  dongxi
//
//  Created by 穆康 on 16/2/2.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DXUserCheckResultVersion;
@class DXUserCheckResultNotification;

@interface DXUserCheckResult : NSObject

/** 用户喜好是否设置 2未设置 1已设置 */
@property (nonatomic, assign) NSUInteger userlike_isset;
/** 用户昵称是否设置 2未设置 1已设置 */
@property (nonatomic, assign) NSUInteger usernick_isset;
/** 用户版本信息 */
@property (nonatomic, strong) DXUserCheckResultVersion *version;
/** 新消息通知信息 */
@property (nonatomic, strong) DXUserCheckResultNotification *notification;

@end


@interface DXUserCheckResultVersion : NSObject

/** 是否有新版本 1有新版本 0没有新版本 */
@property (nonatomic, assign) BOOL update;
/** 新版本build号 */
@property (nonatomic, assign) NSUInteger build;
/** 新版本号 */
@property (nonatomic, copy) NSString *ver;
/** 提示内容 */
@property (nonatomic, copy) NSString *txt;
/** 是否强制更新 1是 2不是 */
@property (nonatomic, assign) NSUInteger type;
/** 新版本下载链接 */
@property (nonatomic, copy) NSString *url;

@end


@interface DXUserCheckResultNotification : NSObject

/** 是否有新消息 1有新消息 0没有新消息 */
@property (nonatomic, assign) BOOL status;
/** 赞 1有新消息 0没有新消息 */
@property (nonatomic, assign) BOOL like;
/** 评论 1有新消息 0没有新消息 */
@property (nonatomic, assign) BOOL comment;
/** 通知 1有新消息 0没有新消息 */
@property (nonatomic, assign) BOOL notice;

@end




