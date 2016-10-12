//
//  DXNoticeCommentWrapper.h
//  dongxi
//
//  Created by 穆康 on 15/11/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DXNoticeComment;

@interface DXNoticeCommentWrapper : NSObject

/** 用于排序的ID */
@property (nonatomic, copy) NSString *ID;
/** 评论详情 */
@property (nonatomic, strong) DXNoticeComment *comment;
/** 1我发的feed 2别人发的feed */
@property (nonatomic, assign) NSInteger type;
/** 评论的FeedID */
@property (nonatomic, copy) NSString *fid;
/** feed文字 */
@property (nonatomic, copy) NSString *feed_txt;
/** feed一张缩略图 */
@property (nonatomic, copy) NSString *photo;

@end
