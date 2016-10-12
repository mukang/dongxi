//
//  DXMessageReadManager.h
//  dongxi
//
//  Created by 穆康 on 15/9/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXSingleton.h"

@interface DXMessageReadManager : NSObject
DXSingletonInterface(MessageReadManager)

@property (nonatomic, strong) DXChatMessage *audioMessage;
/**
 *  准备播放语音文件
 *
 *  @param audioMessage     要播放的语音文件
 *  @param updateCompletion 需要更新的回调
 *
 *  @return 若返回NO，则不需要调用播放方法
 *
 */
- (BOOL)prepareAudioMessage:(DXChatMessage *)audioMessage updateViewCompletion:(void (^)(DXChatMessage *prevAudioMessage, DXChatMessage *currentAudioMessage))updateCompletion;

- (DXChatMessage *)stopAudioMessage;

@end
