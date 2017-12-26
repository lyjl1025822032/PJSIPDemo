//
//  CMAMNetStatusManager.m
//  CmosAllMedia
//
//  Created by yao on 2017/11/8.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAMNetStatusManager.h"
#import "CMAMReachability.h"

@interface CMAMNetStatusManager ()
@property (nonatomic) CMAMReachability *reachability;
@end

@implementation CMAMNetStatusManager
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static CMAMNetStatusManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[CMAMNetStatusManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)startObserveNetworkStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kCMAMReachabilityChangedNotification object:nil];
    self.reachability = [CMAMReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self updateInterfaceWithReachability:self.reachability];
}

- (void)reachabilityChanged:(NSNotification*)notifi {
    CMAMReachability *reachability = [notifi object];
    NSParameterAssert([reachability isKindOfClass:[CMAMReachability class]]);
    [self updateInterfaceWithReachability:reachability];
}

- (void)updateInterfaceWithReachability:(CMAMReachability *)reachability {
    CMAMNetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            if (self.netStatusBlock) {
                self.netStatusBlock(CMAMNetStatusNotReach);
            }
            break;
        case ReachableViaWWAN:
            if (self.netStatusBlock) {
                self.netStatusBlock(CMAMNetStatusWWAN);
            }
            break;
        case ReachableViaWiFi:
            if (self.netStatusBlock) {
                self.netStatusBlock(CMAMNetStatusWiFi);
            }
            break;
    }
}

- (void)stopObserveNetworkiStatus {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCMAMReachabilityChangedNotification object:nil];
    [self.reachability stopNotifier];
}
@end
