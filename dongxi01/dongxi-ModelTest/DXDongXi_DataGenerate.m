//
//  DXDongXi_DataGenerate.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DXDongXiApi.h"

@interface DXDongXi_DataGenerate : XCTestCase

@end

@implementation DXDongXi_DataGenerate

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testGenerateUsers {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user register result"];
    
    NSLog(@"用户创建任务开始");
    
    dispatch_group_t group = dispatch_group_create();
    
    NSArray * users = @[
// //示例。注：创建好的数据不要留在这里，避免被当作测试用例执行
//                        @{
//                            @"username": @"于快",
//                            @"password": @"dongxi365",
//                            @"mobile": @"10000000025",
//                            @"gender": @(DXUserGenderTypeMale)
//                            },
                        ];
    
    for (NSDictionary * userInfo in users) {
        NSString * username = [userInfo objectForKey:@"username"];
        NSString * password = [userInfo objectForKey:@"password"];
        NSString * mobile = [userInfo objectForKey:@"mobile"];
        DXUserGenderType gender = [[userInfo objectForKey:@"gender"] integerValue];
        
        DXUserRegisterInfo * registerInfo = [DXUserRegisterInfo new];
        registerInfo.username = username;
        registerInfo.password = password;
        registerInfo.mobile = mobile;
        registerInfo.gender = gender;
        
        dispatch_group_enter(group);
        [[DXDongXiApi api] registerUser:registerInfo result:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"用户(用户名:%@, 密码:%@, 手机:%@, 性别:%d)已创建", username, password, mobile, gender);
            } else {
                NSLog(@"用户(用户名:%@, 密码:%@, 手机:%@, 性别:%d)创建失败: %@", username, password, mobile, gender, error.localizedDescription);
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [expectation fulfill];
        NSLog(@"用户创建任务结束");
    });
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
