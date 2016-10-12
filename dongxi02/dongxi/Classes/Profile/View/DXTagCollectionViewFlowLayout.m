//
//  DXTagCollectionViewFlowLayout.m
//  dongxi
//
//  Created by 穆康 on 16/1/12.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagCollectionViewFlowLayout.h"

#define CollectedItemSpacing DXRealValue(8)     // 关注的cell之间的间距
#define NormalItemSpacing    DXRealValue(12)    // 全部的cell之间的间距
#define InsetMargin          DXRealValue(40/3)

@implementation DXTagCollectionViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *tempArry = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attrs in array) {
        [tempArry addObject:(UICollectionViewLayoutAttributes *)[attrs copy]];
    }
    
    for (int i=1; i<tempArry.count; i++) {
        UICollectionViewLayoutAttributes *currentAttr = tempArry[i];
        UICollectionViewLayoutAttributes *previousAttr = tempArry[i-1];
        
        CGFloat origin = CGRectGetMaxX(previousAttr.frame);
        
        if (currentAttr.indexPath.section == previousAttr.indexPath.section && currentAttr.indexPath.section == 0 && origin + CollectedItemSpacing + currentAttr.size.width + InsetMargin * 2 < self.collectionViewContentSize.width) {
            CGRect temp = currentAttr.frame;
            temp.origin.x = origin + CollectedItemSpacing;
            currentAttr.frame = temp;
        }
        if (currentAttr.indexPath.section == previousAttr.indexPath.section && currentAttr.indexPath.section == 1 && origin + NormalItemSpacing + currentAttr.size.width + InsetMargin * 2 < self.collectionViewContentSize.width) {
            CGRect temp = currentAttr.frame;
            temp.origin.x = origin + NormalItemSpacing;
            currentAttr.frame = temp;
        }
    }
    
    return [tempArry copy];
}

@end
