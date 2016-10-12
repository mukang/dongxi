//
//  DXPhotoToolPanel.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXPhotoToolPanel.h"


NSString * const DXPhotoToolPanelItemImageKey           = @"DXPhotoToolPanelItemImageKey";
NSString * const DXPhotoToolPanelItemSelectedImageKey   = @"DXPhotoToolPanelItemSelectedImageKey";
NSString * const DXPhotoToolPanelItemTitleKey           = @"DXPhotoToolPanelItemTitleKey";


@interface DXPhotoToolPanel ()

@property (nonatomic, strong) UIFont * titleFont;
@property (nonatomic, strong) UIColor * normalTitleColor;
@property (nonatomic, strong) UIColor * selectedTitleColor;
@property (nonatomic, strong) NSMutableArray * items;

@property (nonatomic, strong) UIView * imageViewContainer;
@property (nonatomic, strong) UIView * labelViewContainer;

@property (nonatomic, assign) BOOL needsToUpdateSubviewContraints;
@property (nonatomic, strong) NSMutableArray * allConstraints;

@property (nonatomic, strong) NSMutableArray * imageViews;
@property (nonatomic, strong) NSMutableArray * labels;

@property (nonatomic, assign) NSInteger selectedIndex;

@end


@implementation DXPhotoToolPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initializeIvars];
        [self setupSubviews];
        self.needsToUpdateSubviewContraints = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)initializeIvars {
    _titleFont = [DXFont dxDefaultFontWithSize:40.0/3];
    _normalTitleColor = DXRGBColor(111, 111, 111);
    _selectedTitleColor = DXCommonColor;
}

- (void)setupSubviews {
    _imageViewContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _imageViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    _labelViewContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _labelViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_imageViewContainer];
    [self addSubview:_labelViewContainer];
}

- (void)setupConstraints {
    //imageViewContainer.top = self.top
    NSLayoutConstraint * containerConstraint = [NSLayoutConstraint constraintWithItem:self.imageViewContainer
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    //imageViewContainer.leading = self.leading
    containerConstraint = [NSLayoutConstraint constraintWithItem:self.imageViewContainer
                                                       attribute:NSLayoutAttributeLeading
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeLeading
                                                      multiplier:1.0
                                                        constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    //imageViewContainer.width = self.width
    containerConstraint = [NSLayoutConstraint constraintWithItem:self.imageViewContainer
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1.0
                                                        constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    //labelViewContainer.leading = self.leading
    containerConstraint = [NSLayoutConstraint constraintWithItem:self.labelViewContainer
                                                       attribute:NSLayoutAttributeLeading
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeLeading
                                                      multiplier:1.0
                                                        constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    //labelViewContainer.width = self.width
    containerConstraint = [NSLayoutConstraint constraintWithItem:self.labelViewContainer
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1.0
                                                        constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    //labelViewContainer.top = imageViewContainer.bottom
    containerConstraint = [NSLayoutConstraint constraintWithItem:self.labelViewContainer
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.imageViewContainer
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                        constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    //labelViewContainer.bottom = self.bottom
    containerConstraint = [NSLayoutConstraint constraintWithItem:self.labelViewContainer
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                        constant:0];
    [self addConstraint:containerConstraint];
    [self.allConstraints addObject:containerConstraint];
    
    
    NSUInteger itemCount = self.imageViews.count;
    CGFloat halfCount = itemCount/2.0;
    CGFloat middleIndex = (itemCount-1)/2.0;
    for (int i = 0; i < self.imageViews.count; i++) {
        UIImageView * imageView = self.imageViews[i];
        //Top Constraint
        NSLayoutConstraint *  constraint = [NSLayoutConstraint constraintWithItem:imageView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.imageViewContainer
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:0];
        [self addConstraint:constraint];
        [self.allConstraints addObject:constraint];
        
        UIImage * image = imageView.image;
        if (image) {
            //Leading Constraint
            CGFloat offset = DXRealValue(image.size.width/2) * (i - halfCount) + self.itemSpace * (i - middleIndex) ;
            constraint = [NSLayoutConstraint constraintWithItem:imageView
                                                      attribute:NSLayoutAttributeLeading
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.imageViewContainer
                                                      attribute:NSLayoutAttributeCenterX
                                                     multiplier:1
                                                       constant:offset];
            [self addConstraint:constraint];
            [self.allConstraints addObject:constraint];
            
            //Width Constraint
            constraint = [NSLayoutConstraint constraintWithItem:imageView
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1
                                                       constant:DXRealValue(image.size.width/2)];
            [self addConstraint:constraint];
            [self.allConstraints addObject:constraint];
            
            //Height Constraint
            CGFloat aspect = image.size.height / image.size.width;
            constraint = [NSLayoutConstraint constraintWithItem:imageView
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:imageView
                                                      attribute:NSLayoutAttributeWidth
                                                     multiplier:aspect
                                                       constant:0];
            [self addConstraint:constraint];
            [self.allConstraints addObject:constraint];
        }
        
        //Bottom Constraint
        constraint = [NSLayoutConstraint constraintWithItem:self.imageViewContainer
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                     toItem:imageView
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0];
        [self addConstraint:constraint];
        [self.allConstraints addObject:constraint];
    }
    
    for (int i = 0; i < self.labels.count; i++) {
        UILabel * titleLabel = self.labels[i];
        UIImageView * imageView = [self.imageViews objectAtIndex:i];
        
        NSLayoutConstraint * constraint = nil;
        
        //Top Constraint
        constraint = [NSLayoutConstraint constraintWithItem:self.labelViewContainer
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                     toItem:titleLabel
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0];
        [self addConstraint:constraint];
        [self.allConstraints addObject:constraint];
        
        //Bottom Constraint
        constraint = [NSLayoutConstraint constraintWithItem:titleLabel
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.labelViewContainer
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0];
        [self addConstraint:constraint];
        [self.allConstraints addObject:constraint];
        
        //Center-X Constraint
        constraint = [NSLayoutConstraint constraintWithItem:titleLabel
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:imageView
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1.0
                                                   constant:0];
        [self addConstraint:constraint];
        [self.allConstraints addObject:constraint];
    }
}


- (NSMutableArray *)items {
    if (nil == _items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (NSMutableArray *)allConstraints {
    if (nil == _allConstraints) {
        _allConstraints = [NSMutableArray array];
    }
    return _allConstraints;
}

- (NSMutableArray *)imageViews {
    if (nil == _imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (NSMutableArray *)labels {
    if (nil == _labels) {
        _labels = [NSMutableArray array];
    }
    return _labels;
}

- (NSUInteger)itemCount {
    return self.imageViews.count;
}

- (void)addItemWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title{
    NSDictionary * itemInfo = @{
                                DXPhotoToolPanelItemImageKey            : image,
                                DXPhotoToolPanelItemSelectedImageKey    : selectedImage,
                                DXPhotoToolPanelItemTitleKey            : title
                                };
    [self addItemViewWithItemInfo:itemInfo];
}

- (void)deselectItemAtIndex:(NSInteger)index {
    [self setUnselectedAtIndex:index];
}

- (void)selectItemAtIndex:(NSInteger)index {
    [self setSelectedAtIndex:index];
}

- (void)addItemViewWithItemInfo:(NSDictionary *)itemInfo {
    UIImage * image = [itemInfo objectForKey:DXPhotoToolPanelItemImageKey];
    UIImage * selectedImage = [itemInfo objectForKey:DXPhotoToolPanelItemSelectedImageKey];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image highlightedImage:selectedImage];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString * title = [itemInfo objectForKey:DXPhotoToolPanelItemTitleKey];
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.textColor = self.normalTitleColor;
    titleLabel.font = self.titleFont;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLabel sizeToFit];
    
    [self.imageViews addObject:imageView];
    [self.labels addObject:titleLabel];
    
    [self.imageViewContainer addSubview:imageView];
    [self.labelViewContainer addSubview:titleLabel];
    
    self.needsToUpdateSubviewContraints = YES;
}

- (void)updateConstraints {
    if (self.needsToUpdateSubviewContraints) {
        [self removeConstraints:self.allConstraints];
        [self setupConstraints];
        self.needsToUpdateSubviewContraints = NO;
    }
    
    [super updateConstraints];
}


- (void)setSelectedAtIndex:(NSInteger)index {
    UIImageView * imageView = self.imageViews[index];
    [imageView setHighlighted:YES];
    
    UILabel * titleLabel = self.labels[index];
    titleLabel.textColor = self.selectedTitleColor;    
}

- (void)setUnselectedAtIndex:(NSInteger)index {
    UIImageView * imageView = self.imageViews[index];
    [imageView setHighlighted:NO];
    
    UILabel * titleLabel = self.labels[index];
    titleLabel.textColor = self.normalTitleColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView * imageView = self.imageViews[i];
        UILabel * titleLabel = self.labels[i];
        
        CGRect imageViewFrame = [self convertRect:imageView.bounds fromView:imageView];
        CGRect labelFrame = [self convertRect:titleLabel.bounds fromView:titleLabel];
        
        CGFloat minX = MIN(CGRectGetMinX(imageViewFrame), CGRectGetMinX(labelFrame));
        CGFloat minY = MIN(CGRectGetMinY(imageViewFrame), CGRectGetMinY(labelFrame));
        CGFloat maxX = MAX(CGRectGetMaxX(imageViewFrame), CGRectGetMaxX(labelFrame));
        CGFloat maxY = MAX(CGRectGetMaxY(imageViewFrame), CGRectGetMaxY(labelFrame));
        
        if (point.x >= minX && point.x <= maxX &&
            point.y >= minY && point.y <= maxY) {
            [self setSelectedAtIndex:i];
            self.selectedIndex = i;
            break;
        } else {
            self.selectedIndex = -1;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self setUnselectedAtIndex:self.selectedIndex];
    self.selectedIndex = -1;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.selectedIndex >= 0 && self.delegate && [self.delegate respondsToSelector:@selector(photoToolPanel:didSelectAtIndex:)]) {
        [self.delegate photoToolPanel:self didSelectAtIndex:self.selectedIndex];
    }
}

@end
