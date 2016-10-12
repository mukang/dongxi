//
//  DXUserValidateRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

typedef enum : NSUInteger {
    DXUserValidateTypeUserName,
    DXUserValidateTypeMobile,
    DXUserValidateTypeEmail,
} DXUserValidateType;

@interface DXUserValidateRequest : DXClientRequest

- (void)validate:(DXUserValidateType)type value:(NSString *)value;

@end
