//
//  DXCacheFile.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCacheFile.h"
#import "DXCacheFile+Internal.h"

@implementation DXCacheFile

- (instancetype)init {
    self = [super init];
    if (self) {
        _assignRandomName = YES;
    }
    return self;
}

- (instancetype)initWithFileType:(DXCacheFileType)cacheFileType {
    self = [self init];
    if (self) {
        _fileType = cacheFileType;
    }
    return self;
}

+ (instancetype)cacheFileWithFileType:(DXCacheFileType)cacheFileType {
    return [[self alloc] initWithFileType:cacheFileType];
}

- (void)setName:(NSString *)name {
    _name = [self trimPathString:name returnNilIfEmpty:YES];
}

- (void)setExtension:(NSString *)extension {
    _extension = [self trimPathString:extension returnNilIfEmpty:YES];
}

- (void)setRelativePath:(NSString *)relativePath {
    _relativePath = [self trimPathString:relativePath returnNilIfEmpty:YES];
}

- (NSString *)fullName {
    if (self.extension) {
        return [self.name stringByAppendingPathExtension:self.extension];
    } else {
        return self.name;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<DXCacheFile fileID:%@, name:%@, extension:%@, relativePath:%@, fileType:%d, url:%@, deleteWhenAppLaunch:%d, assignRandomName:%d, createdAt:%.0f, updatedAt:%.0f, version:%@>", self.fileID, self.name, self.extension, self.relativePath, (int)self.fileType, self.url.path, self.deleteWhenAppLaunch, self.assignRandomName, self.createdAt, self.updatedAt, self.version];
}


#pragma mark - Internal

- (void)setFileID:(NSString *)fileID {
    _fileID = fileID;
}

- (void)setFileType:(DXCacheFileType)fileType {
    _fileType = fileType;
}

- (void)setUrl:(NSURL *)url {
    _url = url;
}

- (void)setVersion:(NSString *)version {
    _version = version;
}

- (void)setCreatedAt:(NSTimeInterval)createdAt {
    _createdAt = createdAt;
}

- (void)setUpdatedAt:(NSTimeInterval)updatedAt {
    _updatedAt = updatedAt;
}

- (NSString *)trimPathString:(NSString *)pathString returnNilIfEmpty:(BOOL)returnNilIfEmpty {
    pathString = [pathString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    pathString = [pathString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    if (pathString.length == 0 && returnNilIfEmpty) {
        return nil;
    } else {
        return pathString;
    }
    
}

@end
