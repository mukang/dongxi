//
//  DXFeedToolView.h
//  dongxi
//
//  Created by 穆康 on 15/10/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//  工具栏中评论和点赞控件

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXFeedToolViewType) {
    DXFeedToolViewTypeBrowseComment,
    DXFeedToolViewTypeOther
};

@interface DXFeedToolView : UIView

/** 控件标题 */
@property (nonatomic, copy) NSString *titleName;
/** 控件图片名字 */
@property (nonatomic, copy) NSString *imageName;
/** 评论人数（只有在toolViewType类型为DXFeedToolViewTypeComment时才会赋值） */
@property (nonatomic, assign) NSUInteger commentCount;


@property (nonatomic, assign, readonly) DXFeedToolViewType toolViewType;
/** 唯一初始化方法 */
- (instancetype)initWithToolViewType:(DXFeedToolViewType)toolViewType;

@end
