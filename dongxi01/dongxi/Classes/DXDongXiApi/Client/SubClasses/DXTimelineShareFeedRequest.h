//
//  DXTimelineShareFeedRequest.h
//  dongxi
//
//  Created by 穆康 on 16/2/23.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

/** 通知服务器feed已被分享 */
@interface DXTimelineShareFeedRequest : DXClientRequest

@property (nonatomic, copy) NSString *fid;

@property (nonatomic, copy) NSString *share_to;

@end
