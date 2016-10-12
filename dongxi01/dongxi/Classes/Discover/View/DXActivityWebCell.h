//
//  DXActivityWebCell.h
//  dongxi
//
//  Created by Xu Shiwen on 15/9/17.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXActivityWebCellDelegate;



@interface DXActivityWebCell : UICollectionViewCell

@property (nonatomic, weak) id<DXActivityWebCellDelegate> delegate;

@property (nonatomic, copy) NSString * introText;
@property (nonatomic, copy) NSString * fullTextHtml;
@property (nonatomic, assign) BOOL showFullText;

- (void)afterWebContentLoaded:(void(^)(void))loadCallBack;
- (CGFloat)getFittingHeight;

@end



@protocol DXActivityWebCellDelegate <NSObject>

@optional
- (void)webCell:(DXActivityWebCell *)cell willShowFullText:(BOOL)showFullText;

@end