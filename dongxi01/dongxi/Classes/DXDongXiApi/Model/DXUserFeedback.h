//
//  DXUserFeedback.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 用户意见反馈信息 */
@interface DXUserFeedback : NSObject

/** 用户联系方式（电邮、微信、QQ等） */
@property (nonatomic, copy) NSString * contact;
/** 用户反馈内容 */
@property (nonatomic, copy) NSString * txt;

@end
