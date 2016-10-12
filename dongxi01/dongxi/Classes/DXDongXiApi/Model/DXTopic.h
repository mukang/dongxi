//
//  DXTopic.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface DXTopic : NSObject

@property (nonatomic, copy) NSString *topic_id;

@property (nonatomic, assign) NSInteger joined;

@property (nonatomic, assign) BOOL is_like;

@property (nonatomic, assign) BOOL is_top;

@property (nonatomic, assign) BOOL is_join;

@property (nonatomic, copy) NSString *topic;

@property (nonatomic, copy) NSString *cover;

@property (nonatomic, copy) NSString *thumb;

@property (nonatomic, assign) NSUInteger topic_type;

@property (nonatomic, copy) NSString *txt;

/** 话题活跃度 */
@property (nonatomic, assign) NSInteger activeness;
/** 是否是有奖话题 */
@property (nonatomic, assign) BOOL has_prize;
/** 副标题 */
@property (nonatomic, copy) NSString *title;

@end
