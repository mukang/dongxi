//
//  DXWxauthorizerLoginResponse.h
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXWxauthorizerLoginResponse : DXClientResponse

@property (nonatomic, assign) DXWechatLoginStatus status;

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) NSTimeInterval validtime;
@property (nonatomic, assign) DXUserVerifiedType verified;

@end