//
//  DXUserLoginResponse.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXUserLoginResponse : DXClientResponse

@property (nonatomic, strong) NSString * uid;
@property (nonatomic, strong) NSString * sid;
@property (nonatomic, assign) NSTimeInterval validtime;
@property (nonatomic, strong) NSString * nick;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, assign) NSInteger verified;

@end
