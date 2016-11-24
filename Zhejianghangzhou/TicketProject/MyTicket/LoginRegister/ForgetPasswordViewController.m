//
//  ForgetPasswordViewController.m 个人中心－验证账户
//  TicketProject
//
//  Created by KAI on 15-1-19.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "ResetPasswordViewController.h"
#import "CaptchaButton.h"

#import "Globals.h"

@interface ForgetPasswordViewController ()

@end

#pragma mark -
#pragma mark @implementation ForgetPasswordViewController
@implementation ForgetPasswordViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"验证账户"];
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
    
    CGFloat fieldImageViewBtnVerticalInterval = IS_PHONE ? 20.0f : 40.0f;
    
    CGFloat captchaButtonLandScapeInterval = IS_PHONE ? 10.0f : 20.0f;
    CGFloat captchaButtonWidth = IS_PHONE ? 100.0f : 180.0f;
    /********************** adjustment end ***************************/
    
    //userNameImageView 背景图
    CGRect userNameImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, fieldImageViewMinY, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *userNameImageView = [[UIImageView alloc] initWithFrame:userNameImageViewRect];
    [userNameImageView setUserInteractionEnabled:YES];
    [userNameImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:userNameImageView];
    [userNameImageView release];
    
    //userNameField 账号
    CGRect userNameFieldRect = CGRectMake(CGRectGetMinX(userNameImageViewRect) + fieldTextAddY, CGRectGetMinY(userNameImageViewRect), CGRectGetWidth(userNameImageViewRect) - fieldTextAddY, CGRectGetHeight(userNameImageViewRect));
    _userNameField = [[UITextField alloc] initWithFrame:userNameFieldRect];
    [_userNameField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_userNameField setDelegate:self];
    [_userNameField setBackgroundColor:[UIColor clearColor]];
    [_userNameField setKeyboardType:UIKeyboardTypeNumberPad];
    [_userNameField setPlaceholder:@"请输入手机号码"];
    [_userNameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_userNameField setTextAlignment:NSTextAlignmentLeft];
    [_userNameField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_userNameField setTag:330];
    [self.view addSubview:_userNameField];
    [_userNameField release];
    
    //passwordImageView
    CGRect captchaImageViewRect = CGRectMake(CGRectGetMinX(userNameImageViewRect), CGRectGetMaxY(userNameImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth - captchaButtonLandScapeInterval - captchaButtonWidth, fielfImageViewHeight);
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
    [_captchaField setPlaceholder:@"请输入右侧验证码"];
    [_captchaField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_captchaField setTextAlignment:NSTextAlignmentLeft];
    [_captchaField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_captchaField setTag:331];
    [self.view addSubview:_captchaField];
    [_captchaField release];
    
    //getCaptchaButton 获取验证码按钮
    CGRect getCaptchaButtonRect = CGRectMake(CGRectGetMaxX(captchaImageViewRect) + captchaButtonLandScapeInterval, CGRectGetMinY(captchaImageViewRect), captchaButtonWidth, fielfImageViewHeight);
    _getCaptchaButton = [[CaptchaButton alloc] initWithFrame:getCaptchaButtonRect];
    [_getCaptchaButton setBackgroundColor:[UIColor colorWithRed:160.0f/255.0f green:117.0f/255.0f blue:63.0f/255.0f alpha:1.0f]];
    [_getCaptchaButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_getCaptchaButton.titleLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_getCaptchaButton];
    [_getCaptchaButton release];
    
    //captchaButton 验证账号按钮
    CGRect captchaButtonRect = CGRectMake(CGRectGetMinX(captchaImageViewRect), CGRectGetMaxY(captchaImageViewRect) + fieldImageViewBtnVerticalInterval, CGRectGetWidth(userNameImageViewRect), fielfImageViewHeight);
    UIButton *captchaButton = [[UIButton alloc] initWithFrame:captchaButtonRect];
    [captchaButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize18]];
    [captchaButton.titleLabel setTextColor:[UIColor whiteColor]];
    [captchaButton setTitle:@"验证账号" forState:UIControlStateNormal];
    [captchaButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [captchaButton addTarget:self action:@selector(captchaTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captchaButton];
    [captchaButton release];
    
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
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"连接失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
        
    } else if (responseDic) {
        NSInteger hasPhoneNumber = [responseDic intValueForKey:@"hasPhoneNumber"];
        if (hasPhoneNumber == 1) {
            ResetPasswordViewController *resetPasswordViewController = [[ResetPasswordViewController alloc] initWithPhoneNumber:_userNameField.text];
            [self.navigationController pushViewController:resetPasswordViewController animated:YES];
            [resetPasswordViewController release];
            
        } else {
            [Globals alertWithMessage:@"手机号不存在"];
        }
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if ((range.location >= 11 && textField.tag == 330) || (range.location >= 4 && textField.tag == 331)) {
        return NO;
    }

    NSString *regex = @"[a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if(![pred evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 330) {
        
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [_userNameField resignFirstResponder];
    [_captchaField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)captchaTouchUpInside:(id)sender {
    [_userNameField resignFirstResponder];
    [_captchaField resignFirstResponder];
    if (_userNameField.text.length != 11) {
        [Globals alertWithMessage:@"请输入正确的的手机号"];
        return;
        
    } else if (_captchaField.text.length == 0) {
        [Globals alertWithMessage:@"请输入验证码"];
        return;
        
    } else if (![_captchaField.text isEqualToString:_getCaptchaButton.captchaString]) {
        [Globals alertWithMessage:@"验证码错误"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"验证账户中"];
    [self clearHTTPRequest];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_userNameField.text forKey:@"mobile"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_VerifyPhoneNumber userId:@"-1" infoDict:dict]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [_userNameField resignFirstResponder];
    [_captchaField resignFirstResponder];
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

@end
