//
//  DXTopicPost.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXTopicPost : NSObject

/** 更新feed时有用 */
@property (nonatomic, copy) NSString *feed_id;
@property (nonatomic, strong) NSArray *image_ids;
@property (nonatomic, strong) NSArray *image_url;

@property (nonatomic, copy) NSString * txt;
@property (nonatomic, assign) BOOL lock;
@property (nonatomic, strong) NSArray * tag;
@property (nonatomic, copy) NSString * topic_id;
@property (nonatomic, copy) NSString * lat;
@property (nonatomic, copy) NSString * lng;
@property (nonatomic, copy) NSString * place;
@property (nonatomic, strong) NSArray *content_pieces;

- (void)setPhotoURLs:(NSArray *)photoURLs;
- (NSArray *)photoURLs;

@end
