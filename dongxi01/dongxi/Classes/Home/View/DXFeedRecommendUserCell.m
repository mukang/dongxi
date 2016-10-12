//
//  DXFeedRecommendUserCell.m
//  dongxi
//
//  Created by 穆康 on 16/3/14.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedRecommendUserCell.h"
#import "DXFeedRecommendUserView.h"

#define TopMargin DXRealValue(7) // cell内容顶部间距
static const NSInteger userCount = 4;

@interface DXFeedRecommendUserCell () <DXFeedRecommendUserViewDelegate>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *userViews;
@property (nonatomic, strong) NSMutableArray *separateViews;

@end

@implementation DXFeedRecommendUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = DXRGBColor(222, 222, 222);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:containerView];
    self.containerView = containerView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"你可能感兴趣的人";
    titleLabel.textColor = DXRGBColor(72, 72, 72);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:35/3.0];
    [titleLabel sizeToFit];
    [containerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    for (NSInteger i=0; i<userCount; i++) {
        DXFeedRecommendUserView *userView = [[DXFeedRecommendUserView alloc] init];
        userView.delegate = self;
        [containerView addSubview:userView];
        [self.userViews addObject:userView];
    }
    
    for (NSInteger i=0; i<userCount-1; i++) {
        UIView *separateView = [[UIView alloc] init];
        separateView.backgroundColor = DXRGBColor(225, 225, 225);
        [containerView addSubview:separateView];
        [self.separateViews addObject:separateView];
    }
}

- (void)setRecommendation:(DXTimelineRecommendation *)recommendation {
    _recommendation = recommendation;
    
    NSArray *users = recommendation.recommend_user;
    for (NSUInteger i=0; i<users.count; i++) {
        DXFeedRecommendUserView *userView = self.userViews[i];
        userView.user = users[i];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(0, TopMargin, self.contentView.width, self.contentView.height - TopMargin);
    
    self.titleLabel.x = DXRealValue(13);
    self.titleLabel.y = DXRealValue(35/3.0);
    
    CGFloat userViewX = 0;
    CGFloat userViewY = DXRealValue(25);
    CGFloat userViewW = self.containerView.width / userCount;
    CGFloat userViewH = self.containerView.height - userViewY;
    for (NSInteger i=0; i<userCount; i++) {
        DXFeedRecommendUserView *userView = self.userViews[i];
        userViewX = userViewW * i;
        userView.frame = CGRectMake(userViewX, userViewY, userViewW, userViewH);
    }
    
    CGFloat separateViewX = 0;
    CGFloat separateViewY = DXRealValue(124/3.0);
    CGFloat separateViewW = 0.5;
    CGFloat separateViewH = DXRealValue(172/3.0);
    for (NSInteger i=0; i<userCount-1; i++) {
        DXFeedRecommendUserView *userView = self.userViews[i];
        UIView *separateView = self.separateViews[i];
        separateViewX = CGRectGetMaxX(userView.frame);
        separateView.frame = CGRectMake(separateViewX, separateViewY, separateViewW, separateViewH);
    }
}

- (void)feedRecommendUserView:(DXFeedRecommendUserView *)view didTapAvatarViewWithUser:(DXUser *)user {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedRecommendUserCell:didTapAvatarViewWithUser:)]) {
        [self.delegate feedRecommendUserCell:self didTapAvatarViewWithUser:user];
    }
}

- (NSMutableArray *)userViews {
    if (_userViews == nil) {
        _userViews = [NSMutableArray arrayWithCapacity:userCount];
    }
    return _userViews;
}

- (NSMutableArray *)separateViews {
    if (_separateViews == nil) {
        _separateViews = [NSMutableArray arrayWithCapacity:userCount-1];
    }
    return _separateViews;
}

@end
