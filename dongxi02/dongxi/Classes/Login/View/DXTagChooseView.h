//
//  DXTagChooseView.h
//  dongxi
//
//  Created by 穆康 on 16/3/10.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DXTagChooseViewDelegate;



@interface DXTagChooseView : UIView

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, weak) id<DXTagChooseViewDelegate> delegate;

- (void)setTags:(NSArray *)tags withRect:(CGRect)rect;

@end



@protocol DXTagChooseViewDelegate <NSObject>

@optional
- (void)tagChooseView:(DXTagChooseView *)view didShowTagsWithRange:(NSRange)range;
- (void)tagChooseView:(DXTagChooseView *)view didTapTagWitNormalTag:(DXTag *)normalTag;

@end
