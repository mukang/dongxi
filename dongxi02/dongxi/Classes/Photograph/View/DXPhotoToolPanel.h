//
//  DXPhotoToolPanel.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXPhotoToolItem;
@protocol DXPhotoToolPanelDelegate;


@interface DXPhotoToolPanel : UIView

@property (nonatomic, assign) CGFloat itemSpace;
@property (nonatomic, readonly) NSUInteger itemCount;
@property (nonatomic, weak) id<DXPhotoToolPanelDelegate> delegate;

/**
 *  添加item，指定图片、选中状态图片、标题，状态
 *
 *  @param image         item图片
 *  @param selectedImage item选中状态图片
 *  @param title         标题
 */
- (void)addItemWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title;

- (void)deselectItemAtIndex:(NSInteger)index;
- (void)selectItemAtIndex:(NSInteger)index;


@end


@protocol DXPhotoToolPanelDelegate <NSObject>

- (void)photoToolPanel:(DXPhotoToolPanel *)toolPanel didSelectAtIndex:(NSInteger)index;

@end