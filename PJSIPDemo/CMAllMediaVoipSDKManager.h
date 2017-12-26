//
//  CMAllMediaVoipSDKManager.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/9/6.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  语音SDK工具类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VoipState) {
    /** 1.发起语音 */
    VoipStateCalling = 1,
    /** 2.语音来电 */
    VoipStateIncoming   ,
    /** 3.响铃中 */
    VoipStateEarly      ,
    /** 4.正连接通话 */
    VoipStateConnecting ,
    /** 5.正通话中 */
    VoipStateConfirm    ,
    /** 6.挂断通话 */
    VoipStateDisconnect ,
    /** 7.对方无应答 */
    VoipStateNoResponse ,
    /** 8.dtmf回调 */
    VoipStateDtmf       ,
};

@interface CMAllMediaVoipSDKManager : NSObject
/** 初始化单例 **/
+ (CMAllMediaVoipSDKManager *)sharedInstance;

/** 语音是否接入正常 **/
@property (nonatomic, assign)BOOL isVoipNormal;

/** 上次通话是否存在 **/
@property (nonatomic, assign)BOOL isCallingFlag;

/** 语音通话状态回调 **/
@property (nonatomic, copy)void(^voipBlock)(VoipState state);

/**
 *  登陆语音账号
 *
 *  @param username        用户名
 *  @param password        密码
 *  @param domain        域名
 *  @param domainPort        端口
 *  @param completionBlock 登录回调
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                   domain:(NSString *)domain
               domainPort:(NSString *)domainPort
               completion:(void (^)(BOOL result, NSString *error))completionBlock;

/** 语音请求 */
- (void)callUserWithUserNumber:(NSString *)remoteNumber;

/** 挂断语音 **/
- (void)hangupVoipPJSIP;

/** 接通语音 **/
- (void)acceptVoipPJSIP;

/** 发送DTMF数据 **/
- (void)sendDTMFDataString:(NSString *)dtmfStr;

/** 语音通讯播放路径 YES:扬声器 NO:听筒**/
- (void)changeVoiceWithLoudSpeaker:(BOOL)flag;

/** 语音通讯静音操作 */
- (void)changeIsSilenceWithFlag:(BOOL)flag;

/** 退出语音账号 **/
- (void)logoutVoipAccount;

/** 销毁语音对象 **/
- (void)destroySip;

/**
 *  手动调节麦克风音量
 *
 *  @param microVolume        音量大小(0~1 减小, 1~2 放大)
 */
- (void)adjustMicroVolume:(CGFloat)microVolume;

/**
 *  手动调节语音音量
 *
 *  @param sipSpeakerVolume   音量大小(0~1 减小, 1~2 放大)
 */
- (void)adjustSipSpeakerVolumeMicroVolume:(CGFloat)sipSpeakerVolume;
@end
