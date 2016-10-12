//
//  DXArchiveService.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXArchiveService : NSObject

+ (instancetype)sharedService;

- (BOOL)archiveObject:(id)object ForLoginUser:(NSString *)uid;

- (id)unarchiveObject:(NSString *)modelName ForLoginUser:(NSString *)uid;

- (BOOL)cleanObject:(NSString *)modelName ForLoginUser:(NSString *)uid;

- (BOOL)archiveObject:(id)object ForLoginUser:(NSString *)uid forcePersist:(BOOL)force;

- (id)unarchiveObject:(NSString *)modelName ForLoginUser:(NSString *)uid forcePersist:(BOOL)force;

- (BOOL)cleanObject:(NSString *)modelName ForLoginUser:(NSString *)uid forcePersist:(BOOL)force;

@end
