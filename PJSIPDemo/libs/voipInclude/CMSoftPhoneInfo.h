//
//  CMSoftPhoneInfo.h
//  CMPJSIP
//
//  Created by 宁晓明 on 16/7/29.
//  Copyright © 2016年 CMOS. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CM_SOFT_PHONE_STATE) {
    CM_SOFT_PHONE_STATE_NIL,			//未初始化状态
    CM_SOFT_PHONE_STATE_INIT,			//已初始化、未注册状态
    CM_SOFT_PHONE_STATE_REGISTERING,	//正在注册
    CM_SOFT_PHONE_STATE_REGISTERED		//已注册
};


@interface CMSoftPhoneInfo : NSObject<NSCopying>
@property (nonatomic, assign,readonly)      CM_SOFT_PHONE_STATE state;      //soft phone 状态
@property (nonatomic, assign,readonly)      int                 accessID;   //用户ID
@property (nonatomic, copy) NSString        *userName;                      //用户名
@property (nonatomic, copy) NSString        *password;                      //密码
@property (nonatomic, copy) NSString        *domain;                        //sip域
@property (nonatomic, assign) unsigned      domainPort;                     //sip域端口



@end
