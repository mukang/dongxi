//
//  DXCommentCreateRequest.h
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientRequest.h"

@interface DXCommentCreateRequest : DXClientRequest

@property (nonatomic, strong) NSDictionary *commentPost;

@end
