//
//  DXWechatRegisterInfo.h
//  dongxi
//
//  Created by 穆康 on 16/6/17.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXWechatRegisterInfo : NSObject

@property (nonatomic, copy) NSString *open_id;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, assign) int expires_in;
@property (nonatomic, copy) NSString *refresh_token;
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *push_id;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, assign) int gender;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *privilege;
@property (nonatomic, copy) NSString *unionid;

@end
