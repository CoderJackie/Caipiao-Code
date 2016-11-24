//
//  FeedbackViewController.m 个人中心－设置－反馈意见
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140812 13:55（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140812 14:00（洪晓彬）：进行ipad适配

#import "FeedbackViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

@interface FeedbackViewController ()

@end
#pragma mark -
#pragma mark @implementation FeedbackViewController
@implementation FeedbackViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"反馈意见"];
    }
    return self;
}

- (void)dealloc {
    _titleField = nil;
    _suggestionTextView = nil;
    _phoneField = nil;
    _emailField = nil;
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
    
    //tapGesture 点击非输入框收回键盘的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapResignKeyboard:)];
    tapGesture.delegate = self;
    [baseView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat feedBackImageViewMinX = IS_PHONE ? 10.0f : 120.0f;
    CGFloat feedBackBottomImageViewHeight = 115.0f;
    
    CGFloat feedBackFaceImageViewMinX = IS_PHONE ? 10.0f : 120.0f;
    CGFloat feedBackFaceImageViewMinY = IS_PHONE ? 15.0f : 35.0f;
    CGFloat feedBackFaceImageViewWidth = IS_PHONE ? 13.0f : 20.0f;
    CGFloat feedBackFaceImageViewHeight = IS_PHONE ? 13.0f : 20.0f;
    
    CGFloat promptLabelFeedBackFaceImageViewLandScapeInterval = 5.0f;
    
    
    CGFloat promptLabelMiny = IS_PHONE ? 13.0f : 30.0f;
    CGFloat promptLabelHeight = IS_PHONE ? 16.0f : 30.0f;
    
    
    CGFloat allTextFieldMinX = IS_PHONE ? 20.0f : 140.0f;  //提示栏跟左边的距离
    CGFloat allTextFieldHeight = IS_PHONE ? 30.0f : 40.0f;
    CGFloat layerBroderWidth = 1.0f;    //所有输入框的边框线大小
    CGFloat suggestionTextViewAddX = 3.0f;
    
    CGFloat textViewHeight = IS_PHONE ? 120.0f : 200.0f;
    
    CGFloat submitBtnAddY = IS_PHONE ? 16.5f : 20.0f;
    CGFloat submitBtnWidth = IS_PHONE ? 240.0f : 400.0f;
    CGFloat submitBtnheight = IS_PHONE ? 40.0f : 60.0f;
    
    CGFloat viewInterval = IS_PHONE ? 7.25f : 15.0f;  //控件之间的垂直方向的距离
    /********************** adjustment end ***************************/
    
    //feedBackTopImageView
    UIImageView *feedBackTopImageView = [[UIImageView alloc] init];
    [feedBackTopImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"feedBackTop.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:feedBackTopImageView];
    [feedBackTopImageView release];
    
    //feedBackBottomImageView
    UIImageView *feedBackBottomImageView = [[UIImageView alloc] init];
    [feedBackBottomImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"feedBackBottom.png"]] stretchableImageWithLeftCapWidth:10.0f topCapHeight:1.0f]];
    [self.view addSubview:feedBackBottomImageView];
    [feedBackBottomImageView release];
    
    //feedBackFace
    CGRect feedBackFaceImageViewRect = CGRectMake(feedBackFaceImageViewMinX, feedBackFaceImageViewMinY, feedBackFaceImageViewWidth, feedBackFaceImageViewHeight);
    UIImageView *feedBackFaceImageView = [[UIImageView alloc] initWithFrame:feedBackFaceImageViewRect];
    [feedBackFaceImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"feedBackFace.png"]]];
    [self.view addSubview:feedBackFaceImageView];
    [feedBackFaceImageView release];
    
    //promptLabel 提示栏
    CGRect promptLabelRect = CGRectMake(CGRectGetMaxX(feedBackFaceImageViewRect) + promptLabelFeedBackFaceImageViewLandScapeInterval , promptLabelMiny, CGRectGetWidth(appRect) - CGRectGetMaxX(feedBackFaceImageViewRect) - promptLabelFeedBackFaceImageViewLandScapeInterval, promptLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [promptLabel setText:@"你的意见将会帮助我们改进产品和服务"];
    [promptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:promptLabel];
    [promptLabel release];
    
    //titleField 标题输入框
    CGRect titleFieldRect = CGRectMake(allTextFieldMinX, CGRectGetMaxY(promptLabelRect) + viewInterval * 2, CGRectGetWidth(promptLabelRect), allTextFieldHeight);
    _titleField = [[UITextField alloc] initWithFrame:titleFieldRect];
    [_titleField setPlaceholder:@"标题"];
    [_titleField setBackgroundColor:[UIColor clearColor]];
    [_titleField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_titleField.layer setBorderWidth:layerBroderWidth];
    [_titleField.layer setBorderColor:[UIColor clearColor].CGColor];
    [_titleField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_titleField setDelegate:self];
    [self.view addSubview:_titleField];
    [_titleField release];
    
    [self addLineWithRect:CGRectMake(feedBackFaceImageViewMinX, CGRectGetMaxY(titleFieldRect) + viewInterval / 2.0f, CGRectGetWidth(appRect) - feedBackFaceImageViewMinX * 2, 1.0f) superView:self.view];
    
    //suggestionTextView 反馈
    CGRect suggestionTextViewRect = CGRectMake(allTextFieldMinX - suggestionTextViewAddX, CGRectGetMaxY(titleFieldRect) + viewInterval, CGRectGetWidth(promptLabelRect) + suggestionTextViewAddX * 2, textViewHeight);
    _suggestionTextView = [[UITextView alloc] initWithFrame:suggestionTextViewRect];
    [_suggestionTextView setBackgroundColor:[UIColor clearColor]];
    [_suggestionTextView.layer setBorderWidth:layerBroderWidth];
    [_suggestionTextView.layer setBorderColor:[UIColor clearColor].CGColor];
    [_suggestionTextView setTextColor:[UIColor lightGrayColor]];
    [_suggestionTextView setDelegate:self];
    [_suggestionTextView setText:@"请输入反馈建议"];
    [_suggestionTextView setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.view addSubview:_suggestionTextView];
    [_suggestionTextView release];
    
    [self addLineWithRect:CGRectMake(feedBackFaceImageViewMinX, CGRectGetMaxY(suggestionTextViewRect) + viewInterval / 2.0f, CGRectGetWidth(appRect) - feedBackFaceImageViewMinX * 2, 1.0f) superView:self.view];
    
    //phoneField 手机号码
    CGRect phoneFieldRect = CGRectMake(allTextFieldMinX, CGRectGetMaxY(suggestionTextViewRect) + viewInterval, CGRectGetWidth(promptLabelRect), allTextFieldHeight);
    _phoneField = [[UITextField alloc] initWithFrame:phoneFieldRect];
    [_phoneField setPlaceholder:@"你的手机号(必填)"];
    [_phoneField setBackgroundColor:[UIColor clearColor]];
    [_phoneField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_phoneField.layer setBorderWidth:layerBroderWidth];
    [_phoneField setKeyboardType:UIKeyboardTypeNumberPad];
    [_phoneField.layer setBorderColor:[UIColor clearColor].CGColor];
    [_phoneField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_phoneField setDelegate:self];
    [self.view addSubview:_phoneField];
    [_phoneField release];
    
    [self addLineWithRect:CGRectMake(feedBackFaceImageViewMinX, CGRectGetMaxY(phoneFieldRect) + viewInterval / 2.0f, CGRectGetWidth(appRect) - feedBackFaceImageViewMinX * 2, 1.0f) superView:self.view];

    //emailField 邮箱
    CGRect emailFieldRect = CGRectMake(allTextFieldMinX, CGRectGetMaxY(phoneFieldRect) + viewInterval, CGRectGetWidth(promptLabelRect), allTextFieldHeight);
    _emailField = [[UITextField alloc] initWithFrame:emailFieldRect];
    [_emailField setPlaceholder:@"你的邮箱(选填)"];
    [_emailField setBackgroundColor:[UIColor clearColor]];
    [_emailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_emailField.layer setBorderWidth:layerBroderWidth];
    [_emailField.layer setBorderColor:[UIColor clearColor].CGColor];
    [_emailField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_emailField setDelegate:self];
    [self.view addSubview:_emailField];
    [_emailField release];
    
    [self addLineWithRect:CGRectMake(feedBackFaceImageViewMinX, CGRectGetMaxY(emailFieldRect) + viewInterval / 2.0f, CGRectGetWidth(appRect) - feedBackFaceImageViewMinX * 2, 1.0f) superView:self.view];
    
    //submitButton 提交按钮
    CGRect submitButtonRect = CGRectMake((CGRectGetWidth(appRect) - submitBtnWidth) / 2.0f,CGRectGetMaxY(emailFieldRect) + viewInterval / 2.0f + submitBtnAddY, submitBtnWidth, submitBtnheight);
    UIButton *submitButton = [[UIButton alloc] initWithFrame:submitButtonRect];
    [submitButton.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:@"提交反馈" forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
    [submitButton release];
    
    //
    CGRect feedBackTopImageViewRect = CGRectMake(feedBackImageViewMinX, CGRectGetMinY(titleFieldRect) - viewInterval / 2.0f, CGRectGetWidth(appRect) - feedBackImageViewMinX * 2, CGRectGetMaxY(emailFieldRect) - CGRectGetMinY(titleFieldRect) + viewInterval / 2.0f);
    [feedBackTopImageView setFrame:feedBackTopImageViewRect];
    
    //
    CGRect feedBackBottomImageViewRect = CGRectMake(feedBackImageViewMinX, CGRectGetMaxY(feedBackTopImageViewRect), CGRectGetWidth(appRect) - feedBackImageViewMinX * 2, feedBackBottomImageViewHeight);
    [feedBackBottomImageView setFrame:feedBackBottomImageViewRect];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    _controlCanTouch = YES;
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _titleField = nil;
        _suggestionTextView = nil;
        _phoneField = nil;
        _emailField = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark-MakeUI
- (void)addLineWithRect:(CGRect)lineRect superView:(UIView *)superView {
    UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
    [lineView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
    [superView addSubview:lineView];
    [lineView release];
}

#pragma Delegate
#pragma mark -
#pragma mark -ASIHTTPRequestDelegate
-(void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"数据加载失败"];
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];

    [SVProgressHUD dismiss];
    if (responseDic && [[responseDic objectForKey:@"error"] isEqualToString:@"0"]) {
        [Globals alertWithMessage:@"提交成功" delegate:self tag:23];
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

#pragma mark -UITextViewDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _editTextFieldRect = textField.frame;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    _editTextFieldRect = textView.frame;
    if ([textView.text isEqualToString:@"请输入反馈建议"]) {
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (_suggestionTextView.text.length == 0) {
        _suggestionTextView.text = @"请输入反馈建议";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardRect = [value CGRectValue];
    
    CGFloat viewY = IncreaseNavY;
    if (CGRectGetMinY(keyBoardRect) < (CGRectGetMaxY(_editTextFieldRect) + 64.0f)) {
        viewY = 0 - (CGRectGetMaxY(_editTextFieldRect) + 64.0f - CGRectGetMinY(keyBoardRect));
    }

    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.view setFrame:CGRectMake(0, viewY, self.view.bounds.size.width, self.view.bounds.size.height)];
    [UIView commitAnimations];
    return;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3];
    [self.view setFrame:CGRectMake(0, IncreaseNavY, self.view.bounds.size.width, self.view.bounds.size.height)];
    [UIView commitAnimations];
}

#pragma mark -UIAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 23) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submit:(id)sender {
    
    [self tapResignKeyboard:nil];
    if (_titleField.text.length > 0 && _suggestionTextView.text.length > 0 && ![_suggestionTextView.text isEqualToString:@"请输入反馈建议"]) {
        if (![Globals isPhoneNumber:_phoneField.text]) {
            [Globals alertWithMessage:@"手机号码不正确"];
            return;
        }
        
        [SVProgressHUD showWithStatus:@"加载中"];
        
        if (_controlCanTouch == NO) {
            return;
        }
        _controlCanTouch = NO;
        
        [self submitRequest];
    } else {
        [Globals alertWithMessage:@"请完善信息"];
    }
    
}
//使键盘消失 view下去
- (void)tapResignKeyboard:(UITapGestureRecognizer *)tapGesture {
    [_titleField resignFirstResponder];
    [_suggestionTextView resignFirstResponder];
    [_phoneField resignFirstResponder];
    [_emailField resignFirstResponder];
}

#pragma mark -Customized: Private (General)
- (void)submitRequest {
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:_titleField.text forKey:@"title"];
    [infoDic setObject:_suggestionTextView.text forKey:@"content"];
    [infoDic setObject:_phoneField.text forKey:@"tel"];
    [infoDic setObject:_emailField.text forKey:@"email"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_FeedBack userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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

@end
