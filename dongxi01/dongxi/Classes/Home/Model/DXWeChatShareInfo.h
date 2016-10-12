//
//  DXWeChatShareInfo.h
//  dongxi
//
//  Created by 穆康 on 15/11/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXWeChatShareInfo : NSObject

/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 描述 */
@property (nonatomic, copy) NSString *desc;
/** 链接地址 */
@property (nonatomic, copy) NSString *url;
/** 图片地址 */
@property (nonatomic, copy) NSString *photoUrl;
/** 图片数据 */
@property (nonatomic, strong) NSData *photoData;

@end
