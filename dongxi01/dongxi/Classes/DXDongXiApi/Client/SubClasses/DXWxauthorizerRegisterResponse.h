//
//  DXWxauthorizerRegisterResponse.h
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXWxauthorizerRegisterResponse : DXClientResponse

@property (nonatomic, assign) DXWechatRegisterStatus status;

@end