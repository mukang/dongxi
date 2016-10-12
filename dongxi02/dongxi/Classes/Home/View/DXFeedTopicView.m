//
//  DXFeedTopicView.m
//  dongxi
//
//  Created by 穆康 on 15/9/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedTopicView.h"

@interface DXFeedTopicView ()

@property (nonatomic, weak) UILabel *topicL;

@property (nonatomic, weak) UIView *bgView;

@end

@implementation DXFeedTopicView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = DXRGBColor(240, 240, 240);
    bgView.hidden = YES;
    [self addSubview:bgView];
    self.bgView = bgView;
    
    UILabel *topicL = [[UILabel alloc] init];
    topicL.textColor = DXRGBColor(64, 189, 206);
    [self addSubview:topicL];
    self.topicL = topicL;
}

- (void)setFont:(UIFont *)font {
    
    _font = font;
    
    self.topicL.font = font;
}

- (void)setText:(NSString *)text {
    
    _text = text;
    
    self.topicL.text = text;
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    [self.topicL sizeToFit];
    
    return CGSizeMake(self.topicL.width, self.topicL.height);
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.topicL.origin = CGPointMake(0, 0);
    
    self.bgView.frame = self.bounds;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.bgView.hidden = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.bgView.hidden = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.bgView.hidden = YES;
}

@end
