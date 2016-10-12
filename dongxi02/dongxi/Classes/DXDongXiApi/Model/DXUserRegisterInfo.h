//
//  DXUserRegisterInfo.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUserEnum.h"

@interface DXUserRegisterInfo : NSObject

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * mobile;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * location;
@property (nonatomic, assign) DXUserGenderType gender;
/** 远程推送ID */
@property (nonatomic, copy) NSString * push_id;

@property (nonatomic, readonly, strong) NSString * device;
@property (nonatomic, readonly, strong) NSString * uuid;

@end
