//
//  DXTopicDiscussAskViewController.m
//  dongxi
//
//  Created by 穆康 on 16/7/1.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXTopicDiscussAskViewController.h"

@interface DXTopicDiscussAskViewController ()

@end

@implementation DXTopicDiscussAskViewController {
    DXBarButtonItem *_submitItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _submitItem = [[DXBarButtonItem alloc] init];
    [_submitItem setTitle:@"提交"];
    [_submitItem setTarget:self];
    [_submitItem setAction:@selector(submitItemTapped:)];
    [self.navigationItem setRightBarButtonItem:_submitItem];
}

- (void)submitItemTapped:(DXBarButtonItem *)sender {
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"ioSubmitQuestion()"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
