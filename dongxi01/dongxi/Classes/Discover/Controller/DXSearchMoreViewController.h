//
//  DXSearchMoreViewController.h
//  dongxi
//
//  Created by 穆康 on 16/1/25.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXSearchMoreType) {
    DXSearchMoreTypeTopic,
    DXSearchMoreTypeUser,
    DXSearchMoreTypeActivity,
    DXSearchMoreTypeFeed
};

@interface DXSearchMoreViewController : UIViewController

@property (nonatomic, copy) NSString *keywords;

@property (nonatomic, assign, readonly) DXSearchMoreType searchMoreType;

- (instancetype)initWithSearchMoreType:(DXSearchMoreType)searchMoreType;

@end
