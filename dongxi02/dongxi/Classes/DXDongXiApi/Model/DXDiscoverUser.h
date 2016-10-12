//
//  DXDiscoverUser.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXUserEnum.h"

@interface DXDiscoverUser : NSObject

@property (nonatomic, copy) NSString * uid;
@property (nonatomic, copy) NSString * nick;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, copy) NSString * bio;
@property (nonatomic, copy) NSString * bio_pic1;
@property (nonatomic, copy) NSString * bio_pic2;
@property (nonatomic, copy) NSString * bio_pic3;
@property (nonatomic, assign) DXUserRelationType relations;

@property (nonatomic, assign) DXUserVerifiedType verified;

@property (nonatomic, copy) NSString * ID;

@end
