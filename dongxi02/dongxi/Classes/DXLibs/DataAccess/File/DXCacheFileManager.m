//
//  DXCacheFileManager.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCacheFileManager.h"
#import "DXCacheFile+Internal.h"
#import "DXFunctions.h"
#import <sqlite3.h>

#if DXCFM_LOG_ON == 1
#define DXCFMLog(FORMAT, ...) NSLog(@"<DXCFM> [notice] [Line %d] " FORMAT, __LINE__, ##__VA_ARGS__)
#else
#define DXCFMLog(FORMAT, ...)
#endif

#define DXCFMWarn(FORMAT, ...) NSLog(@"<DXCFM> [warning] [Line %d] " FORMAT, __LINE__, ##__VA_ARGS__)

NSString * const DXCacheFileManagerErrorDomain  = @"DXCacheFileManagerErrorDomain";

@implementation DXCacheFileManager {
    NSFileManager * _systemFileManager;
    NSString * _baseDirectory;
    sqlite3 * _database;
    NSString * _tableName;
    NSString * _tableVersion;
}

#pragma mark - Public

+ (DXCacheFileManager *)sharedManager {
    static dispatch_once_t onceToken;
    static DXCacheFileManager * shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        shared->_systemFileManager = [NSFileManager defaultManager];
        //以App ID作为上级文件夹
        shared->_baseDirectory = DXGetAppIdentifier();
        [shared prepareDatabase];
    });
    return shared;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (BOOL)saveData:(NSData *)data toFile:(DXCacheFile *)file error:(NSError *__autoreleasing *)error {
    NSAssert(data != nil, @"参数data不能为nil");
    NSAssert(file != nil, @"参数file不能为nil");
    NSAssert(file.assignRandomName == YES || file.name != nil, @"当DXManagedFile的属性assignRandomName为NO时，name不能为nil");
    
    if (file.assignRandomName && file.name == nil) {
        [file setName:[self getRandomFileName]];
    }
    [file setUrl:[self getURLForManagedFile:file]];
    
    BOOL success = [self saveData:data toAbsoluteURL:file.url error:error];
    if (success) {
        [self writeFileToDatabase:file];
    }
    return success;
}

- (BOOL)readData:(NSData *__autoreleasing *)data fromFile:(DXCacheFile *)file error:(NSError *__autoreleasing *)error {
    NSAssert(file != nil, @"参数file不能为nil");
    NSAssert(file.name != nil, @"参数file的name属性不能为nil");
    
    if ([self isFileExisted:file]) {
        if (data) {
            NSURL * fileURL = [self getURLForManagedFile:file];
            *data = [NSData dataWithContentsOfURL:fileURL];
            DXCacheFile * existedFile = [self getFileFromDataBase:file];
            if (existedFile) {
                //如果文件记录存在，拷贝文件信息
                [self copyFileInfoFrom:existedFile toFile:file];
            } else {
                //如果文件记录不存在，补充一个文件记录
                [self writeFileToDatabase:file];
            }
            [file setUrl:fileURL];
        }
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:DXCacheFileManagerErrorDomain code:DXCacheFileManagerErrorCodeFileNotExist userInfo:@{NSLocalizedDescriptionKey : @"文件不存在"}];
        }
        return NO;
    }
}


- (NSArray *)filesWithQuery:(DXCacheFileQuery *)query {
    NSMutableArray * files = [NSMutableArray array];
    
    if (query) {
        NSMutableArray * queryParams = [NSMutableArray array];
        if (query.name) {
            [queryParams addObject:[NSString stringWithFormat:@"name = '%@'", query.name]];
        }
        if (query.extension) {
            [queryParams addObject:[NSString stringWithFormat:@"extension = '%@'", query.extension]];
        }
        if (query.relativePath) {
            [queryParams addObject:[NSString stringWithFormat:@"relative_path = '%@'", query.relativePath]];
        }
        if (query.fileType) {
            [queryParams addObject:[NSString stringWithFormat:@"file_type = %d", query.fileType.intValue]];
        }
        if (query.deleteWhenAppLaunch) {
            [queryParams addObject:[NSString stringWithFormat:@"delete_when_app_launch = %d", query.deleteWhenAppLaunch.boolValue]];
        }
        
        NSString * queryParts = nil;
        if (queryParams.count > 0) {
            queryParts = [queryParams componentsJoinedByString:@" and "];
        }
        
        NSString * selectSQL = nil;
        sqlite3_stmt * stmt = NULL;
        if (queryParts) {
            selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@;", _tableName, queryParts];
        } else {
            selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@;", _tableName];
        }
        
        if (sqlite3_prepare_v2(_database, selectSQL.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                DXCacheFile * cacheFile = [self getFileWithSqliteStatement:stmt];
                if (cacheFile) {
                    [files addObject:cacheFile];
                }
            }
        } else {
            DXCFMWarn(@"查询文件记录SQL编译失败: %s", sqlite3_errmsg(_database));
        }
        sqlite3_finalize(stmt);
    }
    
    return [files copy];
}


- (BOOL)isFileExisted:(DXCacheFile *)file {
    NSURL * fileURL = [self getURLForManagedFile:file];
    return [_systemFileManager fileExistsAtPath:fileURL.path];
}

- (BOOL)deleteFile:(DXCacheFile *)file error:(NSError *__autoreleasing *)error {
    NSAssert(file.url != nil, @"参数file的url属性不能为nil");
    
    NSError * localError = nil;
    NSURL * fileURL = [self getURLForManagedFile:file];
    BOOL success = [self deleteFileAtURL:fileURL error:&localError];
    if (success) {
        [self removeFileFromDatabase:file];
    } else {
        if (error) {
            *error = localError;
        }
        if ([localError.domain isEqualToString:DXCacheFileManagerErrorDomain] &&
            localError.code == DXCacheFileManagerErrorCodeFileNotExist) {
            [self removeFileFromDatabase:file];
        }
    }
    return success;
}

- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)option {
    DXCacheFileQuery * query = [[DXCacheFileQuery alloc] init];
    query.deleteWhenAppLaunch = @(YES);
    NSArray * allCacheFiles = [self filesWithQuery:query];
    for (DXCacheFile * cacheFile in allCacheFiles) {
        if (cacheFile.deleteWhenAppLaunch) {
            [self deleteFile:cacheFile error:nil];
        }
    }
}

#pragma mark - Internal

+ (NSDictionary *)subdirectoryConfig {
    return @{
             @(DXCacheFileTypeGeneralCache)     : @"dxCacheFileManager/general/",
             @(DXCacheFileTypeImageCache)       : @"dxCacheFileManager/images/",
             @(DXCacheFileTypeConfigCache)      : @"dxCacheFileManager/config/"
             };
}

#pragma mark 数据库操作

- (void)prepareDatabase {
    _tableName = @"cache_file";
    _tableVersion = @"1.0";
    
    DXCacheFile * dbFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeConfigCache];
    dbFile.assignRandomName = NO;
    dbFile.name = @"data";
    dbFile.extension = @"db";

    NSURL * dbFileURL = [self getURLForManagedFile:dbFile];
    NSError * error = nil;
    if ([self prepareDirectoryForFileAtURL:dbFileURL error:&error]) {
        if (sqlite3_open(dbFileURL.path.UTF8String, &_database) != SQLITE_OK) {
            sqlite3_close(_database);
        } else {
            NSString * tablePrepareSql = [NSString stringWithFormat:
                                          @"CREATE TABLE IF NOT EXISTS %@ ("
                                          "file_id INTEGER PRIMARY KEY AUTOINCREMENT,"
                                          "file_type INTEGER,"
                                          "name TEXT,"
                                          "extension TEXT,"
                                          "relative_path TEXT,"
                                          "full_name TEXT,"
                                          "delete_when_app_launch NUMERIC,"
                                          "assign_random_name NUMERIC,"
                                          "created_at INTEGER,"
                                          "updated_at INTEGER,"
                                          "version REAL,"
                                          "_extra BLOB"
                                          ");", _tableName];
            char * sqlite3_err = NULL;
            if (sqlite3_exec(_database, tablePrepareSql.UTF8String, NULL, NULL, &sqlite3_err) != SQLITE_OK) {
                DXCFMWarn(@"准备table出错: %s", sqlite3_err);
            } else {
                DXCFMLog(@"准备table成功, SQL: %@", tablePrepareSql);
            }
        }
    } else {
        DXCFMWarn(@"准备文件目录出错: %@", error.localizedDescription);
    }
}

- (DXCacheFile *)getFileFromDataBase:(DXCacheFile *)file {
    DXCacheFile * cacheFile = nil;
    
    sqlite3_stmt * stmt = NULL;
    NSString * selectSQL = nil;
    if (file.fileID) {
        selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE file_id = ?1", _tableName];
    } else {
        selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE full_name = ?1 and relative_path = ?2 and file_type = ?3 and assign_random_name = ?4;", _tableName];
    }
    if (sqlite3_prepare_v2(_database, selectSQL.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
        if (file.fileID) {
            sqlite3_bind_int64(stmt, 1, [file.fileID longLongValue]);
        } else {
            sqlite3_bind_text(stmt, 1, file.fullName.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt, 2, file.relativePath.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt, 3, file.fileType);
            sqlite3_bind_int(stmt, 4, file.assignRandomName);
        }
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            cacheFile = [self getFileWithSqliteStatement:stmt];
            NSURL * fileURL = [self getURLForManagedFile:cacheFile];
            [cacheFile setUrl:fileURL];
            break;
        }
    } else {
        DXCFMWarn(@"文件记录查询SQL编译失败: %s", sqlite3_errmsg(_database));
    }
    sqlite3_finalize(stmt);

    return cacheFile;
}

- (DXCacheFile *)getFileWithSqliteStatement:(sqlite3_stmt *)stmt {
    DXCacheFile * cacheFile = nil;
    NSDictionary * rowInfo = [self getRowInfoFromSqliteStatement:stmt];
    if (rowInfo) {
        cacheFile = [[DXCacheFile alloc] init];
         /** 设置fileID */
        NSNumber * fileIDValue = [rowInfo objectForKey:@"file_id"];
        if (fileIDValue) {
            [cacheFile setFileID:[NSString stringWithFormat:@"%lld", [fileIDValue longLongValue]]];
        }
        /** 设置fileType */
        NSNumber * fileTypeValue = [rowInfo objectForKey:@"file_type"];
        if (fileTypeValue) {
            [cacheFile setFileType:[fileTypeValue integerValue]];
        }
        
        // 如果fileID、fileType并没有同时存在，则认为该记录信息是不完整的
        if (fileIDValue && fileTypeValue) {
            /** 设置name */
            NSString * name = [rowInfo objectForKey:@"name"];
            [cacheFile setName:name];
            /** 设置extension */
            NSString * extension = [rowInfo objectForKey:@"extension"];
            [cacheFile setExtension:extension];
            /** 设置relativePath */
            NSString * relativePath = [rowInfo objectForKey:@"relative_path"];
            [cacheFile setRelativePath:relativePath];
            /** 设置deleteWhenAppLaunch */
            NSNumber * deleteWhenAppLaunchValue = [rowInfo objectForKey:@"delete_when_app_launch"];
            if (deleteWhenAppLaunchValue) {
                [cacheFile setDeleteWhenAppLaunch:[deleteWhenAppLaunchValue boolValue]];
            }
            /** 设置createdAt */
            NSNumber * createdAtValue = [rowInfo objectForKey:@"created_at"];
            if (createdAtValue) {
                [cacheFile setCreatedAt:[createdAtValue floatValue]];
            }
            /** 设置updatedAt */
            NSNumber * updatedAtValue = [rowInfo objectForKey:@"updated_at"];
            if (updatedAtValue) {
                [cacheFile setUpdatedAt:[updatedAtValue floatValue]];
            }
            /** 设置version */
            NSNumber * versionValue = [rowInfo objectForKey:@"version"];
            if (versionValue) {
                [cacheFile setVersion:[NSString stringWithFormat:@"%.1f", versionValue.floatValue]];
            }
            /** 设置assignRandomName */
            NSNumber * assignRandomNameValue = [rowInfo objectForKey:@"assign_random_name"];
            if (assignRandomNameValue) {
                [cacheFile setAssignRandomName:[assignRandomNameValue boolValue]];
            } else {
                [cacheFile setAssignRandomName:NO];
            }
            
            [cacheFile setUrl:[self getURLForManagedFile:cacheFile]];
        } else {
            cacheFile = nil;
        }
    }
    return cacheFile;
}

- (NSDictionary *)getRowInfoFromSqliteStatement:(sqlite3_stmt *)stmt {
    NSMutableDictionary * rowInfo = nil;
    int cols = sqlite3_column_count(stmt);
    for (int i = 0; i < cols; i++) {
        if (rowInfo == nil) {
            rowInfo = [NSMutableDictionary dictionary];
        }
        int columnType = sqlite3_column_type(stmt, i);
        NSString * columnName = [NSString stringWithFormat:@"%s", sqlite3_column_name(stmt, i)];
        id columnValue = nil;
        switch (columnType) {
            case SQLITE_INTEGER:
                columnValue = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)];
                break;
            case SQLITE_FLOAT:
                columnValue = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
                break;
#ifdef SQLITE_TEXT
            case SQLITE_TEXT:
#else
            case SQLITE3_TEXT:
#endif
                columnValue = [NSString stringWithFormat:@"%s", sqlite3_column_text(stmt, i)];
                break;
            case SQLITE_BLOB:
                columnValue = [NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)];
                break;
            case SQLITE_NULL:
                break;
            default:
                break;
        }
        if (columnValue) {
            [rowInfo setObject:columnValue forKey:columnName];
        }
    }
    return [rowInfo copy];
}

- (BOOL)writeFileToDatabase:(DXCacheFile *)file {
    BOOL writeSuccess = NO;
    sqlite3_stmt * stmt = NULL;
    
    DXCacheFile * existedFile = [self getFileFromDataBase:file];
    if (existedFile) {
        DXCFMLog(@"文件记录(file_id:%@)已经存在", existedFile.fileID);
        NSTimeInterval updatedAt = [[NSDate date] timeIntervalSince1970];
        NSString * updateSQL = [NSString stringWithFormat:
                                @"UPDATE %@ SET "
                                "name = ?1, "
                                "extension = ?2, "
                                "delete_when_app_launch = ?3, "
                                "updated_at = ?4, "
                                "relative_path = ?5, "
                                "version = ?6 "
                                "WHERE file_id = ?7;", _tableName];
        if (sqlite3_prepare_v2(_database, updateSQL.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, file.name.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt, 2, file.extension.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt, 3, file.deleteWhenAppLaunch);
            sqlite3_bind_int64(stmt, 4, updatedAt);
            sqlite3_bind_text(stmt, 5, file.relativePath.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt, 6, _tableVersion.floatValue);
            sqlite3_bind_int64(stmt, 7, existedFile.fileID.longLongValue);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                writeSuccess = YES;
                file.fileID = existedFile.fileID;
                file.updatedAt = updatedAt;
                file.version = _tableVersion;
                DXCFMLog(@"文件记录(file_id:%@)已更新", existedFile.fileID);
            } else {
                writeSuccess = NO;
                DXCFMWarn(@"文件记录(file_id:%@)更新失败: %s", existedFile.fileID, sqlite3_errmsg(_database));
            }
        } else {
            writeSuccess = NO;
            DXCFMWarn(@"文件记录更新SQL编译失败: %s", sqlite3_errmsg(_database));
        }
        sqlite3_finalize(stmt);
    } else {
        NSTimeInterval createdAt = [[NSDate date] timeIntervalSince1970];
        NSString * insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (file_type,name,extension,full_name,assign_random_name,delete_when_app_launch,created_at,version,relative_path) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9);", _tableName];
        if (sqlite3_prepare_v2(_database, insertSQL.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, file.fileType);
            sqlite3_bind_text(stmt, 2, file.name.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt, 3, file.extension.UTF8String, -1, NULL);
            sqlite3_bind_text(stmt, 4, file.fullName.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt, 5, file.assignRandomName);
            sqlite3_bind_int(stmt, 6, file.deleteWhenAppLaunch);
            sqlite3_bind_int64(stmt, 7, createdAt);
            sqlite3_bind_int(stmt, 8, _tableVersion.floatValue);
            sqlite3_bind_text(stmt, 9, file.relativePath.UTF8String, -1, NULL);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                writeSuccess = YES;
                NSString * lastID = [NSString stringWithFormat:@"%lld", sqlite3_last_insert_rowid(_database)];
                file.fileID = lastID;
                file.createdAt = createdAt;
                file.version = _tableVersion;
                DXCFMLog(@"文件记录(rowid:%lld)已写入", sqlite3_last_insert_rowid(_database));
            } else {
                writeSuccess = NO;
                DXCFMWarn(@"文件记录写入失败: %s", sqlite3_errmsg(_database));
            }
        } else {
            writeSuccess = NO;
            DXCFMWarn(@"文件记录写入SQL编译失败: %s", sqlite3_errmsg(_database));
        }
        sqlite3_finalize(stmt);
    }

    return writeSuccess;
}

- (void)removeFileFromDatabase:(DXCacheFile *)file {
    DXCacheFile * existedFile = [self getFileFromDataBase:file];
    if (existedFile) {
        NSString * deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE file_id = %@;", _tableName, existedFile.fileID];
        char * errmsg = NULL;
        if (sqlite3_exec(_database, deleteSQL.UTF8String, NULL, NULL, &errmsg) == SQLITE_OK) {
            DXCFMLog(@"文件记录(file_id:%@)删除成功", existedFile.fileID);
        } else {
            DXCFMWarn(@"文件记录(file_id:%@)删除失败: %s", existedFile.fileID, errmsg);
            sqlite3_free(errmsg);
        }
    } else {
        DXCFMWarn(@"待删除的文件记录不存在, %@", file);
    }
}

#pragma mark 文件操作

- (void)copyFileInfoFrom:(DXCacheFile *)sourceFile toFile:(DXCacheFile *)targetFile {
    targetFile.fileID               = sourceFile.fileID;
    targetFile.fileType             = sourceFile.fileType;
    targetFile.name                 = sourceFile.name;
    targetFile.extension            = sourceFile.extension;
    targetFile.relativePath         = sourceFile.relativePath;
    targetFile.url                  = sourceFile.url;
    targetFile.deleteWhenAppLaunch  = sourceFile.deleteWhenAppLaunch;
    targetFile.assignRandomName     = sourceFile.assignRandomName;
    targetFile.createdAt            = sourceFile.createdAt;
    targetFile.updatedAt            = sourceFile.updatedAt;
    targetFile.version              = sourceFile.version;
}

- (NSURL *)getURLForManagedFile:(DXCacheFile *)managedFile {
    if (managedFile == nil) {
        return nil;
    }
    
    NSString * subdirectory = [[[self class] subdirectoryConfig] objectForKey:@(managedFile.fileType)];
    subdirectory = [subdirectory stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    subdirectory = [NSString stringWithFormat:@"%@/%@", _baseDirectory, subdirectory];
    
    NSURL * rootDirectory = nil;
    if (managedFile.deleteWhenAppLaunch) {
        rootDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    } else {
        rootDirectory = [[_systemFileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    }
    
    NSURL * directory = [rootDirectory URLByAppendingPathComponent:subdirectory isDirectory:YES];
    NSString * relativeFilePath = [[self getRelativeURLForManagedFile:managedFile].path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSURL * fileUrl = [directory URLByAppendingPathComponent:relativeFilePath];
    return fileUrl;
}

- (NSURL *)getRelativeURLForManagedFile:(DXCacheFile *)managedFile {
    NSURL * relativeURL = nil;
    if (managedFile.relativePath == nil) {
        relativeURL = [NSURL fileURLWithPath:managedFile.name];
    } else {
        relativeURL = [[NSURL fileURLWithPath:managedFile.relativePath isDirectory:YES] URLByAppendingPathComponent:managedFile.name];
    }
    
    if (managedFile.extension) {
        relativeURL = [relativeURL URLByAppendingPathExtension:managedFile.extension];
    }
    return relativeURL;
}

- (NSString *)getRandomFileName {
    return [[NSUUID UUID] UUIDString];
}

- (BOOL)prepareDirectoryForFileAtURL:(NSURL *)fileURL error:(NSError *__autoreleasing *)error {
    NSURL * fileDirectoryURL = [fileURL URLByDeletingLastPathComponent];
    if (![_systemFileManager fileExistsAtPath:fileDirectoryURL.path]) {
        return [_systemFileManager createDirectoryAtURL:fileDirectoryURL withIntermediateDirectories:YES attributes:nil error:error];
    } else {
        return YES;
    }
}

- (BOOL)saveData:(NSData *)data toAbsoluteURL:(NSURL *)fileURL error:(NSError *__autoreleasing *)error {
    NSAssert(fileURL != nil, @"fileURL不能为nil");
    NSAssert(data != nil, @"data不能为nil，如果想保存空文件，可以考虑使用[NSData data]");
    
    if ([self prepareDirectoryForFileAtURL:fileURL error:error]) {
        BOOL success = [data writeToURL:fileURL options:NSDataWritingAtomic error:error];
        if (success) {
            DXCFMLog(@"文件（%.2fM）已存储在路径%@", [data length]/1048576.0, fileURL);
        }
        return success;
    } else {
        return NO;
    }
}

- (BOOL)deleteFileAtURL:(NSURL *)fileURL error:(NSError *__autoreleasing *)error {
    NSAssert(fileURL != nil, @"fileURL不可为nil");
    
    if ([_systemFileManager fileExistsAtPath:fileURL.path]) {
        NSError * localError = nil;
        BOOL success = [_systemFileManager removeItemAtURL:fileURL error:&localError];
        if (success) {
            DXCFMLog(@"已成功删除文件%@", fileURL);
        } else {
            if (error) {
                *error = localError;
            }
            DXCFMWarn(@"文件删除失败:%@", localError.localizedDescription);
        }
        return success;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:DXCacheFileManagerErrorDomain code:DXCacheFileManagerErrorCodeFileNotExist userInfo:@{NSLocalizedDescriptionKey: @"指定文件不存在"}];
        }
        return NO;
    }
}


@end
