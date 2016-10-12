//
//  DXLocationGetResponse.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXLocationGetResponse : DXClientResponse

@property (nonatomic, assign) BOOL status;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSArray * pois;

@end
