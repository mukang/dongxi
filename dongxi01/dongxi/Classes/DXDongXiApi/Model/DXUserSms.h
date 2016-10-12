//
//  DXUserSms.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXUserSms : NSObject

@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, readonly) NSString *key;

+ (instancetype)newUserSmsWithMobile:(NSString *)mobile;

@end
