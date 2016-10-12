//
//  DXWechatUserInfo.h
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXWechatUserInfo : NSObject

@property (nonatomic, copy) NSString *open_id;
@property (nonatomic, copy) NSString *nick_name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *privilege;
@property (nonatomic, copy) NSString *unionid;

@end
