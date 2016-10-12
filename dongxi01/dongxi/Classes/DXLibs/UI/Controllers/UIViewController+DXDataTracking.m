//
//  UIViewController+DXDataTracking.m
//  dongxi
//
//  Created by Xu Shiwen on 16/2/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "UIViewController+DXDataTracking.h"

NSString * const DXDataTrackingPage_HomeTimelineHot             = @"home_timeline_hot";
NSString * const DXDataTrackingPage_HomeTimelineFollow          = @"home_timeline_follow";
NSString * const DXDataTrackingPage_HomeTimelineNewest          = @"home_timeline_newest";
NSString * const DXDataTrackingPage_LikeRank                    = @"like_rank";
NSString * const DXDataTrackingPage_DiscoverTopics              = @"discover_topics";
NSString * const DXDataTrackingPage_DiscoverActivities          = @"discover_activities";
NSString * const DXDataTrackingPage_DiscoverUsers               = @"discover_users";
NSString * const DXDataTrackingPage_PhotoDetail                 = @"photo_detail";
NSString * const DXDataTrackingPage_PhotoLikes                  = @"photo_likes";
NSString * const DXDataTrackingPage_PhotoMap                    = @"photo_map";
NSString * const DXDataTrackingPage_PhotoCommentPublish         = @"photo_comment_publish";
NSString * const DXDataTrackingPage_PhotoCommentReply           = @"photo_comment_reply";
NSString * const DXDataTrackingPage_ProfileTimelineJoined       = @"profile_timeline_joined";
NSString * const DXDataTrackingPage_ProfileTimelineSaved        = @"profile_timeline_saved";
NSString * const DXDataTrackingPage_ProfileAvatarModify         = @"profile_avatar_modify";
NSString * const DXDataTrackingPage_ProfileCoverModify          = @"profile_cover_modify";
NSString * const DXDataTrackingPage_ProfileFans                 = @"profile_fans";
NSString * const DXDataTrackingPage_ProfileFollowing            = @"profile_following";
NSString * const DXDataTrackingPage_CaptureCamera               = @"capture_camera";
NSString * const DXDataTrackingPage_CaptureAlbum                = @"capture_album";
NSString * const DXDataTrackingPage_CaptureCrop                 = @"capture_crop";
NSString * const DXDataTrackingPage_CaptureEdit                 = @"capture_edit";
NSString * const DXDataTrackingPage_PhotoPublish                = @"photo_publish";
NSString * const DXDataTrackingPage_PhotoEditing                = @"photo_editing";
NSString * const DXDataTrackingPage_PhotoPublishLocations       = @"photo_publish_locations";
NSString * const DXDataTrackingPage_PhotoPublishPhotoBrowser    = @"photo_publish_photo_browser";
NSString * const DXDataTrackingPage_TopicTimeline               = @"topic_timeline";
NSString * const DXDataTrackingPage_TopicInvite                 = @"topic_invite";
NSString * const DXDataTrackingPage_TopicRank                   = @"topic_rank";
NSString * const DXDataTrackingPage_ActivityDetail              = @"activity_detail";
NSString * const DXDataTrackingPage_ActivityFollowers           = @"activity_followers";
NSString * const DXDataTrackingPage_ActivityComment             = @"activity_comment";
NSString * const DXDataTrackingPage_Settings                    = @"settings";
NSString * const DXDataTrackingPage_SettingsProfile             = @"settings_profile";
NSString * const DXDataTrackingPage_SettingsFeedback            = @"settings_feedback";
NSString * const DXDataTrackingPage_SettingsPassword            = @"settings_password";
NSString * const DXDataTrackingPage_SettingsTag                 = @"settings_tag";
NSString * const DXDataTrackingPage_SettingsBio                 = @"settings_bio";
NSString * const DXDataTrackingPage_About                       = @"about";
NSString * const DXDataTrackingPage_AboutPrivacy                = @"about_privacy";
NSString * const DXDataTrackingPage_AboutAgreement              = @"about_agreement";
NSString * const DXDataTrackingPage_AboutVerification           = @"about_verification";
NSString * const DXDataTrackingPage_Login                       = @"login";
NSString * const DXDataTrackingPage_LoginByPhone                = @"login_by_phone";
NSString * const DXDataTrackingPage_RegisterPhoneVerify         = @"register_phone_verify";
NSString * const DXDataTrackingPage_RegisterWechatVerify        = @"register_wechat_verify";
NSString * const DXDataTrackingPage_RegisterPassword            = @"register_password";
NSString * const DXDataTrackingPage_RegisterUserInfo            = @"register_user_info";
NSString * const DXDataTrackingPage_RecoverPhoneVerify          = @"recover_phone_verify";
NSString * const DXDataTrackingPage_RecoverPassword             = @"recover_password";
NSString * const DXDataTrackingPage_Messages                    = @"messages";
NSString * const DXDataTrackingPage_MessagesComments            = @"messages_comments";
NSString * const DXDataTrackingPage_MessagesLikes               = @"messages_likes";
NSString * const DXDataTrackingPage_MessagesNotices             = @"messages_notices";
NSString * const DXDataTrackingPage_PrivateChat                 = @"private_chat";
NSString * const DXDataTrackingPage_Web                         = @"web";
NSString * const DXDataTrackingPage_Search                      = @"search";
NSString * const DXDataTrackingPage_SearchMoreTopic             = @"search_more_topic";
NSString * const DXDataTrackingPage_SearchMoreUser              = @"search_more_user";
NSString * const DXDataTrackingPage_SearchMoreActivity          = @"search_more_activity";
NSString * const DXDataTrackingPage_SearchMoreFeed              = @"search_more_feed";
NSString * const DXDataTrackingPage_ReferUser                   = @"refer_user";
NSString * const DXDataTrackingPage_ReferTopic                  = @"refer_topic";

@implementation UIViewController (DXDataTracking)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self dt_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(dt_viewDidAppear:)];
        [self dt_swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(dt_viewDidDisappear:)];
    });
}


- (void)setDt_pageName:(NSString *)dt_pageName {
    objc_setAssociatedObject(self, @selector(dt_pageName), dt_pageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)dt_pageName {
    return objc_getAssociatedObject(self, @selector(dt_pageName));
}


- (void)dt_viewDidAppear:(BOOL)animated {
    [self dt_viewDidAppear:animated];
    
    if (self.dt_pageName) {
#ifndef DEBUG
        dx_trackPageBegin(self.dt_pageName);
#endif
    }
}


- (void)dt_viewDidDisappear:(BOOL)animated {
    [self dt_viewDidDisappear:animated];
    
    if (self.dt_pageName) {
#ifndef DEBUG
        dx_trackPageEnd(self.dt_pageName);
#endif
    }
}


+ (void)dt_swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    Class thisClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(thisClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(thisClass, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(thisClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(thisClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
