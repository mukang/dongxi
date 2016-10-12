//
//  NSUserDefaults+DXUnRegisterDefaults.h
//  dongxi
//
//  Created by Xu Shiwen on 16/3/17.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DXUnRegisterDefaults)

- (void)unregisterDefaultForKey:(NSString *)defaultName;

@end
