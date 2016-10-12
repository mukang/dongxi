//
//  DXUserInfoManager.m
//  dongxi
//
//  Created by Xu Shiwen on 15/12/8.
//  Copyright © 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXUserInfoManager.h"
#import "DXCacheFileManager.h"
#import "DXWeakObjectList.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DXUserInfoManager()

@property (nonatomic, strong) NSMutableDictionary * users;
@property (nonatomic, strong) NSString * relativePath;

@property (nonatomic, strong) NSMutableDictionary * nicknameObservers;
@property (nonatomic, strong) NSMutableDictionary * avatarObservers;

@end


@implementation DXUserInfoManager


#pragma mark - 公开接口


+ (instancetype)sharedManager {
    static DXUserInfoManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        [manager prepare];
    });
    return manager;
}

+ (DXUserInfo *)userInfoForUID:(NSString *)uid {
    return [[self sharedManager] userInfoForUID:uid];
}


+ (void)setUserInfo:(DXUserInfo *)userInfo forUID:(NSString *)uid {
    [[self sharedManager] setUserInfo:userInfo forUID:uid];
}


- (DXUserInfo *)userInfoForUID:(NSString *)uid {
    NSAssert(uid != nil, @"参数uid不能为nil");
    
    DXUserInfo * userInfo = [self.users objectForKey:uid];
    // 如果内存中不存在用户信息，尝试从文件读取
    if (userInfo == nil) {
        DXCacheFile * cacheFile = [self cacheFileForUID:uid];
        userInfo = [self readUserInfoFromCacheFile:cacheFile];
        // 如果文件存在，将其放入内存
        if (userInfo) {
            [self.users setObject:userInfo forKey:uid];
        }
    }
    return userInfo;
}


- (void)setUserInfo:(DXUserInfo *)userInfo forUID:(NSString *)uid {
    NSAssert(userInfo != nil, @"参数userInfo不能为nil");
    NSAssert(uid != nil, @"参数uid不能为nil");
    
    DXUserInfo * existedUserInfo = [self.users objectForKey:uid];
    if (existedUserInfo) {
        // 用户信息已存在且已经过时
        if ((![userInfo isEqualToUserInfo:existedUserInfo] && userInfo.updateTime >= existedUserInfo.updateTime) ||
            (userInfo.nickname != nil && existedUserInfo.nickname == nil) ||
            (userInfo.avatar != nil && existedUserInfo.avatar == nil)) {
            // 更新文件信息
            DXCacheFile * cacheFile = [self cacheFileForUID:uid];
            [self saveUserInfo:userInfo toCacheFile:cacheFile];
            
            // 更新内存信息
            [self.users setObject:userInfo forKey:uid];
            
            // 更新关联的UI
            if (![userInfo.nickname isEqualToString:existedUserInfo.nickname]) {
                [self updateNickname:userInfo.nickname forUID:uid];
            }
            if (![userInfo.avatar isEqualToString:existedUserInfo.avatar]) {
                [self updateAvatar:userInfo.avatar forUID:uid];
            }
        }
    } else {
        // 更新文件信息
        DXCacheFile * cacheFile = [self cacheFileForUID:uid];
        [self saveUserInfo:userInfo toCacheFile:cacheFile];
        
        // 更新内存信息
        [self.users setObject:userInfo forKey:uid];
        
        // 更新关联的UI
        [self updateAvatar:userInfo.avatar forUID:uid];
        [self updateNickname:userInfo.nickname forUID:uid];
    }
}


- (void)addLabelObserver:(UILabel *__weak)label forNicknameWithUID:(NSString *)uid {
    if (uid && label) {
        DXWeakObjectList * list =  [self.nicknameObservers objectForKey:uid];
        if (list == nil) {
            list = [[DXWeakObjectList alloc] init];
            [self.nicknameObservers setObject:list forKey:uid];
        }
        
        NSUInteger i = 0;
        BOOL existed = NO;
        for (UILabel * currentLabel in list) {
            if (currentLabel == label) {
                existed = YES;
                break;
            } else if (currentLabel == nil) {
//                NSLog(@"第%lu个UILabel对象已释放", (unsigned long)i);
            }
            i++;
        }
        
        if (!existed) {
            typeof(label) __weak weakLabel = label;
            [list addObject:weakLabel];
        }
    }
}

- (void)addImageViewObserver:(UIImageView *__weak)imageView forAvatarWithUID:(NSString *)uid {
    if (uid && imageView) {
        DXWeakObjectList * list =  [self.avatarObservers objectForKey:uid];
        if (list == nil) {
            list = [[DXWeakObjectList alloc] init];
            [self.avatarObservers setObject:list forKey:uid];
        }
        
        NSUInteger i = 0;
        BOOL existed = NO;
        for (UIImageView * currentImageView in list) {
            if (currentImageView == imageView) {
                existed = YES;
                break;
            } else if (currentImageView == nil) {
//                NSLog(@"第%lu个UIImageView对象已释放", (unsigned long)i);
            }
            i++;
        }
        
        if (!existed) {
            typeof(imageView) __weak weakImageView = imageView;
            [list addObject:weakImageView];
        }
    }
}


+ (NSString *)getNewestNicknameWithCurrentNickname:(NSString *)nickname updateTime:(NSTimeInterval)updateTime forUID:(NSString *)uid {
    return [[self sharedManager] getNewestNicknameWithCurrentNickname:nickname updateTime:updateTime forUID:uid];
}


+ (NSString *)getNewestAvatarWithCurrentAvatar:(NSString *)avatar updateTime:(NSTimeInterval)updateTime forUID:(NSString *)uid {
    return [[self sharedManager] getNewestAvatarWithCurrentAvatar:avatar updateTime:updateTime forUID:uid];
}


- (NSString *)getNewestNicknameWithCurrentNickname:(NSString *)nickname updateTime:(NSTimeInterval)updateTime forUID:(NSString *)uid {
    DXUserInfo * userInfo = [[self  userInfoForUID:uid] copy];
    if (userInfo) {
        if (!userInfo.nickname || (![nickname isEqualToString:userInfo.nickname] && updateTime > userInfo.updateTime)) {
            userInfo.nickname = nickname;
            userInfo.updateTime = updateTime;
            [self setUserInfo:userInfo forUID:uid];
        }
    } else {
        userInfo = [[DXUserInfo alloc] init];
        userInfo.nickname = nickname;
        userInfo.updateTime = updateTime;
        [self setUserInfo:userInfo forUID:uid];
    }
    return userInfo.nickname;
}


- (NSString *)getNewestAvatarWithCurrentAvatar:(NSString *)avatar updateTime:(NSTimeInterval)updateTime forUID:(NSString *)uid {
    DXUserInfo * userInfo = [[self userInfoForUID:uid] copy];
    if (userInfo) {
        if (!userInfo.avatar || (![avatar isEqualToString:userInfo.avatar] && updateTime > userInfo.updateTime)) {
            userInfo.avatar = avatar;
            userInfo.updateTime = updateTime;
            [self setUserInfo:userInfo forUID:uid];
        }
    } else {
        userInfo = [[DXUserInfo alloc] init];
        userInfo.avatar = avatar;
        userInfo.updateTime = updateTime;
        [self setUserInfo:userInfo forUID:uid];
    }
    return userInfo.avatar;
}


#pragma mark - 私有接口

- (NSMutableDictionary *)users {
    if (nil == _users) {
        _users = [NSMutableDictionary dictionary];
    }
    return _users;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)prepare {
    self.relativePath = @"userinfo";
    self.nicknameObservers = [NSMutableDictionary dictionary];
    self.avatarObservers = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMemoryWarningNotification:) name:
     UIApplicationDidReceiveMemoryWarningNotification object:nil];
}


- (DXCacheFile *)cacheFileForUID:(NSString *)uid {
    NSAssert(uid != nil, @"参数uid不能为nil");
    
    DXCacheFile * cacheFile = [[DXCacheFile alloc] initWithFileType:DXCacheFileTypeGeneralCache];
    cacheFile.name = uid;
    cacheFile.relativePath = self.relativePath;
    cacheFile.assignRandomName = NO;
    cacheFile.deleteWhenAppLaunch = NO;
    
    return cacheFile;
}


- (void)saveUserInfo:(DXUserInfo *)userInfo toCacheFile:(DXCacheFile *)cacheFile{
    NSAssert(userInfo != nil, @"参数userInfo不能为nil");
    
    DXCacheFileManager * cacheFileManager = [DXCacheFileManager sharedManager];
    NSData * userData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
    [cacheFileManager saveData:userData toFile:cacheFile error:nil];
}


- (DXUserInfo *)readUserInfoFromCacheFile:(DXCacheFile *)cacheFile {
    NSAssert(cacheFile != nil, @"参数cacheFile不能为nil");
    
    DXUserInfo * cacheInfo = nil;
    DXCacheFileManager * cacheFileManager = [DXCacheFileManager sharedManager];
    if ([cacheFileManager isFileExisted:cacheFile]) {
        NSData * userData = nil;
        if ([cacheFileManager readData:&userData fromFile:cacheFile error:nil]) {
            cacheInfo = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        }
    }
    return cacheInfo;
}


- (void)onMemoryWarningNotification:(NSNotification *)noti {
    self.users = nil;
    
    // 清理已被释放的observer
    for (NSString * uid in self.avatarObservers.allKeys) {
        DXWeakObjectList * list = [self.avatarObservers objectForKey:uid];
        [list removeReleasedObjects];
    }
    
    for (NSString * uid in self.nicknameObservers.allKeys) {
        DXWeakObjectList * list = [self.nicknameObservers objectForKey:uid];
        [list removeReleasedObjects];
    }
}


#pragma mark - UI 更新

- (void)updateNickname:(NSString *)nickname forUID:(NSString *)uid {
    DXWeakObjectList * list = [self.nicknameObservers objectForKey:uid];
    for (UILabel * label in list) {
        if (label) {
            [label setText:nickname];
        } else {
//            NSLog(@"UILabel已被释放，无需更新");
        }
    }
}

- (void)updateAvatar:(NSString *)avatar forUID:(NSString *)uid {
    DXWeakObjectList * list = [self.avatarObservers objectForKey:uid];
    for (UIImageView * imageView in list) {
        if (imageView) {
            NSURL * avatarURL = [NSURL URLWithString:avatar];
            [imageView sd_setImageWithURL:avatarURL];
        } else {
//            NSLog(@"UIImageView已被释放，无需更新");
        }
    }
}


@end



@implementation UIImageView (DXUserInfoManager)

- (void)hookAvatarImageForUID:(NSString *)uid {
    if (uid) {
        DXUserInfoManager * manager = [DXUserInfoManager sharedManager];
        typeof(self) __weak weakSelf = self;
        [manager addImageViewObserver:weakSelf forAvatarWithUID:uid];
    }
}

@end


@implementation UILabel (DXUserInfoManager)

- (void)hookNicknameTextForUID:(NSString *)uid {
    if (uid) {
        DXUserInfoManager * manager = [DXUserInfoManager sharedManager];
        typeof(self) __weak weakSelf = self;
        [manager addLabelObserver:weakSelf forNicknameWithUID:uid];
    }
}

@end
