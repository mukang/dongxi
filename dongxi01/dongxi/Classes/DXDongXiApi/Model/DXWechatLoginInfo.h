//
//  DXWechatLoginInfo.h
//  dongxi
//
//  Created by 穆康 on 16/6/16.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXWechatLoginInfo : NSObject

@property (nonatomic, copy) NSString *open_id;
@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, copy) NSString *refresh_token;
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *union_id;
@property (nonatomic, copy) NSString *push_id;
@property (nonatomic, assign) int expires_in;

@end
