//
//  DetailInformationViewController.m 个人中心－消息中心－消息详情
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140812 09:51（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140812 09:51（洪晓彬）：进行ipad适配

#import "DetailInformationViewController.h"

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "XFTabBarViewController.h"

@interface DetailInformationViewController ()
/** 向服务器发送请求 更新该消息为已经阅读状态*/
- (void)updateReadStatus;
@end
#pragma mark -
#pragma mark @implementation DetailInformationViewController
@implementation DetailInformationViewController
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithDetailDictionary:(NSDictionary *)dic withType:(NSInteger)type {
    self = [super init];
    if(self) {
        _originalTabBarState = self.xfTabBarController.tabBarHidden;
        [self.xfTabBarController setTabBarHidden:YES];
        [self setTitle:@"消息详情"];
        _detailDic = [dic retain];
        _type = type;
    }
    return self;
}

- (void)dealloc {
    [_detailDic release];
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor whiteColor]];
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
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat contentTextViewMinX = 15.0f;
    CGFloat contentTextViewMinY = 15.0f;
    CGFloat contentTextViewHeight = 250.0f;
    /********************** adjustment end ***************************/
    
    //contentTextView 消息显示框
    CGRect contentTextViewRect = CGRectMake(contentTextViewMinX, contentTextViewMinY, CGRectGetWidth(appRect) - 2 * contentTextViewMinX, contentTextViewHeight);
    UITextView *contentTextView = [[UITextView alloc]initWithFrame:contentTextViewRect];
    [contentTextView setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [contentTextView setBackgroundColor:[UIColor clearColor]];
    [contentTextView setText:_type == 2 ? [_detailDic objectForKey:@"content"] : [_detailDic objectForKey:@"MessageContent"]];
    [contentTextView setEditable:NO];
    [self.view addSubview:contentTextView];
    [contentTextView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_type == 2) {
        [self updateReadStatus];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBack:(id)sender {
    [self.xfTabBarController setTabBarHidden:_originalTabBarState];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if ([_delegate respondsToSelector:@selector(updateIsReadedStatus:)]) {
        [_delegate updateIsReadedStatus:YES];
    }
}

#pragma mark -Customized: Private (General)
- (void)updateReadStatus {
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    if ([_detailDic objectForKey:@"Id"]) {
        [infoDic setObject:[_detailDic objectForKey:@"Id"] forKey:@"ID"];
    }
    [infoDic setObject:@"0" forKey:@"operateType"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetMessageCenterDetail userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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
