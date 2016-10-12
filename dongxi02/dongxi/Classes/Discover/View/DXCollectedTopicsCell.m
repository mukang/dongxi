//
//  DXCollectedTopicsCell.m
//  dongxi
//
//  Created by 穆康 on 16/1/26.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCollectedTopicsCell.h"
#import "DXCollectedTopicCell.h"

static NSString *const IDCollectedTopicCell = @"CollectedTopicCell";

@interface DXCollectedTopicsCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation DXCollectedTopicsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = DXRGBColor(222, 222, 222);
    
    CGFloat margin = roundf(DXRealValue(25/3.0));
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(roundf(DXRealValue(84)), roundf(DXRealValue(84)));
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(0, margin, margin, margin);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[DXCollectedTopicCell class] forCellWithReuseIdentifier:IDCollectedTopicCell];
}

- (void)setCollectedTopics:(NSArray *)collectedTopics {
    _collectedTopics = collectedTopics;
    
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:collectedTopics];
    [self.collectionView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat collectionViewW = self.contentView.width;
    CGFloat collectionViewH = roundf(DXRealValue(25/3.0)) + roundf(DXRealValue(84));
    self.collectionView.frame = CGRectMake(0, 0, collectionViewW, collectionViewH);
}

#pragma mark - collection view dataSource and delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DXCollectedTopicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDCollectedTopicCell forIndexPath:indexPath];
    DXTopic *topic = self.dataList[indexPath.item];
    cell.topic = topic;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DXTopic *topic = self.dataList[indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectedTopicsCell:didTapTopicPhotoWithTopic:)]) {
        [self.delegate collectedTopicsCell:self didTapTopicPhotoWithTopic:topic];
    }
}

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
