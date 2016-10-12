//
//  DXSettingOneCell.m
//  dongxi
//
//  Created by 邱思雨 on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingNameCell.h"

@interface DXProfileSettingNameCell ()

@property(nonatomic,strong) UIImageView *nextIamge;

@end

@implementation DXProfileSettingNameCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        /** 设置分隔线样式，针对iOS [7.0, 8.0) */
        self.separatorInset = UIEdgeInsetsZero;
        
        /** 改变分隔线样式：设置layoutMargins，针对iOS (>=8.0) */
        if ([self respondsToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        
        /** 改变分隔线样式：阻止使用父视图的layoutMargins，针对iOS (>=8.0) */
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            self.preservesSuperviewLayoutMargins = NO;
        }
        
        //用户名
        UILabel *userNameLabel = [[UILabel alloc] init];
        userNameLabel.text = @"请输入昵称";
        userNameLabel.textColor = DXRGBColor(72, 72, 72);
        userNameLabel.font = [UIFont fontWithName:DXCommonBoldFontName size:DXRealValue(18)];
        [self.contentView addSubview:userNameLabel];
        
        _nameLabel = userNameLabel;
        
        //用户头像
        UIImageView *userIcon = [[UIImageView alloc] init];
        [userIcon setImage:[UIImage imageNamed:@"image150_test"]];
        [self.contentView addSubview:userIcon];
        
        _avatarImageView = userIcon;
        
        //导航键
        UIImageView *nextImage = [[UIImageView alloc]init];
        [nextImage setImage:[UIImage imageNamed:@"set_more"]];
        [self.contentView addSubview:nextImage];
        
        _nextIamge = nextImage;
    }
    return self;
}

-(void)layoutSubviews
{
    //用户名约束
    [self.nameLabel sizeToFit];
    self.nameLabel.x =DXRealValue( 13.3);
    self.nameLabel.centerY = self.contentView.centerY;
   
    //用户头像约束
    self.avatarImageView.width = DXRealValue(50);
    self.avatarImageView.height = DXRealValue(50);
    self.avatarImageView.centerY = self.contentView.centerY;
    self.avatarImageView.x = self.width - DXRealValue(90);
    self.avatarImageView.layer.cornerRadius = DXRealValue(50)/2;
    self.avatarImageView.layer.masksToBounds = YES;
    
    //下一步图标
    self.nextIamge.width = DXRealValue(8);
    self.nextIamge.height = DXRealValue(13);
    self.nextIamge.centerY = self.contentView.centerY;
    self.nextIamge.x = self.width - DXRealValue(21);
    
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
