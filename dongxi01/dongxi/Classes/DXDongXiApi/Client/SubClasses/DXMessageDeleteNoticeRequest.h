//
//  DXMessageDeleteNoticeRequest.h
//  dongxi
//
//  Created by 穆康 on 15/10/15.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  删除通知条目

#import "DXClientRequest.h"

@interface DXMessageDeleteNoticeRequest : DXClientRequest

@property (nonatomic, copy) NSString *ID;

@end
