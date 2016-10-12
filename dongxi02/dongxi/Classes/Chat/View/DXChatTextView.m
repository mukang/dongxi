//
//  DXChatTextView.m
//  dongxi
//
//  Created by 穆康 on 15/9/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatTextView.h"

@implementation DXChatTextView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = DXRGBColor(245, 245, 245);
    self.textColor = DXRGBColor(102, 102, 102);
    self.font = [UIFont fontWithName:DXCommonFontName size:17];
    self.textAlignment = NSTextAlignmentLeft;
    self.scrollEnabled = YES;
    self.returnKeyType = UIReturnKeySend;
    self.enablesReturnKeyAutomatically = YES;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 8, 0);
    self.textContainerInset = UIEdgeInsetsMake(8, 4, 8, 4);
}


@end
