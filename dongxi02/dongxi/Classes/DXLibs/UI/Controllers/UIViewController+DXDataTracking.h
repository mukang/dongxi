//
//  UIViewController+DXDataTracking.h
//  dongxi
//
//  Created by Xu Shiwen on 16/2/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXDataTrackingHelpers.h"

extern NSString * const DXDataTrackingPage_HomeTimelineHot;
extern NSString * const DXDataTrackingPage_HomeTimelineFollow;
extern NSString * const DXDataTrackingPage_HomeTimelineNewest;
extern NSString * const DXDataTrackingPage_LikeRank;
extern NSString * const DXDataTrackingPage_DiscoverTopics;
extern NSString * const DXDataTrackingPage_DiscoverActivities;
extern NSString * const DXDataTrackingPage_DiscoverUsers;
extern NSString * const DXDataTrackingPage_PhotoDetail;
extern NSString * const DXDataTrackingPage_PhotoLikes;
extern NSString * const DXDataTrackingPage_PhotoMap;
extern NSString * const DXDataTrackingPage_PhotoCommentPublish;
extern NSString * const DXDataTrackingPage_PhotoCommentReply;
extern NSString * const DXDataTrackingPage_ProfileTimelineJoined;
extern NSString * const DXDataTrackingPage_ProfileTimelineSaved;
extern NSString * const DXDataTrackingPage_ProfileAvatarModify;
extern NSString * const DXDataTrackingPage_ProfileCoverModify;
extern NSString * const DXDataTrackingPage_ProfileFans;
extern NSString * const DXDataTrackingPage_ProfileFollowing;
extern NSString * const DXDataTrackingPage_CaptureCamera;
extern NSString * const DXDataTrackingPage_CaptureAlbum;
extern NSString * const DXDataTrackingPage_CaptureCrop;
extern NSString * const DXDataTrackingPage_CaptureEdit;
extern NSString * const DXDataTrackingPage_PhotoPublish;
extern NSString * const DXDataTrackingPage_PhotoEditing;
extern NSString * const DXDataTrackingPage_PhotoPublishLocations;
extern NSString * const DXDataTrackingPage_PhotoPublishPhotoBrowser;
extern NSString * const DXDataTrackingPage_TopicTimeline;
extern NSString * const DXDataTrackingPage_TopicInvite;
extern NSString * const DXDataTrackingPage_TopicRank;
extern NSString * const DXDataTrackingPage_ActivityDetail;
extern NSString * const DXDataTrackingPage_ActivityFollowers;
extern NSString * const DXDataTrackingPage_ActivityComment;
extern NSString * const DXDataTrackingPage_Settings;
extern NSString * const DXDataTrackingPage_SettingsProfile;
extern NSString * const DXDataTrackingPage_SettingsFeedback;
extern NSString * const DXDataTrackingPage_SettingsPassword;
extern NSString * const DXDataTrackingPage_SettingsTag;
extern NSString * const DXDataTrackingPage_SettingsBio;
extern NSString * const DXDataTrackingPage_About;
extern NSString * const DXDataTrackingPage_AboutPrivacy;
extern NSString * const DXDataTrackingPage_AboutAgreement;
extern NSString * const DXDataTrackingPage_AboutVerification;
extern NSString * const DXDataTrackingPage_Login;
extern NSString * const DXDataTrackingPage_LoginByPhone;
extern NSString * const DXDataTrackingPage_RegisterPhoneVerify;
extern NSString * const DXDataTrackingPage_RegisterWechatVerify;
extern NSString * const DXDataTrackingPage_RegisterPassword;
extern NSString * const DXDataTrackingPage_RegisterUserInfo;
extern NSString * const DXDataTrackingPage_RecoverPhoneVerify;
extern NSString * const DXDataTrackingPage_RecoverPassword;
extern NSString * const DXDataTrackingPage_Messages;
extern NSString * const DXDataTrackingPage_MessagesComments;
extern NSString * const DXDataTrackingPage_MessagesLikes;
extern NSString * const DXDataTrackingPage_MessagesNotices;
extern NSString * const DXDataTrackingPage_PrivateChat;
extern NSString * const DXDataTrackingPage_Web;
extern NSString * const DXDataTrackingPage_Search;
extern NSString * const DXDataTrackingPage_SearchMoreTopic;
extern NSString * const DXDataTrackingPage_SearchMoreUser;
extern NSString * const DXDataTrackingPage_SearchMoreActivity;
extern NSString * const DXDataTrackingPage_SearchMoreFeed;
extern NSString * const DXDataTrackingPage_ReferUser;
extern NSString * const DXDataTrackingPage_ReferTopic;


@interface UIViewController (DXDataTracking)

@property (nonatomic, strong) NSString * dt_pageName;

@end
