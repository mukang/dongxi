//
//  DXImagePlayerViewController.h
//  dongxi
//
//  Created by 穆康 on 15/8/8.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXPictureShowWrapper.h"

@interface DXImagePlayerViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *imageUrls;

@property (nonatomic, strong) DXPictureShowWrapper *pictureShowWrapper;

@end
