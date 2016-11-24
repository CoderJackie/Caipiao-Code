//
//  RechargeViewController.m 个人中心－充值
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140825 17:55（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//  20140825 18:12（洪晓彬）：进行ipad适配
//  20150709 16:30（刘科）：优化界面UI，新增充值赠送彩金

#import "RechargeViewController.h"
#import "XFTabBarViewController.h"
#import "PaysuccessViewController.h"

#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Globals.h"
#import "UPPayPlugin.h"
#import "WeixinpayViewController.h"

@interface RechargeViewController ()

@end

#define kWaiting          @"正在获取TN,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"%@"

#pragma mark -
#pragma mark @implementation RechargeViewController
@implementation RechargeViewController
#pragma mark Lifecircle

- (id)initWithRechargeType:(RechargeType)rechargeType {
    self = [super init];
    if (self) {
        _rechargeType = rechargeType;
        if (_rechargeType == RechargeTypeOfUPPayPlugin) {
            [self setTitle:@"银联充值"];
            
        } else if (_rechargeType == RechargeTypeOfAlixPay) {
            [self setTitle:@"银联充值"];
            
        } else if (_rechargeType == RechargeTypeOfNone) {
            [self setTitle:@"微信充值"];
            
        }
        
    }
    return self;
}

- (void)dealloc {
    _userNameLabel = nil;
    _rechargeTextField = nil;
    _giftMoneyLabel = nil;
    [_activeList release];
    _activeList = nil;
    
    [_orderString release];
    [_signString release];
    
    [super dealloc];
}

- (void)loadView {
    _activeList = [NSMutableArray array];
    
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
    
    CGFloat rechargeBackImageViewMinY = IS_PHONE ? 40.0f : 60.0f;
//    CGFloat rechargeBackImageViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat rechargeBackImageViewHeight = IS_PHONE ? 44.0f : 70.0f;
    
    CGFloat rechargeTextFieldMaginBackImageViewX = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat confirmBtnAddY = IS_PHONE ? 10.0f : 20.0f;
//    CGFloat confirmBtnWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat confirmBtnHeight = IS_PHONE ? 40.0f : 65.0f;
    
    CGFloat promptLabelAddY = IS_PHONE ? 13.0f : 20.0f;
    CGFloat promotLabelHeight = IS_PHONE ? 100.0f : 130.0f;
    /********************** adjustment end ***************************/
    
    // chargeAmountLabel
    UILabel *chargeAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.view.frame.size.width - 40, 20)];
    chargeAmountLabel.text = @"请输入充值金额(元)";
    [chargeAmountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [self.view addSubview:chargeAmountLabel];
    [chargeAmountLabel release];
    
    //rechargeBackImageView
    CGRect rechargeBackImageViewRect = CGRectMake(20 , rechargeBackImageViewMinY, CGRectGetWidth(appRect) - 40, rechargeBackImageViewHeight);
    UIImageView *rechargeBackImageView = [[UIImageView alloc] initWithFrame:rechargeBackImageViewRect];
    [rechargeBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:rechargeBackImageView];
    [rechargeBackImageView release];
    
    //rechargeTextField 充值金额
    CGRect rechargeTextFieldRect = CGRectMake(CGRectGetMinX(rechargeBackImageViewRect) + rechargeTextFieldMaginBackImageViewX, rechargeBackImageViewMinY, CGRectGetWidth(appRect) - 40 - rechargeTextFieldMaginBackImageViewX, rechargeBackImageViewHeight);
    _rechargeTextField = [[UITextField alloc] initWithFrame:rechargeTextFieldRect];
    [_rechargeTextField setBackgroundColor:[UIColor clearColor]];
    [_rechargeTextField setTextColor:[UIColor colorWithRed:0xcc/255.0f green:0xcc/255.0f blue:0xcc/255.0f alpha:1.0f]];
    [_rechargeTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize17]];
    [_rechargeTextField setPlaceholder:@"20元"];
    [_rechargeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_rechargeTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_rechargeTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_rechargeTextField];
    [_rechargeTextField release];
    
    // giftMoneyLabel
    _giftMoneyLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(rechargeTextFieldRect) + 10, self.view.frame.size.width - 40, 25)];
    [_giftMoneyLabel setBackgroundColor:[UIColor clearColor]];
    [_giftMoneyLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [self.view addSubview:_giftMoneyLabel];
    [_giftMoneyLabel release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">赠送彩金:  </font><font color=\"%@\">0</font><font color=\"black\"> 元</font>",tRedColorText];
    NSAttributedString *attString =[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize12];
    CGSize payMoneyPromptLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize12];
    [_giftMoneyLabel setFrame:CGRectMake(20, 94, payMoneyPromptLabelSize.width, 25)];
    [_giftMoneyLabel setAttString:attString];
    
    
    //confirmBtn 确定按钮
    CGRect confirmBtnRect = CGRectMake(20, CGRectGetMaxY(_giftMoneyLabel.frame) + confirmBtnAddY - 10, CGRectGetWidth(appRect) - 40, confirmBtnHeight);
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:confirmBtnRect];
    [confirmBtn setTitle:@"立即充值" forState:UIControlStateNormal];
    [confirmBtn setTitle:@"立即充值" forState:UIControlStateHighlighted];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [confirmBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [confirmBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [confirmBtn addTarget:self action:@selector(submitRechargeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    [confirmBtn release];
    
     //promptLabel 提示
    CGRect promptLabelRect = CGRectMake(20, CGRectGetMaxY(confirmBtnRect) + promptLabelAddY, CGRectGetWidth(appRect) - 40 ,promotLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [promptLabel setNumberOfLines:0];
    [promptLabel setText:@"温馨提示：为防止套现和洗钱，每笔充值后需消费30%，剩余金额才可以提现，中奖奖金无限制；\n大额充值请在电脑上登录网址www.sanyi365.com网银支付"];
    [self.view addSubview:promptLabel];
    [promptLabel release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userNameLabel.text = [UserInfo shareUserInfo].userName;
    
    [self loadHandsel];
}

- (void)viewWillAppear:(BOOL)animated {
    _naxfTabBarHiddenState = self.xfTabBarController.tabBarHidden;
    [self.xfTabBarController setTabBarHidden:YES];
    // 充值成功后
    if ([MyAppDelegate shareAppDelegate].isRechargeSuccessful) {
        [MyAppDelegate shareAppDelegate].isRechargeSuccessful = NO;
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *users = [NSMutableDictionary dictionaryWithDictionary:[userdefaults objectForKey:@"userinfo"]];
        double balance = [[NSString stringWithFormat:@"%.2f",[[users objectForKey:@"balance"] doubleValue]] doubleValue];
        double balanceAfterRecharge = balance + [_rechargeTextField.text doubleValue];
        [users setObject:[NSString stringWithFormat:@"%.2f",balanceAfterRecharge] forKey:@"balance"];
        
        [userdefaults setObject:users forKey:@"userinfo"];
        [userdefaults synchronize];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _userNameLabel = nil;
        _rechargeTextField = nil;
        _giftMoneyLabel = nil;
        
        [_orderString release];
        [_signString release];
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [UserInfo shareUserInfo].rechargeMoney = 0.0f;
    [self clearHTTPRequestOfAlixPay];
    [self clearHTTPRequestOfUPPayPlugin];
    [self clearHTTPRequestOfNone];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)getAlixPayRechargeFail:(ASIHTTPRequest *)request {
}

- (void)getAlixPayRechargeFinshed:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];

//    NSString *responseStr = [[NSString alloc]initWithData:request.responseData encoding:NSUTF8StringEncoding];
//    if (responseStr) {
//        NSRange range_content_head = [responseStr rangeOfString:@"<content>"];
//        NSRange range_content_end = [responseStr rangeOfString:@"</content>"];
//        if(range_content_head.location >= responseStr.length || range_content_end.location >= responseStr.length) {
//            [responseStr release];
//            responseStr = nil;
//            return;
//        }
//        
//        NSRange range_content = NSMakeRange(range_content_head.location + range_content_head.length, range_content_end.location - range_content_head.location - range_content_head.length);
//        NSString *content = [responseStr substringWithRange:range_content];
//        
//        NSRange range_sign_head = [responseStr rangeOfString:@"<sign>"];
//        NSRange range_sign_end = [responseStr rangeOfString:@"</sign>"];
//        
//        NSRange range_sign = NSMakeRange(range_sign_head.location + range_sign_head.length, range_sign_end.location - range_sign_head.location - range_sign_head.length);
//        NSString *sign = [responseStr substringWithRange:range_sign];
//        
//        content = [[self class] URLDecodedString:content];
//        if (_orderString != nil) {
//            [_orderString release];
//            _orderString = nil;
//        }
//        _orderString = [content copy];
//        if (_signString != nil) {
//            [_signString release];
//            _signString = nil;
//        }
//        _signString = [sign copy];
//        [self alixPay];
//    }
//    
//    [responseStr release];
}

- (void)getUPPayPluginRechargeFinshed:(ASIHTTPRequest *)request {
    NSString *responseStr = [[NSString alloc]initWithData:request.responseData encoding:NSUTF8StringEncoding];
    NSRange range_sign_head = [responseStr rangeOfString:@"<head>"];
    if (range_sign_head.length > 0) {
        [self hideAlert];
        [self showAlertMessage:@"服务器返回订单数据出错,银联账户绑定域名非本站点"];
        return;
    }
    if (responseStr) {
        _UPPayPluginPayString = [[NSMutableString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
        if (_mAlert != nil) {
            [_mAlert dismissWithClickedButtonIndex:0 animated:YES];
            _mAlert = nil;
        }
        if (_UPPayPluginPayString != nil && _UPPayPluginPayString.length > 0) {
            [UPPayPlugin startPay:_UPPayPluginPayString  mode:@"00" viewController:self delegate:self];
        }
        [_UPPayPluginPayString release];
    }
    [responseStr release];
}

- (void)getUPPayPluginRechargeFail:(ASIHTTPRequest *)request {
    
}

#pragma mark -UPPayPluginDelegate
- (void)UPPayPluginResult:(NSString *)result {
    NSString* msg = [NSString stringWithFormat:kResult, result];
    
    [self showAlertMessage:msg];
}

#pragma mark -UIAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 123 && buttonIndex == 1) {//支付宝
		NSString * URLString = @"http://itunes.apple.com/cn/app/id535715926?mt=8";
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
        
	} else if (alertView.tag == 124 && buttonIndex == 1) { //银联
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController setTabBarHidden:_naxfTabBarHiddenState];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    } else if ([textField.text integerValue] > 100000) {
        [textField setText:@"100000"];
    }
    
    // 初始化当前赠送彩金
    currentHandsel = @"0";
    // 初始化充值最高金额
    _conditionHighest = 0;
    // 初始化最大彩金
    _numerical = 0;
    
    float amount = [textField.text floatValue];
    
//    赠送金额计算方式：
//    定额：
//    1.在后台设定区间内按后面定额数据值进行赠送
//    2.如果超出最高限额 则按最高限额的额度来赠送
//    
//    定比：
//    用户金额 *（金额所在区间的比例）=赚送金额
//    如：用户充值150
//    赠送金额=150*0.1=15
//    
//    如果超出最高限额
//    最高限额*区间比例=赠送金额
//    如：
//    用户充值500
//    赠送金额=400*0.3=120
    
    if (_giveType) {    // 定比
        
        for (int i = 0; i < _activeList.count; i++) {
            
            NSDictionary *schemeD = _activeList[i];
            CGFloat conditionLowest = [[schemeD objectForKey:@"conditionLowest"] floatValue];
            CGFloat conditionHighest = [[schemeD objectForKey:@"conditionHighest"] floatValue];
            NSString *numerical = [schemeD objectForKey:@"numerical"];
            
            // 保存充值最高值赠送彩金
            if (_numerical < [numerical floatValue]) {
                _numerical = [numerical floatValue];
            }
            
            // 保存充值最高值
            if (_conditionHighest < conditionHighest) {
                _conditionHighest = conditionHighest;
            }
            
            if (amount >= conditionLowest && amount <= conditionHighest) {
                
                currentHandsel = [NSString stringWithFormat:@"%.2f", [numerical floatValue] * amount];
            }
        }
        
        if (amount > _conditionHighest) {
            currentHandsel = [NSString stringWithFormat:@"%.2f", _numerical * _conditionHighest];;
        }
        
    }else { // 定额
        
        for (int i = 0; i < _activeList.count; i++) {
            
            NSDictionary *schemeD = _activeList[i];
            CGFloat conditionLowest = [[schemeD objectForKey:@"conditionLowest"] floatValue];
            CGFloat conditionHighest = [[schemeD objectForKey:@"conditionHighest"] floatValue];
            NSString *numerical = [schemeD objectForKey:@"numerical"];
            
            if (_numerical < [numerical floatValue]) {
                _numerical = [numerical floatValue];
            }
            
            if (_conditionHighest < conditionHighest) {
                _conditionHighest = conditionHighest;
            }
            
            if (amount >= conditionLowest && amount <= conditionHighest) {
                
                currentHandsel = numerical;
                NSLog(@"currentHandsel -> %@",currentHandsel);
            }
        }
        
        if (amount > _conditionHighest) {
            currentHandsel = [NSString stringWithFormat:@"%.2f", _numerical];
        }
    }
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">赠送彩金:  </font><font color=\"%@\">%@</font><font color=\"black\"> 元</font>",tRedColorText, currentHandsel];
    
    NSAttributedString *attString =[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize12];
    
    CGSize payMoneyPromptLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize12];
    //    CGRect payMoneyPromptLabelRect = _giftMoneyLabel.frame;
    [_giftMoneyLabel setFrame:CGRectMake(20, 94, payMoneyPromptLabelSize.width, 25)];
    [_giftMoneyLabel setAttString:attString];
    
}

//提交充值
- (void)submitRechargeTouchUpInside:(id)sender {
    [_rechargeTextField resignFirstResponder];
    if ([_rechargeTextField.text integerValue] <= 0  && _rechargeTextField.text.length != 0) {
        [Globals alertWithMessage:@"请正确输入充值金额"];
        return;
    }
    
    CGFloat rechargeMoney = _rechargeTextField.text.length == 0 ? 20 : [_rechargeTextField.text floatValue];
    
    if (rechargeMoney < 20) {
        [Globals alertWithMessage:@"最少充值20元"];
        return;
    }
    
    _rechargeMoney = [NSString stringWithFormat:@"%f",rechargeMoney];
    [UserInfo shareUserInfo].rechargeMoney = rechargeMoney;

    if (_rechargeType == RechargeTypeOfAlixPay) {
        [self clearHTTPRequestOfAlixPay];
        
        
        NSString *uid = [UserInfo shareUserInfo].userID;
        NSString *mon = [NSString stringWithFormat:@"%.1f",rechargeMoney];
        NSString *urlll = [NSString stringWithFormat:@"http://cai.jijiatmall.com/Home/Room/OnlinePay/EcpssYemadaiPay/Send.aspx?id=%@&money=%@",uid,mon];
        PaysuccessViewController *pay = [[PaysuccessViewController alloc]init];
        pay.myurl = urlll;
        [self.navigationController pushViewController:pay animated:YES];

    } else if (_rechargeType == RechargeTypeOfUPPayPlugin) {
        [self clearHTTPRequestOfUPPayPlugin];
        
        _httpRequestOfUPPayPlugin = [[ASIFormDataRequest alloc] initWithURL:[NSURL shoveRechargeURLWithUserId:[UserInfo shareUserInfo].userID money:[NSString stringWithFormat:@"%f",rechargeMoney] rechargeType:RechargeTypeOfUPPayPlugin]];
        [_httpRequestOfUPPayPlugin setPostValue:[UserInfo shareUserInfo].userID forKey:@"uid"];
        [_httpRequestOfUPPayPlugin setPostValue:[NSNumber numberWithFloat:rechargeMoney] forKey:@"payMoney"];
        [_httpRequestOfUPPayPlugin setDidFinishSelector:@selector(getUPPayPluginRechargeFinshed:)];
        [_httpRequestOfUPPayPlugin setDidFailSelector:@selector(getUPPayPluginRechargeFail:)];
        [_httpRequestOfUPPayPlugin setDelegate:self];
        [_httpRequestOfUPPayPlugin startAsynchronous];
        [self showAlertWait];
        
    }else if (_rechargeType == RechargeTypeOfNone) {//微信
        [self clearHTTPRequestOfNone];
        
        [SVProgressHUD showWithStatus:@"加载中"];
        
        _httpRequestOfNone = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://zjzxs.test.shovesoft.net/Home/Room/OnlinePay/WFTpay/Index.aspx?payMoney=%f&uid=%ld&terminal=MOVE",[_rechargeTextField.text floatValue] == 0 ? 1.0 : [_rechargeTextField.text floatValue],(long)[[UserInfo shareUserInfo].userID integerValue]]]];
        [_httpRequestOfNone setDidFailSelector:@selector(weixinFaild:)];
        [_httpRequestOfNone setDidFinishSelector:@selector(weixinFinish:)];
        [_httpRequestOfNone setDelegate:self];
        [_httpRequestOfNone startAsynchronous];
        
    }
    
}

- (void)weixinFaild:(ASIFormDataRequest *)request{
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

- (void)weixinFinish:(ASIFormDataRequest *)request{
    NSDictionary *dic = [[request responseString] objectFromJSONString];
    NSLog(@"---weixin--:\n%@",[request responseString]);
    
    if (dic) {
        [SVProgressHUD showSuccessWithStatus:@"加载成功"];
        
        WeixinpayViewController *weixin = [[WeixinpayViewController alloc] init];
        [weixin setUrlString:[dic objectForKey:@"code_img_url"]];
        [self.navigationController pushViewController:weixin animated:YES];
        [weixin release];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"加载失败"];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark -Customized: Private (General)
- (void)clearHTTPRequestOfAlixPay {
    if (_httpRequestOfAlixPay != nil) {
        [_httpRequestOfAlixPay clearDelegatesAndCancel];
        [_httpRequestOfAlixPay release];
        _httpRequestOfAlixPay = nil;
    }
}

- (void)clearHTTPRequestOfUPPayPlugin {
    if (_httpRequestOfUPPayPlugin != nil) {
        [_httpRequestOfUPPayPlugin clearDelegatesAndCancel];
        [_httpRequestOfUPPayPlugin release];
        _httpRequestOfUPPayPlugin = nil;
    }
}

- (void)clearHTTPRequestOfNone {
    if (_httpRequestOfNone != nil) {
        [_httpRequestOfNone clearDelegatesAndCancel];
        [_httpRequestOfNone release];
        _httpRequestOfNone = nil;
    }
}

+ (NSString *)URLDecodedString:(NSString*)stringURL{
    return (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)stringURL, CFSTR(""), kCFStringEncodingUTF8);
}

//支付宝安全支付
- (void)alixPay {
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"RSA\"", _orderString, _signString];
    
    //获取安全支付单例并调用安全支付接口
    
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:kApplicationScheme callback:^(NSDictionary *resultDic) {
        NSInteger resultStatus = [resultDic intValueForKey:@"resultStatus"];
         if (resultStatus == 9000) {
             
             CGFloat rechargeMoney = [UserInfo shareUserInfo].rechargeMoney;
             CGFloat balance = [[UserInfo shareUserInfo].balance floatValue];
             [[UserInfo shareUserInfo] setBalance:[NSString stringWithFormat:@"%.2f",(rechargeMoney + balance)]];
             
             // 保存到NSUserDefaults
             NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
             [userinfo setObject:[UserInfo shareUserInfo].balance forKey:@"balance"];
             [[NSUserDefaults standardUserDefaults]setObject:userinfo forKey:@"userinfo"];
             [[NSUserDefaults standardUserDefaults]synchronize];
             [Globals alertWithMessage:@"订单支付成功"];
             
         } else if (resultStatus == 8000) {
             [Globals alertWithMessage:@"正在处理中"];
         } else if (resultStatus == 4000) {
             [Globals alertWithMessage:@"订单支付失败"];
         } else if (resultStatus == 6001) {
             [Globals alertWithMessage:@"用户中途取消支付"];
         } else if (resultStatus == 6002) {
             [Globals alertWithMessage:@"网络连接出错"];
         }
    }];
}

- (void)showAlertMessage:(NSString*)msg {
    
    if([msg hasSuffix:@"success"]){
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *users = [NSMutableDictionary dictionaryWithDictionary:[userdefaults objectForKey:@"userinfo"]];
        double balance = [[NSString stringWithFormat:@"%.2f",[[users objectForKey:@"balance"] doubleValue]] doubleValue];
        double balanceAfterRecharge = balance + [_rechargeMoney doubleValue];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%.2f",balanceAfterRecharge];
        [users setObject:[NSString stringWithFormat:@"%.2f",balanceAfterRecharge] forKey:@"balance"];
        
        [userdefaults setObject:users forKey:@"userinfo"];
        [userdefaults synchronize];
    }
    
    if([msg hasSuffix:@"success"]){
        msg = @"支付成功";
    } else if ([msg hasSuffix:@"cancel"]){
        msg = @"用户取消支付";
    } else if (msg.length == 0){
        msg = @"支付失败";
    }
    _mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [_mAlert setTag:124];
    [_mAlert show];
    [_mAlert release];
}


- (void)showAlertWait {
    _mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [_mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(_mAlert.frame.size.width / 2.0f - 15, _mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [_mAlert addSubview:aiv];
    [aiv release];
    [_mAlert release];
}

- (void)hideAlert {
    if (_mAlert != nil) {
        [_mAlert dismissWithClickedButtonIndex:0 animated:YES];
        _mAlert = nil;
    }
}

//获取银行信息
- (void)loadHandsel {
    [self clearLoadHandselRequest];
    
    _loadHandselRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetHandsel userId:[UserInfo shareUserInfo].userID infoDict:nil]];
    [_loadHandselRequest setDelegate:self];
    [_loadHandselRequest startAsynchronous];
}

- (void)clearLoadHandselRequest {
    if (_loadHandselRequest != nil) {
        [_loadHandselRequest clearDelegatesAndCancel];
        [_loadHandselRequest release];
        _loadHandselRequest = nil;
    }
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if(responseDic && [[responseDic objectForKey:@"isSuccess"] integerValue] == 1) {
        
        NSArray *dataArr = [responseDic objectForKey:@"activeList"];
        _activeList = [dataArr mutableCopy];
       
        _giveType = [[responseDic objectForKey:@"giveType"] integerValue];
        NSLog(@"_activeList -> %lu", (unsigned long)_activeList.count);
        
        if (_activeList.count == 0) {
            NSLog(@"暂无彩金奖励");
            _giftMoneyLabel.hidden = YES;
        }
    }
}

@end
