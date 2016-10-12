//
//  UIResponder+Router.h
//  dongxi
//
//  Created by 穆康 on 15/9/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)

/**
 *  发送一个路由器消息, 对eventName感兴趣的 UIResponsder 可以对消息进行处理
 *
 *  @param eventName 发生的事件名称
 *  @param userInfo  传递消息时, 携带的数据, 数据传递过程中, 会有新的数据添加
 *
 */
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

/**
 *  发送一个路由器消息, 对eventName感兴趣的 UIResponsder 可以对消息进行处理
 *
 *  @param eventName   发生的事件名称
 *  @param userInfo    传递消息时, 携带的数据, 数据传递过程中, 会有新的数据添加
 *  @param resultBlock 结果回调
 */
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo result:(void(^)(BOOL success))resultBlock;

@end
