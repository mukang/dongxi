//
//  DXWxauthorizerCaptchaRequest.h
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"
@class DXUserSms;

@interface DXWxauthorizerCaptchaRequest : DXClientRequest

@property (nonatomic, strong) DXUserSms *sms;

@end
