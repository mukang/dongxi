//
//  DXClientPostForm.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientPostForm.h"
#import "DXClientPostFormFile.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation DXClientPostForm {
    NSMutableDictionary * _paramTable;
    NSMutableArray * _files;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _paramTable = [NSMutableDictionary dictionary];
        _files = [NSMutableArray array];
        _boundaryIdentifier = @"Kepler452b";
    }
    return self;
}

- (void)addParams:(NSData *)paramsData name:(NSString *)paramName {
    [_paramTable setObject:paramsData forKey:paramName];
}

- (void)addFileData:(NSData *)fileData fileName:(NSString *)fileName {
    DXClientPostFormFile * file = [[DXClientPostFormFile alloc] init];
    file.fileData = fileData;
    file.fileName = fileName;
    [_files addObject:file];    
}

- (NSData *)getFormData {
    NSData * boundaryData = [[NSString stringWithFormat:@"--%@\r\n", self.boundaryIdentifier] dataUsingEncoding:NSUTF8StringEncoding];
    NSData * changeLineData = [[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData * formData = [NSMutableData data];
    for (NSString * paramName in _paramTable) {
        NSData * paramNameData = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", paramName] dataUsingEncoding:NSUTF8StringEncoding];
        NSData * paramData = [_paramTable objectForKey:paramName];
        [formData appendData:boundaryData];
        [formData appendData:paramNameData];
        [formData appendData:paramData];
        [formData appendData:changeLineData];
    }
    
    for (int i = 0; i < _files.count; i++) {
        NSString * fileFieldName = nil;
        if (_files.count > 1) {
            fileFieldName = [NSString stringWithFormat:@"file%d", i];
        } else {
            fileFieldName = @"file";
        }
        DXClientPostFormFile * currentFile = _files[i];
        NSString * fileName = currentFile.fileName;
        NSData * fileNameData = [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileFieldName, fileName] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString * fileExtension = [fileName pathExtension];
        NSString * mimeType = [self mimeTypeForExtension:fileExtension];
        NSData * mimeTypeData = [[NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding];
        NSData * transferEncodingData = [[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
        NSData * fileData = currentFile.fileData;
        
        [formData appendData:boundaryData];
        [formData appendData:fileNameData];
        [formData appendData:mimeTypeData];
        [formData appendData:transferEncodingData];
        [formData appendData:fileData];
        [formData appendData:changeLineData];
    }
    
    [formData appendData:boundaryData];
    return [formData copy];
}

- (NSString *)mimeTypeForExtension:(NSString *)extension {
    NSString * mimeTypeUniversal = @"application/octet-stream";
    if (extension) {
        CFStringRef ext = (__bridge CFStringRef)extension;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, NULL);
        if (UTI == NULL) {
            return mimeTypeUniversal;
        } else {
            NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
            CFRelease(UTI);
            if (mimetype == NULL) {
                return mimeTypeUniversal;
            } else {
                return mimetype;
            }
        }
    } else {
        return mimeTypeUniversal;
    }
}


@end
