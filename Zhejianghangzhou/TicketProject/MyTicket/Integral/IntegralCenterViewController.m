//
//  IntegralCenterViewController.m  积分中心  (整体滑动是晓洁要干的)
//  TicketProject
//
//  Created by KAI on 15-4-18.
//  Copyright (c) 2015年 sls002. All rights reserved.
//
//  20150820 10:47（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "IntegralCenterViewController.h"
#import "CircleBtn.h"
#import "IntegralDetailViewController.h"
#import "IntegralExchangeViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "UserInfo.h"

#define kIntegralRuleLabelMaginBottom (IS_PHONE ? 20.0f : 200.0f)

#pragma mark -
#pragma mark @implementation IntegralCenterViewController
@implementation IntegralCenterViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"积分中心"];
    }
    return self;
}

- (void)dealloc {
    _circleBtn = nil;
    _accumulatePromptLabel = nil;
    _integralRuleScrollView = nil;
    _integralRuleLabel = nil;
    
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
    CGFloat circleBtnMinY = IS_PHONE ? 5.0f : 10.0f;
    CGSize circleBtnSize = IS_PHONE ? CGSizeMake(80.0f, 80.0f) : CGSizeMake(180.0f, 180.0f);

    CGFloat promptIntegralLabelHeight = IS_PHONE ? 21.0f : 50.0f;
    
    CGFloat accumulatePromptLabelMaginCircleBtnY = 7.0f;
    
    CGFloat lineMaginAccumulatePromptLabelY = 10.0f;
    
    CGFloat exchangeIntegralBtnWidth = IS_PHONE ? 240.0f : 500.0f;
    CGFloat exchangeIntegralBtnHeight = IS_PHONE ? 40.0f : 70.0f;
    CGFloat btnVerticalInterval = IS_PHONE ? 15.0f : 45.0f;
    
    CGFloat integralRuleLabelMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat integralRuleLabelMinY = IS_PHONE ? 10.0f : 30.0f;
    /********************** adjustment end ***************************/
    //integralRuleScrollView
    CGRect integralRuleScrollViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f);
    _integralRuleScrollView = [[UIScrollView alloc] initWithFrame:integralRuleScrollViewRect];
    [_integralRuleScrollView setBackgroundColor:[UIColor clearColor]];
    [_integralRuleScrollView setScrollEnabled:YES];
    [self.view addSubview:_integralRuleScrollView];
    [_integralRuleScrollView release];
    
    //circleBtn
    CGRect circleBtnRect = CGRectMake((CGRectGetWidth(appRect) - circleBtnSize.width) / 2.0f, circleBtnMinY, circleBtnSize.width, circleBtnSize.height);
    _circleBtn = [[CircleBtn alloc] initWithFrame:circleBtnRect];
    [_circleBtn addTarget:self action:@selector(integralDetailTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_integralRuleScrollView addSubview:_circleBtn];
    [_circleBtn release];
    
    //accumulatePromptLabel 按钮下积分提示
    CGRect accumulatePromptLabelRect = CGRectMake(0, CGRectGetMaxY(circleBtnRect) + accumulatePromptLabelMaginCircleBtnY, CGRectGetWidth(appRect), promptIntegralLabelHeight);
    _accumulatePromptLabel = [[UILabel alloc] initWithFrame:accumulatePromptLabelRect];
    [_accumulatePromptLabel setBackgroundColor:[UIColor clearColor]];
    [_accumulatePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_accumulatePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_accumulatePromptLabel setTextColor:kGrayColor];
    [_accumulatePromptLabel setMinimumScaleFactor:0.75];
    [_accumulatePromptLabel setAdjustsFontSizeToFitWidth:YES];
    [_accumulatePromptLabel setText:[self getIntegralDetailPrompt]];
    [_integralRuleScrollView addSubview:_accumulatePromptLabel];
    [_accumulatePromptLabel release];
    
    //lineView
    CGRect lineViewRect = CGRectMake(0, CGRectGetMaxY(accumulatePromptLabelRect) + lineMaginAccumulatePromptLabelY, CGRectGetWidth(appRect), AllLineWidthOrHeight);
    UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
    [lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine3.png"]]]];
    [_integralRuleScrollView addSubview:lineView];
    [lineView release];
    
    //exchangeIntegralBtn
    CGRect exchangeIntegralBtnRect = CGRectMake((CGRectGetWidth(appRect) - exchangeIntegralBtnWidth) / 2.0f, CGRectGetMaxY(lineViewRect) + btnVerticalInterval, exchangeIntegralBtnWidth, exchangeIntegralBtnHeight);
    UIButton *exchangeIntegralBtn = [[UIButton alloc] initWithFrame:exchangeIntegralBtnRect];
    [exchangeIntegralBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [exchangeIntegralBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [exchangeIntegralBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [exchangeIntegralBtn setTitle:@"积分兑换" forState:UIControlStateNormal];
    [exchangeIntegralBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redLineButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [exchangeIntegralBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [exchangeIntegralBtn addTarget:self action:@selector(integralExchangeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_integralRuleScrollView addSubview:exchangeIntegralBtn];
    [exchangeIntegralBtn release];
    
    //integralDetailBtn
    CGRect integralDetailBtnRect = CGRectMake(CGRectGetMinX(exchangeIntegralBtnRect), CGRectGetMaxY(exchangeIntegralBtnRect) + btnVerticalInterval, exchangeIntegralBtnWidth, exchangeIntegralBtnHeight);
    UIButton *integralDetailBtn = [[UIButton alloc] initWithFrame:integralDetailBtnRect];
    [integralDetailBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [integralDetailBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [integralDetailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [integralDetailBtn setTitle:@"积分明细" forState:UIControlStateNormal];
    [integralDetailBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redLineButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [integralDetailBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [integralDetailBtn addTarget:self action:@selector(integralDetailTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_integralRuleScrollView addSubview:integralDetailBtn];
    [integralDetailBtn release];
    
    //integralRuleLabel 有问题  看能不能改
    CGRect integralRuleLabelRect = CGRectMake(integralRuleLabelMinX, CGRectGetMaxY(integralDetailBtnRect) + integralRuleLabelMinY, CGRectGetWidth(integralRuleScrollViewRect) - integralRuleLabelMinX * 2, CGRectGetHeight(integralRuleScrollViewRect) - integralRuleLabelMinY);
    _integralRuleLabel = [[CustomLabel alloc] initWithFrame:integralRuleLabelRect];
    [_integralRuleLabel setBackgroundColor:[UIColor clearColor]];
    [_integralRuleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_integralRuleLabel setNumberOfLines:100];
    [_integralRuleScrollView addSubview:_integralRuleLabel];
    [_integralRuleLabel release];
}

- (void)viewDidLoad {
    [self.xfTabBarController  setTabBarHidden:YES];
    [self fillIntegralRule];
    [self httpRequest];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fillIntegralLabel];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"连接失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"查询成功"];
    
    NSDictionary *responseDict = [[request responseString] objectFromJSONString];
    if(responseDict && [[responseDict objectForKey:@"error"] isEqualToString:@"0"]) {
        
        [UserInfo shareUserInfo].surplusIntegral = [responseDict intValueForKey:@"currentScoring"];//剩余积分，当前积分
        [UserInfo shareUserInfo].totalIntegral = [responseDict intValueForKey:@"totalScoring"];//总积分
        [UserInfo shareUserInfo].exchangeIntegral = [responseDict intValueForKey:@"totalConversionScoring"];//兑换积分
        [UserInfo shareUserInfo].scoringExchangerate = [responseDict floatValueForKey:@"scoringExchangerate"];//兑换比例
        [UserInfo shareUserInfo].optScoringOfSelfBuy = [responseDict floatValueForKey:@"optScoringOfSelfBuy"];//购彩一元获得的积分
        [self fillIntegralLabel];
        [self fillIntegralRule];
        
    } else {
        [XYMPromptView showInfo:[responseDict objectForKey:@"msg"] bgColor:[UIColor blackColor].CGColor inView:[(AppDelegate *)[UIApplication sharedApplication].delegate window] isCenter:NO vertical:1];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)integralExchangeTouchUpInside:(id)sender {
    IntegralExchangeViewController *integralExchangeViewController = [[IntegralExchangeViewController alloc] init];
    [self.navigationController pushViewController:integralExchangeViewController animated:YES];
    [integralExchangeViewController release];
}

- (void)integralDetailTouchUpInside:(id)sender {
    IntegralDetailViewController *integralDetailViewController = [[IntegralDetailViewController alloc] init];
    [self.navigationController pushViewController:integralDetailViewController animated:YES];
    [integralDetailViewController release];
}

- (NSString *)getIntegralDetailPrompt {
    return [NSString stringWithFormat:@"累计获得积分：%ld分     累计兑换积分：%ld分",(long)[UserInfo shareUserInfo].totalIntegral, (long)[UserInfo shareUserInfo].exchangeIntegral];
}

- (void)httpRequest {
    [SVProgressHUD showWithStatus:@"正在请求数据中"];
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetIntegral userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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

- (void)fillIntegralLabel {
    [_circleBtn setIntegral:[UserInfo shareUserInfo].surplusIntegral];
    [_accumulatePromptLabel setText:[self getIntegralDetailPrompt]];
}

- (void)fillIntegralRule {
    NSAttributedString *integralRuleString = [self integralRuleTextWithFontSize:XFIponeIpadFontSize12];
    
    CGRect attStringRect;
    if (IS_IOS7) {
        attStringRect = [integralRuleString boundingRectWithSize:CGSizeMake(CGRectGetWidth(_integralRuleLabel.frame), NSIntegerMax) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    } else {
        CGSize textSize = [[self integralRuleNormalText] sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12] constrainedToSize:CGSizeMake(CGRectGetWidth(_integralRuleLabel.frame), NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
        attStringRect = CGRectMake(0, 0, textSize.width, textSize.height);
    }
    
    
    CGFloat integralRuleLabelHeight = CGRectGetHeight(attStringRect) + kIntegralRuleLabelMaginBottom;
    CGRect integralRuleLabelRect = CGRectMake(CGRectGetMinX(_integralRuleLabel.frame), CGRectGetMinY(_integralRuleLabel.frame), attStringRect.size.width, integralRuleLabelHeight);
    [_integralRuleLabel setFrame:integralRuleLabelRect];
    [_integralRuleLabel setAttString:integralRuleString];
    
    
    [_integralRuleScrollView setContentSize:CGSizeMake(0, integralRuleLabelHeight + CGRectGetMinY(integralRuleLabelRect))];
}

- (void)getScoringOfSelfBuyAndScoringExchangerate {
    CGFloat scoringExchangerate = [UserInfo shareUserInfo].scoringExchangerate;
    NSInteger optScoringOfSelfBuy = [UserInfo shareUserInfo].optScoringOfSelfBuy;
    _optScoringOfSelfBuy = optScoringOfSelfBuy == 0 ? 1 : optScoringOfSelfBuy;
    _scoringExchangerate = scoringExchangerate == 0 ? 100.0f : scoringExchangerate;
}

- (NSAttributedString *)integralRuleTextWithFontSize:(CGFloat)fontSize {
    [self getScoringOfSelfBuyAndScoringExchangerate];
    NSString *textExchangeIntegral = [NSString stringWithFormat:@"%ld",(long)(_scoringExchangerate)];
    
    NSString *colorText = [NSString stringWithFormat:@"<font color=\"888474\">我的积分规则:\n1. 我的积分是对用户参与本站彩票代购、合买进行奖励的积分机制。\n\n2. 我的购彩积分：\n在本站参与代购、合买彩票的用户，每成功购买满 1 元（撤单、方案未成功不积分），积 </font><font color=\"%@\">%ld</font><font color=\"888474\"> 分，单次投注不满 1 元不积分。\n\n3.我的中奖积分：\n本站后台根据不同彩种以及不同玩法设置了一定的积分比例，代购或者参与合买的用户，将根据奖金的金额比例获得对应的积分。\n\n4.积分兑换：\n积分满 </font><font color=\"%@\">%@</font><font color=\"888474\"> 分，用户可以进行积分兑换，兑换以 </font><font color=\"%@\">%@</font><font color=\"888474\"> 分为一个兑换单位，超过 </font><font color=\"%@\">%@</font><font color=\"888474\"> 分兑换奖励的用户，兑换积分必须是 </font><font color=\"%@\">%@</font><font color=\"888474\"> 的整数倍，不够 </font><font color=\"%@\">%@</font><font color=\"888474\"> 分不能兑换。</font><font color=\"%@\">%@</font><font color=\"888474\"> 分兑换 1 元，兑换后此款项自动增加到用户的可用资金中，但不能对积分兑换的金额进行提款。</font>",tRedColorText, (long)_optScoringOfSelfBuy, tRedColorText, textExchangeIntegral, tRedColorText, textExchangeIntegral, tRedColorText, textExchangeIntegral, tRedColorText, textExchangeIntegral, tRedColorText, textExchangeIntegral, tRedColorText, textExchangeIntegral];
    
    MarkupParser *p = [[MarkupParser alloc]initWithFontSize:fontSize];
    NSAttributedString *attString = [p attrStringFromMarkup:colorText];
    [p release];
    
    return attString;
}

- (NSString *)integralRuleNormalText {
    [self getScoringOfSelfBuyAndScoringExchangerate];
    NSString *textExchangeIntegral = [NSString stringWithFormat:@"%ld",(long)(_scoringExchangerate)];
    
    NSString *text = [NSString stringWithFormat:@"我的积分规则:\n1. 我的积分是对用户参与本站彩票代购、合买进行奖励的积分机制。\n\n2. 我的购彩积分：\n在本站参与代购、合买彩票的用户，每成功购买满 1 元（撤单、方案未成功不积分），积 %ld 分，单次投注不满 1 元不积分。\n\n3.我的中奖积分：\n本站后台根据不同彩种以及不同玩法设置了一定的积分比例，代购或者参与合买的用户，将根据奖金的金额比例获得对应的积分。\n\n4.积分兑换：\n积分满 %@ 分，用户可以进行积分兑换，兑换以 %@ 分为一个兑换单位，超过 %@ 分兑换奖励的用户，兑换积分必须是 %@ 的整数倍，不够 %@< 分不能兑换。%@ 分兑换 1 元，兑换后此款项自动增加到用户的可用资金中，但不能对积分兑换的金额进行提款。",(long)_optScoringOfSelfBuy, textExchangeIntegral, textExchangeIntegral, textExchangeIntegral, textExchangeIntegral, textExchangeIntegral,  textExchangeIntegral];
    return text;
}

@end
