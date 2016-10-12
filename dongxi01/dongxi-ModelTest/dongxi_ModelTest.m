//
//  dongxi_ModelTest.m
//  dongxi-ModelTest
//
//  Created by Xu Shiwen on 15/8/12.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DXCacheFileManager.h"

@interface dongxi_ModelTest : XCTestCase

@end

@implementation dongxi_ModelTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDXFileManager {
    
    [self measureBlock:^{
        DXCacheFileManager * fileManager = [DXCacheFileManager sharedManager];
        DXCacheFile * cacheFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeImageCache];
        NSError * fileError = nil;
        [fileManager saveData:[NSData data] toFile:cacheFile error:&fileError];
        if (!fileError) {
            [fileManager deleteFile:cacheFile error:&fileError];
        }
        
        XCTAssert(fileError == nil, @"文件存储/删除正常");
    }];
}

- (void)testUUID_way1 {
    NSMutableArray * uuidArray =  [NSMutableArray array];

    [self measureBlock:^{
        [uuidArray addObject:[[NSProcessInfo processInfo] globallyUniqueString]];
    }];
    
    NSLog(@"%@", uuidArray);
}

- (void)testUUID_way2 {
    NSMutableArray * uuidArray =  [NSMutableArray array];
    
    [self measureBlock:^{
        [uuidArray addObject:[[NSUUID UUID] UUIDString]];
    }];
    
    NSLog(@"%@", uuidArray);
}

@end
