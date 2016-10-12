//
//  DXFeedFeedUpdateRequest.h
//  dongxi
//
//  Created by 穆康 on 16/5/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXFeedFeedUpdateRequest : DXClientRequest

@property (nonatomic, copy) NSDictionary * topicPost;
@property (nonatomic, copy) NSArray * photoURLs;

@end
