//
//  DXEventCommentView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXTextView.h"

@interface DXEventCommentView : UIView

@property (nonatomic) UILabel * titleLabel;
@property (nonatomic) UIButton * submitButton;
@property (nonatomic) UIButton * submitAndShareButton;
@property (nonatomic) DXTextView * textView;
@property (nonatomic) NSString * placeholder;
@property (nonatomic) NSUInteger stars;

@end