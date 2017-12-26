//
//  CMAMNetStatusManager.h
//  CmosAllMedia
//
//  Created by yao on 2017/11/8.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CMAMNetStatus) {
    CMAMNetStatusNotReach = 0,
    CMAMNetStatusWiFi        ,
    CMAMNetStatusWWAN        ,
};

@interface CMAMNetStatusManager : NSObject
+ (instancetype)shareInstance;

- (void)startObserveNetworkStatus;

@property (nonatomic, copy)void(^netStatusBlock)(CMAMNetStatus netStatus);

- (void)stopObserveNetworkiStatus;
@end
