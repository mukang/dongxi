//
//  DXPictureShow.h
//  dongxi
//
//  Created by 穆康 on 15/10/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXPictureShow : NSObject

/** 序号 */
@property (nonatomic, copy) NSString *ID;
/** 图片地址 */
@property (nonatomic, copy) NSString *cover;
/** 1某某话题的参加页 2微信中推送的文章 */
@property (nonatomic, assign) NSInteger type;
/** type为1时为话题的topic_id type为2时为跳转H5页面的url */
@property (nonatomic, copy) NSString *url;

@end
