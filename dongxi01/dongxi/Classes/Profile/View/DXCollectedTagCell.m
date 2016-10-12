//
//  DXCollectedTagCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollectedTagCell.h"
#import "DXTag.h"

#define TagLabelFont        [DXFont dxDefaultFontWithSize:16]   // 标签字体
#define TagLabelPadding     DXRealValue(11)                     // 标签在背景图中的左右偏移
#define DeleteBtnWH         DXRealValue(13)                     // 删除按钮的尺寸

@interface DXCollectedTagCell ()

@property (nonatomic, weak) UIView *bgView;
@property (nonatomic, weak) UILabel *tagLabel;
@property (nonatomic, weak) UIButton *deleteBtn;

@end

@implementation DXCollectedTagCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = DXRGBColor(108, 197, 255);
    [self.contentView addSubview:bgView];
    
    UILabel *tagLabel = [[UILabel alloc] init];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.textColor = [UIColor whiteColor];
    tagLabel.font = TagLabelFont;
    [bgView addSubview:tagLabel];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"button_tag_delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteBtn];
    
    self.bgView = bgView;
    self.tagLabel = tagLabel;
    self.deleteBtn = deleteBtn;
}

- (void)setCollectedTag:(DXTag *)collectedTag {
    _collectedTag = collectedTag;
    
    self.tagLabel.text = collectedTag.name;
    [self.tagLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat deleteBtnX = self.contentView.width - DeleteBtnWH;
    self.deleteBtn.frame = CGRectMake(deleteBtnX, 0, DeleteBtnWH, DeleteBtnWH);
    
    CGFloat bgViewY = DeleteBtnWH / 3;
    CGFloat bgViewW = self.contentView.width - DeleteBtnWH / 3;
    CGFloat bgViewH = self.contentView.height - bgViewY;
    self.bgView.frame = CGRectMake(0, bgViewY, bgViewW, bgViewH);
    self.bgView.layer.cornerRadius = bgViewH / 3;
    self.bgView.layer.masksToBounds = YES;
    
    self.tagLabel.center = CGPointMake(bgViewW * 0.5, bgViewH * 0.5);
}

- (void)deleteBtnDidClick {

    if (self.delegate && [self.delegate respondsToSelector:@selector(collectedTagCell:didClickDeleteBtnWithCollectedTag:)]) {
        [self.delegate collectedTagCell:self didClickDeleteBtnWithCollectedTag:self.collectedTag];
    }
}

+ (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath withCollectedTag:(DXTag *)collectedTag {
    
    NSDictionary *attributes = @{NSFontAttributeName: TagLabelFont};
    CGSize tagLabelSize = [collectedTag.name sizeWithAttributes:attributes];
    
    return (TagLabelPadding * 2) + tagLabelSize.width + (DeleteBtnWH / 3);
}

@end
