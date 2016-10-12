//
//  DXDongXiApi_Topic_Test.m
//  dongxi
//
//  Created by Xu Shiwen on 15/11/9.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXDongXiApi.h"

@interface DXDongXiApi_Topic_Test : XCTestCase

@property (nonatomic, strong) DXDongXiApi * api;

@end

@implementation DXDongXiApi_Topic_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.api = [DXDongXiApi api];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetTopicFollowList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期得到话题邀请关注列表接口响应"];
    
    //topic: 26, user: 616, ID: [43, 25, 24, 23]
    [self.api getTopicInviteFollowList:@"26" ofUser:@"616" pullType:DXDataListPullNewerList count:10 lastID:@"43" result:^(DXTopicInviteFollowList *followList, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(followList.top != nil);
        XCTAssert(followList.list != nil);
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
