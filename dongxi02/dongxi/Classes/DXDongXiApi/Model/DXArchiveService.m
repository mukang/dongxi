//
//  DXArchiveService.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXArchiveService.h"
#import "DXFunctions.h"

@implementation DXArchiveService

+ (instancetype)sharedService {
    static DXArchiveService * service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [DXArchiveService new];
    });
    return service;
}

- (BOOL)archiveObject:(id)object ForLoginUser:(NSString *)uid {
    return [self archiveObject:object ForLoginUser:uid forcePersist:NO];
}

- (id)unarchiveObject:(NSString *)modelName ForLoginUser:(NSString *)uid {
    return [self unarchiveObject:modelName ForLoginUser:uid forcePersist:NO];
}

- (BOOL)cleanObject:(NSString *)modelName ForLoginUser:(NSString *)uid {
    return [self cleanObject:modelName ForLoginUser:uid forcePersist:NO];
}

- (BOOL)archiveObject:(id)object ForLoginUser:(NSString *)uid forcePersist:(BOOL)force {
    NSString * modelName = NSStringFromClass([object class]);
    return [NSKeyedArchiver archiveRootObject:object toFile:[self archiveFileURLForLoginUser:uid andModel:modelName forcePersist:force].path];
}

- (id)unarchiveObject:(NSString *)modelName ForLoginUser:(NSString *)uid forcePersist:(BOOL)force {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archiveFileURLForLoginUser:uid andModel:modelName forcePersist:force].path];
}

- (BOOL)cleanObject:(NSString *)modelName ForLoginUser:(NSString *)uid forcePersist:(BOOL)force {
    NSURL * fileURL = [self archiveFileURLForLoginUser:uid andModel:modelName forcePersist:force];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileURL.path]) {
        return [fileManager removeItemAtURL:fileURL error:nil];
    } else {
        return YES;
    }
}


#pragma mark - Private Methods

- (NSURL *)archiveFileURLForLoginUser:(NSString *)uid andModel:(NSString *)modelName forcePersist:(BOOL)force {
    
    NSAssert(modelName, @"modelName不可为nil");
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSSearchPathDirectory directory;
    if (force) {
        directory = NSDocumentDirectory;
    } else {
        directory = NSCachesDirectory;
    }
    NSURL * docDirURL = [[fileManager URLsForDirectory:directory inDomains:NSUserDomainMask] firstObject];
    docDirURL =[docDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/dxArchiveService", DXGetAppIdentifier()] isDirectory:YES];
    
    NSURL * archiveDirURL = nil;
    if (uid == nil) {
        archiveDirURL = [docDirURL URLByAppendingPathComponent:@"data/archive/common" isDirectory:YES];
    } else {
        archiveDirURL = [docDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"data/archive/%@", DXDigestMD5(uid)] isDirectory:YES];
    }
    
    // 检查目录
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:archiveDirURL.path isDirectory:&isDirectory]) {
        NSError * err = nil;
        [fileManager createDirectoryAtURL:archiveDirURL withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            //TODO: 处理目录创建错误
            return nil;
        }
    } else {
        if (isDirectory == NO) {
            //TODO: 处理目录名已被占用错误
            return nil;
        }
    }
    NSURL * fileURL = [archiveDirURL URLByAppendingPathComponent:DXDigestMD5(modelName)];
    return fileURL;
}

@end
