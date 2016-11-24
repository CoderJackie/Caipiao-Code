//
//  PhoneVerificationViewController.m  个人中心－手机验证
//  TicketProject
//
//  Created by KAI on 15-1-21.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "PhoneVerificationViewController.h"
#import "CaptchaCountDownButton.h"
#import "Globals.h"
#import "UserInfo.h"

@interface PhoneVerificationViewController ()

@end

#pragma mark -
#pragma mark @implementation PhoneVerificationViewController
@implementation PhoneVerificationViewController
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"手机验证"];
    }
    return self;
}

- (void)dealloc {
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
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat fieldImageViewMinY = IS_PHONE ? 25.0f : 40.0f;
    CGFloat fieldImageViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat fielfImageViewHeight = IS_PHONE ? 43.0f : 70.0f;
    CGFloat fieldImageViewsVerticalInterval = IS_PHONE ? 15.0f : 25.0f;
    
    CGFloat fieldTextAddY = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat fieldImageViewBtnVerticalInterval = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat captchaButtonLandScapeInterval = IS_PHONE ? 10.0f : 20.0f;
    CGFloat captchaButtonWidth = IS_PHONE ? 100.0f : 180.0f;
    /********************** adjustment end ***************************/
    
    //phoneImageView 背景图
    CGRect phoneImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, fieldImageViewMinY, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *phoneImageView = [[UIImageView alloc] initWithFrame:phoneImageViewRect];
    [phoneImageView setUserInteractionEnabled:YES];
    [phoneImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:phoneImageView];
    [phoneImageView release];
    
    //phoneNumberField 手机号码
    CGRect phoneNumberFieldRect = CGRectMake(CGRectGetMinX(phoneImageViewRect) + fieldTextAddY, CGRectGetMinY(phoneImageViewRect), CGRectGetWidth(phoneImageViewRect) - fieldTextAddY, CGRectGetHeight(phoneImageViewRect));
    _phoneNumberField = [[UITextField alloc] initWithFrame:phoneNumberFieldRect];
    [_phoneNumberField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_phoneNumberField setDelegate:self];
    [_phoneNumberField setKeyboardType:UIKeyboardTypeNumberPad];
    [_phoneNumberField setBackgroundColor:[UIColor clearColor]];
    [_phoneNumberField setPlaceholder:@"请输入关联的手机号码"];
    [_phoneNumberField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_phoneNumberField setTextAlignment:NSTextAlignmentLeft];
    [_phoneNumberField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_phoneNumberField setTag:340];
    [self.view addSubview:_phoneNumberField];
    [_phoneNumberField release];
    
    //passwordImageView
    CGRect captchaImageViewRect = CGRectMake(CGRectGetMinX(phoneImageViewRect), CGRectGetMaxY(phoneImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth - captchaButtonLandScapeInterval - captchaButtonWidth, fielfImageViewHeight);
    UIImageView *captchaImageView = [[UIImageView alloc] initWithFrame:captchaImageViewRect];
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
    [_captchaField setTag:341];
    [self.view addSubview:_captchaField];
    [_captchaField release];
    
    //captchaButton 获取验证码按钮
    CGRect getCaptchaButtonRect = CGRectMake(CGRectGetMaxX(captchaImageViewRect) + captchaButtonLandScapeInterval, CGRectGetMinY(captchaImageViewRect), captchaButtonWidth, fielfImageViewHeight);
    _getCaptchaButton = [[CaptchaCountDownButton alloc] initWithFrame:getCaptchaButtonRect];
    [_getCaptchaButton addTarget:self action:@selector(getCaptchaTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCaptchaButton];
    [_getCaptchaButton release];
    
    //checkPhoneButton 验证手机号码
    CGRect checkPhoneButtonRect = CGRectMake(CGRectGetMinX(captchaImageViewRect), CGRectGetMaxY(captchaImageViewRect) + fieldImageViewBtnVerticalInterval, CGRectGetWidth(phoneImageViewRect), fielfImageViewHeight);
    UIButton *checkPhoneButton = [[UIButton alloc] initWithFrame:checkPhoneButtonRect];
    [checkPhoneButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize18]];
    [checkPhoneButton.titleLabel setTextColor:[UIColor whiteColor]];
    [checkPhoneButton setTitle:@"确认" forState:UIControlStateNormal];
    [checkPhoneButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [checkPhoneButton addTarget:self action:@selector(checkPhoneTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkPhoneButton];
    [checkPhoneButton release];
    
    //tap 用来收回键盘的手势点击动作
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    [tap release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if (range.location >= 11 && textField.tag == 340) {
        return NO;
    }
    
    NSString *regex = @"[a-zA-Z0-9]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if(![pred evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}


#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [Globals alertWithMessage:@"连接网络失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [self handleTap:nil];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        [_getCaptchaButton requestNoteWithPhoneNumber:_phoneNumberField.text];
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

- (void)requestVerificationFinished:(ASIHTTPRequest *)request {
    [self handleTap:nil];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(phoneVerificationPassWithPhoneNumber:)]) {
            NSString *phoneNumber = [_phoneNumberField.text copy];
            [_delegate phoneVerificationPassWithPhoneNumber:phoneNumber];
            [phoneNumber release];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

- (void)requestVerificationFail:(ASIHTTPRequest *)request {
    [Globals alertWithMessage:@"连接网络失败"];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getCaptchaTouchUpInside:(id)sender {
    [_phoneNumberField resignFirstResponder];
    [_captchaField resignFirstResponder];
    if (_phoneNumberField.text.length != 11) {
        [Globals alertWithMessage:@"请输入正确的手机号码"];
        return;
    }
    
    NSString *regex = @"^1[0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject: _phoneNumberField.text]) {
        [Globals alertWithMessage:@"手机号只能由数字组成"];
        return;
    }
    
    NSString *phoneNumber = [_phoneNumberField.text copy];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:phoneNumber forKey:@"mobile"];
    [phoneNumber release];
    
    [self clearHTTPRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_VerifyPhoneNumber userId:@"-1" infoDict:infoDic]];
    _httpRequest.delegate = self;
    [_httpRequest startAsynchronous];
}

- (void)checkPhoneTouchUpInside:(id)sender {
    [_phoneNumberField resignFirstResponder];
    [_captchaField resignFirstResponder];
    if (_phoneNumberField.text.length != 11) {
        [Globals alertWithMessage:@"请输入正确的手机号码"];
        return;
    } else if (_captchaField.text.length == 0) {
        [Globals alertWithMessage:@"请输入验证码"];
        return;
    }
    
    NSString *regex = @"^1[0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject: _phoneNumberField.text]) {
        [Globals alertWithMessage:@"手机号只能由数字组成"];
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_phoneNumberField.text forKey:@"mobile"];
    [dict setObject:_captchaField.text forKey:@"code"];
    
    
    [self clearVerificationRequest];
    _verificationRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_VerificationPhoneNumberCaptcha userId:@"-1" infoDict:dict]];
    [_verificationRequest setDidFinishSelector:@selector(requestVerificationFinished:)];
    [_verificationRequest setDidFailSelector:@selector(requestVerificationFail:)];
    [_verificationRequest setDelegate:self];
    [_verificationRequest startAsynchronous];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [_phoneNumberField resignFirstResponder];
    [_captchaField resignFirstResponder];
}

#pragma mark -Customized: Private (General)
- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)clearVerificationRequest {
    if (_verificationRequest != nil) {
        [_verificationRequest clearDelegatesAndCancel];
        [_verificationRequest release];
        _verificationRequest = nil;
    }
}

@end