//
//  DXTopicRankUserCell.m
//  dongxi
//
//  Created by 穆康 on 16/2/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicRankUserCell.h"

#define RankNumImageFirst        [UIImage imageNamed:@"discover_rank_num_first"]    // 第一名
#define RankNumImageSecond       [UIImage imageNamed:@"discover_rank_num_second"]   // 第二名
#define RankNumImageThird        [UIImage imageNamed:@"discover_rank_num_third"]    // 第三名

@interface DXTopicRankUserCell ()

@property (nonatomic, weak) UILabel *activenessLabel;

@end

@implementation DXTopicRankUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UILabel *activenessLabel = [[UILabel alloc] init];
    activenessLabel.textColor = DXCommonColor;
    activenessLabel.font = [DXFont dxDefaultFontWithSize:15];
    [self.contentView addSubview:activenessLabel];
    self.activenessLabel = activenessLabel;
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
    
    self.activenessLabel.text = [NSString stringWithFormat:@"活跃值：%zd", rankUser.points];
    [self.activenessLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activenessLabel.x = DXRealValue(120);
    self.activenessLabel.y = DXRealValue(38);
}

@end
