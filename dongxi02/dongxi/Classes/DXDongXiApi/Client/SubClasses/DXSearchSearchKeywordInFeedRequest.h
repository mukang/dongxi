//
//  DXSearchSearchKeywordInFeedRequest.h
//  dongxi
//
//  Created by 穆康 on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXSearchSearchKeywordInFeedRequest : DXClientRequest

@property (nonatomic, copy) NSString *keyword;

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy) NSString *last_id;

@end
