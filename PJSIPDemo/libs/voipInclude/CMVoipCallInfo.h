//
//  CMVoipCallInfo.h
//  CMPJSIP
//
//  Created by 宁晓明 on 16/7/29.
//  Copyright © 2016年 CMOS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CM_VOIP_CALL_STATE) {
    CM_VOIP_CALL_STATE_NULL,                //呼叫发起前
    CM_VOIP_CALL_STATE_CALLING,             //发起呼叫
    CM_VOIP_CALL_STATE_INCOMNG,             //来电
    CM_VOIP_CALL_STATE_EARLY,               //响铃
    CM_VOIP_CALL_STATE_CONNECTING,          //通话
    CM_VOIP_CALL_STATE_CONFIRMED,           //ack确认应答
    CM_VOIP_CALL_STATE_DISCONNCTD,          //挂机,
    CM_VOIP_CALL_STATE_BUSY,                //通话中
};

@interface CMVoipCallInfo : NSObject<NSCopying>
@property (nonatomic, copy) NSString *localInfo;                            //呼出号码
@property (nonatomic, copy) NSString *remoteInfo;                           //被叫号码
@property (nonatomic, assign, readonly) int                  callID;         //该次呼叫的唯一标识
@property (nonatomic, copy, readonly)   NSString             *callState;     //呼叫状态
@property (nonatomic, assign, readonly) CM_VOIP_CALL_STATE   stateCode;      //状态码
@property (nonatomic, assign, readonly) NSInteger            callType;       //呼叫类型

@end
