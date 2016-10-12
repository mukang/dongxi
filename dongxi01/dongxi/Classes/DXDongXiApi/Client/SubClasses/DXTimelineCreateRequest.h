//
//  DXTimelineCreateRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXTimelineCreateRequest : DXClientRequest

@property (nonatomic, copy) NSDictionary * topicPost;
@property (nonatomic, copy) NSArray * photoURLs;

@end
