//
//  DXNoContentCell.m
//  dongxi
//
//  Created by 穆康 on 15/12/4.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXNoContentCell.h"

@interface DXNoContentCell ()

@property (nonatomic, weak) UILabel *noticeLabel;

@end

@implementation DXNoContentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"NoContentCell";
    
    DXNoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXNoContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setup];
    }
    return self;
}

// 初始化子控件
- (void)setup {
    
    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.font = [UIFont fontWithName:DXCommonFontName size:DXRealValue(15.0f)];
    noticeLabel.textColor = DXRGBColor(72, 72, 72);
    [self.contentView addSubview:noticeLabel];
    self.noticeLabel = noticeLabel;
}

- (void)setNotice:(NSString *)notice {
    
    _notice = notice;
    
    self.noticeLabel.text = notice;
    [self.noticeLabel sizeToFit];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.noticeLabel.center = CGPointMake(self.contentView.width * 0.5f, self.contentView.height * 0.5f);
}

@end
