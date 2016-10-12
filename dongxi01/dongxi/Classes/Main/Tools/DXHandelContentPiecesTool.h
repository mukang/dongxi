//
//  DXHandelContentPiecesTool.h
//  dongxi
//
//  Created by 穆康 on 16/5/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DXHandelContentPiecesToolDelegate;
@interface DXHandelContentPiecesTool : NSObject

@property (nonatomic, weak) id<DXHandelContentPiecesToolDelegate> delegate;

- (NSAttributedString *)createAttributedStringWithContentPieces:(NSArray *)contentPieces;

@end

@protocol DXHandelContentPiecesToolDelegate <NSObject>

@optional
- (void)contentPiecesTool:(DXHandelContentPiecesTool *)tool didSelectHighlightWithUserID:(NSString *)userID;
- (void)contentPiecesTool:(DXHandelContentPiecesTool *)tool didSelectHighlightWithTopicID:(NSString *)topicID;

@end
