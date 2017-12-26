//
//  CMPJSIP.h
//  CMPJSIP
//
//  Created by 宁晓明 on 16/7/28.
//  Copyright © 2016年 CMOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CMSoftPhoneInfo.h"
#import "CMVoipCallInfo.h"


/**
 控制台是否打印日志
 0 打印 1 不打印
 */
#define RELEASE_VERSION 0


/**
 以下内容制定了srtp的传输特性

 - CM_SRTP_USE_DIAABLE:   使用该选项将会禁止使用SRTP,并且拒绝RTP/SAVP请求
 - CM_SRTP_USE_OPITION:   使用该选项将会使SRTP变更为可选项，当有SRTP加密请求时将对接收到/发送
 - CM_SRTP_USE_MANDATORY: 使用该选项将会强制使用SRTP加密
 */
typedef NS_ENUM(NSUInteger, CM_SRTP_USE) {
    CM_SRTP_USE_DISABLE,
    CM_SRTP_USE_OPITION,
    CM_SRTP_USE_MANDATORY,
};


/**
 错误类型

 - CM_SOFT_PHONE_ERR_INVALID_PARAM:           非法参数
 - CM_SOFT_PHONE_ERR_SIP_INIT_FAIL:           初始化失败
 - CM_SOFT_PHONE_ERR_SIP_NOT_INIT:            sip实例没有初始化
 - CM_SOFT_PHONE_ERR_SIP_NOT_REGISTER:        sip账号没有注册
 - CM_SOFT_PHONE_ERR_SIP_REGISTERING:         sip账号注册中
 - CM_SOFT_PHONE_ERR_SIP_REGISTED:            sip账号已注册
 - CM_SOFT_PHONE_ERR_SIP_UNREGISTER:          sip账号注销失败
 - CM_SOFT_PHONE_ERR_SIP_ACCEPT:              sip电话接听失败
 - CM_SOFT_PHONE_ERR_SIP_REJECT:              sip电话拒绝失败
 - CM_SOFT_PHONE_ERR_SIP_HANGUP:              sip电话挂断失败
 - CM_SOFT_PHONE_ERR_SIP_SENDDTMF_FAIL:       sip电话发送DTMF数据失败
 - CM_SOFT_PHONE_ERR_SIP_SETMICRO_FAIL:       sip电话设置麦克风音量失败
 - CM_SOFT_PHONE_ERR_SIP_SETSPEAKER_FAIL:     sip电话设置扬声器音量失败
 - CM_SOFT_PHONE_ERR_SIP_PLAYRING_FAIL:       sip电话播放铃声失败
 - CM_SOFT_PHONE_ERR_SIP_MODIFY_ACC_CFG_FAIL: sip电话修改账号配置信息失败
 */
typedef NS_ENUM(NSInteger, CM_SOFT_PHONE_ERR) {
    
    CM_SOFT_PHONE_ERR_INVALID_PARAM             ,
    CM_SOFT_PHONE_ERR_SIP_INIT_FAIL             ,
    CM_SOFT_PHONE_ERR_SIP_NOT_INIT              ,
    CM_SOFT_PHONE_ERR_SIP_NOT_REGISTER          ,
    CM_SOFT_PHONE_ERR_SIP_REGISTERING           ,
    CM_SOFT_PHONE_ERR_SIP_REGISTED              ,
    CM_SOFT_PHONE_ERR_SIP_UNREGISTER            ,
    CM_SOFT_PHONE_ERR_SIP_ACCEPT                ,
    CM_SOFT_PHONE_ERR_SIP_REJECT                ,
    CM_SOFT_PHONE_ERR_SIP_HANGUP                ,
    CM_SOFT_PHONE_ERR_SIP_SENDDTMF_FAIL         ,
    CM_SOFT_PHONE_ERR_SIP_SETMICRO_FAIL         ,
    CM_SOFT_PHONE_ERR_SIP_SETSPEAKER_FAIL       ,
    CM_SOFT_PHONE_ERR_SIP_PLAYRING_FAIL         ,
    CM_SOFT_PHONE_ERR_SIP_MODIFY_ACC_CFG_FAIL   ,
};
@class CMPJSIP;
@protocol CMPJSIPDelegate <NSObject>


/**
 注册状态回调

 @param pjsip pjsp对象
 @param result   是否注册成功
 @param error   注册不成功的回调
 */
- (void)cmpjsip:(CMPJSIP *)pjsip registeResult:(BOOL)result error:(NSString *)error;

/**
 来电/拨打电话状态-来电

 @param pjsip pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip incomingVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;


@optional
/**
 来电/拨打电话状态-拨打中
 
 @param pjsip     pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip callingVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;


/**
 来电/拨打电话状态-电话铃想起
 
 @param pjsip     pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip earlyVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;


/**
 来电/拨打电话状态-接通电话
 
 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip connectingVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;


/**
 来电/拨打电话状态-持续通话（tcp中的ack应答）

 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip confirmVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;

/**
  来电/拨打电话状态-挂断电话

 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip disconnectVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;

/**
 拨打电话状态-用户忙
 
 *  @param pjsip        pjsip对象
 *  @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip busyVoipCallInfo:(CMVoipCallInfo *)voipCallInfo;

/**
 dtmf回调

 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip dtmfCallBack:(CMVoipCallInfo *)voipCallInfo;


@end

@interface CMPJSIP : NSObject

/**
 *  默认初始化方法·
 *
 *  @return 实例对象
 */
+ (instancetype)sharedInstance;


/**
 *  生成voip信息
 *
 *  @param softPhoneInfo 初始化参数
 *  @param delegate      回调代理
 *  @param error         错误信息
 */
- (void)generateVoipInfoWithCMSoftPhoneInfo:(CMSoftPhoneInfo *)softPhoneInfo
                                   delegate:(id<CMPJSIPDelegate>)delegate
                                      error:(NSError **)error;

/**
 *  初始化对象并且生成voip信息
 *  如果error不为空则说明初始化失败
 *
 *  @param softPhoneInfo 初始化参数
 *  @param delegate      回调代理
 *  @param error         错误信息
 *
 *  @return 实例对象
 */
+ (instancetype)initWithCMSoftPhoneInfo:(CMSoftPhoneInfo *)softPhoneInfo
                               delegate:(id <CMPJSIPDelegate>)delegate
                                  error:(NSError **)error;
/**
 *  销毁sip实例
 *
 *  @param error 错误信息
 */
- (void)destroySip:(NSError **)error;

/**
 *  注册sip账号
 *
 *  @param error 错误信息
 */
- (void)registerSip:(NSError **)error;

/**
 *  注销sip账号
 *
 *  @param error 错误信息
 */
- (void)unRegisterSip:(NSError **)error;

/**
 拨打电话
 
 @param callInfo 要拨打的电话信息
 @param error    错误信息
 */
- (void)makeCallBySip:(CMVoipCallInfo *)callInfo error:(NSError **)error;
/**
 *  接通电话
 *
 *  @param voipCallInfo voip info 包含此次通话信息
 *  @param error        错误信息
 */
- (void)acceptSipCall:(CMVoipCallInfo *)voipCallInfo error:(NSError **)error;

/**
 *  挂断电话
 *
 *  @param error 错误信息
 */
- (void)hangupSipCall:(CMVoipCallInfo *)voipCallInfo error:(NSError **)error;

/**
 *  发送DTMF数据
 *
 *  @param dtmf  dtmf信息
 *  @param error 错误信息
 */
- (void)sendDTMFData:(NSString *)dtmf error:(NSError **)error;

/**
 *  拒绝来电
 *
 *  @param voipCallInfo voip info 包含此次通话信息
 *  @param error        错误信息
 */
- (void)rejectSipCall:(CMVoipCallInfo *)voipCallInfo error:(NSError **)error;

/**
 *  调节麦克风音量
 *
 *  @param microLevel 麦克风声音强度级别，默认为1，取值范围0~2; 0~1减小音量,1~2增加音量
 *  @param error      错误信息
 */
- (void)adjustSipMicroLevel:(float)microLevel error:(NSError **)error;

/**
 *  调节听筒或扬声器音量
 *
 *  @param speakerLevel 听筒声音强度级别，默认为1，取值范围0~2; 0~1减小音量,1~2增加音量
 *  @param error        错误信息
 */
- (void)adjustSipSpeakerLevel:(float)speakerLevel error:(NSError **)error;

/**
 是否使用扬声器通话

 @return 是否成功
 */
- (BOOL)enableLoudSpeaker:(BOOL)enable;




/**
 获取所有本地日志信息

 @param error 错误信息，如果成功为nil

 @return 日志内容
 */
- (NSString *)getlocalLog:(NSError **)error;


/**
 删除本地日志文件
 
 @param error 错误信息，如果成功为nil
 */
- (void)destroyLoaclLog:(NSError **)error;



/**
 使用iOS系统内部的铃声，详细请参考
 http://iphonedevwiki.net/index.php/AudioServices
 默认使用system sound id 1005
 @param soundID SystemSoundID
 */
- (void)setSoundID:(SystemSoundID)soundID;

/**
 使用指定的音频文件作为铃声，铃声文件需要caf格式并且不超过30s
 并且copy到bundle中
 @param path 文件名路径
 
 */
- (void)setSoundName:(NSString *)path;


/**
 设置srtp加密
 根据后台需要变更srtp选项，默认使用CM_SRTP_USE_DISABLE

 @param srtpUse srtp是否可用
 @param error  错误信息，如果成功为nil
 */
- (void)setSrtpEnable:(CM_SRTP_USE)srtpUse error:(NSError **)error;



/**
 获取pjsip配置
 */
- (void *)pjsipConfig;

/**
 *  获取sip电话信息
 *
 *  @return CMSoftPhoneInfo实例
 */
- (CMSoftPhoneInfo *)softPhoneInfo;

/**
 *  获取当前通话的信息
 *
 *  @return 当前通话信息的实例
 */
- (CMVoipCallInfo *)voipCallInfo;
@end
