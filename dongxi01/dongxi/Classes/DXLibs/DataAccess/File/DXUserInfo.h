//
//  DXUserInfo.h
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXUserInfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * avatar;

@property (nonatomic, assign) NSTimeInterval updateTime;

- (BOOL)isEqualToUserInfo:(DXUserInfo *)userInfo;

@end
