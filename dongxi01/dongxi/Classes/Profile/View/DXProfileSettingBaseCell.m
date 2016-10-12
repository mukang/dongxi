//
//  DXProfileSettingBaseCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/27.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileSettingBaseCell.h"

@implementation DXProfileSettingBaseCell {
    CGFloat _settingLabelLeading;
    UIView * _settingIconContainer;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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

        [self prepareSubviews];
        
        [self.settingIconView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self.settingIconView removeObserver:self forKeyPath:@"image"];
}

- (void)prepareSubviews {
    _settingLabelLeading = DXRealValue(132.0/3);
    
    _settingIconContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _settingIconContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_settingIconContainer];
    
    _settingIconView = [[UIImageView alloc] init];
    _settingIconView.translatesAutoresizingMaskIntoConstraints = NO;
    [_settingIconContainer addSubview:_settingIconView];
    
    _settingTextLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _settingTextLabel.font = [DXFont dxDefaultFontWithSize:50.0/3];
    _settingTextLabel.textColor = DXRGBColor(72, 72, 72);
    _settingTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_settingTextLabel];
    
    [self setNeedsUpdateConstraints];
}

- (void)prepareConstraints {
    [self removeConstraints:self.constraints];
    
    if (self.settingIconView.image) {
        CGSize iconSize = self.settingIconView.image.size;
        iconSize.width = DXRealValue(iconSize.width);
        iconSize.height = DXRealValue(iconSize.height);
        
        /** 设置图标父容器 Top约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_settingIconContainer
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0]];
        /** 设置图标父容器 Leading约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_settingIconContainer
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0
                                                          constant:0]];
        /** 设置图标父容器 Bottom约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_settingIconContainer
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0]];
        /** 设置图标父容器 Width约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_settingIconContainer
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:_settingLabelLeading]];
        /** settingIconView Width约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingIconView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:iconSize.width]];
        /** settingIconView Height约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingIconView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:iconSize.height]];
        /** settingIconView CenterX约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingIconView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_settingIconContainer
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
        /** settingIconView CenterY约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingIconView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_settingIconContainer
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        /** settingTextLabel Leading约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingTextLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0
                                                          constant:_settingLabelLeading]];
    } else {
        CGFloat noneIconLeading = DXRealValue(12);
        /** settingTextLabel Leading约束 */
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingTextLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0
                                                          constant:noneIconLeading]];
    }
    
    /** settingTextLabel Trailing约束 */
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingTextLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:0]];
    /** settingTextLabel Top约束 */
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingTextLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    /** settingTextLabel Bottom约束 */
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.settingTextLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
}

- (void)updateConstraints {
    [self prepareConstraints];
    
    [super updateConstraints];
}

- (void)setShowMoreView:(BOOL)showMoreView {
    _showMoreView = showMoreView;
    
    if (showMoreView) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_more"]];
    } else {
        self.accessoryView = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.settingIconView && [keyPath isEqualToString:@"image"]) {
        [self setNeedsUpdateConstraints];
    }
}

@end
