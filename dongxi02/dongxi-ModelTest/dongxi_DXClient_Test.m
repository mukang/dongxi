//
//  DXClient_Test.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/11.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXClientImport.h"

@interface DXClient_Test : XCTestCase

@end

@implementation DXClient_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testClient {
    DXClient * client = [DXClient client];
    XCTAssert(client);
}

- (void)testClientRequest {
    NSArray * apiList = @[
                          DXClientAPi_UserChangeAvatar,
                          DXClientAPi_UserChangeCover,
                          DXClientAPi_UserChangeProfile,
                          DXClientAPi_UserChangePwd,
                          DXClientAPi_UserCheckSms,
                          DXClientAPi_UserFansList,
                          DXClientAPi_UserFollow,
                          DXClientAPi_UserFollowList,
                          DXClientApi_UserLogin,
                          DXClientApi_UserLogout,
                          DXClientAPi_UserProfile,
                          DXClientApi_UserRegister,
                          DXClientAPi_UserResetPwd,
                          DXClientAPi_UserResetSendSms,
                          DXClientApi_UserSendSms,
                          DXClientAPi_UserUnfollow,
                          DXClientApi_UserValidate,
                          DXClientApi_TimelineCreate,
                          DXClientApi_TimelineDelete,
                          DXClientApi_TimelineLike,
                          DXClientApi_TimelineUnlike,
                          DXClientApi_TimelineReport,
                          DXClientApi_TimelinePublicList,
                          DXClientApi_TimelineHotList,
                          DXClientApi_TimelinePrivateList,
                          DXClientApi_TimelineLikeList,
                          DXClientApi_TimelineGetFeed,
                          DXClientApi_TimelineTopics,
                          DXClientApi_TimelineMyTopics,
                          DXClientApi_TimelineTopicList
                          ];
    for (NSString * apiName in apiList) {
        DXClientRequest * request = [DXClientRequest requestWithApi:apiName];
        XCTAssert(request);
        XCTAssert([request requestIdentifier]);
    }
}

- (void)testClientRequestSetParam {
    DXClientRequest * request = [DXClientRequest requestWithApi:DXClientAPi_UserChangeProfile];
    [request setValue:@"6" forParam:@"uid"];
    NSDictionary * params = [request params];
    XCTAssert([[params objectForKey:@"uid"] isEqualToString:@"6"]);
}

- (void)testClientSendRequest {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect Response After Client Send Request"];
    
    DXClient * client = [DXClient client];
    DXClientRequest * request = [DXClientRequest requestWithApi:DXClientAPi_UserProfile];
    [request setValue:@"1" forParam:@"uid"];
    [client send:request progress:^(float percent) {
        XCTAssert(percent >= 0 && percent <= 1.0, @"数据发送进度为大于等于0小于等于1.0的float数");
    } finish:^(DXClientResponse *response) {
        NSError *err =  [response error];
        XCTAssert([err.domain isEqualToString:@"DXClientRequestError"], @"错误域为DXClientRequestError");
        XCTAssert([err.userInfo objectForKey:DXClientRequestOriginErrorDescriptionKey], @"错误userInfo中包含DXClientRequestOriginErrorDescriptionKey字段");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testClientReponseWithData {
    NSDictionary * testData = @{
                                @"id" : @(11211),
                                @"valid" : @(YES),
                                @"name" : @"testName"
                                };
    NSArray * apiList = @[
                          DXClientAPi_UserChangeAvatar,
                          DXClientAPi_UserChangeCover,
                          DXClientAPi_UserChangeProfile,
                          DXClientAPi_UserChangePwd,
                          DXClientAPi_UserCheckSms,
                          DXClientAPi_UserFansList,
                          DXClientAPi_UserFollow,
                          DXClientAPi_UserFollowList,
                          DXClientApi_UserLogin,
                          DXClientApi_UserLogout,
                          DXClientAPi_UserProfile,
                          DXClientApi_UserRegister,
                          DXClientAPi_UserResetPwd,
                          DXClientAPi_UserResetSendSms,
                          DXClientApi_UserSendSms,
                          DXClientAPi_UserUnfollow,
                          DXClientApi_UserValidate,
                          DXClientApi_TimelineCreate,
                          DXClientApi_TimelineDelete,
                          DXClientApi_TimelineLike,
                          DXClientApi_TimelineUnlike,
                          DXClientApi_TimelineReport,
                          DXClientApi_TimelinePublicList,
                          DXClientApi_TimelineHotList,
                          DXClientApi_TimelinePrivateList,
                          DXClientApi_TimelineLikeList,
                          DXClientApi_TimelineGetFeed,
                          DXClientApi_TimelineTopics,
                          DXClientApi_TimelineMyTopics,
                          DXClientApi_TimelineTopicList
                          ];
    for (NSString * apiName in apiList) {
        DXClientResponse * response = [DXClientResponse responseWithApi:apiName data:testData orError:nil];
        XCTAssert(response);
    }
}

- (void)testDXClientRequestError {
    DXClientRequestErrorCode testErrorCode = DXClientRequestErrorServerInternalError;
    NSString * testErrorDescription = @"测试错误";
    DXClientRequestError * error = [DXClientRequestError errorWithCode:testErrorCode andDescription:testErrorDescription];
    XCTAssert(error);
    XCTAssert(error.code == testErrorCode);
    XCTAssert([[error.userInfo objectForKey:DXClientRequestOriginErrorDescriptionKey] isEqualToString:testErrorDescription]);
}


- (void)testClientReponseWithError {
    DXClientRequestErrorCode testErrorCode = DXClientRequestErrorServerInternalError;
    NSString * testErrorDescription = @"测试错误";
    DXClientRequestError * error = [DXClientRequestError errorWithCode:testErrorCode andDescription:testErrorDescription];
    
    NSArray * apiList = @[
                          DXClientAPi_UserChangeAvatar,
                          DXClientAPi_UserChangeCover,
                          DXClientAPi_UserChangeProfile,
                          DXClientAPi_UserChangePwd,
                          DXClientAPi_UserCheckSms,
                          DXClientAPi_UserFansList,
                          DXClientAPi_UserFollow,
                          DXClientAPi_UserFollowList,
                          DXClientApi_UserLogin,
                          DXClientApi_UserLogout,
                          DXClientAPi_UserProfile,
                          DXClientApi_UserRegister,
                          DXClientAPi_UserResetPwd,
                          DXClientAPi_UserResetSendSms,
                          DXClientApi_UserSendSms,
                          DXClientAPi_UserUnfollow,
                          DXClientApi_UserValidate
                          ];
    for (NSString * apiName in apiList) {
        DXClientResponse * response = [DXClientResponse responseWithApi:apiName data:nil orError:error];
        XCTAssert(response);
        XCTAssert([response error].code == testErrorCode);
        XCTAssert([[error.userInfo objectForKey:DXClientRequestOriginErrorDescriptionKey] isEqualToString:testErrorDescription]);
    }
    
}





@end
