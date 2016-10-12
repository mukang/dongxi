//
//  DXCacheFileQuery.h
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  DXCacheFile查询条件类，每个属性代表需要匹配的内容，设置多少属性
就会增加多少查询约束，如没有设置任何属性，则表示匹配所有的文件
 *
 *  @discussion **注意: 每个属性只支持完全匹配，不支持模糊或正则**
 */
@interface DXCacheFileQuery : NSObject

/** 匹配文件名 */
@property (nonatomic, copy) NSString * name;

/** 匹配文件后缀名 */
@property (nonatomic, copy) NSString * extension;

/** 匹配自定义相对路径 */
@property (nonatomic, copy) NSString * relativePath;

/** 匹配缓存文件类型，见DXCacheFileType */
@property (nonatomic, copy) NSNumber * fileType;

/** 匹配是否在启动时删除属性 */
@property (nonatomic, copy) NSNumber * deleteWhenAppLaunch;

@end
