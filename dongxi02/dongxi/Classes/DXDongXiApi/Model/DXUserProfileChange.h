//
//  DXUserProfileChange.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  用户资料修改信息
 */
@interface DXUserProfileChange : NSObject

@property (nonatomic, strong) NSString * username;

@property (nonatomic, strong) NSString * location;

@property (nonatomic, strong) NSNumber * gender;

@property (nonatomic, strong) NSString * bio;


- (NSString *)genderDescription;

@end
