//
//  AccountInfoViewController.m 个人中心－账号信息 
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140820 09:15（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//20140820 09:34（洪晓彬）：进行ipad适配

#import "AccountInfoViewController.h"
#import "MSKeyboardScrollView.h"
#import "PayOutViewController.h"
#import "PhoneVerificationViewController.h"
#import "PerfectSucceedViewController.h"
#import "SafeProblemPopView.h"
#import "SelectViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "XmlParser.h"

#define CustomAlertViewSize (IS_PHONE ? CGSizeMake(300.0f, 300.0f) : CGSizeMake(500.0f, 500.0f))//所有选择框的大小

@interface AccountInfoViewController ()
/** 获取个人绑定信息 */
- (void)loadBankInfo;
@end

#pragma mark -
#pragma mark @implementation AccountInfoViewController
@implementation AccountInfoViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"账户信息"];
    }
    return self;
}

- (void)dealloc {
    _userNameTextField = nil;
    _qqTextField = nil;
    _cardNumberTextField = nil;
    
    _bankCardNumberTextField = nil;
    _openAccountAddressLabel = nil;
    _openAccountFullNameTextField = nil;
    _bankNameLabel = nil;
    
    _perfectBtn = nil;
    
    [_bankDict release];
    _bankDict = nil;
    [_selectBankDict release];
    _selectBankDict = nil;
    [_selectProvinceCityDic release];
    _selectProvinceCityDic = nil;
    [_provinceDict release];
    _provinceDict = nil;
    [_cityDict release];
    _cityDict = nil;
    [_selectPlaceDict release];
    _selectPlaceDict = nil;
    [_infoDict release];
    _infoDict = nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
	[baseView release];
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //scrollView
    CGRect scrollViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kNavigationBarHeight);
    _scrollView = [[MSKeyboardScrollView alloc]initWithFrame:scrollViewRect];
    [_scrollView setClipsToBounds:YES];
    [_scrollView setUserInteractionEnabled:YES];
    [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect), 760 - 140)];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat sectionPromptLabelMinY = IS_PHONE ? 3.0f : 6.0f;
    CGFloat sectionPromptLabelHeight = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat imageViewMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat imageViewMinY = IS_PHONE ? 12.0f : 18.0f;
    CGFloat imageViewSize = IS_PHONE ? 21.0f : 30.0f;
    
    CGFloat allLeftLabelImageViewAddX = IS_PHONE ? 6.0f : 20.0f;//左边的提示label的x坐标
    CGFloat allLeftLabelWidth = IS_PHONE ? 64.0f : 100.0f;//左边label的宽度
    CGFloat allLabelHeight = imageViewSize;//所有label的高度
    
    CGFloat backImageViewMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat backImageViewWidth = CGRectGetWidth(appRect) - backImageViewMinX * 2;
    CGFloat backImageViewLineHeight = allLabelHeight + imageViewMinY * 2;
    
    CGFloat buttonWidth = IS_PHONE ? 300.0f : 600.0f;//完善按钮的宽度
    CGFloat buttonHeight = IS_PHONE ? 40.0f : 60.0f;//完善按钮的高度
    
    CGFloat partVerticalInterval = 16.0f;//三个部分的间距
    
    CGFloat leftSignImageViewMaginRightX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat leftSignImageViewWidth = IS_PHONE ? 15.0f : 22.5f;
    CGFloat leftSignImageViewHeight = IS_PHONE ? 14.0f : 21.0f;
    
    CGFloat angleButtonWidth = IS_PHONE ? 25.5f : 39.5f;
    CGFloat angleButtonHeight = IS_PHONE ? 27.5 : 42.0f;
    
    CGFloat customerServiceLabelHeight = IS_PHONE ? 160.0f : 220.0f;
    /********************** adjustment end ***************************/
    
    //firstPartPromptLabel
    CGRect firstPartPromptLabelRect = CGRectMake(backImageViewMinX, sectionPromptLabelMinY, backImageViewWidth, sectionPromptLabelHeight);
    UILabel *firstPartPromptLabel = [[UILabel alloc] initWithFrame:firstPartPromptLabelRect];
    [firstPartPromptLabel setBackgroundColor:[UIColor clearColor]];
    [firstPartPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [firstPartPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [firstPartPromptLabel setText:@"账户信息"];
    [_scrollView addSubview:firstPartPromptLabel];
    [firstPartPromptLabel release];
    
    //firstBackImageView
    CGRect firstBackImageViewRect = CGRectMake(backImageViewMinX, CGRectGetMaxY(firstPartPromptLabelRect), backImageViewWidth, backImageViewLineHeight * 3 + AllLineWidthOrHeight * 3);
    UIImageView *firstBackImageView = [[UIImageView alloc] initWithFrame:firstBackImageViewRect];
    [firstBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [firstBackImageView setUserInteractionEnabled:YES];
    [_scrollView addSubview:firstBackImageView];
    [firstBackImageView release];
    
    /*************************************************/
    
    //phoneImageView
    CGRect phoneImageViewRect = CGRectMake(imageViewMinX, imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *phoneImageView = [[UIImageView alloc] initWithFrame:phoneImageViewRect];
    [phoneImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountPhone.png"]]];
    [firstBackImageView addSubview:phoneImageView];
    [phoneImageView release];
    
    //phonePromptLabel 手机号码－提示文字
    CGRect phonePromptLabelRect = CGRectMake(CGRectGetMaxX(phoneImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(phoneImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *phonePromptLabel = [[UILabel alloc] initWithFrame:phonePromptLabelRect];
    [phonePromptLabel setBackgroundColor:[UIColor clearColor]];
    [phonePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [phonePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [phonePromptLabel setText:@"手机号码"];
    [firstBackImageView addSubview:phonePromptLabel];
    [phonePromptLabel release];
    
    //phoneCaptchaBtn 手机号码
    CGRect phoneCaptchaBtnRect = CGRectMake(CGRectGetMinX(phonePromptLabelRect), 0, CGRectGetWidth(appRect) - CGRectGetMinX(phonePromptLabelRect) - CGRectGetMinX(phonePromptLabelRect), backImageViewLineHeight);
    _phoneCaptchaBtn = [[UIButton alloc] initWithFrame:phoneCaptchaBtnRect];
    [_phoneCaptchaBtn setBackgroundColor:[UIColor clearColor]];
    [_phoneCaptchaBtn setTitleColor:[UIColor colorWithRed:194.0f/255.0f green:194.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//    [_phoneCaptchaBtn setTitle:@"点击绑定关联手机号码" forState:UIControlStateNormal];
    [[_phoneCaptchaBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_phoneCaptchaBtn setAdjustsImageWhenHighlighted:NO];
    
    [_phoneCaptchaBtn addTarget:self action:@selector(phoneCaptchaTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [firstBackImageView addSubview:_phoneCaptchaBtn];
    [_phoneCaptchaBtn release];
    
    //phoneCaptchaLeftSignImageView 电话号码进入提示
    CGRect phoneCaptchaLeftSignImageViewRect = CGRectMake(CGRectGetWidth(firstBackImageViewRect) - leftSignImageViewWidth - leftSignImageViewMaginRightX, (backImageViewLineHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
    _phoneCaptchaLeftSignImageView = [[UIImageView alloc] initWithFrame:phoneCaptchaLeftSignImageViewRect];
    [_phoneCaptchaLeftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
    [firstBackImageView addSubview:_phoneCaptchaLeftSignImageView];
    [_phoneCaptchaLeftSignImageView release];
    
    //phoneLabel 手机号码
    CGRect phoneLabelRect = CGRectMake(CGRectGetMaxX(phonePromptLabelRect), CGRectGetMinY(phonePromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(phonePromptLabelRect) - CGRectGetMinX(phonePromptLabelRect), allLabelHeight);
    _phoneLabel = [[UILabel alloc] initWithFrame:phoneLabelRect];
    [_phoneLabel setBackgroundColor:[UIColor clearColor]];
    [_phoneLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [_phoneLabel setText:@"15920112233"];//测试用
    [firstBackImageView addSubview:_phoneLabel];
    [_phoneLabel release];
    
    CGRect firstViewLine1Rect = CGRectMake(0, CGRectGetMaxY(phonePromptLabelRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:firstViewLine1Rect inSuperView:firstBackImageView];
    
    /*************************************************/
    
    //userNameImageView
    CGRect userNameImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(firstViewLine1Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *userNameImageView = [[UIImageView alloc] initWithFrame:userNameImageViewRect];
    [userNameImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountName.png"]]];
    [firstBackImageView addSubview:userNameImageView];
    [userNameImageView release];
    
    //userNamePromptLabel 用户名－提示文字
    CGRect userNamePromptLabelRect = CGRectMake(CGRectGetMaxX(userNameImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(userNameImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *userNamePromptLabel = [[UILabel alloc] initWithFrame:userNamePromptLabelRect];
    [userNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [userNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [userNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [userNamePromptLabel setText:@"用户名"];
    [firstBackImageView addSubview:userNamePromptLabel];
    [userNamePromptLabel release];
    
    //userNameTextField 用户名
    CGRect userNameTextFieldRect = CGRectMake(CGRectGetMaxX(userNamePromptLabelRect), CGRectGetMinY(userNamePromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(userNamePromptLabelRect) - CGRectGetMinX(userNamePromptLabelRect), allLabelHeight);
    _userNameTextField = [[UITextField alloc] initWithFrame:userNameTextFieldRect];
    [_userNameTextField setBackgroundColor:[UIColor clearColor]];
    [_userNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_userNameTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_userNameTextField setAdjustsFontSizeToFitWidth:YES];
    [_userNameTextField setEnabled:NO];
    [_userNameTextField setPlaceholder:@"请输入用户名"];
    [firstBackImageView addSubview:_userNameTextField];
    [_userNameTextField release];
    
    CGRect firstViewLine2Rect = CGRectMake(0, CGRectGetMaxY(userNamePromptLabelRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:firstViewLine2Rect inSuperView:firstBackImageView];
    
    /*************************************************/
    
    //qqImageView
    CGRect qqImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(firstViewLine2Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *qqImageView = [[UIImageView alloc] initWithFrame:qqImageViewRect];
    [qqImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountName.png"]]];
    [firstBackImageView addSubview:qqImageView];
    [qqImageView release];
    
    //qqPromptLabel qq－提示文字
    CGRect qqPromptLabelRect = CGRectMake(CGRectGetMaxX(qqImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(qqImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *qqPromptLabel = [[UILabel alloc] initWithFrame:qqPromptLabelRect];
    [qqPromptLabel setBackgroundColor:[UIColor clearColor]];
    [qqPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [qqPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [qqPromptLabel setText:@"QQ"];
    [firstBackImageView addSubview:qqPromptLabel];
    [qqPromptLabel release];
    
    //qqTextFieldRect qq
    CGRect qqTextFieldRect = CGRectMake(CGRectGetMaxX(qqPromptLabelRect), CGRectGetMinY(qqPromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(qqPromptLabelRect) - CGRectGetMinX(qqPromptLabelRect), allLabelHeight);
    _qqTextField = [[UITextField alloc] initWithFrame:qqTextFieldRect];
    [_qqTextField setBackgroundColor:[UIColor clearColor]];
    [_qqTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_qqTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_qqTextField setAdjustsFontSizeToFitWidth:YES];
    [_qqTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_qqTextField setPlaceholder:@"(选填)"];
    [firstBackImageView addSubview:_qqTextField];
    [_qqTextField release];
    
    
    /*************************************************/
    
    //secondPartPromptLabel
    CGRect secondPartPromptLabelRect = CGRectMake(backImageViewMinX, CGRectGetMaxY(firstBackImageViewRect) + sectionPromptLabelMinY, backImageViewWidth, sectionPromptLabelHeight);
    UILabel *secondPartPromptLabel = [[UILabel alloc] initWithFrame:secondPartPromptLabelRect];
    [secondPartPromptLabel setBackgroundColor:[UIColor clearColor]];
    [secondPartPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [secondPartPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [secondPartPromptLabel setText:@"个人资料"];
    [_scrollView addSubview:secondPartPromptLabel];
    [secondPartPromptLabel release];
    
    //secondBackImageView
    CGRect secondBackImageViewRect = CGRectMake(backImageViewMinX, CGRectGetMaxY(secondPartPromptLabelRect), backImageViewWidth, backImageViewLineHeight * 8 + AllLineWidthOrHeight * 7);
    _secondBackImageView = [[UIImageView alloc] initWithFrame:secondBackImageViewRect];
    [_secondBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [_secondBackImageView setClipsToBounds:YES];
    [_secondBackImageView setUserInteractionEnabled:YES];
    [_scrollView addSubview:_secondBackImageView];
    [_secondBackImageView release];
    
    /*************************************************/
    
    //realNameImageView
    CGRect realNameImageViewRect = CGRectMake(imageViewMinX, imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *realNameImageView = [[UIImageView alloc] initWithFrame:realNameImageViewRect];
    [realNameImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountName.png"]]];
    [_secondBackImageView addSubview:realNameImageView];
    [realNameImageView release];
    
    //realNamePromptLabel 真实姓名－提示文字
    CGRect realNamePromptLabelRect = CGRectMake(CGRectGetMaxX(realNameImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(realNameImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *realNamePromptLabel = [[UILabel alloc] initWithFrame:realNamePromptLabelRect];
    [realNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [realNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [realNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [realNamePromptLabel setText:@"真实姓名"];
    [_secondBackImageView addSubview:realNamePromptLabel];
    [realNamePromptLabel release];

    //realNameTextField 真实姓名
    CGRect realNameTextFieldRect = CGRectMake(CGRectGetMaxX(realNamePromptLabelRect), CGRectGetMinY(realNamePromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(realNamePromptLabelRect) - CGRectGetMinX(realNamePromptLabelRect), allLabelHeight);
    _realNameTextField = [[UITextField alloc] initWithFrame:realNameTextFieldRect];
    [_realNameTextField setBackgroundColor:[UIColor clearColor]];
    [_realNameTextField setPlaceholder:@"请输入真实姓名"];
    [_realNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_realNameTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_realNameTextField setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_realNameTextField];
    [_realNameTextField release];
    
    CGRect secondViewLine1Rect = CGRectMake(0, CGRectGetMaxY(realNameImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine1Rect inSuperView:_secondBackImageView];
    
    /*************************************************/
    //cardNumberImageView
    CGRect cardNumberImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine1Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *cardNumberImageView = [[UIImageView alloc] initWithFrame:cardNumberImageViewRect];
    [cardNumberImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountID.png"]]];
    [_secondBackImageView addSubview:cardNumberImageView];
    [cardNumberImageView release];
    
    //cardNumberPromptLabel 身份证号－提示文字
    CGRect cardNumberPromptLabelRect = CGRectMake(CGRectGetMaxX(cardNumberImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(cardNumberImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *cardNumberPromptLabel = [[UILabel alloc] initWithFrame:cardNumberPromptLabelRect];
    [cardNumberPromptLabel setBackgroundColor:[UIColor clearColor]];
    [cardNumberPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [cardNumberPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [cardNumberPromptLabel setText:@"身份证号"];
    [_secondBackImageView addSubview:cardNumberPromptLabel];
    [cardNumberPromptLabel release];
    
    //cardNumberTextField 身份证号
    CGRect cardNumberTextFieldRect = CGRectMake(CGRectGetMinX(realNameTextFieldRect), CGRectGetMinY(cardNumberPromptLabelRect), CGRectGetWidth(realNameTextFieldRect), allLabelHeight);
    _cardNumberTextField = [[UITextField alloc] initWithFrame:cardNumberTextFieldRect];
    [_cardNumberTextField setBackgroundColor:[UIColor clearColor]];
    [_cardNumberTextField setPlaceholder:@"请输入身份证号码"];
    [_cardNumberTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_cardNumberTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_cardNumberTextField setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_cardNumberTextField];
    [_cardNumberTextField release];
    
    CGRect secondViewLine2Rect = CGRectMake(0, CGRectGetMaxY(cardNumberImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine2Rect inSuperView:_secondBackImageView];
    
    /*************************************************/
    
    
   /*
    //myBankInformationBackImageView
    CGRect myBankInformationBackImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine2Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *myBankInformationBackImageView = [[UIImageView alloc] initWithFrame:myBankInformationBackImageViewRect];
    [myBankInformationBackImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountBank.png"]]];
    [_secondBackImageView addSubview:myBankInformationBackImageView];
    [myBankInformationBackImageView release];
    
    //bankNamePromptLabel 银行名称－提示文字
    CGRect bankNamePromptLabelRect = CGRectMake(CGRectGetMaxX(myBankInformationBackImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(myBankInformationBackImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *bankNamePromptLabel = [[UILabel alloc] initWithFrame:bankNamePromptLabelRect];
    [bankNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [bankNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [bankNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [bankNamePromptLabel setText:@"银行名称"];
    [_secondBackImageView addSubview:bankNamePromptLabel];
    [bankNamePromptLabel release];
    
    //bankNameLabel 银行名称
    CGRect bankNameLabelRect = CGRectMake(CGRectGetMinX(cardNumberTextFieldRect), CGRectGetMinY(bankNamePromptLabelRect), CGRectGetWidth(cardNumberTextFieldRect), allLabelHeight);
    _bankNameLabel = [[UILabel alloc] initWithFrame:bankNameLabelRect];
    [_bankNameLabel setBackgroundColor:[UIColor clearColor]];
    [_bankNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_bankNameLabel setMinimumScaleFactor:0.75];
    [_bankNameLabel setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_bankNameLabel];
    [_bankNameLabel release];
    
    //bankNameSelectBtn
    CGRect bankNameSelectBtnRect = CGRectMake(0, CGRectGetMaxY(secondViewLine2Rect), CGRectGetWidth(secondBackImageViewRect), backImageViewLineHeight);
    _bankNameSelectBtn = [[UIButton alloc] initWithFrame:bankNameSelectBtnRect];
    [_bankNameSelectBtn setBackgroundColor:[UIColor clearColor]];
    [_bankNameSelectBtn setTitleColor:[UIColor colorWithRed:194.0f/255.0f green:194.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_bankNameSelectBtn setTitle:@"点击选择银行名称" forState:UIControlStateNormal];
    [[_bankNameSelectBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_bankNameSelectBtn setAdjustsImageWhenHighlighted:NO];
    [_bankNameSelectBtn addTarget:self action:@selector(bankNameSelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBackImageView addSubview:_bankNameSelectBtn];
    [_bankNameSelectBtn release];
    
    //bankNameLeftSignImageView 银行进入提示
    CGRect bankNameLeftSignImageViewRect = CGRectMake(CGRectGetWidth(secondBackImageViewRect) - leftSignImageViewWidth - leftSignImageViewMaginRightX, CGRectGetMaxY(secondViewLine2Rect) + (backImageViewLineHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
    _bankNameLeftSignImageView = [[UIImageView alloc] initWithFrame:bankNameLeftSignImageViewRect];
    [_bankNameLeftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
    [_secondBackImageView addSubview:_bankNameLeftSignImageView];
    [_bankNameLeftSignImageView release];
    
    
    CGRect secondViewLine3Rect = CGRectMake(0, CGRectGetMaxY(myBankInformationBackImageViewRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine3Rect inSuperView:_secondBackImageView];

    */
    /*************************************************/
    
    /*
     //openAccountAddressImageView
     CGRect openAccountAddressImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine3Rect) + imageViewMinY, imageViewSize, imageViewSize);
     UIImageView *openAccountAddressImageView = [[UIImageView alloc] initWithFrame:openAccountAddressImageViewRect];
     [openAccountAddressImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountPlace.png"]]];
     [_secondBackImageView addSubview:openAccountAddressImageView];
     [openAccountAddressImageView release];
     
     //openAccountAddressPromptLabel 开户地点－提示文字
     CGRect openAccountAddressPromptLabelRect = CGRectMake(CGRectGetMaxX(openAccountAddressImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(openAccountAddressImageViewRect), allLeftLabelWidth, allLabelHeight);
     UILabel *openAccountAddressPromptLabel = [[UILabel alloc] initWithFrame:openAccountAddressPromptLabelRect];
     [openAccountAddressPromptLabel setBackgroundColor:[UIColor clearColor]];
     [openAccountAddressPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
     [openAccountAddressPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
     [openAccountAddressPromptLabel setText:@"开户地点"];
     [_secondBackImageView addSubview:openAccountAddressPromptLabel];
     [openAccountAddressPromptLabel release];
     
     //openAccountAddressLabel 开户地点
     CGRect openAccountAddressLabelRect = CGRectMake(CGRectGetMinX(bankNameLabelRect), CGRectGetMinY(openAccountAddressPromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
     _openAccountAddressLabel = [[UILabel alloc] initWithFrame:openAccountAddressLabelRect];
     [_openAccountAddressLabel setBackgroundColor:[UIColor clearColor]];
     [_openAccountAddressLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
     [_openAccountAddressLabel setMinimumScaleFactor:0.75];
     [_openAccountAddressLabel setAdjustsFontSizeToFitWidth:YES];
     [_secondBackImageView addSubview:_openAccountAddressLabel];
     [_openAccountAddressLabel release];
     
     //openAccountAddressBtn
     CGRect openAccountAddressBtnRect = CGRectMake(0, CGRectGetMaxY(secondViewLine3Rect), CGRectGetWidth(secondBackImageViewRect), backImageViewLineHeight);
     _openAccountAddressBtn = [[UIButton alloc] initWithFrame:openAccountAddressBtnRect];
     [_openAccountAddressBtn setBackgroundColor:[UIColor clearColor]];
     [_openAccountAddressBtn setTitleColor:[UIColor colorWithRed:194.0f/255.0f green:194.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
     [_openAccountAddressBtn setTitle:@"点击选择开户地点" forState:UIControlStateNormal];
     [[_openAccountAddressBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
     [_openAccountAddressBtn setAdjustsImageWhenHighlighted:NO];
     [_openAccountAddressBtn addTarget:self action:@selector(openAccountAddressTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
     [_secondBackImageView addSubview:_openAccountAddressBtn];
     [_openAccountAddressBtn release];
     
     //openAccountAddressLeftSignImageView 银行进入提示
     CGRect openAccountAddressLeftSignImageViewRect = CGRectMake(CGRectGetWidth(secondBackImageViewRect) - leftSignImageViewWidth - leftSignImageViewMaginRightX, CGRectGetMaxY(secondViewLine3Rect) + (backImageViewLineHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
     _openAccountAddressLeftSignImageView = [[UIImageView alloc] initWithFrame:openAccountAddressLeftSignImageViewRect];
     [_openAccountAddressLeftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
     [_secondBackImageView addSubview:_openAccountAddressLeftSignImageView];
     [_openAccountAddressLeftSignImageView release];
     
     
     CGRect secondViewLine4Rect = CGRectMake(0, CGRectGetMaxY(openAccountAddressImageViewRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
     [Globals makeLineWithFrame:secondViewLine4Rect inSuperView:_secondBackImageView];
     */
    
    /*************************************************/
    
    /*
     //openAccountFullNameImageView
     CGRect openAccountFullNameImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine4Rect) + imageViewMinY, imageViewSize, imageViewSize);
     UIImageView *openAccountFullNameImageView = [[UIImageView alloc] initWithFrame:openAccountFullNameImageViewRect];
     [openAccountFullNameImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountDetailPlace.png"]]];
     [_secondBackImageView addSubview:openAccountFullNameImageView];
     [openAccountFullNameImageView release];
     
     //openAccountFullNamePromptLabel 开户行全称－提示文字
     CGRect openAccountFullNamePromptLabelRect = CGRectMake(CGRectGetMaxX(openAccountFullNameImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(openAccountFullNameImageViewRect), allLeftLabelWidth, allLabelHeight);
     UILabel *openAccountFullNamePromptLabel = [[UILabel alloc] initWithFrame:openAccountFullNamePromptLabelRect];
     [openAccountFullNamePromptLabel setBackgroundColor:[UIColor clearColor]];
     [openAccountFullNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
     [openAccountFullNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
     [openAccountFullNamePromptLabel setText:@"开户支行"];
     [_secondBackImageView addSubview:openAccountFullNamePromptLabel];
     [openAccountFullNamePromptLabel release];
     
     //openAccountFullNameTextField 开户行全称
     CGRect openAccountFullNameTextFieldRect = CGRectMake(CGRectGetMinX(openAccountAddressLabelRect), CGRectGetMinY(openAccountFullNamePromptLabelRect), CGRectGetWidth(openAccountAddressLabelRect), allLabelHeight);
     _openAccountFullNameTextField = [[UITextField alloc] initWithFrame:openAccountFullNameTextFieldRect];
     [_openAccountFullNameTextField setBackgroundColor:[UIColor clearColor]];
     [_openAccountFullNameTextField setPlaceholder:@"请输入开户支行"];
     [_openAccountFullNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
     [_openAccountFullNameTextField setMinimumFontSize:XFIponeIpadFontSize7];
     [_openAccountFullNameTextField setAdjustsFontSizeToFitWidth:YES];
     [_secondBackImageView addSubview:_openAccountFullNameTextField];
     [_openAccountFullNameTextField release];
     
     CGRect secondViewLine5Rect = CGRectMake(0, CGRectGetMaxY(openAccountFullNameImageViewRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
     [Globals makeLineWithFrame:secondViewLine5Rect inSuperView:_secondBackImageView];

     */
    /*************************************************/
    
    /*
     //bankCardNumberImageView
     CGRect bankCardNumberImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine5Rect) + imageViewMinY, imageViewSize, imageViewSize);
     UIImageView *bankCardNumberImageView = [[UIImageView alloc] initWithFrame:bankCardNumberImageViewRect];
     [bankCardNumberImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountCard.png"]]];
     [_secondBackImageView addSubview:bankCardNumberImageView];
     [bankCardNumberImageView release];
     
     //bankCardNumberPromptLabel 银行卡号－提示文字
     CGRect bankCardNumberPromptLabelRect = CGRectMake(CGRectGetMaxX(bankCardNumberImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(bankCardNumberImageViewRect), allLeftLabelWidth, allLabelHeight);
     UILabel *bankCardNumberPromptLabel = [[UILabel alloc] initWithFrame:bankCardNumberPromptLabelRect];
     [bankCardNumberPromptLabel setBackgroundColor:[UIColor clearColor]];
     [bankCardNumberPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
     [bankCardNumberPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
     [bankCardNumberPromptLabel setText:@"银行卡号"];
     [_secondBackImageView addSubview:bankCardNumberPromptLabel];
     [bankCardNumberPromptLabel release];
     
     //bankCardNumberTextField 银行卡号
     CGRect bankCardNumberTextFieldRect = CGRectMake(CGRectGetMinX(openAccountFullNameTextFieldRect), CGRectGetMinY(bankCardNumberPromptLabelRect), CGRectGetWidth(openAccountFullNameTextFieldRect), allLabelHeight);
     _bankCardNumberTextField = [[UITextField alloc] initWithFrame:bankCardNumberTextFieldRect];
     [_bankCardNumberTextField setBackgroundColor:[UIColor clearColor]];
     [_bankCardNumberTextField setPlaceholder:@"请输入银行卡号"];
     [_bankCardNumberTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
     [_bankCardNumberTextField setMinimumFontSize:XFIponeIpadFontSize7];
     [_bankCardNumberTextField setAdjustsFontSizeToFitWidth:YES];
     [_secondBackImageView addSubview:_bankCardNumberTextField];
     [_bankCardNumberTextField release];
     
     CGRect secondViewLine6Rect = CGRectMake(0, CGRectGetMaxY(bankCardNumberImageViewRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
     [Globals makeLineWithFrame:secondViewLine6Rect inSuperView:_secondBackImageView];
     */
    
    /*************************************************/
    
    //saftProblemImageView
    CGRect saftProblemImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine2Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *saftProblemImageView = [[UIImageView alloc] initWithFrame:saftProblemImageViewRect];
    [saftProblemImageView setTag:2010];
    [_secondBackImageView addSubview:saftProblemImageView];
    [saftProblemImageView release];
    
    //saftProblemPromptLabel 安全问题－提示文字
    CGRect saftProblemPromptLabelRect = CGRectMake(CGRectGetMaxX(saftProblemImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(saftProblemImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *saftProblemPromptLabel = [[UILabel alloc] initWithFrame:saftProblemPromptLabelRect];
    [saftProblemPromptLabel setBackgroundColor:[UIColor clearColor]];
    [saftProblemPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [saftProblemPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [saftProblemPromptLabel setText:@"安全问题"];
    [saftProblemPromptLabel setTag:2011];
    [_secondBackImageView addSubview:saftProblemPromptLabel];
    [saftProblemPromptLabel release];
    
    //saftProblemTextField
    CGRect saftProblemTextFieldRect = CGRectMake(CGRectGetMinX(cardNumberTextFieldRect), CGRectGetMinY(saftProblemPromptLabelRect), CGRectGetWidth(cardNumberTextFieldRect) - angleButtonWidth, angleButtonHeight);
    _saftProblemTextField = [[UITextField alloc] initWithFrame:saftProblemTextFieldRect];
    [_saftProblemTextField setBackgroundColor:[UIColor clearColor]];
    [_saftProblemTextField setPlaceholder:@"点击选择安全问题"];
    [_saftProblemTextField setTag:2012];
    [_saftProblemTextField.layer setBorderWidth:1.0];
    [_saftProblemTextField.layer setBorderColor:[UIColor colorWithRed:0xef/255.0f green:0xef/255.0f blue:0xef/255.0f alpha:1.0f].CGColor];
    [_saftProblemTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_saftProblemTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_saftProblemTextField setAdjustsFontSizeToFitWidth:YES];
    [_saftProblemTextField setEnabled:NO];
    [_secondBackImageView addSubview:_saftProblemTextField];
    [_saftProblemTextField release];
    
    //selectBtn
    CGRect selectBtnRect = CGRectMake(CGRectGetMaxX(saftProblemTextFieldRect), CGRectGetMinY(saftProblemTextFieldRect), angleButtonWidth, angleButtonHeight);
    UIButton *selectBtn = [[UIButton alloc] initWithFrame:selectBtnRect];
    [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"angleButton.png"]] forState:UIControlStateNormal];
    [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"angleButton.png"]] forState:UIControlStateHighlighted];
    [selectBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
    [selectBtn addTarget:self action:@selector(selectSafeProblemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtn setTag:2013];
    [_secondBackImageView addSubview:selectBtn];
    [selectBtn release];
    
    CGRect secondViewLine7Rect = CGRectMake(0, CGRectGetMaxY(saftProblemImageViewRect) + imageViewMinY, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine7Rect inSuperView:_secondBackImageView];
    
    /*************************************************/
    //answerImageView
    CGRect answerImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine7Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *answerImageView = [[UIImageView alloc] initWithFrame:answerImageViewRect];
    [answerImageView setTag:2014];
    [_secondBackImageView addSubview:answerImageView];
    [answerImageView release];
    
    //answerPromptLabel 安全问题－提示文字
    CGRect answerPromptLabelRect = CGRectMake(CGRectGetMaxX(answerImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(answerImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *answerPromptLabel = [[UILabel alloc] initWithFrame:answerPromptLabelRect];
    [answerPromptLabel setBackgroundColor:[UIColor clearColor]];
    [answerPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [answerPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [answerPromptLabel setText:@"答案"];
    [answerPromptLabel setTag:2015];
    [_secondBackImageView addSubview:answerPromptLabel];
    [answerPromptLabel release];
    
    //answerTextField 银行卡号
    CGRect answerTextFieldRect = CGRectMake(CGRectGetMinX(cardNumberTextFieldRect), CGRectGetMinY(answerPromptLabelRect), CGRectGetWidth(cardNumberTextFieldRect), allLabelHeight);
    _answerTextField = [[UITextField alloc] initWithFrame:answerTextFieldRect];
    [_answerTextField setBackgroundColor:[UIColor clearColor]];
    [_answerTextField setPlaceholder:@"请输入答案"];
    [_answerTextField setTag:2016];
    [_answerTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_answerTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_answerTextField setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_answerTextField];
    [_answerTextField release];
    
    //设置背景高度
    secondBackImageViewRect.size.height = CGRectGetMaxY(answerImageViewRect) + imageViewMinY + AllLineWidthOrHeight;
    [_secondBackImageView setFrame:secondBackImageViewRect];
    
    /*************************************************/
    
    //perfectBtn 完善信息按钮
    CGRect perfectBtnRect = CGRectMake((CGRectGetWidth(appRect) - buttonWidth) / 2, CGRectGetMaxY(secondBackImageViewRect) + partVerticalInterval, buttonWidth, buttonHeight);
    _perfectBtn = [[UIButton alloc] initWithFrame:perfectBtnRect];
    [_perfectBtn setTitle:@"完善信息" forState:UIControlStateNormal];
    [_perfectBtn setTitle:@"完善信息" forState:UIControlStateHighlighted];
    [_perfectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_perfectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_perfectBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [_perfectBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [_perfectBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [_perfectBtn addTarget:self action:@selector(perfectInfoTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_perfectBtn setHidden:YES];
    [_scrollView addSubview:_perfectBtn];
    [_perfectBtn release];
    
    //customerServiceLabel
    CGRect customerServiceLabelRect = CGRectMake(backImageViewMinX, CGRectGetMaxY(perfectBtnRect), backImageViewWidth, customerServiceLabelHeight);
    _customerServiceLabel = [[UILabel alloc] initWithFrame:customerServiceLabelRect];
    [_customerServiceLabel setBackgroundColor:[UIColor clearColor]];
    [_customerServiceLabel setTextAlignment:NSTextAlignmentLeft];
    [_customerServiceLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_customerServiceLabel setMinimumScaleFactor:0.75];
    [_customerServiceLabel setNumberOfLines:10];
    [_customerServiceLabel setTextColor:tRedColor];
    [_customerServiceLabel setAdjustsFontSizeToFitWidth:YES];
    [_customerServiceLabel setText:@"温馨提示：\n1、用户名以及手机号码是你登录的唯一凭证。\n2、真实姓名须同银行卡户名一致，身份证号码须同银行卡户主身份一致。\n3、请放心填写真实的个人资料，我们会对你的身份信息进行严格保密。\n4、以上资料仅用于提款到银行卡，请真实填写否则无法完成提款。\n5、以上信息一经填写不能轻易修改，请确保填写准确\n\n"];
    [_scrollView addSubview:_customerServiceLabel];
    [_customerServiceLabel release];
    
    //给背景添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGesture.cancelsTouchesInView = NO;
    [_scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XmlParser *parser1 = [[XmlParser alloc]init];
    _bankDict = [[parser1 getBankNameDictionary] retain];
    [parser1 release];
    
    XmlParser *parser2 = [[XmlParser alloc]init];
    _provinceDict = [[parser2 getProvinceNameDictionary] retain];
    [parser2 release];
    
    XmlParser *parser3 = [[XmlParser alloc]init];
    _cityDict = [[parser3 getCityNameDictionary] retain];
    [parser3 release];
    
    _selectPlaceDict = [[NSMutableDictionary alloc] init];
    _infoDict = [[NSMutableDictionary alloc] init];
    [self fillView];
    [self customerServiceMessageRequest];
    [self.xfTabBarController setTabBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadBankInfo];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _realNameTextField = nil;
        _cardNumberTextField = nil;
        
        _bankCardNumberTextField = nil;
        _openAccountAddressLabel = nil;
        _openAccountFullNameTextField = nil;
        _bankNameLabel = nil;
        
        _perfectBtn = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
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
    [_perfectBtn setHidden:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [self hideKeyBoard:nil];
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    NSLog(@"responseDic == %@",[request responseString]);
    if(responseDic && [[responseDic stringForKey:@"isBinded"] isEqualToString:@"Yes"]) { //全部已经绑定信息
        /********************** adjustment 控件调整 ***************************/
        CGFloat imageViewMinY = IS_PHONE ? 12.0f : 18.0f;
        CGFloat imageViewSize = IS_PHONE ? 21.0f : 30.0f;
        CGFloat allLabelHeight = imageViewSize;//所有label的高度
        CGFloat backImageViewLineHeight = allLabelHeight + imageViewMinY * 2;
        /********************** adjustment end ***************************/
        CGRect originalSecondBackImageViewRect = _secondBackImageView.frame;
        
        CGRect secondBackImageViewRect = CGRectMake(CGRectGetMinX(originalSecondBackImageViewRect), CGRectGetMinY(originalSecondBackImageViewRect), CGRectGetWidth(originalSecondBackImageViewRect), backImageViewLineHeight * 6 + AllLineWidthOrHeight * 5);
        secondBackImageViewRect.size.height -= (IS_PHONE ? 21.0f : 30.0f)*4;
        [_secondBackImageView setFrame:secondBackImageViewRect];
        
        //customerServiceLabel
        CGRect originalCustomerServiceLabelRect = _customerServiceLabel.frame;
        CGRect customerServiceLabelRect = CGRectMake(CGRectGetMinX(originalCustomerServiceLabelRect), CGRectGetMaxY(secondBackImageViewRect)-50, CGRectGetWidth(originalCustomerServiceLabelRect), CGRectGetHeight(originalCustomerServiceLabelRect));
        [_customerServiceLabel setFrame:customerServiceLabelRect];
        
        CGRect appRect = [[UIScreen mainScreen] applicationFrame];
        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect), 740 - 140)];
        
        [_phoneLabel setText:[responseDic stringForKey:@"mobile"]];
        [_phoneCaptchaBtn setHidden:YES];
        [_phoneCaptchaLeftSignImageView setHidden:YES];
        
        if ([responseDic stringForKey:@"name"].length > 0) {
            [_userNameTextField setText:[responseDic stringForKey:@"name"]];
        } else if ([responseDic stringForKey:@"mobile"].length > 0) {
            [_userNameTextField setText:[responseDic stringForKey:@"mobile"]];
        }
        [_userNameTextField setEnabled:NO];
        
        if ([responseDic stringForKey:@"qqnumber"].length > 0) {
            [_qqTextField setText:[responseDic stringForKey:@"qqnumber"]];
        } else {
            [_qqTextField setText:@"无"];
        }
        [_qqTextField setEnabled:NO];
        
        [_realNameTextField setText:[responseDic stringForKey:@"realityName"]];
        [_realNameTextField setEnabled:NO];
        
        
        [_bankNameSelectBtn setHidden:YES];
        [_bankNameLeftSignImageView setHidden:YES];
        
        
        NSRange range = NSMakeRange(5, 6);
        NSString *cardNumber = [responseDic stringForKey:@"idCardnumber"];
        if(cardNumber && cardNumber.length > 10) {
            [_cardNumberTextField setText:[InterfaceHelper replaceString:cardNumber InRange:range WithCharacter:@"*"]];
            [_cardNumberTextField setEnabled:NO];
        } else {
            [_cardNumberTextField setText:cardNumber];
            [_cardNumberTextField setEnabled:NO];
        }
        
        _bankNameLabel.text = [responseDic stringForKey:@"bankTypeName"];
        _openAccountAddressLabel.text = [NSString stringWithFormat:@"%@%@",[responseDic stringForKey:@"provinceName"],[responseDic stringForKey:@"cityName"]];
        [_openAccountAddressBtn setHidden:YES];
        [_openAccountAddressLeftSignImageView setHidden:YES];
        
        [_openAccountFullNameTextField setText:[responseDic stringForKey:@"branchBankName"]];
        [_openAccountFullNameTextField setEnabled:NO];
        
        NSString *bankCardNumber = [responseDic stringForKey:@"bankCardNumber"];
        if (bankCardNumber && bankCardNumber.length > 10) {
            [_bankCardNumberTextField setText:[InterfaceHelper replaceString:bankCardNumber InRange:range WithCharacter:@"*"]];
            [_bankCardNumberTextField setEnabled:NO];
        }
        
        for (NSInteger i = 2010; i<2017; i++) {//隐藏安全问题
            UIView *view = [_secondBackImageView viewWithTag:i];
            if (view) {
                [view setHidden:YES];
            }
        }
        
        [_perfectBtn setHidden:YES]; //已经绑定银行卡信息  将按钮隐藏
        
    } else if (responseDic){ //没有全部绑定的情况
        
        [XYMPromptView defaultShowInfo:@"请先绑定身份信息" isCenter:YES];
        
        NSString *realName = [UserInfo shareUserInfo].realName;
        NSString *cardNo = [UserInfo shareUserInfo].cardNumber;
        if (realName != nil && realName.length > 0 && cardNo != nil && cardNo.length > 0) {//有绑定“我的身份证信息”
            [_realNameTextField setText:realName];
            [_realNameTextField setEnabled:NO];
            
            NSRange range = NSMakeRange(5, 6);
            if(cardNo && cardNo.length > 12) {
                [_cardNumberTextField setText:[InterfaceHelper replaceString:cardNo InRange:range WithCharacter:@"*"]];
                [_cardNumberTextField setEnabled:NO];
            } else {
                [_cardNumberTextField setText:cardNo];
            }
        }
        
        if ([responseDic stringForKey:@"qqnumber"].length > 0) {
            [_qqTextField setText:[responseDic stringForKey:@"qqnumber"]];
            [_qqTextField setEnabled:NO];
        }
        
        [_perfectBtn setHidden:NO];
        
        if ([responseDic stringForKey:@"securityQuestionAnswer"].length > 0 && [responseDic stringForKey:@"securityQuestionId"].length > 0) {
            /********************** adjustment 控件调整 ***************************/
            CGFloat imageViewMinY = IS_PHONE ? 12.0f : 18.0f;
            CGFloat imageViewSize = IS_PHONE ? 21.0f : 30.0f;
            CGFloat allLabelHeight = imageViewSize;//所有label的高度
            CGFloat backImageViewLineHeight = allLabelHeight + imageViewMinY * 2;
            /********************** adjustment end ***************************/
            CGRect originalSecondBackImageViewRect = _secondBackImageView.frame;
            
            CGRect secondBackImageViewRect = CGRectMake(CGRectGetMinX(originalSecondBackImageViewRect), CGRectGetMinY(originalSecondBackImageViewRect), CGRectGetWidth(originalSecondBackImageViewRect), backImageViewLineHeight * 6 + AllLineWidthOrHeight * 5);
            [_secondBackImageView setFrame:secondBackImageViewRect];
            
            CGRect originalperfectBtnRect = _perfectBtn.frame;
            CGRect perfectBtnRect = CGRectMake(CGRectGetMinX(originalperfectBtnRect), CGRectGetMaxY(secondBackImageViewRect) + 10, CGRectGetWidth(originalperfectBtnRect), CGRectGetHeight(originalperfectBtnRect));
            [_perfectBtn setFrame:perfectBtnRect];
            
            //customerServiceLabel
            CGRect originalCustomerServiceLabelRect = _customerServiceLabel.frame;
            CGRect customerServiceLabelRect = CGRectMake(CGRectGetMinX(originalCustomerServiceLabelRect), CGRectGetMaxY(perfectBtnRect), CGRectGetWidth(originalCustomerServiceLabelRect), CGRectGetHeight(originalCustomerServiceLabelRect));
            [_customerServiceLabel setFrame:customerServiceLabelRect];
            
            if ([responseDic stringForKey:@"securityQuestionAnswer"].length > 0) {
                [_answerTextField setText:[NSString stringWithFormat:@"%@",[responseDic stringForKey:@"securityQuestionAnswer"]]];
            }
            
            if ([responseDic stringForKey:@"securityQuestionId"].length > 0) {
                securityQuestionId = [[responseDic stringForKey:@"securityQuestionId"] integerValue];
            }
        }
    }
    if (_loadBankInfoRequest != nil) {
        [_loadBankInfoRequest clearDelegatesAndCancel];
        [_loadBankInfoRequest release];
        _loadBankInfoRequest = nil;
    }
}

- (void)customerServiceMessageRequestFinish:(ASIHTTPRequest *)request {
    [self hideKeyBoard:nil];
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    if(responseDic) {
        NSString *siteName = [responseDic stringForKey:@"SiteName"];
        NSString *phone = [responseDic stringForKey:@"Phone"];
        [_customerServiceLabel setText:[NSString stringWithFormat:@"温馨提示：\n1、用户名以及手机号码是你登录的唯一凭证。\n2、真实姓名须同银行卡户名一致，身份证号码须同银行卡户主身份一致。\n3、请放心填写真实的个人资料，我们会对你的身份信息进行严格保密。\n4、以上资料仅用于提款到银行卡，请真实填写否则无法完成提款。\n5、以上信息一经填写不能轻易修改，请确保填写准确\n6、如需修改账户信息，请联系【%@】客服，热线电话：%@",siteName,phone]];
    }
}

- (void)customerServiceMessageRequestFail:(ASIHTTPRequest *)request {
}

- (void)bindBankFinish:(ASIHTTPRequest *)request {
    [self hideKeyBoard:nil];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic stringForKey:@"isBinded"] isEqualToString:@"Yes"]) {
        [UserInfo shareUserInfo].realName = [_infoDict stringForKey:@"realityName"];
        [UserInfo shareUserInfo].cardNumber = [_infoDict stringForKey:@"idCardnumber"];
        PerfectSucceedViewController *perfectSucceedViewController = [[PerfectSucceedViewController alloc] init];
        [self.navigationController pushViewController:perfectSucceedViewController animated:YES];
        [perfectSucceedViewController release];
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic stringForKey:@"msg"]];
    }
}

- (void)bindBankFail:(ASIHTTPRequest *)request {
}

#pragma mark -PhoneVerificationViewControllerDelegate
- (void)phoneVerificationPassWithPhoneNumber:(NSString *)phoneNumber {
    [_phoneCaptchaBtn setTitle:phoneNumber.length == 0 ? @"点击绑定关联手机号码" : @"" forState:UIControlStateNormal];
    [_phoneLabel setText:phoneNumber];
}

#pragma mark -SelectViewControllerDelegate
- (void)selectViewAtIndex:(NSInteger)index selectType:(SelectType)selectType {
    if (selectType == SelectTypeOfBankName) {
        [_selectBankDict release];
        _selectBankDict = [[_bankDict objectForKey:[NSString stringWithFormat:@"%ld",(long)index]] retain];
        
        NSString *bankName = [_selectBankDict stringForKey:@"bankname"];
        if (bankName.length > 0) {
            [_bankNameLabel setText:bankName];
            [_bankNameSelectBtn setTitle:@"" forState:UIControlStateNormal];
        } else {
            [_bankNameSelectBtn setTitle:@"点击选择银行名称" forState:UIControlStateNormal];
        }
        
    }
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //省份和城市
    if(component == 0) {
        return _provinceDict.count;
    }
    if(component == 1) {
        return _selectProvinceCitysArray.count;
    }
    
    return 0;
}

#pragma mark -UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[[UILabel alloc] init] autorelease];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
        [pickerLabel setMinimumScaleFactor:0.6];
        [pickerLabel setAdjustsFontSizeToFitWidth:YES];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        
    }
    
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self pickerTag:pickerView.tag titleForRow:row forComponent:component];
    
}

- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component == 0) {
        //根据选中的省份  找出对应的城市数组
        NSDictionary *provinceInfo = [_provinceDict objectForKey:[NSString stringWithFormat:@"%ld",(long)row]];
        NSString *selectProvinceID = [provinceInfo stringForKey:@"id"];
        [_selectProvinceCitysArray release];
        _selectProvinceCitysArray = nil;
        _selectProvinceCitysArray = [[_cityDict objectForKey:selectProvinceID] retain];
        [picker reloadComponent:1];
        
        NSString *provinceStr = [self pickerTag:picker.tag titleForRow:row forComponent:0];
        [_selectPlaceDict setObject:selectProvinceID forKey:@"provinceID"];
        [_selectPlaceDict setObject:provinceStr forKey:@"provinceName"];
        
        NSDictionary *dic = [_selectProvinceCitysArray objectAtIndex:0];
        NSString *selectCityID = [dic stringForKey:@"cityId"];
        NSString *cityStr = [dic stringForKey:@"cityName"];
        [_selectPlaceDict setObject:selectCityID forKey:@"cityID"];
        [_selectPlaceDict setObject:cityStr forKey:@"cityName"];
        [_selectPlaceDict setObject:[NSString stringWithFormat:@"%ld",(long)row] forKey:@"selectProvinceRowIndex"];
        [_selectPlaceDict setObject:[NSString stringWithFormat:@"%d",0] forKey:@"selectCityRowIndex"];
    }
    if(component == 1) {
        NSDictionary *dic = [_selectProvinceCitysArray objectAtIndex:row];
        NSString *selectCityID = [dic stringForKey:@"cityId"];
        NSString *cityStr = [self pickerTag:picker.tag titleForRow:row forComponent:1];
        [_selectPlaceDict setObject:selectCityID forKey:@"cityID"];
        [_selectPlaceDict setObject:cityStr forKey:@"cityName"];
        [_selectPlaceDict setObject:[NSString stringWithFormat:@"%ld",(long)row] forKey:@"selectCityRowIndex"];
    }
}

#pragma mark -CustomAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 520) {
        if (buttonIndex == 1) {
            NSString *place = [NSString stringWithFormat:@"%@%@",[_selectPlaceDict stringForKey:@"provinceName"],[_selectPlaceDict stringForKey:@"cityName"]];
            [_openAccountAddressLabel setText:place];
            if (place.length > 0) {
                [_openAccountAddressBtn setTitle:@"" forState:UIControlStateNormal];
            } else {
                [_openAccountAddressBtn setTitle:@"点击选择开户地点" forState:UIControlStateNormal];
            }
        }
    } else if (alertView.tag == 521) {
        if (buttonIndex == 1) {
            [self bindBankInfo];
        }
    }
}

#pragma mark -SelectSafeProblemViewDelegate
- (void)listViewDidSelectedText:(NSString *)selectText AtRowIndex:(NSInteger)index {
    [_saftProblemTextField setText:selectText];
    _selectSafeProblemIndex = index;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController setTabBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)phoneCaptchaTouchUpInside:(id)sender {
    if([UserInfo shareUserInfo].phoneNumber.length != 0)
        return;
    
    PhoneVerificationViewController *phoneVerificationViewController = [[PhoneVerificationViewController alloc] init];
    [phoneVerificationViewController setDelegate:self];
    [self.navigationController pushViewController:phoneVerificationViewController animated:YES];
    [phoneVerificationViewController release];
}

- (void)bankNameSelectTouchUpInside:(id)sender {
    SelectViewController *selectViewController = [[SelectViewController alloc] initWithSelectDict:_bankDict selectKeyName:@"bankname" selectType:SelectTypeOfBankName];
    [selectViewController setDelegate:self];
    [self.navigationController pushViewController:selectViewController animated:YES];
    [selectViewController release];
}

- (void)openAccountAddressTouchUpInside:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if([_selectProvinceCityDic objectForKey:@"selectProvinceRowIndex"]) {
        NSString *selectProvinceRow = [_selectProvinceCityDic stringForKey:@"selectProvinceRowIndex"];
        [dic setObject:selectProvinceRow forKey:@"selectProvinceRowIndex"];
    }
    if([_selectProvinceCityDic objectForKey:@"selectCityRowIndex"]) {
        NSString *selectCityRow = [_selectProvinceCityDic stringForKey:@"selectCityRowIndex"];
        [dic setObject:selectCityRow forKey:@"selectCityRowIndex"];
    }
    
    CGRect alertRect = CGRectMake(0, 0, CustomAlertViewSize.width, CustomAlertViewSize.height);
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:alertRect title:@"请选择开户地点" delegate:self];
    alert.tag = 520;
    /********************** adjustment 控件调整 ***************************/
    CGRect titleRect = alert.titleLabel.frame;
    CGRect lineRect = alert.redLineView.frame;
    CGFloat pickerViewHeight = 200.0;
    /********************** adjustment end ***************************/
    UIView *backView = alert.secondBackView;
    
    //pickerView 滚动选择视图
    CGRect pickerViewRect = CGRectMake(CGRectGetMinX(titleRect), CGRectGetMaxY(lineRect), CGRectGetWidth(titleRect), pickerViewHeight);
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:pickerViewRect];
    [pickerView setShowsSelectionIndicator:YES];
    [pickerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [pickerView setDataSource:self];
    [pickerView setDelegate:self];
    [pickerView setTag:10];
    [backView addSubview:pickerView];
    [pickerView release];
    
    [alert show];
    [alert release];
    
    [self pickerView:pickerView didSelectRow:0 inComponent:0];
}

- (void)selectSafeProblemTouchUpInside:(id)sender {
    [self hideKeyBoard:nil];
    CGRect frame = [UIScreen mainScreen].bounds;
    
    SafeProblemPopView *popView = [[SafeProblemPopView alloc]initWithFrame:CGRectMake((frame.size.width - CustomAlertViewSize.width) / 2, (frame.size.height - CustomAlertViewSize.height) / 2, CustomAlertViewSize.width, CustomAlertViewSize.height) SelectIndex:_selectSafeProblemIndex];
    popView.delegate = self;
    [popView show];
    [popView release];
}

- (void)hideKeyBoard:(UITapGestureRecognizer *)gesture {
    [_userNameTextField resignFirstResponder];
    [_qqTextField resignFirstResponder];
    [_realNameTextField resignFirstResponder];
    [_cardNumberTextField resignFirstResponder];
    [_openAccountFullNameTextField resignFirstResponder];
    [_bankCardNumberTextField resignFirstResponder];
    [_saftProblemTextField resignFirstResponder];
    [_answerTextField resignFirstResponder];
}

- (void)perfectInfoTouchUpInside:(id)sender {
    if (_phoneLabel.text.length == 0 || _userNameTextField.text == 0 || _realNameTextField.text.length == 0 || _cardNumberTextField.text.length == 0 || _answerTextField.text.length == 0) {
        [Globals alertWithMessage:@"请完善信息"];
        return;
    }
    
    [_infoDict removeAllObjects];
    //提前处理info
    [_infoDict setObject:_userNameTextField.text forKey:@"name"];
    [_infoDict setObject:_qqTextField.text.length > 0 ? _qqTextField.text : @"" forKey:@"qqnumber"];
    [_infoDict setObject:_phoneLabel.text  forKey:@"mobile"];
    [_infoDict setObject:_realNameTextField.text forKey:@"realityName"];
    [_infoDict setObject:_cardNumberTextField.text forKey:@"idCardnumber"];
    [_infoDict setObject:securityQuestionId != 0 ? [NSString stringWithFormat:@"%ld",(long)securityQuestionId] : [NSString stringWithFormat:@"%ld",(long)(_selectSafeProblemIndex + 1)] forKey:@"securityQuestionId"];//服务器问题是从1下标开始的
    [_infoDict setObject:_answerTextField.text forKey:@"securityQuestionAnswer"];
    [self showSubmitView];
}

#pragma mark -Customized: Private (General)
- (void)fillView {
    if ([UserInfo shareUserInfo].phoneNumber.length > 0) {
        [_phoneLabel setText:[UserInfo shareUserInfo].phoneNumber];
        [_phoneCaptchaBtn setHidden:YES];
        [_phoneCaptchaLeftSignImageView setHidden:YES];
    }
    
    if ([UserInfo shareUserInfo].userName.length > 0) {
        [_userNameTextField setText:[UserInfo shareUserInfo].userName];
        [_userNameTextField setEnabled:NO];
        
    } else if([UserInfo shareUserInfo].phoneNumber.length > 0) {
        [_userNameTextField setText:[UserInfo shareUserInfo].phoneNumber];
        [_userNameTextField setEnabled:NO];
    }
}

- (NSString *)pickerTag:(NSInteger)pickerTag titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0) {//省份
        NSDictionary *provinceInfoDic = [_provinceDict objectForKey:[NSString stringWithFormat:@"%ld",(long)row]];
        return [provinceInfoDic stringForKey:@"provincename"];
    }
    if(component == 1) {//跟省份对应的城市
        if(_selectProvinceCitysArray.count > 0) {
            NSDictionary *cityInfoDic = [_selectProvinceCitysArray objectAtIndex:row];
            return [cityInfoDic stringForKey:@"cityName"];
        } else {
            return @"";
        }
    }
    
    return @"";
}

- (void)showSubmitView {
    CGFloat underOfLineLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    CGFloat labelVerticalInterval = IS_PHONE ? 10.0f : 15.0f;
    
    CGRect alertRect = CGRectMake(0, 0, CustomAlertViewSize.width, CustomAlertViewSize.height + (_qqTextField.text.length > 0 ? 40.0f : 0.0f) - underOfLineLabelHeight*4);
    CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:alertRect title:@"请确认以下信息" delegate:self];
    alert.tag = 521;
    /********************** adjustment 控件调整 ***************************/
    CGRect titleRect = alert.titleLabel.frame;
    CGRect lineRect = alert.redLineView.frame;
    /********************** adjustment end ***************************/
    
    
    UIView *backView = alert.secondBackView;
    
    //phoneNumberLabel 手机号码
    CGRect phoneNumberLabelRect = CGRectMake(CGRectGetMinX(titleRect), CGRectGetMaxY(lineRect) + labelVerticalInterval , CGRectGetWidth(titleRect), underOfLineLabelHeight);
    UILabel *phoneNumberLabel = [[UILabel alloc]initWithFrame:phoneNumberLabelRect];
    [phoneNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [phoneNumberLabel setBackgroundColor:[UIColor clearColor]];
    [phoneNumberLabel setTextAlignment:NSTextAlignmentLeft];
    [phoneNumberLabel setText:[NSString stringWithFormat:@"手机号码：%@",[_infoDict objectForKey:@"mobile"]]];
    [backView addSubview:phoneNumberLabel];
    [phoneNumberLabel release];
    
    //realNameLabel 真实姓名
    CGRect realNameLabelRect = CGRectMake(CGRectGetMinX(titleRect), CGRectGetMaxY(phoneNumberLabelRect) + labelVerticalInterval , CGRectGetWidth(titleRect), underOfLineLabelHeight);
    UILabel *realNameLabel = [[UILabel alloc]initWithFrame:realNameLabelRect];
    [realNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [realNameLabel setBackgroundColor:[UIColor clearColor]];
    [realNameLabel setTextAlignment:NSTextAlignmentLeft];
    [realNameLabel setText:[NSString stringWithFormat:@"真实姓名：%@",[_infoDict objectForKey:@"realityName"]]];
    [backView addSubview:realNameLabel];
    [realNameLabel release];
    
    CGFloat idLabelRectMinY = CGRectGetMaxY(realNameLabelRect) + labelVerticalInterval;
    
    if (_qqTextField.text.length > 0) {
        //idLabel 身份证号码
        CGRect qqLabelRect = CGRectMake(CGRectGetMinX(titleRect), idLabelRectMinY , CGRectGetWidth(titleRect), underOfLineLabelHeight);
        UILabel *qqLabel = [[UILabel alloc]initWithFrame:qqLabelRect];
        [qqLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [qqLabel setBackgroundColor:[UIColor clearColor]];
        [qqLabel setTextAlignment:NSTextAlignmentLeft];
        [qqLabel setText:[NSString stringWithFormat:@"qq：%@",[_infoDict objectForKey:@"qqnumber"]]];
        [backView addSubview:qqLabel];
        [qqLabel release];
        
        idLabelRectMinY = CGRectGetMaxY(qqLabelRect) + labelVerticalInterval;
    }
    
    //idLabel 身份证号码
    CGRect idLabelRect = CGRectMake(CGRectGetMinX(titleRect), idLabelRectMinY , CGRectGetWidth(titleRect), underOfLineLabelHeight);
    UILabel *idLabel = [[UILabel alloc]initWithFrame:idLabelRect];
    [idLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [idLabel setBackgroundColor:[UIColor clearColor]];
    [idLabel setTextAlignment:NSTextAlignmentLeft];
    [idLabel setText:[NSString stringWithFormat:@"身份证号码：%@",[_infoDict objectForKey:@"idCardnumber"]]];
    [backView addSubview:idLabel];
    [idLabel release];
    
    [alert show];
    [alert release];
}

- (void)bindBankInfo {
    [self clearHTTPRequest];
    
    NSLog(@"bind -> %@", [NSURL shoveURLWithOpt:HTTP_REQUEST_BindBankInformation userId:[UserInfo shareUserInfo].userID infoDict:_infoDict]);
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_BindBankInformation userId:[UserInfo shareUserInfo].userID infoDict:_infoDict]];
    _httpRequest.delegate = self;
    [_httpRequest setDidFinishSelector:@selector(bindBankFinish:)];
    [_httpRequest setDidFailSelector:@selector(bindBankFail:)];
    [_httpRequest startAsynchronous];
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

- (void)loadBankInfo {
    [self clearLoadBankInfoRequest];
    
    NSLog(@"opt -> %@", [NSURL shoveURLWithOpt:HTTP_REQUEST_BindInformation userId:[UserInfo shareUserInfo].userID infoDict:nil]);
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

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

@end
