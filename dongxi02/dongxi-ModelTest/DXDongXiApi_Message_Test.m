//
//  DXDongXiApi_Message_Test.m
//  dongxi
//
//  Created by Xu Shiwen on 15/9/1.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXDongXiApi.h"
#import "DXClientImport.h"
#import "NSObject+DXModel.h"

@interface DXDongXiApi_Message_Test : XCTestCase

@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, assign) NSTimeInterval maxWaitTime;

@end

@implementation DXDongXiApi_Message_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.api = [DXDongXiApi api];
    self.maxWaitTime = 5.0;
    
    if ([self.api needLogin]) {
        XCTestExpectation * expectation = [self expectationWithDescription:@"Expect login successfully"];
        
        DXUserLoginInfo * loginInfo = [DXUserLoginInfo new];
        [loginInfo setAccountInfoWithMobile:@"13520166164" andPassword:@"123456"];
        [self.api login:loginInfo result:^(DXUserSession *user, NSError *error) {
            XCTAssert(user != nil, @"user不为nil时登录成功");
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
            if (error) {
                XCTFail(@"Expectation Failed with error: %@", error);
            }
        }];
    } else {
        NSLog(@"使用已有会话信息进行登录");
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoticeList {
    // This is an example of a functional test case.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get notice list successfully"];
    
    [self.api getMessageNoticeList:20 pullType:DXDataListPullFirstTime lastID:nil result:^(DXNoticeList *noticeList, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(noticeList != nil, @"正常获取列表");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testSendDiscussMsg {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect sendDiscussMsg successfully"];
    
    [self.api sendDiscussMsgToUserID:@"619" withText:@"nihaoa哈哈" msgType:DXDiscussMsgTypeText isOline:YES result:^(BOOL success, NSError *error) {
        
        [expectation fulfill];
        
        XCTAssert(success == YES, @"发送成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testGetMessageDiscussList {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect getMessageDiscussList successfully"];
    
    [self.api getMessageDiscussList:10 pullType:DXDataListPullFirstTime lastID:nil getCount:0 result:^(DXMessageDiscussList *messageDiscussList, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(messageDiscussList.count != 0, @"正常获取私聊列表(有聊天记录的情况)");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testGetDiscussListByUser {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect getDiscussListByUser successfully"];
    
    [self.api getDiscussListByUserID:@"614" count:10 pullType:DXDataListPullFirstTime lastID:nil result:^(DXDiscussList *discussList, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(discussList.count != 0, @"正常获取聊天记录列表(有聊天记录的情况)");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testDeleteMessageDiscuss {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect deleteMessageDiscuss successfully"];
    
    [self.api deleteMessageDiscussByUserID:@"614" result:^(BOOL success, NSError *error) {
        
        [expectation fulfill];
        
        XCTAssert(success == YES, @"删除成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testSetMessageDiscussRead {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect setMessageDiscussRead successfully"];
    
    [self.api messageDiscussSetReadByUserID:@"617" result:^(BOOL success, NSError *error) {
       
        [expectation fulfill];
        
        XCTAssert(success == YES, @"设置已读成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
