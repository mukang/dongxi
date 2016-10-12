//
//  DXSearchResults.h
//  dongxi
//
//  Created by 穆康 on 16/1/21.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXSearchResults : NSObject

@property (nonatomic, strong) DXSearchTopicWrapper *topic;

@property (nonatomic, strong) DXSearchUserWrapper *user;

@property (nonatomic, strong) DXSearchActivityWrapper *activity;

@property (nonatomic, strong) DXSearchFeedWrapper *feed;

@end

