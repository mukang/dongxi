//
//  DXDongXiApi_Activity_Test.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/26.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "DXDongXiApi.h"

@interface DXDongXiApi_Activity_Test : XCTestCase

@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, assign) NSTimeInterval maxWaitTime;

@end

@implementation DXDongXiApi_Activity_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.api = [DXDongXiApi api];
    self.maxWaitTime = 5.0;
    
//    if ([self.api needLogin]) {
//        XCTestExpectation * expectation = [self expectationWithDescription:@"Expect login successfully"];
//        
//        DXUserLoginInfo * loginInfo = [DXUserLoginInfo new];
//        [loginInfo setAccountInfoWithMobile:@"18612828490" andPassword:@"123456"];
//        [self.api login:loginInfo result:^(DXUserSession *user, NSError *error) {
//            XCTAssert(user != nil, @"user不为nil时登录成功");
//            [expectation fulfill];
//        }];
//        
//        [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
//            if (error) {
//                XCTFail(@"Expectation Failed with error: %@", error);
//            }
//        }];
//    } else {
//        NSLog(@"使用已有会话信息进行登录");
//    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testActivityList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get activity list successfully"];
    
    [self.api getActivityList:^(NSArray *activityList, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(error == nil, @"获取数据时未发生错误");
        XCTAssert(activityList != nil, @"获取的数据不为nil");
        
        if (activityList.count > 0) {
            DXActivity * activity = [activityList firstObject];
            [self validateDXActivity:activity];
        }
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testGetAcitvity {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期得到活动详情接口响应"];
    
    [self.api getActivityByID:@"102" result:^(DXActivity *activity, NSError *error) {
        [expectation fulfill];
        
        if (activity) {
            [self validateDXActivity:activity];
        }
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testDiscoverGetUserList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期得到发现找人接口响应"];
    
    [self.api getDiscoverUserList:20 pullType:DXDataListPullFirstTime lastID:nil result:^(DXDiscoverUserWrapper *userWrapper, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(userWrapper != nil, @"找人结果不应为nil");
        XCTAssert(userWrapper.list.count == userWrapper.count, @"找人结果列表数量应等于其count数量");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)validateDXActivity:(DXActivity *)activity {
    XCTAssert([activity isKindOfClass:[DXActivity class]], @"传入的参数确实为DXActivity对象");
    XCTAssert([activity.activity_id isKindOfClass:[NSString class]], @"activity_id属性是NSString对象");
    XCTAssert([activity.detail isKindOfClass:[DXActivityDetail class]], @"detail属性是DXActivityDetail对象");
}

@end
