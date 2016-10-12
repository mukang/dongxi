//
//  DXChatTimeCell.m
//  dongxi
//
//  Created by 穆康 on 15/9/10.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXChatTimeCell.h"

@implementation DXChatTimeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"ChatTimeCell";
    
    DXChatTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DXChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = DXRGBColor(222, 222, 222);
        self.textLabel.textColor = DXRGBColor(143, 143, 143);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [DXFont systemFontOfSize:13.0f weight:DXFontWeightLight];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
