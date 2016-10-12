//
//  DXContentPiece.h
//  dongxi
//
//  Created by 穆康 on 16/5/4.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DXContentPieceType) {
    DXContentPieceTypeNormal = 0,
    DXContentPieceTypeRefer
};

typedef NS_ENUM(NSInteger, DXReferType) {
    DXReferTypeUser = 0,
    DXReferTypeTopic
};

@interface DXContentPiece : NSObject

@property (nonatomic, assign) DXContentPieceType type;
@property (nonatomic, assign) DXReferType refer_type;
@property (nonatomic, copy) NSString *refer_id;
@property (nonatomic, copy) NSString *content;

@end
