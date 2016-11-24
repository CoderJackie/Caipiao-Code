//
//  UpdatePasswordViewController.m  个人中心－设置－修改密码
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "UserLoginViewController.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"
#import "SVProgressHUD.h"

#import "Globals.h"
#import "UserInfo.h"
#import "InterfaceHelper.h"
#import "NSString+CustomString.h"

@interface UpdatePasswordViewController ()

@end

#pragma mark -
#pragma mark @implementation UpdatePasswordViewController
@implementation UpdatePasswordViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"修改密码"];
    }
    return self;
}

- (void)dealloc {
    _oldPasswordTextField = nil;
    _newPasswordTextField = nil;
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
    CGFloat oneLineHeight = IS_PHONE ? 45.0f : 80.0f;
    
    CGFloat labelMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat labelWidth = IS_PHONE ? 60.0f : 130.0f;
    
    CGFloat labelTextFieldLandscape = IS_PHONE ? 5.0f : 8.0f;
    
    CGFloat confirmBtnMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat confirmBtnAddY = IS_PHONE ? 20.0f : 30.0f;
    CGFloat confirmBtnHeight = IS_PHONE ? 43.0f : 66.0f;
    
    CGFloat promptLabelHeight = IS_PHONE ? 40.0f : 60.0f;
    /********************** adjustment end ***************************/
    //oldPasswordPromptLabel
    CGRect oldPasswordPromptLabelRect = CGRectMake(labelMinX, 0, labelWidth, oneLineHeight - AllLineWidthOrHeight);
    UILabel *oldPasswordPromptLabel = [[UILabel alloc] initWithFrame:oldPasswordPromptLabelRect];
    [oldPasswordPromptLabel setBackgroundColor:[UIColor clearColor]];
    [oldPasswordPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [oldPasswordPromptLabel setTextColor:kDarkGrayColor];
    [oldPasswordPromptLabel setText:@"原始密码"];
    [self.view addSubview:oldPasswordPromptLabel];
    [oldPasswordPromptLabel release];
    
    //oldPasswordTextField
    CGRect oldPasswordTextFieldRect = CGRectMake(CGRectGetMaxX(oldPasswordPromptLabelRect) + labelTextFieldLandscape, CGRectGetMinY(oldPasswordPromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(oldPasswordPromptLabelRect) - labelTextFieldLandscape, CGRectGetHeight(oldPasswordPromptLabelRect));
    _oldPasswordTextField = [[UITextField alloc] initWithFrame:oldPasswordTextFieldRect];
    [_oldPasswordTextField setBackgroundColor:[UIColor clearColor]];
    [_oldPasswordTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_oldPasswordTextField setDelegate:self];
    [_oldPasswordTextField setBackgroundColor:[UIColor clearColor]];
    [_oldPasswordTextField setSecureTextEntry:YES];
    [_oldPasswordTextField setPlaceholder:@"请输入旧密码"];
    [_oldPasswordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_oldPasswordTextField setTextAlignment:NSTextAlignmentLeft];
    [_oldPasswordTextField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [self.view addSubview:_oldPasswordTextField];
    [_oldPasswordTextField release];
    
    //lineImageView1
    CGRect lineImageView1Rect = CGRectMake(0, CGRectGetMaxY(oldPasswordPromptLabelRect), CGRectGetWidth(appRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:lineImageView1Rect inSuperView:self.view];
    
    //newPasswordPromptLabel
    CGRect newPasswordPromptLabelRect = CGRectMake(labelMinX, CGRectGetMaxY(lineImageView1Rect), labelWidth, oneLineHeight - AllLineWidthOrHeight);
    UILabel *newPasswordPromptLabel = [[UILabel alloc] initWithFrame:newPasswordPromptLabelRect];
    [newPasswordPromptLabel setBackgroundColor:[UIColor clearColor]];
    [newPasswordPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [newPasswordPromptLabel setTextColor:kDarkGrayColor];
    [newPasswordPromptLabel setText:@"新密码"];
    [self.view addSubview:newPasswordPromptLabel];
    [newPasswordPromptLabel release];
    
    //newPasswordTextField
    CGRect newPasswordTextFieldRect = CGRectMake(CGRectGetMaxX(newPasswordPromptLabelRect) + labelTextFieldLandscape, CGRectGetMinY(newPasswordPromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(newPasswordPromptLabelRect) - labelTextFieldLandscape, CGRectGetHeight(newPasswordPromptLabelRect));
    _newPasswordTextField = [[UITextField alloc] initWithFrame:newPasswordTextFieldRect];
    [_newPasswordTextField setBackgroundColor:[UIColor clearColor]];
    [_newPasswordTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_newPasswordTextField setDelegate:self];
    [_newPasswordTextField setBackgroundColor:[UIColor clearColor]];
    [_newPasswordTextField setSecureTextEntry:YES];
    [_newPasswordTextField setPlaceholder:@"请输入新密码"];
    [_newPasswordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_newPasswordTextField setTextAlignment:NSTextAlignmentLeft];
    [_newPasswordTextField setTextColor:[UIColor colorWithRed:90.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [_newPasswordTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_newPasswordTextField];
    [_newPasswordTextField release];
    
    //lineImageView2
    CGRect lineImageView2Rect = CGRectMake(0, CGRectGetMaxY(newPasswordPromptLabelRect), CGRectGetWidth(appRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:lineImageView2Rect inSuperView:self.view];
    
    
    CGRect viewRect = CGRectMake(confirmBtnMinX, CGRectGetMaxY(lineImageView2Rect), CGRectGetWidth(appRect) - confirmBtnMinX * 2, confirmBtnHeight - 13.0f);
    UIView *view = [[UIView alloc] initWithFrame:viewRect];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setHidden:YES];
    [view setTag:345];
    [self.view addSubview:view];
    
    CGRect promptLableRects = CGRectMake(0, 0, CGRectGetWidth(appRect) - confirmBtnMinX * 2, confirmBtnHeight - 13.0f);
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
        CGRect promptLableRect = CGRectMake(confirmBtnMinX + i * ((CGRectGetWidth(appRect) - confirmBtnMinX * 2) /5 + 10), CGRectGetMaxY(lineImageView2Rect) + 5, (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
        UIButton *_promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    
    //registeButton 注册按钮
    CGRect confirmBtnRect = CGRectMake(confirmBtnMinX, CGRectGetMaxY(lineImageView2Rect) + confirmBtnAddY, CGRectGetWidth(appRect) - confirmBtnMinX * 2, confirmBtnHeight);
    confirmBtn = [[UIButton alloc] initWithFrame:confirmBtnRect];
    [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize18]];
    [confirmBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [confirmBtn setTitle:@"确 认" forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    [confirmBtn release];
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(CGRectGetMinX(confirmBtnRect), CGRectGetMaxY(confirmBtnRect), CGRectGetWidth(confirmBtnRect), promptLabelHeight);
    promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [promptLabel setText:@"提示：输入旧密码以及新密码即可完成密码修改"];
    [promptLabel setTextColor:[UIColor colorWithRed:251.0f/255.0f green:8.0f/255.0f blue:27.0f/255.0f alpha:1.0f]];
    [self.view addSubview:promptLabel];
    [promptLabel release];
    
    
    //tap 用来收回键盘的手势点击动作
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    [tap release];
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    NSInteger count = [NSString checkOmString:textField.text];
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat oneLineHeight = IS_PHONE ? 45.0f : 80.0f;
    
    CGFloat confirmBtnMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat confirmBtnAddY = IS_PHONE ? 20.0f : 30.0f;
    CGFloat confirmBtnHeight = IS_PHONE ? 43.0f : 66.0f;
    
    CGFloat promptLabelHeight = IS_PHONE ? 40.0f : 60.0f;
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
        
        CGRect confirmBtnRect = CGRectMake(confirmBtnMinX, oneLineHeight * 2 + confirmBtnAddY, CGRectGetWidth(appRect) - confirmBtnMinX * 2, confirmBtnHeight);
        [confirmBtn setFrame:confirmBtnRect];
        
        //promptLabel
        CGRect promptLabelRect = CGRectMake(CGRectGetMinX(confirmBtnRect), CGRectGetMaxY(confirmBtnRect), CGRectGetWidth(confirmBtnRect), promptLabelHeight);
        [promptLabel setFrame:promptLabelRect];
        
    } else {
        [btn1 setHidden:NO];
        [btn2 setHidden:NO];
        [btn3 setHidden:NO];
        
        if (textField.text.length < 6 || count < 3 || ![NSString ruoCheckString:textField.text]) {
            [btn1 setSelected:YES];
            [btn2 setSelected:NO];
            [btn3 setSelected:NO];
            [view setHidden:NO];
            
            CGRect viewRect = CGRectMake(confirmBtnMinX, oneLineHeight * 2, CGRectGetWidth(appRect) - confirmBtnMinX * 2, confirmBtnHeight - 13.0f);
            [view setFrame:viewRect];
            
            CGRect promptLableRect1 = CGRectMake(CGRectGetMinX(viewRect), CGRectGetMaxY(viewRect), (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
            [btn1 setFrame:promptLableRect1];
            
            CGRect promptLableRect2 = CGRectMake(CGRectGetMinX(viewRect) + 1 * ((CGRectGetWidth(appRect) - confirmBtnMinX * 2)  /5 + 10), CGRectGetMaxY(viewRect), (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
            [btn2 setFrame:promptLableRect2];
            
            CGRect promptLableRect3 = CGRectMake(CGRectGetMinX(viewRect) + 2 * ((CGRectGetWidth(appRect) - confirmBtnMinX * 2)  /5 + 10), CGRectGetMaxY(viewRect), (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
            [btn3 setFrame:promptLableRect3];
            
        } else {
            [view setHidden:YES];
            CGRect promptLableRect1 = CGRectMake(confirmBtnMinX, CGRectGetMaxY(textField.frame) + 15, (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
            [btn1 setFrame:promptLableRect1];
            
            CGRect promptLableRect2 = CGRectMake(confirmBtnMinX + 1 * ((CGRectGetWidth(appRect) - confirmBtnMinX * 2)  /5 + 10), CGRectGetMaxY(textField.frame) + 15, (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
            [btn2 setFrame:promptLableRect2];
            
            CGRect promptLableRect3 = CGRectMake(confirmBtnMinX + 2 * ((CGRectGetWidth(appRect) - confirmBtnMinX * 2)  /5 + 10), CGRectGetMaxY(textField.frame) + 15, (CGRectGetWidth(appRect) - confirmBtnMinX * 2) / 5, confirmBtnHeight - 18);
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
        
        CGRect confirmBtnRect = CGRectMake(confirmBtnMinX, CGRectGetMaxY(btn1.frame) + confirmBtnAddY, CGRectGetWidth(appRect) - confirmBtnMinX * 2, confirmBtnHeight);
        [confirmBtn setFrame:confirmBtnRect];
        
        //promptLabel
        CGRect promptLabelRect = CGRectMake(CGRectGetMinX(confirmBtnRect), CGRectGetMaxY(confirmBtnRect), CGRectGetWidth(confirmBtnRect), promptLabelHeight);
        [promptLabel setFrame:promptLabelRect];

        
    }
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
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"链接失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"修改密码成功"];
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        NSInteger updateSucceed = [responseDic intValueForKey:@"update"];
        if (updateSucceed == 1) {
            [Globals alertWithMessage:@"修改密码成功"];
            [UserInfo shareUserInfo].userID = nil;
            [UserInfo shareUserInfo].userName = nil;
            [UserInfo shareUserInfo].password = nil;
            [UserInfo shareUserInfo].realName = nil;
            [UserInfo shareUserInfo].cardNumber = nil;
            [UserInfo shareUserInfo].phoneNumber = nil;
            [UserInfo shareUserInfo].balance = nil;
            [UserInfo shareUserInfo].freeze = nil;
            [UserInfo shareUserInfo].handselAmount = nil;
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^(){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lightPassword"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UserLoginViewController *login = [[UserLoginViewController alloc]init];
                XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
                [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = loginNav;
                [self.xfTabBarController.currentController.view.window.rootViewController presentViewController:loginNav animated:YES completion:nil];
                [loginNav release];
                [login release];
            }];
        }
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmTouchUpInside:(id)sender {
    [_oldPasswordTextField resignFirstResponder];
    [_newPasswordTextField resignFirstResponder];
    if (_oldPasswordTextField.text.length == 0) {
        [Globals alertWithMessage:@"请输入旧密码"];
        return;
    } else if (_newPasswordTextField.text.length == 0) {
        [Globals alertWithMessage:@"请输入新密码"];
        return;
    }
    
    if (_oldPasswordTextField.text.length < 6 || _oldPasswordTextField.text.length > 16) {
        [Globals alertWithMessage:@"密码只能6到16位"];
        return;
    } else if (_newPasswordTextField.text.length < 6 || _newPasswordTextField.text.length > 16) {
        [Globals alertWithMessage:@"密码只能6到16位"];
        return;
    }
    
    NSInteger count = [NSString checkOmString:_newPasswordTextField.text];
    if (_newPasswordTextField.text.length < 6 || count < 3 || ![NSString ruoCheckString:_newPasswordTextField.text]) {
        [Globals alertWithMessage:@"密码强度过弱,不能修改"];
        return;
    }
    
    [self clearHTTPRequest];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[UserInfo shareUserInfo].userID forKey:@"uid"];
    [dict setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_oldPasswordTextField.text,kAppKey]] forKey:@"password"];
    [dict setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_newPasswordTextField.text,kAppKey]] forKey:@"theNewPassword"];
    
    [SVProgressHUD showWithStatus:@"正在修改密码"];
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_UpdatePassword userId:@"-1" infoDict:dict]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [_oldPasswordTextField resignFirstResponder];
    [_newPasswordTextField resignFirstResponder];
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}


@end