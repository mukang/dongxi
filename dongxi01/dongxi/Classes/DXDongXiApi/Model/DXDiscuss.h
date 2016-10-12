//
//  DXDiscuss.h
//  dongxi
//
//  Created by 穆康 on 15/9/16.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  聊天记录
 */
@interface DXDiscuss : NSObject

/** 排序ID */
@property (nonatomic, copy) NSString *ID;

/** FeedID */
@property (nonatomic, copy) NSString *fid;

/** Feed缩略图(暂时没用) */
@property (nonatomic, copy) NSString *preview;

/** 聊天对象的ID */
@property (nonatomic, copy) NSString *uid;

/** 头像地址 */
@property (nonatomic, copy) NSString *avatar;

/** 聊天对象昵称 */
@property (nonatomic, copy) NSString *nick;

/** 聊天文本内容 */
@property (nonatomic, copy) NSString *txt;

/** 1文字 2语音 */
@property (nonatomic, assign) NSInteger type;

/** 语音文件id(对应环信中会话ID) */
@property (nonatomic, copy) NSString *sound_id;

/** 发送时间 */
@property (nonatomic, assign) NSInteger time;

@end
