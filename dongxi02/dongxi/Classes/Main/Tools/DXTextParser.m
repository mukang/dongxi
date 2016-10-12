//
//  DXTextParser.m
//  dongxi
//
//  Created by 穆康 on 16/5/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTextParser.h"

@implementation DXTextParser

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)selectedRange {
    BOOL changed = NO;
    NSMutableString *tempStr = [NSMutableString string];
    for (DXContentPiece *peice in self.contentPieces) {
        [tempStr appendString:peice.content];
        NSRange range = NSMakeRange(tempStr.length - peice.content.length, peice.content.length);
        if (text.length >= range.location + range.length) {
            if (peice.type == DXContentPieceTypeRefer) {
                YYTextBinding *textBinding = [YYTextBinding bindingWithDeleteConfirm:YES];
                [text yy_setTextBinding:textBinding range:range];
                [text yy_setColor:DXRGBColor(64, 189, 206) range:range];
            } else {
                [text yy_setColor:DXRGBColor(72, 72, 72) range:range];
            }
            changed = YES;
        }
    }
    return changed;
}

@end
