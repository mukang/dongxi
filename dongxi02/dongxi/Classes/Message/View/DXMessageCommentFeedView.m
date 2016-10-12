//
//  DXMessageCommentFeedView.m
//  dongxi
//
//  Created by 穆康 on 15/10/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMessageCommentFeedView.h"
#import "DXDongXiApi.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Extension.h"

@interface DXMessageCommentFeedView ()

/** feed图片 */
@property (nonatomic, weak) UIImageView *feedImageV;
/** feed内容 */
@property (nonatomic, weak) UILabel *feedTextL;

@end

@implementation DXMessageCommentFeedView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = DXRGBColor(241, 241, 241);
        [self setup];
    }
    return self;
}

- (void)setup {
    
    // feed图片
    UIImageView *feedImageV = [[UIImageView alloc] init];
    [self addSubview:feedImageV];
    self.feedImageV = feedImageV;
    
    // feed内容
    UILabel *feedTextL = [[UILabel alloc] init];
    feedTextL.textColor = DXRGBColor(102, 102, 102);
    feedTextL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13)];
    feedTextL.numberOfLines = 4;
    feedTextL.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [self addSubview:feedTextL];
    self.feedTextL = feedTextL;
}

- (void)setCommentWrapper:(DXNoticeCommentWrapper *)commentWrapper {
    
    _commentWrapper = commentWrapper;
    
    UIImage *placeholderImage = [UIImage placeholderImageWithImageNamed:@"bg_picture" imageSize:CGSizeMake(DXRealValue(110.0f), DXRealValue(110.0f))];
    [self.feedImageV sd_setImageWithURL:[NSURL URLWithString:commentWrapper.photo] placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    
    self.feedTextL.text = commentWrapper.feed_txt;
    [self.feedTextL sizeToFit];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // feed图片
    self.feedImageV.frame = CGRectMake(0, 0, self.height, self.height);
    
    // feed内容
    CGFloat textLX = CGRectGetMaxX(self.feedImageV.frame) + DXRealValue(15);
    CGFloat textLY = DXRealValue(10);
    CGFloat textLW = self.width - textLX - DXRealValue(15);
    CGSize textLSize = [self.feedTextL sizeThatFits:CGSizeMake(textLW, CGFLOAT_MAX)];
    self.feedTextL.frame = CGRectMake(textLX, textLY, textLSize.width, textLSize.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.backgroundColor = DXRGBColor(222, 222, 222);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.backgroundColor = DXRGBColor(241, 241, 241);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didTapMessageCommentFeedView)]) {
            [weakSelf.delegate didTapMessageCommentFeedView];
        }
    });
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.backgroundColor = DXRGBColor(241, 241, 241);
}

@end
