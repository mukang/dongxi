//
//  DXCommentPost.h
//  dongxi
//
//  Created by 穆康 on 16/5/11.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXCommentPost : NSObject

@property (nonatomic, copy) NSString *fid;
@property (nonatomic, copy) NSString *txt;
@property (nonatomic, copy) NSString *at_uid;
@property (nonatomic, copy) NSString *at_id;
@property (nonatomic, strong) NSArray *content_pieces;

@end
