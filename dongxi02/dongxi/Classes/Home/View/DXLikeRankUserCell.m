//
//  DXLikeRankUserCell.m
//  dongxi
//
//  Created by 穆康 on 16/3/18.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXLikeRankUserCell.h"

#define RankNumImageFirst        [UIImage imageNamed:@"like_rank_num_first"]    // 第一名
#define RankNumImageSecond       [UIImage imageNamed:@"like_rank_num_second"]   // 第二名
#define RankNumImageThird        [UIImage imageNamed:@"like_rank_num_third"]    // 第三名

@interface DXLikeRankUserCell ()

@property (nonatomic, weak) UIImageView *likeView;
@property (nonatomic, weak) UILabel *likeLabel;

@end

@implementation DXLikeRankUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UIImageView *likeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like_rank_like_image"]];
    [self.contentView addSubview:likeView];
    
    UILabel *likeLabel = [[UILabel alloc] init];
    likeLabel.textColor = DXRGBColor(255, 139, 139);
    likeLabel.font = [DXFont dxDefaultFontWithSize:40/3.0];
    [self.contentView addSubview:likeLabel];
    
    self.likeView = likeView;
    self.likeLabel = likeLabel;
}

- (void)setRankUser:(DXRankUser *)rankUser {
    [super setRankUser:rankUser];
    
    if (rankUser.rank == 1) {
        self.rankNumView.hidden = NO;
        self.rankNumLabel.hidden = YES;
        self.rankNumView.image = RankNumImageFirst;
    } else if (rankUser.rank == 2) {
        self.rankNumView.hidden = NO;
        self.rankNumLabel.hidden = YES;
        self.rankNumView.image = RankNumImageSecond;
    } else if (rankUser.rank == 3) {
        self.rankNumView.hidden = NO;
        self.rankNumLabel.hidden = YES;
        self.rankNumView.image = RankNumImageThird;
    } else {
        self.rankNumView.hidden = YES;
        self.rankNumLabel.hidden = NO;
        self.rankNumLabel.text = [NSString stringWithFormat:@"%zd", rankUser.rank];
        [self.rankNumLabel sizeToFit];
    }
    
    self.likeLabel.text = [NSString stringWithFormat:@"%zd", rankUser.like_count];
    [self.likeLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.likeView.size = CGSizeMake(DXRealValue(46/3.0), DXRealValue(40/3.0));
    self.likeView.x = DXRealValue(120);
    self.likeView.y = DXRealValue(37);
    
    self.likeLabel.centerY = self.likeView.centerY;
    self.likeLabel.x = CGRectGetMaxX(self.likeView.frame) + DXRealValue(7);
}

@end
