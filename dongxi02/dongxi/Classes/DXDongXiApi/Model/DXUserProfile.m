//
//  DXUserProfile.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserProfile.h"

@implementation DXUserProfile

+ (NSDictionary *)objectClassInArray{
    return @{@"tag" : [DXUserProfileTag class]};
}

- (NSString *)genderDescription {
    
    switch (self.gender) {
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

@implementation DXUserProfileTag

@end