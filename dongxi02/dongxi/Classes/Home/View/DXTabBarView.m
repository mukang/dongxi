//
//  DXTabBarView.m
//  dongxi
//
//  Created by 穆康 on 15/8/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTabBarView.h"
#import "DXButton.h"
#import <POP.h>

///** 小圆点之间的间距 */
//static const CGFloat dotMargin = 3.0f;
///** 小圆点宽高 */
//static const CGFloat dotWH = 4.0f;

#define dotMargin  DXRealValue(3.0f)  // 小圆点之间的间距
#define dotWH      DXRealValue(4.0f)  // 小圆点宽高

@interface DXTabBarView ()

/** 当前的按钮 */
@property (nonatomic, weak) UIButton *currentBtn;
/** 存放按钮的数组 */
@property (nonatomic, strong) NSMutableArray *tabBtns;
/** 存放小圆点的数组 */
@property (nonatomic, strong) NSMutableArray *dotViews;

@end

@implementation DXTabBarView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame tabCount:(int)count names:(NSArray *)names {
    
    if (self = [super initWithFrame:frame]) {
        
        // 创建btn
        for (int i=0; i<count; i++) {
            
            UIButton *tabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *tabName = names[i];
            [tabBtn setTitle:tabName forState:UIControlStateNormal];
            [tabBtn setTitleColor:DXRGBColor(143, 143, 143) forState:UIControlStateNormal];
            [tabBtn setTitleColor:DXRGBColor(72, 72, 72) forState:UIControlStateSelected];
            [tabBtn addTarget:self action:@selector(clickTabBtn:) forControlEvents:UIControlEventTouchDown];
            
            CGFloat btnW = self.width / count;
            CGFloat btnH = self.height;
            CGFloat btnX = btnW * i;
            tabBtn.frame = CGRectMake(btnX, 0, btnW, btnH);
            [self addSubview:tabBtn];
            
            if (i == 0) {
                tabBtn.selected = YES;
                self.currentBtn = tabBtn;
            }
            [self.tabBtns addObject:tabBtn];
            
            tabBtn.tag = i;
        }
        
        // 创建动画小圆点
        for (int i=-1; i<2; i++) {
            UIImageView *dotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_3point_blue"]];
            CGFloat bottomMargin = DXRealValue(7);
            UIButton *firstTabBtn = self.tabBtns[0];
            dotView.size = CGSizeMake(dotWH, dotWH);
            dotView.centerX = firstTabBtn.centerX + (dotMargin + dotWH) * i;
            dotView.y = self.height - bottomMargin - dotWH;
            
            [self addSubview:dotView];
            [self.dotViews addObject:dotView];
        }
    }
    return self;
}

- (void)setName:(NSString *)name atTabIndex:(NSUInteger)tabIndex {
    if (self.tabBtns.count > tabIndex) {
        UIButton * tabButton = [self.tabBtns objectAtIndex:tabIndex];
        if ([tabButton respondsToSelector:@selector(setTitle:forState:)]) {
            [tabButton setTitle:name forState:UIControlStateNormal];
//            [self setNeedsLayout];
//            [self layoutIfNeeded];
        }
    }
}

- (void)selectIndex:(NSUInteger)index {
    if (self.tabBtns.count > index) {
        UIButton * button = [self.tabBtns objectAtIndex:index];
        [self clickTabBtn:button];
    }
}


#pragma mark - 点击按钮执行的方法

- (void)clickTabBtn:(UIButton *)btn {
    
    if (self.currentBtn == btn) return;
    
    btn.selected = YES;
    self.currentBtn.selected = NO;
    
    CGFloat margin = btn.centerX - self.currentBtn.centerX;
    
    self.currentBtn = btn;
    
    if (margin > 0) {
        
        for (NSInteger i=self.dotViews.count - 1; i>=0; i--) {
            UIImageView *dotView = self.dotViews[i];
            POPBasicAnimation *anima = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
            anima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anima.duration = 0.4;
            anima.beginTime = CACurrentMediaTime() + (self.dotViews.count - 1 - i) * 0.1;
            anima.toValue = [NSValue valueWithCGPoint:CGPointMake(self.currentBtn.centerX + (dotWH + dotMargin) * (i - 1), dotView.centerY)];
            [dotView pop_addAnimation:anima forKey:[NSString stringWithFormat:@"dotView-%zd", i]];
        }
        
    } else {
        
        for (NSInteger i=0; i<self.dotViews.count; i++) {
            UIImageView *dotView = self.dotViews[i];
            POPBasicAnimation *anima = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
            anima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anima.duration = 0.4;
            anima.beginTime = CACurrentMediaTime() + i * 0.1;
            anima.toValue = [NSValue valueWithCGPoint:CGPointMake(self.currentBtn.centerX + (dotWH + dotMargin) * (i - 1), dotView.centerY)];
            [dotView pop_addAnimation:anima forKey:[NSString stringWithFormat:@"dotView-%zd", i]];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarView:didTapButtonAtIndex:)]) {
        [self.delegate tabBarView:self didTapButtonAtIndex:btn.tag];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    
    for (UIButton *btn in self.tabBtns) {
        
        if ([self.delegate respondsToSelector:@selector(titleFontInTabBarView:)]) {
            btn.titleLabel.font = [self.delegate titleFontInTabBarView:self];
        } else {
            btn.titleLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
        }
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentInsets, UIEdgeInsetsZero)) {
        CGFloat leftPadding = self.contentInsets.left;
        CGFloat rightPadding = self.contentInsets.right;
        
        CGFloat buttonWidth = (self.bounds.size.width - leftPadding - rightPadding) / self.tabBtns.count;
        CGFloat buttonHeight = self.bounds.size.height;
        
        CGRect frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
        for (int i = 0; i < self.tabBtns.count; i++) {
            UIButton * tabButton = [self.tabBtns objectAtIndex:i];
            frame.origin.x = i * buttonWidth + leftPadding;
            [tabButton setFrame:frame];
        }
        
        
        for (int i= 0 ; i < self.dotViews.count; i++) {
            UIImageView *dotView = [self.dotViews objectAtIndex:i];
            UIButton *firstTabBtn = self.tabBtns[0];
            dotView.center = CGPointMake(firstTabBtn.center.x + (dotMargin + dotWH) * (i - 1), dotView.center.y);
        }
    }
}

#pragma mark - 懒加载

- (NSMutableArray *)tabBtns {
    
    if (_tabBtns == nil) {
        _tabBtns = [NSMutableArray array];
    }
    return _tabBtns;
}

- (NSMutableArray *)dotViews {
    
    if (_dotViews == nil) {
        _dotViews = [NSMutableArray array];
    }
    return _dotViews;
}

@end
