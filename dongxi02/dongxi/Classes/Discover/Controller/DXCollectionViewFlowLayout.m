//
//  DXCollectionViewFlowLayout.m
//  dongxi
//
//  Created by 穆康 on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollectionViewFlowLayout.h"

@implementation DXCollectionViewFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    DXLog(@"====>%zd", array.count);
    for (UICollectionViewLayoutAttributes *att in array) {
        DXLog(@"====>%@", att);
    }
    
    return array;
}

@end
