//
//  DXClientPostForm.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/13.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXClientPostForm : NSObject

@property (nonatomic, strong, readonly) NSString * boundaryIdentifier;

- (void)addParams:(NSData *)paramsData name:(NSString *)paramName;
- (void)addFileData:(NSData *)fileData fileName:(NSString *)fileName;
- (NSData *)getFormData;

@end
