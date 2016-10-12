//
//  DXDongXiApi.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DXUserEnum.h"
#import "DXUserRegisterInfo.h"
#import "DXUserLoginInfo.h"
#import "DXUserSession.h"
#import "DXUserSms.h"
#import "DXUserSmsCheck.h"
#import "DXUserProfile.h"
#import "DXUserProfileChange.h"
#import "DXUser.h"
#import "DXRankUser.h"
#import "DXUserWrapper.h"
#import "DXDiscoverUser.h"
#import "DXDiscoverUserWrapper.h"
#import "DXUserFeedback.h"
#import "DXUserCheckResult.h"
#import "DXReferUserWrapper.h"

#import "DXUserPasswordChangeInfo.h"
#import "DXUserPasswordResetInfo.h"

#import "DXUserCoupon.h"
#import "DXUserCouponWrapper.h"

#import "DXPictureShowWrapper.h"
#import "DXPictureShow.h"
#import "DXTimelineFeedWrapper.h"
#import "DXTimelineFeed.h"
#import "DXContentPiece.h"
#import "DXTimelineRecommendation.h"
#import "DXLikeRankUserWrapper.h"
#import "DXTopicPost.h"
#import "DXTopic.h"
#import "DXTopicFeedList.h"
#import "DXTopicInviteFollowList.h"
#import "DXTopicInviteFansList.h"
#import "DXTopicRankUserWrapper.h"

#import "DXActivity.h"

#import "DXMessageNewDetail.h"

#import "DXNotice.h"
#import "DXNoticeList.h"

#import "DXNoticeLike.h"
#import "DXNoticeLikeList.h"

#import "DXNoticeComment.h"
#import "DXNoticeCommentList.h"
#import "DXNoticeCommentWrapper.h"

#import "DXMessageDiscuss.h"
#import "DXMessageDiscussList.h"

#import "DXDiscuss.h"
#import "DXDiscussList.h"

#import "DXComment.h"
#import "DXCommentList.h"
#import "DXCommentPost.h"

#import "DXSearchTopicWrapper.h"
#import "DXSearchUserWrapper.h"
#import "DXSearchActivityWrapper.h"
#import "DXSearchFeedWrapper.h"
#import "DXSearchHotKeywords.h"
#import "DXSearchResults.h"

#import "DXTopAndHotTopicList.h"
#import "DXCollectedTopicList.h"

#import "DXWatermark.h"

#import "DXTag.h"
#import "DXTagWrapper.h"

#import "DXChatMessage.h"

#import "DXWechatLoginInfo.h"
#import "DXWechatRegisterInfo.h"


#import "DXFeedHomeList.h"
#import "DXFeed.h"

#pragma mark 常量定义

typedef enum : NSUInteger {
    DXDataListPullFirstTime = 0,
    DXDataListPullOlderList,
    DXDataListPullNewerList,
} DXDataListPullType;

typedef enum : NSInteger {
    DXDiscussMsgTypeText = 1,
    DXDiscussMsgTypeVoice
} DXDiscussMsgType;

typedef NS_ENUM(NSInteger, DXUnreadMessageType) {
    DXUnreadMessageTypeNotice = 1,
    DXUnreadMessageTypeComment,
    DXUnreadMessageTypeLike
};

typedef NS_ENUM(NSInteger, DXWechatLoginStatus) {
    DXWechatLoginStatusNeedBindingMobile = 0,
    DXWechatLoginStatusSuccess,
    DXWechatLoginStatusFailed
};

typedef NS_ENUM(NSInteger, DXWechatRegisterStatus) {
    DXWechatRegisterStatusMobileHasBinded = 0,
    DXWechatRegisterStatusSuccess,
    DXWechatRegisterStatusFailed
};

typedef NS_OPTIONS(NSUInteger, DXUserCheckType) {
    DXUserCheckTypeNewVersion   = 1 << 0,
    DXUserCheckTypeNotification = 1 << 1,
    DXUserCheckTypeSetNick      = 1 << 2,
    DXUserCheckTypeSetLike      = 1 << 3
};

extern NSString * const DXDongXiApiNotificationUserDidLogin;
extern NSString * const DXDongXiApiNotificationUserDidLogout;

extern NSString * const DXClientRequestErrorDomain;
extern NSString * const DXClientRequestOriginErrorDescriptionKey;

#pragma mark - DXDongXiApi -


@interface DXDongXiApi : NSObject 

/**
 *  获取api实例
 *
 *  @return 返回DXDongXiApi实例
 */
+ (instancetype)api;

/*****************************************************************************
 *
 * 设备相关
 *
 *****************************************************************************/
#pragma mark - 设备相关

/**
 *  准备工作
 */
- (void)prepareForWorking:(void(^)(NSError * error))completion;

@property (nonatomic, assign, readonly, getter=isPrepared) BOOL prepared;


/*****************************************************************************
 *
 * 用户会话相关
 *
 *****************************************************************************/
#pragma mark - 用户会话相关

/**
 *  检查是否需要重新登录
 *
 *  @return 返回BOOL类型的值，YES表示需要，NO表示不需要
 */
- (BOOL)needLogin;

/**
 *  获取当前已登陆用户的会话
 *
 *  @return 返回DXUserSession实例，返回nil表示当前没有保留的已登陆会话或会话已过期
 */
- (DXUserSession *)currentUserSession;

/**
 *  更新会话中的用户头像
 *
 *  @param avatar 用户头像地址
 */
- (void)updateSessionAvatar:(NSString *)avatar;

/*****************************************************************************
 *
 * 用户相关操作
 *
 *****************************************************************************/

#pragma mark - 用户注册、登录相关操作

/**
 *  验证邮箱是否已被使用，不会检查登录状态
 *
 *  @param email  需要验证的邮箱
 *  @param result 验证结果回调，valid为true表示有效，无效原因见error的code和userInfo
 */
- (void)isEmail:(NSString *)email valid:(void(^)(BOOL valid, NSError * error))result;

/**
 *  验证用户名是否已被使用，不会检查登录状态
 *
 *  @param username 需要验证的用户名
 *  @param result   验证结果回调，valid为YES表示有效，无效原因见error的code和userInfo
 */
- (void)isUsername:(NSString *)username valid:(void(^)(BOOL valid, NSError * error))result;

/**
 *  验证手机号是否已被使用，不会检查登录状态
 *
 *  @param mobile 需要验证的手机号
 *  @param result 验证结果回调，valid为YES表示有效，无效原因见error的code和userInfo
 */
- (void)isMobile:(NSString *)mobile valid:(void(^)(BOOL valid, NSError * error))result;

/**
 *  注册一个新用户，不会检查登录状态
 *
 *  @param userRegisterInfo 用户注册信息，DXUserRegisterInfo对象
 *  @param resultBlock      结果回调，success为YES表示成功，失败原因见error的code和userInfo
 */
- (void)registerUser:(DXUserRegisterInfo *)userRegisterInfo result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  用户登录，不会检查登录状态，登录后会保留登录状态
 *
 *  @param loginInfo   用户登录信息，DXUserLoginInfo对象
 *  @param resultBlock 结果回调，user为nil时表示登录失败，失败原因见error的code和userInfo
 */
- (void)login:(DXUserLoginInfo *)loginInfo result:(void(^)(DXUserSession *user, NSError * error))resultBlock;

/**
 *  用户登录，不会检查登录状态，登录后会保留登录状态(新增参数newRegistered)
 */
- (void)login:(DXUserLoginInfo *)loginInfo isNewRegistered:(BOOL)newRegistered result:(void(^)(DXUserSession *user, NSError * error))resultBlock;

/**
 *  用户注销，会检查登录状态，已登陆的会撤销登录状态，未登录的情况下会直接返回成功
 *
 *  @param resultBlock 结果回调，success为YES表示成功，失败原因见error的code和userInfo
 */
- (void)logoutWithResult:(void(^)(BOOL success, NSError * error))resultBlock;


/**
 *  发送注册短信验证码，不会检查登录状态
 *
 *  @param sms         手机信息，DXUserSms对象
 *  @param resultBlock 结果回调，success为YES表示短信发送成功，失败原因见error的code和userInfo
 */
- (void)sendSms:(DXUserSms *)sms result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  验证手机注册短信验证码，不会检查登录状态
 *
 *  @param smsCheck    手机短信验证，DXUserSmsCheck
 *  @param resultBlock 结果回调，valid为YES表示注册短信验证成功，失败原因见error的code和userInfo
 */
- (void)checkSms:(DXUserSmsCheck *)smsCheck result:(void(^)(BOOL valid, NSError * error))resultBlock;


/**
 *  验证重置密码的短信验证码是否有效
 *
 *  @param code        短信验证码
 *  @param uid         用户DXUser的uid
 *  @param resultBlock 结果回调，valid为YES表示注册短信验证成功，失败原因见error的code和userInfo
 */
- (void)checkResetPasswordSmsCode:(NSString *)code forUser:(NSString *)uid result:(void(^)(BOOL valid, NSError * error))resultBlock;

/**
 *  刷新用户session
 *
 *  @param resultBlock 回调结果
 */
- (void)flushUserSession:(void(^)(BOOL success, NSError *error))resultBlock;

#pragma mark - 微信登录相关操作

/**
 *  微信登录
 *
 *  @param loginInfo   微信登录信息
 *  @param resultBlock 回调结果
 */
- (void)loginWithWechatLoginInfo:(DXWechatLoginInfo *)loginInfo result:(void(^)(DXWechatLoginStatus loginStatus, DXUserSession *user, NSError * error))resultBlock;

/**
 *  发送微信绑定手机号的短信验证码
 *
 *  @param sms         手机信息，DXUserSms对象
 *  @param resultBlock 回调结果
 */
- (void)sendWechatSms:(DXUserSms *)sms result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  微信绑定手机号并注册用户，注册成功后直接登录
 *
 *  @param registerInfo 注册信息
 *  @param resultBlock  回调结果
 */
- (void)registerWechatUser:(DXWechatRegisterInfo *)registerInfo result:(void(^)(DXWechatRegisterStatus registerStatus, DXUserSession *session, NSError *error))resultBlock;

#pragma mark - 用户密码相关操作

/**
 *  修改密码，会检查登录状态
 *
 *  @param info        密码修改信息，见DXUserPasswordChangeInfo
 *  @param resultBlock 结果回调，status见DXUserChangePasswordStatus定义，失败原因见error的code和userInfo
 */
- (void)changePasswordWithInfo:(DXUserPasswordChangeInfo *)info result:(void(^)(DXUserChangePasswordStatus status, NSError * error))resultBlock;

/**
 *  发送重置密码短信验证码，不会检查登录状态
 *
 *  @param sms         手机信息，DXUserSms对象
 *  @param resultBlock 结果回调，status见DXUserResetPassSmsStatus定义，nick为手机号对应用户的昵称，uid为手机号对应用户的uid，失败原因见error的code和userInfo
 */
- (void)sendResetPasswordSms:(DXUserSms *)sms result:(void(^)(DXUserResetPassSmsStatus status, NSString * nick, NSString * uid, NSError * error))resultBlock;

/**
 *  重置密码，不会检查登录状态
 *
 *  @param info        密码重置信息，见DXUserPasswordResetInfo
 *  @param resultBlock 结果回调，status见DXUserResetPasswordStatus定义，失败原因见error的code和userInfo
 */
- (void)resetPasswordWithInfo:(DXUserPasswordResetInfo *)info result:(void(^)(DXUserResetPasswordStatus status, NSError * error))resultBlock;


#pragma mark - 用户资料相关操作

/**
 *  获取用户详细资料
 *
 *  @discussion 无需登录
 *
 *  @param uid         用户的uid
 *  @param resultBlock 结果回调，profile为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)getProfileOfUser:(NSString *)uid result:(void(^)(DXUserProfile *profile, NSError * error))resultBlock;


/**
 *  通过用户名称/昵称获取用户详细资料
 *
 *  @param nick        用户名称/昵称
 *  @param resultBlock 结果回调，profile为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)getProfileOfUserByNick:(NSString *)nick result:(void(^)(DXUserProfile *profile, NSError * error))resultBlock;

/**
 *  批量获取用户昵称和头像
 *
 *  @param userIDs     用户id数组
 *  @param resultBlock 结果回调，error为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getUserInfoListWithUserIDs:(NSArray *)userIDs result:(void(^)(DXUserWrapper * userWrapper, NSError * error))resultBlock;

/**
 *  更新用户资料，会检查登录状态
 *
 *  @param profileChange 需要修改的用户资料内容，设置了哪些字段就会修改哪些字段
 *  @param resultBlock   结果回调，success为YES表示修改成功，失败原因见error的code和userInfo
 */
- (void)changeProfile:(DXUserProfileChange *)profileChange result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  修改用户头像，会检查登录状态
 *
 *  @param avatarURL   头像文件地址，必须为本地文件路径
 *  @param resultBlock 结果回调，success为YES表示修改成功，失败原因见error的code和userInfo
 */
- (void)changeAvatar:(NSURL *)avatarURL result:(void(^)(BOOL success, NSString * url, NSError * error))resultBlock;

/**
 *  修改用户封面，会检查登录状态
 *
 *  @param coverURL    封面文件地址，必须为本地文件路径
 *  @param resultBlock 结果回调，success为YES表示修改成功，失败原因见error的code和userInfo
 */
- (void)changeCover:(NSURL *)coverURL result:(void(^)(BOOL success, NSString * url, NSError * error))resultBlock;

/**
 *  发送用户意见反馈
 *
 *  @param feedback    意见反馈信息，DXUserFeedback对象
 *  @param resultBlock 结果回调，success为YES表示修改成功，失败原因见error的code和userInfo
 */
- (void)sendUserFeeback:(DXUserFeedback *)feedback result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  检查用户设置信息及应用新版本
 *
 *  @param checkType   检查类型
 *  @param resultBlock 结果回调，error有值表示检查失败，失败原因见error的code和userInfo
 */
- (void)checkUserInfoAndAppVersionWithCheckType:(DXUserCheckType)checkType result:(void(^)(DXUserCheckResult *userCheckResult, NSError *error))resultBlock;

#pragma mark - 用户关系相关操作


/**
 *  关注一个指定用户
 *
 *  @param uid         想要关注的用户的uid
 *  @param resultBlock 结果回调，success为YES表示关注成功，sucess为NO表示已经关注，error不为nil表示失败，原因见error的code和userInfo
 */
- (void)followUser:(NSString *)uid result:(void(^)(BOOL success, DXUserRelationType relation, NSError * error))resultBlock;


/**
 *  取消关注一个指定用户
 *
 *  @param uid         想要关注的用户的uid
 *  @param resultBlock 结果回调，success为YES表示取消关注成功，sucess为NO表示并没有关注该用户，error不为nil表示失败，原因见error的code和userInfo
 */
- (void)unfollowUser:(NSString *)uid result:(void(^)(BOOL success, DXUserRelationType relation, NSError * error))resultBlock;


/**
 *  获取关注列表
 *
 *  @param uid         想要获取哪个用户的关注列表
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的DXUser的ID
 *  @param resultBlock 结果回调，error为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getFollowListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXUserWrapper * userWrapper, NSError * error))resultBlock;

/**
 *  获取粉丝列表
 *
 *  @param uid         想要获取哪个用户的粉丝列表
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的DXUser的ID
 *  @param resultBlock 结果回调，error为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getFanListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXUserWrapper * userWrapper, NSError * error))resultBlock;

#pragma mark - 邀请码相关

/**
 *  是否开启邀请注册(由后台控制)
 *
 *  @param resultBlock 回调结果
 */
- (void)checkInvitationStatusWithResult:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  获取邀请码列表
 *
 *  @param resultBlock 结果回调，couponWrapper为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getUserCouponList:(void(^)(DXUserCouponWrapper * couponWrapper, NSError * error))resultBlock;

/**
 *  发送邀请码
 *
 *  @param code        邀请码
 *  @param resultBlock 结果回调，success为NO表示发送失败，失败原因见error的code和userInfo
 */
- (void)sendUserCouponWithCode:(NSString *)code result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  使用邀请码
 *
 *  @param code        邀请码
 *  @param resultBlock 结果回调，success为NO表示使用失败，失败原因见error的code和userInfo
 */
- (void)useUserCouponWithCode:(NSString *)code result:(void(^)(BOOL success, NSError *error))resultBlock;
/**
 *  申请邀请码
 *
 *  @param mobile      手机号
 *  @param resultBlock 结果回调，success为NO表示申请失败，失败原因见error的code和userInfo
 */
- (void)getUserCouponWithMobile:(NSString *)mobile result:(void(^)(BOOL success, NSError *error))resultBlock;

#pragma mark - 图片轮播
/**
 *  获取图片轮播数据
 *
 *  @param resultBlock 结果回调，error为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getPictureShowList:(void(^)(DXPictureShowWrapper * pictureShowWrapper, NSError * error))resultBlock;


/*****************************************************************************
 *
 * Feed相关操作
 *
 *****************************************************************************/

#pragma mark - Feed相关操作 -


#pragma mark 首页－精选话题Feed
/**
 *  获取时间线－精选列表
 *
 *  @discussion 支持在未登陆时调用
 *
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID，例如pullType选DXDataListPullOlderList，ID为"500"，表示获取比ID为500的feed更早的数据
 *  @param resultBlock 结果回调，feedWrapper不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getTimelineHotList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTimelineFeedWrapper * feedWrapper, NSError * error))resultBlock;

/**
 *  获取时间线－精选列表(新接口)
 *
 *  @param pullType       拉取方式
 *  @param count          拉取的feed数量
 *  @param ID             拉取数据时所参考的feed的ID
 *  @param userTimestamp  (推荐用户)时间戳，用来和服务器沟通是否需要更新推荐信息
 *  @param topicTimestamp (推荐话题)时间戳，用来和服务器沟通是否需要更新推荐信息
 *  @param resultBlock    结果回调
 */
- (void)getTimelineHotList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID userTimestamp:(NSUInteger)userTimestamp topicTimestamp:(NSUInteger)topicTimestamp result:(void(^)(DXTimelineFeedWrapper * feedWrapper, NSError * error))resultBlock;


#pragma mark 首页－关注话题Feed
/**
 *  获取时间线－关注列表
 *
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID
 *  @param resultBlock 结果回调，feedWrapper不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getTimelinePublicList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTimelineFeedWrapper * feedWrapper, NSError * error))resultBlock;


#pragma mark 首页－最新Feed列表
/**
 *  获取时间线－最新列表
 *
 *  @discussion 支持在未登陆时调用
 *
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID，例如pullType选DXDataListPullOlderList，ID为"500"，表示获取比ID为500的feed更早的数据
 *  @param resultBlock 结果回调，feedWrapper不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getTimelineNewestList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTimelineFeedWrapper * feedWrapper, NSError * error))resultBlock;


#pragma mark 用户参与的话题Feed
/**
 *  获取指定用户参与过的话题feed
 *
 *  @discussion 无需登录
 *
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID
 *  @param resultBlock 结果回调，feedWrapper不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getPrivateFeedListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTimelineFeedWrapper * feedWrapper, NSError * error))resultBlock;




#pragma mark 用户收藏的话题Feed
/**
 *  获取指定用户收藏过的话题feed
 *
 *  @discussion 无需登录
 *
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID
 *  @param resultBlock 结果回调，feedWrapper不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getSavedFeedListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTimelineFeedWrapper * feedWrapper, NSError * error))resultBlock;

#pragma mark 点赞
/**
 *  点赞
 *
 *  @param feedID      feedID
 *  @param resultBlock 结果回调，success为YES表示点赞成功
 */
- (void)likeFeedWithFeedID:(NSString *)feedID result:(void(^)(BOOL success, NSError * error))resultBlock;

#pragma mark 取消赞
/**
 *  取消赞
 *
 *  @param feedID      feedID
 *  @param resultBlock 结果回调，success为YES表示取消赞成功
 */
- (void)unlikeFeedWithFeedID:(NSString *)feedID result:(void(^)(BOOL success, NSError * error))resultBlock;

#pragma mark 收藏Feed
/**
 *  收藏Feed
 *
 *  @param feedID      feedID
 *  @param resultBlock 结果回调，success为YES表示收藏成功
 */
- (void)saveFeedWithFeedID:(NSString *)feedID result:(void(^)(BOOL success, NSError * error))resultBlock;

#pragma mark 取消收藏Feed
/**
 *  取消收藏Feed
 *
 *  @param feedID      feedID
 *  @param resultBlock 结果回调，success为YES表示取消收藏成功
 */
- (void)unsaveFeedWithFeedID:(NSString *)feedID result:(void(^)(BOOL success, NSError * error))resultBlock;


#pragma mark 根据feedID获得对应DXTimelineFeed数据
/**
 *  根据feedID获得对应DXTimelineFeed数据
 *
 *  @discussion 无需登录
 *
 *  @param feedID      DXTimelineFeed对象的fid
 *  @param resultBlock 结果回调，feed不为nil时表示获取成功，失败原因见error的code和userInfo
 */
- (void)getFeedWithID:(NSString *)feedID result:(void(^)(DXTimelineFeed * feed, NSError * error))resultBlock;


#pragma mark 获取某个Feed的点赞用户列表
/**
 *  获取某个Feed的点赞用户列表
 *
 *  @discussion 无需登录
 *
 *  @param feedID      DXTimelineFeed的fid
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的DXTimelineFeed对象的ID
 *  @param resultBlock 结果回调，userList不为nil时表示获取成功，失败原因见error的code和userInfo
 */
- (void)getLikeUsersOfFeed:(NSString *)feedID pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXUserWrapper * users, NSError * error))resultBlock;

#pragma mark 删除某个Feed
/**
 *  删除某个Feed
 *
 *  @param feedID      feedID
 *  @param resultBlock 结果回调，success为NO表示删除失败，失败原因见error的code和userInfo
 */
- (void)deleteFeedWithFeedID:(NSString *)feedID result:(void(^)(BOOL success, NSError * error))resultBlock;

#pragma mark 举报某个Feed
/**
 *  举报某个Feed
 *
 *  @param feedID      feedID
 *  @param type        举报类型
 *  @param resultBlock 结果回调，success为NO表示举报失败，失败原因见error的code和userInfo
 */
- (void)reportFeedWithFeedID:(NSString *)feedID type:(NSInteger)type result:(void(^)(BOOL success, NSError * error))resultBlock;

#pragma mark 通知服务器分享了某个Feed
/**
 *  通知服务器分享了某个Feed
 *
 *  @param feedID      feedID
 *  @param scene       分享到的场景
 *  @param resultBlock 结果回调
 */
- (void)postFeedIsSharedWithFeedID:(NSString *)feedID toScene:(NSString *)scene result:(void(^)(BOOL success, NSError *error))resultBlock;

#pragma mark 引用联系人列表
/**
 *  引用联系人列表
 *
 *  @param resultBlock 结果回调
 */
- (void)getReferContacts:(void(^)(NSArray *recentContacts, NSArray *allContacts, NSError *error))resultBlock;

#pragma mark 引用话题列表
/**
 *  引用话题列表
 *
 *  @param resultBlock 结果回调
 */
- (void)getReferTopics:(void(^)(NSArray *recentTopics, NSArray *allTopics, NSError *error))resultBlock;

#pragma mark 修改feed
/**
 *  修改feed
 *
 *  @param topicPost     修改后的内容
 *  @param progressBlock 进度回调
 *  @param resultBlock   结果回调
 */
- (void)updateFeedWithPost:(DXTopicPost *)topicPost progress:(void(^)(float percent))progressBlock result:(void(^)(DXTimelineFeed * feed, NSError * error))resultBlock;

#pragma mark - 一周红人榜
/**
 *  一周红人榜
 *
 *  @param resultBlock 结果回调
 */
- (void)getLikeRankUserWrapper:(void(^)(DXLikeRankUserWrapper *rankUserWrapper, NSError *error))resultBlock;

#pragma mark - 话题相关


/**
 *  获取默认的话题topic_id，当用户发表内容没有选择话题时，服务器会默认使用该topic_id
 *
 *  @param resultBlock 结果回调，topic_id为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getDefaultTopicID:(void(^)(NSString * topic_id, NSError * error))resultBlock;

/**
 *  获取话题列表，可以取得包含话题DXTopic对象的数组(此接口已废弃)
 *
 *  @discussion 支持在未登陆时调用
 *
 *  @param resultBlock resultBlock 结果回调，topics不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getTopics:(void(^)(NSArray *topics, NSError * error))resultBlock;

/**
 *  获取推荐和热门话题列表(此接口暂时废弃)
 *
 *  @param resultBlock 结果回调，error为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getTopAndHotTopicListWithLastID:(NSString *)lastID pullType:(DXDataListPullType)pullType count:(NSUInteger)count result:(void(^)(DXTopAndHotTopicList *topAndHotTopicList, NSError *error))resultBlock;

/**
 *  获取推荐和热门话题列表
 *
 *  @param resultBlock 结果回调，error为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getTopAndHotTopicList:(void(^)(DXTopAndHotTopicList *topAndHotTopicList, NSError *error))resultBlock;

/**
 *  获取收藏话题列表
 *
 *  @param resultBlock 结果回调，error为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getCollectedTopicListWithLastID:(NSString *)lastID pullType:(DXDataListPullType)pullType count:(NSUInteger)count result:(void(^)(DXCollectedTopicList *collectedTopicList, NSError *error))resultBlock;

/**
 *  收藏某个话题
 *
 *  @param resultBlock 结果回调，error为nil表示收藏成功，失败原因见error的code和userInfo
 */
- (void)collectTopicWithTopicID:(NSString *)topicID result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  取消收藏某个话题
 *
 *  @param resultBlock 结果回调，error为nil表示取消收藏成功，失败原因见error的code和userInfo
 */
- (void)cancelCollectTopicWithTopicID:(NSString *)topicID result:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 *  参与话题发表内容
 *
 *  @param topicPost   参与话题时发表的内容，DXTopicPost对象
 *  @param resultBlock resultBlock 结果回调，feed不为nil表示发表成功，失败原因见error的code和userInfo
 */
- (void)postToTopic:(DXTopicPost *)topicPost progress:(void(^)(float percent))progressBlock result:(void(^)(DXTimelineFeed * feed, NSError * error))resultBlock;



/**
 *  获取话题详情＋话题下的Feed（最新）列表
 *
 *  @discussion 无需用户登录
 *
 *  @param topicID     话题ID
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID
 *  @param resultBlock 结果回调，error不为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getTopicFeedList:(NSString *)topicID pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTopicFeedList * topicFeedList, NSError * error))resultBlock;


/**
 *  获取话题详情＋话题下的Feed（精选）列表
 *
 *  @discussion 无需用户登录
 *
 *  @param topicID     话题ID
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID
 *  @param resultBlock 结果回调，error不为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getHotTopicFeedList:(NSString *)topicID pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTopicFeedList * topicFeedList, NSError * error))resultBlock;


/**
 *  获取指定用户（uid）在某话题（topicID）下对已关注用户的邀请列表
 *
 *  @param topicID     话题id
 *  @param uid         用户id
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的user的id
 *  @param resultBlock 结果回调，followList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getTopicInviteFollowList:(NSString *)topicID ofUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTopicInviteFollowList * followList, NSError * error))resultBlock;

/**
 *  获取指定用户（uid）在某话题（topicID）下对粉丝用户的邀请列表
 *
 *  @param topicID     话题id
 *  @param uid         用户id
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的user的id
 *  @param resultBlock 结果回调，fansList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getTopicInviteFansList:(NSString *)topicID ofUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void(^)(DXTopicInviteFansList * fansList, NSError * error))resultBlock;


/**
 *  邀请某人参加某话题
 *
 *  @param uid         想要邀请的人的uid
 *  @param topicID     话题的topic_id
 *  @param resultBlock 结果回调，success为YES时表明邀请成功，为NO且error为nil时表示已邀请过，error不为nil表示邀请失败，失败原因见error的code和userInfo
 */
- (void)inviteUser:(NSString *)uid joinTopic:(NSString *)topicID result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  获取话题用户积分排行榜
 *
 *  @param topicID     话题id
 *  @param resultBlock 回调结果
 */
- (void)getTopicRankUserWrapperByTopicID:(NSString *)topicID result:(void(^)(DXTopicRankUserWrapper *rankUserWrapper, NSError *error))resultBlock;


/*****************************************************************************
 *
 * 活动相关操作
 *
 *****************************************************************************/

#pragma mark - 活动相关

/**
 *  获取活动列表
 *
 *  @discussion 无需登录
 *
 *  @param resultBlock 结果回调，error不为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getActivityList:(void(^)(NSArray * activityList, NSError * error))resultBlock;


/**
 *  获取指定activity_id的活动信息
 *
 *  @discussion 无需登录
 *
 *  @param activity_id 活动的activity_id
 *  @param resultBlock 结果回调，activity为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getActivityByID:(NSString *)activity_id result:(void(^)(DXActivity * activity, NSError * error))resultBlock;


/**
 *  想要参加某活动
 *
 *  @param activityID  活动ID
 *  @param resultBlock 结果回调，success为NO表示未能成功参加，失败原因见error的code和userInfo
 */
- (void)wantToJoinActivity:(NSString *)activityID result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  对某活动进行评论
 *
 *  @param activityID  活动ID
 *  @param stars       给予星星的数量
 *  @param text        评论内容
 *  @param resultBlock 结果回调，success为NO表示未能成功评论，失败原因见error的code和userInfo
 */
- (void)remarkOnActivity:(NSString *)activityID stars:(NSUInteger)stars text:(NSString *)text result:(void(^)(BOOL success, NSError * error))resultBlock;


/*****************************************************************************
 *
 * 消息相关操作
 *
 *****************************************************************************/

#pragma mark - 消息相关操作
#pragma mark 检查是否有新消息
/**
 *  检查是否有新消息(该接口已废除)
 *
 *  @param resultBlock 回调结果
 */
- (void)checkNewMessageResult:(void(^)(DXMessageNewDetail *newDetail, BOOL hasNew, NSError *error))resultBlock;
#pragma mark 通知服务器消息已读
/**
 *  通知服务器消息已读
 *
 *  @param type        消息类型
 *  @param resultBlock 回调结果
 */
- (void)postUnreadMessageDidReadWithMessageType:(DXUnreadMessageType)type result:(void(^)(BOOL success, NSError * error))resultBlock;
#pragma mark 获取通知列表
/**
 *  获取通知列表
 *
 *  @param count       预期数量，当实际数量不足时，返回的结果数量会比预期数量少
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param lastID      拉取列表时参考的DXNotice的ID
 *  @param resultBlock 结果回调，noticeList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getMessageNoticeList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void(^)(DXNoticeList * noticeList, NSError * error))resultBlock;

#pragma mark 删除通知条目
/**
 *  删除通知条目或者赞条目
 *
 *  @param ID          ID
 *  @param resultBlock 回调
 */
- (void)deleteMessageNoticeOrLikeByID:(NSString *)ID result:(void(^)(BOOL success, NSError * error))resultBlock;

#pragma mark 获取消息点赞列表
/**
 *  获取消息点赞列表
 *
 *  @param count       预期数量，当实际数量不足时，返回的结果数量会比预期数量少
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param lastID      拉取列表时参考的DXNoticeLike的ID
 *  @param resultBlock 结果回调，noticeLikeList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getMessageNoticeLikeList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void(^)(DXNoticeLikeList * noticeLikeList, NSError * error))resultBlock;

#pragma mark 获取消息评论列表
/**
 *  获取消息评论列表
 *
 *  @param count       预期数量，当实际数量不足时，返回的结果数量会比预期数量少
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param lastID      拉取列表时参考的DXNoticeComment的ID
 *  @param resultBlock 结果回调，noticeCommentList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getMessageNoticeCommentList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void(^)(DXNoticeCommentList *commentList, NSError * error))resultBlock;

/*****************************************************************************
 *
 * 私聊相关操作
 *
 *****************************************************************************/

#pragma mark - 私聊相关操作

/**
 *  获取私聊列表
 *
 *  @param count       预期数量，当实际数量不足时，返回的结果数量会比预期数量少
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param lastID      拉取新数据时最新一条数据的ID
 *  @param getCount    拉去旧数据时当前已拉取的条数，其他情况传0
 *  @param resultBlock 结果回调，messageDiscussList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getMessageDiscussList:(NSInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID getCount:(NSInteger)getCount result:(void(^)(DXMessageDiscussList * messageDiscussList, NSError * error))resultBlock;

/**
 *  删除聊天条目
 *
 *  @param userID      聊天对象的uid
 *  @param resultBlock 结果回调，success为YES表示删除成功
 */
- (void)deleteMessageDiscussByUserID:(NSString *)userID result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  设置已读
 *
 *  @param userID      聊天对象的uid
 *  @param resultBlock 结果回调，success为YES表示设置已读成功
 */
- (void)messageDiscussSetReadByUserID:(NSString *)userID result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  获取聊天记录列表
 *
 *  @param userID      聊天对象的uid
 *  @param count       预期数量，当实际数量不足时，返回的结果数量会比预期数量少
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param lastID      拉取旧数据时为第一条数据的ID，注意：没有拉取新数据
 *  @param resultBlock 结果回调，discussList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getDiscussListByUserID:(NSString *)userID count:(NSInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void(^)(DXDiscussList * discussList, NSError * error))resultBlock;

/**
 *  发送消息
 *
 *  @param userID      聊天对象的uid
 *  @param text        消息内容，如果是语音消息text为环信返回的消息ID
 *  @param msgType     消息类型，DXDiscussMsgTypeText文本消息，DXDiscussMsgTypeVoice语音消息
 *  @param isOline     聊天对象是否在线(注意：由于客户端无法获知对方用户是否在线，此处传0)
 *  @param resultBlock 结果回调，success为YES表示发送成功
 */
- (void)sendDiscussMsgToUserID:(NSString *)userID withText:(NSString *)text msgType:(DXDiscussMsgType)msgType isOline:(BOOL)isOline result:(void(^)(BOOL success, NSError * error))resultBlock;

/**
 *  根据私聊对象，获取私聊消息 - 2016.04.11新增
 *
 *  @param userID      私聊对象的id
 *  @param count       获取消息条数
 *  @param messageID   消息id，通过此条消息id，获取之前的消息
 *  @param resultBlock 回调结果
 */
- (void)getChatListWithUserID:(NSString *)userID count:(NSInteger)count messageID:(NSString *)messageID result:(void(^)(NSDictionary *data, NSError *error))resultBlock;

/**
 *  获取会话列表 - 2016.04.11新增
 *
 *  @param resultBlock 回调结果
 */
- (void)getConversations:(void(^)(NSDictionary *data, NSError *error))resultBlock;

/**
 *  备份消息 - 2016.04.11新增
 *
 *  @param chatMessage 消息
 *  @param resultBlock 回调结果
 */
- (void)backupMessageWithChatMessage:(DXChatMessage *)chatMessage result:(void(^)(BOOL success, NSError *error))resultBlock;


- (void)upLoadMessageFileWithFileType:(NSInteger)fileType fileURL:(NSURL *)fileURL result:(void(^)(NSString *fileID, NSError *error))resultBlock;

/**
 *  设置消息已读 - 2016.04.11新增
 *
 *  @param userID      聊天对象的id
 *  @param resultBlock 回调结果
 */
- (void)setMessagesAsReadByUserID:(NSString *)userID result:(void(^)(BOOL success, NSError *error))resultBlock;

/*****************************************************************************
 *
 * 评论相关
 *
 *****************************************************************************/

#pragma mark - 评论相关
#pragma mark 获取评论列表
/**
 *  获取评论列表
 *
 *  @param feedID      被评论的feed的ID
 *  @param count       预期数量，当实际数量不足时，返回的结果数量会比预期数量少
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param lastID      拉取数据时所参考的评论的ID
 *  @param resultBlock 结果回调，commentList为nil表示获取失败，失败原因见error的code和userInfo
 */
- (void)getCommentListByFeedID:(NSString *)feedID count:(NSInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void(^)(DXCommentList * commentList, NSError * error))resultBlock;
#pragma mark 发布评论
/**
 *  发布评论
 *
 *  @param commentPost 需要发布的评论信息
 *  @param resultBlock 回调结果
 */
- (void)postCommentWithCommentPost:(DXCommentPost *)commentPost result:(void(^)(DXComment * comment, NSError *error))resultBlock;
#pragma mark 删除评论
/**
 *  删除评论
 *
 *  @param commentID   评论的ID
 *  @param resultBlock 回调结果
 */
- (void)deleteCommentByCommentID:(NSString *)commentID result:(void(^)(BOOL success, NSError *error))resultBlock;

/*****************************************************************************
 *
 * 地理位置相关
 *
 *****************************************************************************/

#pragma mark - 地理位置相关

/**
 *  获取指定纬度(latitude)、经度(longitude)的地址信息
 *
 */
- (void)getAddressOfLatitude:(float)latitude andLongitude:(float)longitude result:(void(^)(BOOL status, NSString * address, NSArray * pois, NSError * error))resultBlock;



/*****************************************************************************
 *
 * 搜索相关
 *
 *****************************************************************************/
#pragma mark - 搜索相关

/**
 *  获取发现页用户列表
 *
 */
- (void)getDiscoverUserList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void(^)(DXDiscoverUserWrapper * userWrapper, NSError * error))resultBlock;

/**
 *  获取热门搜索关键词
 */
- (void)getHotKeywordsListResult:(void(^)(NSArray *hotKeywordsList, NSError *error))resultBlock;

/**
 *  通过关键词获取搜索结果
 */
- (void)getSearchResultsByKeywords:(NSString *)keywords result:(void(^)(DXSearchResults *searchResults, NSError *error))resultBlock;

/**
 *  通过关键词获取搜索话题结果
 */
- (void)getSearchTopicWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void(^)(DXSearchTopicWrapper *searchTopicWrapper, NSError *error))resultBlock;

/**
 *  通过关键词获取搜索用户结果
 */
- (void)getSearchUserWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void(^)(DXSearchUserWrapper *searchUserWrapper, NSError *error))resultBlock;

/**
 *  通过关键词获取搜索活动结果
 */
- (void)getSearchActivityWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void(^)(DXSearchActivityWrapper *searchActivityWrapper, NSError *error))resultBlock;

/**
 *  通过关键词获取搜索feed结果
 */
- (void)getSearchFeedWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void(^)(DXSearchFeedWrapper *searchFeedWrapper, NSError *error))resultBlock;

/*****************************************************************************
 *
 * 客户端相关
 *
 *****************************************************************************/
#pragma mark - 客户端相关

- (void)checkWatermarksWithTimestamp:(NSInteger)timestamp result:(void(^)(NSArray * watermarks, NSInteger timestamp, NSError * error))resultBlock;

/*****************************************************************************
 *
 * 标签相关
 *
 *****************************************************************************/
#pragma mark - 标签相关
/**
 *  获取当前登陆用户收藏的标签和全部标签列表
 */
- (void)getTagWrapper:(void(^)(DXTagWrapper *tagWrapper, NSError *error))resultBlock;
/**
 *  增加或删除标签
 *
 *  @param createTagIDs  增加的标签id数组
 *  @param deleteTageIDs 删除的标签id数组
 */
- (void)changeTagRelationWithCreateTagIDs:(NSArray *)createTagIDs deleteTageIDs:(NSArray *)deleteTageIDs result:(void(^)(BOOL success, NSError *error))resultBlock;


#pragma mark - ******************************   v2.0   ******************************

/*****************************************************************************
 *
 * Feed相关操作
 *
 *****************************************************************************/

#pragma mark - Feed相关操作 -

#pragma mark Feed首页列表
/**
 *  获取Feed首页列表
 *
 *  @discussion 支持在未登陆时调用
 *
 *  @param pullType    拉取方式。DXDataListPullFirstTime代表首次; DXDataListPullOlderList代表要取更早的数据，DXDataListPullNewerList代表要取更新的数据
 *  @param count       拉取的数量
 *  @param ID          拉取数据时所参考的feed的ID，例如pullType选DXDataListPullOlderList，ID为"500"，表示获取比ID为500的feed更早的数据
 *  @param resultBlock 结果回调，feedWrapper不为nil表示获取成功，失败原因见error的code和userInfo
 */
- (void)getFeedHomeList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID userTimestamp:(NSUInteger)userTimestamp topicTimestamp:(NSUInteger)topicTimestamp result:(void(^)(DXFeedHomeList * feedList, NSError * error))resultBlock;

@end



