//
//  DXUserProfileChange.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserProfileChange.h"
#import "DXUserEnum.h"

@implementation DXUserProfileChange

- (NSString *)genderDescription {
    
    switch (self.gender.integerValue) {
        case DXUserGenderTypeMale:
            return @"男";
            break;
        case DXUserGenderTypeFemale:
            return @"女";
            break;
            
        default:
            return @"其他";
            break;
    }
}

@end
