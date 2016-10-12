//
//  DXClientConfig.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientConfig.h"

NSString * const DXClientApi_ClientShow                     = @"client/show";
NSString * const DXClientApi_ClientGetDefaultTopicId        = @"client/get_default_topic_id";
NSString * const DXClientApi_ClientCheckInvite              = @"client/check_invite";
NSString * const DXClientApi_ClientCheckWatermarks          = @"client/check_watermarks";

NSString * const DXClientApi_UserValidate                   = @"user/validate";
NSString * const DXClientApi_UserRegister                   = @"user/register";
NSString * const DXClientApi_UserLogin                      = @"user/login";
NSString * const DXClientApi_UserLogout                     = @"user/logout";
NSString * const DXClientApi_UserSendSms                    = @"user/send_sms";
NSString * const DXClientAPi_UserCheckSms                   = @"user/check_sms";
NSString * const DXClientAPi_UserResetSendSms               = @"user/reset_send_sms";
NSString * const DXClientApi_UserCheckResetSms              = @"user/check_reset_sms";
NSString * const DXClientAPi_UserResetPwd                   = @"user/reset_pwd";
NSString * const DXClientAPi_UserChangePwd                  = @"user/change_pwd";
NSString * const DXClientAPi_UserProfile                    = @"user/profile";
NSString * const DXClientAPi_UserProfileBynick              = @"user/profile_bynick";
NSString * const DXClientAPi_UserChangeAvatar               = @"user/change_avatar";
NSString * const DXClientAPi_UserChangeCover                = @"user/change_cover";
NSString * const DXClientAPi_UserChangeProfile              = @"user/change_profile";
NSString * const DXClientAPi_UserFollow                     = @"user/follow";
NSString * const DXClientAPi_UserUnfollow                   = @"user/unfollow";
NSString * const DXClientAPi_UserFollowList                 = @"user/follow_list";
NSString * const DXClientAPi_UserFansList                   = @"user/fans_list";
NSString * const DXClientAPi_UserProfileAll                 = @"user/profile_all";
NSString * const DXClientAPi_UserCouponList                 = @"user/coupon_list";
NSString * const DXClientAPi_UserCouponSend                 = @"user/coupon_send";
NSString * const DXClientAPi_UserCouponUse                  = @"user/coupon_use";
NSString * const DXClientAPi_UserCouponGet                  = @"user/coupon_get";
NSString * const DXClientApi_UserFeedback                   = @"user/feedback";
NSString * const DXClientApi_UserUserCheck                  = @"user/user_check";
NSString * const DXClientApi_UserLikeRank                   = @"user/like_rank";
NSString * const DXClientApi_UserFlushSession               = @"user/flush_session";

NSString * const DXClientApi_TimelineCreate                 = @"timeline/create";
NSString * const DXClientApi_TimelineDelete                 = @"timeline/delete";
NSString * const DXClientApi_TimelineLike                   = @"timeline/like";
NSString * const DXClientApi_TimelineUnlike                 = @"timeline/unlike";
NSString * const DXClientApi_TimelineReport                 = @"timeline/report";
NSString * const DXClientApi_TimelinePublicList             = @"timeline/public_list";
NSString * const DXClientApi_TimelineSaveList               = @"timeline/save_list";
NSString * const DXClientApi_TimelineHotList                = @"timeline/hot_list";
NSString * const DXClientApi_TimelinePrivateList            = @"timeline/private_list";
NSString * const DXClientApi_TimelineLikeList               = @"timeline/like_list";
NSString * const DXClientApi_TimelineGetFeed                = @"timeline/get_feed";
NSString * const DXClientApi_TimelineTopics                 = @"timeline/topics";
NSString * const DXClientApi_TimelineMyTopics               = @"timeline/my_topics";
NSString * const DXClientApi_TimelineTopicList              = @"timeline/topic_list";
NSString * const DXClientApi_TimelineTopicFollowList        = @"timeline/topic_follow_list";
NSString * const DXClientApi_TimelineTopicFansList          = @"timeline/topic_fans_list";
NSString * const DXClientApi_TimelineTopicInvite            = @"timeline/topic_invite";
NSString * const DXClientApi_TimelineSave                   = @"timeline/save";
NSString * const DXClientApi_TimelineUnsave                 = @"timeline/unsave";
NSString * const DXClientApi_TimelineLikeUserList           = @"timeline/like_user_list";
NSString * const DXClientApi_TimelineShareFeed              = @"timeline/share_feed";
NSString * const DXClientApi_TimelineRecentContacts         = @"timeline/recent_contacts";
NSString * const DXClientApi_TimelineRecentTopics           = @"timeline/recent_topics";

NSString * const DXClientApi_FeedTimeline                   = @"feed/timeline";
NSString * const DXClientApi_FeedFeedUpdate                 = @"feed/feed_update";

NSString * const DXClientApi_ActivityLists                  = @"activity/lists";
NSString * const DXClientApi_ActivityGetDetail              = @"activity/get_detail";
NSString * const DXClientApi_ActivityWant                   = @"activity/want";
NSString * const DXClientApi_ActivityMark                   = @"activity/mark";

NSString * const DXClientApi_MessageCheckNew                = @"message/check_new";
NSString * const DXClientApi_MessagePostRead                = @"message/post_read";

NSString * const DXClientApi_MessageNoticeList              = @"message/notice_list";
NSString * const DXClientApi_MessageDeleteNotice            = @"message/delete_notice";
NSString * const DXClientApi_MessageNoticeListLike          = @"message/notice_list_like";
NSString * const DXClientApi_MessageNoticeListComment       = @"message/notice_list_comment";

NSString * const DXClientApi_MessageDiscussListByUser       = @"message/discuss_list_by_user";
NSString * const DXClientApi_MessageDeleteDiscuss           = @"message/delete_discuss";
NSString * const DXClientApi_MessageDiscussSetRead          = @"message/discuss_set_read";
NSString * const DXClientApi_DiscussListsByUser             = @"discuss/lists_by_user";
NSString * const DXClientApi_DiscussCreate                  = @"discuss/create";

NSString * const DXClientApi_CommentLists                   = @"comment/lists";
NSString * const DXClientApi_CommentCreate                  = @"comment/create";
NSString * const DXClientApi_CommentDelete                  = @"comment/delete";

NSString * const DXClientApi_LocationGet                    = @"location/get";
NSString * const DXClientApi_LocationSearch                 = @"location/search";
NSString * const DXClientApi_LocationSuggestion             = @"location/suggestion";

NSString * const DXClientApi_SearchUserList                 = @"search/user_list";
NSString * const DXClientApi_SearchHotKeywords              = @"search/hot_keywords";
NSString * const DXClientApi_SearchSearchByKeyword          = @"search/search_by_keyword";
NSString * const DXClientApi_SearchSearchKeywordInTopic     = @"search/search_keyword_in_topic";
NSString * const DXClientApi_SearchSearchKeywordInUser      = @"search/search_keyword_in_user";
NSString * const DXClientApi_SearchSearchKeywordInActivity  = @"search/search_keyword_in_activity";
NSString * const DXClientApi_SearchSearchKeywordInFeed      = @"search/search_keyword_in_feed";

NSString * const DXClientApi_TopicTopics                    = @"topic/topics";
NSString * const DXClientApi_TopicTopicLikes                = @"topic/topic_likes";
NSString * const DXClientApi_TopicCreateTopicLike           = @"topic/create_topic_like";
NSString * const DXClientApi_TopicCancelTopicLike           = @"topic/cancel_topic_like";
NSString * const DXClientApi_TopicRankingList               = @"topic/ranking_list";

NSString * const DXClientApi_TagTagList                     = @"tag/tag_list";
NSString * const DXClientApi_TagCreateOrDeleteTagRelation   = @"tag/create_or_delete_tag_relation";

NSString * const DXClientApi_ChatChatList                   = @"chat/chat_list";
NSString * const DXClientApi_ChatConversations              = @"chat/conversations";
NSString * const DXClientApi_ChatBackupChat                 = @"chat/backup_chat";
NSString * const DXClientApi_ChatUploadChatFile             = @"chat/upload_chat_file";
NSString * const DXClientApi_ChatSetRead                    = @"chat/set_read";

NSString * const DXClientApi_WxauthorizerLogin              = @"wxauthorizer/login";
NSString * const DXClientApi_WxauthorizerCaptcha            = @"wxauthorizer/captcha";
NSString * const DXClientApi_WxauthorizerRegisterAndLogin   = @"wxauthorizer/register_and_login";



