//
//  DXWatermark.h
//  dongxi
//
//  Created by Xu Shiwen on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BUNDLE_WATERMARK @"watermark.bundle"

typedef enum : NSUInteger {
    DXWatermarkTypeNormal = 0,
    DXWatermarkTypeTopic
} DXWatermarkType;

typedef enum : NSUInteger {
    DXWatermarkSourceLocal = 0,
    DXWatermarkSourceServer,
} DXWatermarkSourceType;


@interface DXWatermark : NSObject <NSCoding>

@property (nonatomic, copy) NSString * ID;
@property (nonatomic, assign) DXWatermarkType type;
@property (nonatomic, assign) DXWatermarkSourceType sourceType;

@property (nonatomic, copy) NSString * image_url;
@property (nonatomic, copy) NSString * thumb_url;

@property (nonatomic, copy) NSString * image;
@property (nonatomic, copy) NSString * thumb_image;

@property (nonatomic, strong) NSArray * origin;
@property (nonatomic, strong) NSArray * offset;
@property (nonatomic, assign) CGFloat initial_scale;
@property (nonatomic, copy) NSString * topic_id;
@property (nonatomic, copy) NSString * topic_title;
@property (nonatomic, copy) NSString * comment;
@property (nonatomic, copy) NSString * created_at;
@property (nonatomic, copy) NSString * updated_at;

- (NSURL *)imageURLForCurrentScreen;
- (NSURL *)thumbURLForCurrentScreen;

- (NSString *)imageName;
- (NSString *)thumbName;

@end





@interface DXWatermarkManager : NSObject

+ (instancetype)sharedManager;

- (void)loadWatermarks:(void(^)(NSArray * watermarks, DXWatermarkSourceType sourceType, NSError * error))completion;

- (void)clearCache;

@end
