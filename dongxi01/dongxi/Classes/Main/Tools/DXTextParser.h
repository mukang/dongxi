//
//  DXTextParser.h
//  dongxi
//
//  Created by 穆康 on 16/5/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText/YYText.h>

@interface DXTextParser : NSObject <YYTextParser>

@property (nonatomic, strong) NSArray *contentPieces;

@end
