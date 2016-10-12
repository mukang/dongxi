//
//  DXMutiLineLabel.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXMutiLineLabel.h"

@implementation DXMutiLineLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfLines = 0;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    self.preferredMaxLayoutWidth = bounds.size.width;
}

- (void)setText:(NSString *)text {
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text && self.paragraphStyle) {
        NSDictionary * attributes = @{
                                      NSParagraphStyleAttributeName: self.paragraphStyle
                                      };
        NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [self setAttributedText:attributedText];
    } else {
       [super setText:text];
    }
}

@end
