//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
#import "DXFunctions.h"
#import "DXArchiveService.h"

NSString *const WXAppID = @"wx2d2724d8b6254932";
NSString *const WXAppSecret = @"14309496e63bcb49930de2071fe35d03";
NSString *const WXBaseURL = @"https://api.weixin.qq.com";

@interface WXApiManager ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) DXWechatLoginInfo *loginInfo;

@end

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
        [instance loadWechatLoginInfo];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - 登录信息相关

- (void)loadWechatLoginInfo {
    NSString *loginInfoModelName = NSStringFromClass([DXWechatLoginInfo class]);
    DXArchiveService *archiveService = [DXArchiveService sharedService];
    DXWechatLoginInfo *loginInfo = [archiveService unarchiveObject:loginInfoModelName ForLoginUser:nil forcePersist:YES];
    _loginInfo = loginInfo;
}

- (DXWechatLoginInfo *)wechatLoginInfo {
    return _loginInfo;
}

- (void)saveWechatLoginInfo:(DXWechatLoginInfo *)loginInfo {
    if (loginInfo) {
        BOOL success = [[DXArchiveService sharedService] archiveObject:loginInfo ForLoginUser:nil forcePersist:YES];
        if (success) {
            _loginInfo = loginInfo;
            DXLog(@"WechatLoginInfo归档成功");
        } else {
            DXLog(@"WechatLoginInfo归档失败");
        }
    }
}

- (void)cleanWechatLoginInfo {
    if (_loginInfo) {
        _loginInfo = nil;
    }
    [[DXArchiveService sharedService] cleanObject:NSStringFromClass([DXWechatLoginInfo class]) ForLoginUser:nil forcePersist:YES];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate managerDidRecvAddCardResponse:addCardResp];
        }
    }
}

- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [_delegate managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

#pragma mark - 用户登录相关接口

- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken result:(void (^)(NSDictionary *, NSError *))resultBlock {
    NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WXBaseURL, WXAppID, refreshToken];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:refreshUrlStr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseData = nil;
        if (!error) {
            NSError *serializeError = nil;
            responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializeError];
            if (serializeError) {
                responseData = nil;
                error = serializeError;
            }
        }
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(responseData, error));
        }
    }];
    [task resume];
}

- (void)getAccessTokenWithCode:(NSString *)code result:(void (^)(NSDictionary *, NSError *))resultBlock {
    NSString *accessUrlStr = [NSString stringWithFormat:@"%@/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WXBaseURL, WXAppID, WXAppSecret, code];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:accessUrlStr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseData = nil;
        if (!error) {
            NSError *serializeError = nil;
            responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializeError];
            if (serializeError) {
                responseData = nil;
                error = serializeError;
            }
        }
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(responseData, error));
        }
    }];
    [task resume];
}

- (void)getUserInfoWithAccessToken:(NSString *)accessToken openID:(NSString *)openID result:(void (^)(NSDictionary *, NSError *))resultBlock {
    NSString *userUrlStr = [NSString stringWithFormat:@"%@/sns/userinfo?access_token=%@&openid=%@", WXBaseURL, accessToken, openID];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:[NSURL URLWithString:userUrlStr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseData = nil;
        if (!error) {
            NSError *serializeError = nil;
            responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializeError];
            if (serializeError) {
                responseData = nil;
                error = serializeError;
            }
        }
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(responseData, error));
        }
    }];
    [task resume];
}

#pragma mark - lazy

- (NSURLSession *)session {
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

@end
