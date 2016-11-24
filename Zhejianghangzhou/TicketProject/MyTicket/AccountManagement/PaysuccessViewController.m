//
//  PaysuccessViewController.m
//  TicketProject
//
//  Created by 杨宁 on 16/8/20.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "PaysuccessViewController.h"
#import "Globals.h"
@interface PaysuccessViewController ()

@end

@implementation PaysuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"银联支付";
    
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    

    
    NSURL *url = [[NSURL alloc]initWithString:_myurl];
    _Mywebview = [[UIWebView alloc]init];
    _Mywebview.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_Mywebview loadRequest:request];

    [self.view addSubview:_Mywebview];
    

}
- (void)getBackTouchUpInside:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
