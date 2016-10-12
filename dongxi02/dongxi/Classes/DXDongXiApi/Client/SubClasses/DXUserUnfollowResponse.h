//
//  DXUserUnfollowResponse.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXUserUnfollowResponse : DXClientResponse

@property (nonatomic, assign) BOOL status;
@property (nonatomic, assign) NSUInteger relations;

@end
