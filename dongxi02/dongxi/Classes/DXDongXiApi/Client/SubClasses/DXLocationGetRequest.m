//
//  DXLocationGetRequest.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLocationGetRequest.h"

@implementation DXLocationGetRequest

- (void)setLat:(NSString *)lat {
    _lat = lat;
    
    [self setValue:lat forParam:@"lat"];
}

- (void)setLng:(NSString *)lng {
    _lng = lng;
    
    [self setValue:lng forParam:@"lng"];
}

@end
