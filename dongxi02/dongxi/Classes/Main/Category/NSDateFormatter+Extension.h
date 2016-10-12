//
//  NSDateFormatter+Extension.h
//  dongxi
//
//  Created by 穆康 on 15/9/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Extension)

+ (id)dateFormatter;
+ (id)dateFormatterWithFormat:(NSString *)dateFormat;

+ (id)defaultDateFormatter;/*yyyy-MM-dd HH:mm:ss*/

@end
