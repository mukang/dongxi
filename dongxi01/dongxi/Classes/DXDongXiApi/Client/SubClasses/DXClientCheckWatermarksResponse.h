//
//  DXClientCheckWatermarksResponse.h
//  dongxi
//
//  Created by Xu Shiwen on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXClientResponse.h"

@interface DXClientCheckWatermarksResponse : DXClientResponse

@property (nonatomic, strong) NSArray * list;
@property (nonatomic, assign) NSInteger timestamp;

@end
