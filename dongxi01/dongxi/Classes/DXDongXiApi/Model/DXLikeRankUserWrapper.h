//
//  DXLikeRankUserWrapper.h
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DXLikeRankInfo;

@interface DXLikeRankUserWrapper : NSObject

@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) DXLikeRankInfo *info;

@end


@interface DXLikeRankInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;

@end
