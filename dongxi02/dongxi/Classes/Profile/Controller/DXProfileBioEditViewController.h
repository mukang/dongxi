//
//  DXProfileBioEditViewController.h
//  dongxi
//
//  Created by Xu Shiwen on 15/11/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DXProfileBioDidChangeHandler)(NSString * bioText);

@interface DXProfileBioEditViewController : UIViewController

@property (nonatomic, copy) NSString * bioText;
@property (nonatomic, assign) NSUInteger maxBioTextCount;

@property (nonatomic, copy) DXProfileBioDidChangeHandler bioDidChangeHandler;

@end

