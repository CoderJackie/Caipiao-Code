//
//  RegisteSucceedViewController.m  个人中心－注册成功
//  TicketProject
//
//  Created by KAI on 15-1-22.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "RegisteSucceedViewController.h"
#import "AccountInfoViewController.h"
#import "AccountInfoViewController.h"
#import "SelectRechargeTypeViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"

@interface RegisteSucceedViewController ()

@end

#pragma mark -
#pragma mark @implementation RegisteSucceedViewController
@implementation RegisteSucceedViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"注册成功"];
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
    CGFloat paySuccessLogoMinY = IS_PHONE ? 23.0f : 40.0f;
    CGFloat paySuccessLogoWidth = IS_PHONE ? 76.0f : 130.0f;
    CGFloat paySuccessLogoHeight = IS_PHONE ? 75.0f : 128.5f;
    
    CGFloat payMoneyPromptLabelAddY = IS_PHONE ? 20.0f : 40.0f;
    CGFloat payPromptLabelAddY = IS_PHONE ? 17.0f : 20.0f;
    CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    
    CGFloat firstBtnAddY = IS_PHONE ? 30.0f : 40.0f;
    CGFloat otherBtnAddY = IS_PHONE ? 10.0f : 20.0f;
    CGFloat btnWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat btnHeight = IS_PHONE ? 40.0f : 65.0f;
    /********************************************/
    
    //paySuccessLogoImageView
    CGRect paySuccessLogoImageViewRect = CGRectMake((CGRectGetWidth(appRect) - paySuccessLogoWidth) / 2.0f, paySuccessLogoMinY, paySuccessLogoWidth, paySuccessLogoHeight);
    UIImageView *paySuccessLogoImageView = [[UIImageView alloc] initWithFrame:paySuccessLogoImageViewRect];
    [paySuccessLogoImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"paySuccessLogo.png"]]];
    [self.view addSubview:paySuccessLogoImageView];
    [paySuccessLogoImageView release];
    
    //payMoneyPromptLabel
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    CGRect promptLabelRect = CGRectMake(0, CGRectGetMaxY(paySuccessLogoImageViewRect) + payMoneyPromptLabelAddY, CGRectGetWidth(appRect), allLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setText:[NSString stringWithFormat:@"恭喜你注册成功%@",appName]];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.view addSubview:promptLabel];
    [promptLabel release];
    
    //payPromptLabel
    CGRect payPromptLabelRect = CGRectMake(0, CGRectGetMaxY(promptLabelRect) + payPromptLabelAddY, CGRectGetWidth(appRect), allLabelHeight);
    UILabel *payPromptLabel = [[UILabel alloc] initWithFrame:payPromptLabelRect];
    [payPromptLabel setBackgroundColor:[UIColor clearColor]];
    [payPromptLabel setText:@"建议立即完善资料，确保账户安全。"];
    [payPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
    [payPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:payPromptLabel];
    [payPromptLabel release];
    
    //perfectMessageBtn
    CGRect perfectMessageBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(payPromptLabelRect) + firstBtnAddY, btnWidth, btnHeight);
    UIButton *perfectMessageBtn = [[UIButton alloc] initWithFrame:perfectMessageBtnRect];
    [perfectMessageBtn setTitle:@"完善信息" forState:UIControlStateNormal];
    [perfectMessageBtn setTitle:@"完善信息" forState:UIControlStateHighlighted];
    [perfectMessageBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [perfectMessageBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [perfectMessageBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [perfectMessageBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [perfectMessageBtn addTarget:self action:@selector(perfectMessageTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:perfectMessageBtn];
    [perfectMessageBtn release];
    
    //rechargeBtn
    CGRect rechargeBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(perfectMessageBtnRect) + otherBtnAddY, btnWidth, btnHeight);
    UIButton *rechargeBtn = [[UIButton alloc] initWithFrame:rechargeBtnRect];
    [rechargeBtn setTitle:@"我要充值" forState:UIControlStateNormal];
    [rechargeBtn setTitle:@"我要充值" forState:UIControlStateHighlighted];
    [rechargeBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [rechargeBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [rechargeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [rechargeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [rechargeBtn addTarget:self action:@selector(rechargeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rechargeBtn];
    [rechargeBtn release];
    
    //goToBuyBtn
    CGRect goToBuyBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(rechargeBtnRect) + otherBtnAddY, btnWidth, btnHeight);
    UIButton *goToBuyBtn = [[UIButton alloc] initWithFrame:goToBuyBtnRect];
    [goToBuyBtn setTitle:@"我要购彩" forState:UIControlStateNormal];
    [goToBuyBtn setTitle:@"我要购彩" forState:UIControlStateHighlighted];
    [goToBuyBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [goToBuyBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [goToBuyBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [goToBuyBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [goToBuyBtn addTarget:self action:@selector(goToBuyTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goToBuyBtn];
    [goToBuyBtn release];
    
    //neverOperateBtn
    CGRect neverOperateBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(goToBuyBtnRect) + otherBtnAddY, btnWidth, btnHeight);
    UIButton *neverOperateBtn = [[UIButton alloc] initWithFrame:neverOperateBtnRect];
    [neverOperateBtn setTitle:@"暂不完善" forState:UIControlStateNormal];
    [neverOperateBtn setTitle:@"暂不完善" forState:UIControlStateHighlighted];
    [neverOperateBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [neverOperateBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [neverOperateBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [neverOperateBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [neverOperateBtn addTarget:self action:@selector(neverOperateTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:neverOperateBtn];
    [neverOperateBtn release];
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
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -


#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)perfectMessageTouchUpInside:(id)sender {
    AccountInfoViewController *accountInfoViewController = [[AccountInfoViewController alloc] init];
    [self.navigationController pushViewController:accountInfoViewController animated:NO];
    [accountInfoViewController release];
}

- (void)checkDetailTouchUpInside:(id)sender {
    UIViewController *viewController = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:viewController animated:YES];
}

- (void)rechargeTouchUpInside:(id)sender {
    SelectRechargeTypeViewController *selectRechargeTypeViewController = [[SelectRechargeTypeViewController alloc] init];
    [self.navigationController pushViewController:selectRechargeTypeViewController animated:YES];
    [selectRechargeTypeViewController release];
}

- (void)goToBuyTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(){
        [self.xfTabBarController setTabBarHidden:NO];
        [self.xfTabBarController setSelectControllerIndex:1];
    }];
}

- (void)neverOperateTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -Customized: Private (General)

@end
