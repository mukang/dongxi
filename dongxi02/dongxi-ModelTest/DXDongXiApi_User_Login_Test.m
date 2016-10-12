//
//  DXDongXiApi_User_Login_Test.m
//  dongxi-ModelTest
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXFunctions.h"
#import "DXDongXiApi.h"

/**
 * 在已登陆情况下，DXUser的测试用例
 */
@interface DXDongXiApi_User_Login_Test : XCTestCase

@property (nonatomic, strong) NSString * testMobile;
@property (nonatomic, strong) NSString * testEmail;
@property (nonatomic, strong) NSString * testUsername;
@property (nonatomic, strong) NSString * testPassword;
@property (nonatomic, strong) NSString * testLocation;
@property (nonatomic, assign) NSTimeInterval testMaxWaitTime;

@property (nonatomic, strong) DXDongXiApi * dongxiApi;

@end

@implementation DXDongXiApi_User_Login_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testMobile = @"18612828490";
    self.testEmail = @"xusw21@gmail.com";
    self.testUsername = @"xusw";
    self.testPassword = @"234567";
    self.testLocation = @"北京";
    self.testMaxWaitTime = 5.0;
    
    self.dongxiApi = [DXDongXiApi api];
    
    if ([self.dongxiApi needLogin]) {
        XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user login"];
        
        DXUserLoginInfo * loginInfo = [DXUserLoginInfo new];
        [loginInfo setAccountInfoWithMobile:self.testMobile andPassword:self.testPassword];
        
        [self.dongxiApi login:loginInfo result:^(DXUserSession *userSession, NSError *error) {
            if (userSession) {
                NSLog(@"User Successfully Login during setUp");
            } else {
                XCTFail(@"Expectation Failed with failed login: %@", error);
            }
            [expectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
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

- (void)testUserProfile {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user profile"];
    
    [self.dongxiApi getProfileOfUser:self.dongxiApi.currentUserSession.uid result:^(DXUserProfile *profile, NSError *error) {
        XCTAssert(error == nil, @"已登陆用户获取自己的资料出错");
        XCTAssert([profile.uid isEqualToString:self.dongxiApi.currentUserSession.uid], @"uid不一致");
        
        if (profile.tag) {
            XCTAssert([profile.tag isKindOfClass:[NSArray class]], @"tag字段需为NSArray类型");
            if (profile.tag.count > 0) {
                id firstTag = [profile.tag firstObject];
                XCTAssert([firstTag isKindOfClass:[DXUserProfileTag class]], @"tag数组的里对象必须为DXUserProfileTag类型");
            }
        }
        
        if (profile.uid) {
            XCTAssert([profile.uid isKindOfClass:[NSString class]], @"uid属性为NSString类型");
        }
                
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"sExpectation Failed with error: %@", error);
        }
    }];
}


- (void)testUserChangeProfile {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user change profile"];
    
    DXUserProfileChange * profileChange = [DXUserProfileChange new];
    NSString * usernameNew = [NSString stringWithFormat:@"廿文%03d", arc4random()%100];
    NSString * bioNew = [NSString stringWithFormat:@"随机的简介%3d", arc4random()%100];
    NSString * locationNew = [NSString stringWithFormat:@"北京%3d", arc4random()%100];
    profileChange.username = usernameNew;
    profileChange.bio = bioNew;
    profileChange.location = locationNew;
    
    [self.dongxiApi changeProfile:profileChange result:^(BOOL success, NSError *error) {
        XCTAssert(error == nil, @"修改用户资料失败");
        [self.dongxiApi getProfileOfUser:self.dongxiApi.currentUserSession.uid result:^(DXUserProfile *profile, NSError *error) {
            XCTAssert(error == nil, @"获取用户资料失败");
            XCTAssert([profile.username isEqualToString:usernameNew], @"修改后的昵称与要修改的不一致");
            XCTAssert([profile.bio isEqualToString:bioNew], @"修改后的简介与要修改的不一致");
            XCTAssert([profile.location isEqualToString:locationNew], @"修改的地点与要修改的不一致");
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"sExpectation Failed with error: %@", error);
        }
    }];
}

- (void)testUserChangeAvatar {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user change avatar"];
    
    NSURL * avatarTestURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"avatarTest" withExtension:@"jpg"];
    XCTAssert(avatarTestURL, @"测试文件avatarTest.jpg不存在");

    [self.dongxiApi changeAvatar:avatarTestURL result:^(BOOL success, NSString *url, NSError *error) {
        XCTAssert(success, @"上传成功");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"sExpectation Failed with error: %@", error);
        }
    }];
}

- (void)testUserChangeCover {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user change cover"];
    
    NSURL * coverTestURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"testCover" withExtension:@"jpeg"];
    XCTAssert(coverTestURL, @"测试文件coverTest.jpeg不存在");
    
    [self.dongxiApi changeCover:coverTestURL result:^(BOOL success, NSString *url, NSError *error) {
        XCTAssert(success, @"上传成功");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"sExpectation Failed with error: %@", error);
        }
    }];
}

- (void)testUserLogout {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect user logout"];
    
    [self.dongxiApi logoutWithResult:^(BOOL success, NSError *error) {
        XCTAssert(self.dongxiApi.currentUserSession == nil, @"注销后当前用户session为nil");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试获取关注列表
 */
- (void)testUserFollowList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfuly get user's follow list"];
    
    [self.dongxiApi getFollowListOfUser:self.dongxiApi.currentUserSession.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXUserWrapper *userWrapper, NSError *error) {
        XCTAssert(userWrapper != nil, @"成功获取到关注列表");
        XCTAssert([userWrapper isKindOfClass:[DXUserWrapper class]], @"userWrapper为DXUserWrapper类型");
        XCTAssert([userWrapper.list isKindOfClass:[NSArray class]], @"list属性为NSArray");
        if (userWrapper.list.count > 0) {
            DXUser * user = [userWrapper.list firstObject];
            XCTAssert([user isKindOfClass:[DXUser class]], @"list里的对象为DXUser对象");
            
            XCTAssert([user.ID isKindOfClass:[NSString class]], @"user对象的ID是NSString");
            XCTAssert([user.uid isKindOfClass:[NSString class]], @"user对象的uid属性是NSString");
            XCTAssert(user.location == nil || [user.location isKindOfClass:[NSString class]], @"user对象的location属性要么是nil，是NSString对象");
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试获取粉丝列表
 */
- (void)testUserFanList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfuly get user's fans list"];
    
    [self.dongxiApi getFanListOfUser:self.dongxiApi.currentUserSession.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXUserWrapper *userWrapper, NSError *error) {
        XCTAssert(userWrapper != nil, @"成功获取到关注列表");
        XCTAssert([userWrapper isKindOfClass:[DXUserWrapper class]], @"userWrapper为DXUserWrapper类型");
        XCTAssert([userWrapper.list isKindOfClass:[NSArray class]], @"list属性为NSArray");
        if (userWrapper.list.count > 0) {
            DXUser * user = [userWrapper.list firstObject];
            XCTAssert([user isKindOfClass:[DXUser class]], @"list里的对象为DXUser对象");
            
            XCTAssert([user.ID isKindOfClass:[NSString class]], @"user对象的ID是NSString");
            XCTAssert([user.uid isKindOfClass:[NSString class]], @"user对象的uid属性是NSString");
            XCTAssert(user.location == nil || [user.location isKindOfClass:[NSString class]], @"user对象的location属性要么是nil，是NSString对象");
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


- (void)testFollowUser {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfuly follow a user"];
    
    [self.dongxiApi followUser:@"123" result:^(BOOL success, DXUserRelationType relation, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(error == nil, @"无返回错误，但可能会关注失败");
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testUnfollowUser {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfuly unfollow a user"];
    
    [self.dongxiApi unfollowUser:@"123" result:^(BOOL success, DXUserRelationType relation, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(error == nil, @"无返回错误，但可能会取消关注失败");
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


#pragma mark - 测试更改密码接口

- (void)testUserChangePassword {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期成功更改密码"];
    
    DXUserPasswordChangeInfo * changeInfo = [[DXUserPasswordChangeInfo alloc] init];
    changeInfo.oldpassword = @"234567";
    changeInfo.newpassword = @"234567";
    
    [self.dongxiApi changePasswordWithInfo:changeInfo result:^(DXUserChangePasswordStatus status, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(status == YES, @"密码修改成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

#pragma mark - 测试拉取邀请码列表接口

- (void)testGetUserCouponList {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"拉取邀请码列表成功"];
    
    [self.dongxiApi getUserCouponList:^(DXUserCouponWrapper *couponWrapper, NSError *error) {
        
        [expectation fulfill];
        XCTAssert(couponWrapper.list.count, @"拉取邀请码列表成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testGetUserCoupon {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"申请邀请码成功"];
    
    [self.dongxiApi getUserCouponWithMobile:@"18510509908" result:^(BOOL success, NSError *error) {
        [expectation fulfill];
        XCTAssert(success, @"申请邀请码成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.testMaxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
