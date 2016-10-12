//
//  DXDongXiApi_Timeline_Test.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXDongXiApi.h"

@interface DXDongXiApi_Timeline_Test : XCTestCase

@property (nonatomic, strong) DXDongXiApi * api;
@property (nonatomic, assign) NSTimeInterval maxWaitTime;

@end

@implementation DXDongXiApi_Timeline_Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.api = [DXDongXiApi api];
    self.maxWaitTime = 5.0;
    
//    if ([self.api needLogin]) {
//        XCTestExpectation * expectation = [self expectationWithDescription:@"Expect login successfully"];
//        
//        DXUserLoginInfo * loginInfo = [DXUserLoginInfo new];
//        [loginInfo setAccountInfoWithMobile:@"18810534201" andPassword:@"123456"];
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

- (void)testGetHotList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get hot list of timeline"];
    
    [self.api getTimelineHotList:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper * feedWrapper, NSError *error) {
        XCTAssert(error == nil, @"请求没有出错");
        
        [self validateTimelineFeedWrapper:feedWrapper];
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testGetTopics {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get topics"];
    
    [self.api getTopics:^(NSArray *topics, NSError *error) {
        XCTAssert(error == nil, @"请求没有出错");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testPostTopic {
    NSURL * avatarTestURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"avatarTest" withExtension:@"jpg"];
    XCTAssert(avatarTestURL, @"测试文件avatarTest.jpg不存在");
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get a successfully posted feed"];
    
    DXTopicPost * post = [DXTopicPost new];
    post.txt = @"惘闻，国内的最好器乐摇滚乐队，擅长营造氛围，无论是现场还是录音，效果都堪称一流。他们的黑胶一出必收。";
    post.lock = NO;
    post.topic_id = @"1";
    post.lat = @"39.9632737";
    post.lng = @"116.4488983";
    post.place = @"三元桥时间国际";
    post.photoURLs = @[avatarTestURL];
    [self.api postToTopic:post progress:^(float percent) {
        XCTAssert(percent >= 0 && percent <= 1.0, @"percent为0到1之间，表示上传进度的百分比");
    } result:^(DXTimelineFeed *feed, NSError *error) {
        XCTAssert(feed != nil, @"成功发表");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
    
}

- (void)testGetTopicFeedList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfully get feed list of a topic"];
    [self.api getTopicFeedList:@"1" pullType:DXDataListPullFirstTime count:20 lastID:nil result:^(DXTopicFeedList *topicFeedList, NSError *error) {
        XCTAssert(topicFeedList != nil, @"成功拉取列表");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testGetHotTopicFeedList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfully get hot feed list of a topic"];
    [self.api getHotTopicFeedList:@"1" pullType:DXDataListPullFirstTime count:20 lastID:nil result:^(DXTopicFeedList *topicFeedList, NSError *error) {
        XCTAssert(topicFeedList != nil, @"成功拉取列表");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试获取“时间线－关注”列表
 */
- (void)testGetPublicList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get public list of timeline"];
    
    [self.api getTimelinePublicList:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper * feedWrapper, NSError *error) {
        XCTAssert(error == nil, @"请求没有出错");
        
        [self validateTimelineFeedWrapper:feedWrapper];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试获取当前已登陆用户自己的“我参与”列表
 */
- (void)testGetPrivateListOfUser {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get private feed list of user"];
    NSString * testUID = self.api.currentUserSession.uid;
    
    [self.api getPrivateFeedListOfUser:testUID pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper * feedWrapper, NSError *error) {
        XCTAssert(error == nil, @"请求没有出错");
        
        [self validateTimelineFeedWrapper:feedWrapper];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}


/**
 *  测试获取当前已登陆用户自己的收藏列表
 */
- (void)testGetSaveListOfUser {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect get saved feed list of user"];
    
    [self.api getSavedFeedListOfUser:self.api.currentUserSession.uid pullType:DXDataListPullFirstTime count:10 lastID:nil result:^(DXTimelineFeedWrapper * feedWrapper, NSError *error) {
        XCTAssert(error == nil, @"请求没有出错");
        
        [self validateTimelineFeedWrapper:feedWrapper];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试邀请用户参加话题
 */
- (void)testInviteUserJoinTopic {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect successfully invite a user"];
    
    [self.api inviteUser:@"123" joinTopic:@"1" result:^(BOOL success, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(error == nil, @"无返回错误，如果success为NO则是重复邀请");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试feed的点赞用户列表
 */
- (void)testGetLikeUserList {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期成功获取点赞列表"];
    
    [self.api getLikeUsersOfFeed:@"1154" pullType:DXDataListPullFirstTime count:20 lastID:nil result:^(DXUserWrapper *users, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(error == nil, @"返回无错误产生");
        XCTAssert(users != nil, @"返回成功生成了DXUserWrapper对象");
        [self validateUserWrapper:users];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

/**
 *  测试获取feed
 */
- (void)testGetFeed {
    XCTestExpectation * expectation = [self expectationWithDescription:@"预期成功获取Feed"];
    
    [self.api getFeedWithID:@"1154" result:^(DXTimelineFeed *feed, NSError *error) {
        [expectation fulfill];
        
        XCTAssert(error == nil, @"返回无错误产生");
        XCTAssert(feed != nil, @"成功获得了feed数据");
        [self validateTimelineFeed:feed];
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}



#pragma mark -

- (void)validateTimelineFeedWrapper:(DXTimelineFeedWrapper *)feedWrapper {
    XCTAssert([feedWrapper isKindOfClass:[DXTimelineFeedWrapper class]], @"feedWrapper是DXTimelineFeedWrapper类型");
    
    XCTAssert(feedWrapper.count == feedWrapper.feeds.count, @"收到的feedWrapper的count属性与feeds数组的count值一致");
    
    if (feedWrapper.feeds) {
        XCTAssert([feedWrapper.feeds isKindOfClass:[NSArray class]], @"feedWrapper的feeds属性为NSArray类型");
        if (feedWrapper.feeds.count > 0) {
            DXTimelineFeed * feed  = [feedWrapper.feeds firstObject];
            XCTAssert([feed isKindOfClass:[DXTimelineFeed class]], @"feeds数组中的对象为DXTimelineFeed类型");
            
            [self validateTimelineFeed:feed];
        }
    }
}

- (void)validateTimelineFeed:(DXTimelineFeed *)feed {
    XCTAssert([feed.fid isKindOfClass:[NSString class]], @"feed的fid是字符串类型");
    XCTAssert([feed.uid isKindOfClass:[NSString class]], @"feed的uid是字符串类型");
    
    if (feed.data) {
        XCTAssert([feed.data isKindOfClass:[DXTimelineFeedContent class]], @"feed的data是DXTimelineFeedContent类型");
        if (feed.data.comments) {
            XCTAssert([feed.data.comments isKindOfClass:[NSArray class]], @"DXTimelineFeedContent的comments是NSArray类型");
            if (feed.data.comments.count > 0) {
                DXTimelineFeedComment * comment = [feed.data.comments firstObject];
                XCTAssert([comment isKindOfClass:[DXTimelineFeedComment class]], @"comments数组里的是DXTimelineFeedComment类型");
                
                XCTAssert([comment.uid isKindOfClass:[NSString class]], @"DXTimelineFeedComment对象的uid属性是NSString");
                XCTAssert([comment.ID isKindOfClass:[NSString class]], @"DXTimelineFeedComment对象的ID属性是NSString");
            }
        }
        
        if (feed.data.likes) {
            XCTAssert([feed.data.likes isKindOfClass:[NSArray class]], @"DXTimelineFeedContent的likes是NSArray类型");
            if (feed.data.likes.count > 0) {
                DXTimelineFeedLiker * feedLiker = [feed.data.likes firstObject];
                XCTAssert([feedLiker isKindOfClass:[DXTimelineFeedLiker class]], @"likes数组里的是DXTimelineFeedLiker类型");
                
                XCTAssert([feedLiker.uid isKindOfClass:[NSString class]], @"DXTimelineFeedLiker对象的uid属性是NSString");
            }
        }
        
        if (feed.data.tags) {
            XCTAssert([feed.data.tags isKindOfClass:[NSArray class]], @"DXTimelineFeedContent的tags是NSArray类型");
            if (feed.data.tags.count > 0) {
                DXTimelineFeedTag * feedTag = [feed.data.tags firstObject];
                XCTAssert([feedTag isKindOfClass:[DXTimelineFeedTag class]], @"tags数组里的是DXTimelineFeedTag类型");
                
                XCTAssert([feedTag.tag_id isKindOfClass:[NSString class]], @"DXTimelineFeedTag对象的tag_id属性是NSString");
            }
        }
        
        if (feed.data.topic) {
            XCTAssert([feed.data.topic isKindOfClass:[DXTimelineFeedTopicInfo class]], @"DXTimelineFeedContent的topic是DXTimelineFeedTopicInfo类型");
            XCTAssert([feed.data.topic.topic_id isKindOfClass:[NSString class]], @"DXTimelineFeedTopicInfo对象的topic_id是NSString");
        }
    }
}


- (void)validateUserWrapper:(DXUserWrapper *)userWrapper {
    XCTAssert([userWrapper.list isKindOfClass:[NSArray class]], @"list是NSArray对象");
    XCTAssert(userWrapper.count == userWrapper.list.count, @"list数组的数量和count字段的数量一致");
    
    for (DXUser * user in userWrapper.list) {
        XCTAssert([user isKindOfClass:[DXUser class]], @"list数组包含的是DXUser对象");
        [self validateUser:user];
    }
}


- (void)validateUser:(DXUser *)user {
    XCTAssert([user.uid isKindOfClass:[NSString class]], @"uid是NSString对象");
    XCTAssert(user.ID == nil || [user.ID isKindOfClass:[NSString class]], @"ID是NSString对象");
    XCTAssert(user.py == nil || [user.py isKindOfClass:[NSString class]], @"py是NSString对象");
    XCTAssert([user.nick isKindOfClass:[NSString class]], @"nick是NSString对象");
    XCTAssert([user.avatar isKindOfClass:[NSString class]], @"avatar是NSString对象");
    XCTAssert(user.location == nil || [user.location isKindOfClass:[NSString class]], @"location是NSString对象");
}

- (void)testDeleteFeed {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"删除成功"];
    
    [self.api deleteFeedWithFeedID:@"1267" result:^(BOOL success, NSError *error) {
        [expectation fulfill];
        XCTAssert(success, @"删除成功");
    }];
    
    [self waitForExpectationsWithTimeout:self.maxWaitTime handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
