//
//  CMAllMediaVoipView.h
//  CmosAllMediaUI
//
//  Created by 王智垚 on 2017/9/12.
//  Copyright © 2017年 cmos. All rights reserved.
//  语音通话界面

#import <UIKit/UIKit.h>
#import "CMAllMediaVoipSDKManager.h"

@interface CMAllMediaVoipView : UIView
/**
 * 语音通信回调
 *
 * @param state   语音通话状态
 * @param timeStr 通话时长
*/
@property(nonatomic, copy)void(^voipViewBlock)(VoipState state,NSString *timeStr);

//点击了悬浮球放大
@property(nonatomic, copy)void(^enlargeBlock)(void);

//显示语音通话界面
- (void)showVoipView;
@end
