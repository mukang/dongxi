//
//  DXCompatibleAlert.m
//  dongxi
//
//  Created by Xu Shiwen on 15/10/28.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXCompatibleAlert.h"

typedef void(^DXCompatibleAlertActionHandler)(DXCompatibleAlertAction *);
typedef void(^DXCompatibleAlertAnimatedCompletionHandler)(void);

@interface DXCompatibleAlertAction()

@property (nonatomic, assign) NSInteger compatibleIndex;
@property (nonatomic, weak) id standardAlertAction;
@property (nonatomic, copy) DXCompatibleAlertActionHandler handler;

@end


@implementation DXCompatibleAlertAction {
    NSString * _title;
    DXCompatibleAlertActionStyle _style;
}

+ (instancetype)actionWithTitle:(NSString *)title style:(DXCompatibleAlertActionStyle)style handler:(void (^)(DXCompatibleAlertAction *))handler {
    DXCompatibleAlertAction * alertAction = [[[self class] alloc] init];
    alertAction->_title = title;
    alertAction->_style = style;
    alertAction->_handler = handler;
    alertAction->_enabled = YES;
    alertAction->_compatibleIndex = -1;
    return alertAction;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    if (self.standardAlertAction && [self.standardAlertAction respondsToSelector:@selector(setEnabled:)]) {
        [self.standardAlertAction setEnabled:enabled];
    }
}

@end


@interface DXCompatibleAlert()

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet;
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)didPresentAlertView:(UIAlertView *)alertView;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end


@implementation DXCompatibleAlert {
    DXCompatibleAlertStyle _preferredStyle;
    CGFloat _systemVersion;
    NSMutableArray * _compatibleActions;
    DXCompatibleAlertAction * _compatibleCancelAction;
    DXCompatibleAlertAction * _compatibleDestructiveAction;
    NSMutableArray * _standardAlertActions;
    DXCompatibleAlertAnimatedCompletionHandler _alertShowCompletion;
    
    __weak id _alertView;
    __weak id _acitionView;
}

+ (instancetype)compatibleAlertWithPreferredStyle:(DXCompatibleAlertStyle)style {
    DXCompatibleAlert * alert = [[DXCompatibleAlert alloc] initWithStyle:style];
    return alert;
}

- (instancetype)initWithStyle:(DXCompatibleAlertStyle)style {
    self = [super init];
    if (self) {
        _preferredStyle = style;
        _systemVersion = DXSystemVersion;
        _compatibleActions = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    if (_alertView && [_alertView respondsToSelector:@selector(setDelegate:)]) {
        [_alertView setDelegate:nil];
    }
    
    if (_acitionView && [_acitionView respondsToSelector:@selector(setDelegate:)]) {
        [_acitionView setDelegate:nil];
    }
}

- (void)addAction:(DXCompatibleAlertAction *)action {
    [_compatibleActions addObject:action];
}

- (NSArray *)actions {
    return [_compatibleActions copy];
}

- (void)prepareActions {
    _standardAlertActions = [NSMutableArray array];

    for (DXCompatibleAlertAction * action in _compatibleActions) {
        id standardAlertAction = [self standardAlertActionFromCompatibleAction:action];
        if (standardAlertAction) {
            [_standardAlertActions addObject:standardAlertAction];
        }
        
        if (action.style == DXCompatibleAlertActionStyleCancel) {
            _compatibleCancelAction = action;
        }
        
        if (action.style == DXCompatibleAlertActionStyleDestructive) {
            _compatibleDestructiveAction = action;
        }
    }
}

- (id)standardAlertActionFromCompatibleAction:(DXCompatibleAlertAction *)compatibleAction {
    Class AlertActionClass = NSClassFromString(@"UIAlertAction");
    if (AlertActionClass) {
        UIAlertAction * standardAction = [UIAlertAction actionWithTitle:compatibleAction.title
                                                                  style:(NSInteger)compatibleAction.style
                                                                handler:^(UIAlertAction *action) {
                                                                    if (compatibleAction.handler) {
                                                                        compatibleAction.handler(compatibleAction);
                                                                    }
                                                                }];
        standardAction.enabled = compatibleAction.enabled;
        compatibleAction.standardAlertAction = standardAction;
        return standardAction;
    } else {
        return nil;
    }
}

- (UIWindow *)prepareDisplayWindow {
    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [[UIViewController alloc] init];
    window.windowLevel = UIWindowLevelAlert+1;
    return window;
}

- (void)showInController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion {
    [self prepareActions];
    
    if (self.preferredStyle == DXCompatibleAlertStyleActionSheet) {
        Class AlertControllerClass = NSClassFromString(@"UIAlertController");
        if (AlertControllerClass) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleActionSheet];
            for (UIAlertAction * action in _standardAlertActions) {
                [alertController addAction:action];
            }
            UIWindow * window = [self prepareDisplayWindow];
            [window makeKeyAndVisible];
            [window.rootViewController presentViewController:alertController animated:animated completion:completion];
        } else {
            [self showAsUIActionSheetInController:controller animated:animated completion:completion];
        }
    }
    
    if (self.preferredStyle == DXCompatibleAlertStyleAlert) {
        Class AlertControllerClass = NSClassFromString(@"UIAlertController");
        if (AlertControllerClass) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleAlert];
            for (UIAlertAction * action in _standardAlertActions) {
                [alertController addAction:action];
            }
            UIWindow * window = [self prepareDisplayWindow];
            [window makeKeyAndVisible];
            [window.rootViewController presentViewController:alertController animated:animated completion:completion];
        } else {
            [self showAsUIAlertViewInController:controller animated:animated completion:completion];
        }
    }
}

- (void)showAsUIActionSheetInController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion {
    if (controller) {
        /**
         *  使用第一个window来retain住当前实例
         *  @author Xu Shiwen
         *  @date   29/10/2015
         */
        UIWindow * firstWindow = [[[UIApplication sharedApplication] windows] firstObject];
        [firstWindow addSubview:self];
        
        _alertShowCompletion = completion;
        Class ActionSheetClass = NSClassFromString(@"UIActionSheet");
        if (ActionSheetClass) {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:self.title
                                                       delegate:(id<UIActionSheetDelegate>)self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:_compatibleDestructiveAction.title
                                              otherButtonTitles:nil];
            NSInteger cancelButtonIndex = -1;
            for (DXCompatibleAlertAction * action in _compatibleActions) {
                if (action == _compatibleCancelAction || action == _compatibleDestructiveAction) {
                    continue;
                }
                NSInteger index = [actionSheet addButtonWithTitle:action.title];
                action.compatibleIndex = index;
            }
            
            /***************************************************************
             *  不能在初始化UIActionSheet时指定cancelButtonTitle
             *  在iOS7下这样会导致cancelButton不在最后排，且无透明
             *  间隔，解决办法就是最后添加cancelButton，并设置相应的
             *  cancelButtonIndex
             *
             *  @author Xu Shiwen
             *  @date   28/10/2015
             ***************************************************************/
            if (_compatibleCancelAction) {
                cancelButtonIndex = [actionSheet addButtonWithTitle:_compatibleCancelAction.title];
                [actionSheet setCancelButtonIndex:cancelButtonIndex];
            }
            
            [actionSheet showFromRect:controller.view.bounds inView:controller.view animated:animated];
        }
    }
}

- (void)showAsUIAlertViewInController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion {
    if (controller) {
        /**
         *  使用第一个window来retain住当前实例
         *  @author Xu Shiwen
         *  @date   29/10/2015
         */
        UIWindow * firstWindow = [[[UIApplication sharedApplication] windows] firstObject];
        [firstWindow addSubview:self];
        
        _alertShowCompletion = completion;
        Class AlertViewClass = NSClassFromString(@"UIAlertView");
        if (AlertViewClass) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                    message:self.message
                                                   delegate:(id<UIAlertViewDelegate>)self
                                          cancelButtonTitle:_compatibleCancelAction.title
                                          otherButtonTitles:nil];
            for (DXCompatibleAlertAction * action in _compatibleActions) {
                if (action == _compatibleCancelAction) {
                    continue;
                }
                NSInteger index = [alertView addButtonWithTitle:action.title];
                action.compatibleIndex = index;
            }
            [alertView show];
        }
    }
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        if (_compatibleCancelAction && _compatibleCancelAction.handler) {
            _compatibleCancelAction.handler(_compatibleCancelAction);
        }
    } else if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        if (_compatibleDestructiveAction && _compatibleDestructiveAction.handler) {
            _compatibleDestructiveAction.handler(_compatibleDestructiveAction);
        }
    } else {
        for (DXCompatibleAlertAction * action in _compatibleActions) {
            if (action.compatibleIndex == buttonIndex && action.handler) {
                action.handler(action);
                break;
            }
        }
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    if (_alertShowCompletion) {
        _alertShowCompletion();
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self removeFromSuperview];
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if (_compatibleCancelAction.handler) {
            _compatibleCancelAction.handler(_compatibleCancelAction);
        }
    } else {
        for (DXCompatibleAlertAction * action in _compatibleActions) {
            if (action.compatibleIndex == buttonIndex && action.handler) {
                action.handler(action);
                break;
            }
        }
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    if (_alertShowCompletion) {
        _alertShowCompletion();
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self removeFromSuperview];
}

@end
