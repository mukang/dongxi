//
//  DXCollapseTextView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/21.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXCollapseTextViewDelegate;


@interface DXCollapseTextView : UIView

@property (nonatomic) UIButton * moreButton;
@property (nonatomic) UIButton * hideButton;

@property (nonatomic) NSString * text;
@property (nonatomic, weak) id<DXCollapseTextViewDelegate> delegate;
@property (nonatomic) BOOL showFull;

@end



@protocol DXCollapseTextViewDelegate <NSObject>

- (void)collapseTextView:(DXCollapseTextView *)collapseTextView willChangeState:(BOOL)collapse;

@end