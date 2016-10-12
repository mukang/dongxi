//
//  DXRoute.h
//  dongxi
//
//  Created by 穆康 on 16/7/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXRoute : NSObject

@property (nonatomic, strong) NSDictionary *map;
@property (nonatomic, copy) NSString *routeID;

/**
 *  解析URL
 *
 *  @param params 通过URL解析出来的参数
 *  @param URL    URL
 *
 *  @return 解析出来的控制器名称
 */
- (NSString *)controllerNameAndParams:(NSDictionary **)params withParseURL:(NSURL *)URL;

@end
