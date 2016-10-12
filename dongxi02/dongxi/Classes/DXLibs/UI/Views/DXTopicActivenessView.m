//
//  DXTopicActivenessView.m
//  dongxi
//
//  Created by 穆康 on 16/1/22.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicActivenessView.h"

#define GreenColor      DXRGBColor(112, 171, 43)   // 小于1000
#define YellowColor     DXRGBColor(203, 172, 0)    // 小于5000
#define OrangeColor     DXRGBColor(221, 125, 12)   // 小于10000
#define RedColor        DXRGBColor(225, 79, 60)    // 大于等于10000

@interface DXTopicActivenessView ()

/** 活跃度Label */
@property (nonatomic, weak) UILabel *activenessLabel;

@end

@implementation DXTopicActivenessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1;
    
    UILabel *activenessLabel = [[UILabel alloc] init];
    activenessLabel.font = [DXFont dxDefaultFontWithSize:28/3.0];
    [self addSubview:activenessLabel];
    self.activenessLabel = activenessLabel;
}

- (void)setActiveness:(NSInteger)activeness {
    _activeness = activeness;
    
    if (activeness < 1000) {
        self.layer.borderColor = GreenColor.CGColor;
        self.activenessLabel.textColor = GreenColor;
        self.activenessLabel.text = [NSString stringWithFormat:@"活跃度%zd", activeness];
    } else if (activeness < 5000) {
        self.layer.borderColor = YellowColor.CGColor;
        self.activenessLabel.textColor = YellowColor;
        self.activenessLabel.text = @"活跃度1000+";
    } else if (activeness < 10000) {
        self.layer.borderColor = OrangeColor.CGColor;
        self.activenessLabel.textColor = OrangeColor;
        self.activenessLabel.text = @"活跃度5000+";
    } else {
        self.layer.borderColor = RedColor.CGColor;
        self.activenessLabel.textColor = RedColor;
        self.activenessLabel.text = @"活跃度10000+";
    }
    
    [self.activenessLabel sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [super sizeThatFits:size];
    
    fitSize.width = self.activenessLabel.width + DXRealValue(8);
    fitSize.height = DXRealValue(17);
    
    return fitSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activenessLabel.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

@end
