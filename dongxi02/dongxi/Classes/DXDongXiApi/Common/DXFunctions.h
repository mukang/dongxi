//
//  DXFunctions.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef dongxi_DXFunctions_h
#define dongxi_DXFunctions_h

#pragma mark - NSString 操作

/**
 *  反转字符串
 *
 *  @param origin 需要反转的NSString字符串
 *
 *  @return 返回已反转的NSString字符串
 */
extern NSString * DXReverseNSString(NSString * origin);

/**
 *  计算字符串的MD5摘要
 *
 *  @param text 需要计算MD5摘要的NSString字符串
 *
 *  @return 返回已计算的MD5摘要，为32个小写字符
 */
extern NSString * DXDigestMD5(NSString * text);



#pragma mark - 线程操作

#ifndef DX_CALL_ASYNC_MQ
#define DX_CALL_ASYNC_MQ(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ ;})
#endif

#ifndef DX_CALL_ASYNC_GQ_HIGH
#define DX_CALL_ASYNC_GQ_HIGH(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ __VA_ARGS__ ;})
#endif

#ifndef DX_CALL_ASYNC_GQ_DEFAULT
#define DX_CALL_ASYNC_GQ_DEFAULT(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ ;})
#endif

#ifndef DX_CALL_ASYNC_GQ_LOW
#define DX_CALL_ASYNC_GQ_LOW(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{ __VA_ARGS__ ;})
#endif

#ifndef DX_CALL_ASYNC_GQ_BACKGROUND
#define DX_CALL_ASYNC_GQ_BACKGROUND(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ __VA_ARGS__ ;})
#endif

#ifndef DX_CALL_ASYNC_Q
#define DX_CALL_ASYNC_Q(queue, ...) dispatch_async(queue, ^{ __VA_ARGS__ ;})
#endif


#pragma mark - 设备操作

extern NSString * DXGetDeviceModel();

extern NSString * DXGetDeviceUUID();

extern NSString * DXGetDeviceOSVersion();

extern NSString * DXGetAppIdentifier();

extern NSString * DXGetAppVersion();

extern NSString * DXGetAppBuildVersion();

extern NSString * DXGetAppFullVersion();

#endif
