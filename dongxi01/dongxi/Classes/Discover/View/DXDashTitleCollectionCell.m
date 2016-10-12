//
//  DXDashTitleCollectionCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDashTitleCollectionCell.h"

@implementation DXDashTitleCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect titleViewFrame = frame;
        titleViewFrame.origin = CGPointZero;
        self.titleView = [[DXDashTitleView alloc] initWithFrame:titleViewFrame];
        self.titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:self.titleView];
    }
    return self;
}

@end
