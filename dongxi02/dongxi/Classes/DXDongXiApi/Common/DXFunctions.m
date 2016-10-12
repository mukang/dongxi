//
//  DXFunctions.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFunctions.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>

#ifndef dongxi_DXFunctions_m
#define dongxi_DXFunctions_m

#pragma mark - NSString 操作

NSString * DXReverseNSString(NSString * origin) {
    CFStringRef str = (__bridge CFStringRef)origin;
    CFIndex strLen = CFStringGetLength(str);
    CFMutableStringRef reversedCFString = CFStringCreateMutable(kCFAllocatorDefault, strLen);
    for (CFIndex i = strLen - 1; i >= 0; i--) {
        UniChar thisChar = CFStringGetCharacterAtIndex(str, i);
        CFStringAppendCharacters(reversedCFString, &thisChar, 1);
    }
    NSString * reversedString = (__bridge NSString *)reversedCFString;
    CFRelease(reversedCFString);
    return reversedString;
}

NSString * DXDigestMD5(NSString * text) {
    const char * textCPtr = [text UTF8String];
    if (textCPtr == NULL) {
        textCPtr = "";
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(textCPtr, (CC_LONG)strlen(textCPtr), digest);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
}


#pragma mark - 设备操作

NSString * DXGetDeviceModel() {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

NSString * DXGetDeviceUUID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSString * DXGetDeviceOSVersion() {
    return [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
}

NSString * DXGetAppIdentifier() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
}

NSString * DXGetAppVersion() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

NSString * DXGetAppBuildVersion() {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}

NSString * DXGetAppFullVersion() {
    return [NSString stringWithFormat:@"%@ (Build %@)", DXGetAppVersion(), DXGetAppBuildVersion()];
}

#endif
