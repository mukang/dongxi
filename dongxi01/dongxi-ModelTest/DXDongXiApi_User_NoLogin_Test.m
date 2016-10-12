//
//  DXDongXiApi_User_NoLogin_Test.m
//  dongxi-ModelTest
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXDongXiApi.h"
#import "DXFunctions.h"

@interface DXDongXiApi_User_NoLogin_Test : XCTestCase

@property (nonatomic, strong) DXDongXiApi * dongxiApi;
@property (nonatomic, strong) NSString * testMobile;
@property (nonatomic, strong) NSString * testSmsMobile;
@property (nonatomic, strong) NSString * testEmail;
@property (nonatomic, strong) NSString * testUsername;
@property (nonatomic, strong) NSString * testPassword;
@property (nonatomic, strong) NSString * testLocation;
@property (nonatomic, assign) NSTimeInterval maxWaitTime;

@end

@implementation DXDongXiApi_User_NoLogin_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.dongxiApi = [DXDongXiApi api];
    self.testMobile = @"18612828490";
    self.testSmsMobile = @"18612828490";
    self.testEmail = @"xusw21@gmail.com";
    self.testUsername = @"xusw";
    self.testPassword = @"123456";
    self.testLocation = @"北京";
    self.maxWaitTime = 5;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 * 验证邮箱是否可用
 */
- (void)testUserValidateEmail {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect mail validate result"];
    
    [self.dongxiApi isEmail:self.testEmail valid:^(BOOL valid, NSError *error) {
        XCTAssert(valid == YES || valid == NO);
        NSLog(@"邮箱%@%@注册", self.testEmail, valid ? @"可" : @"不可");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 * 验证用户名是否可用
 */
- (void)testUserValidateUsername {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect username validate result"];
    
    [self.dongxiApi isUsername:self.testUsername valid:^(BOOL valid, NSError *error) {
        XCTAssert(valid == YES || valid == NO);
        NSLog(@"用户名%@%@注册", self.testUsername, valid ? @"可" : @"不可");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 * 验证手机号是否可用
 */
- (void)testUserValidateMobile {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect username validate result"];
    
    [self.dongxiApi isMobile:self.testMobile valid:^(BOOL valid, NSError *error) {
        XCTAssert(valid == YES || valid == NO);
        NSLog(@"手机号%@%@注册", self.testMobile, valid ? @"可" : @"不可");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 * 用户注册
 */
- (void)testUserRegister {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user register result"];
    
    DXUserRegisterInfo * registerInfo = [DXUserRegisterInfo new];
    registerInfo.username = self.testUsername;
    registerInfo.password = self.testPassword;
    registerInfo.email = self.testEmail;
    registerInfo.mobile = self.testMobile;
    registerInfo.location = self.testLocation;
    registerInfo.gender = DXUserGenderTypeMale;
    
    [self.dongxiApi registerUser:registerInfo result:^(BOOL success, NSError *error) {
        if (success) {
            XCTAssert(error == nil);
            NSLog(@"User Register Success");
        } else {
            XCTAssert(error != nil);
            NSLog(@"User Register Fail : %@", error.localizedDescription);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 * 用户登录
 */
- (void)testUserLogin {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user login result"];
    DXUserLoginInfo * loginInfo = [DXUserLoginInfo new];
    [loginInfo setAccountInfoWithMobile:self.testMobile andPassword:self.testPassword];
    
    XCTAssert(loginInfo.account_type == DXUserLoginAccountTypeMobile);
    XCTAssert([[loginInfo.account_info objectForKey:@"mobile"] isEqualToString:self.testMobile]);
    XCTAssert([[loginInfo.account_info objectForKey:@"password"] isEqualToString:DXDigestMD5(self.testPassword)]);
    
    [self.dongxiApi login:loginInfo result:^(DXUserSession *session, NSError *error) {
        if (session) {
            XCTAssert(error == nil);
            XCTAssert(session.uid, @"uid不能为空");
            XCTAssert(session.sid, @"sid不能为空");
            XCTAssert(session.validtime > 0, @"sid有效时间不能为空");
            NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
            XCTAssert(session.validtime > current, @"sid有效时间必须大于当前时间");
            XCTAssert(session.avatar, @"avatar不能为空");
            NSLog(@"User Login Success, login as %@", session);
        } else {
            XCTAssert(error != nil);
            NSLog(@"User Login Fail : %@", error.localizedDescription);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


/**
 * 发送手机注册码
 */
- (void)testUserSendRegisterSms {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user send sms result"];
    DXUserSms * sms = [DXUserSms newUserSmsWithMobile:self.testSmsMobile];
    XCTAssert([sms.key isEqualToString:DXReverseNSString(DXDigestMD5(DXReverseNSString(self.testSmsMobile)))], @"短信key计算不正确");
    
    [self.dongxiApi sendSms:sms result:^(BOOL success, NSError *error) {
        XCTAssert(success, @"短信发送不成功: %@", error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


/**
 * 验证手机注册码
 */
- (void)testUserCheckRegisterSms {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user check sms result"];
    DXUserSmsCheck * sms = [DXUserSmsCheck new];
    sms.mobile = self.testSmsMobile;
    sms.code = @"30014"; //替换成接收到的手机验证码

    [self.dongxiApi checkSms:sms result:^(BOOL valid, NSError *error) {
        XCTAssert(valid, @"短信验证手机有效");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

#pragma mark - 测试发送密码重置短信验证码

- (void)testUserSendResetPasswordSms {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期成功收到重置密码短信"];
    DXUserSms * sms = [[DXUserSms alloc] init];
    sms.mobile = @"18612828490";
    
    [self.dongxiApi sendResetPasswordSms:sms result:^(DXUserResetPassSmsStatus status, NSString *nick, NSString *uid, NSError *error) {
       [expectation fulfill];
        
        if (status == DXUserResetPassSmsSended) {
            XCTAssert(nick != nil, @"成功获取用户昵称");
            XCTAssert(uid != nil, @"成功获取用户uid");
        }
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


#pragma mark - 测试验证重置密码的短信验证码是否有效

- (void)testCheckUserResetPasswordSms {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期成功收到接口响应"];

    NSString * code = nil;
    NSString * uid = nil;
    
    NSAssert(code != nil, @"测试前先输入收到的code");
    NSAssert(uid != nil, @"测试前先输入要验证的用户的uid");
    
    [self.dongxiApi checkResetPasswordSmsCode:code forUser:uid result:^(BOOL valid, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(valid == YES, @"重置密码的短信验证码是有效的");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

#pragma mark - 测试重置密码

- (void)testUserResetPassword {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期成功通过短信/邮箱验证码重置密码"];
    
    DXUserPasswordResetInfo * resetInfo = [[DXUserPasswordResetInfo alloc] init];
    resetInfo.uid = @"616";
    resetInfo.newpassword = @"68998";
    resetInfo.code = @"68998"; //替换成当前收到的短信验证码或邮箱验证码
    [self.dongxiApi resetPasswordWithInfo:resetInfo result:^(DXUserResetPasswordStatus status, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(status == DXUserResetPasswordOK ||
                  status == DXUserResetPasswordFailed ||
                  status == DXUserResetPasswordWrongCode);
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


#pragma mark - 测试获取用户资料

- (void)testGetUserProfileByNick {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期获得响应"];
    
    [self.dongxiApi getProfileOfUserByNick:@"廿文" result:^(DXUserProfile *profile, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(profile != nil);
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
