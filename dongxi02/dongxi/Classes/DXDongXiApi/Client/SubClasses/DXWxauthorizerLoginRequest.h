//
//  DXWxauthorizerLoginRequest.h
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXWxauthorizerLoginRequest : DXClientRequest

@property (nonatomic, strong) DXWechatLoginInfo *loginInfo;

@end