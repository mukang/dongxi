//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

extern NSString *const WXAppID;
extern NSString *const WXAppSecret;
extern NSString *const WXBaseURL;

@protocol WXApiManagerDelegate <NSObject>

@optional

- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;

@end

@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;

+ (instancetype)sharedManager;

#pragma mark - 登录信息相关
/**
 *  微信的登录信息
 */
- (DXWechatLoginInfo *)wechatLoginInfo;
/**
 *  更新微信的登录信息
 */
- (void)saveWechatLoginInfo:(DXWechatLoginInfo *)loginInfo;
/**
 *  清除微信登陆信息
 */
- (void)cleanWechatLoginInfo;

#pragma mark - 用户登录相关
/**
 *  刷新accessToken
 *
 *  @param refreshToken 用来刷新access_token
 *  @param resultBlock  回调结果
 */
- (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken result:(void(^)(NSDictionary *responseData, NSError *error))resultBlock;
/**
 *  获取accessToken
 *
 *  @param code        用户换取access_token的code
 *  @param resultBlock 回调结果
 */
- (void)getAccessTokenWithCode:(NSString *)code result:(void(^)(NSDictionary *responseData, NSError *error))resultBlock;
/**
 *  获取用户个人信息
 *
 *  @param accessToken 调用凭证
 *  @param openID      普通用户的标识，对当前开发者帐号唯一
 *  @param resultBlock 回调结果
 */
- (void)getUserInfoWithAccessToken:(NSString *)accessToken openID:(NSString *)openID result:(void(^)(NSDictionary *responseData, NSError *error))resultBlock;

@end
