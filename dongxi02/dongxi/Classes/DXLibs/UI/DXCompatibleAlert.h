//
//  DXCompatibleActionSheet.h
//  dongxi
//
//  Created by Xu Shiwen on 15/10/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DXCompatibleAlertActionStyle) {
    DXCompatibleAlertActionStyleDefault = 0,
    DXCompatibleAlertActionStyleCancel,
    DXCompatibleAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, DXCompatibleAlertStyle) {
    DXCompatibleAlertStyleActionSheet = 0,
    DXCompatibleAlertStyleAlert,
};

/**
 *  DXCompatibleAlertAction，用于兼容iOS 7.0的UIAlertAction
 */
@interface DXCompatibleAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(DXCompatibleAlertActionStyle)style handler:(void (^)(DXCompatibleAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) DXCompatibleAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end



/**
 *  DXCompatibleAlert，用于兼容iOS 7.0和8.0的UIAlertView、UIActionSheet
 *
 *  @discussion 如果项目的target版本是8.0或以上，请直接使用UIAlertController
 */
@interface DXCompatibleAlert : UIView

+ (instancetype)compatibleAlertWithPreferredStyle:(DXCompatibleAlertStyle)style;

/**
 * 标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  消息
 *
 *  @discussion 重要！若使用DXCompatibleAlertStyleActionSheet风格，iOS 8.0以下的设备会不显示message
 */
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) DXCompatibleAlertStyle preferredStyle;
@property (nonatomic, readonly) NSArray *actions;

- (void)addAction:(DXCompatibleAlertAction *)action;

- (void)showInController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion;


@end
