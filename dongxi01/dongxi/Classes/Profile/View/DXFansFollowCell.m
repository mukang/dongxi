//
//  DXFansFollowCell.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/31.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFansFollowCell.h"

@interface DXFansFollowCell  ()

@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIView *lineV;

@end

@implementation DXFansFollowCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //头像
        DXAvatarView *IconV = [[DXAvatarView alloc]init];
    
        [self.contentView addSubview:IconV];
        
        _avatarView = IconV;
        
        
        //小背景图点击
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelAvatarTapGesture:)];
        
        singleFingerOne.numberOfTouchesRequired = 1;
        
        singleFingerOne.numberOfTapsRequired = 1;
        
        singleFingerOne.delegate = self;
        
        [IconV addGestureRecognizer:singleFingerOne];

        
        //用户昵称
        UILabel *userName = [[UILabel alloc]init];
        
        [userName setTextColor:DXRGBColor(72, 72, 72)];
        
        [userName setFont:[DXFont dxDefaultBoldFontWithSize:16.6]];
        
        [self.contentView addSubview:userName];
        
        _nameLabel = userName;
        
        //用户来自
        UILabel *userAddress = [[UILabel alloc]init];

        [userAddress setTextColor:DXCommonColor];
        
        [userAddress setFont:[DXFont dxDefaultFontWithSize:15]];
        
        [self.contentView addSubview:userAddress];
        
        _locationLabel = userAddress;
        
        //关注按钮
        UIButton *acctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [acctionBtn addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:acctionBtn];
        
        _followButton = acctionBtn;
        

        UIView *lineV = [[UIView alloc] initWithFrame:CGRectZero];
        lineV.backgroundColor = DXRGBColor(222, 222, 222);
        [self addSubview:lineV];
        
        _lineV = lineV;
    }
    
    return self;
}

/**
 *  设置关注关系，影响followButton的图片显示
 *
 *  @param relation 与当前用户的关系，见DXUserRelationType
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)setRelation:(DXUserRelationType)relation {
    _relation = relation;
    
    self.followButton.hidden = NO;
    
    switch (relation) {
        case DXUserRelationTypeFollower:
            [self.followButton setImage:[UIImage imageNamed:@"attention_add"] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFollowed:
            [self.followButton setImage:[UIImage imageNamed:@"attention_ok"] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeFriend:
            [self.followButton setImage:[UIImage imageNamed:@"attention_mutual"] forState:UIControlStateNormal];
            break;
        case DXUserRelationTypeCurrentUser:
            self.followButton.hidden = YES;
            break;
        default:
            [self.followButton setImage:[UIImage imageNamed:@"attention_add"] forState:UIControlStateNormal];
            break;
    }
}


/**
 *  处理头像上的轻按手势
 *
 *  @param gesture 轻按手势
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)handelAvatarTapGesture:(UITapGestureRecognizer *)gesture{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatarInFansFollowCell:)]) {
        [self.delegate didTapAvatarInFansFollowCell:self];
    }
}


/**
 *  关注按钮点击事件回调
 *
 *  @param sender 回调调用对象
 *
 *  @author Xu Shiwen
 *  @date   02/11/2015
 */
- (void)followButtonTapped:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollowButtonInFansFollowCell:)]) {
        [self.delegate didTapFollowButtonInFansFollowCell:self];
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    //头像
    self.avatarView.width = DXRealValue(50);
    
    self.avatarView.height = DXRealValue(50);
    
    self.avatarView.x = DXRealValue(13);
    
    self.avatarView.centerY = self.contentView.centerY;
    
    //用户昵称
    self.nameLabel.x = DXRealValue(77.6);
    
    self.nameLabel.y = DXRealValue(12);
    
    [self.nameLabel sizeToFit];
    
    //用户来自
    self.locationLabel.x = DXRealValue(77.6);
    
    self.locationLabel.y = DXRealValue(35.3);
    
    [self.locationLabel sizeToFit];
    
    //关注按钮
    self.followButton.width = DXRealValue(58.5);
    
    self.followButton.height = DXRealValue(33);
    
    self.followButton.x = [UIScreen mainScreen].bounds.size.width - DXRealValue(78.5);
    
    self.followButton.centerY = self.contentView.centerY;
    
    
    CGFloat cellHeight = CGRectGetHeight(self.bounds);
    CGFloat cellWidth = CGRectGetWidth(self.bounds);
    [self.lineV setFrame:CGRectMake(0, cellHeight-0.5, cellWidth, 0.5)];

}
@end
