//
//  AddBankCardViewController.m
//  TicketProject
//
//  Created by jsonLuo on 16/9/23.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import "AddBankCardViewController.h"
#import "AddCardTableViewCell.h"
#import "Globals.h"
#import "SelectViewController.h"
#import "XmlParser.h"
#import "PhoneVerificationViewController.h"
#import "XFTabBarViewController.h"
#import "UserInfo.h"
#import "PerfectSucceedViewController.h"
#import "SafeProblemPopView.h"
#import "UserInfo.h"

#define CustomAlertViewSize (IS_PHONE ? CGSizeMake(300.0f, 300.0f) : CGSizeMake(500.0f, 500.0f))//所有选择框的大小

@interface AddBankCardViewController ()<CustomAlertViewDelegate>{
    
    UILabel *_bankNameLabel;            //银行卡名
    UILabel *_openAccountAddressLabel;  //开户地点
    UIButton *_bankNameSelectBtn;       //选择银行卡
    UIButton *_openAccountAddressBtn;   //选择开户地点
    UIButton *_perfectBtn;              //绑定银行卡
    UITextField *_realNameTextField;    //真实姓名
    UITextField *_cardNumberTextField;  //银行卡
    UITextField *_openAccountFullNameTextField;         //开户支行全称
    UITextField *_bankCardNumberTextField;              //银行卡号
    UIImageView *_bankNameLeftSignImageView;            //银行卡进入提示
    UIImageView *_openAccountAddressLeftSignImageView;  //银行进入提示
    
    NSDictionary *_bankDict;        //银行
    NSDictionary *_provinceDict;    //省份
    NSDictionary *_cityDict;        //城市
    NSMutableDictionary *_selectBankDict;
    NSMutableArray *_selectProvinceCitysArray;
    NSMutableDictionary *_selectPlaceDict;
    
    BOOL _isDetail; //是否是银行卡详情
    NSDictionary *_cardInfo;    //银行卡信息
    void(^_succeed)();          //添加银行卡成功回调
}

@end

@implementation AddBankCardViewController

- (instancetype)initWithisDetail:(BOOL)isDetail info:(NSDictionary *)info succeed:(void(^)())succeed{
    if (self = [super init]) {
        _isDetail = isDetail;
        _cardInfo = info;
        _succeed = succeed;
    }
    return self;
}

- (void)dealloc{
    _realNameTextField = nil;
    _cardNumberTextField = nil;
    _bankNameLabel = nil;
    _openAccountAddressLabel = nil;
    _bankNameSelectBtn = nil;
    _openAccountAddressBtn = nil;
    _bankNameLeftSignImageView = nil;
    _openAccountAddressLeftSignImageView = nil;
    _openAccountFullNameTextField = nil;
    _bankCardNumberTextField = nil;
    _perfectBtn = nil;
    _selectBankDict = nil;
    _selectProvinceCitysArray = nil;
    _selectPlaceDict = nil;
}

- (void)loadView{
    [super loadView];
    [self setTitle:@"添加银行卡"];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    _selectPlaceDict = [[NSMutableDictionary alloc] init];
    
    /********************** adjustment 控件调整 ***************************/
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    
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
    
    CGRect secondBackImageViewRect = CGRectMake(backImageViewMinX, backImageViewMinX, backImageViewWidth, backImageViewLineHeight * 8 + AllLineWidthOrHeight * 7);
    UIView *_secondBackImageView = self.view;
    [_secondBackImageView setBackgroundColor:[UIColor whiteColor]];
    
    /*************************************************/
    
    
    //realNameImageView
    CGRect realNameImageViewRect = CGRectMake(imageViewMinX, imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *realNameImageView = [[UIImageView alloc] initWithFrame:realNameImageViewRect];
    [realNameImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountName.png"]]];
    [_secondBackImageView addSubview:realNameImageView];
//    [realNameImageView setHidden:!_isDetail];
    
    //realNamePromptLabel 真实姓名－提示文字
    CGRect realNamePromptLabelRect = CGRectMake(CGRectGetMaxX(realNameImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(realNameImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *realNamePromptLabel = [[UILabel alloc] initWithFrame:realNamePromptLabelRect];
    [realNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [realNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [realNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [realNamePromptLabel setText:@"持 卡 人"];
    [_secondBackImageView addSubview:realNamePromptLabel];
//    [realNamePromptLabel setHidden:!_isDetail];
    
    //realNameTextField 真实姓名
    CGRect realNameTextFieldRect = CGRectMake(CGRectGetMaxX(realNamePromptLabelRect), CGRectGetMinY(realNamePromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(realNamePromptLabelRect) - CGRectGetMinX(realNamePromptLabelRect), allLabelHeight);
    _realNameTextField = [[UITextField alloc] initWithFrame:realNameTextFieldRect];
    [_realNameTextField setBackgroundColor:[UIColor clearColor]];
    [_realNameTextField setPlaceholder:@"请输入持卡人姓名"];
    [_realNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_realNameTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_realNameTextField setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_realNameTextField];
//    [_realNameTextField setHidden:!_isDetail];
    
    CGRect secondViewLine1Rect = CGRectMake(0, CGRectGetMaxY(realNameImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine1Rect inSuperView:_secondBackImageView];
    
    
    //myBankInformationBackImageView
    CGRect myBankInformationBackImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine1Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *myBankInformationBackImageView = [[UIImageView alloc] initWithFrame:myBankInformationBackImageViewRect];
    [myBankInformationBackImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountBank.png"]]];
    [_secondBackImageView addSubview:myBankInformationBackImageView];
    
    //bankNamePromptLabel 银行名称－提示文字
    CGRect bankNamePromptLabelRect = CGRectMake(CGRectGetMaxX(myBankInformationBackImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(myBankInformationBackImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *bankNamePromptLabel = [[UILabel alloc] initWithFrame:bankNamePromptLabelRect];
    [bankNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [bankNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [bankNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [bankNamePromptLabel setText:@"银行名称"];
    [_secondBackImageView addSubview:bankNamePromptLabel];
    
    //bankNameLabel 银行名称
    CGRect bankNameLabelRect = CGRectMake(CGRectGetMaxX(bankNamePromptLabelRect), CGRectGetMinY(bankNamePromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(bankNamePromptLabelRect) - CGRectGetMinX(bankNamePromptLabelRect), allLabelHeight);
    _bankNameLabel = [[UILabel alloc] initWithFrame:bankNameLabelRect];
    [_bankNameLabel setBackgroundColor:[UIColor clearColor]];
    [_bankNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_bankNameLabel setMinimumScaleFactor:0.75];
    [_bankNameLabel setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_bankNameLabel];
    
    //bankNameSelectBtn
    CGRect bankNameSelectBtnRect = CGRectMake(0, CGRectGetMaxY(secondViewLine1Rect), CGRectGetWidth(secondBackImageViewRect), backImageViewLineHeight);
    _bankNameSelectBtn = [[UIButton alloc] initWithFrame:bankNameSelectBtnRect];
    [_bankNameSelectBtn setBackgroundColor:[UIColor clearColor]];
    [_bankNameSelectBtn setTitleColor:[UIColor colorWithRed:194.0f/255.0f green:194.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_bankNameSelectBtn setTitle:@"点击选择银行名称" forState:UIControlStateNormal];
    [[_bankNameSelectBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_bankNameSelectBtn setAdjustsImageWhenHighlighted:NO];
    [_bankNameSelectBtn addTarget:self action:@selector(bankNameSelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBackImageView addSubview:_bankNameSelectBtn];
    [_bankNameSelectBtn setHidden:_isDetail];
    
    //bankNameLeftSignImageView 银行进入提示
    CGRect bankNameLeftSignImageViewRect = CGRectMake(CGRectGetWidth(secondBackImageViewRect) - leftSignImageViewWidth - leftSignImageViewMaginRightX,  CGRectGetMaxY(secondViewLine1Rect) + (backImageViewLineHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
    _bankNameLeftSignImageView = [[UIImageView alloc] initWithFrame:bankNameLeftSignImageViewRect];
    [_bankNameLeftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
    [_secondBackImageView addSubview:_bankNameLeftSignImageView];
    [_bankNameLeftSignImageView setHidden:_isDetail];
    
    
    CGRect secondViewLine3Rect = CGRectMake(0, CGRectGetMaxY(myBankInformationBackImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine3Rect inSuperView:_secondBackImageView];
    
    /*************************************************/
    
//    //openAccountAddressImageView
//    CGRect openAccountAddressImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine3Rect) + imageViewMinY, imageViewSize, imageViewSize);
//    UIImageView *openAccountAddressImageView = [[UIImageView alloc] initWithFrame:openAccountAddressImageViewRect];
//    [openAccountAddressImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountPlace.png"]]];
//    [_secondBackImageView addSubview:openAccountAddressImageView];
//    
//    //openAccountAddressPromptLabel 开户地点－提示文字
//    CGRect openAccountAddressPromptLabelRect = CGRectMake(CGRectGetMaxX(openAccountAddressImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(openAccountAddressImageViewRect), allLeftLabelWidth, allLabelHeight);
//    UILabel *openAccountAddressPromptLabel = [[UILabel alloc] initWithFrame:openAccountAddressPromptLabelRect];
//    [openAccountAddressPromptLabel setBackgroundColor:[UIColor clearColor]];
//    [openAccountAddressPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [openAccountAddressPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//    [openAccountAddressPromptLabel setText:@"开户地点"];
//    [_secondBackImageView addSubview:openAccountAddressPromptLabel];
//    
//    //openAccountAddressLabel 开户地点
//    CGRect openAccountAddressLabelRect = CGRectMake(CGRectGetMinX(bankNameLabelRect), CGRectGetMinY(openAccountAddressPromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
//    _openAccountAddressLabel = [[UILabel alloc] initWithFrame:openAccountAddressLabelRect];
//    [_openAccountAddressLabel setBackgroundColor:[UIColor clearColor]];
//    [_openAccountAddressLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [_openAccountAddressLabel setMinimumScaleFactor:0.75];
//    [_openAccountAddressLabel setAdjustsFontSizeToFitWidth:YES];
//    [_secondBackImageView addSubview:_openAccountAddressLabel];
//    
//    //openAccountAddressBtn
//    CGRect openAccountAddressBtnRect = CGRectMake(0, CGRectGetMaxY(secondViewLine3Rect), CGRectGetWidth(secondBackImageViewRect), backImageViewLineHeight);
//    _openAccountAddressBtn = [[UIButton alloc] initWithFrame:openAccountAddressBtnRect];
//    [_openAccountAddressBtn setBackgroundColor:[UIColor clearColor]];
//    [_openAccountAddressBtn setTitleColor:[UIColor colorWithRed:194.0f/255.0f green:194.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
//    [_openAccountAddressBtn setTitle:@"点击选择开户地点" forState:UIControlStateNormal];
//    [[_openAccountAddressBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [_openAccountAddressBtn setAdjustsImageWhenHighlighted:NO];
//    [_openAccountAddressBtn addTarget:self action:@selector(openAccountAddressTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//    [_secondBackImageView addSubview:_openAccountAddressBtn];
//    [_openAccountAddressBtn setHidden:_isDetail];
//    
//    //openAccountAddressLeftSignImageView 银行进入提示
//    CGRect openAccountAddressLeftSignImageViewRect = CGRectMake(CGRectGetWidth(secondBackImageViewRect) - leftSignImageViewWidth - leftSignImageViewMaginRightX, CGRectGetMaxY(secondViewLine3Rect) + (backImageViewLineHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
//    _openAccountAddressLeftSignImageView = [[UIImageView alloc] initWithFrame:openAccountAddressLeftSignImageViewRect];
//    [_openAccountAddressLeftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
//    [_secondBackImageView addSubview:_openAccountAddressLeftSignImageView];
//    [_openAccountAddressLeftSignImageView setHidden:_isDetail];
//    
//    
//    CGRect secondViewLine4Rect = CGRectMake(0, CGRectGetMaxY(openAccountAddressImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
//    [Globals makeLineWithFrame:secondViewLine4Rect inSuperView:_secondBackImageView];
    
    /*************************************************/
    
//    //openAccountFullNameImageView
//    CGRect openAccountFullNameImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine4Rect) + imageViewMinY, imageViewSize, imageViewSize);
//    UIImageView *openAccountFullNameImageView = [[UIImageView alloc] initWithFrame:openAccountFullNameImageViewRect];
//    [openAccountFullNameImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountDetailPlace.png"]]];
//    [_secondBackImageView addSubview:openAccountFullNameImageView];
//    
//    //openAccountFullNamePromptLabel 开户行全称－提示文字
//    CGRect openAccountFullNamePromptLabelRect = CGRectMake(CGRectGetMaxX(openAccountFullNameImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(openAccountFullNameImageViewRect), allLeftLabelWidth, allLabelHeight);
//    UILabel *openAccountFullNamePromptLabel = [[UILabel alloc] initWithFrame:openAccountFullNamePromptLabelRect];
//    [openAccountFullNamePromptLabel setBackgroundColor:[UIColor clearColor]];
//    [openAccountFullNamePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [openAccountFullNamePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//    [openAccountFullNamePromptLabel setText:@"开户支行"];
//    [_secondBackImageView addSubview:openAccountFullNamePromptLabel];
//    
//    //openAccountFullNameTextField 开户行全称
//    CGRect openAccountFullNameTextFieldRect = CGRectMake(CGRectGetMinX(openAccountAddressLabelRect), CGRectGetMinY(openAccountFullNamePromptLabelRect), CGRectGetWidth(openAccountAddressLabelRect), allLabelHeight);
//    _openAccountFullNameTextField = [[UITextField alloc] initWithFrame:openAccountFullNameTextFieldRect];
//    [_openAccountFullNameTextField setBackgroundColor:[UIColor clearColor]];
//    [_openAccountFullNameTextField setPlaceholder:@"请输入开户支行"];
//    [_openAccountFullNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [_openAccountFullNameTextField setMinimumFontSize:XFIponeIpadFontSize7];
//    [_openAccountFullNameTextField setAdjustsFontSizeToFitWidth:YES];
//    [_secondBackImageView addSubview:_openAccountFullNameTextField];
//    
//    CGRect secondViewLine5Rect = CGRectMake(0, CGRectGetMaxY(openAccountFullNameImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
//    [Globals makeLineWithFrame:secondViewLine5Rect inSuperView:_secondBackImageView];
    
    /*************************************************/
    
    //bankCardNumberImageView
    CGRect bankCardNumberImageViewRect = CGRectMake(imageViewMinX, CGRectGetMaxY(secondViewLine3Rect) + imageViewMinY, imageViewSize, imageViewSize);
    UIImageView *bankCardNumberImageView = [[UIImageView alloc] initWithFrame:bankCardNumberImageViewRect];
    [bankCardNumberImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"accountCard.png"]]];
    [_secondBackImageView addSubview:bankCardNumberImageView];
    
    //bankCardNumberPromptLabel 银行卡号－提示文字
    CGRect bankCardNumberPromptLabelRect = CGRectMake(CGRectGetMaxX(bankCardNumberImageViewRect) + allLeftLabelImageViewAddX, CGRectGetMinY(bankCardNumberImageViewRect), allLeftLabelWidth, allLabelHeight);
    UILabel *bankCardNumberPromptLabel = [[UILabel alloc] initWithFrame:bankCardNumberPromptLabelRect];
    [bankCardNumberPromptLabel setBackgroundColor:[UIColor clearColor]];
    [bankCardNumberPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [bankCardNumberPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [bankCardNumberPromptLabel setText:@"银行卡号"];
    [_secondBackImageView addSubview:bankCardNumberPromptLabel];
    
    //bankCardNumberTextField 银行卡号
    CGRect bankCardNumberTextFieldRect = CGRectMake(CGRectGetMinX(bankNameLabelRect), CGRectGetMinY(bankCardNumberPromptLabelRect), CGRectGetWidth(bankNameLabelRect), allLabelHeight);
    _bankCardNumberTextField = [[UITextField alloc] initWithFrame:bankCardNumberTextFieldRect];
    [_bankCardNumberTextField setBackgroundColor:[UIColor clearColor]];
    [_bankCardNumberTextField setPlaceholder:@"请输入银行卡号"];
    [_bankCardNumberTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_bankCardNumberTextField setMinimumFontSize:XFIponeIpadFontSize7];
    [_bankCardNumberTextField setAdjustsFontSizeToFitWidth:YES];
    [_secondBackImageView addSubview:_bankCardNumberTextField];
    
    CGRect secondViewLine6Rect = CGRectMake(0, CGRectGetMaxY(bankCardNumberImageViewRect) + imageViewMinY, CGRectGetWidth(secondBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:secondViewLine6Rect inSuperView:_secondBackImageView];
    
    //perfectBtn 绑定按钮
    CGRect perfectBtnRect = CGRectMake((CGRectGetWidth(appRect) - buttonWidth) / 2, CGRectGetMaxY(bankCardNumberImageViewRect) + partVerticalInterval, buttonWidth, buttonHeight);
    _perfectBtn = [[UIButton alloc] initWithFrame:perfectBtnRect];
    [_perfectBtn setTitle:@"绑定银行卡" forState:UIControlStateNormal];
    [_perfectBtn setTitle:@"绑定银行卡" forState:UIControlStateHighlighted];
    [_perfectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_perfectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_perfectBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [_perfectBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [_perfectBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [_perfectBtn addTarget:self action:@selector(perfectInfoTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//    [_perfectBtn setHidden:YES];
    [_secondBackImageView addSubview:_perfectBtn];
    
    //判断详情？添加？
    [_perfectBtn setHidden:_isDetail];//详情则隐藏
    [self.view setUserInteractionEnabled:!_isDetail];//详情页不可交互
    if (_cardInfo) {//加载信息
        [self setInfo];
    }
    if (_isDetail) {
        UIBarButtonItem *naviItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteCard)];
        [self.navigationItem setRightBarButtonItem:naviItem animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XmlParser *parser1 = [[XmlParser alloc]init];
    _bankDict = [parser1 getBankNameDictionary];
    
    XmlParser *parser2 = [[XmlParser alloc]init];
    _provinceDict = [parser2 getProvinceNameDictionary];
    
    XmlParser *parser3 = [[XmlParser alloc]init];
    _cityDict = [parser3 getCityNameDictionary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 填写银行卡信息
- (void)setInfo{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    [_realNameTextField setText:userInfo.realName];
    [_realNameTextField setText:[NSString stringWithFormat:@"%@",[_cardInfo objectForKey:@"BankUserName"]]];
    [_bankNameLabel setText:[NSString stringWithFormat:@"%@",[_cardInfo objectForKey:@"BankTypeName"]]];
//    [_openAccountAddressLabel setText:[NSString stringWithFormat:@"%@",[_cardInfo objectForKey:@"BankAddress"]]];
//    [_openAccountFullNameTextField setText:[NSString stringWithFormat:@"%@",[_cardInfo objectForKey:@"BankName"]]];
    [_bankCardNumberTextField setText:[NSString stringWithFormat:@"%@",[_cardInfo objectForKey:@"BankCardNumber"]]];
}

#pragma mark 点击绑定银行卡
- (void)perfectInfoTouchUpInside:(UIButton *)button{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    NSMutableDictionary *_infoDict = [[NSMutableDictionary alloc] init];
    /*
     bankInProvinceId:5,
     bankTypeID:1,
     bankInCityId:56,
     bankTypeName:中国工商银行,
     cityName:深圳,
     provinceName:广东,
     bankCardNumber:6222024000088888888,
     bankId:baoan,
     branchBankName:baoan
     */
    
    if (_realNameTextField.text.length == 0 || _bankCardNumberTextField.text.length == 0) {
        [Globals alertWithMessage:@"请完善信息"];
        return;
    }
    
    if (_bankCardNumberTextField.text.length < 16) {
        [Globals alertWithMessage:@"银行卡号码位数不够"];
        return;
    }
    
    NSString *bankTypeID = [_selectBankDict objectForKey:@"id"];
    NSString *bankTypeName = [_selectBankDict objectForKey:@"bankname"];
    if (bankTypeID.length == 0 || bankTypeName.length == 0) {
        [Globals alertWithMessage:@"请选择银行信息"];
        return;
    }
//    NSString *provinceID = [_selectPlaceDict stringForKey:@"provinceID"];
//    NSString *provinceName = [_selectPlaceDict stringForKey:@"provinceName"];
//    NSString *cityID = [_selectPlaceDict stringForKey:@"cityID"];
//    NSString *cityName = [_selectPlaceDict stringForKey:@"cityName"];
//    if (provinceID.length == 0 || provinceName.length == 0 || cityID.length == 0 || cityName.length == 0) {
//        [Globals alertWithMessage:@"请选择开户地点"];
//        return;
//    }
    
    [_infoDict removeAllObjects];
    //提前处理info
    [_infoDict setObject:_realNameTextField.text forKey:@"bankUserName"];
    [_infoDict setObject:bankTypeID forKey:@"bankTypeID"];
    [_infoDict setObject:bankTypeID forKey:@"bankTypeID"];
    [_infoDict setObject:bankTypeName forKey:@"bankTypeName"];
//    [_infoDict setObject:_openAccountFullNameTextField.text forKey:@"bankId"];
//    [_infoDict setObject:_openAccountFullNameTextField.text forKey:@"branchBankName"];
    [_infoDict setObject:_bankCardNumberTextField.text forKey:@"bankCardNumber"];
//    [_infoDict setObject:provinceID forKey:@"bankInProvinceId"];
//    [_infoDict setObject:provinceName forKey:@"provinceName"];
//    [_infoDict setObject:cityID forKey:@"bankInCityId"];
//    [_infoDict setObject:cityName forKey:@"cityName"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_AddBankCard userId:userInfo.userID infoDict:_infoDict]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(addFinish:)];
    [request setDidFailSelector:@selector(addFaild:)];
    [request startAsynchronous];
    [SVProgressHUD showWithStatus:@"绑定中"];
}

- (void)addFinish:(ASIFormDataRequest *)request{
    NSLog(@"--------opt:80----------%@",[request responseString]);
    NSLog(@"--------opt:80URL----------%@",[request url]);
    NSDictionary *dic = [[request responseString] objectFromJSONString];
    if (dic && [[dic objectForKey:@"error"] integerValue] == 0) {
        [SVProgressHUD showSuccessWithStatus:@"添加绑定成功"];
        _succeed();//成功回调
        [self.navigationController popViewControllerAnimated:YES];
    }else if (dic){
        [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"msg"]];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"添加绑定失败"];
    }

}

- (void)addFaild:(ASIFormDataRequest *)request{
    [SVProgressHUD showErrorWithStatus:@"添加绑定失败"];
}

//删除、解绑银行卡
- (void)deleteCard{
    CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:@"确定解除此银行卡的绑定吗" leftText:@"取消" rightText:@"确定"];
    [customAlert setTag:368];
    [customAlert show];
}

- (void)removeFinish:(ASIFormDataRequest *)request{
    NSLog(@"--------opt:81----------%@",[request responseString]);
    NSLog(@"--------opt:81URL----------%@",[request url]);
    NSDictionary *dic = [[request responseString] objectFromJSONString];
    if (dic && [[dic objectForKey:@"error"] integerValue] == 0) {
        [SVProgressHUD showSuccessWithStatus:@"解除绑定成功"];
        _succeed();//成功回调
        [self.navigationController popViewControllerAnimated:YES];
    }else if (dic){
        [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"msg"]];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"解除绑定失败"];
    }
    
}

- (void)removeFaild:(ASIFormDataRequest *)request{
    [SVProgressHUD showErrorWithStatus:@"解除绑定失败"];
}

- (void)bankNameSelectTouchUpInside:(id)sender {
    SelectViewController *selectViewController = [[SelectViewController alloc] initWithSelectDict:_bankDict selectKeyName:@"bankname" selectType:SelectTypeOfBankName];
    [selectViewController setDelegate:self];
    [self.navigationController pushViewController:selectViewController animated:YES];
}

- (void)openAccountAddressTouchUpInside:(id)sender {
    [self.view endEditing:YES];
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
    
    [alert show];
    
    [self pickerView:pickerView didSelectRow:0 inComponent:0];
}


#pragma mark -

#pragma mark -SelectViewControllerDelegate
- (void)selectViewAtIndex:(NSInteger)index selectType:(SelectType)selectType {
    if (selectType == SelectTypeOfBankName) {
        _selectBankDict = [_bankDict objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
        
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
        pickerLabel = [[UILabel alloc] init];
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
        _selectProvinceCitysArray = nil;
        _selectProvinceCitysArray = [_cityDict objectForKey:selectProvinceID];
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
    }else if (alertView.tag == 368){
        if (buttonIndex == 1) {
            UserInfo *userInfo = [UserInfo shareUserInfo];
            NSMutableDictionary *_infoDict = [[NSMutableDictionary alloc] init];
            [_infoDict setObject:[_cardInfo objectForKey:@"BankCardNumber"] forKey:@"bankCardNumber"];
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_RemoveBankCard userId:userInfo.userID infoDict:_infoDict]];
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(removeFinish:)];
            [request setDidFailSelector:@selector(removeFaild:)];
            [request startAsynchronous];
            [SVProgressHUD showWithStatus:@"解绑中"];
        }

    }
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
}


- (void)selectSafeProblemTouchUpInside:(id)sender {
    [self hideKeyBoard:nil];
    CGRect frame = [UIScreen mainScreen].bounds;
    
    /*
     SafeProblemPopView *popView = [[SafeProblemPopView alloc]initWithFrame:CGRectMake((frame.size.width - CustomAlertViewSize.width) / 2, (frame.size.height - CustomAlertViewSize.height) / 2, CustomAlertViewSize.width, CustomAlertViewSize.height) SelectIndex:_selectSafeProblemIndex];
     popView.delegate = self;
     [popView show];
     [popView release];
     */
}

- (void)hideKeyBoard:(UITapGestureRecognizer *)gesture {
    [_realNameTextField resignFirstResponder];
    [_cardNumberTextField resignFirstResponder];
    [_openAccountFullNameTextField resignFirstResponder];
    [_bankCardNumberTextField resignFirstResponder];
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

- (void)bindBankInfo {
    
    /*
     NSLog(@"bind -> %@", [NSURL shoveURLWithOpt:HTTP_REQUEST_BindBankInformation userId:[UserInfo shareUserInfo].userID infoDict:_infoDict]);
     ASIFormDataRequest *_httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_BindBankInformation userId:[UserInfo shareUserInfo].userID infoDict:_infoDict]];
     _httpRequest.delegate = self;
     [_httpRequest setDidFinishSelector:@selector(bindBankFinish:)];
     [_httpRequest setDidFailSelector:@selector(bindBankFail:)];
     [_httpRequest startAsynchronous];
     */
}


- (void)bindBankFinish:(ASIHTTPRequest *)request {
    [self hideKeyBoard:nil];
    /*
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
     */
}

- (void)bindBankFail:(ASIHTTPRequest *)request {
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (![[touch view] conformsToProtocol:@protocol(UITextInput)]) {
        [self.view endEditing:YES];
    }
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
