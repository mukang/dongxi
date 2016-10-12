//
//  DXComposeViewController.h
//  dongxi
//
//  Created by 穆康 on 15/11/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  撰写

#import <UIKit/UIKit.h>
#import "DXCommentTemp.h"

typedef NS_ENUM(NSInteger, DXComposeType) {
    DXComposeTypeComment,                   // 评论
    DXComposeTypeReply                      // 回复
};

typedef void(^DXCommentBlock)(DXComment *comment);

@interface DXComposeViewController : UIViewController

@property (nonatomic, assign) DXComposeType composeType;
/** 临时的评论模型 */
@property (nonatomic, strong) DXCommentTemp *temp;
/** 评论回调 */
@property (nonatomic, copy) DXCommentBlock commentBlock;

@end
