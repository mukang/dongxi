//
//  DXChatUploadChatFileRequest.m
//  dongxi
//
//  Created by 穆康 on 16/4/12.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatUploadChatFileRequest.h"

@implementation DXChatUploadChatFileRequest

- (void)setFile_type:(NSInteger)file_type {
    _file_type = file_type;
    [self setValue:@(file_type) forParam:@"file_type"];
}

- (void)setFileURL:(NSURL *)fileURL {
    _fileURL = fileURL;
    [self addFile:fileURL];
}

@end
