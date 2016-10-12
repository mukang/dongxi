//
//  DXTagAlertView.m
//  dongxi
//
//  Created by 穆康 on 16/3/10.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTagAlertView.h"
#import "DXTagChooseView.h"
#import <CoreText/CoreText.h>

@interface DXTagAlertView () <DXTagChooseViewDelegate>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *topContainerView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, weak) UIView *separateView;
@property (nonatomic, weak) DXTagChooseView *chooseView;
@property (nonatomic, weak) UIButton *changeButton;
@property (nonatomic, weak) UIButton *completionButton;

@property (nonatomic, strong) NSMutableArray *tags;
/** 变化的标签 */
@property (nonatomic, strong) NSMutableArray *changeTags;

@end

@implementation DXTagAlertView {
    __weak DXTagAlertView *_weakSelf;
    __weak UIViewController *_controller;
}

- (instancetype)initWithController:(UIViewController *)controller {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _weakSelf = self;
        _controller = controller;
        [self setup];
    }
    return self;
}

- (void)setup {
    
    [_controller.view addSubview:self];
    self.frame = _controller.view.bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 容器view
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.size = CGSizeMake(DXRealValue(351), DXRealValue(445));
    containerView.centerX = self.width * 0.5;
    containerView.centerY = self.height + containerView.height * 0.5;
    [self addSubview:containerView];
    
    // 顶部容器view
    UIView *topContainerView = [[UIView alloc] init];
    topContainerView.backgroundColor = DXRGBColor(240, 240, 240);
    topContainerView.frame = CGRectMake(0, 0, containerView.width, DXRealValue(103));
    [containerView addSubview:topContainerView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"选择符合你的标签";
    titleLabel.textColor = DXRGBColor(72, 72, 72);
    titleLabel.font = [DXFont dxDefaultBoldFontWithSize:83/3.0];
    [titleLabel sizeToFit];
    titleLabel.centerX = topContainerView.width * 0.5;
    titleLabel.y = DXRealValue(29);
    [topContainerView addSubview:titleLabel];
    
    // 副标题
    UILabel *subTitleLabel = [[UILabel alloc] init];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"定制属于你的专属体验"];
    long number = 6.0f;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [attrStr addAttributes:@{
                             NSForegroundColorAttributeName : DXRGBColor(72, 72, 72),
                             NSFontAttributeName            : [DXFont dxDefaultFontWithSize:47/3.0],
                             (id)kCTKernAttributeName       : (__bridge id)num
                             }
                     range:NSMakeRange(0, attrStr.length)];
    CFRelease(num);
    [subTitleLabel setAttributedText:attrStr];
    [subTitleLabel sizeToFit];
    subTitleLabel.centerX = titleLabel.centerX + 3;
    subTitleLabel.y = DXRealValue(187/3.0);
    [topContainerView addSubview:subTitleLabel];
    
    // 分割线
    UIView *separateView = [[UIView alloc] init];
    separateView.backgroundColor = DXRGBColor(72, 72, 72);
    separateView.size = CGSizeMake(titleLabel.width, 0.5);
    separateView.centerX = titleLabel.centerX;
    separateView.y = DXRealValue(179/3.0);
    [topContainerView addSubview:separateView];
    
    // 标签
    DXTagChooseView *chooseView = [[DXTagChooseView alloc] init];
    chooseView.size = CGSizeMake(containerView.width, DXRealValue(220));
    chooseView.centerX = containerView.width * 0.5;
    chooseView.y = CGRectGetMaxY(topContainerView.frame);
    chooseView.delegate = self;
    [containerView addSubview:chooseView];
    
    // 换一批
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setImage:[UIImage imageNamed:@"tag_change_button"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(handleClickChangeButton:) forControlEvents:UIControlEventTouchUpInside];
    changeButton.size = CGSizeMake(DXRealValue(222/3.0), DXRealValue(56/3.0));
    changeButton.x = containerView.width - DXRealValue(18) - changeButton.width;
    changeButton.y = DXRealValue(985/3.0);
    [containerView addSubview:changeButton];
    
    // 完成
    UIButton *completionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [completionButton setImage:[UIImage imageNamed:@"tag_completion_button_normal"] forState:UIControlStateNormal];
    [completionButton setImage:[UIImage imageNamed:@"tag_completion_button_highlighted"] forState:UIControlStateHighlighted];
    [completionButton addTarget:self action:@selector(handleClickCompletionButton:) forControlEvents:UIControlEventTouchUpInside];
    completionButton.size = CGSizeMake(DXRealValue(280/3.0), DXRealValue(109/3.0));
    completionButton.centerX = containerView.width * 0.5;
    completionButton.y = DXRealValue(1187/3.0);
    [containerView addSubview:completionButton];
    
    self.containerView = containerView;
    self.topContainerView = topContainerView;
    self.titleLabel = titleLabel;
    self.subTitleLabel = subTitleLabel;
    self.separateView = separateView;
    self.chooseView = chooseView;
    self.changeButton = changeButton;
    self.completionButton = completionButton;
    
    [self loadNetData];
}

- (void)show {
    
    [UIView animateWithDuration:0.2 animations:^{
        _weakSelf.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        _weakSelf.containerView.centerY = _weakSelf.height * 0.5;
    }];
}

- (void)dismiss {
    
    [UIView animateWithDuration:0.2 animations:^{
        _weakSelf.backgroundColor = [UIColor clearColor];
        _weakSelf.containerView.centerY = _weakSelf.height + _weakSelf.containerView.height * 0.5;
    } completion:^(BOOL finished) {
        [_weakSelf removeFromSuperview];
    }];
}

- (void)loadNetData {
    
    [[DXDongXiApi api] getTagWrapper:^(DXTagWrapper *tagWrapper, NSError *error) {
        if (tagWrapper.all.count) {
            [_weakSelf.tags addObjectsFromArray:tagWrapper.all];
            [_weakSelf.chooseView setTags:tagWrapper.all withRect:_weakSelf.chooseView.frame];
        }
    }];
}

#pragma mark - DXTagChooseViewDelegate

- (void)tagChooseView:(DXTagChooseView *)view didShowTagsWithRange:(NSRange)range {
    
    NSArray *tempArray = [self.tags subarrayWithRange:range];
    [self.tags removeObjectsInRange:range];
    [self.tags addObjectsFromArray:tempArray];
}

- (void)tagChooseView:(DXTagChooseView *)view didTapTagWitNormalTag:(DXTag *)normalTag {
    
    if (normalTag.status && ![self.changeTags containsObject:normalTag]) {
        [self.changeTags addObject:normalTag];
    }
}

#pragma mark - 处理点击事件

- (void)handleClickChangeButton:(UIButton *)button {
    [_weakSelf.chooseView setTags:_weakSelf.tags withRect:_weakSelf.chooseView.frame];
}

- (void)handleClickCompletionButton:(UIButton *)button {
    
    if (self.changeTags.count) {
        NSMutableArray *createTagIDs = [NSMutableArray array];
        for (DXTag *tag in self.changeTags) {
            [createTagIDs addObject:tag.ID];
        }
        [[DXDongXiApi api] changeTagRelationWithCreateTagIDs:createTagIDs deleteTageIDs:nil result:nil];
    }
    
    [self dismiss];
}

#pragma mark - 懒加载

- (NSMutableArray *)tags {
    if (_tags == nil) {
        _tags = [[NSMutableArray alloc] init];
    }
    return _tags;
}

- (NSMutableArray *)changeTags {
    if (_changeTags == nil) {
        _changeTags = [[NSMutableArray alloc] init];
    }
    return _changeTags;
}

@end
