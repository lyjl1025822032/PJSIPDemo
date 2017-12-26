//
//  ViewController.m
//  PJSIPDemo
//
//  Created by yao on 2017/12/19.
//  Copyright © 2017年 王智垚. All rights reserved.
//

#import "ViewController.h"
#import "CMAllMediaVoipView.h"

#define kCMScreenWidth [UIScreen mainScreen].bounds.size.width
#define kCMScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[CMAllMediaVoipSDKManager sharedInstance] loginWithUsername:@"18768863993" password:@"1234" domain:@"211.138.20.170" domainPort:@"8081" completion:^(BOOL result, NSString *error) {
        NSLog(@"%@ - %@", result?@"语音接入成功":@"语音接入失败", error);
    }];

}

- (IBAction)handlePJSIPView:(UIButton *)sender {
    CMAllMediaVoipView *voipView = [[CMAllMediaVoipView alloc] initWithFrame:CGRectMake(0, 0, kCMScreenWidth, kCMScreenHeight)];
    voipView.enlargeBlock = ^{
        [self.view endEditing:YES];
    };
    voipView.voipViewBlock = ^(VoipState state, NSString *timeStr) {
        switch (state) {
            case VoipStateDisconnect:
                break;
            case VoipStateNoResponse:
                break;
            default:
                break;
        }
    };
    [voipView showVoipView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
