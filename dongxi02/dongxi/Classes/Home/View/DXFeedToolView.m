//
//  DXFeedToolView.m
//  dongxi
//
//  Created by 穆康 on 15/10/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedToolView.h"
#import "DXFeedCommentCountView.h"

@interface DXFeedToolView ()

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) DXFeedCommentCountView *commentCountView;

@end

@implementation DXFeedToolView

- (instancetype)initWithToolViewType:(DXFeedToolViewType)toolViewType {
    self = [self initWithToolViewType:toolViewType frame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithToolViewType:DXFeedToolViewTypeOther frame:frame];
    return self;
}

- (instancetype)initWithToolViewType:(DXFeedToolViewType)toolViewType frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _toolViewType = toolViewType;
        [self setup];
    }
    return self;
}

#pragma mark - 初始化

- (void)setup {
    
    // 图片
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    self.imageView = imageView;
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DXRGBColor(48, 48, 48);
    titleLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(17)];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    if (self.toolViewType == DXFeedToolViewTypeBrowseComment) {
        DXFeedCommentCountView *commentCountView = [[DXFeedCommentCountView alloc] init];
        [self addSubview:commentCountView];
        self.commentCountView = commentCountView;
    }
}

- (void)setTitleName:(NSString *)titleName {
    
    _titleName = titleName;
    
    self.titleLabel.text = titleName;
}

- (void)setImageName:(NSString *)imageName {
    
    _imageName = imageName;
    
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)setCommentCount:(NSUInteger)commentCount {
    _commentCount = commentCount;
    
    if (commentCount) {
        self.commentCountView.hidden = NO;
        NSString *commentCountStr = nil;
        if (commentCount > 99) {
            commentCountStr = @"99+";
        } else {
            commentCountStr = [NSString stringWithFormat:@"%zd", commentCount];
        }
        self.commentCountView.countLabel.text = commentCountStr;
    } else {
        self.commentCountView.hidden = YES;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.imageName) {
        
        self.imageView.size = CGSizeMake(DXRealValue(16), DXRealValue(16));
        self.imageView.x = DXRealValue(22);
        self.imageView.centerY = self.height * 0.5;
        
        [self.titleLabel sizeToFit];
        self.titleLabel.x = CGRectGetMaxX(self.imageView.frame) + DXRealValue(6);
        self.titleLabel.centerY = self.imageView.centerY;
        
    } else {
        
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
    
    if (self.toolViewType == DXFeedToolViewTypeBrowseComment) {
        CGFloat commentCountViewX = roundf(DXRealValue(72));
        CGFloat commentCountViewY = roundf(DXRealValue(6));
        CGFloat commentCountViewW = roundf(DXRealValue(24));
        CGFloat commentCountViewH = roundf(DXRealValue(40/3.0));
        self.commentCountView.frame = CGRectMake(commentCountViewX, commentCountViewY, commentCountViewW, commentCountViewH);
    }
}

@end
