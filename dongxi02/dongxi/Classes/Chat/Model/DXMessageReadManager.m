//
//  DXMessageReadManager.m
//  dongxi
//
//  Created by 穆康 on 15/9/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageReadManager.h"
#import "EMCDDeviceManager.h"
#import "DXChatHelper.h"

@implementation DXMessageReadManager
DXSingletonImplementation(MessageReadManager)

- (BOOL)prepareAudioMessage:(DXChatMessage *)audioMessage updateViewCompletion:(void (^)(DXChatMessage *, DXChatMessage *))updateCompletion {
    BOOL isPrepare = NO;
    if (audioMessage.type == eMessageBodyType_Voice) {
        DXChatMessage *prevAudioMessage = self.audioMessage;
        DXChatMessage *currentAudioMessage = audioMessage;
        self.audioMessage = audioMessage;
        
        BOOL isPlaying = audioMessage.isPlaying;
        if (isPlaying) {
            audioMessage.isPlaying = NO;
            self.audioMessage = nil;
            currentAudioMessage = nil;
            [[EMCDDeviceManager sharedInstance] stopPlaying];
        } else {
            audioMessage.isPlaying = YES;
            prevAudioMessage.isPlaying = NO;
            isPrepare = YES;
            
            if (!audioMessage.isPlayed && !audioMessage.is_sender) {
                audioMessage.isPlayed = YES;
                // 更新数据库中的状态
                [[DXChatHelper sharedHelper] markChatMessageAudioIsPlayedWithOtherUid:audioMessage.other_uid messageID:audioMessage.msg_id];
            }
            
        }
        if (updateCompletion) {
            updateCompletion(prevAudioMessage, currentAudioMessage);
        }
    }
    return isPrepare;
}

- (DXChatMessage *)stopAudioMessage {
    DXChatMessage *tempMessage = nil;
    if (self.audioMessage.type == eMessageBodyType_Voice) {
        if (self.audioMessage.isPlaying) {
            tempMessage = self.audioMessage;
        }
        self.audioMessage.isPlaying = NO;
        self.audioMessage = nil;
    }
    
    return tempMessage;
}

@end
