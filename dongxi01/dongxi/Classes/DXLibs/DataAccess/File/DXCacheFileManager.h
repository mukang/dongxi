//
//  DXCacheFileManager.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXCacheFile.h"
#import "DXCacheFileQuery.h"

#define DXCFM_LOG_ON 0

extern NSString * const DXCacheFileManagerErrorDomain;

typedef enum : NSInteger {
    DXCacheFileManagerErrorCodeDirectoryNil = -20000,
    DXCacheFileManagerErrorCodeFileNotExist
} DXCacheFileManagerErrorCode;

/**
 *  缓存文件管理类
 *
 *  @author Shiwen Xu
 *  @date   2015/9/9
 */
@interface DXCacheFileManager : NSObject

/**
 *  获取DXCacheFileManager实例
 *
 *  @return 返回DXCacheFileManager实例
 */
+ (DXCacheFileManager *)sharedManager;

/**
 *  保存数据到缓存文件
 *
 *  @param data  要保存的数据，不能为nil
 *  @param file  缓存文件，不能为nil，当file的assignRandomName为NO时，file的name不能为nil
 *  @param error 错误信息
 *
 *  @return 返回YES表示保存成功，返回NO表示保存失败
 */
- (BOOL)saveData:(NSData *)data toFile:(DXCacheFile *)file error:(NSError **)error;

/**
 *  从缓存文件读取信息
 *
 *  @param data  用来保存读取的数据的NSData指针
 *  @param file  需要读取的文件，不能为nil，且file的name不能为nil
 *  @param error 错误信息
 *
 *  @return 返回YES表示读取成功，返回NO表示读取失败
 */
- (BOOL)readData:(NSData **)data fromFile:(DXCacheFile *)file error:(NSError **)error;


- (NSArray *)filesWithQuery:(DXCacheFileQuery *)query;


/**
 *  查询指定缓存文件是否存在
 *
 *  @param file 缓存文件实例，见DXCacheFile
 *
 *  @return 返回YES表示缓存文件存在，反之表示不存在
 */
- (BOOL)isFileExisted:(DXCacheFile *)file;



/**
 *  删除指定的缓存文件
 *
 *  @param file  缓存文件实例，见DXCacheFile
 *  @param error 错误信息
 *
 *  @return 返回YES表示删除成功，反之表示失败
 */
- (BOOL)deleteFile:(DXCacheFile *)file error:(NSError **)error;



/**
 *  应用启动回调处调用该方法，其他地方不要使用
 *
 *  @param option 应用启用信息
 */
- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)option;

@end
