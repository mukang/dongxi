//
//  DXWatermarkManagerTest.m
//  dongxi
//
//  Created by Xu Shiwen on 16/1/28.
//  Copyright © 2016年 北京聚益网络科技有限公司. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DXWatermark.h"

@interface DXWatermarkManagerTest : XCTestCase

@end

@implementation DXWatermarkManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadWatermarks {
    XCTestExpectation * expectation = [self expectationWithDescription:@"等待block回调"];
    
    __block int count = 0;
        
    [[DXWatermarkManager sharedManager] loadWatermarks:^(NSArray *watermarks, DXWatermarkSourceType sourceType, NSError *error) {
        count++;
        if (count == 2) {
            [expectation fulfill];
        }
        for (DXWatermark * watermark in watermarks) {
            if (sourceType == DXWatermarkSourceLocal) {
                NSLog(@"%@, %@, %@", watermark.comment, watermark.imageName, watermark.thumbName);
            } else {
                NSLog(@"%@, %@, %@", watermark.comment, watermark.imageURLForCurrentScreen, watermark.thumbURLForCurrentScreen);
            }
        }
        XCTAssert(error == nil);
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}



@end
