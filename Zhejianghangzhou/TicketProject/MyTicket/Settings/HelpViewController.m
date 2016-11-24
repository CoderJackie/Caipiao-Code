//
//  HelpViewController.m 合买说明 || 玩法说明
//  TicketProject
//
//  Created by sls002 on 13-8-16.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140812 15:39（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140812 15:45（洪晓彬）：进行ipad适配

#import "HelpViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "GlobalsProject.h"
#import "Service.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

-(void)dealloc {
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nil;
    _textView = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:([Service getDefaultService].lotteryTypes == 1000) ? @"合买说明" : @"玩法说明"];
    }
    return self;
}

- (id)initWithLotteryId:(NSInteger)lotteryId {
    self = [super init];
    if (self) {
        _lotteryId = lotteryId;
        [self setTitle:([Service getDefaultService].lotteryTypes == 1000) ? @"合买说明" : @"玩法说明"];
    }
    return self;
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
	[baseView release];

    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];

    //textView 帮助说明框
    CGRect textViewRect = CGRectMake(CGRectGetMinX(appRect), CGRectGetMinY(appRect), CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f);
    _textView = [[UITextView alloc] initWithFrame:textViewRect];
    [_textView setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setTextColor:kDarkGrayColor];
    [_textView setEditable:NO];
    [self.view addSubview:_textView];
    [_textView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTxt];
}

- (void)viewWillAppear:(BOOL)animated {
    _originalNavHidden = self.xfTabBarController.tabBarHidden;
    [self.xfTabBarController setTabBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)getBack:(UIButton *)sender {
    if (_lotteryId == 2000) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.xfTabBarController setTabBarHidden:_originalNavHidden];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)addTxt {
    Service*service=[Service getDefaultService];
    NSInteger lotteryType = 0;
    if (_lotteryId > 0) {
        lotteryType = _lotteryId;
    } else {
        lotteryType = service.lotteryTypes;
    }
    /*
     0:双色球
     1:竞彩足球
     2:大乐透
     3:竞彩篮球
     4:3D
     5:排列三
     6:七星彩
     7:七乐彩
     8:排列五
     9:胜负彩
     10:任选九
     */
    
    [self showText:[GlobalsProject helpTxtNameWithPlayID:lotteryType]];
    if (lotteryType == 2000) {
        [self setTitle:@"注册协议"];
    }else if(lotteryType == 1111) {
        [self setTitle:@"奖金优化玩法说明"];
    }
}

- (void)showText:(NSString *)textName {
    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:textName];
    [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _textView.text=str;
    [str release];
}

@end
