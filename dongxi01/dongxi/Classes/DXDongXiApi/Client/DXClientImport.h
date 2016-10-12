//
//  DXClientRequestImport.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClient.h"
#import "DXClientRequest.h"
#import "DXClientResponse.h"
#import "DXClientRequestError.h"

/*****************************************************************************
 *
 * 用户相关
 *
 *****************************************************************************/

// 账号是否可注册
#import "DXUserValidateRequest.h"
#import "DXUserValidateResponse.h"
// 注册
#import "DXUserRegisterRequest.h"
#import "DXUserRegisterResponse.h"
// 登录
#import "DXUserLoginRequest.h"
#import "DXUserLoginResponse.h"
// 注销
#import "DXUserLogoutRequest.h"
#import "DXUserLogoutResponse.h"
// 注册发送手机验证码
#import "DXUserSendSmsRequest.h"
#import "DXUserSendSmsResponse.h"
// 注册短信验证码验证
#import "DXUserCheckSmsRequest.h"
#import "DXUserCheckSmsResponse.h"
// 重置密码发送手机验证码
#import "DXUserResetSendSmsRequest.h"
#import "DXUserResetSendSmsResponse.h"
// 重置密码短信验证码验证
#import "DXUserCheckResetSmsRequest.h"
#import "DXUserCheckResetSmsResponse.h"
// 重置密码
#import "DXUserResetPwdRequest.h"
#import "DXUserResetPwdResponse.h"
// 修改密码
#import "DXUserChangePwdRequest.h"
#import "DXUserChangePwdResponse.h"
// 获取用户资料
#import "DXUserProfileRequest.h"
#import "DXUserProfileResponse.h"

#import "DXUserProfileBynickRequest.h"
#import "DXUserProfileBynickResponse.h"

// 换头像
#import "DXUserChangeAvatarRequest.h"
#import "DXUserChangeAvatarResponse.h"
// 换封面
#import "DXUserChangeCoverRequest.h"
#import "DXUserChangeCoverResponse.h"
// 更新用户资料
#import "DXUserChangeProfileRequest.h"
#import "DXUserChangeProfileResponse.h"
// 关注某人
#import "DXUserFollowRequest.h"
#import "DXUserFollowResponse.h"
// 取消关注某人
#import "DXUserUnfollowRequest.h"
#import "DXUserUnfollowResponse.h"
// 关注列表
#import "DXUserFollowListRequest.h"
#import "DXUserFollowListResponse.h"
// 粉丝列表
#import "DXUserFansListRequest.h"
#import "DXUserFansListResponse.h"
// 批量获取用户昵称和头像
#import "DXUserProfileAllRequest.h"
#import "DXUserProfileAllResponse.h"
// 邀请码列表
#import "DXUserCouponListRequest.h"
#import "DXUserCouponListResponse.h"
// 发送邀请码
#import "DXUserCouponSendRequest.h"
#import "DXUserCouponSendResponse.h"
// 使用邀请码
#import "DXUserCouponUseRequest.h"
#import "DXUserCouponUseResponse.h"
// 申请邀请码
#import "DXUserCouponGetRequest.h"
#import "DXUserCouponGetResponse.h"

#import "DXUserFeedbackRequest.h"
#import "DXUserFeedbackResponse.h"
// 检查用户及客户端信息
#import "DXUserUserCheckRequest.h"
#import "DXUserUserCheckResponse.h"
// 用户点赞排行
#import "DXUserLikeRankRequest.h"
#import "DXUserLikeRankResponse.h"
// 刷新sessionID
#import "DXUserFlushSessionRequest.h"
#import "DXUserFlushSessionResponse.h"

/*****************************************************************************
 *
 * 客户端
 *
 *****************************************************************************/

#import "DXClientShowRequest.h"
#import "DXClientShowResponse.h"

#import "DXClientGetDefaultTopicIdRequest.h"
#import "DXClientGetDefaultTopicIdResponse.h"

#import "DXClientCheckInviteRequest.h"
#import "DXClientCheckInviteResponse.h"

#import "DXClientCheckWatermarksRequest.h"
#import "DXClientCheckWatermarksResponse.h"

/*****************************************************************************
 *
 * Feed相关
 *
 *****************************************************************************/

#import "DXTimelineCreateRequest.h"
#import "DXTimelineCreateResponse.h"

#import "DXTimelineDeleteRequest.h"
#import "DXTimelineDeleteResponse.h"

#import "DXTimelineLikeRequest.h"
#import "DXTimelineLikeResponse.h"

#import "DXTimelineUnlikeRequest.h"
#import "DXTimelineUnlikeResponse.h"

#import "DXTimelineReportRequest.h"
#import "DXTimelineReportResponse.h"

#import "DXTimelinePublicListRequest.h"
#import "DXTimelinePublicListResponse.h"

#import "DXTimelineSaveListRequest.h"
#import "DXTimelineSaveListResponse.h"

#import "DXTimelineHotListRequest.h"
#import "DXTimelineHotListResponse.h"

#import "DXTimelinePrivateListRequest.h"
#import "DXTimelinePrivateListResponse.h"

#import "DXTimelineLikeListRequest.h"
#import "DXTimelineLikeListResponse.h"

#import "DXTimelineGetFeedRequest.h"
#import "DXTimelineGetFeedResponse.h"

#import "DXTimelineTopicsRequest.h"
#import "DXTimelineTopicsResponse.h"

#import "DXTimelineMyTopicsRequest.h"
#import "DXTimelineMyTopicsResponse.h"

#import "DXTimelineTopicListRequest.h"
#import "DXTimelineTopicListResponse.h"

#import "DXTimelineTopicFollowListRequest.h"
#import "DXTimelineTopicFollowListResponse.h"

#import "DXTimelineTopicFansListRequest.h"
#import "DXTimelineTopicFansListResponse.h"

#import "DXTimelineTopicInviteRequest.h"
#import "DXTimelineTopicInviteResponse.h"
// 收藏
#import "DXTimelineSaveRequest.h"
#import "DXTimelineSaveResponse.h"
// 取消收藏
#import "DXTimelineUnsaveRequest.h"
#import "DXTimelineUnsaveResponse.h"

#import "DXTimelineLikeUserListRequest.h"
#import "DXTimelineLikeUserListResponse.h"

#import "DXTimelineShareFeedRequest.h"
#import "DXTimelineShareFeedResponse.h"
// 最新
#import "DXFeedTimelineRequest.h"
#import "DXFeedTimelineResponse.h"
// 引用联系人列表
#import "DXTimelineRecentContactsRequest.h"
#import "DXTimelineRecentContactsResponse.h"
// 引用话题列表
#import "DXTimelineRecentTopicsRequest.h"
#import "DXTimelineRecentTopicsResponse.h"
// 更新feed
#import "DXFeedFeedUpdateRequest.h"
#import "DXFeedFeedUpdateResponse.h"

/*****************************************************************************
 *
 * 活动相关
 *
 *****************************************************************************/
#import "DXActivityListsRequest.h"
#import "DXActivityListsResponse.h"

#import "DXActivityGetDetailRequest.h"
#import "DXActivityGetDetailResponse.h"

#import "DXActivityWantRequest.h"
#import "DXActivityWantResponse.h"

#import "DXActivityMarkRequest.h"
#import "DXActivityMarkResponse.h"

/*****************************************************************************
 *
 * 消息相关
 *
 *****************************************************************************/
// 通知列表
#import "DXMessageNoticeListRequest.h"
#import "DXMessageNoticeListResponse.h"
// 删除通知条目
#import "DXMessageDeleteNoticeRequest.h"
#import "DXMessageDeleteNoticeResponse.h"
// 点赞列表
#import "DXMessageNoticeListLikeRequest.h"
#import "DXMessageNoticeListLikeResponse.h"
// 评论列表
#import "DXMessageNoticeListCommentRequest.h"
#import "DXMessageNoticeListCommentResponse.h"
// 检查是否有新消息
#import "DXMessageCheckNewRequest.h"
#import "DXMessageCheckNewResponse.h"
// 通知服务器消息已读
#import "DXMessagePostReadRequest.h"
#import "DXMessagePostReadResponse.h"

/*****************************************************************************
 *
 * 私聊相关操作
 *
 *****************************************************************************/
// 消息私聊列表
#import "DXMessageDiscussListByUserRequest.h"
#import "DXMessageDiscussListByUserResponse.h"
// 删除聊天条目
#import "DXMessageDeleteDiscussRequest.h"
#import "DXMessageDeleteDiscussResponse.h"
// 设置消息已读
#import "DXMessageDiscussSetReadRequest.h"
#import "DXMessageDiscussSetReadResponse.h"
// 聊天记录列表
#import "DXDiscussListsByUserRequest.h"
#import "DXDiscussListsByUserResponse.h"
// 发送消息
#import "DXDiscussCreateRequest.h"
#import "DXDiscussCreateResponse.h"
// 消息列表
#import "DXChatChatListRequest.h"
#import "DXChatChatListResponse.h"
// 会话列表
#import "DXChatConversationsRequest.h"
#import "DXChatConversationsResponse.h"
// 备份消息
#import "DXChatBackupChatRequest.h"
#import "DXChatBackupChatResponse.h"
// 上传消息文件
#import "DXChatUploadChatFileRequest.h"
#import "DXChatUploadChatFileResponse.h"
// 设置消息已读
#import "DXChatSetReadRequest.h"
#import "DXChatSetReadResponse.h"

/*****************************************************************************
 *
 * 评论相关
 *
 *****************************************************************************/
// Feed评论列表
#import "DXCommentListsRequest.h"
#import "DXCommentListsResponse.h"
// 发布评论
#import "DXCommentCreateRequest.h"
#import "DXCommentCreateResponse.h"
// 删除评论
#import "DXCommentDeleteRequest.h"
#import "DXCommentDeleteResponse.h"

/*****************************************************************************
 *
 * 地址位置相关
 *
 *****************************************************************************/

#import "DXLocationGetRequest.h"
#import "DXLocationGetResponse.h"

#import "DXLocationSearchRequest.h"
#import "DXLocationSearchResponse.h"

#import "DXLocationSuggestionRequest.h"
#import "DXLocationSuggestionResponse.h"

/*****************************************************************************
 *
 * 搜索相关
 *
 *****************************************************************************/

#import "DXSearchUserListRequest.h"
#import "DXSearchUserListResponse.h"

#import "DXSearchHotKeywordsRequest.h"
#import "DXSearchHotKeywordsResponse.h"

#import "DXSearchSearchByKeywordRequest.h"
#import "DXSearchSearchByKeywordResponse.h"

#import "DXSearchSearchKeywordInTopicRequest.h"
#import "DXSearchSearchKeywordInTopicResponse.h"

#import "DXSearchSearchKeywordInUserRequest.h"
#import "DXSearchSearchKeywordInUserResponse.h"

#import "DXSearchSearchKeywordInActivityRequest.h"
#import "DXSearchSearchKeywordInActivityResponse.h"

#import "DXSearchSearchKeywordInFeedRequest.h"
#import "DXSearchSearchKeywordInFeedResponse.h"

/*****************************************************************************
 *
 * 话题相关
 *
 *****************************************************************************/

#import "DXTopicTopicsRequest.h"
#import "DXTopicTopicsResponse.h"

#import "DXTopicTopicLikesRequest.h"
#import "DXTopicTopicLikesResponse.h"

#import "DXTopicCreateTopicLikeRequest.h"
#import "DXTopicCreateTopicLikeResponse.h"

#import "DXTopicCancelTopicLikeRequest.h"
#import "DXTopicCancelTopicLikeResponse.h"

#import "DXTopicRankingListRequest.h"
#import "DXTopicRankingListResponse.h"

/*****************************************************************************
 *
 * 标签相关
 *
 *****************************************************************************/

#import "DXTagTagListRequest.h"
#import "DXTagTagListResponse.h"
#import "DXTagCreateOrDeleteTagRelationRequest.h"
#import "DXTagCreateOrDeleteTagRelationResponse.h"

/*****************************************************************************
 *
 * 微信登录相关
 *
 *****************************************************************************/

#import "DXWxauthorizerLoginRequest.h"
#import "DXWxauthorizerLoginResponse.h"
#import "DXWxauthorizerCaptchaRequest.h"
#import "DXWxauthorizerCaptchaResponse.h"
#import "DXWxauthorizerRegisterAndLoginRequest.h"
#import "DXWxauthorizerRegisterAndLoginResponse.h"

#pragma mark - ******************************   v2.0   ******************************


/*****************************************************************************
 *
 * Feed相关
 *
 *****************************************************************************/

#import "DXFeedHomeListRequest.h"
#import "DXFeedHomeListResponse.h"
















