//
//  DXCommentHeaderView.m
//  dongxi
//
//  Created by 穆康 on 15/11/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCommentHeaderView.h"

#define TopMargin  DXRealValue(7.0f)   // 顶部间距

@interface DXCommentHeaderView ()

/** 评论数 */
@property (nonatomic, weak) UILabel *numL;
/** 分割线 */
@property (nonatomic, weak) UIView *dividerV;

@end

@implementation DXCommentHeaderView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = DXRGBColor(222, 222, 222);
    
    UILabel *numL = [[UILabel alloc] init];
    numL.backgroundColor = [UIColor whiteColor];
    numL.textAlignment = NSTextAlignmentCenter;
    numL.textColor = DXRGBColor(143, 143, 143);
    numL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(14)];
    [self addSubview:numL];
    self.numL = numL;
    
    // 分割线
    UIView *dividerV = [[UIView alloc] init];
    dividerV.backgroundColor = DXRGBColor(208, 208, 208);
    [self addSubview:dividerV];
    self.dividerV = dividerV;
}

- (void)setNum:(NSInteger)num {
    
    _num = num;
    
    self.numL.text = [NSString stringWithFormat:@"%zd条评论", num];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat numLX = 0.0f;
    CGFloat numLY = TopMargin;
    CGFloat numLW = self.width;
    CGFloat numLH = self.height - TopMargin;
    self.numL.frame = CGRectMake(numLX, numLY, numLW, numLH);
    
    CGFloat dividerVW = self.width;
    CGFloat dividerVH = 0.5f;
    CGFloat dividerVX = 0.0f;
    CGFloat dividerVY = self.height - dividerVH;
    self.dividerV.frame = CGRectMake(dividerVX, dividerVY, dividerVW, dividerVH);
}

@end
