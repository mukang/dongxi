//
//  DXTopTopicsView.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/20.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopTopicsView.h"

@interface DXTopTopicsView() <DXTopTopicItemViewDelegate>

@property (nonatomic, assign) CGFloat paddingSpace;

@property (nonatomic, assign) CGFloat bottomPaddingSpace;

@end

@implementation DXTopTopicsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (CGFloat)paddingSpace {
    return 2.0f;
}

- (CGFloat)bottomPaddingSpace {
    return DXRealValue(20/3.0);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        frame.size.height = (frame.size.width - self.paddingSpace) / 2 + self.paddingSpace * 2;
        self.frame = frame;
        
        self.firstTopTopicView = [[DXTopTopicItemView alloc] initWithFrame:CGRectZero];
        self.firstTopTopicView.translatesAutoresizingMaskIntoConstraints = NO;
        self.firstTopTopicView.delegate = self;
        
        self.secondTopTopicView = [[DXTopTopicItemView alloc] initWithFrame:CGRectZero];
        self.secondTopTopicView.translatesAutoresizingMaskIntoConstraints = NO;
        self.secondTopTopicView.delegate = self;
        
        [self addSubview:self.firstTopTopicView];
        [self addSubview:self.secondTopTopicView];
        
        NSDictionary * views = @{
                                 @"firstTopTopicView" : self.firstTopTopicView,
                                 @"secondTopTopicView" : self.secondTopTopicView
                                 };
        
        NSString * visualFormat = nil;
        NSArray * constraints = nil;
        visualFormat = [NSString stringWithFormat:@"H:|[firstTopTopicView(==secondTopTopicView)]-%.1f-[secondTopTopicView]|", self.paddingSpace];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        visualFormat = [NSString stringWithFormat:@"V:|-%.1f-[firstTopTopicView]-%1.f-|", self.paddingSpace, self.bottomPaddingSpace];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
        
        visualFormat = [NSString stringWithFormat:@"V:|-%.1f-[secondTopTopicView]-%1.f-|", self.paddingSpace, self.bottomPaddingSpace];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
        [self addConstraints:constraints];
    }
    return self;
}

- (void)userDidTapTopicItemView:(DXTopTopicItemView *)itemView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(topTopicsView:didSelectAtIndex:)]) {
        if (itemView == self.firstTopTopicView) {
            [self.delegate topTopicsView:self didSelectAtIndex:0];
        } else {
            [self.delegate topTopicsView:self didSelectAtIndex:1];
        }
    }
}

@end
