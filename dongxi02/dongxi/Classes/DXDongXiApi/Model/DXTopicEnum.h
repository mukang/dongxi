//
//  DXTopicEnum.h
//  dongxi
//
//  Created by 穆康 on 16/2/17.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#ifndef DXTopicEnum_h
#define DXTopicEnum_h

/**
 *  话题类型
 */
typedef NS_ENUM(NSInteger, DXTopicType) {
    /** 推荐话题 */
    DXTopicTypeTop = 1,
    /** 热门话题 */
    DXTopicTypeHot,
    /** 有奖话题 */
    DXTopicTypePrize
};

#endif /* DXTopicEnum_h */
