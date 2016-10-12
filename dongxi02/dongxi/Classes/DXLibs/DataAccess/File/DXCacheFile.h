//
//  DXCacheFile.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    /** 通用类型的缓存 */
    DXCacheFileTypeGeneralCache,
    /** 图片类型的缓存 */
    DXCacheFileTypeImageCache,
    /** 配置类型的缓存 */
    DXCacheFileTypeConfigCache
} DXCacheFileType;



@interface DXCacheFile : NSObject

/**
 *  指定初始化方法
 *
 *  @param cacheFileType 缓存文件类型，见DXCacheFileType。不同缓存类型的缓存文件会保存在不同地方
 *
 *  @return 返回DXCacheFile实例
 */
- (instancetype)initWithFileType:(DXCacheFileType)cacheFileType;


/**
 *  生成实例的快速方法
 *
 *  @param cacheFileType 缓存文件类型，见DXCacheFileType。不同缓存类型的缓存文件会保存在不同地方
 *
 *  @return 返回DXCacheFile实例
 */
+ (instancetype)cacheFileWithFileType:(DXCacheFileType)cacheFileType;


/** 文件名，当assignRandomName为YES时可以不指定文件名，否则必须指定 */
@property (nonatomic, strong) NSString * name;

/** 文件后缀，可以不指定 */
@property (nonatomic, strong) NSString * extension;

/** 相对路径目录，可以不指定，指定时会在指定目录下再创建一个路径目录来缓存文件 */
@property (nonatomic, strong) NSString * relativePath;

/** 只读，文件类型，在初始化时指定。见-[DXCacheFile initWithFileType:] */
@property (nonatomic, readonly, assign) DXCacheFileType fileType;

/** 是否分配随机名称，默认为YES，当name为nil时会随机分配名字，当name不为nil时，既是该属性为YES也不会分配名字 */
@property (nonatomic, assign) BOOL assignRandomName;

/** 是否当App启动的时候自动清除该文件，默认为NO */
@property (nonatomic, assign) BOOL deleteWhenAppLaunch;



/** 只读，文件ID，保存文件后会得到该属性 */
@property (nonatomic, readonly, strong) NSString * fileID;

/** 只读，文件全名，实质为name和extension的组合 */
@property (nonatomic, readonly, strong) NSString * fullName;

/** 只读，文件保存地址，保存文件后会得到该属性 */
@property (nonatomic, readonly, strong) NSURL * url;

/** 只读，文件保存版本，保存文件后会得到该属性 */
@property (nonatomic, readonly, strong) NSString * version;

/** 只读，创建时间戳，保存文件后会得到改属性 */
@property (nonatomic, readonly, assign) NSTimeInterval createdAt;

/** 只读，更新时间戳，保存文件后会得到改属性 */
@property (nonatomic, readonly, assign) NSTimeInterval updatedAt;



@end
