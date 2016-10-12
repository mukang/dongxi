//
//  DXTableView.h
//  dongxi
//
//  Created by Xu Shiwen on 15/8/24.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXTableViewDelegate;


@interface DXTableView : UITableView

@property (nonatomic, weak) UIView<DXTableViewDelegate> * touchEventDelegate;
@property (nonatomic, assign) CGSize minContentSize;

@end


@protocol DXTableViewDelegate <NSObject>

@optional
- (BOOL)shouldTableView:(DXTableView *)tableView respondToEvent:(UIEvent *)event atPoint:(CGPoint)point;

@end