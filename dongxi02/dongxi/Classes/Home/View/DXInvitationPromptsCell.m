//
//  DXInvitationPromptsCell.m
//  dongxi
//
//  Created by 穆康 on 15/11/5.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXInvitationPromptsCell.h"

@interface DXInvitationPromptsCell ()

@property (nonatomic, weak) UIView *bgView;

@property (nonatomic, weak) UILabel *promptsL;

@end

@implementation DXInvitationPromptsCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"InvitationPromptsCell";
    
    DXInvitationPromptsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXInvitationPromptsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = DXRGBColor(222, 222, 222);
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = DXRGBColor(247, 250, 251);
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    UILabel *promptsL = [[UILabel alloc] init];
    promptsL.text = @"赶快邀请身边酷酷的朋友来加入超酷的东西吧；）";
    promptsL.textColor = DXRGBColor(143, 143, 143);
    promptsL.textAlignment = NSTextAlignmentCenter;
    promptsL.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(13.0f)];
    [bgView addSubview:promptsL];
    self.promptsL = promptsL;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat bgViewW = DXRealValue(338.0f);
    CGFloat bgViewH = DXRealValue(34.6f);
    self.bgView.size = CGSizeMake(bgViewW, bgViewH);
    self.bgView.centerX = self.contentView.width * 0.5f;
    self.bgView.y = DXRealValue(17.0f);
    self.bgView.layer.cornerRadius = bgViewH * 0.5f;
    self.bgView.layer.masksToBounds = YES;
    
    self.promptsL.frame = self.bgView.bounds;
}

@end
