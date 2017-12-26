//
//  CMVoipSDKManager.m
//  Cmos
//
//  Created by 王智垚 on 2017/9/6.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaVoipSDKManager.h"
#import "CMPJSIP.h"
#import "CMVoipCallInfo.h"
#import "CMSoftPhoneInfo.h"
#import "CMAMNetStatusManager.h"

@interface CMAllMediaVoipSDKManager ()<CMPJSIPDelegate>
@property (nonatomic, strong) CMPJSIP         *pjSip;
@property (nonatomic, strong) CMSoftPhoneInfo *softPhoneInfo;
@property (nonatomic, strong) CMVoipCallInfo  *voipCallInfo;
@property (nonatomic, copy) void(^loginResultBlock)(BOOL resultFlag,NSString *error);
@property(nonatomic, strong)CMAMNetStatusManager *netManager;
@end

@implementation CMAllMediaVoipSDKManager
+ (CMAllMediaVoipSDKManager *)sharedInstance {
    static CMAllMediaVoipSDKManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMAllMediaVoipSDKManager alloc]init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.isCallingFlag = NO;
        self.netManager = [CMAMNetStatusManager shareInstance];
    }
    return self;
}

//登陆语音账号
- (void)loginWithUsername:(NSString *)username password:(NSString *)password domain:(NSString *)domain domainPort:(NSString *)domainPort completion:(void (^)(BOOL, NSString *))completionBlock {
    if (!domain.length || !domainPort.length || !username.length || !password.length) {
        completionBlock(NO,@"Param Invalid");
        return;
    }
    [_netManager startObserveNetworkStatus];
    self.softPhoneInfo.userName   = username;
    self.softPhoneInfo.password   = password;
    self.softPhoneInfo.domain     = domain;
    self.softPhoneInfo.domainPort = domainPort.intValue;
    
    NSError *registerError = nil;
    [self.pjSip registerSip:&registerError];
    
    __weak typeof(self)weakSelf = self;
    self.loginResultBlock = ^(BOOL resultFlag, NSString *error) {
        weakSelf.isVoipNormal = resultFlag?YES:NO;
        resultFlag?completionBlock(resultFlag,nil):completionBlock(resultFlag,error);
    };
}

#pragma mark 语音操作
//呼叫用户
- (void)callUserWithUserNumber:(NSString *)remoteNumber {
    self.isCallingFlag = YES;
    [self changeProximityMonitorEnableState:YES];
    //app被杀死挂断语音
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:@"UIApplicationWillTerminateNotification" object:nil];
    
    __weak typeof(self) weakSelf = self;
    self.netManager.netStatusBlock = ^(CMAMNetStatus netStatus) {
        if (netStatus == CMAMNetStatusNotReach) {
            [weakSelf hangupVoipPJSIP];
        }
    };
    self.voipCallInfo.localInfo = self.softPhoneInfo.userName;
    self.voipCallInfo.remoteInfo = remoteNumber;
    NSError *error = nil;
    [self.pjSip makeCallBySip:self.voipCallInfo error:&error];
    if (error) {
        return;
    }
}

// 挂断语音
- (void)hangupVoipPJSIP {
    self.isCallingFlag = NO;
    NSError *error = nil;
    [self.pjSip hangupSipCall:self.voipCallInfo error:&error];
    [self changeProximityMonitorEnableState:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
}

/** 发送DTMF数据 **/
- (void)sendDTMFDataString:(NSString *)dtmfStr {
    NSError *error = nil;
    [self.pjSip sendDTMFData:dtmfStr error:&error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
}

// 接通语音
- (void)acceptVoipPJSIP {
    //app被杀死挂断语音
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:@"UIApplicationWillTerminateNotification" object:nil];
     
    NSError *error = nil;
    [self.pjSip acceptSipCall:self.voipCallInfo error:&error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
}

//app被杀死挂断
- (void)applicationWillTerminate:(UIApplication *)application {
    [self hangupVoipPJSIP];
}

//退出账号
- (void)logoutVoipAccount {
    NSError *error = nil;
    [self.pjSip unRegisterSip:&error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
}

//切换声音路径
- (void)changeVoiceWithLoudSpeaker:(BOOL)flag {
    [self changeProximityMonitorEnableState:!flag];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.pjSip enableLoudSpeaker:flag];
    });
}

//静音操作
- (void)changeIsSilenceWithFlag:(BOOL)flag {
    [self.pjSip adjustSipMicroLevel:flag?0:1 error:nil];
}

//麦克风音量
- (void)adjustMicroVolume:(CGFloat)microVolume {
    [self.pjSip adjustSipMicroLevel:microVolume error:nil];
}

//语音音量
- (void)adjustSipSpeakerVolumeMicroVolume:(CGFloat)sipSpeakerVolume {
    [self.pjSip adjustSipSpeakerLevel:sipSpeakerVolume error:nil];
}

#pragma mark - 近距离传感器
- (void)changeProximityMonitorEnableState:(BOOL)enable {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:enable];
    }
}

//销毁语音对象
- (void)destroySip {
    [self.pjSip destroySip:nil];
}

#pragma mark - CMPJSIPDelegate
//账号登陆
- (void)cmpjsip:(CMPJSIP *)pjsip registeResult:(BOOL)result error:(NSString *)errorStr {
    if (result) {
        _loginResultBlock(result, errorStr);
    } else {
        self.voipCallInfo = nil;
        _loginResultBlock(result, errorStr);
    }
}

/**
 1. 发起语音 -- 呼叫/被呼叫
 @param pjsip     pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip callingVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    if (self.voipBlock) {
        self.voipBlock(VoipStateCalling);
    }
}

/**
 2. 来电 -- 呼叫/被呼叫
 @param pjsip     pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip incomingVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    if (self.voipBlock) {
        self.voipBlock(VoipStateIncoming);
    }
}

/**
 3. 响铃中 -- 呼叫/被呼叫
 @param pjsip     pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip earlyVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    if (self.voipBlock) {
        self.voipBlock(VoipStateEarly);
    }
}

/**
 4. 接听连接中
 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip connectingVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    if (self.voipBlock) {
        self.voipBlock(VoipStateConnecting);
    }
}

/**
 5. 电话通信中
 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip confirmVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    if (self.voipBlock) {
        self.voipBlock(VoipStateConfirm);
    }
}

/**
 6. 挂断电话
 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip disconnectVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    self.isCallingFlag = NO;
    if (self.voipBlock) {
        self.voipBlock(VoipStateDisconnect);
    }
}

/**
 7. 未接通被挂断(无应答)
 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip busyVoipCallInfo:(CMVoipCallInfo *)voipCallInfo {
    self.isCallingFlag = NO;
    if (self.voipBlock) {
        self.voipBlock(VoipStateNoResponse);
    }
}

/**
 8. dtmf回调
 @param pjsip        pjsip对象
 @param voipCallInfo 本次通话的相关信息对象
 */
- (void)cmpjsip:(CMPJSIP *)pjsip dtmfCallBack:(CMVoipCallInfo *)voipCallInfo {
    self.isCallingFlag = NO;
    if (self.voipBlock) {
        self.voipBlock(VoipStateDtmf);
    }
}

#pragma mark 懒加载
- (CMPJSIP *)pjSip {
    if (!_pjSip) {
        NSError *error = nil;
        _pjSip = [CMPJSIP initWithCMSoftPhoneInfo:self.softPhoneInfo delegate:self error:&error];
        if (error) {
            return nil;
        };
    }
    return _pjSip;
}

- (CMSoftPhoneInfo *)softPhoneInfo {
    if (!_softPhoneInfo) {
        _softPhoneInfo = [[CMSoftPhoneInfo alloc] init];
    }
    return _softPhoneInfo;
}

- (CMVoipCallInfo *)voipCallInfo {
    if (!_voipCallInfo) {
        _voipCallInfo = [[CMVoipCallInfo alloc] init];
    }
    return _voipCallInfo;
}

- (void)dealloc {
    self.isCallingFlag = nil;
    [self destroySip];
    [self changeProximityMonitorEnableState:NO];
}

@end
