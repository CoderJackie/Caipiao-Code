//
//  PayOutViewController.m 个人中心－提款申请
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140825 16:40（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//20140825 16:54（洪晓彬）：进行ipad适配
//20150710 10:20（刘科）：新增提现彩金功能

#import "PayOutViewController.h"
#import "SafeProblemPopView.h"
#import "WithdrawalTypePopView.h"
#import "UserInfo.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "XmlParser.h"


#define kPopViewSize (IS_PHONE ? CGSizeMake(300,230) : CGSizeMake(500,430))
#define kPopViewSize1 (IS_PHONE ? CGSizeMake(300,80) : CGSizeMake(500,125))

@interface PayOutViewController ()<SelectWithdrawalTypeViewDelegate>{
    NSDictionary *_cardDic;
}

@end
#pragma mark -
#pragma mark @implementation PayOutViewController
@implementation PayOutViewController
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithDic:(NSDictionary *)cardDic {
    self = [super init];
    if (self) {
        [self setTitle:@"提款"];
        _withdrawalsing = NO;
        _selectIndex1 = 0;
        _cardDic = [cardDic retain];
    }
    return self;
}

- (void)dealloc {
    _bankNameLabel = nil;
    _openAccountAddressLabel = nil;
    _openAccountFullNameLabel = nil;
    _bankCardNumberLabel = nil;
    _payeeNameLabel = nil;
    
    _payoutCountTextField = nil;
    _safeProblemTextField = nil;
    _answerTextField = nil;
    
    [_questionDict release];
    _questionDict = nil;
    
    [_cardDic release];
    _cardDic = nil;
    
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
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstLabelMinY = IS_PHONE ? 20.0f : 25.0f;//第一个label的高度
    
    CGFloat allLeftLabelMinX = IS_PHONE ? 20.0f : 30.0f;//左边label的x
    CGFloat allLeftLabelWidth = IS_PHONE ? 70.0f : 120.0f;//左边label的宽度
    CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;//所有label的高
    
    CGFloat firstLabelVerticalInterval = IS_PHONE ? 3.0f : 10.0f;//前5个左边label之间的垂直间距
    /********************** adjustment end ***************************/
    
    //bankNamePromptLabel 银行名称－提示文字
    NSString *bankNamePrompt = @"银行名称：";
    CGSize bankNamePromptSize = [Globals defaultSizeWithString:bankNamePrompt fontSize:XFIponeIpadFontSize12];
    CGRect bankNamePromptLabelRect = CGRectMake(allLeftLabelMinX, firstLabelMinY, bankNamePromptSize.width, allLabelHeight);
    UILabel *bankNamePromptLabel = [[UILabel alloc] initWithFrame:bankNamePromptLabelRect];
    [bankNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [bankNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [bankNamePromptLabel setText:bankNamePrompt];
    [bankNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [bankNamePromptLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:bankNamePromptLabel];
    [bankNamePromptLabel release];
    
    //bankNameLabel 银行名称
    CGRect bankNameLabelRect = CGRectMake(CGRectGetMaxX(bankNamePromptLabelRect), CGRectGetMinY(bankNamePromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(bankNamePromptLabelRect) - allLeftLabelMinX, allLabelHeight);
    _bankNameLabel = [[UILabel alloc] initWithFrame:bankNameLabelRect];
    [_bankNameLabel setBackgroundColor:[UIColor clearColor]];
    [_bankNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_bankNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [self.view addSubview:_bankNameLabel];
    [_bankNameLabel release];
    
    //openAccountAddressPromptLabel 开户地点－提示文字
//    NSString *openAccountAddressPrompt = @"开户地点：";
//    CGSize openAccountAddressPromptSize = [Globals defaultSizeWithString:openAccountAddressPrompt fontSize:XFIponeIpadFontSize12];
//    CGRect openAccountAddressPromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMaxY(bankNamePromptLabelRect) + firstLabelVerticalInterval, openAccountAddressPromptSize.width, allLabelHeight);
//    UILabel *openAccountAddressPromptLabel = [[UILabel alloc] initWithFrame:openAccountAddressPromptLabelRect];
//    [openAccountAddressPromptLabel setBackgroundColor:[UIColor clearColor]];
//    [openAccountAddressPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [openAccountAddressPromptLabel setText:openAccountAddressPrompt];
//    [openAccountAddressPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//    [openAccountAddressPromptLabel setTextAlignment:NSTextAlignmentRight];
//    [self.view addSubview:openAccountAddressPromptLabel];
//    [openAccountAddressPromptLabel release];
//
//    //openAccountAddressLabel 开户地点
//    CGRect openAccountAddressLabelRect = CGRectMake(CGRectGetMaxX(openAccountAddressPromptLabelRect), CGRectGetMinY(openAccountAddressPromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
//    _openAccountAddressLabel = [[UILabel alloc] initWithFrame:openAccountAddressLabelRect];
//    [_openAccountAddressLabel setBackgroundColor:[UIColor clearColor]];
//    [_openAccountAddressLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [_openAccountAddressLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//    [self.view addSubview:_openAccountAddressLabel];
//    [_openAccountAddressLabel release];
//    
//    //openAccountFullNamePromptLabel 开户行全称－提示文字
//    NSString *openAccountFullNamePrompt = @"开户行：";
//    CGSize openAccountFullNamePromptSize = [Globals defaultSizeWithString:openAccountFullNamePrompt fontSize:XFIponeIpadFontSize12];
//    CGRect openAccountFullNamePromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMaxY(openAccountAddressPromptLabelRect) + firstLabelVerticalInterval, openAccountFullNamePromptSize.width, allLabelHeight);
//    UILabel *openAccountFullNamePromptLabel = [[UILabel alloc] initWithFrame:openAccountFullNamePromptLabelRect];
//    [openAccountFullNamePromptLabel setBackgroundColor:[UIColor clearColor]];
//    [openAccountFullNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [openAccountFullNamePromptLabel setText:openAccountFullNamePrompt];
//    [openAccountFullNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//    [openAccountFullNamePromptLabel setTextAlignment:NSTextAlignmentRight];
//    [self.view addSubview:openAccountFullNamePromptLabel];
//    [openAccountFullNamePromptLabel release];
    
    //openAccountFullNameLabel 开户行全称
//    CGRect openAccountFullNameLabelRect = CGRectMake(CGRectGetMaxX(openAccountFullNamePromptLabelRect), CGRectGetMinY(openAccountFullNamePromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
//    _openAccountFullNameLabel = [[UILabel alloc] initWithFrame:openAccountFullNameLabelRect];
//    [_openAccountFullNameLabel setBackgroundColor:[UIColor clearColor]];
//    [_openAccountFullNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [_openAccountFullNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//    [self.view addSubview:_openAccountFullNameLabel];
//    [_openAccountFullNameLabel release];
    
    //bankCardNumberPromptLabel 银行卡号－提示文字
    NSString *bankCardNumberPrompt = @"银行卡号：";
    CGSize bankCardNumberPromptSize = [Globals defaultSizeWithString:bankCardNumberPrompt fontSize:XFIponeIpadFontSize12];
//    CGRect bankCardNumberPromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMaxY(openAccountFullNamePromptLabelRect) + firstLabelVerticalInterval, bankCardNumberPromptSize.width, allLabelHeight);
    CGRect bankCardNumberPromptLabelRect =  CGRectMake(allLeftLabelMinX, CGRectGetMaxY(bankNamePromptLabelRect) + firstLabelVerticalInterval, bankCardNumberPromptSize.width, allLabelHeight);
    UILabel *bankCardNumberPromptLabel = [[UILabel alloc] initWithFrame:bankCardNumberPromptLabelRect];
    [bankCardNumberPromptLabel setBackgroundColor:[UIColor clearColor]];
    [bankCardNumberPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [bankCardNumberPromptLabel setText:bankCardNumberPrompt];
    [bankCardNumberPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [bankCardNumberPromptLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:bankCardNumberPromptLabel];
    [bankCardNumberPromptLabel release];
    
    //bankCardNumberLabel 银行卡号
    CGRect bankCardNumberLabelRect = CGRectMake(CGRectGetMaxX(bankCardNumberPromptLabelRect), CGRectGetMinY(bankCardNumberPromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
    _bankCardNumberLabel = [[UILabel alloc] initWithFrame:bankCardNumberLabelRect];
    [_bankCardNumberLabel setBackgroundColor:[UIColor clearColor]];
    [_bankCardNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_bankCardNumberLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [self.view addSubview:_bankCardNumberLabel];
    [_bankCardNumberLabel release];
    
    //payeeNamePromptLabel 收款人－提示文字
    NSString *payeeNamePrompt = @"收款人：";
    CGSize payeeNamePromptSize = [Globals defaultSizeWithString:payeeNamePrompt fontSize:XFIponeIpadFontSize12];
    CGRect payeeNamePromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMaxY(bankCardNumberPromptLabelRect) + firstLabelVerticalInterval, payeeNamePromptSize.width, allLabelHeight);
    UILabel *payeeNamePromptLabel = [[UILabel alloc] initWithFrame:payeeNamePromptLabelRect];
    [payeeNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [payeeNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [payeeNamePromptLabel setText:payeeNamePrompt];
    [payeeNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [payeeNamePromptLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:payeeNamePromptLabel];
    [payeeNamePromptLabel release];
    
    //payeeNameLabel 收款人
    CGRect payeeNameLabelRect = CGRectMake(CGRectGetMaxX(payeeNamePromptLabelRect), CGRectGetMinY(payeeNamePromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
    _payeeNameLabel = [[UILabel alloc] initWithFrame:payeeNameLabelRect];
    [_payeeNameLabel setBackgroundColor:[UIColor clearColor]];
    [_payeeNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_payeeNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [self.view addSubview:_payeeNameLabel];
    [_payeeNameLabel release];
    
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat lineAddY = IS_PHONE ? 15.0f : 25.0f;
    CGFloat lineHeight = IS_PHONE ? 2.0f : 4.0f;
    
    CGFloat firstBackImageViewHeight = IS_PHONE ? 26.0f : 70.0f;
    CGFloat secondThreeBackImagaViewHeight = IS_PHONE ? 26 : 42.0f;
    
    CGFloat backImageVerticalInterval = IS_PHONE ? 12.0f : 18.0f;
    
    CGFloat firstTextFieldAddX = 10.0f;
    CGFloat secondTextFieldAddX = 5.0f;
    
    CGFloat angleButtonHeight = IS_PHONE ? 27.5f : 42.0f;
    
    
    CGFloat buttonAddY = IS_PHONE ? 21.0f : 30.0f;  //确认button跟imageview的距离
    CGFloat buttonHeight = IS_PHONE ? 40.0 : 60.0f; //确认button的高度
    
    CGFloat backImageViewWidth = self.view.frame.size.width - 120 - angleButtonHeight;
    CGFloat confirmBtnAndCustomerServiceLabelVerticalInterval = 10.0;
    /********************** adjustment end ***************************/
    
    CGRect blackWhiteLineViewRect = CGRectMake(20, CGRectGetMaxY(payeeNamePromptLabelRect) + lineAddY, self.view.frame.size.width - 40, lineHeight);
    [Globals createBlackWithImageViewWithFrame:blackWhiteLineViewRect inSuperView:self.view];
    
    //firstBackImageView
    CGRect firstBackImageViewRect = CGRectMake(90, CGRectGetMaxY(blackWhiteLineViewRect) + backImageVerticalInterval, backImageViewWidth, secondThreeBackImagaViewHeight);
    UIImageView *firstBackImageView = [[UIImageView alloc] initWithFrame:firstBackImageViewRect];
    [firstBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:firstBackImageView];
    [firstBackImageView release];
    
    //payoutCountPromptLabel 提现金额－提示文字
    CGRect payoutCountPromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMinY(firstBackImageViewRect) + (firstBackImageViewHeight - allLabelHeight) / 2.0f, allLeftLabelWidth, allLabelHeight);
    _payoutCountPromptLabel = [[UILabel alloc] initWithFrame:payoutCountPromptLabelRect];
    [_payoutCountPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_payoutCountPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_payoutCountPromptLabel setText:@"提款金额："];
    [_payoutCountPromptLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:_payoutCountPromptLabel];
    [_payoutCountPromptLabel release];
    
    //payoutCountTextField 提现金额
    CGRect payoutCountTextFieldRect = CGRectMake(90 + firstTextFieldAddX, CGRectGetMinY(firstBackImageViewRect), CGRectGetWidth(firstBackImageViewRect) - firstTextFieldAddX, CGRectGetHeight(firstBackImageViewRect));
    _payoutCountTextField = [[UITextField alloc] initWithFrame:payoutCountTextFieldRect];
    [_payoutCountTextField setBackgroundColor:[UIColor clearColor]];
    [_payoutCountTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_payoutCountTextField setDelegate:self];
    [_payoutCountTextField setPlaceholder:@"提款金额不少于20元"];
    [_payoutCountTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_payoutCountTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_payoutCountTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_payoutCountTextField addTarget:self action:@selector(payoutCountTextFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view addSubview:_payoutCountTextField];
    [_payoutCountTextField release];
    
    //secondBackImageView
    CGRect secondBackImageViewRect = CGRectMake(90, CGRectGetMaxY(firstBackImageViewRect) + backImageVerticalInterval, backImageViewWidth, secondThreeBackImagaViewHeight);
    UIImageView *secondBackImageView = [[UIImageView alloc] initWithFrame:secondBackImageViewRect];
    [secondBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:secondBackImageView];
    [secondBackImageView release];
    
    //safeProblemPromptLabel 安全问题－提示文字
    CGRect safeProblemPromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMinY(secondBackImageViewRect) + (secondThreeBackImagaViewHeight - allLabelHeight) / 2.0f, allLeftLabelWidth, allLabelHeight);
    UILabel *safeProblemPromptLabel = [[UILabel alloc] initWithFrame:safeProblemPromptLabelRect];
    [safeProblemPromptLabel setBackgroundColor:[UIColor clearColor]];
    [safeProblemPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [safeProblemPromptLabel setText:@"安全问题："];
    [safeProblemPromptLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:safeProblemPromptLabel];
    [safeProblemPromptLabel release];
    
    //safeProblemTextField 安全问题
    CGRect safeProblemTextFieldRect = CGRectMake(90 + secondTextFieldAddX, CGRectGetMinY(secondBackImageViewRect), CGRectGetWidth(secondBackImageViewRect) - secondTextFieldAddX, CGRectGetHeight(secondBackImageViewRect));
    _safeProblemTextField = [[UITextField alloc] initWithFrame:safeProblemTextFieldRect];
    [_safeProblemTextField setBackgroundColor:[UIColor clearColor]];
    [_safeProblemTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_safeProblemTextField setText:@"我婆婆或岳母的名字叫什么?"];
    [_safeProblemTextField setEnabled:NO];
    [_safeProblemTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:_safeProblemTextField];
    [_safeProblemTextField release];
    
    //safeProblemBtn 安全问题－选择按钮
//    CGRect safeProblemBtnRect = CGRectMake(CGRectGetMaxX(safeProblemTextFieldRect), CGRectGetMinY(secondBackImageViewRect), angleButtonWidth, angleButtonHeight);
//    UIButton *safeProblemBtn = [[UIButton alloc] initWithFrame:safeProblemBtnRect];
//    [safeProblemBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"angleButton.png"]] forState:UIControlStateNormal];
//    [safeProblemBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"angleButton.png"]] forState:UIControlStateHighlighted];
//    [safeProblemBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
//    [safeProblemBtn addTarget:self action:@selector(selectSafeProblemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside]; //需求要不能修改安全问题，如果需要修改自己去掉注释
//    [self.view addSubview:safeProblemBtn];
//    [safeProblemBtn release];
    
    
    //threeBackImageView
    CGRect threeBackImageViewRect = CGRectMake(90, CGRectGetMaxY(secondBackImageViewRect) + backImageVerticalInterval, backImageViewWidth, secondThreeBackImagaViewHeight);
    UIImageView * threeBackImageView = [[UIImageView alloc] initWithFrame:threeBackImageViewRect];
    [ threeBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview: threeBackImageView];
    [ threeBackImageView release];
    
    //answerPromptLabel 答案－提示文字
    CGRect answerPromptLabelRect = CGRectMake(allLeftLabelMinX, CGRectGetMinY(threeBackImageViewRect) + (secondThreeBackImagaViewHeight - allLabelHeight) / 2.0f, allLeftLabelWidth, allLabelHeight);
    UILabel *answerPromptLabel = [[UILabel alloc] initWithFrame:answerPromptLabelRect];
    [answerPromptLabel setBackgroundColor:[UIColor clearColor]];
    [answerPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [answerPromptLabel setText:@"答案："];
    [answerPromptLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:answerPromptLabel];
    [answerPromptLabel release];
    
    //answerTextField 答案
    CGRect answerTextFieldRect = CGRectMake(90 + secondTextFieldAddX, CGRectGetMinY(threeBackImageViewRect), CGRectGetWidth(threeBackImageViewRect) - secondTextFieldAddX, CGRectGetHeight(threeBackImageViewRect));
    _answerTextField = [[UITextField alloc] initWithFrame:answerTextFieldRect];
    [_answerTextField setBackgroundColor:[UIColor clearColor]];
    [_answerTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_answerTextField setPlaceholder:@"点击输入答案"];
    [_answerTextField setDelegate:self];
    [_answerTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:_answerTextField];
    [_answerTextField release];
    
    //confirmBtn 确定按钮
    CGRect confirmBtnRect = CGRectMake(20, CGRectGetMaxY(answerPromptLabelRect) + buttonAddY, self.view.frame.size.width - 40, buttonHeight);
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:confirmBtnRect];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitle:@"确定" forState:UIControlStateHighlighted];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [confirmBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [confirmBtn addTarget:self action:@selector(submitTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    [confirmBtn release];
    
    //customerServiceLabel
    CGRect customerServiceLabelRect = CGRectMake(0, CGRectGetMaxY(confirmBtnRect) + confirmBtnAndCustomerServiceLabelVerticalInterval, kWinSize.width, allLabelHeight);
    _customerServiceLabel = [[UILabel alloc] initWithFrame:customerServiceLabelRect];
    [_customerServiceLabel setBackgroundColor:[UIColor clearColor]];
    [_customerServiceLabel setTextAlignment:NSTextAlignmentCenter];
    [_customerServiceLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_customerServiceLabel setMinimumScaleFactor:0.75];
    [_customerServiceLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [_customerServiceLabel setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:_customerServiceLabel];
    [_customerServiceLabel release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.xfTabBarController setTabBarHidden:YES];
    _selectIndex = 0;
    XmlParser *xmlParser = [[XmlParser alloc] init];
    _questionDict = [[xmlParser getQuestionDictionary] retain];
    [xmlParser release];
    
    [self loadBankInfo];
    [self customerServiceMessageRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    _controlCanTouch = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && self.view.window) {
        _bankNameLabel = nil;
        _openAccountAddressLabel = nil;
        _openAccountFullNameLabel = nil;
        _bankCardNumberLabel = nil;
        _payeeNameLabel = nil;
        
        _payoutCountTextField = nil;
        _safeProblemTextField = nil;
        _answerTextField = nil;
        
        [_questionDict release];
        _questionDict = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearHTTPRequest];
    [self clearCustomerServiceRequest];
    [self clearLoadBankInfoRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if(responseDic && [[responseDic objectForKey:@"isBinded"] isEqualToString:@"Yes"]) {
        _isHandselDrawing = [[responseDic objectForKey:@"handselDrawing"] integerValue];
        UserInfo.shareUserInfo.balance = [NSString stringWithFormat:@"%@", [responseDic objectForKey:@"balance"]];
        UserInfo.shareUserInfo.handselAmount = [NSString stringWithFormat:@"%@", [responseDic objectForKey:@"userAllowHandsel"]];
//        _payoutCountTextField.placeholder = [NSString stringWithFormat:@"可提款金额%@元", [responseDic objectForKey:@"balance"]];
        _payoutCountTextField.placeholder = [NSString stringWithFormat:@"可提款金额%@元", [responseDic objectForKey:@"cashWithdrawal"]];
        _bankNameLabel.text = [_cardDic objectForKey:@"BankTypeName"];
        
        _openAccountAddressLabel.text = [NSString stringWithFormat:@"%@%@",[_cardDic objectForKey:@"BankInProvinceName"],[_cardDic objectForKey:@"BankInCityName"]];
        _openAccountFullNameLabel.text = [_cardDic objectForKey:@"BankName"];

        NSRange range = NSMakeRange(5, 6);
        NSString *bankCardNumber = [_cardDic objectForKey:@"BankCardNumber"];
        _bankCardNumberLabel.text = [InterfaceHelper replaceString:bankCardNumber InRange:range WithCharacter:@"*"];
        _payeeNameLabel.text = [_cardDic stringForKey:@"BankUserName"];  //  用户真实姓名
        
        NSString *securityquestion = [responseDic stringForKey:@"securityquestion"];
        [_safeProblemTextField setText:securityquestion];
        if (securityquestion) {
            NSArray *questionIndexArray = [_questionDict allKeysForObject:securityquestion];
            if (questionIndexArray && [questionIndexArray count] > 0) {
                _selectIndex = [[questionIndexArray objectAtIndex:0] integerValue] - 1;
            }
        }
        
    } else if (responseDic) {
        [Globals alertWithMessage:@"您的账户尚未绑定银行卡" delegate:self tag:571];
    }
}

- (void)submitFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"提款申请失败"];
    _withdrawalsing = NO;
    _controlCanTouch = YES;
}

//访问结束 的方法调用
- (void)submitFinished:(ASIHTTPRequest *)request {
    _controlCanTouch = YES;
    _withdrawalsing = NO;
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    NSString *msg = [responseDic objectForKey:@"msg"];
    [SVProgressHUD dismiss];
    
    if (responseDic) {
        
        if([msg isEqualToString:@""]) {
            // 加减金额
            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *users = [NSMutableDictionary dictionaryWithDictionary:[userdefaults objectForKey:@"userinfo"]];
            float balance = [[NSString stringWithFormat:@"%.2f",[[users objectForKey:@"balance"] floatValue]] floatValue];
            float freez = [[NSString stringWithFormat:@"%.2f",[[users objectForKey:@"freeze"] floatValue]] floatValue];
            float balanceAfterTikuan = balance - [_payoutCountTextField.text floatValue];
            float freezAfterTikuan = freez + [_payoutCountTextField.text floatValue];
            [users setObject:[NSString stringWithFormat:@"%.2f",balanceAfterTikuan] forKey:@"balance"];
            [users setObject:[NSString stringWithFormat:@"%.2f",freezAfterTikuan] forKey:@"freeze"];
            
            NSLog(@"balance -> %f, %f", balance, balanceAfterTikuan);
            [userdefaults setObject:users forKey:@"userinfo"];
            [userdefaults synchronize];
            
            [[UserInfo shareUserInfo] setBalance:[NSString stringWithFormat:@"%.2f",balanceAfterTikuan]];
            [[UserInfo shareUserInfo] setFreeze:[NSString stringWithFormat:@"%.2f",freezAfterTikuan]];
            
            [Globals alertWithMessage:@"已提交申请" delegate:self tag:572];
        } else {
            [Globals alertWithMessage:msg];
        }
        
    }
}

- (void)customerServiceMessageRequestFinish:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    if(responseDic) {
        NSString *siteName = [responseDic stringForKey:@"SiteName"];
        NSString *phone = [responseDic stringForKey:@"Phone"];
        [_customerServiceLabel setText:[NSString stringWithFormat:@"【%@】客服热线：%@",siteName,phone]];
    }
}

- (void)customerServiceMessageRequestFail:(ASIHTTPRequest *)request {
    
}

#pragma mark -UIAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 571) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == 572){
        [self.navigationController popViewControllerAnimated:NO];
        if (_delegate && [_delegate respondsToSelector:@selector(didPaySucceed)]) {
            [_delegate didPaySucceed];
        }
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _editTextFieldRect = textField.frame;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - SelectSafeProblemViewDelegate
- (void)listViewDidSelectedText:(NSString *)selectText AtRowIndex:(NSInteger)index {
    _safeProblemTextField.text = selectText;
    _selectIndex = index;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController setTabBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    } else if ([textField.text integerValue] > [[UserInfo shareUserInfo].balance integerValue]) {
        [textField setText:[NSString stringWithFormat:@"%ld",(long)[[UserInfo shareUserInfo].balance integerValue]]];
    }
}

- (void)payoutCountTextFieldEditingDidEnd:(id)sender {
    UITextField *textField = sender;
    if (textField.text.length == 0) {
        return;
    }
    if ([textField.text integerValue] < 20) {
        
        [textField setText:@"20"];
        [XYMPromptView defaultShowInfo:@"提款金额不少于20元" isCenter:NO];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//选择安全问题
- (void)selectSafeProblemTouchUpInside:(id)sender {
    [_payoutCountTextField resignFirstResponder];
    [_answerTextField resignFirstResponder];
    CGRect frame = [UIScreen mainScreen].bounds;
    
    SafeProblemPopView *popView = [[SafeProblemPopView alloc]initWithFrame:CGRectMake((frame.size.width - kPopViewSize.width) / 2, (frame.size.height - kPopViewSize.height) / 2, kPopViewSize.width, kPopViewSize.height) SelectIndex:_selectIndex];
    popView.delegate = self;
    [popView show];
}

#pragma mark - 选择提款类型
- (void)selectwithdrawalTypeTouchUpInside:(id)sender {
    CGRect frame = [UIScreen mainScreen].bounds;
    
    WithdrawalTypePopView *popView = [[WithdrawalTypePopView alloc]initWithFrame:CGRectMake((frame.size.width - kPopViewSize1.width) / 2, (frame.size.height - kPopViewSize1.height) / 2, kPopViewSize1.width, kPopViewSize1.height) SelectIndex:_selectIndex1];
    [popView.layer setMasksToBounds:YES];
    [popView.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    popView.delegate = self;
    [popView show];
}

#pragma mark - 提交申请
- (void)submitTouchUpInside:(id)sender {
    [_payoutCountTextField resignFirstResponder];
    [_answerTextField resignFirstResponder];
    if (_withdrawalsing) {
        return;
    }
    if([_safeProblemTextField.text isEqualToString:@""] || [_answerTextField.text isEqualToString:@""]) {
        [XYMPromptView defaultShowInfo:@"亲，请先校验安全问题。" isCenter:NO];
        
        return;
    }
    
    if (_controlCanTouch == NO) {
        return;
    }
    
    _controlCanTouch = NO;
    
    NSString *money = @"";
    if (_payoutCountTextField.text.length == 0) {
        money = @"20";
    } else {
        money = _payoutCountTextField.text;
    }
    _withdrawalsing = YES;
    
    [self clearHTTPRequest];
    [SVProgressHUD showWithStatus:@"加载中"];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:money forKey:@"money"];
//    [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)_selectIndex1] forKey:@"moneyType"];
    [infoDic setObject:@"0" forKey:@"moneyType"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)(_selectIndex + 1)] forKey:@"securityQuestionId"];//服务器问题是从1下标开始的
    [infoDic setObject:_answerTextField.text forKey:@"securityQuestionAnswer"];
    [infoDic setObject:[_cardDic objectForKey:@"BankCardNumber"] forKey:@"bankcardNumber"];
    [infoDic setObject:[_cardDic stringForKey:@"BankTypeName"] forKey:@"bankTypeName"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_DrawMoney userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_httpRequest setDidFailSelector:@selector(submitFailed:)];
    [_httpRequest setDidFinishSelector:@selector(submitFinished:)];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

#pragma mark -Customized: Private (General)
//获取银行信息
- (void)loadBankInfo {
    [self clearLoadBankInfoRequest];
    
    _loadBankInfoRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_BindInformation userId:[UserInfo shareUserInfo].userID infoDict:nil]];
    [_loadBankInfoRequest setDelegate:self];
    [_loadBankInfoRequest startAsynchronous];
}

- (void)clearLoadBankInfoRequest {
    if (_loadBankInfoRequest != nil) {
        [_loadBankInfoRequest clearDelegatesAndCancel];
        [_loadBankInfoRequest release];
        _loadBankInfoRequest = nil;
    }
}

- (void)customerServiceMessageRequest {
    [self clearCustomerServiceRequest];
    
    _customerServiceRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetCustomerServiceMessage userId:[UserInfo shareUserInfo].userID infoDict:nil]];
    [_customerServiceRequest setDelegate:self];
    [_customerServiceRequest setDidFinishSelector:@selector(customerServiceMessageRequestFinish:)];
    [_customerServiceRequest setDidFailSelector:@selector(customerServiceMessageRequestFail:)];
    [_customerServiceRequest startAsynchronous];
}

- (void)clearCustomerServiceRequest {
    if (_customerServiceRequest != nil) {
        [_customerServiceRequest clearDelegatesAndCancel];
        [_customerServiceRequest release];
        _customerServiceRequest = nil;
    }
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

@end
