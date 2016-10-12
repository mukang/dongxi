//
//  DXUnReadInfo.m
//  dongxi
//
//  Created by 穆康 on 15/11/19.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUnReadInfo.h"
#import "DXArchiveService.h"

@interface DXUnReadInfo ()

@property (nonatomic, strong) DXArchiveService *archiveService;

@property (nonatomic, strong) NSString *currentUid;

@end

@implementation DXUnReadInfo

DXSingletonImplementation(UnReadInfo)

- (NSInteger)unReadMessageCount {
    
    DXUnReadMessageWrapper *wrapper = [self.archiveService unarchiveObject:NSStringFromClass([DXUnReadMessageWrapper class]) ForLoginUser:self.currentUid];
    
    if (wrapper) {
        return wrapper.list.count;
    }
    
    return 0;
}

- (BOOL)addUnReadMessageWithType:(DXUnReadMessageType)type {
    
    DXUnReadMessage *temp = [[DXUnReadMessage alloc] init];
    temp.type = type;
    
    DXUnReadMessageWrapper *wrapper = [self.archiveService unarchiveObject:NSStringFromClass([DXUnReadMessageWrapper class]) ForLoginUser:self.currentUid];
    
    if (wrapper) {
        NSMutableArray *messages = [NSMutableArray arrayWithArray:wrapper.list];
        BOOL isContain = NO;
        for (DXUnReadMessage *message in messages) {
            if (message.type == type) {
                isContain = YES;
                break;
            }
        }
        if (isContain) {
            return YES;
        } else {
            [messages addObject:temp];
            wrapper.list = messages;
            return [self.archiveService archiveObject:wrapper ForLoginUser:self.currentUid];
        }
    } else {
        wrapper = [[DXUnReadMessageWrapper alloc] init];
        wrapper.list = @[temp];
        return [self.archiveService archiveObject:wrapper ForLoginUser:self.currentUid];
    }
}

- (BOOL)removeUnReadMessageWithType:(DXUnReadMessageType)type {
    
    DXUnReadMessageWrapper *wrapper = [self.archiveService unarchiveObject:NSStringFromClass([DXUnReadMessageWrapper class]) ForLoginUser:self.currentUid];
    
    if (wrapper) {
        NSMutableArray *messages = [NSMutableArray arrayWithArray:wrapper.list];
        BOOL isContain = NO;
        for (DXUnReadMessage *message in messages) {
            if (message.type == type) {
                isContain = YES;
                [messages removeObject:message];
                break;
            }
        }
        if (isContain) {
            wrapper.list = messages;
            return [self.archiveService archiveObject:wrapper ForLoginUser:self.currentUid];
        } else {
            return YES;
        }
    } else {
        wrapper = [[DXUnReadMessageWrapper alloc] init];
        return [self.archiveService archiveObject:wrapper ForLoginUser:self.currentUid];
    }
}

- (BOOL)cleanAllUnReadMessage {
    
    return [self.archiveService cleanObject:NSStringFromClass([DXUnReadMessageWrapper class]) ForLoginUser:self.currentUid];
}

#pragma mark - 懒加载

- (DXArchiveService *)archiveService {
    
    if (_archiveService == nil) {
        _archiveService = [DXArchiveService sharedService];
    }
    return _archiveService;
}

- (NSString *)currentUid {
    
    if (_currentUid == nil) {
        _currentUid = [[DXDongXiApi api] currentUserSession].uid;
    }
    return _currentUid;
}

@end
