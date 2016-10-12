//
//  DXDongXiApi.m
//  dongxi
//
//  Created by Xu Shiwen on 15/8/18.
//  Copyright (c) 2015年 北京聚益网络科技有限公司. All rights reserved.
//

#import "DXDongXiApi.h"

#import "DXClientImport.h"
#import "DXFunctions.h"
#import "DXClientFunctions.h"
#import "NSObject+DXModel.h"
#import "DXArchiveService.h"
#import "DXUserSession.h"


NSString * const DXDongXiApiNotificationUserDidLogin      = @"DXDongXiApiNotificationUserDidLogin";
NSString * const DXDongXiApiNotificationUserDidLogout     = @"DXDongXiApiNotificationUserDidLogout";


#pragma mark - DXDongXiApi -

@interface DXDongXiApi () <DXClientDelegate>

@end

@implementation DXDongXiApi {
    DXUserSession * _userSession;
}

+ (instancetype)api {
    static DXDongXiApi * api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api = [[self class] new];
        [api loadArchivedUserSession];
        [api setClientDelegate];
        [[NSNotificationCenter defaultCenter] addObserver:api
                                                 selector:@selector(didReceiveUserNeedReloginNotification:)
                                                     name:@"DXClientResponseUserNeedRelogin"
                                                   object:nil];
    });
    return api;
}

- (void)loadArchivedUserSession {
    NSString * sessionModelName = NSStringFromClass([DXUserSession class]);
    DXArchiveService * archiveService = [DXArchiveService sharedService];
    DXUserSession * session = [archiveService unarchiveObject:sessionModelName ForLoginUser:nil forcePersist:YES];
    _userSession = session;
}

- (void)setClientDelegate {
    [DXClient client].delegate = self;
}

- (BOOL)needLogin {
    return ![self isUserSessionValid];
}

- (BOOL)isUserSessionValid {
    
    if (_userSession && _userSession.validtime > [[NSDate date] timeIntervalSince1970]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)needFlushSession {
    if ([self isUserSessionValid]) {
        NSTimeInterval time = _userSession.validtime - [[NSDate date] timeIntervalSince1970];
        if (time < (60 * 60 * 24)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (DXUserSession *)currentUserSession {
    if ([self isUserSessionValid]) {
        return _userSession;
    } else {
        return nil;
    }
}

- (void)setUserSession:(DXUserSession *)userSession {
    _userSession = userSession;
    if (userSession) {
        BOOL success = [[DXArchiveService sharedService] archiveObject:userSession ForLoginUser:nil forcePersist:YES];
        if (success) {
            DXClientLog(@"UserSession归档成功");
        } else {
            DXClientLog(@"UserSession归档失败");
        }
    }
}

- (void)cleanUserSession {
    if (_userSession) {
        _userSession = nil;
    }
    [[DXArchiveService sharedService] cleanObject:NSStringFromClass([DXUserSession class]) ForLoginUser:nil forcePersist:YES];
}


- (void)prepareForWorking:(void (^)(NSError *))completion {
    _prepared = YES;
    
    // 获取默认的话题id
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *topicID = [userDefaults stringForKey:DX_DEFAULTS_KEY_DEFAULT_TOPIC_ID];
    
    if (!topicID) {
        [self getDefaultTopicID:^(NSString *topic_id, NSError *error) {
            if (topic_id) {
                [userDefaults setObject:topic_id forKey:DX_DEFAULTS_KEY_DEFAULT_TOPIC_ID];
                [userDefaults synchronize];
            }
        }];
    }
    
    // 更新sid
    if ([self needFlushSession]) {
        [self flushUserSession:nil];
    }
    
    if (completion) {
        completion(nil);
    }
}

- (void)didReceiveUserNeedReloginNotification:(NSNotification *)noti {
    [self logoutWithResult:nil];
}

- (void)updateSessionAvatar:(NSString *)avatar {
    DXUserSession * userSession = self.currentUserSession;
    userSession.avatar = avatar;
    [self setUserSession:userSession];
}

- (void)updateSessionNick:(NSString *)nick {
    DXUserSession * userSession = self.currentUserSession;
    userSession.nick = nick;
    [self setUserSession:userSession];
}

- (void)updateSessionLocation:(NSString *)location {
    DXUserSession * userSession = self.currentUserSession;
    userSession.location = location;
    [self setUserSession:userSession];
}

- (void)updateSessionDefaultTopicID:(NSString *)defaultTopicID {
    DXUserSession * userSession = self.currentUserSession;
    userSession.defaultTopicID = defaultTopicID;
    [self setUserSession:userSession];
}

- (void)updateSessionSid:(NSString *)sid validtime:(NSTimeInterval)validtime {
    DXUserSession * userSession = self.currentUserSession;
    userSession.sid = sid;
    userSession.validtime = validtime;
    [self setUserSession:userSession];
}

/*
- (void)updateSessionGender:(DXUserGenderType)gender {
    DXUserSession * userSession = self.currentUserSession;
    userSession.gender = gender;
    [self setUserSession:userSession];
}
*/

#pragma mark - <DXClientDelegate>

- (NSDictionary *)client:(DXClient *)client prepareSignParamsWithRequest:(DXClientRequest *)request {
    if ([self isUserSessionValid]) {
        return [self.currentUserSession toObjectDictionary];
    } else {
        return nil;
    }
}

/*****************************************************************************
 *
 * 用户相关操作
 *
 *****************************************************************************/

#pragma mark - 用户注册、登录相关操作

- (void)isEmail:(NSString *)email valid:(void (^)(BOOL, NSError *))result {
    DXUserValidateRequest * request = [DXUserValidateRequest requestWithApi:DXClientApi_UserValidate];
    [request validate:DXUserValidateTypeEmail value:email];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (result) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(result(NO, err));
            } else {
                DXUserValidateResponse * validateResp = (DXUserValidateResponse *)response;
                DX_CALL_ASYNC_MQ(result(validateResp.status, nil));
            }
        }
    }];
}

- (void)isUsername:(NSString *)username valid:(void (^)(BOOL, NSError *))result {
    DXUserValidateRequest * request = [DXUserValidateRequest requestWithApi:DXClientApi_UserValidate];
    [request validate:DXUserValidateTypeUserName value:username];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (result) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(result(NO, err));
            } else {
                DXUserValidateResponse * validateResp = (DXUserValidateResponse *)response;
                DX_CALL_ASYNC_MQ(result(validateResp.status, nil));
            }
        }
    }];
}

- (void)isMobile:(NSString *)mobile valid:(void (^)(BOOL, NSError *))result {
    DXUserValidateRequest * request = [DXUserValidateRequest requestWithApi:DXClientApi_UserValidate];
    [request validate:DXUserValidateTypeMobile value:mobile];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (result) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(result(NO, err));
            } else {
                DXUserValidateResponse * validateResp = (DXUserValidateResponse *)response;
                DX_CALL_ASYNC_MQ(result(validateResp.status, nil));
            }
        }
    }];
}

- (void)registerUser:(DXUserRegisterInfo *)userRegisterInfo result:(void (^)(BOOL, NSError *))resultBlock {
    DXUserRegisterRequest * request = [DXUserRegisterRequest requestWithApi:DXClientApi_UserRegister];
    [request setUserRegister:userRegisterInfo];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, err));
            } else {
                DXUserRegisterResponse * registerResp = (DXUserRegisterResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(registerResp.status, nil));
            }
        }
    }];
}

- (void)login:(DXUserLoginInfo *)loginInfo result:(void (^)(DXUserSession *, NSError *))resultBlock {
    DXUserLoginRequest * request = [DXUserLoginRequest requestWithApi:DXClientApi_UserLogin];
    [request setLoginInfo:loginInfo];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXUserLoginResponse * loginResp = (DXUserLoginResponse *)response;
        DXUserSession * session = nil;
        NSError * err = [response error];
        if (!err) {
            session = [DXUserSession new];
            session.uid = loginResp.uid;
            session.sid = loginResp.sid;
            session.validtime = loginResp.validtime;
            session.nick = loginResp.nick;
            session.avatar = loginResp.avatar;
            session.verified = loginResp.verified;
            [self setUserSession:session];
            DX_CALL_ASYNC_MQ({
                [[NSNotificationCenter defaultCenter] postNotificationName:DXDongXiApiNotificationUserDidLogin object:nil];
            });
        } else {
            [self setUserSession:nil];
        }
        
        if (resultBlock) {
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DX_CALL_ASYNC_MQ(resultBlock(session, nil));
            }
        }
    }];
}

- (void)login:(DXUserLoginInfo *)loginInfo isNewRegistered:(BOOL)newRegistered result:(void (^)(DXUserSession *, NSError *))resultBlock {
    DXUserLoginRequest * request = [DXUserLoginRequest requestWithApi:DXClientApi_UserLogin];
    [request setLoginInfo:loginInfo];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXUserLoginResponse * loginResp = (DXUserLoginResponse *)response;
        DXUserSession * session = nil;
        NSError * err = [response error];
        if (!err) {
            session = [DXUserSession new];
            session.uid = loginResp.uid;
            session.sid = loginResp.sid;
            session.validtime = loginResp.validtime;
            session.nick = loginResp.nick;
            session.avatar = loginResp.avatar;
            session.verified = loginResp.verified;
            [self setUserSession:session];
            DX_CALL_ASYNC_MQ({
                [[NSNotificationCenter defaultCenter] postNotificationName:DXDongXiApiNotificationUserDidLogin object:@(newRegistered)];
            });
        } else {
            [self setUserSession:nil];
        }
        
        if (resultBlock) {
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DX_CALL_ASYNC_MQ(resultBlock(session, nil));
            }
        }
    }];
}

- (void)logoutWithResult:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXUserLogoutRequest * request = [DXUserLogoutRequest requestWithApi:DXClientApi_UserLogout];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXUserLogoutResponse * logoutResponse = (DXUserLogoutResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(logoutResponse.status, nil));
                }
            }
        }];
    } else {
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(YES, nil));
        }
    }
    [self cleanUserSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:DXDongXiApiNotificationUserDidLogout object:self];
}

- (void)sendSms:(DXUserSms *)sms result:(void (^)(BOOL, NSError *))resultBlock {
    DXUserSendSmsRequest * request = [DXUserSendSmsRequest requestWithApi:DXClientApi_UserSendSms];
    [request setSms:sms];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, err));
            } else {
                DXUserSendSmsResponse * smsResponse = (DXUserSendSmsResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(smsResponse.status, nil));
            }
        }
    }];
}

- (void)checkSms:(DXUserSmsCheck *)smsCheck result:(void (^)(BOOL, NSError *))resultBlock {
    NSAssert(smsCheck, @"参数smsCheck不能为空");
    DXUserCheckSmsRequest * request = [DXUserCheckSmsRequest requestWithApi:DXClientAPi_UserCheckSms];
    [request setSmsCheck:smsCheck];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, err));
            } else {
                DXUserCheckSmsResponse * smsCheckResponse = (DXUserCheckSmsResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(smsCheckResponse.status, nil));
            }
        }
    }];
}

- (void)checkResetPasswordSmsCode:(NSString *)code forUser:(NSString *)uid result:(void (^)(BOOL, NSError *))resultBlock {
    NSAssert(code != nil, @"code 必须不为空");
    NSAssert(uid != nil, @"uid 必须不为空");
    
    DXUserCheckResetSmsRequest * request  = [DXUserCheckResetSmsRequest requestWithApi:DXClientApi_UserCheckResetSms];
    [request setValue:code forKey:@"code"];
    [request setValue:uid forKey:@"uid"];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, err));
            } else {
                DXUserCheckResetSmsResponse * smsCheckResponse = (DXUserCheckResetSmsResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(smsCheckResponse.status, nil));
            }
        }
    }];
}

- (void)flushUserSession:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXUserFlushSessionRequest *request = [DXUserFlushSessionRequest requestWithApi:DXClientApi_UserFlushSession];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        request.priority = DXClientRequestPriorityHigh;
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            NSError *error = [response error];
            if (error) {
                if (resultBlock) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                }
            } else {
                NSDictionary *data = [response data];
                NSString *sid = [data objectForKey:@"sid"];
                NSTimeInterval validtime = [[data objectForKey:@"validtime"] doubleValue];
                [self updateSessionSid:sid validtime:validtime];
                if (resultBlock) {
                    DX_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

#pragma mark - 微信登录相关操作

- (void)loginWithWechatLoginInfo:(DXWechatLoginInfo *)loginInfo result:(void (^)(DXWechatLoginStatus, DXUserSession *, NSError *))resultBlock {
    DXWxauthorizerLoginRequest *request = [DXWxauthorizerLoginRequest requestWithApi:DXClientApi_WxauthorizerLogin];
    request.loginInfo = loginInfo;
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        NSError *error = [response error];
        DXWechatLoginStatus loginStatus = -1;
        DXUserSession *session = nil;
        if (!error) {
            DXWxauthorizerLoginResponse *loginResponse = (DXWxauthorizerLoginResponse *)response;
            loginStatus = loginResponse.status;
            if (loginStatus == DXWechatLoginStatusSuccess) {
                session = [DXUserSession new];
                session.uid = loginResponse.uid;
                session.sid = loginResponse.sid;
                session.validtime = loginResponse.validtime;
                session.nick = loginResponse.nick;
                session.avatar = loginResponse.avatar;
                session.verified = loginResponse.verified;
                [self setUserSession:session];
                DX_CALL_ASYNC_MQ({
                    [[NSNotificationCenter defaultCenter] postNotificationName:DXDongXiApiNotificationUserDidLogin object:nil];
                });
            } else {
                [self setUserSession:nil];
            }
            
        } else {
            loginStatus = DXWechatLoginStatusFailed;
            [self setUserSession:nil];
        }
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(loginStatus, session, error));
        }
    }];
}

- (void)sendWechatSms:(DXUserSms *)sms result:(void (^)(BOOL, NSError *))resultBlock {
    DXWxauthorizerCaptchaRequest *request = [DXWxauthorizerCaptchaRequest requestWithApi:DXClientApi_WxauthorizerCaptcha];
    request.sms = sms;
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, error));
            } else {
                DXWxauthorizerCaptchaResponse *captchaResponse = (DXWxauthorizerCaptchaResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(captchaResponse.status, nil));
            }
        }
    }];
}

- (void)registerWechatUser:(DXWechatRegisterInfo *)registerInfo result:(void (^)(DXWechatRegisterStatus, DXUserSession *, NSError *))resultBlock {
    DXWxauthorizerRegisterAndLoginRequest *request = [DXWxauthorizerRegisterAndLoginRequest requestWithApi:DXClientApi_WxauthorizerRegisterAndLogin];
    request.timeout = 60;
    request.wxRegisterInfo = registerInfo;
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        NSError *error = [response error];
        DXWechatRegisterStatus registerStatus = -1;
        DXUserSession *session = nil;
        if (!error) {
            DXWxauthorizerRegisterAndLoginResponse *registerResponse = (DXWxauthorizerRegisterAndLoginResponse *)response;
            registerStatus = [registerResponse status];
            if (registerStatus == DXWechatRegisterStatusSuccess) {
                session = [DXUserSession new];
                session.uid = registerResponse.uid;
                session.sid = registerResponse.sid;
                session.validtime = registerResponse.validtime;
                session.nick = registerResponse.nick;
                session.avatar = registerResponse.avatar;
                session.verified = registerResponse.verified;
                [self setUserSession:session];
                DX_CALL_ASYNC_MQ({
                    [[NSNotificationCenter defaultCenter] postNotificationName:DXDongXiApiNotificationUserDidLogin object:nil];
                });
            } else {
                [self setUserSession:nil];
            }
        } else {
            registerStatus = DXWechatRegisterStatusFailed;
            [self setUserSession:nil];
        }
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(registerStatus, session, error));
        }
    }];
}

#pragma mark - 用户密码相关操作

- (void)changePasswordWithInfo:(DXUserPasswordChangeInfo *)info result:(void (^)(DXUserChangePasswordStatus, NSError *))resultBlock {
    NSAssert(info != nil, @"info不可为nil");
    if ([self isUserSessionValid]) {
        DXUserChangePwdRequest * request = [DXUserChangePwdRequest requestWithApi:DXClientAPi_UserChangePwd];
        [request setValue:info.oldpassword forKey:@"oldpassword"];
        [request setValue:info.newpassword forKey:@"newpassword"];
        [request setValue:info.key forKey:@"key"];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(DXUserChangePasswordErrorOccurred, err));
                } else {
                    DXUserChangePwdResponse * changePwdResponse = (DXUserChangePwdResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(changePwdResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(DXUserChangePasswordErrorOccurred, sessionError));
        }
    }
}

- (void)sendResetPasswordSms:(DXUserSms *)sms result:(void (^)(DXUserResetPassSmsStatus, NSString *, NSString *, NSError *))resultBlock {
    NSAssert(sms != nil, @"sms不可为nil");
    DXUserResetSendSmsRequest * request = [DXUserResetSendSmsRequest requestWithApi:DXClientAPi_UserResetSendSms];
    [request setValue:sms.mobile forKey:@"mobile"];
    [request setValue:sms.key forKey:@"key"];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(DXUserResetPassSmsFailed, nil, nil, err));
            } else {
                DXUserResetSendSmsResponse * resetSendSmsResponse = (DXUserResetSendSmsResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(resetSendSmsResponse.status,
                                             resetSendSmsResponse.username,
                                             resetSendSmsResponse.uid,
                                             nil));
            }
        }
    }];
}

- (void)resetPasswordWithInfo:(DXUserPasswordResetInfo *)info result:(void (^)(DXUserResetPasswordStatus, NSError *))resultBlock {
    NSAssert(info != nil, @"info不可为nil");
    DXUserResetPwdRequest * request = [DXUserResetPwdRequest requestWithApi:DXClientAPi_UserResetPwd];
    [request setValue:info.uid forKey:@"uid"];
    [request setValue:info.key forKey:@"key"];
    [request setValue:info.code forKey:@"code"];
    [request setValue:info.newpassword forKey:@"newpassword"];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(DXUserResetPasswordFailed, err));
            } else {
                DXUserResetPwdResponse * resetPwdResponse = (DXUserResetPwdResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(resetPwdResponse.status, nil));
            }
        }
    }];
}


#pragma mark - 用户资料相关操作

- (void)getProfileOfUser:(NSString *)uid result:(void (^)(DXUserProfile *, NSError *))resultBlock {
    DXUserProfileRequest * request = [DXUserProfileRequest requestWithApi:DXClientAPi_UserProfile];
    request.uid = uid;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXUserProfileResponse * profileResponse = (DXUserProfileResponse *)response;
                NSDictionary * profileData = [profileResponse data];
                DXUserProfile * profile  = [[DXUserProfile alloc] initWithObjectDictionary:profileData];
                DX_CALL_ASYNC_MQ(resultBlock(profile, nil));
            }
        }
    }];
}


- (void)getProfileOfUserByNick:(NSString *)nick result:(void (^)(DXUserProfile *, NSError *))resultBlock {
    DXUserProfileBynickRequest * request = [DXUserProfileBynickRequest requestWithApi:DXClientAPi_UserProfileBynick];
    [request setValue:nick forKey:@"nick"];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXUserProfileBynickResponse * profileResponse = (DXUserProfileBynickResponse *)response;
                NSDictionary * profileData = [profileResponse data];
                DXUserProfile * profile  = [[DXUserProfile alloc] initWithObjectDictionary:profileData];
                DX_CALL_ASYNC_MQ(resultBlock(profile, nil));
            }
        }
    }];
}

- (void)getUserInfoListWithUserIDs:(NSArray *)userIDs result:(void (^)(DXUserWrapper *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXUserProfileAllRequest *request = [DXUserProfileAllRequest requestWithApi:DXClientAPi_UserProfileAll];
        request.uid_all = userIDs;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary *data = [response data];
                    DXUserWrapper *userWrapper = [[DXUserWrapper alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(userWrapper, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)changeProfile:(DXUserProfileChange *)profileChange result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        typeof(self) __weak weakSelf = self;
        DXUserChangeProfileRequest * request = [DXUserChangeProfileRequest requestWithApi:DXClientAPi_UserChangeProfile];
        request.profileChange = profileChange;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXUserChangeProfileResponse * profileResponse = (DXUserChangeProfileResponse *)response;
                    if (profileResponse.status) {
                        if (profileChange.username) {
                            [weakSelf updateSessionNick:profileChange.username];
                        }
                        
                        if (profileChange.location) {
                            [weakSelf updateSessionLocation:profileChange.location];
                        }
                        
                        /*
                        if (profileChange.gender) {
                            [weakSelf updateSessionGender:[profileChange.gender integerValue]];
                        }
                         */
                    }
                    DX_CALL_ASYNC_MQ(resultBlock(profileResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)changeAvatar:(NSURL *)avatarURL result:(void (^)(BOOL, NSString *, NSError *))resultBlock {
    NSAssert([avatarURL isFileURL], @"头像文件地址只能使用本地文件地址");
    
    typeof(self) __weak weakSelf = self;
    if ([self isUserSessionValid]) {
        DXUserChangeAvatarRequest * request = [DXUserChangeAvatarRequest requestWithApi:DXClientAPi_UserChangeAvatar];
        [request addFile:avatarURL];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, nil, err));
                } else {
                    DXUserChangeAvatarResponse * changeAvatarResponse = (DXUserChangeAvatarResponse *)response;
                    if (changeAvatarResponse.status) {
                        [weakSelf updateSessionAvatar:changeAvatarResponse.url];
                    }
                    DX_CALL_ASYNC_MQ(resultBlock(changeAvatarResponse.status, changeAvatarResponse.url, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, nil, sessionError));
        }
    }
}

- (void)changeCover:(NSURL *)coverURL result:(void (^)(BOOL, NSString *, NSError *))resultBlock {
    NSAssert([coverURL isFileURL], @"图片文件地址只能使用本地文件地址");
    if ([self isUserSessionValid]) {
        DXUserChangeCoverRequest * request = [DXUserChangeCoverRequest requestWithApi:DXClientAPi_UserChangeCover];
        [request addFile:coverURL];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, nil, err));
                } else {
                    DXUserChangeCoverResponse * changeCoverResponse = (DXUserChangeCoverResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(changeCoverResponse.status, changeCoverResponse.url, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, nil, sessionError));
        }
    }
}

- (void)sendUserFeeback:(DXUserFeedback *)feedback result:(void (^)(BOOL, NSError *))resultBlock {
    DXUserFeedbackRequest * request = [DXUserFeedbackRequest requestWithApi:DXClientApi_UserFeedback];
    [request setValue:feedback.contact forKey:@"contact"];
    [request setValue:feedback.txt forKey:@"txt"];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, err));
            } else {
                DXUserFeedbackResponse * feedBackResponse = (DXUserFeedbackResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(feedBackResponse.status, nil));
            }
        }
    }];
}

- (void)checkUserInfoAndAppVersionWithCheckType:(DXUserCheckType)checkType result:(void (^)(DXUserCheckResult *, NSError *))resultBlock {
    DXUserUserCheckRequest *request = [DXUserUserCheckRequest requestWithApi:DXClientApi_UserUserCheck];
    request.type = checkType;
    request.build = [DXGetAppBuildVersion() longLongValue];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXUserUserCheckResponse *userCheckResponse = (DXUserUserCheckResponse *)response;
        if (resultBlock) {
            NSError *error = [userCheckResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [userCheckResponse data];
                DXUserCheckResult *userCheckResult = [[DXUserCheckResult alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(userCheckResult, nil));
            }
        }
    }];
}

#pragma mark - 用户关系相关操作

- (void)followUser:(NSString *)uid result:(void (^)(BOOL, DXUserRelationType, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXUserFollowRequest * request = [DXUserFollowRequest requestWithApi:DXClientAPi_UserFollow];
        request.uid = uid;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXUserFollowResponse * followResponse = (DXUserFollowResponse * )response;
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, 0, err));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(followResponse.status, followResponse.relations, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, 0, sessionError));
        }
    }
}

- (void)unfollowUser:(NSString *)uid result:(void (^)(BOOL, DXUserRelationType, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXUserUnfollowRequest * request = [DXUserUnfollowRequest requestWithApi:DXClientAPi_UserUnfollow];
        request.uid = uid;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXUserUnfollowResponse * unfollowResponse = (DXUserUnfollowResponse * )response;
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, 0, err));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(unfollowResponse.status, unfollowResponse.relations, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, 0, sessionError));
        }
    }
}

- (void)getFollowListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXUserWrapper *, NSError *))resultBlock {
    DXUserFollowListRequest * request = [DXUserFollowListRequest requestWithApi:DXClientAPi_UserFollowList];
    request.uid = uid;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXUserFollowListResponse * followListResponse = (DXUserFollowListResponse *)response;
                NSDictionary * data = [followListResponse data];
                DXUserWrapper * userWrapper = [[DXUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(userWrapper, nil));
            }
        }
    }];
}

- (void)getFanListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXUserWrapper *, NSError *))resultBlock {
    DXUserFansListRequest * request = [DXUserFansListRequest requestWithApi:DXClientAPi_UserFansList];
    request.uid = uid;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXUserFansListResponse * fansListResponse = (DXUserFansListResponse *)response;
                NSDictionary * data = [fansListResponse data];
                DXUserWrapper * userWrapper = [[DXUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(userWrapper, nil));
            }
        }
    }];
}

#pragma mark - 邀请码相关

- (void)checkInvitationStatusWithResult:(void (^)(BOOL, NSError *))resultBlock {
    
    DXClientCheckInviteRequest *request = [DXClientCheckInviteRequest requestWithApi:DXClientApi_ClientCheckInvite];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, error));
            } else {
                DXClientCheckInviteResponse *checkInviteResponse = (DXClientCheckInviteResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(checkInviteResponse.status, nil));
            }
        }
    }];
}

- (void)getUserCouponList:(void (^)(DXUserCouponWrapper *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXUserCouponListRequest *request = [DXUserCouponListRequest requestWithApi:DXClientAPi_UserCouponList];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    DXUserCouponListResponse *couponListResponse = (DXUserCouponListResponse *)response;
                    NSDictionary *data = [couponListResponse data];
                    DXUserCouponWrapper *userCouponWrapper = [[DXUserCouponWrapper alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(userCouponWrapper, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)sendUserCouponWithCode:(NSString *)code result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXUserCouponSendRequest *request = [DXUserCouponSendRequest requestWithApi:DXClientAPi_UserCouponSend];
        request.code = code;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXUserCouponSendResponse *couponSendResponse = (DXUserCouponSendResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(couponSendResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)useUserCouponWithCode:(NSString *)code result:(void (^)(BOOL, NSError *))resultBlock {
    
    DXUserCouponUseRequest *request = [DXUserCouponUseRequest requestWithApi:DXClientAPi_UserCouponUse];
    request.code = code;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, error));
            } else {
                DXUserCouponUseResponse *couponUseResponse = (DXUserCouponUseResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(couponUseResponse.status, nil));
            }
        }
    }];
}

- (void)getUserCouponWithMobile:(NSString *)mobile result:(void (^)(BOOL, NSError *))resultBlock {
    
    DXUserCouponGetRequest *request = [DXUserCouponGetRequest requestWithApi:DXClientAPi_UserCouponGet];
    request.mobile = mobile;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, error));
            } else {
                DXUserCouponGetResponse *couponGetResponse = (DXUserCouponGetResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(couponGetResponse.status, nil));
            }
        }
    }];
}

#pragma mark - 图片轮播
- (void)getPictureShowList:(void (^)(DXPictureShowWrapper *, NSError *))resultBlock {
    
    DXClientShowRequest *request = [DXClientShowRequest requestWithApi:DXClientApi_ClientShow];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                DXClientShowResponse *showResponse = (DXClientShowResponse *)response;
                NSDictionary *data = [showResponse data];
                DXPictureShowWrapper *pictureShowWrapper = [[DXPictureShowWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(pictureShowWrapper, nil));
            }
        }
    }];
}

/*****************************************************************************
 *
 * Feed相关操作
 *
 *****************************************************************************/

#pragma mark - Feed相关操作

- (void)getTimelineHotList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTimelineFeedWrapper *, NSError *))resultBlock {
    DXTimelineHotListRequest * request = [DXTimelineHotListRequest requestWithApi:DXClientApi_TimelineHotList];
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXTimelineHotListResponse * hotListResponse = (DXTimelineHotListResponse *)response;
                NSDictionary * data = [hotListResponse data];
                DXTimelineFeedWrapper * feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
            }
        }
    }];
}

- (void)getTimelineHotList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID userTimestamp:(NSUInteger)userTimestamp topicTimestamp:(NSUInteger)topicTimestamp result:(void (^)(DXTimelineFeedWrapper *, NSError *))resultBlock {
    DXTimelineHotListRequest * request = [DXTimelineHotListRequest requestWithApi:DXClientApi_TimelineHotList];
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.recommend_user_timestamp = userTimestamp;
    request.recommend_topic_timestamp = topicTimestamp;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXTimelineHotListResponse * hotListResponse = (DXTimelineHotListResponse *)response;
                NSDictionary * data = [hotListResponse data];
                DXTimelineFeedWrapper * feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
            }
        }
    }];
}

- (void)getTimelinePublicList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTimelineFeedWrapper *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelinePublicListRequest * request = [DXTimelinePublicListRequest requestWithApi:DXClientApi_TimelinePublicList];
        request.flag = pullType;
        request.count = count;
        request.last_id = ID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, err));
                } else {
                    DXTimelinePublicListResponse * publicListResponse = (DXTimelinePublicListResponse *)response;
                    NSDictionary * data = [publicListResponse data];
                    DXTimelineFeedWrapper * feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)getTimelineNewestList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTimelineFeedWrapper *, NSError *))resultBlock {
    DXFeedTimelineRequest *request = [DXFeedTimelineRequest requestWithApi:DXClientApi_FeedTimeline];
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.filter = @"all";
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXFeedTimelineResponse *timelineResponse = (DXFeedTimelineResponse *)response;
        if (resultBlock) {
            NSError *error = [timelineResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [timelineResponse data];
                DXTimelineFeedWrapper *feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
            }
        }
    }];
}

- (void)getPrivateFeedListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTimelineFeedWrapper *, NSError *))resultBlock {
    DXTimelinePrivateListRequest * request = [DXTimelinePrivateListRequest requestWithApi:DXClientApi_TimelinePrivateList];
    request.uid = uid;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXTimelinePrivateListResponse * privateListResponse = (DXTimelinePrivateListResponse *)response;
                NSDictionary * data = [privateListResponse data];
                DXTimelineFeedWrapper * feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
            }
        }
    }];
}

- (void)getSavedFeedListOfUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTimelineFeedWrapper *, NSError *))resultBlock {
    DXTimelineSaveListRequest * request = [DXTimelineSaveListRequest requestWithApi:DXClientApi_TimelineSaveList];
    request.uid = uid;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXTimelineSaveListResponse * saveListResponse = (DXTimelineSaveListResponse *)response;
                NSDictionary * data = [saveListResponse data];
                DXTimelineFeedWrapper * feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
            }
        }
    }];
}

- (void)getDefaultTopicID:(void(^)(NSString *, NSError *))resultBlock {
    DXClientGetDefaultTopicIdRequest * request = [DXClientGetDefaultTopicIdRequest requestWithApi:DXClientApi_ClientGetDefaultTopicId];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (!err) {
                DXClientGetDefaultTopicIdResponse * defaultTopicIdResponse = (DXClientGetDefaultTopicIdResponse *)response;
                DX_CALL_ASYNC_MQ(resultBlock(defaultTopicIdResponse.topic_id, nil));
            } else {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            }
        }
    }];
}

- (void)getTopics:(void (^)(NSArray *, NSError *))resultBlock {
    DXTimelineTopicsRequest * request = [DXTimelineTopicsRequest requestWithApi:DXClientApi_TimelineTopics];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                DXTimelineTopicsResponse * topicsResponse = (DXTimelineTopicsResponse *)response;
                NSDictionary * data = [topicsResponse data];
                if ([data objectForKey:@"topic_category"]) {
                    NSArray * topicArray = [data objectForKey:@"topic_category"];
                    NSMutableArray * topics = [NSMutableArray array];
                    for (NSDictionary * topicInfo in topicArray) {
                        DXTopic * topic = [[DXTopic alloc] initWithObjectDictionary:topicInfo];
                        [topics addObject:topic];
                    }
                    DX_CALL_ASYNC_MQ(resultBlock([topics copy], nil));
                } else {
                    DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorServerInternalError andDescription:@"服务器响应未包含topic_category字段"];
                    DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
                }
            }
        }
    }];
}

- (void)getTopAndHotTopicListWithLastID:(NSString *)lastID pullType:(DXDataListPullType)pullType count:(NSUInteger)count result:(void (^)(DXTopAndHotTopicList *, NSError *))resultBlock {
    DXTopicTopicsRequest *request = [DXTopicTopicsRequest requestWithApi:DXClientApi_TopicTopics];
    request.last_id = lastID;
    request.flag = pullType;
    request.count = count;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXTopicTopicsResponse *topicsResponse = (DXTopicTopicsResponse *)response;
        if (resultBlock) {
            NSError *error = [topicsResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [topicsResponse data];
                DXTopAndHotTopicList *topAndHotTopicList = [[DXTopAndHotTopicList alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(topAndHotTopicList, nil));
            }
        }
    }];
}

- (void)getTopAndHotTopicList:(void (^)(DXTopAndHotTopicList *, NSError *))resultBlock {
    DXTopicTopicsRequest *request = [DXTopicTopicsRequest requestWithApi:DXClientApi_TopicTopics];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXTopicTopicsResponse *topicsResponse = (DXTopicTopicsResponse *)response;
        if (resultBlock) {
            NSError *error = [topicsResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [topicsResponse data];
                DXTopAndHotTopicList *topAndHotTopicList = [[DXTopAndHotTopicList alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(topAndHotTopicList, nil));
            }
        }
    }];
}

- (void)getCollectedTopicListWithLastID:(NSString *)lastID pullType:(DXDataListPullType)pullType count:(NSUInteger)count result:(void (^)(DXCollectedTopicList *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTopicTopicLikesRequest *request = [DXTopicTopicLikesRequest requestWithApi:DXClientApi_TopicTopicLikes];
        request.last_id = lastID;
        request.flag = pullType;
        request.count = count;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTopicTopicLikesResponse *topicLikesResponse = (DXTopicTopicLikesResponse *)response;
            if (resultBlock) {
                NSError *error = [topicLikesResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary *data = [topicLikesResponse data];
                    DXCollectedTopicList *collectedTopicList = [[DXCollectedTopicList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(collectedTopicList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)collectTopicWithTopicID:(NSString *)topicID result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTopicCreateTopicLikeRequest *request = [DXTopicCreateTopicLikeRequest requestWithApi:DXClientApi_TopicCreateTopicLike];
        request.topic_id = topicID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTopicCreateTopicLikeResponse *createTopicLikeResponse = (DXTopicCreateTopicLikeResponse *)response;
            if (resultBlock) {
                NSError *error = [createTopicLikeResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(createTopicLikeResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)cancelCollectTopicWithTopicID:(NSString *)topicID result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTopicCancelTopicLikeRequest *request = [DXTopicCancelTopicLikeRequest requestWithApi:DXClientApi_TopicCancelTopicLike];
        request.topic_id = topicID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTopicCancelTopicLikeResponse *cancelTopicLikeResponse = (DXTopicCancelTopicLikeResponse *)response;
            if (resultBlock) {
                NSError *error = [cancelTopicLikeResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(cancelTopicLikeResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)postToTopic:(DXTopicPost *)topicPost progress:(void(^)(float percent))progressBlock result:(void (^)(DXTimelineFeed *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineCreateRequest * request = [DXTimelineCreateRequest requestWithApi:DXClientApi_TimelineCreate];
        request.topicPost = [topicPost toObjectDictionary:YES];
        request.photoURLs = [topicPost photoURLs];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:^(float percent) {
            if (progressBlock) {
                DX_CALL_ASYNC_MQ(progressBlock(percent));
            }
        } finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, err));
                } else {
                    NSDictionary * data = [response data];
                    DXTimelineFeed * feed = [[DXTimelineFeed alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(feed, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)getTopicFeedList:(NSString *)topicID pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTopicFeedList *, NSError *))resultBlock {
    DXTimelineTopicListRequest * request = [DXTimelineTopicListRequest requestWithApi:DXClientApi_TimelineTopicList];
    request.topic_id = topicID;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.type = DXTopicFeedListTypeNew;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                NSDictionary * data = [response data];
                DXTopicFeedList * topicFeedList = [[DXTopicFeedList alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(topicFeedList, nil));
            }
        }
    }];
}

- (void)getHotTopicFeedList:(NSString *)topicID pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTopicFeedList *, NSError *))resultBlock {
    DXTimelineTopicListRequest * request = [DXTimelineTopicListRequest requestWithApi:DXClientApi_TimelineTopicList];
    request.topic_id = topicID;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.type = DXTopicFeedListTypeHot;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                NSDictionary * data = [response data];
                DXTopicFeedList * topicFeedList = [[DXTopicFeedList alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(topicFeedList, nil));
            }
        }
    }];
}

- (void)getTopicInviteFollowList:(NSString *)topicID ofUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTopicInviteFollowList *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineTopicFollowListRequest * request = [DXTimelineTopicFollowListRequest requestWithApi:DXClientApi_TimelineTopicFollowList];
        request.topic_id = topicID;
        request.uid = uid;
        request.flag = pullType;
        request.count = count;
        request.last_id = ID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, err));
                } else {
                    NSDictionary * data = [response data];
                    DXTopicInviteFollowList * topicFollowList = [[DXTopicInviteFollowList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(topicFollowList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}


- (void)getTopicInviteFansList:(NSString *)topicID ofUser:(NSString *)uid pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXTopicInviteFansList *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineTopicFansListRequest * request = [DXTimelineTopicFansListRequest requestWithApi:DXClientApi_TimelineTopicFansList];
        request.topic_id = topicID;
        request.uid = uid;
        request.flag = pullType;
        request.count = count;
        request.last_id = ID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, err));
                } else {
                    NSDictionary * data = [response data];
                    DXTopicInviteFansList * topicFansList = [[DXTopicInviteFansList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(topicFansList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}


- (void)inviteUser:(NSString *)uid joinTopic:(NSString *)topicID result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineTopicInviteRequest * request = [DXTimelineTopicInviteRequest requestWithApi:DXClientApi_TimelineTopicInvite];
        request.uid = uid;
        request.topic_id = topicID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTimelineTopicInviteResponse * inviteResponse = (DXTimelineTopicInviteResponse * )response;
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, nil));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(inviteResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)getTopicRankUserWrapperByTopicID:(NSString *)topicID result:(void (^)(DXTopicRankUserWrapper *, NSError *))resultBlock {
    DXTopicRankingListRequest *request = [DXTopicRankingListRequest requestWithApi:DXClientApi_TopicRankingList];
    request.topic_id = topicID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXTopicRankingListResponse *rankingListResponse = (DXTopicRankingListResponse *)response;
        if (resultBlock) {
            NSError *error = [rankingListResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [rankingListResponse data];
                DXTopicRankUserWrapper *rankUserWrapper = [[DXTopicRankUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(rankUserWrapper, nil));
            }
        }
    }];
}

#pragma mark 点赞

- (void)likeFeedWithFeedID:(NSString *)feedID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXTimelineLikeRequest *request = [DXTimelineLikeRequest requestWithApi:DXClientApi_TimelineLike];
        request.fid = feedID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXTimelineLikeResponse *likeResponse = (DXTimelineLikeResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(likeResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

#pragma mark 取消赞

- (void)unlikeFeedWithFeedID:(NSString *)feedID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXTimelineUnlikeRequest *request = [DXTimelineUnlikeRequest requestWithApi:DXClientApi_TimelineUnlike];
        request.fid = feedID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXTimelineUnlikeResponse *unlikeResponse = (DXTimelineUnlikeResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(unlikeResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

#pragma mark 收藏Feed

- (void)saveFeedWithFeedID:(NSString *)feedID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXTimelineSaveRequest *request = [DXTimelineSaveRequest requestWithApi:DXClientApi_TimelineSave];
        request.fid = feedID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXTimelineSaveResponse *saveResponse = (DXTimelineSaveResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(saveResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

#pragma mark 取消收藏Feed

- (void)unsaveFeedWithFeedID:(NSString *)feedID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXTimelineUnsaveRequest *request = [DXTimelineUnsaveRequest requestWithApi:DXClientApi_TimelineUnsave];
        request.fid = feedID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXTimelineUnsaveResponse *unsaveResponse = (DXTimelineUnsaveResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(unsaveResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}


#pragma mark 根据feedID获得对应DXTimelineFeed数据

- (void)getFeedWithID:(NSString *)feedID result:(void (^)(DXTimelineFeed *, NSError *))resultBlock {
    DXTimelineGetFeedRequest * request = [DXTimelineGetFeedRequest requestWithApi:DXClientApi_TimelineGetFeed];
    [request setValue:feedID forKey:@"fid"];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary * data = [response data];
                DXTimelineFeedWrapper * feedWrapper = [[DXTimelineFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock([feedWrapper.feeds firstObject], nil));
            }
        }
    }];
}


#pragma mark 获取某个Feed的点赞用户列表

- (void)getLikeUsersOfFeed:(NSString *)feedID pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID result:(void (^)(DXUserWrapper *, NSError *))resultBlock {
    DXTimelineLikeUserListRequest * request = [DXTimelineLikeUserListRequest requestWithApi:DXClientApi_TimelineLikeUserList];
    request.fid = feedID;
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (!err) {
                NSDictionary * data = [response data];
                DXUserWrapper * users = [[DXUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(users, nil));
            } else {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            }
        }
    }];
}

#pragma mark 删除某个Feed

- (void)deleteFeedWithFeedID:(NSString *)feedID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXTimelineDeleteRequest *request = [DXTimelineDeleteRequest requestWithApi:DXClientApi_TimelineDelete];
        request.fid = feedID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXTimelineDeleteResponse *deleteResponse = (DXTimelineDeleteResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(deleteResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

#pragma mark 举报某个Feed

- (void)reportFeedWithFeedID:(NSString *)feedID type:(NSInteger)type result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXTimelineReportRequest *request = [DXTimelineReportRequest requestWithApi:DXClientApi_TimelineReport];
        request.fid = feedID;
        request.type = type;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXTimelineReportResponse *reportResponse = (DXTimelineReportResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(reportResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)postFeedIsSharedWithFeedID:(NSString *)feedID toScene:(NSString *)scene result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineShareFeedRequest *request = [DXTimelineShareFeedRequest requestWithApi:DXClientApi_TimelineShareFeed];
        request.fid = feedID;
        request.share_to = scene;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTimelineShareFeedResponse *shareFeedResponse = (DXTimelineShareFeedResponse *)response;
            if (resultBlock) {
                NSError *error = [shareFeedResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(shareFeedResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)getReferContacts:(void (^)(NSArray *, NSArray *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineRecentContactsRequest *request = [DXTimelineRecentContactsRequest requestWithApi:DXClientApi_TimelineRecentContacts];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTimelineRecentContactsResponse *contactsResponse = (DXTimelineRecentContactsResponse *)response;
            if (resultBlock) {
                NSError *error = [contactsResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, nil, error));
                } else {
                    NSDictionary *data = [contactsResponse data];
                    NSArray *recentContactsDictArray = [data objectForKey:@"recent_contacts"];
                    NSMutableArray *recentContacts = [NSMutableArray arrayWithCapacity:recentContactsDictArray.count];
                    for (NSDictionary *dict in recentContactsDictArray) {
                        DXUser *user = [[DXUser alloc] initWithObjectDictionary:dict];
                        [recentContacts addObject:user];
                        
                    }
                    NSDictionary *allContactsDict = [data objectForKey:@"follow_list"];
                    NSMutableArray *allContacts = [NSMutableArray arrayWithCapacity:allContactsDict.count];
                    for (int i=65; i<=90; i++) {
                        NSString *indexID = [NSString stringWithFormat:@"%c", i];
                        NSArray *userDictArray = [allContactsDict objectForKey:indexID];
                        if (userDictArray) {
                            DXReferUserWrapper *referUserWrapper = [[DXReferUserWrapper alloc] init];
                            referUserWrapper.indexID = indexID;
                            NSMutableArray *tempArray = [NSMutableArray array];
                            for (NSDictionary *dict in userDictArray) {
                                DXUser *user = [[DXUser alloc] initWithObjectDictionary:dict];
                                [tempArray addObject:user];
                            }
                            referUserWrapper.referUsers = [tempArray copy];
                            [allContacts addObject:referUserWrapper];
                        }
                    }
                    NSArray *otherContactsDictArray = [allContactsDict objectForKey:@"other"];
                    if (otherContactsDictArray) {
                        DXReferUserWrapper *referUserWrapper = [[DXReferUserWrapper alloc] init];
                        referUserWrapper.indexID = @"other";
                        NSMutableArray *tempArray = [NSMutableArray array];
                        for (NSDictionary *dict in otherContactsDictArray) {
                            DXUser *user = [[DXUser alloc] initWithObjectDictionary:dict];
                            [tempArray addObject:user];
                        }
                        referUserWrapper.referUsers = [tempArray copy];
                        [allContacts addObject:referUserWrapper];
                    }
                    DX_CALL_ASYNC_MQ(resultBlock([recentContacts copy], [allContacts copy], nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, nil, sessionError));
        }
    }
}

- (void)getReferTopics:(void (^)(NSArray *, NSArray *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTimelineRecentTopicsRequest *request = [DXTimelineRecentTopicsRequest requestWithApi:DXClientApi_TimelineRecentTopics];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTimelineRecentTopicsResponse *topicsResponse = (DXTimelineRecentTopicsResponse *)response;
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, nil, error));
                } else {
                    NSDictionary *data = [topicsResponse data];
                    NSArray *recentTopicDictArray = [data objectForKey:@"recent_topic"];
                    NSMutableArray *recentTopics = [NSMutableArray arrayWithCapacity:recentTopicDictArray.count];
                    for (NSDictionary *dict in recentTopicDictArray) {
                        DXTopic *referTopic = [[DXTopic alloc] initWithObjectDictionary:dict];
                        [recentTopics addObject:referTopic];
                    }
                    NSArray *allTopicDictArray = [data objectForKey:@"topic"];
                    NSMutableArray *allTopics = [NSMutableArray arrayWithCapacity:allTopicDictArray.count];
                    for (NSDictionary *dict in allTopicDictArray) {
                        DXTopic *referTopic = [[DXTopic alloc] initWithObjectDictionary:dict];
                        [allTopics addObject:referTopic];
                    }
                    DX_CALL_ASYNC_MQ(resultBlock([recentTopics copy], [allTopics copy], nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, nil, sessionError));
        }
    }
}

#pragma mark 修改feed

- (void)updateFeedWithPost:(DXTopicPost *)topicPost progress:(void (^)(float))progressBlock result:(void (^)(DXTimelineFeed *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXFeedFeedUpdateRequest * request = [DXFeedFeedUpdateRequest requestWithApi:DXClientApi_FeedFeedUpdate];
        request.topicPost = [topicPost toObjectDictionary:YES];
        request.photoURLs = [topicPost photoURLs];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:^(float percent) {
            if (progressBlock) {
                DX_CALL_ASYNC_MQ(progressBlock(percent));
            }
        } finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, err));
                } else {
                    NSDictionary * data = [response data];
                    DXTimelineFeed * feed = [[DXTimelineFeed alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(feed, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

#pragma mark - 一周红人榜

- (void)getLikeRankUserWrapper:(void (^)(DXLikeRankUserWrapper *, NSError *))resultBlock {
    DXUserLikeRankRequest *request = [DXUserLikeRankRequest requestWithApi:DXClientApi_UserLikeRank];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXUserLikeRankResponse *rankResponse = (DXUserLikeRankResponse *)response;
        if (resultBlock) {
            NSError *error = [rankResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [rankResponse data];
                DXLikeRankUserWrapper *rankUserWrapper = [[DXLikeRankUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(rankUserWrapper, nil));
            }
        }
    }];
}

/*****************************************************************************
 *
 * 活动相关操作
 *
 *****************************************************************************/

#pragma mark - 活动相关

- (void)getActivityList:(void (^)(NSArray *, NSError *))resultBlock {
    DXActivityListsRequest * request = [DXActivityListsRequest requestWithApi:DXClientApi_ActivityLists];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                NSDictionary * data = [response data];
                NSMutableArray * activityList = [NSMutableArray array];
                for (NSDictionary * activityData in [data objectForKey:@"activity_category"]) {
                    [activityList addObject:[[DXActivity alloc] initWithObjectDictionary:activityData]];
                }
                DX_CALL_ASYNC_MQ(resultBlock([activityList copy], nil));
            }
        }
    }];
}

- (void)getActivityByID:(NSString *)activity_id result:(void (^)(DXActivity *, NSError *))resultBlock {
    NSAssert(activity_id != nil, @"参数activity_id不能为nil");

    DXActivityGetDetailRequest * request = [DXActivityGetDetailRequest requestWithApi:DXClientApi_ActivityGetDetail];
    [request setValue:activity_id forKey:@"activity_id"];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                NSDictionary * data = [response data];
                DXActivity * activity = [[DXActivity alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(activity, nil));
            }
        }
    }];
}

- (void)wantToJoinActivity:(NSString *)activityID result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXActivityWantRequest * request = [DXActivityWantRequest requestWithApi:DXClientApi_ActivityWant];
        request.activity_id = activityID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXActivityWantResponse * wantResponse = (DXActivityWantResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(wantResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)remarkOnActivity:(NSString *)activityID stars:(NSUInteger)stars text:(NSString *)text result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXActivityMarkRequest * request = [DXActivityMarkRequest requestWithApi:DXClientApi_ActivityMark];
        request.activity_id = activityID;
        request.star = stars;
        request.txt = text;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXActivityMarkResponse * markResponse = (DXActivityMarkResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(markResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}




/*****************************************************************************
 *
 * 消息相关操作
 *
 *****************************************************************************/

#pragma mark - 消息相关操作
#pragma mark 检查是否有新消息
- (void)checkNewMessageResult:(void (^)(DXMessageNewDetail *, BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXMessageCheckNewRequest *request = [DXMessageCheckNewRequest requestWithApi:DXClientApi_MessageCheckNew];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            NSError *error = [response error];
            if (resultBlock) {
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, NO, error));
                } else {
                    DXMessageCheckNewResponse *newResponse = (DXMessageCheckNewResponse *)response;
                    NSDictionary *data = [response data];
                    NSDictionary *dict = [data objectForKey:@"detail"];
                    DXMessageNewDetail *newDetail = [[DXMessageNewDetail alloc] initWithObjectDictionary:dict];
                    DX_CALL_ASYNC_MQ(resultBlock(newDetail, newResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, NO, sessionError));
        }
    }
}
#pragma mark 通知服务器消息已读
- (void)postUnreadMessageDidReadWithMessageType:(DXUnreadMessageType)type result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXMessagePostReadRequest *request = [DXMessagePostReadRequest requestWithApi:DXClientApi_MessagePostRead];
        request.type = type;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            NSError *error = [response error];
            if (resultBlock) {
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXMessagePostReadResponse *postReadResponse = (DXMessagePostReadResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(postReadResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}
#pragma mark 获取通知列表
- (void)getMessageNoticeList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void (^)(DXNoticeList *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXMessageNoticeListRequest * request = [DXMessageNoticeListRequest requestWithApi:DXClientApi_MessageNoticeList];
        request.flag = pullType;
        request.count = count;
        request.last_id = lastID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            NSError *error = [response error];
            if (resultBlock) {
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary * data = [response data];
                    DXNoticeList * noticeList = [[DXNoticeList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(noticeList, nil));
                }
            }
        }];
        
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}
#pragma mark 删除通知条目
- (void)deleteMessageNoticeOrLikeByID:(NSString *)ID result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXMessageDeleteNoticeRequest *request = [DXMessageDeleteNoticeRequest requestWithApi:DXClientApi_MessageDeleteNotice];
        request.ID = ID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXMessageDeleteNoticeResponse *deleteNoticeResponse = (DXMessageDeleteNoticeResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(deleteNoticeResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}
#pragma mark 获取消息点赞列表
- (void)getMessageNoticeLikeList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void (^)(DXNoticeLikeList *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXMessageNoticeListLikeRequest *request = [DXMessageNoticeListLikeRequest requestWithApi:DXClientApi_MessageNoticeListLike];
        request.flag = pullType;
        request.count = count;
        request.last_id = lastID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary * data = [response data];
                    DXNoticeLikeList *noticeLikeList = [[DXNoticeLikeList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(noticeLikeList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}
#pragma mark 获取消息评论列表
- (void)getMessageNoticeCommentList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void (^)(DXNoticeCommentList *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXMessageNoticeListCommentRequest *request = [DXMessageNoticeListCommentRequest requestWithApi:DXClientApi_MessageNoticeListComment];
        request.flag = pullType;
        request.count = count;
        request.last_id = lastID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary * data = [response data];
                    DXNoticeCommentList *commentList = [[DXNoticeCommentList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(commentList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

/*****************************************************************************
 *
 * 私聊相关操作
 *
 *****************************************************************************/

#pragma mark - 私聊相关操作

- (void)getMessageDiscussList:(NSInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID getCount:(NSInteger)getCount result:(void (^)(DXMessageDiscussList *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXMessageDiscussListByUserRequest *request = [DXMessageDiscussListByUserRequest requestWithApi:DXClientApi_MessageDiscussListByUser];
        request.flag = pullType;
        request.count = count;
        request.last_id = lastID;
        request.get_count = getCount;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary *data = [response data];
                    DXMessageDiscussList *messageDiscussList = [[DXMessageDiscussList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(messageDiscussList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)deleteMessageDiscussByUserID:(NSString *)userID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXMessageDeleteDiscussRequest *request = [DXMessageDeleteDiscussRequest requestWithApi:DXClientApi_MessageDeleteDiscuss];
        request.uid = userID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXMessageDeleteDiscussResponse * createResponse = (DXMessageDeleteDiscussResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(createResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)messageDiscussSetReadByUserID:(NSString *)userID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXMessageDiscussSetReadRequest *request = [DXMessageDiscussSetReadRequest requestWithApi:DXClientApi_MessageDiscussSetRead];
        request.uid = userID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXMessageDiscussSetReadResponse * readResponse = (DXMessageDiscussSetReadResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(readResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)getDiscussListByUserID:(NSString *)userID count:(NSInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void (^)(DXDiscussList *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXDiscussListsByUserRequest *request = [DXDiscussListsByUserRequest requestWithApi:DXClientApi_DiscussListsByUser];
        request.flag = pullType;
        request.to = userID;
        request.count = count;
        request.last_id = lastID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary *data = [response data];
                    DXDiscussList *discussList = [[DXDiscussList alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(discussList, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)sendDiscussMsgToUserID:(NSString *)userID withText:(NSString *)text msgType:(DXDiscussMsgType)msgType isOline:(BOOL)isOline result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXDiscussCreateRequest *request = [DXDiscussCreateRequest requestWithApi:DXClientApi_DiscussCreate];
        request.to = userID;
        request.txt = text;
        request.type = msgType;
        request.online = isOline;
        request.fid = @"0";
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError * err = [response error];
                if (err) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, err));
                } else {
                    DXDiscussCreateResponse * createResponse = (DXDiscussCreateResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(createResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)getChatListWithUserID:(NSString *)userID count:(NSInteger)count messageID:(NSString *)messageID result:(void (^)(NSDictionary *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXChatChatListRequest *request = [DXChatChatListRequest requestWithApi:DXClientApi_ChatChatList];
        request.to = userID;
        request.count = count;
        request.msg_id = messageID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXChatChatListResponse *chatListResponse = (DXChatChatListResponse *)response;
            if (resultBlock) {
                NSError *error = [chatListResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock([chatListResponse data], nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)getConversations:(void (^)(NSDictionary *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXChatConversationsRequest *request = [DXChatConversationsRequest requestWithApi:DXClientApi_ChatConversations];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXChatConversationsResponse *conversationsResponse = (DXChatConversationsResponse *)response;
            if (resultBlock) {
                NSError *error = [conversationsResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock([conversationsResponse data], nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)backupMessageWithChatMessage:(DXChatMessage *)chatMessage result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXChatBackupChatRequest *request = [DXChatBackupChatRequest requestWithApi:DXClientApi_ChatBackupChat];
        request.type = chatMessage.type;
        request.chat_type = chatMessage.chat_type;
        request.time = chatMessage.time;
        request.from = chatMessage.other_uid;
        request.msg_id = chatMessage.msg_id;
        request.msg = (chatMessage.type == eMessageBodyType_Text) ? chatMessage.msg : chatMessage.file_id;
        request.length = chatMessage.length;
        request.url = chatMessage.url;
        request.filename = chatMessage.file_name;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXChatBackupChatResponse *backupChatResponse = (DXChatBackupChatResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock([backupChatResponse status], nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)upLoadMessageFileWithFileType:(NSInteger)fileType fileURL:(NSURL *)fileURL result:(void (^)(NSString *, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXChatUploadChatFileRequest *request = [DXChatUploadChatFileRequest requestWithApi:DXClientApi_ChatUploadChatFile];
        request.file_type = fileType;
        request.fileURL = fileURL;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    DXChatUploadChatFileResponse *uploadResponse = (DXChatUploadChatFileResponse *)response;
                    NSDictionary *data = [uploadResponse data];
                    NSString *fileID = [data objectForKey:@"file_id"];
                    DX_CALL_ASYNC_MQ(resultBlock(fileID, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)setMessagesAsReadByUserID:(NSString *)userID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXChatSetReadRequest *request = [DXChatSetReadRequest requestWithApi:DXClientApi_ChatSetRead];
        request.from = userID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXChatSetReadResponse *setReadResponse = (DXChatSetReadResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock([setReadResponse status], nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

/*****************************************************************************
 *
 * 评论相关
 *
 *****************************************************************************/

#pragma mark - 评论相关

- (void)getCommentListByFeedID:(NSString *)feedID count:(NSInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void (^)(DXCommentList *, NSError *))resultBlock {
    DXCommentListsRequest *request = [DXCommentListsRequest requestWithApi:DXClientApi_CommentLists];
    request.fid = feedID;
    request.count = count;
    request.flag = pullType;
    request.last_id = lastID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [response data];
                DXCommentList *commentList = [[DXCommentList alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(commentList, nil));
            }
        }
    }];
}

- (void)postCommentWithCommentPost:(DXCommentPost *)commentPost result:(void (^)(DXComment *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXCommentCreateRequest *request = [DXCommentCreateRequest requestWithApi:DXClientApi_CommentCreate];
        request.commentPost = [commentPost toObjectDictionary:YES];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXCommentCreateResponse *commentCreateResponse = (DXCommentCreateResponse *)response;
            if (resultBlock) {
                NSError *error = [commentCreateResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary *commentInfo = [commentCreateResponse comment];
                    DXComment * comment = [[DXComment alloc] initWithObjectDictionary:commentInfo];
                    DX_CALL_ASYNC_MQ(resultBlock(comment, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)deleteCommentByCommentID:(NSString *)commentID result:(void (^)(BOOL, NSError *))resultBlock {
    
    if ([self isUserSessionValid]) {
        DXCommentDeleteRequest *request = [DXCommentDeleteRequest requestWithApi:DXClientApi_CommentDelete];
        request.ID = commentID;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            if (resultBlock) {
                NSError *error = [response error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DXCommentDeleteResponse *commentDeleteResponse = (DXCommentDeleteResponse *)response;
                    DX_CALL_ASYNC_MQ(resultBlock(commentDeleteResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

/*****************************************************************************
 *
 * 地理位置相关
 *
 *****************************************************************************/

#pragma mark - 地理位置相关

- (void)getAddressOfLatitude:(float)latitude andLongitude:(float)longitude result:(void (^)(BOOL, NSString *, NSArray *, NSError *))resultBlock {
    DXLocationGetRequest * request = [DXLocationGetRequest requestWithApi:DXClientApi_LocationGet];
    request.lat = [NSString stringWithFormat:@"%.6f", latitude];
    request.lng = [NSString stringWithFormat:@"%.6f", longitude];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXLocationGetResponse * locationGetResponse = (DXLocationGetResponse *)response;
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(NO, nil, nil, err));
            } else {
                DX_CALL_ASYNC_MQ(resultBlock(locationGetResponse.status, locationGetResponse.address, locationGetResponse.pois, nil));
            }
        }
    }];
}


/*****************************************************************************
 *
 * 搜索相关
 *
 *****************************************************************************/

#pragma mark - 搜索相关

- (void)getDiscoverUserList:(NSUInteger)count pullType:(DXDataListPullType)pullType lastID:(NSString *)lastID result:(void (^)(DXDiscoverUserWrapper *, NSError *))resultBlock {
    DXSearchUserListRequest * request = [DXSearchUserListRequest requestWithApi:DXClientApi_SearchUserList];
    [request setValue:@(count) forParam:@"count"];
    [request setValue:lastID forParam:@"last_id"];
    [request setValue:@(pullType) forParam:@"flag"];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError * err = [response error];
            if (err) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, err));
            } else {
                NSDictionary * data = [response data];
                DXDiscoverUserWrapper * userWrapper = [[DXDiscoverUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(userWrapper, nil));
            }
        }
    }];
}

- (void)getHotKeywordsListResult:(void (^)(NSArray *, NSError *))resultBlock {
    DXSearchHotKeywordsRequest *request = [DXSearchHotKeywordsRequest requestWithApi:DXClientApi_SearchHotKeywords];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXSearchHotKeywordsResponse *hotKeywordsResponse = (DXSearchHotKeywordsResponse *)response;
        if (resultBlock) {
            NSError *error = [hotKeywordsResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [hotKeywordsResponse data];
                NSArray *list = [data objectForKey:@"list"];
                NSMutableArray *temp = [NSMutableArray array];
                for (NSDictionary *dict in list) {
                    DXSearchHotKeywords *hotKeywords = [[DXSearchHotKeywords alloc] initWithObjectDictionary:dict];
                    [temp addObject:hotKeywords];
                }
                DX_CALL_ASYNC_MQ(resultBlock([temp copy], nil));
            }
        }
    }];
}

- (void)getSearchResultsByKeywords:(NSString *)keywords result:(void (^)(DXSearchResults *, NSError *))resultBlock {
    DXSearchSearchByKeywordRequest *request = [DXSearchSearchByKeywordRequest requestWithApi:DXClientApi_SearchSearchByKeyword];
    request.keyword = keywords;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXSearchSearchByKeywordResponse *searchByKeywordResponse = (DXSearchSearchByKeywordResponse *)response;
        if (resultBlock) {
            NSError *error = [searchByKeywordResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [searchByKeywordResponse data];
                DXSearchResults *searchResults = [[DXSearchResults alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(searchResults, nil));
            }
        }
    }];
}

- (void)getSearchTopicWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void (^)(DXSearchTopicWrapper *, NSError *))resultBlock {
    DXSearchSearchKeywordInTopicRequest *request = [DXSearchSearchKeywordInTopicRequest requestWithApi:DXClientApi_SearchSearchKeywordInTopic];
    request.keyword = keywords;
    request.flag = pullType;
    request.count = count;
    request.last_id = lastID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXSearchSearchKeywordInTopicResponse *topicResponse = (DXSearchSearchKeywordInTopicResponse *)response;
        if (resultBlock) {
            NSError *error = [topicResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [topicResponse data];
                DXSearchTopicWrapper *topicWrapper = [[DXSearchTopicWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(topicWrapper, nil));
            }
        }
    }];
}

- (void)getSearchUserWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void (^)(DXSearchUserWrapper *, NSError *))resultBlock {
    DXSearchSearchKeywordInActivityRequest *request = [DXSearchSearchKeywordInActivityRequest requestWithApi:DXClientApi_SearchSearchKeywordInUser];
    request.keyword = keywords;
    request.flag = pullType;
    request.count = count;
    request.last_id = lastID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXSearchSearchKeywordInUserResponse *userResponse = (DXSearchSearchKeywordInUserResponse *)response;
        if (resultBlock) {
            NSError *error = [userResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [userResponse data];
                DXSearchUserWrapper *userWrapper = [[DXSearchUserWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(userWrapper, nil));
            }
        }
    }];
}

- (void)getSearchActivityWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void (^)(DXSearchActivityWrapper *, NSError *))resultBlock {
    DXSearchSearchKeywordInActivityRequest *request = [DXSearchSearchKeywordInActivityRequest requestWithApi:DXClientApi_SearchSearchKeywordInActivity];
    request.keyword = keywords;
    request.flag = pullType;
    request.count = count;
    request.last_id = lastID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXSearchSearchKeywordInActivityResponse *activityResponse = (DXSearchSearchKeywordInActivityResponse *)response;
        if (resultBlock) {
            NSError *error = [activityResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [activityResponse data];
                DXSearchActivityWrapper *activityWrapper = [[DXSearchActivityWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(activityWrapper, nil));
            }
        }
    }];
}

- (void)getSearchFeedWrapperByKeywords:(NSString *)keywords pullType:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)lastID result:(void (^)(DXSearchFeedWrapper *, NSError *))resultBlock {
    DXSearchSearchKeywordInFeedRequest *request = [DXSearchSearchKeywordInFeedRequest requestWithApi:DXClientApi_SearchSearchKeywordInFeed];
    request.keyword = keywords;
    request.flag = pullType;
    request.count = count;
    request.last_id = lastID;
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXSearchSearchKeywordInFeedResponse *feedResponse = (DXSearchSearchKeywordInFeedResponse *)response;
        if (resultBlock) {
            NSError *error = [feedResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                NSDictionary *data = [feedResponse data];
                DXSearchFeedWrapper *feedWrapper = [[DXSearchFeedWrapper alloc] initWithObjectDictionary:data];
                DX_CALL_ASYNC_MQ(resultBlock(feedWrapper, nil));
            }
        }
    }];
}

/*****************************************************************************
 *
 * 客户端相关
 *
 *****************************************************************************/

#pragma mark - 客户端相关

- (void)checkWatermarksWithTimestamp:(NSInteger)timestamp result:(void (^)(NSArray *, NSInteger, NSError *))resultBlock {
    DXClientCheckWatermarksRequest * request = [DXClientCheckWatermarksRequest requestWithApi:DXClientApi_ClientCheckWatermarks];
    [request setValue:@(timestamp) forKey:@"timestamp"];
    request.userInfo = [self.currentUserSession toObjectDictionary];
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        DXClientCheckWatermarksResponse * checkResponse = (DXClientCheckWatermarksResponse *)response;
        if (resultBlock) {
            NSError * error = [checkResponse error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, 0, error));
            } else {
                NSMutableArray * watermarkList = [NSMutableArray array];
                for (NSDictionary * watermarkInfo in checkResponse.list) {
                    @autoreleasepool {
                        DXWatermark * watermark = [[DXWatermark alloc] initWithObjectDictionary:watermarkInfo];
                        watermark.sourceType = DXWatermarkSourceServer;
                        [watermarkList addObject:watermark];
                    }
                }
                DX_CALL_ASYNC_MQ(resultBlock(watermarkList, checkResponse.timestamp, nil));
            }
        }
    }];
}

/*****************************************************************************
 *
 * 标签相关
 *
 *****************************************************************************/
#pragma mark - 标签相关

- (void)getTagWrapper:(void (^)(DXTagWrapper *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTagTagListRequest *request = [DXTagTagListRequest requestWithApi:DXClientApi_TagTagList];
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTagTagListResponse *tagListResponse = (DXTagTagListResponse *)response;
            if (resultBlock) {
                NSError *error = [tagListResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(nil, error));
                } else {
                    NSDictionary *data = [tagListResponse data];
                    DXTagWrapper *tagWrapper = [[DXTagWrapper alloc] initWithObjectDictionary:data];
                    DX_CALL_ASYNC_MQ(resultBlock(tagWrapper, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)changeTagRelationWithCreateTagIDs:(NSArray *)createTagIDs deleteTageIDs:(NSArray *)deleteTageIDs result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        DXTagCreateOrDeleteTagRelationRequest *request = [DXTagCreateOrDeleteTagRelationRequest requestWithApi:DXClientApi_TagCreateOrDeleteTagRelation];
        request.create_ids = createTagIDs;
        request.delete_ids = deleteTageIDs;
        request.userInfo = [self.currentUserSession toObjectDictionary];
        [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
            DXTagCreateOrDeleteTagRelationResponse *tagRelationResponse = (DXTagCreateOrDeleteTagRelationResponse *)response;
            if (resultBlock) {
                NSError *error = [tagRelationResponse error];
                if (error) {
                    DX_CALL_ASYNC_MQ(resultBlock(NO, error));
                } else {
                    DX_CALL_ASYNC_MQ(resultBlock(tagRelationResponse.status, nil));
                }
            }
        }];
    } else {
        DXClientRequestError * sessionError = [DXClientRequestError errorWithCode:DXClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            DX_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

#pragma mark - ******************************   v2.0   ******************************

-(void)getFeedHomeList:(DXDataListPullType)pullType count:(NSUInteger)count lastID:(NSString *)ID userTimestamp:(NSUInteger)userTimestamp topicTimestamp:(NSUInteger)topicTimestamp result:(void (^)(DXFeedHomeList *, NSError *))resultBlock {
    DXFeedHomeListRequest *request = [DXFeedHomeListRequest requestWithApi:DXClientApi_FeedHomeList];
    request.flag = pullType;
    request.count = count;
    request.last_id = ID;
    request.recommend_user_timestamp = userTimestamp;
    request.recommend_topic_timestamp = topicTimestamp;
    [[DXClient client] send:request progress:nil finish:^(DXClientResponse *response) {
        if (resultBlock) {
            NSError *error = [response error];
            if (error) {
                DX_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                DXFeedHomeList *feedList = [[DXFeedHomeList alloc] initWithObjectDictionary:[response data]];
                DX_CALL_ASYNC_MQ(resultBlock(feedList, nil));
            }
        }
    }];
}

@end
