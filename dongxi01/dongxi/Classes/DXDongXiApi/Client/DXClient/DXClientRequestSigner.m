//
//  DXClientRequestSigner.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequestSigner.h"
#import "DXClientRequest.h"
#import "DXClientConfig.h"
#import "DXFunctions.h"


@implementation DXClientRequestDefaultSigner

- (NSArray *)sessionFields {
    return @[@"uid", @"sid"];
}

- (NSDictionary *)signParamsFromRequest:(DXClientRequest *)request {
    NSDictionary * userInfo = [request userInfo];
    return [self signParamsFromRequest:request withSessionInfo:userInfo];
}

- (NSDictionary *)signParamsFromRequest:(DXClientRequest *)request withSessionInfo:(NSDictionary *)sessionInfo {
    NSMutableDictionary * signedParams = [NSMutableDictionary dictionary];
    for (NSString * field in [self sessionFields]) {
        if ([sessionInfo objectForKey:field]) {
            [signedParams setObject:[sessionInfo objectForKey:field] forKey:field];
        }
    }
    [signedParams setObject:DXGetAppVersion() forKey:@"ver"];
    [signedParams setObject:DXCLIENT_API_DEVICE forKey:@"device"];
    [signedParams setObject:DXGetDeviceUUID() forKey:@"udid"];
    [signedParams setObject:DXGetDeviceOSVersion() forKey:@"device_os"];
    [signedParams setObject:DXGetDeviceModel() forKey:@"device_model"];
    NSDate * now = [NSDate date];
    NSString * timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[now timeIntervalSince1970]];
    NSString * sign = [self getSign:timestamp];
    [signedParams setObject:timestamp forKey:@"time"];
    [signedParams setObject:sign forKey:@"sign"];
#if DEBUG
    [signedParams setObject:@(YES) forKey:@"develop"];
#endif
    [signedParams setObject:[request params] forKey:@"request"];
    return [signedParams copy];
}

- (NSString *)getSign:(NSString *)ts {
    NSString * reversedTs = DXReverseNSString(ts);
    NSString * reversedTsStrMD5 = DXDigestMD5(reversedTs);
    return DXReverseNSString(reversedTsStrMD5);
}


@end
