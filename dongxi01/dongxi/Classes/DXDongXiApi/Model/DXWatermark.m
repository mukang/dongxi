//
//  DXWatermark.m
//  dongxi
//
//  Created by Xu Shiwen on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXWatermark.h"
#import "DXDongXiApi.h"
#import "NSObject+DXModel.h"


@implementation DXWatermark

- (NSURL *)imageURLForCurrentScreen {
    if (self.image_url) {
        NSInteger scale = [[UIScreen mainScreen] scale];
        if (scale == 3) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@-3x", self.image_url]];
        } else if (scale == 2) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@-2x", self.image_url]];
        } else {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@-2x", self.image_url]];
        }
    } else {
        return nil;
    }
}

- (NSURL *)thumbURLForCurrentScreen {
    if (self.thumb_url) {
        NSInteger scale = [[UIScreen mainScreen] scale];
        if (scale == 3) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@-3x", self.thumb_url]];
        } else if (scale == 2) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@-2x", self.thumb_url]];
        } else {
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@-2x", self.thumb_url]];
        }
    } else {
        return nil;
    }
}


- (NSString *)imageName {
    if (self.image) {
        return [NSString stringWithFormat:@"%@/%@", BUNDLE_WATERMARK, self.image];
    } else {
        return nil;
    }
}

- (NSString *)thumbName {
    if (self.thumb_image) {
        return [NSString stringWithFormat:@"%@/%@", BUNDLE_WATERMARK, self.thumb_image];
    } else {
        return nil;
    }
}

@end



@interface DXWatermarkManager()

@property (nonatomic, strong) NSURL * bundleURL;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, assign) NSInteger updateTimestamp;
@property (nonatomic, assign) NSTimeInterval refreshInterval;

@end


@implementation DXWatermarkManager

+ (instancetype)sharedManager {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[[self class] alloc] init];
            [manager initialize];
        }
    });
    return manager;
}

- (void)initialize {
    self.bundleURL = [[NSBundle mainBundle] URLForResource:BUNDLE_WATERMARK withExtension:nil];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber * timestampValue = [userDefaults objectForKey:DX_DEFAULTS_KEY_WATERMARK_TIMESTAMP];
    if (timestampValue) {
        self.timestamp = [timestampValue integerValue];
    } else {
        self.timestamp = 0;
    }
    
    NSNumber * updateTimestampValue = [userDefaults objectForKey:DX_DEFAULTS_KEY_WATERMARK_UPDATE];
    if (updateTimestampValue) {
        self.updateTimestamp = [updateTimestampValue integerValue];
    } else {
        self.updateTimestamp = 0;
    }
    
    self.refreshInterval = 3600*0.5; //0.5小时间隔
}

- (void)loadWatermarks:(void (^)(NSArray *, DXWatermarkSourceType, NSError *))completion {
    NSArray * localWatermarks = [self loadFromBundle];
    completion(localWatermarks, DXWatermarkSourceLocal, nil);
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (self.updateTimestamp == 0 || now > self.updateTimestamp + self.refreshInterval) {
        typeof(self) __weak weakSelf = self;
        [[DXDongXiApi api] checkWatermarksWithTimestamp:self.timestamp result:^(NSArray *watermarks, NSInteger timestamp, NSError *error) {
            if (watermarks.count > 0) {
                weakSelf.timestamp = timestamp;
                weakSelf.updateTimestamp = now;
                [weakSelf saveToCache:watermarks];
                //存储时存储通用比例，但发送给回调时使用根据屏幕适配后的比例
                [watermarks enumerateObjectsUsingBlock:^(DXWatermark * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.initial_scale *= DXRealValue(1);
                }];
                completion(watermarks, DXWatermarkSourceServer, error);
            } else {
                NSArray * cachedWatermarks = [self loadFromCache];
                completion(cachedWatermarks, DXWatermarkSourceServer, nil);
            }
        }];
    } else {
        NSArray * cachedWatermarks = [self loadFromCache];
        completion(cachedWatermarks, DXWatermarkSourceServer, nil);
    }
}

- (void)clearCache {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:DX_DEFAULTS_KEY_WATERMARK_LIST];
    [userDefaults removeObjectForKey:DX_DEFAULTS_KEY_WATERMARK_TIMESTAMP];
    [userDefaults removeObjectForKey:DX_DEFAULTS_KEY_WATERMARK_UPDATE];
    
    self.timestamp = 0;
    self.updateTimestamp = 0;
}

- (NSArray *)loadFromBundle {
    NSMutableArray * list = [NSMutableArray array];
    if (self.bundleURL) {
        NSBundle * watermarkBundle = [NSBundle bundleWithURL:self.bundleURL];
        if (watermarkBundle) {
            NSURL * configFile = [watermarkBundle URLForResource:@"config" withExtension:@"plist"];
            NSDictionary * config = [NSDictionary dictionaryWithContentsOfURL:configFile];
            NSArray * watermarkConfigs = [config objectForKey:@"watermarks"];
            for (NSDictionary * info in watermarkConfigs) {
                @autoreleasepool {
                    DXWatermark * watermark = [[DXWatermark alloc] initWithObjectDictionary:info];
                    watermark.sourceType = DXWatermarkSourceLocal;
                    watermark.initial_scale *= DXRealValue(1);
                    [list addObject:watermark];
                }
            }
        }
    }
    return [list copy];
}

- (NSArray *)loadFromCache {
    NSMutableArray * objectList = [NSMutableArray array];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * encodedWatermarkList = [userDefaults objectForKey:DX_DEFAULTS_KEY_WATERMARK_LIST];
    
    for (NSData * encodedWatermark in encodedWatermarkList) {
        DXWatermark * watermark = [NSKeyedUnarchiver unarchiveObjectWithData:encodedWatermark];
        if (watermark) {
            [objectList addObject:watermark];
        }
    }
    return [objectList copy];
}

- (void)saveToCache:(NSArray *)objectList {
    NSMutableArray * encodedWatermarkList = [NSMutableArray array];
    for (DXWatermark * watermark in objectList) {
        NSData * encodedWatermark = [NSKeyedArchiver archivedDataWithRootObject:watermark];
        if (encodedWatermark) {
            [encodedWatermarkList addObject:encodedWatermark];
        }
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:encodedWatermarkList forKey:DX_DEFAULTS_KEY_WATERMARK_LIST];
}


- (void)setTimestamp:(NSInteger)timestamp {
    _timestamp = timestamp;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(timestamp) forKey:DX_DEFAULTS_KEY_WATERMARK_TIMESTAMP];
}

- (void)setUpdateTimestamp:(NSInteger)updateTimestamp {
    _updateTimestamp = updateTimestamp;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(updateTimestamp) forKey:DX_DEFAULTS_KEY_WATERMARK_UPDATE];
}

@end