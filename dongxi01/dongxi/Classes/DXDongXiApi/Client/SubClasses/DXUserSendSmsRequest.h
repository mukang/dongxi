//
//  DXUserSendSmsRequest.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@class DXUserSms;

@interface DXUserSendSmsRequest : DXClientRequest

@property (nonatomic, strong) DXUserSms * sms;

@end
