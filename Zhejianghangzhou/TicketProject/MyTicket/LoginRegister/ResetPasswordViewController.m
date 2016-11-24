//
//  ResetPasswordViewController.m  个人中心－重置密码
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//
//  20150820 10:59（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "ResetPasswordViewController.h"
#import "CaptchaCountDownButton.h"

#import "Globals.h"
#import "InterfaceHelper.h"

@interface ResetPasswordViewController ()

@end

#pragma mark -
#pragma mark @implementation ResetPasswordViewController
@implementation ResetPasswordViewController
#pragma mark Lifecircle

- (id)initWithPhoneNumber:(NSString *)phoneNumber {
    self = [super init];
    if (self) {
        _phoneNumber = [phoneNumber copy];
        [self setTitle:@"重置密码"];
    }
    return self;
}

- (void)dealloc {
    [_phoneNumber release];
    _phoneNumber = nil;
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
    
    //newPasswordImageView 背景图
    CGRect newPasswordImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, fieldImageViewMinY, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *newPasswordImageView = [[UIImageView alloc] initWithFrame:newPasswordImageViewRect];
    [newPasswordImageView setUserInteractionEnabled:YES];
    [newPasswordImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:newPasswordImageView];
    [newPasswordImageView release];
    
    //newPasswordField 重置密码
    CGRect newPasswordFieldRect = CGRectMake(CGRectGetMinX(newPasswordImageViewRect) + fieldTextAddY, CGRectGetMinY(newPasswordImageViewRect), CGRectGetWidth(newPasswordImageViewRect) - fieldTextAddY, CGRectGetHeight(newPasswordImageViewRect));
    _newPasswordField = [[UITextField alloc] initWithFrame:newPasswordFieldRect];
    [_newPasswordField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_newPasswordField setDelegate:self];
    [_newPasswordField setBackgroundColor:[UIColor clearColor]];
    [_newPasswordField setSecureTextEntry:YES];
    [_newPasswordField setPlaceholder:@"请设置新的登录密码"];
    [_newPasswordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_newPasswordField setTextAlignment:NSTextAlignmentLeft];
    [_newPasswordField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_newPasswordField setTag:340];
    [self.view addSubview:_newPasswordField];
    [_newPasswordField release];
    
    //newPasswordConfirmImageView 背景图
    CGRect newPasswordConfirmImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, CGRectGetMaxY(newPasswordImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *newPasswordConfirmImageView = [[UIImageView alloc] initWithFrame:newPasswordConfirmImageViewRect];
    [newPasswordConfirmImageView setUserInteractionEnabled:YES];
    [newPasswordConfirmImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:newPasswordConfirmImageView];
    [newPasswordConfirmImageView release];
    
    //newPasswordConfirmField 重置确认密码
    CGRect newPasswordConfirmFieldRect = CGRectMake(CGRectGetMinX(newPasswordConfirmImageViewRect) + fieldTextAddY, CGRectGetMinY(newPasswordConfirmImageViewRect), CGRectGetWidth(newPasswordConfirmImageViewRect) - fieldTextAddY, CGRectGetHeight(newPasswordConfirmImageViewRect));
    _newPasswordConfirmField = [[UITextField alloc] initWithFrame:newPasswordConfirmFieldRect];
    [_newPasswordConfirmField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_newPasswordConfirmField setDelegate:self];
    [_newPasswordConfirmField setBackgroundColor:[UIColor clearColor]];
    [_newPasswordConfirmField setSecureTextEntry:YES];
    [_newPasswordConfirmField setPlaceholder:@"请再次输入新的登录密码"];
    [_newPasswordConfirmField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_newPasswordConfirmField setTextAlignment:NSTextAlignmentLeft];
    [_newPasswordConfirmField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_newPasswordConfirmField setTag:341];
    [self.view addSubview:_newPasswordConfirmField];
    [_newPasswordConfirmField release];
    
    //passwordImageView
    CGRect captchaImageViewRect = CGRectMake(CGRectGetMinX(newPasswordConfirmImageViewRect), CGRectGetMaxY(newPasswordConfirmImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth - captchaButtonLandScapeInterval - captchaButtonWidth, fielfImageViewHeight);
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
    [_captchaField setTag:331];
    [self.view addSubview:_captchaField];
    [_captchaField release];
    
    //captchaButton 修改密码按钮
    CGRect getCaptchaButtonRect = CGRectMake(CGRectGetMaxX(captchaImageViewRect) + captchaButtonLandScapeInterval, CGRectGetMinY(captchaImageViewRect), captchaButtonWidth, fielfImageViewHeight);
    _getCaptchaButton = [[CaptchaCountDownButton alloc] initWithFrame:getCaptchaButtonRect];
    [_getCaptchaButton addTarget:self action:@selector(getCaptchaTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_getCaptchaButton];
    [_getCaptchaButton release];
    
    //captchaButton 修改密码按钮
    CGRect updatePasswordButtonRect = CGRectMake(CGRectGetMinX(captchaImageViewRect), CGRectGetMaxY(captchaImageViewRect) + fieldImageViewBtnVerticalInterval, CGRectGetWidth(newPasswordImageViewRect), fielfImageViewHeight);
    UIButton *updatePasswordButton = [[UIButton alloc] initWithFrame:updatePasswordButtonRect];
    [updatePasswordButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize18]];
    [updatePasswordButton.titleLabel setTextColor:[UIColor whiteColor]];
    [updatePasswordButton setTitle:@"确认" forState:UIControlStateNormal];
    [updatePasswordButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [updatePasswordButton addTarget:self action:@selector(updatePasswordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updatePasswordButton];
    [updatePasswordButton release];
    
    //tap 用来收回键盘的手势点击动作
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    [tap release];
}

- (void)viewDidLoad {
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
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
    [self clearUpdatePasswordRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        [self clearUpdatePasswordRequest];
        [SVProgressHUD showWithStatus:@"正在提交请求"];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:_phoneNumber forKey:@"mobile"];
        [dict setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_newPasswordField.text,kAppKey]] forKey:@"password"];
        
        _updatePasswordRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_ToResetPassword userId:@"-1" infoDict:dict]];
        [_updatePasswordRequest setDidFinishSelector:@selector(updatePasswordFinished:)];
        [_updatePasswordRequest setDidFailSelector:@selector(updatePasswordFail:)];
        [_updatePasswordRequest setDelegate:self];
        [_updatePasswordRequest startAsynchronous];
        
    } else if (responseDic) {
        [SVProgressHUD dismiss];
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
        
    }
}

- (void)updatePasswordFail:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"修改密码失败"];
}

- (void)updatePasswordFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"修改密码成功"];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        [Globals alertWithMessage:@"修改成功"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lightPassword"];
        [[NSUserDefaults standardUserDefaults] setObject:_phoneNumber forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] setObject:_newPasswordField.text forKey:@"lightPassword"];
        [[NSUserDefaults standardUserDefaults] setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_newPasswordField.text,kAppKey]] forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}
#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [_newPasswordField resignFirstResponder];
    [_newPasswordConfirmField resignFirstResponder];
    [_captchaField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [_newPasswordField resignFirstResponder];
    [_newPasswordConfirmField resignFirstResponder];
    [_captchaField resignFirstResponder];
}

- (void)getCaptchaTouchUpInside:(id)sender {
    [_getCaptchaButton requestNoteWithPhoneNumber:_phoneNumber];
}

- (void)updatePasswordTouchUpInside:(id)sender {
    [_newPasswordField resignFirstResponder];
    [_newPasswordConfirmField resignFirstResponder];
    [_captchaField resignFirstResponder];
    if (_newPasswordField.text.length == 0) {
        [Globals alertWithMessage:@"请输入新的登录密码"];
        return;
    } else if (_newPasswordConfirmField.text.length == 0) {
        [Globals alertWithMessage:@"请输入新的确认登录密码"];
        return;
    } else if (![_newPasswordField.text isEqualToString:_newPasswordConfirmField.text]) {
        [Globals alertWithMessage:@"新的登录密码和确认密码不一致"];
        return;
    } else if (_captchaField.text.length == 0) {
        [Globals alertWithMessage:@"请输入验证码"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在提交请求"];
    [self clearHTTPRequest];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_phoneNumber forKey:@"mobile"];
    [dict setObject:_captchaField.text forKey:@"code"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_VerificationPhoneNumberCaptcha userId:@"-1" infoDict:dict]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)clearUpdatePasswordRequest {
    if (_updatePasswordRequest != nil) {
        [_updatePasswordRequest clearDelegatesAndCancel];
        [_updatePasswordRequest release];
        _updatePasswordRequest = nil;
    }
}


@end