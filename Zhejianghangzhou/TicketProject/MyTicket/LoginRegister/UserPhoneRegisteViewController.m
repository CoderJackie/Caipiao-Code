		//
//  UserPhoneRegisteViewController.m
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//  20150820 12:02（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "UserPhoneRegisteViewController.h"
#import "CaptchaCountDownButton.h"
#import "HelpViewController.h"
#import "RegisteSucceedViewController.h"
#import "XFNavigationViewController.h"

#import "CustomResultParser.h"
#import "Globals.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "NSString+CustomString.h"

@interface UserPhoneRegisteViewController ()

@end

#pragma mark -
#pragma mark @implementation UserPhoneRegisteViewController
@implementation UserPhoneRegisteViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"手机注册"];
    }
    return self;
}

- (void)dealloc {
    [_userInfoDictionary release];
    _userInfoDictionary = nil;
    _userNameField = nil;
    [super dealloc];
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
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //loginBtn
    CGRect loginBtnRect = CGRectMake(0, 0, 65, 28);
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:loginBtnRect];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateHighlighted];
    [loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
    [loginBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearWhiteLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearWhiteLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *loginBtnItem = [[UIBarButtonItem alloc]initWithCustomView:loginBtn];
    [self.navigationItem setRightBarButtonItem:loginBtnItem];
    [loginBtnItem release];
    
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat fieldImageViewMinY = IS_PHONE ? 25.0f : 40.0f;
    CGFloat fieldImageViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat fielfImageViewHeight = IS_PHONE ? 43.0f : 70.0f;
    CGFloat fieldImageViewsVerticalInterval = IS_PHONE ? 15.0f : 25.0f;
    
    CGFloat fieldTextAddY = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat fieldImageViewBtnVerticalInterval = IS_PHONE ? 20.0f : 40.0f;
    
    CGFloat captchaButtonLandScapeInterval = IS_PHONE ? 10.0f : 20.0f;
    CGFloat captchaButtonWidth = IS_PHONE ? 100.0f : 180.0f;
    
    CGFloat protocolPromptLabelHeight = IS_PHONE ? 50.0f : 80.0f;
    
    CGFloat phoneRegisteButtonAddY = IS_PHONE ? 30.0f : 120.0f;
    CGFloat phoneRegisteButtonHeight = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat underLineViewMinY = IS_PHONE ? 16.0f : 25.0f;
    /********************** adjustment end ***************************/
    
    //userNameImageViewRect 背景图
    CGRect userNameImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, fieldImageViewMinY, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *userNameView = [[UIImageView alloc] initWithFrame:userNameImageViewRect];
    [userNameView setUserInteractionEnabled:YES];
    [userNameView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:userNameView];
    [userNameView release];
    
    //userNameField 账号
    CGRect userNameFieldRect = CGRectMake(CGRectGetMinX(userNameImageViewRect) + fieldTextAddY, CGRectGetMinY(userNameImageViewRect), CGRectGetWidth(userNameImageViewRect) - fieldTextAddY, CGRectGetHeight(userNameImageViewRect));
    _userNameField = [[UITextField alloc] initWithFrame:userNameFieldRect];
    [_userNameField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_userNameField setDelegate:self];
    [_userNameField setBackgroundColor:[UIColor clearColor]];
    [_userNameField setPlaceholder:@"用户名"];
    [_userNameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_userNameField setTextAlignment:NSTextAlignmentLeft];
    [_userNameField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [self.view addSubview:_userNameField];
    [_userNameField release];
    
    //userNameImageViewRect 背景图
    CGRect userPhoneNumberImageViewRect = CGRectMake(CGRectGetMinX(userNameImageViewRect), CGRectGetMaxY(userNameImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *userNameImageView = [[UIImageView alloc] initWithFrame:userPhoneNumberImageViewRect];
    [userNameImageView setUserInteractionEnabled:YES];
    [userNameImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:userNameImageView];
    [userNameImageView release];
    
    //userPhoneNumberField 手机
    CGRect userPhoneNumberFieldRect = CGRectMake(CGRectGetMinX(userPhoneNumberImageViewRect) + fieldTextAddY, CGRectGetMinY(userPhoneNumberImageViewRect), CGRectGetWidth(userPhoneNumberImageViewRect) - fieldTextAddY, CGRectGetHeight(userPhoneNumberImageViewRect));
    _userPhoneNumberField = [[UITextField alloc] initWithFrame:userPhoneNumberFieldRect];
    [_userPhoneNumberField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_userPhoneNumberField setDelegate:self];
    [_userPhoneNumberField setBackgroundColor:[UIColor clearColor]];
    [_userPhoneNumberField setPlaceholder:@"手机号 11位数字"];
    [_userPhoneNumberField setKeyboardType:UIKeyboardTypeNumberPad];
    [_userPhoneNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_userPhoneNumberField setTextAlignment:NSTextAlignmentLeft];
    [_userPhoneNumberField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [self.view addSubview:_userPhoneNumberField];
    [_userPhoneNumberField release];
    
    //passwordImageView
    CGRect passwordImageViewRect = CGRectMake(CGRectGetMinX(userPhoneNumberImageViewRect), CGRectGetMaxY(userPhoneNumberImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *passwordImageView = [[UIImageView alloc] initWithFrame:passwordImageViewRect];
    [passwordImageView setUserInteractionEnabled:YES];
    [passwordImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:passwordImageView];
    [passwordImageView release];
    
    //passwordField 密码
    CGRect passwordFieldRect = CGRectMake(CGRectGetMinX(passwordImageViewRect) + fieldTextAddY, CGRectGetMinY(passwordImageViewRect), CGRectGetWidth(passwordImageViewRect) - fieldTextAddY, CGRectGetHeight(passwordImageViewRect));
    _passwordField = [[UITextField alloc] initWithFrame:passwordFieldRect];
    [_passwordField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_passwordField setDelegate:self];
    [_passwordField setBackgroundColor:[UIColor clearColor]];
    [_passwordField setPlaceholder:@"密码 6-16个字符"];
    [_passwordField setSecureTextEntry:YES];
    [_passwordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_passwordField setTextAlignment:NSTextAlignmentLeft];
    [_passwordField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_passwordField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_passwordField];
    [_passwordField release];
    
    CGRect viewRect = CGRectMake(CGRectGetMinX(passwordImageViewRect) + fieldTextAddY, CGRectGetMaxY(passwordImageViewRect), fieldImageViewWidth, fielfImageViewHeight - 13.0f);
    UIView *view = [[UIView alloc] initWithFrame:viewRect];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setHidden:YES];
    [view setTag:345];
    [self.view addSubview:view];
    
    CGRect promptLableRects = CGRectMake(0, 0, fieldImageViewWidth, fielfImageViewHeight - 13.0f);
    UILabel *_promptLable = [[UILabel alloc] initWithFrame:promptLableRects];
    [_promptLable setBackgroundColor:[UIColor clearColor]];
    [_promptLable setText:@"请输入6-16位数字、字母或常用符号，字母区分大小写"];
    [_promptLable setTextColor:[UIColor redColor]];
    [_promptLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [view addSubview:_promptLable];
    [_promptLable release];
    [view release];
    
    NSArray *array = [NSArray arrayWithObjects:@"弱",@"中",@"强", nil];
    for (int i = 0; i < 3; i++) {
        CGRect promptLableRect = CGRectMake(CGRectGetMinX(userPhoneNumberImageViewRect) + i * (fieldImageViewWidth /5 + 10), CGRectGetMaxY(passwordImageViewRect) + 5, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
        _promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_promptButton setFrame:promptLableRect];
        [_promptButton setUserInteractionEnabled:NO];
        [_promptButton setTag:i + 1];
        [_promptButton setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [_promptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_promptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_promptButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] forState:UIControlStateNormal];
        [_promptButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateSelected];
        [_promptButton setAdjustsImageWhenHighlighted:NO];
        [_promptButton setAdjustsImageWhenDisabled:NO];
        [_promptButton setHidden:YES];
        [self.view addSubview:_promptButton];
    }
    
    //captchaImageView
    CGRect captchaImageViewRect = CGRectMake(CGRectGetMinX(userPhoneNumberImageViewRect), CGRectGetMaxY(passwordImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth - captchaButtonLandScapeInterval - captchaButtonWidth, fielfImageViewHeight);
    captchaImageView = [[UIImageView alloc] initWithFrame:captchaImageViewRect];
    [captchaImageView setUserInteractionEnabled:YES];
    [captchaImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:captchaImageView];
    [captchaImageView release];
    
    //captchaField 验证码
    CGRect captchaFieldRect = CGRectMake(CGRectGetMinX(captchaImageViewRect) + fieldTextAddY, CGRectGetMinY(captchaImageViewRect), CGRectGetWidth(captchaImageViewRect) - fieldTextAddY, CGRectGetHeight(captchaImageViewRect));
    _captchaField = [[UITextField alloc] initWithFrame:captchaFieldRect];
    [_captchaField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_captchaField setDelegate:self];
    [_captchaField setBackgroundColor:[UIColor clearColor]];
    [_captchaField setPlaceholder:@"请输入验证码"];
    [_captchaField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_captchaField setTextAlignment:NSTextAlignmentLeft];
    [_captchaField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [self.view addSubview:_captchaField];
    [_captchaField release];
    
    
    //getCaptchaButton 获取验证码按钮
    CGRect getCaptchaButtonRect = CGRectMake(CGRectGetMaxX(captchaImageViewRect) + captchaButtonLandScapeInterval, CGRectGetMinY(captchaImageViewRect), captchaButtonWidth, fielfImageViewHeight);
    _getCaptchaButton = [[CaptchaCountDownButton alloc] initWithFrame:getCaptchaButtonRect];
    [_getCaptchaButton addTarget:self action:@selector(verificationPhoneNumberTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCaptchaButton];
    [_getCaptchaButton release];
    
    //QQconfirmationImageView
    CGRect qqNumberImageViewRect = CGRectMake(CGRectGetMinX(captchaImageViewRect), CGRectGetMaxY(captchaFieldRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
    qqNumberImageView = [[UIImageView alloc] initWithFrame:qqNumberImageViewRect];
    [qqNumberImageView setUserInteractionEnabled:YES];
    [qqNumberImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:qqNumberImageView];
    [qqNumberImageView release];
    
    //QQ
    CGRect qqNumberFieldRect = CGRectMake(CGRectGetMinX(qqNumberImageViewRect) + fieldTextAddY, CGRectGetMinY(qqNumberImageViewRect), CGRectGetWidth(qqNumberImageViewRect), CGRectGetHeight(qqNumberImageViewRect));
    _qqNumberField = [[UITextField alloc] initWithFrame:qqNumberFieldRect];
    [_qqNumberField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_qqNumberField setDelegate:self];
    [_qqNumberField setBackgroundColor:[UIColor clearColor]];
    [_qqNumberField setPlaceholder:@"请输入QQ号"];
    [_qqNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_qqNumberField setTextAlignment:NSTextAlignmentLeft];
    [_qqNumberField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [self.view addSubview:_qqNumberField];
    [_qqNumberField release];
    
    //registeButton 注册按钮
    CGRect registeButtonRect = CGRectMake(CGRectGetMinX(captchaImageViewRect), CGRectGetMaxY(qqNumberImageViewRect) + fieldImageViewBtnVerticalInterval, CGRectGetWidth(userPhoneNumberImageViewRect), fielfImageViewHeight);
    registeButton = [[UIButton alloc] initWithFrame:registeButtonRect];
    [registeButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize18]];
    [registeButton.titleLabel setTextColor:[UIColor whiteColor]];
    [registeButton setTitle:@"完成注册" forState:UIControlStateNormal];
    [registeButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [registeButton addTarget:self action:@selector(registeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registeButton];
    [registeButton release];
    
    //protocolPromptLabel  协议提示文字
    NSString *protocolPrompt = @"注册即表示同意";
    CGSize protocolPromptLabelSize = [Globals defaultSizeWithString:protocolPrompt fontSize:XFIponeIpadFontSize12];
    CGRect protocolPromptLabelRect = CGRectMake(CGRectGetMinX(registeButtonRect), CGRectGetMaxY(registeButtonRect), protocolPromptLabelSize.width, protocolPromptLabelHeight);
    protocolPromptLabel = [[UILabel alloc] initWithFrame:protocolPromptLabelRect];
    [protocolPromptLabel setBackgroundColor:[UIColor clearColor]];
    [protocolPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [protocolPromptLabel setTextColor:kDarkGrayColor];
    [protocolPromptLabel setText:protocolPrompt];
    [self.view addSubview:protocolPromptLabel];
    [protocolPromptLabel release];
    
    //registeProtocolButton 查看注册协议按钮
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appPrompt = [NSString stringWithFormat:@"《%@软件用户注册协议》",appName];
    CGSize appPromptSize = [Globals defaultSizeWithString:appPrompt fontSize:XFIponeIpadFontSize12];
    CGRect registeProtocolButtonRect = CGRectMake(CGRectGetMaxX(protocolPromptLabelRect), CGRectGetMinY(protocolPromptLabelRect), appPromptSize.width, CGRectGetHeight(protocolPromptLabelRect));
    registeProtocolButton = [[UIButton alloc] initWithFrame:registeProtocolButtonRect];
    [registeProtocolButton setBackgroundColor:[UIColor clearColor]];
    [registeProtocolButton setTitle:appPrompt forState:UIControlStateNormal];
    [registeProtocolButton setTitleColor:[UIColor colorWithRed:23.0f/255.0f green:76.0f/255.0f blue:187.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [registeProtocolButton setHighlighted:NO];
    [[registeProtocolButton titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [registeProtocolButton addTarget:self action:@selector(checkRegisteProtocolTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registeProtocolButton];
    [registeProtocolButton release];
    
    //phoneRegisteButton 返回手机注册按钮
    NSString *phoneRegistePrompt = @"用户名注册";
    CGSize phoneRegistePromptSize = [Globals defaultSizeWithString:phoneRegistePrompt fontSize:XFIponeIpadFontSize14];
    CGRect phoneRegisteButtonRect = CGRectMake((CGRectGetWidth(appRect) - phoneRegistePromptSize.width) / 2.0f, CGRectGetMaxY(registeProtocolButtonRect) + phoneRegisteButtonAddY + fieldTextAddY, phoneRegistePromptSize.width, phoneRegisteButtonHeight);
    UIButton *phoneRegisteButton = [[UIButton alloc] initWithFrame:phoneRegisteButtonRect];
    [phoneRegisteButton setBackgroundColor:[UIColor clearColor]];
    [phoneRegisteButton setTitle:phoneRegistePrompt forState:UIControlStateNormal];
    [phoneRegisteButton setTitleColor:[UIColor colorWithRed:23.0f/255.0f green:76.0f/255.0f blue:187.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [phoneRegisteButton setHighlighted:NO];
    [[phoneRegisteButton titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [phoneRegisteButton addTarget:self action:@selector(phoneRegisteTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phoneRegisteButton];
    [phoneRegisteButton setHidden:YES];//隐藏按钮
    [phoneRegisteButton release];
    
    //underLineImageView 下划线
    CGRect underLineViewRect = CGRectMake(0, underLineViewMinY, CGRectGetWidth(phoneRegisteButtonRect), AllLineWidthOrHeight);
    UIView *underLineImageView = [[UIView alloc] initWithFrame:underLineViewRect];
    [underLineImageView setBackgroundColor:[UIColor colorWithRed:23.0f/255.0f green:76.0f/255.0f blue:187.0f/255.0f alpha:1.0f]];
    [phoneRegisteButton addSubview:underLineImageView];
    [underLineImageView release];
    
    
    //tap 用来收回键盘的手势点击动作
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboradHiddenTap:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    [tap release];
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    NSInteger count = [NSString checkOmString:textField.text];
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat fieldImageViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat fielfImageViewHeight = IS_PHONE ? 43.0f : 70.0f;
    CGFloat fieldImageViewsVerticalInterval = IS_PHONE ? 15.0f : 25.0f;
    
    CGFloat fieldTextAddY = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat fieldImageViewBtnVerticalInterval = IS_PHONE ? 20.0f : 40.0f;
    
    CGFloat protocolPromptLabelHeight = IS_PHONE ? 50.0f : 80.0f;
    
    CGFloat captchaButtonWidth = IS_PHONE ? 100.0f : 180.0f;
    CGFloat captchaButtonLandScapeInterval = IS_PHONE ? 10.0f : 20.0f;
    
    /********************** adjustment end ***************************/
        
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:1];
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:2];
    UIButton *btn3 = (UIButton *)[self.view viewWithTag:3];
    UIView *view = (UIView *)[self.view viewWithTag:345];
    
    if (textField.text.length < 1) {
        [btn1 setHidden:YES];
        [btn2 setHidden:YES];
        [btn3 setHidden:YES];
        [view setHidden:YES];
        
        CGRect confirmationImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, CGRectGetMaxY(textField.frame) + fieldImageViewsVerticalInterval, fieldImageViewWidth - captchaButtonLandScapeInterval - captchaButtonWidth, fielfImageViewHeight);
        [captchaImageView setFrame:confirmationImageViewRect];
        
        CGRect confirmationFieldRect = CGRectMake(CGRectGetMinX(confirmationImageViewRect) + fieldTextAddY, CGRectGetMinY(confirmationImageViewRect), CGRectGetWidth(confirmationImageViewRect), CGRectGetHeight(confirmationImageViewRect));
        [_captchaField setFrame:confirmationFieldRect];
        
        CGRect getCaptchaButtonRect = CGRectMake(CGRectGetMaxX(confirmationImageViewRect) + captchaButtonLandScapeInterval, CGRectGetMinY(confirmationFieldRect), captchaButtonWidth, fielfImageViewHeight);
        [_getCaptchaButton setFrame:getCaptchaButtonRect];
        
        CGRect qqNumberImageViewRect = CGRectMake(CGRectGetMinX(confirmationImageViewRect), CGRectGetMaxY(confirmationImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
        [qqNumberImageView setFrame:qqNumberImageViewRect];
        
        CGRect qqNumberFieldRect = CGRectMake(CGRectGetMinX(qqNumberImageViewRect) + fieldTextAddY, CGRectGetMinY(qqNumberImageViewRect), CGRectGetWidth(qqNumberImageViewRect), CGRectGetHeight(qqNumberImageViewRect));
        [_qqNumberField setFrame:qqNumberFieldRect];
        
        CGRect registeButtonRect = CGRectMake(CGRectGetMinX(confirmationImageViewRect), CGRectGetMaxY(qqNumberFieldRect) + fieldImageViewBtnVerticalInterval, CGRectGetWidth(confirmationImageViewRect), fielfImageViewHeight);
        [registeButton setFrame:registeButtonRect];
        
        NSString *protocolPrompt = @"注册即表示同意";
        CGSize protocolPromptLabelSize = [Globals defaultSizeWithString:protocolPrompt fontSize:XFIponeIpadFontSize12];
        CGRect protocolPromptLabelRect = CGRectMake(CGRectGetMinX(registeButtonRect), CGRectGetMaxY(registeButtonRect), protocolPromptLabelSize.width, protocolPromptLabelHeight);
        [protocolPromptLabel setFrame:protocolPromptLabelRect];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        NSString *appPrompt = [NSString stringWithFormat:@"《%@软件用户注册协议》",appName];
        CGSize appPromptSize = [Globals defaultSizeWithString:appPrompt fontSize:XFIponeIpadFontSize12];
        CGRect registeProtocolButtonRect = CGRectMake(CGRectGetMaxX(protocolPromptLabelRect), CGRectGetMinY(protocolPromptLabelRect), appPromptSize.width, CGRectGetHeight(protocolPromptLabelRect));
        [registeProtocolButton setFrame:registeProtocolButtonRect];
        
    } else {
        [btn1 setHidden:NO];
        [btn2 setHidden:NO];
        [btn3 setHidden:NO];
        
        if (textField.text.length < 6 || count < 3 || ![NSString ruoCheckString:textField.text]) {
            [btn1 setSelected:YES];
            [btn2 setSelected:NO];
            [btn3 setSelected:NO];
            [view setHidden:NO];
            
            CGRect viewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, CGRectGetMaxY(textField.frame), fieldImageViewWidth, fielfImageViewHeight);
            [view setFrame:viewRect];
            
            CGRect promptLableRect1 = CGRectMake(CGRectGetMinX(viewRect), CGRectGetMaxY(viewRect) - 15, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
            [btn1 setFrame:promptLableRect1];
            
            CGRect promptLableRect2 = CGRectMake(CGRectGetMinX(viewRect) + 1 * (fieldImageViewWidth /5 + 10), CGRectGetMaxY(viewRect) - 15, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
            [btn2 setFrame:promptLableRect2];
            
            CGRect promptLableRect3 = CGRectMake(CGRectGetMinX(viewRect) + 2 * (fieldImageViewWidth /5 + 10), CGRectGetMaxY(viewRect) - 15, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
            [btn3 setFrame:promptLableRect3];
            
        } else {
            [view setHidden:YES];
            CGRect promptLableRect1 = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, CGRectGetMaxY(textField.frame) + 5, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
            [btn1 setFrame:promptLableRect1];
            
            CGRect promptLableRect2 = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f + 1 * (fieldImageViewWidth /5 + 10), CGRectGetMaxY(textField.frame) + 5, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
            [btn2 setFrame:promptLableRect2];
            
            CGRect promptLableRect3 = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f + 2 * (fieldImageViewWidth /5 + 10), CGRectGetMaxY(textField.frame) + 5, fieldImageViewWidth / 5, fielfImageViewHeight - 18);
            [btn3 setFrame:promptLableRect3];
            
            if ([NSString isContainSpecialString:textField.text] && [NSString isContainString:textField.text] && [NSString isContainCheckOnString:textField.text]) {
                [btn3 setSelected:YES];
                [btn2 setSelected:NO];
                [btn1 setSelected:NO];
                
            } else {
                [btn2 setSelected:YES];
                [btn1 setSelected:NO];
                [btn3 setSelected:NO];
            }
            
        }
        
        CGRect confirmationImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, CGRectGetMaxY(btn1.frame) + 5, fieldImageViewWidth - captchaButtonLandScapeInterval - captchaButtonWidth, fielfImageViewHeight);
        [captchaImageView setFrame:confirmationImageViewRect];
        
        CGRect confirmationFieldRect = CGRectMake(CGRectGetMinX(confirmationImageViewRect) + fieldTextAddY, CGRectGetMinY(confirmationImageViewRect), CGRectGetWidth(confirmationImageViewRect), CGRectGetHeight(confirmationImageViewRect));
        [_captchaField setFrame:confirmationFieldRect];
        
        CGRect getCaptchaButtonRect = CGRectMake(CGRectGetMaxX(confirmationImageViewRect) + captchaButtonLandScapeInterval, CGRectGetMinY(confirmationImageViewRect), captchaButtonWidth, fielfImageViewHeight);
        [_getCaptchaButton setFrame:getCaptchaButtonRect];
        
        CGRect qqNumberImageViewRect = CGRectMake(CGRectGetMinX(confirmationImageViewRect), CGRectGetMaxY(confirmationImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
        [qqNumberImageView setFrame:qqNumberImageViewRect];
        
        CGRect qqNumberFieldRect = CGRectMake(CGRectGetMinX(qqNumberImageViewRect) + fieldTextAddY, CGRectGetMinY(qqNumberImageViewRect), CGRectGetWidth(qqNumberImageViewRect), CGRectGetHeight(qqNumberImageViewRect));
        [_qqNumberField setFrame:qqNumberFieldRect];
        
        CGRect registeButtonRect = CGRectMake(CGRectGetMinX(confirmationImageViewRect), CGRectGetMaxY(qqNumberImageViewRect) + fieldImageViewBtnVerticalInterval, CGRectGetWidth(confirmationImageViewRect), fielfImageViewHeight);
        [registeButton setFrame:registeButtonRect];
        
        NSString *protocolPrompt = @"注册即表示同意";
        CGSize protocolPromptLabelSize = [Globals defaultSizeWithString:protocolPrompt fontSize:XFIponeIpadFontSize12];
        CGRect protocolPromptLabelRect = CGRectMake(CGRectGetMinX(registeButtonRect), CGRectGetMaxY(registeButtonRect), protocolPromptLabelSize.width, protocolPromptLabelHeight);
        [protocolPromptLabel setFrame:protocolPromptLabelRect];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        NSString *appPrompt = [NSString stringWithFormat:@"《%@软件用户注册协议》",appName];
        CGSize appPromptSize = [Globals defaultSizeWithString:appPrompt fontSize:XFIponeIpadFontSize12];
        CGRect registeProtocolButtonRect = CGRectMake(CGRectGetMaxX(protocolPromptLabelRect), CGRectGetMinY(protocolPromptLabelRect), appPromptSize.width, CGRectGetHeight(protocolPromptLabelRect));
        [registeProtocolButton setFrame:registeProtocolButtonRect];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userInfoDictionary = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [self clearUserRegisteRequest];
    [self clearVerifyPhoneRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    [Globals alertWithMessage:@"网络连接失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    [self keyboradHiddenTap:nil];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        [self clearUserRegisteRequest];
        
        NSString *phoneNumber = [_phoneNumber copy];
        NSString *md5Password = [[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_password,kAppKey]] copy];
        
        NSString *userName = [[_userNameField.text copy] autorelease];
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:userName forKey:@"name"];
        [infoDic setObject:md5Password forKey:@"password"];
        [infoDic setObject:@"" forKey:@"email"];
        [infoDic setObject:@"" forKey:@"idcardnumber"];
        [infoDic setObject:@"" forKey:@"realityname"];
        [infoDic setObject:phoneNumber forKey:@"mobile"];
        [infoDic setObject:_qqNumberField.text forKey:@"qq"];
        [infoDic setObject:@"1" forKey:@"type"];
        
        [phoneNumber release];
        [md5Password release];
        
        _userRegisteRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_UserRegiste userId:@"-1" infoDict:infoDic]];
        [_userRegisteRequest setDidFinishSelector:@selector(phoneNumberRegisteFinshed:)];
        [_userRegisteRequest setDidFailSelector:@selector(phoneNumberRegisteFailed:)];
        [_userRegisteRequest setDelegate:self];
        [_userRegisteRequest startAsynchronous];
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
        
    } else {
        [Globals alertWithMessage:@"未知错误"];
        
    }
}

- (void)phoneNumberRegisteFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    [Globals alertWithMessage:@"网络连接失败"];
}

- (void)phoneNumberRegisteFinshed:(ASIHTTPRequest *)request {
    [self keyboradHiddenTap:nil];
    [SVProgressHUD dismiss];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        [CustomResultParser parseResult:responseDic toUserInfoDict:_userInfoDictionary];
        
        [UserInfo shareUserInfo].userID = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"uid"]];
        [UserInfo shareUserInfo].userName = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"name"]];
        [UserInfo shareUserInfo].password = [InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_passwordField.text,kAppKey]];;
        [_userInfoDictionary setObject:_passwordField.text forKey:@"password"];
        [UserInfo shareUserInfo].realName = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"realityName"]];
        [UserInfo shareUserInfo].cardNumber = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"idcardnumber"]];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"balance"]];
        [UserInfo shareUserInfo].freeze = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"freeze"]];
        [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"handselAmount"]];
        [UserInfo shareUserInfo].phoneNumber = [_userInfoDictionary stringForKey:@"mobile"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lightPassword"];
        [[NSUserDefaults standardUserDefaults] setObject:_userInfoDictionary forKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults] setObject:_phoneNumber forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] setObject:_passwordField.text forKey:@"lightPassword"];
        [[NSUserDefaults standardUserDefaults] setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_passwordField.text,kAppKey]] forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:_phoneNumber forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
//        RegisteSucceedViewController *registeSucceedViewController = [[RegisteSucceedViewController alloc] init];
//        [self.navigationController pushViewController:registeSucceedViewController animated:YES];
//        [registeSucceedViewController release];
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    } else {
        [Globals alertWithMessage:@"未知错误"];
    }
}

- (void)verifyPhoneFinshed:(ASIHTTPRequest *)request {
    [self keyboradHiddenTap:nil];
    [SVProgressHUD dismiss];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
    [_getCaptchaButton requestNoteWithPhoneNumber:_userPhoneNumberField.text];
        
    }else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

- (void)verifyPhoneFailed:(ASIHTTPRequest *)request {
    
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)registeTouchUpInside:(id)sender {
    [self keyboradHiddenTap:nil];
    if ([_userNameField.text isEqualToString:@""]) {
        [Globals alertWithMessage:@"请输入用户名"];
        return;
    }
    
    NSInteger charNumber = [NSString characterLength:_userNameField.text];
    if (charNumber < 5 || charNumber > 16) {
        [Globals alertWithMessage:@"用户名只能5到16位"];
        return;
    }
    
    if(![NSString checkOnStandardString:_userNameField.text]) {
        [Globals alertWithMessage:@"用户名只能由中文、字母或数字组成"];
        return;
    }
    
    if ([_userPhoneNumberField.text isEqualToString:@""]) {
        [Globals alertWithMessage:@"请输入手机号码"];
        return;
    }
    
    if ([_userNameField.text isEqualToString:_userPhoneNumberField.text]) {
        [Globals alertWithMessage:@"用户名不能与手机号码一致"];
        return;
    }
    
    if ([_passwordField.text isEqualToString:@""]) {
        [Globals alertWithMessage:@"请输入密码"];
        return;
    }
    
    if (_captchaField.text.length != 6) {
        [Globals alertWithMessage:@"请输入正确的验证码"];
        return;
    }
    
    NSString *userPhoneNumber = _userPhoneNumberField.text;
    charNumber = 0;
    for (int i = 0; i < userPhoneNumber.length; ++i) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [userPhoneNumber substringWithRange:range];
        const char    *cString = [subString UTF8String];
        charNumber += (strlen(cString) == 3 ? 2 : 1);
    }
    if (!(charNumber == 11)) {
        [Globals alertWithMessage:@"手机号只能11位"];
        return;
    }
    
    if (_passwordField.text.length < 6 || _passwordField.text.length > 16) {
        [Globals alertWithMessage:@"密码只能6到16位"];
        return;
    }
    
    NSInteger count = [NSString checkOmString:_passwordField.text];
    if (_passwordField.text.length < 6 || count < 3 || ![NSString ruoCheckString:_passwordField.text]) {
        [Globals alertWithMessage:@"密码强度过弱,不能注册"];
        return;
    }
    
    NSString *regex = @"^1[0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject: _userPhoneNumberField.text]) {
        ////此动画为弹出buttonqww
        [Globals alertWithMessage:@"手机号只能由数字组成"];
        return;
    }
    
    if ([_qqNumberField.text isEqualToString:@""]) {
        [Globals alertWithMessage:@"请输入QQ号"];
        return;
    }
    
    NSString *regex1 = @"[1-9][0-9]{4,10}";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    
    if(![pred1 evaluateWithObject: _qqNumberField.text]) {
        ////此动画为弹出buttonqww
        [Globals alertWithMessage:@"QQ号只能由数字组成，QQ号码只能5到11位"];
        return;
    }

    [SVProgressHUD showWithStatus:@"正在提交"];
    
    [_phoneNumber release];
    _phoneNumber = [_userPhoneNumberField.text copy];
    [_password release];
    _password = [_passwordField.text copy];
    
    NSString *userName = _userNameField.text;
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:userName forKey:@"name"];
    [infoDic setObject:_phoneNumber forKey:@"mobile"];
    [infoDic setObject:_captchaField.text forKey:@"code"];
    
    [self clearHTTPRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_VerificationPhoneNumberCaptcha userId:@"-1" infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

- (void)verificationPhoneNumberTouchUpInside:(id)sender {
    [self keyboradHiddenTap:nil];
    if (_userPhoneNumberField.text.length != 11) {
        [Globals alertWithMessage:@"请输入正确的手机号码"];
        return;
    }
    
    NSString *regex = @"^1[0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject: _userPhoneNumberField.text]) {
        [Globals alertWithMessage:@"手机号只能由数字组成"];
        return;
    }
    
    NSString *phoneNumber = [_userPhoneNumberField.text copy];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:phoneNumber forKey:@"mobile"];
    [phoneNumber release];
    
    [self clearVerifyPhoneRequest];
    [SVProgressHUD showWithStatus:@"验证中"];
    
    _verifyPhoneRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_VerifyPhoneNumber userId:@"-1" infoDict:infoDic]];
    _verifyPhoneRequest.delegate = self;
    [_verifyPhoneRequest setDidFinishSelector:@selector(verifyPhoneFinshed:)];
    [_verifyPhoneRequest setDidFailSelector:@selector(verifyPhoneFailed:)];
    [_verifyPhoneRequest startAsynchronous];
}

- (void)checkRegisteProtocolTouchUpInside:(id)sender {
    HelpViewController *helpViewController = [[HelpViewController alloc]initWithLotteryId:2000];
    [self.navigationController pushViewController:helpViewController animated:YES];
    [helpViewController release];
}

- (void)phoneRegisteTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboradHiddenTap:(UITapGestureRecognizer *)sender {
    [_userNameField resignFirstResponder];
    [_userPhoneNumberField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_captchaField resignFirstResponder];
    [_qqNumberField resignFirstResponder];
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)clearUserRegisteRequest {
    if (_userRegisteRequest != nil) {
        [_userRegisteRequest clearDelegatesAndCancel];
        [_userRegisteRequest release];
        _userRegisteRequest = nil;
    }
}

- (void)clearVerifyPhoneRequest {
    if (_verifyPhoneRequest != nil) {
        [_verifyPhoneRequest clearDelegatesAndCancel];
        [_verifyPhoneRequest release];
        _verifyPhoneRequest = nil;
    }
}

@end
