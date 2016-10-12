//
//  DXFeedListViewFlowLayout.m
//  dongxi
//
//  Created by 穆康 on 16/8/19.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXFeedListViewFlowLayout.h"

static CGFloat const dividerHeight = 3;

@implementation DXFeedListViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.headerReferenceSize = CGSizeMake(DXScreenWidth, 43);
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(dividerHeight, 0, 0, 0);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView *const collectionView = self.collectionView;
    CGPoint const contentOffset = collectionView.contentOffset;
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
    
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        [answer addObject:layoutAttributes];
    }];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [collectionView numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, numberOfItemsInSection - 1) inSection:section];
            
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
            
            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
            CGPoint origin = layoutAttributes.frame.origin;
            origin.y = MIN(
                           MAX(
                               contentOffset.y,
                               CGRectGetMinY(firstCellAttrs.frame) - headerHeight
                               ),
                           CGRectGetMaxY(lastCellAttrs.frame) - headerHeight
                           );
            
            layoutAttributes.zIndex = 1;
            layoutAttributes.frame = (CGRect){
                .origin = origin,
                .size = layoutAttributes.frame.size
            };
        }
    }
    return [answer copy];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
