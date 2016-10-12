//
//  DXCacheFile+Internal.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCacheFile.h"

@interface DXCacheFile (Internal)

- (void)setFileID:(NSString *)fileID;

- (void)setFileType:(DXCacheFileType)fileType;

- (void)setUrl:(NSURL *)url;

- (void)setVersion:(NSString *)version;

- (void)setCreatedAt:(NSTimeInterval)createdAt;

- (void)setUpdatedAt:(NSTimeInterval)updatedAt;

- (NSString *)trimPathString:(NSString *)pathString;

@end
