//
//  DXHandelContentPiecesTool.m
//  dongxi
//
//  Created by 穆康 on 16/5/13.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXHandelContentPiecesTool.h"
#import <YYText/YYText.h>

@implementation DXHandelContentPiecesTool

- (NSAttributedString *)createAttributedStringWithContentPieces:(NSArray *)contentPieces {
    
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] init];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:DXRGBColor(240, 240, 240) cornerRadius:0];
    for (DXContentPiece *piece in contentPieces) {
        NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:piece.content];
        NSRange range = NSMakeRange(0, tempStr.length);
        if (piece.type == DXContentPieceTypeRefer) {
            YYTextHighlight *textHighlight = [[YYTextHighlight alloc] init];
            [textHighlight setBackgroundBorder:border];
            textHighlight.tapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                if (piece.refer_type == DXReferTypeUser) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(contentPiecesTool:didSelectHighlightWithUserID:)]) {
                        [self.delegate contentPiecesTool:weakSelf didSelectHighlightWithUserID:piece.refer_id];
                    }
                } else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(contentPiecesTool:didSelectHighlightWithTopicID:)]) {
                        [self.delegate contentPiecesTool:weakSelf didSelectHighlightWithTopicID:piece.refer_id];
                    }
                }
            };
            [tempStr yy_setTextHighlight:textHighlight range:range];
            [tempStr yy_setColor:DXRGBColor(64, 189, 206) range:range];
        } else {
            [tempStr yy_setColor:DXRGBColor(72, 72, 72) range:range];
        }
        [attStr appendAttributedString:tempStr];
    }
    return attStr;
}

@end
