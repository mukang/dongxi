//
//  DXTextView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/2.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXTextView : UITextView

@property (nonatomic, copy) NSString * placeHolder;
@property (nonatomic, strong) UIFont * placeHolderFont;
@property (nonatomic, strong) UIColor * placeHolderColor;
@property (nonatomic, strong) UIColor * viewStateTextColor;
@property (nonatomic, strong) UIColor * editStateTextColor;

@end
