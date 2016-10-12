//
//  DXDataTrackingHelpers.m
//  dongxi
//
//  Created by Xu Shiwen on 16/2/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDataTrackingHelpers.h"
#import "TalkingData.h"



/**
 *  统计自定义事件
 *  @param  eventId     事件名称
 *  @param  eventLabel  事件标签，可为nil，
 *  @param  parameters  事件参数(key只支持NSString, value支持NSString和NSNumber)，可为nil
 */
void dx_trackEvent(NSString * eventId, NSString * eventLabel, NSDictionary * parameters) {
    if (eventLabel != nil && parameters != nil) {
        [TalkingData trackEvent:eventId label:eventLabel parameters:parameters];
    } else if (eventLabel != nil) {
        [TalkingData trackEvent:eventId label:eventLabel];
    } else {
        [TalkingData trackEvent:eventId];
    }
}


/**
 *  开始追踪某一页面
 *  @param  pageName    页面名称
 */
void dx_trackPageBegin(NSString * pageName) {
    [TalkingData trackPageBegin:pageName];
}


/**
 *  结束追踪某一页面
 *  @param  pageName    页面名称
 */
void dx_trackPageEnd(NSString * pageName) {
    [TalkingData trackPageEnd:pageName];
}