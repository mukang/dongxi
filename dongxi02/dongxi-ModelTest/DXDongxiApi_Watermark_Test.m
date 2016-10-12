//
//  DXDongxiApi_Watermark_Test.m
//  dongxi
//
//  Created by Xu Shiwen on 16/1/27.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DXDongXiApi.h"

@interface DXDongxiApi_Watermark_Test : XCTestCase

@end

@implementation DXDongxiApi_Watermark_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCheckWatermarks {
    XCTestExpectation * expection = [self expectationWithDescription:@"等待服务器响应"];
    
    [[DXDongXiApi api] checkWatermarksWithTimestamp:0 result:^(NSArray *watermarks, NSInteger timestamp, NSError *error) {
        [expection fulfill];
        XCTAssert(error == nil);
        XCTAssert(watermarks != nil);
        XCTAssert(timestamp >= 0);
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
