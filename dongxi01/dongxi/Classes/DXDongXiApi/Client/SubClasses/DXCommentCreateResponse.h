//
//  DXCommentCreateResponse.h
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXCommentCreateResponse : DXClientResponse

@property (nonatomic, assign) BOOL status;
@property (nonatomic, strong) NSDictionary * comment;

@end
