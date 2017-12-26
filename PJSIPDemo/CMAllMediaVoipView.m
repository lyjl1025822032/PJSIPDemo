//
//  CMAllMediaVoipView.m
//  CmosAllMediaUI
//
//  Created by 王智垚 on 2017/9/12.
//  Copyright © 2017年 cmos. All rights reserved.
//

#import "CMAllMediaVoipView.h"
#import "UIView+CMAMLayout.h"

#define kCMScreenWidth [UIScreen mainScreen].bounds.size.width
#define kCMScreenHeight [UIScreen mainScreen].bounds.size.height
#define kCM_loadBundleImage(imageName) [UIImage imageNamed:imageName]
#define kCMScaleWidth (kCMScreenWidth > 320 ? 1.0 : (kCMScreenWidth / 360.0))
#define kCMScaleHeight (kCMScreenHeight > 568.0 ? 1.0 : (kCMScreenHeight / 640.0))

//悬浮屏高度的一半
#define kSmallH (40*kCMScaleHeight)
//悬浮屏宽度的一半
#define kSmallW (35*kCMScaleWidth)
//中间三个按钮Y
#define btnY kCMScreenHeight - 222 * kCMScaleHeight
//三个按钮间隔
#define btnMargin ((kCMScreenWidth - 72*kCMScaleWidth*3) / 4)
//客服工号 100860077 10086886 1008610     10086
#define kServerId       1008610
#define kAgoraServerId  10086

//悬浮球距离边缘的距离
static CGFloat edgeDistance = 8;
//悬浮球宽高
static CGFloat smallWH = 70;
//客服头像宽高
static CGFloat headerWH = 220;
//缩小时客服头像宽高
static CGFloat smallHeader = 17;
//左上角缩放x
static CGFloat shrinkX = 19;
//左上角缩放Y
static CGFloat shrinkY = 30;
//左上角缩放按钮宽
static CGFloat shrinkWidth = 30;
//左上角缩放按钮高
static CGFloat shrinkHeight = 24;
//全屏时计时距缩放按钮titleY
static CGFloat chatLabelY = 240+13;
//全屏时状态和计时tilte间隔
static CGFloat stateChatDistance = 10;
//挂断按钮Y
static CGFloat hangupY = 102;
//接通时四个按钮宽(挂断按钮高)
static CGFloat buttonWidth = 72;
//中间三个按钮高
static CGFloat buttonHeight = 92;
//ivr显示框Y
static CGFloat ivrContentY = 137;
//ivr显示高
static CGFloat ivrContentH = 85;
//数字键盘Y
static CGFloat numberKeyBoardY = 137+85;
//未接通时提示语Y
static CGFloat reminderY = 132+92+17.5+21;

/** 上图片下文字Btn适配 **/
@interface CMAllMediaVerticalButton : UIButton
@end

/** 数字键盘 **/
@interface CMAllMediaNumberKeyboardView : UIView
/** 数字回调 **/
@property(nonatomic, copy)void(^numberBlock)(NSString *numberStr);
@end

@interface CMAllMediaVoipView ()<UIGestureRecognizerDelegate, UITextFieldDelegate> {
    //等待接通
    NSTimer *waitTimer;
    //记录通信时间
    NSTimer *contenctTimer;
    //通讯时长
    NSInteger contenctT;
    //记录放大前Rect
    CGRect smallRect;
    //是否缩小
    BOOL isSmall;
    //缩小前键盘是否正显示
    BOOL isShowKeyboard;
    //是否静音
    BOOL isSilence;
    //是否免提
    BOOL isLoudMode;
}
// 触摸位置与悬浮球中心的偏差
@property (nonatomic, assign) CGFloat offSetX;
@property (nonatomic, assign) CGFloat offSetY;

//语音通话单例 PJSIP
@property (nonatomic, strong) CMAllMediaVoipSDKManager *voipManager;

//展示视图
@property (nonatomic, strong) UIImageView *showView;
//左上缩小按钮
@property (nonatomic, strong) UIButton *shrinkBtn;
//客服头像
@property (nonatomic, strong) UIImageView *serviceHeaderView;
//连接状态
@property (nonatomic, strong) UILabel *stateLabel;
//聊天计时
@property (nonatomic, strong) UILabel *chatStateLabel;
//挂断按钮
@property (nonatomic, strong) UIButton *hangupButton;
//静音按钮
@property (nonatomic, strong) CMAllMediaVerticalButton *silenceBtn;
//拨号键盘
@property (nonatomic, strong) CMAllMediaVerticalButton *keyboardBtn;
//免提按钮
@property (nonatomic, strong) CMAllMediaVerticalButton *loudModeBtn;
//隐藏数字键盘
@property (nonatomic, strong) UIButton *hiddenKeyboardBtn;
//删除DTMF指定按钮
@property (nonatomic, strong) UIButton *deleteBtn;
//数字键盘
@property (nonatomic, strong) CMAllMediaNumberKeyboardView *keyboardView;
//IVR输入内容
@property (nonatomic, strong) UITextField *ivrContentTF;
//提示语title
@property (nonatomic, strong) UILabel *reminderLabel;

//放大全屏手势
@property (nonatomic, strong) UITapGestureRecognizer *largeTap;
//小屏拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@end

@implementation CMAllMediaVoipView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        contenctT = 0;
        isSmall = NO;
        isSilence = NO;
        isLoudMode = NO;
        isShowKeyboard = NO;
        self.voipManager = [CMAllMediaVoipSDKManager sharedInstance];
    }
    return self;
}

#pragma mark UI
//语音通讯界面
- (void)showVoipView {
    if (_voipManager.isCallingFlag || !_voipManager.isVoipNormal) {
        return;
    }
    
    [self callCmosServer];

    [self addSubview:self.showView];
    [self addGestureRecognizer:self.panRecognizer];
    [self.showView addGestureRecognizer:self.largeTap];
    [self.showView addSubview:self.shrinkBtn];
    [self.showView addSubview:self.serviceHeaderView];
    [self.showView addSubview:self.chatStateLabel];
    [self.showView addSubview:self.stateLabel];
    [self.showView addSubview:self.ivrContentTF];
    [self.showView addSubview:self.hangupButton];
    [self.showView addSubview:self.silenceBtn];
    [self.showView addSubview:self.keyboardBtn];
    [self.showView addSubview:self.loudModeBtn];
    [self.showView addSubview:self.keyboardView];
    [self.showView addSubview:self.hiddenKeyboardBtn];
    //[self.showView addSubview:self.deleteBtn];

    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        _showView.frame = CGRectMake(0, 0, kCMScreenWidth, kCMScreenHeight);
    }];
}

//关闭语音通讯界面
- (void)dismissVoipView {
    [UIView animateWithDuration:0.5 animations:^{
        if (isSmall) {
            self.alpha = 0.f;
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        } else {
            self.frame = CGRectMake(0, -kCMScreenHeight, kCMScreenWidth, kCMScreenHeight);
        }
    } completion:^(BOOL finished) {
        [self.showView cmam_removeAllSubviews];
        [self removeFromSuperview];
        _showView = nil;
        _shrinkBtn = nil;
        _serviceHeaderView = nil;
        _stateLabel = nil;
        _chatStateLabel = nil;
        _hangupButton = nil;
        _silenceBtn = nil;
        _keyboardBtn = nil;
        _loudModeBtn = nil;
        _keyboardView = nil;
        _hiddenKeyboardBtn = nil;
        //_deleteBtn = nil;
    }];
}

#pragma mark Private Action
//呼叫客服
- (void)callCmosServer {
    __weak typeof(self)weakSelf = self;
    [_voipManager callUserWithUserNumber:@"10086"];
    _voipManager.voipBlock = ^(VoipState state) {
        [weakSelf handlePJSIPStateWithVoipState:state];
    };
}

//挂断电话
- (void)hangupVoipPhone {
    [_voipManager hangupVoipPJSIP];
}

#pragma mark 根据PJSIP状态的处理
- (void)handlePJSIPStateWithVoipState:(NSInteger)voipState {
    switch (voipState) {
        case VoipStateCalling:
            [self updateStateLabelWithStr:@"邀请人工客服"];
            waitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitTimerState) userInfo:nil repeats:YES];
            break;
        case VoipStateIncoming:
            if (!_showView) {
                [self showVoipView];
            }
            break;
        case VoipStateEarly:
            if (!_showView) {
                [self showVoipView];
            }
            break;
        case VoipStateConnecting:
            break;
        case VoipStateConfirm:
        {
            [self destoryWaitTimer];
            [self updateStateLabelWithStr:@"00:00"];
            _silenceBtn.hidden = isSmall?YES:NO;
            _keyboardBtn.hidden = isSmall?YES:NO;
            _loudModeBtn.hidden = isSmall?YES:NO;

            contenctTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(contenctTimeLength) userInfo:nil repeats:YES];
        }
            break;
        case VoipStateDisconnect:
        {
            [self destoryWaitTimer];
            if (self.voipViewBlock) {
                self.voipViewBlock(VoipStateDisconnect, contenctT?_chatStateLabel.text:nil);
            }
            [self updateStateLabelWithStr:@"已挂断"];
            [self destoryContentTimer];
            [self dismissVoipView];
        }
            break;
        case VoipStateNoResponse:
        {
            [self destoryWaitTimer];
            if (self.voipViewBlock) {
                self.voipViewBlock(VoipStateNoResponse, nil);
            }
            [self updateStateLabelWithStr:@"对方通话中"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissVoipView];
            });
        }
            break;
        default:
            break;
    }
}

- (void)waitTimerState {
    if (![_stateLabel.text isEqualToString:@"等待中"]) {
        [self stateLabelOccurenceOfString:_stateLabel.text];
    }
}

#pragma mark 按钮方法实现
//静音按钮
- (void)handleSilenceVolume:(UIButton *)sender {
    isSilence = isSilence?NO:YES;
    isSilence?[sender setImage:kCM_loadBundleImage(@"silence_pressed") forState:UIControlStateNormal]:[sender setImage:kCM_loadBundleImage(@"silence_mormal") forState:UIControlStateNormal];
        [_voipManager changeIsSilenceWithFlag:isSilence];
}

//免提按钮
- (void)handleChangeVoiceMethod:(UIButton *)sender {
    isLoudMode = isLoudMode?NO:YES;
    isLoudMode?[sender setImage:kCM_loadBundleImage(@"loudmode_pressed") forState:UIControlStateNormal]:[sender setImage:kCM_loadBundleImage(@"loudmode_normal") forState:UIControlStateNormal];
    [_voipManager changeVoiceWithLoudSpeaker:isLoudMode];
}

//删除DTMF指令
- (void)handleDeleteDTMF:(UIButton *)sender {
//    if (_ivrContentTF.text.length) {
//        [_voipManager sendDTMFDataString:@"*"];
//        _ivrContentTF.text = [_ivrContentTF.text substringToIndex:_ivrContentTF.text.length-1];
//    }
}

//显示数字键盘
- (void)handelShowNumberKeyboard:(UIButton *)sender {
    _hiddenKeyboardBtn.hidden = NO;
    //_deleteBtn.hidden = NO;
    isShowKeyboard = YES;
    
    CGRect serverRect = _serviceHeaderView.frame;
    CGRect chatStateRect = _chatStateLabel.frame;
    CGRect stateRect = _stateLabel.frame;
    __weak typeof(self)weakSelf = self;
    _keyboardView.numberBlock = ^(NSString *numberStr) {
        [weakSelf.voipManager sendDTMFDataString:numberStr];
        weakSelf.ivrContentTF.text = [weakSelf.ivrContentTF.text stringByAppendingString:numberStr];
    };
    [UIView animateWithDuration:0.5 animations:^{
        _silenceBtn.alpha = 0.f;
        _silenceBtn.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        _keyboardBtn.alpha = 0.f;
        _keyboardBtn.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        _loudModeBtn.alpha = 0.f;
        _loudModeBtn.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        
        _keyboardView.hidden = NO;
        _keyboardView.alpha = 1.f;
        _keyboardView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
        _serviceHeaderView.frame = CGRectMake(serverRect.origin.x+serverRect.size.width/2, _shrinkBtn.cmam_bottom, 0, 0);
        
        _chatStateLabel.frame = CGRectMake(chatStateRect.origin.x, _shrinkBtn.cmam_bottom, chatStateRect.size.width, chatStateRect.size.height);
        _stateLabel.frame = CGRectMake(stateRect.origin.x, _chatStateLabel.cmam_bottom+stateChatDistance*kCMScaleHeight, stateRect.size.width, stateRect.size.height);
    } completion:^(BOOL finished) {
        _ivrContentTF.hidden = NO;
        _serviceHeaderView.hidden = YES;
    }];
}

//隐藏数字键盘
- (void)handleHiddenNumberKeyboard:(UIButton *)sender {
    _hiddenKeyboardBtn.hidden = YES;
    //_deleteBtn.hidden = YES;
    _ivrContentTF.hidden = YES;
    isShowKeyboard = NO;
    
    CGRect serverRect = _serviceHeaderView.frame;
    CGRect chatStateRect = _chatStateLabel.frame;
    CGRect stateRect = _stateLabel.frame;
    _serviceHeaderView.frame = CGRectMake(serverRect.origin.x+serverRect.size.width/2, _shrinkBtn.cmam_bottom, 0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        _keyboardView.hidden = YES;
        _keyboardView.alpha = 0.f;
        _keyboardView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        
        _silenceBtn.alpha = 1.f;
        _silenceBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _keyboardBtn.alpha = 1.f;
        _keyboardBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _loudModeBtn.alpha = 1.f;
        _loudModeBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
        _chatStateLabel.frame = CGRectMake(chatStateRect.origin.x, _shrinkBtn.cmam_bottom+chatLabelY*kCMScaleHeight, chatStateRect.size.width, chatStateRect.size.height);
        _stateLabel.frame = CGRectMake(stateRect.origin.x, _chatStateLabel.cmam_bottom+stateChatDistance*kCMScaleHeight, stateRect.size.width, stateRect.size.height);
        
        _serviceHeaderView.hidden = NO;
        _serviceHeaderView.frame = CGRectMake((kCMScreenWidth-headerWH*kCMScaleWidth)/2, _shrinkBtn.cmam_bottom, headerWH*kCMScaleWidth, headerWH*kCMScaleWidth);
    }];
}

//缩小界面
- (void)handleShrinkButton:(UIButton *)sender {
    isSmall = YES;
    _shrinkBtn.hidden = YES;
    _silenceBtn.hidden = YES;
    _keyboardBtn.hidden = YES;
    _loudModeBtn.hidden = YES;
    _keyboardView.hidden = YES;
    _hiddenKeyboardBtn.hidden = YES;
    //_deleteBtn.hidden = YES;
    _ivrContentTF.hidden = YES;
    _hangupButton.hidden = YES;
    _stateLabel.hidden = YES;
    smallRect = smallRect.size.width?smallRect:CGRectMake(kCMScreenWidth-90*kCMScaleWidth, 84, smallWH*kCMScaleWidth, smallWH*kCMScaleWidth);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = smallHeader*kCMScaleWidth;
        self.frame = smallRect;
        
        _showView.cmam_size = self.cmam_size;
        _serviceHeaderView.frame = CGRectMake(27*kCMScaleWidth, 13*kCMScaleWidth, smallHeader*kCMScaleWidth, smallHeader*kCMScaleWidth);
        
        _chatStateLabel.text = contenctT?_chatStateLabel.text:@"等待中";
        [self updateStateLabelWithStr:_chatStateLabel.text];
    } completion:^(BOOL finished) {
        _serviceHeaderView.hidden = NO;
        _largeTap.enabled = YES;
        _panRecognizer.enabled = YES;
        [_serviceHeaderView setImage:kCM_loadBundleImage(@"serverheadsmall")];
        [_showView setImage:kCM_loadBundleImage(@"voipbacksmall")];
    }];
}

//放大界面
- (void)handleEnlargeView:(UITapGestureRecognizer *)sender {
    if (self.enlargeBlock) {
        self.enlargeBlock();
    }
    isSmall = NO;
    _chatStateLabel.text = contenctT?_chatStateLabel.text:@"邀请人工客服";
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, kCMScreenWidth, kCMScreenHeight);
        self.layer.cornerRadius = 0;
        
        _showView.cmam_size = self.cmam_size;
        [_showView setImage:kCM_loadBundleImage(@"voipbackbig")];
        
        _serviceHeaderView.hidden = isShowKeyboard?YES:NO;
        _serviceHeaderView.frame = CGRectMake((kCMScreenWidth-headerWH*kCMScaleWidth)/2, _shrinkBtn.cmam_bottom, headerWH*kCMScaleWidth, headerWH*kCMScaleWidth);
        [_serviceHeaderView setImage:kCM_loadBundleImage(@"serverheadbig")];
        
        [self updateStateLabelWithStr:_chatStateLabel.text];
    } completion:^(BOOL finished) {
        self.layer.masksToBounds = NO;
        _shrinkBtn.hidden = NO;
        _hangupButton.hidden = NO;
        _stateLabel.hidden = NO;
        
        _silenceBtn.hidden = NO;
        _keyboardBtn.hidden = NO;
        _loudModeBtn.hidden = NO;
        _keyboardView.hidden = isShowKeyboard?NO:YES;
        _hiddenKeyboardBtn.hidden = isShowKeyboard?NO:YES;
        //_deleteBtn.hidden = isShowKeyboard?NO:YES;
        _ivrContentTF.hidden = isShowKeyboard?NO:YES;
        
        _largeTap.enabled = NO;
        _panRecognizer.enabled = NO;
    }];
}

//拖拽小图
- (void)handlePanVoipView:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:sender.view];
    CGPoint panPoint = [sender locationInView:sender.view.superview];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.offSetX = kSmallW - location.x;
        self.offSetY = kSmallH - location.y;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        sender.view.center = CGPointMake(panPoint.x + _offSetX, panPoint.y + _offSetY);
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        CGFloat superWidth = sender.view.superview.bounds.size.width;
        CGFloat superHeight = sender.view.superview.bounds.size.height;
        
        CGFloat endX = sender.view.center.x;
        CGFloat endY = sender.view.center.y - 2;//矫正Y减2 成为视觉中心, center 需要相应加2以作矫正
        
        CGFloat top = fabs(endY);//上距离
        CGFloat bottom = fabs(superHeight - endY);//下距离
        CGFloat left = fabs(endX);//左距离
        CGFloat right = fabs(superWidth - endX);//右距离
        
        CGFloat minSpace = MIN(MIN(MIN(top, left), bottom), right);
        
        //判断最小距离属于上下左右哪个方向 并设置该方向边缘的point属性
        CGPoint newCenter;
        
        if (minSpace == top) {//上
            endX = endX - kSmallW < edgeDistance * 2 ? kSmallW + edgeDistance : endX;
            endX = endX + kSmallW > superWidth - edgeDistance * 2 ? superWidth - kSmallW - edgeDistance : endX;
            newCenter = CGPointMake(endX , edgeDistance + kSmallH + 2);
        } else if(minSpace == bottom) {//下
            endX = endX - kSmallW < edgeDistance * 2 ? kSmallW + edgeDistance : endX;
            endX = endX + kSmallW > superWidth - edgeDistance * 2 ? superWidth - kSmallW - edgeDistance : endX;
            newCenter = CGPointMake(endX , superHeight - kSmallH - edgeDistance + 2);
        } else if(minSpace == left) {//左
            endY = endY - kSmallH < edgeDistance * 2 ? kSmallH + edgeDistance : endY;
            endY = endY + kSmallH > superHeight - edgeDistance * 2 ? superHeight - kSmallH - edgeDistance : endY;
            newCenter = CGPointMake(edgeDistance + kSmallW , endY + 2);
        } else {//右
            endY = endY - kSmallH < edgeDistance * 2 ? kSmallH + edgeDistance : endY;
            endY = endY + kSmallH > superHeight - edgeDistance * 2 ? superHeight - kSmallH - edgeDistance : endY;
            newCenter = CGPointMake(superWidth - kSmallW - edgeDistance , endY + 2);
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            sender.view.center = newCenter;
            smallRect = sender.view.frame;
        }];
    }
}

#pragma mark 自定义方法
//记录通话时间
- (void)contenctTimeLength {
    contenctT++;
    NSString *str = [self convertTime:contenctT];
    [self updateStateLabelWithStr:str];
}

//时间换算
- (NSString *)convertTime:(long long)timeSecond {
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    } else if (timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    } else if (timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}

//更新状态Label
- (void)updateStateLabelWithStr:(NSString *)str {
    CGSize chatSize, stateSize;
    NSString *chatStr, *stateStr;
    if (isSmall) {
        chatSize = [self getWidthWithString:[str containsString:@"等待中"]?@"等待中":_chatStateLabel.text height:20 font:12];
        _chatStateLabel.text = str;
        _chatStateLabel.frame = CGRectMake((_showView.cmam_width-chatSize.width)/2, 35*kCMScaleWidth, chatSize.width, 20);
    } else {
        if ([str containsString:@"邀请"]) {
            chatStr = @"邀请人工客服";
            stateStr = @"通话中...";
            chatSize = [self getWidthWithString:chatStr height:20 font:24];
            stateSize = [self getWidthWithString:stateStr height:20 font:18];
        } else if ([str containsString:@":"]) {
            chatStr = str;
            stateStr = @"正在通话中";
            chatSize = [self getWidthWithString:str height:20 font:24];
            stateSize = [self getWidthWithString:stateStr height:20 font:18];
        } else {
            chatStr = _chatStateLabel.text;
            stateStr = str;
            chatSize = [self getWidthWithString:chatStr height:20 font:24];
            stateSize = [self getWidthWithString:str height:20 font:18];
        }
        _chatStateLabel.text = chatStr;
        _chatStateLabel.frame = CGRectMake((kCMScreenWidth-chatSize.width)/2, isShowKeyboard?(_shrinkBtn.cmam_bottom):(_serviceHeaderView.cmam_bottom+10*kCMScaleWidth), chatSize.width, 25);
        
        _stateLabel.text = stateStr;
        _stateLabel.frame = CGRectMake((kCMScreenWidth-stateSize.width)/2, _chatStateLabel.cmam_bottom+stateChatDistance*kCMScaleWidth, stateSize.width, 20);
    }
}

//根据文字获取宽度(高度一定)
- (CGSize)getWidthWithString:(NSString *)string height:(CGFloat)height font:(CGFloat)font {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:font];
    
    CGSize size =  [string boundingRectWithSize:CGSizeMake(MAXFLOAT,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}

//状态标语等待文字
- (void)stateLabelOccurenceOfString:(NSString *)string {
    NSInteger count = 0, length = [string length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound) {
        range = [string rangeOfString: @"." options:0 range:range];
        if(range.location != NSNotFound) {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    NSString *titleStr = @"通话中";
    switch (count) {
        case 0:
            _stateLabel.text = [titleStr stringByAppendingString:@"."];
            break;
        case 1:
            _stateLabel.text = [titleStr stringByAppendingString:@".."];
            break;
        case 2:
            _stateLabel.text = [titleStr stringByAppendingString:@"..."];
            break;
        case 3:
            _stateLabel.text = titleStr;
            break;
        default:
            break;
    }
}

//销毁等待时间计时器
- (void)destoryWaitTimer {
    [waitTimer invalidate];
    waitTimer = nil;
}

//销毁通话时间计时器
- (void)destoryContentTimer {
    [contenctTimer invalidate];
    contenctTimer = nil;
}

#pragma mark 懒加载
//显示视图
- (UIImageView *)showView {
    if (!_showView) {
        _showView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -kCMScreenHeight, kCMScreenWidth, kCMScreenHeight)];
        _showView.userInteractionEnabled = YES;
        [_showView setImage:kCM_loadBundleImage(@"voipbackbig")];
    }
    return _showView;
}

//左上缩小按钮
- (UIButton *)shrinkBtn {
    if (!_shrinkBtn) {
        _shrinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shrinkBtn.frame = CGRectMake(shrinkX*kCMScaleWidth, shrinkY*kCMScaleHeight, shrinkWidth*kCMScaleWidth, shrinkHeight*kCMScaleHeight);
        [_shrinkBtn setImage:kCM_loadBundleImage(@"shrink_normal") forState:UIControlStateNormal];
        [_shrinkBtn addTarget:self action:@selector(handleShrinkButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shrinkBtn;
}

//客服头像
- (UIImageView *)serviceHeaderView {
    if (!_serviceHeaderView) {
        _serviceHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake((kCMScreenWidth-headerWH*kCMScaleWidth)/2, _shrinkBtn.cmam_bottom, headerWH*kCMScaleWidth, headerWH*kCMScaleWidth)];
        [_serviceHeaderView setImage:kCM_loadBundleImage(@"serverheadbig")];
    }
    return _serviceHeaderView;
}

//聊天计时
- (UILabel *)chatStateLabel {
    if (!_chatStateLabel) {
        _chatStateLabel = [[UILabel alloc] init];
        _chatStateLabel.numberOfLines = 0;
        _chatStateLabel.adjustsFontSizeToFitWidth = YES;
        _chatStateLabel.textColor = [UIColor whiteColor];
        _chatStateLabel.font = [UIFont systemFontOfSize:24];
    }
    return _chatStateLabel;
}

//连接状态提示
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.numberOfLines = 0;
        _stateLabel.adjustsFontSizeToFitWidth = YES;
        _stateLabel.textColor = [UIColor whiteColor];
    }
    return _stateLabel;
}

//输入IVR内容
- (UITextField *)ivrContentTF {
    if (!_ivrContentTF) {
        _ivrContentTF = [[UITextField alloc] initWithFrame:CGRectMake(10, ivrContentY*kCMScaleHeight, kCMScreenWidth-15, ivrContentH*kCMScaleHeight)];
        _ivrContentTF.hidden = YES;
        _ivrContentTF.minimumFontSize = 36;
        [_ivrContentTF becomeFirstResponder];
        _ivrContentTF.inputView = [UIView new];
        _ivrContentTF.adjustsFontSizeToFitWidth = YES;
        _ivrContentTF.tintColor = [UIColor clearColor];
        _ivrContentTF.textColor = [UIColor whiteColor];
        _ivrContentTF.font = [UIFont systemFontOfSize:72];
    }
    return _ivrContentTF;
}

//提示语title
- (UILabel *)reminderLabel {
    if (!_reminderLabel) {
        _reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake((kCMScreenWidth-240*kCMScaleWidth) / 2, kCMScreenHeight-reminderY*kCMScaleHeight, 240*kCMScaleWidth, 21*kCMScaleWidth)];
        _reminderLabel.hidden = YES;
        _reminderLabel.adjustsFontSizeToFitWidth = YES;
        _reminderLabel.text = @"当前为扬声器模式，请使用听筒接听";
        _reminderLabel.textColor = [UIColor whiteColor];
        _reminderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _reminderLabel;
}

//静音按钮
- (CMAllMediaVerticalButton *)silenceBtn {
    if (!_silenceBtn) {
        _silenceBtn = [CMAllMediaVerticalButton buttonWithType:UIButtonTypeCustom];
        _silenceBtn.frame = CGRectMake(btnMargin, btnY, buttonWidth*kCMScaleWidth, buttonHeight*kCMScaleWidth);
        [_silenceBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_silenceBtn setTitle:@"静音" forState:UIControlStateNormal];
        [_silenceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_silenceBtn setImage:kCM_loadBundleImage(@"silence_mormal") forState:UIControlStateNormal];
        [_silenceBtn addTarget:self action:@selector(handleSilenceVolume:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _silenceBtn;
}

//拨号键盘按钮
- (CMAllMediaVerticalButton *)keyboardBtn {
    if (!_keyboardBtn) {
        _keyboardBtn = [CMAllMediaVerticalButton buttonWithType:UIButtonTypeCustom];
        _keyboardBtn.frame = CGRectMake(btnMargin*2+buttonWidth*kCMScaleWidth, btnY, buttonWidth*kCMScaleWidth, buttonHeight*kCMScaleHeight);
        [_keyboardBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_keyboardBtn setTitle:@"拨号键盘" forState:UIControlStateNormal];
        [_keyboardBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_keyboardBtn setImage:kCM_loadBundleImage(@"showkeyboard") forState:UIControlStateNormal];
        [_keyboardBtn addTarget:self action:@selector(handelShowNumberKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardBtn;
}

//免提按钮
- (CMAllMediaVerticalButton *)loudModeBtn {
    if (!_loudModeBtn) {
        _loudModeBtn = [CMAllMediaVerticalButton buttonWithType:UIButtonTypeCustom];
        _loudModeBtn.frame = CGRectMake(kCMScreenWidth-btnMargin-buttonWidth*kCMScaleWidth, btnY, buttonWidth*kCMScaleWidth, buttonHeight*kCMScaleHeight);
        [_loudModeBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_loudModeBtn setTitle:@"免提" forState:UIControlStateNormal];
        [_loudModeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_loudModeBtn setImage:kCM_loadBundleImage(@"loudmode_normal") forState:UIControlStateNormal];
        [_loudModeBtn addTarget:self action:@selector(handleChangeVoiceMethod:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loudModeBtn;
}

//挂断按钮
- (UIButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hangupButton.frame = CGRectMake((kCMScreenWidth-buttonWidth*kCMScaleWidth)/2, kCMScreenHeight-hangupY*kCMScaleWidth, buttonWidth*kCMScaleWidth, buttonWidth*kCMScaleWidth);
        [_hangupButton setImage:kCM_loadBundleImage(@"voiphangup_normal") forState:UIControlStateNormal];
        [_hangupButton addTarget:self action:@selector(hangupVoipPhone) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupButton;
}

//隐藏数字键盘按钮
- (UIButton *)hiddenKeyboardBtn {
    if (!_hiddenKeyboardBtn) {
        _hiddenKeyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _hiddenKeyboardBtn.frame = CGRectMake(_shrinkBtn.cmam_left, _hangupButton.cmam_top, _keyboardView.cmam_width / 3, buttonWidth*kCMScaleHeight);
        _hiddenKeyboardBtn.hidden = YES;
        [_hiddenKeyboardBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_hiddenKeyboardBtn setTitle:@"隐藏" forState:UIControlStateNormal];
        [_hiddenKeyboardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_hiddenKeyboardBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_hiddenKeyboardBtn addTarget:self action:@selector(handleHiddenNumberKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hiddenKeyboardBtn;
}

//删除指令按钮
- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(_showView.cmam_width-((_showView.cmam_width-2*_shrinkBtn.cmam_left) / 3)-_shrinkBtn.cmam_left, _hangupButton.cmam_top, _keyboardView.cmam_width / 3, buttonWidth*kCMScaleHeight);
        _deleteBtn.hidden = YES;
        [_deleteBtn setImage:kCM_loadBundleImage(@"dtmfdelete_normal") forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(handleDeleteDTMF:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

//数字键盘
- (CMAllMediaNumberKeyboardView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[CMAllMediaNumberKeyboardView alloc] initWithFrame:CGRectMake(_shrinkBtn.cmam_left, numberKeyBoardY*kCMScaleWidth, _showView.cmam_width-2*_shrinkBtn.cmam_left, _hangupButton.cmam_top-(numberKeyBoardY+20)*kCMScaleWidth)];
        _keyboardView.hidden = YES;
    }
    return _keyboardView;
}

#pragma mark Gesture Action
//全屏手势
- (UITapGestureRecognizer *)largeTap {
    if (!_largeTap) {
        _largeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEnlargeView:)];
        _largeTap.enabled = NO;
        _largeTap.delegate = self;
    }
    return _largeTap;
}

//悬浮拖拽手势
- (UIPanGestureRecognizer *)panRecognizer {
    if (!_panRecognizer) {
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanVoipView:)];
        _panRecognizer.delegate = self;
        _panRecognizer.enabled = NO;
        _panRecognizer.maximumNumberOfTouches = 1;
        _panRecognizer.minimumNumberOfTouches = 1;
    }
    return _panRecognizer;
}
@end


#pragma 自定义btn -- 上图片下文字
@implementation CMAllMediaVerticalButton
// 在重新layout子控件时，改变图片和文字的位置
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    CGRect tempImageviewRect = self.imageView.frame;
    tempImageviewRect.origin.y = 0;
    tempImageviewRect.origin.x = (self.bounds.size.width - tempImageviewRect.size.width) / 2;
    self.imageView.frame = tempImageviewRect;
    
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{@"NSFontAttributeName" : self.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 <= frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (tempImageviewRect.size.height + titleSize.height);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - tempImageviewRect.size.width, - (totalHeight - titleSize.height), 0);
}
@end

#pragma mark 数字键盘
//数组cell
@interface CMAllMediaNumberKeyboardCell : UICollectionViewCell
- (void)configureTitleAttributedText:(NSString *)str;

@property (nonatomic, strong)UILabel *titleLabel;
//下边描边
@property (nonatomic, strong)CALayer *bottomLayer;
//右边描边
@property (nonatomic, strong)CALayer *rightLayer;
@end

@implementation CMAllMediaNumberKeyboardCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.layer addSublayer:self.rightLayer];
        [self.layer addSublayer:self.bottomLayer];
    }
    return self;
}

- (void)configureTitleAttributedText:(NSString *)str {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    // 添加文字颜色
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:18.0],NSFontAttributeName,
                                   [[UIColor whiteColor] colorWithAlphaComponent:0.4],NSForegroundColorAttributeName,nil];
    [attrStr addAttributes:attributeDict range:NSMakeRange(1, str.length-1)];
    
    self.titleLabel.attributedText = attrStr;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.cmam_width, self.contentView.cmam_height)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:30];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;

    }
    return _titleLabel;
}

- (CALayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CALayer layer];
        _bottomLayer.frame = CGRectMake(0, self.contentView.cmam_height - 1, self.contentView.cmam_width, 1);
        _bottomLayer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    }
    return _bottomLayer;
}

- (CALayer *)rightLayer {
    if (!_rightLayer) {
        _rightLayer = [CALayer layer];
        _rightLayer.frame = CGRectMake(self.contentView.cmam_width - 1, 0, 1, self.contentView.cmam_height);
        _rightLayer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    }
    return _rightLayer;
}
@end

//键盘视图
@interface CMAllMediaNumberKeyboardView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong)NSArray *letterArrary;
@end

@implementation CMAllMediaNumberKeyboardView

- (NSArray *)letterArrary {
    if (!_letterArrary) {
        _letterArrary = [NSArray arrayWithObjects:@" ",@"ABC",@"DEF",@"GHI",@"JKL",@"MNO",@"PQRS",@"TUV",@"WXYZ", nil];
    }
    return _letterArrary;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 1;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.cmam_width, self.cmam_height) collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delaysContentTouches = NO;
        [collectionView registerClass:[CMAllMediaNumberKeyboardCell class] forCellWithReuseIdentifier:@"numbercell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self addSubview:collectionView];
    }
    return self;
}

//每一个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.cmam_width - 2) /3, self.cmam_height/4);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMAllMediaNumberKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"numbercell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
        {
            NSString *str = [NSString stringWithFormat:@"%zd\n%@", indexPath.row+1,self.letterArrary[indexPath.row]];
            [cell configureTitleAttributedText:str];
            
            cell.rightLayer.hidden = indexPath.row+1==3?YES:NO;
        }
            break;
        case 1:
        {
            NSString *str = [NSString stringWithFormat:@"%zd\n%@", indexPath.row+4,self.letterArrary[indexPath.row+3]];
            [cell configureTitleAttributedText:str];

            cell.rightLayer.hidden = indexPath.row+4==6?YES:NO;
        }
            break;
        case 2:
        {
            NSString *str = [NSString stringWithFormat:@"%zd\n%@", indexPath.row+7,self.letterArrary[indexPath.row+6]];
            [cell configureTitleAttributedText:str];
            
            cell.rightLayer.hidden = indexPath.row+7==9?YES:NO;
        }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    [cell configureTitleAttributedText:@"*\n"];
                    cell.bottomLayer.hidden = YES;
                    break;
                case 1:
                    [cell configureTitleAttributedText:@"0\n+"];
                    cell.bottomLayer.hidden = YES;
                    break;
                case 2:
                    [cell configureTitleAttributedText:@"#\n"];
                    cell.rightLayer.hidden = YES;
                    cell.bottomLayer.hidden = YES;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

//点击数字cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CMAllMediaNumberKeyboardCell *cell = (CMAllMediaNumberKeyboardCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.numberBlock) {
        self.numberBlock([cell.titleLabel.text substringToIndex:1]);
    }
}

//点击变色
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    CMAllMediaNumberKeyboardCell *cell = (CMAllMediaNumberKeyboardCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
}

//松开恢复
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    CMAllMediaNumberKeyboardCell *cell = (CMAllMediaNumberKeyboardCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

@end
