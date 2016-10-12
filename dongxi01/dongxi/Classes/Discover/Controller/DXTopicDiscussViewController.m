//
//  DXTopicDiscussViewController.m
//  dongxi
//
//  Created by 穆康 on 16/6/29.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicDiscussViewController.h"
#import "DXLoginViewController.h"

@interface DXTopicDiscussViewController ()

@end

@implementation DXTopicDiscussViewController {
    DXBarButtonItem * _replyItem;
}

- (UIViewController *)initWithRouteParams:(NSDictionary *)params {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.showControls = NO;
        self.url = [params objectForKey:@"url"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _replyItem = [[DXBarButtonItem alloc] init];
    [_replyItem setTitle:@"提问"];
    [_replyItem setTarget:self];
    [_replyItem setAction:@selector(replyItemTapped:)];
    [self.navigationItem setRightBarButtonItem:_replyItem];
}

- (void)replyItemTapped:(DXBarButtonItem *)sender {
    __weak typeof(self) weakSelf = self;
    if ([[DXDongXiApi api] needLogin]) {
        DXCompatibleAlert * alert = [DXCompatibleAlert compatibleAlertWithPreferredStyle:DXCompatibleAlertStyleAlert];
        [alert setTitle:@""];
        [alert setMessage:@"登录后才可提问，是否现在就登录/注册？"];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"否" style:DXCompatibleAlertActionStyleCancel handler:nil]];
        [alert addAction:[DXCompatibleAlertAction actionWithTitle:@"是" style:DXCompatibleAlertActionStyleDefault handler:^(DXCompatibleAlertAction *action) {
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[[DXLoginViewController alloc] init]];
            loginNav.navigationBar.hidden = YES;
            [weakSelf presentViewController:loginNav animated:YES completion:nil];
        }]];
        [alert showInController:self animated:YES completion:nil];
        return;
    } else {
        [self insertJS];
    }
}

- (void)insertJS {
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"iosQuestion()"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
