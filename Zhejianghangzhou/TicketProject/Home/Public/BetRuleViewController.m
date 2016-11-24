//
//  BetRuleViewController.m 购彩大厅－
//  TicketProject
//
//  Created by Michael on 8/31/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//
//20141011 10:44（洪晓彬）：修改代码规范，改进生命周期
//20141011 10:59（洪晓彬）：进行ipad适配

#import "BetRuleViewController.h"
#import "ASIHTTPRequest.h"
#import "Globals.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

#define kAuth @"auth"
#define kOpt @"opt"
#define kInfo @"info"

@interface BetRuleViewController ()

@end

@implementation BetRuleViewController

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"委托投注规则"];
    }
    return self;
}

- (void)dealloc {
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nil;
    _contentView = nil;
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
    UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
    [baseView release];
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(goback:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //contentView
    CGRect contentViewRect = CGRectMake(0, 0, kWinSize.width, self.view.bounds.size.height -44.0f);
    _contentView = [[UIWebView alloc]initWithFrame:contentViewRect];
    [self.view addSubview:_contentView];
    [_contentView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestContentHttpUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if(responseDic && [[responseDic objectForKey:@"msg"] isEqualToString:@""]) {
        
        NSString *str = [responseDic objectForKey:@"investAgreement"];
        
        if([str hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            [_contentView loadRequest:request];
        } else {
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [_contentView loadHTMLString:str baseURL:nil];
        }
    } else if (responseDic){
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)goback:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -Customized: Private (General)
- (void)requestContentHttpUrl {
    [self clearHTTPRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetEntrustBuyRule userId:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID infoDict:nil]];
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
