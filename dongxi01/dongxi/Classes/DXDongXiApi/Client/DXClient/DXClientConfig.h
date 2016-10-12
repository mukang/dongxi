//
//  DXClientConfig.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/7.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef dongxi_DXClientConfig_h
#define dongxi_DXClientConfig_h

#define DXCLIENT_API_DEVICE                 @"ios"

#if DEBUG
#define DXCLIENT_API_HOST                   @"192.168.1.100:8082"
#define DXCLIENT_API_HOST_V2                @"192.168.1.100:8083"
//#define DXCLIENT_API_HOST                   @"apitest.dongxi365.com"
#else
#define DXCLIENT_API_HOST                   @"api.dongxi365.com"
#endif

#define DXCLIENT_REQUEST_URL_FORMAT         @"http://" DXCLIENT_API_HOST "/index.php?r=api/%@"
#define DXCLIENT_REQUEST_URL_FORMAT_V2      @"http://" DXCLIENT_API_HOST_V2 "/%@"
#define DXCLIENT_REQUEST_CLASS_FORMAT       @"DX%@Request"
#define DXCLIENT_RESPONSE_CLASS_FORMAT      @"DX%@Response"

#define DXCLIENT_SYSTEM_VARIABLES_MAP @{@"ID":@"id"}

typedef enum : NSInteger {
    DXClientResponseResultOK                    = 0,
    DXClientResponseResultError                 = -1,
    DXClientResponseResultSessionInvalid        = -2,
    DXClientResponseResultUserInvalid           = -3
} DXClientResponseResultType;

/**
 *  v2.0版本响应结果类型
 */
typedef NS_ENUM(NSInteger, DXClientResponseResultTypeV2) {
    /**
     *  用户未登录
     */
    DXClientResponseResultTypeV2UserInvalid = 23001,
    /**
     *  session失效
     */
    DXClientResponseResultTypeV2SessionInvalid = 23002
};

/*-------------------------------------------------------------------
 * 客户端相关接口
 -------------------------------------------------------------------*/

/** 图片轮播接口 */
extern NSString * const DXClientApi_ClientShow;
/** 默认话题ID接口 */
extern NSString * const DXClientApi_ClientGetDefaultTopicId;
/** 是否开启邀请注册 */
extern NSString * const DXClientApi_ClientCheckInvite;
/** 检查并获取最新的水印 */
extern NSString * const DXClientApi_ClientCheckWatermarks;

/*-------------------------------------------------------------------
 * 用户相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_UserValidate;
extern NSString * const DXClientApi_UserRegister;
extern NSString * const DXClientApi_UserLogin;
extern NSString * const DXClientApi_UserLogout;
extern NSString * const DXClientApi_UserSendSms;
extern NSString * const DXClientAPi_UserCheckSms;
extern NSString * const DXClientAPi_UserResetSendSms;
extern NSString * const DXClientApi_UserCheckResetSms;
extern NSString * const DXClientAPi_UserResetPwd;
extern NSString * const DXClientAPi_UserChangePwd;
extern NSString * const DXClientAPi_UserProfile;
extern NSString * const DXClientAPi_UserProfileBynick;
extern NSString * const DXClientAPi_UserChangeAvatar;
extern NSString * const DXClientAPi_UserChangeCover;
extern NSString * const DXClientAPi_UserChangeProfile;
extern NSString * const DXClientAPi_UserFollow;
extern NSString * const DXClientAPi_UserUnfollow;
extern NSString * const DXClientAPi_UserFollowList;
extern NSString * const DXClientAPi_UserFansList;
extern NSString * const DXClientAPi_UserProfileAll;
extern NSString * const DXClientAPi_UserCouponList;
extern NSString * const DXClientAPi_UserCouponSend;
extern NSString * const DXClientAPi_UserCouponUse;
extern NSString * const DXClientAPi_UserCouponGet;
extern NSString * const DXClientApi_UserFeedback;
extern NSString * const DXClientApi_UserUserCheck;
extern NSString * const DXClientApi_UserLikeRank;
extern NSString * const DXClientApi_UserFlushSession;

/*-------------------------------------------------------------------
 * Feed相关接口
 -------------------------------------------------------------------*/

extern NSString * const DXClientApi_TimelineCreate;
extern NSString * const DXClientApi_TimelineDelete;
extern NSString * const DXClientApi_TimelineLike;
extern NSString * const DXClientApi_TimelineUnlike;
extern NSString * const DXClientApi_TimelineReport;
extern NSString * const DXClientApi_TimelinePublicList;
extern NSString * const DXClientApi_TimelineSaveList;
extern NSString * const DXClientApi_TimelineHotList;
extern NSString * const DXClientApi_TimelinePrivateList;
/*! 接口定义：我赞过的Feed列表 */
extern NSString * const DXClientApi_TimelineLikeList;
extern NSString * const DXClientApi_TimelineGetFeed;
extern NSString * const DXClientApi_TimelineTopics;
extern NSString * const DXClientApi_TimelineMyTopics;
extern NSString * const DXClientApi_TimelineTopicList;
extern NSString * const DXClientApi_TimelineTopicFollowList;
extern NSString * const DXClientApi_TimelineTopicFansList;
extern NSString * const DXClientApi_TimelineTopicInvite;
extern NSString * const DXClientApi_TimelineSave;
extern NSString * const DXClientApi_TimelineUnsave;
/*! 接口定义：点赞的用户列表 */
extern NSString * const DXClientApi_TimelineLikeUserList;
extern NSString * const DXClientApi_TimelineShareFeed;
extern NSString * const DXClientApi_FeedTimeline;
/*! 接口定义：引用列表 */
extern NSString * const DXClientApi_TimelineRecentContacts;
extern NSString * const DXClientApi_TimelineRecentTopics;
/*! 接口定义：更新feed */
extern NSString * const DXClientApi_FeedFeedUpdate;

/*-------------------------------------------------------------------
 * 活动相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_ActivityLists;
extern NSString * const DXClientApi_ActivityGetDetail;
extern NSString * const DXClientApi_ActivityWant;
extern NSString * const DXClientApi_ActivityMark;

/*-------------------------------------------------------------------
 * 消息相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_MessageCheckNew;
extern NSString * const DXClientApi_MessagePostRead;
extern NSString * const DXClientApi_MessageNoticeList;
extern NSString * const DXClientApi_MessageDeleteNotice;
extern NSString * const DXClientApi_MessageNoticeListLike;
extern NSString * const DXClientApi_MessageNoticeListComment;

/*-------------------------------------------------------------------
 * 私聊相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_MessageDiscussListByUser;
extern NSString * const DXClientApi_MessageDeleteDiscuss;
extern NSString * const DXClientApi_MessageDiscussSetRead;
extern NSString * const DXClientApi_DiscussListsByUser;
extern NSString * const DXClientApi_DiscussCreate;

/*-------------------------------------------------------------------
 * 评论相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_CommentLists;
extern NSString * const DXClientApi_CommentCreate;
extern NSString * const DXClientApi_CommentDelete;

/*-------------------------------------------------------------------
 * 地址位置相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_LocationGet;
extern NSString * const DXClientApi_LocationSearch;
extern NSString * const DXClientApi_LocationSuggestion;

/*-------------------------------------------------------------------
 * 搜索相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_SearchUserList;
extern NSString * const DXClientApi_SearchHotKeywords;
extern NSString * const DXClientApi_SearchSearchByKeyword;
extern NSString * const DXClientApi_SearchSearchKeywordInTopic;
extern NSString * const DXClientApi_SearchSearchKeywordInUser;
extern NSString * const DXClientApi_SearchSearchKeywordInActivity;
extern NSString * const DXClientApi_SearchSearchKeywordInFeed;

/*-------------------------------------------------------------------
 * 话题相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_TopicTopics;
extern NSString * const DXClientApi_TopicTopicLikes;
extern NSString * const DXClientApi_TopicCreateTopicLike;
extern NSString * const DXClientApi_TopicCancelTopicLike;
extern NSString * const DXClientApi_TopicRankingList;

/*-------------------------------------------------------------------
 * 标签相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_TagTagList;
extern NSString * const DXClientApi_TagCreateOrDeleteTagRelation;

/*-------------------------------------------------------------------
 * 私聊相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_ChatChatList;
extern NSString * const DXClientApi_ChatConversations;
extern NSString * const DXClientApi_ChatBackupChat;
extern NSString * const DXClientApi_ChatUploadChatFile;
extern NSString * const DXClientApi_ChatSetRead;

/*-------------------------------------------------------------------
 * 微信登录相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_WxauthorizerLogin;
extern NSString * const DXClientApi_WxauthorizerCaptcha;
extern NSString * const DXClientApi_WxauthorizerRegisterAndLogin;
extern NSString * const DXClientApi_WxauthorizerRegister;
extern NSString * const DXClientApi_WxauthorizerSyncUserinfo;


#pragma mark - ******************************   v2.0   ******************************

/*-------------------------------------------------------------------
 * Feed相关接口
 -------------------------------------------------------------------*/
extern NSString * const DXClientApi_FeedHomeList;

#endif
