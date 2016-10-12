//
//  DXProfileUpdateBioCell.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/30.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXProfileUpdateBioCell.h"
#import "DXProfileUpdateBioView.h"

@implementation DXProfileUpdateBioCell {
    DXProfileUpdateBioView * _updateBioView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self prepareSubviews];
    }
    return self;
}

- (void)prepareSubviews {
    _updateBioView = [[DXProfileUpdateBioView alloc] initWithFrame:self.bounds];
    _updateBioView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_updateBioView];
    
    self.bioLabel = _updateBioView.bioLabel;
    self.containerView = _updateBioView;
}

@end
