//
//  PaySucceedViewController.m
//  TicketProject
//
//  Created by KAI on 14-11-28.
//  Copyright (c) 2014年 sls002. All rights reserved.
//
//  20150819 10:32（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "PaySucceedViewController.h"
#import "BasketBallViewController.h"
#import "ChaseDetailViewController.h"
#import "ChippedDetailViewController.h"
#import "FootBallViewController.h"
#import "LuckyPickViewController.h"
#import "SFCViewController.h"
#import "RJXViewController.h"
#import "TicketsDetailViewController.h"
#import "SVProgressHUD.h"
#import "SingleViewController.h"

#import "InterfaceHelper.h"
#import "CustomResultParser.h"
#import "Globals.h"
#import "MyTool.h"
#import "UserInfo.h"

#import "GlobalsProject.h"

@interface PaySucceedViewController ()

@end

#pragma mark -
#pragma mark @implementation PaySucceedViewController
@implementation PaySucceedViewController
@synthesize paySucceedViewType = _paySucceedViewType;
#pragma mark Lifecircle

- (id)initWithDict:(NSMutableDictionary *)dict buyType:(OrderStatus)buyType {
    self = [super init];
    if (self) {
        _status = buyType;
        _originalDict = [dict retain];
        _orderDetailDict = [[NSMutableDictionary alloc] init];
        [_orderDetailDict addEntriesFromDictionary:_originalDict];
        
        _lotteryId = [_orderDetailDict intValueForKey:@"lotteryId"];
        [self setTitle:@"付款成功"];
        
        if (buyType == CHASED) {
            _orderId = [[dict objectForKey:@"chasetaskids"] integerValue];
        } else {
            _orderId = [[dict objectForKey:@"schemeids"] integerValue];
        }
    }
    return self;
}

- (void)dealloc {
    [_orderDetailDict release];
    [_checkOrderDetailArray release];
    _checkOrderDetailArray = nil;
    [super dealloc];
}

- (void)loadView {
    [self.tabBarController.tabBar setHidden:YES];
    
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
	[baseView release];
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat paySuccessLogoMinY = IS_PHONE ? 23.0f : 40.0f;
    CGFloat paySuccessLogoWidth = IS_PHONE ? 76.0f : 130.0f;
    CGFloat paySuccessLogoHeight = IS_PHONE ? 75.0f : 128.5f;
    
    CGFloat payMoneyPromptLabelAddY = IS_PHONE ? 20.0f : 40.0f;
    CGFloat residualAmountLabelAddY = IS_PHONE ? 20.0f : 40.0f;
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
    
    //payPromptLabel
    CGRect payPromptLabelRect = CGRectMake(0, CGRectGetMaxY(paySuccessLogoImageViewRect) + payPromptLabelAddY, CGRectGetWidth(appRect), allLabelHeight);
    UILabel *payPromptLabel = [[UILabel alloc] initWithFrame:payPromptLabelRect];
    [payPromptLabel setBackgroundColor:[UIColor clearColor]];
    [payPromptLabel setText:@"你已成功付款，请关注方案出票状态"];
    [payPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
    [payPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:payPromptLabel];
    [payPromptLabel release];
    
    //payMoneyPromptLabel
    CGRect payMoneyPromptLabelRect = CGRectMake(0, CGRectGetMaxY(payPromptLabelRect) + payMoneyPromptLabelAddY, CGRectGetWidth(appRect), allLabelHeight);
    _payMoneyPromptLabel = [[CustomLabel alloc] initWithFrame:payMoneyPromptLabelRect];
    [_payMoneyPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_payMoneyPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.view addSubview:_payMoneyPromptLabel];
    [_payMoneyPromptLabel release];
    
    //residualAmountLabel
    CGRect residualAmountLabelRect = CGRectMake(0, CGRectGetMaxY(payMoneyPromptLabelRect) + residualAmountLabelAddY, CGRectGetWidth(appRect), allLabelHeight);
    _residualAmountLabel = [[CustomLabel alloc] initWithFrame:residualAmountLabelRect];
    [_residualAmountLabel setBackgroundColor:[UIColor clearColor]];
    [_residualAmountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.view addSubview:_residualAmountLabel];
    [_residualAmountLabel release];
    
    //residualHandselLabel
    CGRect residualHandselLabelRect = CGRectMake(0, CGRectGetMaxY(residualAmountLabelRect) + residualAmountLabelAddY, CGRectGetWidth(appRect), allLabelHeight);
    _residualHandselLabel = [[CustomLabel alloc] initWithFrame:residualHandselLabelRect];
    [_residualHandselLabel setBackgroundColor:[UIColor clearColor]];
    [_residualHandselLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self.view addSubview:_residualHandselLabel];
    [_residualHandselLabel release];
    
    //betDetailBtn
    CGRect betDetailBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(residualHandselLabelRect) + firstBtnAddY, btnWidth, btnHeight);
    UIButton *betDetailBtn = [[UIButton alloc] initWithFrame:betDetailBtnRect];
    [betDetailBtn setTitle:@"查看投注详情" forState:UIControlStateNormal];
    [betDetailBtn setTitle:@"查看投注详情" forState:UIControlStateHighlighted];
    [betDetailBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [betDetailBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [betDetailBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [betDetailBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [betDetailBtn addTarget:self action:@selector(detailTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:betDetailBtn];
    [betDetailBtn release];
    
    //continueBetBtn
    CGRect continueBetBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(betDetailBtnRect) + otherBtnAddY, btnWidth, btnHeight);
    UIButton *continueBetBtn = [[UIButton alloc] initWithFrame:continueBetBtnRect];
    [continueBetBtn setTitle:@"继续投注" forState:UIControlStateNormal];
    [continueBetBtn setTitle:@"继续投注" forState:UIControlStateHighlighted];
    [continueBetBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [continueBetBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [continueBetBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [continueBetBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [continueBetBtn addTarget:self action:@selector(continueBetTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueBetBtn];
    [continueBetBtn release];
    
    //goBackBtn
    CGRect goBackBtnRect = CGRectMake((CGRectGetWidth(appRect) - btnWidth) / 2.0f, CGRectGetMaxY(continueBetBtnRect) + otherBtnAddY, btnWidth, btnHeight);
    UIButton *goBackBtn = [[UIButton alloc] initWithFrame:goBackBtnRect];
    [goBackBtn setTitle:@"返回首页" forState:UIControlStateNormal];
    [goBackBtn setTitle:@"返回首页" forState:UIControlStateHighlighted];
    [goBackBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateNormal];
    [goBackBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    [goBackBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [goBackBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"separateButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [goBackBtn addTarget:self action:@selector(goBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goBackBtn];
    [goBackBtn release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    
    _checkOrderDetailArray = [[NSMutableArray alloc] init];
    
    [self fillViewText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _pushView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)orderDetailRequestFinish:(ASIHTTPRequest *)request {
    _pushView = NO;
    [SVProgressHUD dismiss];
    
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        [_checkOrderDetailArray removeAllObjects];
        NSArray *tmpSchemeList;
        if (_status == CHASED) {
            tmpSchemeList = [responseDic objectForKey:@"chaseTaskDetailsList"];
        } else {
            tmpSchemeList = [responseDic objectForKey:@"schemeList"];
        }
        
        NSInteger timeInt = [Globals timeConvertToIndegerWithStringWithStringTime:[responseDic stringForKey:@"serverTime"] beforeMonth:3];
        
        if (_status == CHASED) {
            [CustomResultParser parseResult:tmpSchemeList withChaseOrderArray:_checkOrderDetailArray timeInt:timeInt];
        } else {
            [CustomResultParser parseResult:tmpSchemeList withNormalOrderArray:_checkOrderDetailArray timeInt:timeInt];
        }
        
        for (NSDictionary *dic in _checkOrderDetailArray) {
            NSArray *dateDetail;
            if (_status == CHASED) {
                dateDetail = [dic objectForKey:@"chaseTaskDetail"];
            } else {
                dateDetail = [dic objectForKey:@"dateDetail"];
            }
            
            if (_status == NORMAL && [dateDetail isKindOfClass:[NSArray class]] && [dateDetail count] > 0) {
                for (NSDictionary *dict in dateDetail) {
                    if (_orderId == [[dict objectForKey:@"ID"] integerValue]) {
                        [_orderDetailDict removeAllObjects];
                        [_orderDetailDict addEntriesFromDictionary:dict];
                        break;
                    }
                }
                
            } else if (_status == CHASED && [dateDetail isKindOfClass:[NSArray class]] && [dateDetail count] > 0) {
                for (NSDictionary *dict in dateDetail) {
                    if (_orderId == [[dict objectForKey:@"ID"] integerValue]) {
                        [_orderDetailDict removeAllObjects];
                        [_orderDetailDict addEntriesFromDictionary:_originalDict];
                        [_orderDetailDict addEntriesFromDictionary:dict];
                        break;
                    }
                }
                
            } else if (_status == CHIPPED && [dateDetail isKindOfClass:[NSArray class]] && [dateDetail count] > 0) {
                for (NSDictionary *dict in dateDetail) {
                    if (_orderId == [[dict objectForKey:@"ID"] integerValue]) {
                        [_orderDetailDict removeAllObjects];
                        [_orderDetailDict addEntriesFromDictionary:dict];
                        break;
                    }
                }
            }
        }
        
        if (_status == NORMAL) {
            if ([_orderDetailDict count] > 0) {
                NSInteger lotteryID = 0;
                if ([_orderDetailDict objectForKey:@"lotteryId"]) {
                    lotteryID = [_orderDetailDict intValueForKey:@"lotteryId"];
                } else if ([_orderDetailDict objectForKey:@"lotteryID"]) {
                    lotteryID = [_orderDetailDict intValueForKey:@"lotteryID"];
                }
                
                
                TicketsDetailViewController  *detailViewController = [[TicketsDetailViewController alloc] initWithInfoDic:_orderDetailDict withLotteryID:lotteryID orderStatus:NORMAL];
                [self.navigationController pushViewController:detailViewController animated:YES];
                [detailViewController release];
            }
        } else if (_status == CHASED) {
            if ([_orderDetailDict count] > 0) {
                ChaseDetailViewController  *detailViewController = [[ChaseDetailViewController alloc] initWithInfoDic:_orderDetailDict indexPage:BetRecordTypeOfChase];
                [self.navigationController pushViewController:detailViewController animated:YES];
                [detailViewController release];
            }
        } else if (_status == CHIPPED) {
            if ([_orderDetailDict count] > 0) {
                ChippedDetailViewController *detailViewController = [[ChippedDetailViewController alloc] initWithInfoDic:_orderDetailDict];
                [self.navigationController pushViewController:detailViewController animated:YES];
                [detailViewController release];
            }
        }
        
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
    
}

- (void)orderDetailRequestFail:(ASIHTTPRequest *)request {
    _pushView = NO;
    [SVProgressHUD showErrorWithStatus:@"查询失败"];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)detailTouchUpInside:(id)sender {
    if (_pushView) {
        return;
    }
    _pushView = YES;
    [SVProgressHUD showWithStatus:@"数据加载中"];
    
    [self requestOrderDetail];
}

- (void)continueBetTouchUpInside:(id)sender {
    if (_pushView) {
        return;
    }
    
    if ([self.navigationController.viewControllers count] > 1) {
        if ([[_orderDetailDict stringForKey:@"isLuckyNumber"] isEqualToString:@"YES"]) {
            LuckyPickViewController *luckyPickViewController = (LuckyPickViewController *)[self.navigationController.viewControllers objectAtIndex:1];
            if (luckyPickViewController && [luckyPickViewController isKindOfClass:[LuckyPickViewController class]]) {
                [self.navigationController popToViewController:luckyPickViewController animated:YES];
                _pushView = YES;
            }
            
            
        } else if (_lotteryId == 72) {
            FootBallViewController *footBallViewController = (FootBallViewController *)[self.navigationController.viewControllers objectAtIndex:1];
            if (footBallViewController && [footBallViewController isKindOfClass:[FootBallViewController class]]) {
                [footBallViewController clearAllTouchUpInside:@""];//直接调用点击事件，反正没用到按钮
                UIView *midView = footBallViewController.navigationItem.titleView;
                UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                midBtn.enabled = YES;
                [self.navigationController popToViewController:footBallViewController animated:YES];
                _pushView = YES;
            } else if ([self.navigationController.viewControllers count] >= 4) {
                footBallViewController = (FootBallViewController *)[self.navigationController.viewControllers objectAtIndex:3];
                if (footBallViewController && [footBallViewController isKindOfClass:[FootBallViewController class]]) {
                    [footBallViewController clearAllTouchUpInside:@""];//直接调用点击事件，反正没用到按钮
                    UIView *midView = footBallViewController.navigationItem.titleView;
                    UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                    midBtn.enabled = YES;
                    [self.navigationController popToViewController:footBallViewController animated:YES];
                    _pushView = YES;
                }
            }
        
            
        } else if (_lotteryId == 45) {
            SingleViewController *singleViewController = (SingleViewController *)[self.navigationController.viewControllers objectAtIndex:1];
            if (singleViewController && [singleViewController isKindOfClass:[SingleViewController class]]) {
                [singleViewController clearAllTouchUpInside:@""];//直接调用点击事件，反正没用到按钮
                UIView *midView = singleViewController.navigationItem.titleView;
                UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                midBtn.enabled = YES;
                [self.navigationController popToViewController:singleViewController animated:YES];
                _pushView = YES;
            } else if ([self.navigationController.viewControllers count] >= 4) {
                singleViewController = (SingleViewController *)[self.navigationController.viewControllers objectAtIndex:3];
                if (singleViewController && [singleViewController isKindOfClass:[SingleViewController class]]) {
                    [singleViewController clearAllTouchUpInside:@""];//直接调用点击事件，反正没用到按钮
                    UIView *midView = singleViewController.navigationItem.titleView;
                    UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                    midBtn.enabled = YES;
                    [self.navigationController popToViewController:singleViewController animated:YES];
                    _pushView = YES;
                }
            }
            
            
        } else if (_lotteryId == 73) {
            BasketBallViewController *basketBallViewController = (BasketBallViewController *)[self.navigationController.viewControllers objectAtIndex:1];
            if (basketBallViewController && [basketBallViewController isKindOfClass:[BasketBallViewController class]]) {
                [basketBallViewController clearAllTouchUpInside:@""];
                UIView *midView = basketBallViewController.navigationItem.titleView;
                UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                midBtn.enabled = YES;
                [self.navigationController popToViewController:basketBallViewController animated:YES];
                _pushView = YES;
            } else if ([self.navigationController.viewControllers count] >= 4) {
                basketBallViewController = (BasketBallViewController *)[self.navigationController.viewControllers objectAtIndex:3];
                if (basketBallViewController && [basketBallViewController isKindOfClass:[BasketBallViewController class]]) {
                    [basketBallViewController clearAllTouchUpInside:@""];
                    UIView *midView = basketBallViewController.navigationItem.titleView;
                    UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                    midBtn.enabled = YES;
                    [self.navigationController popToViewController:basketBallViewController animated:YES];
                    _pushView = YES;
                }
            }
            
            
        } else if (_lotteryId == 74) {
            SFCViewController *sfcViewController = (SFCViewController *)[self.navigationController.viewControllers objectAtIndex:1];
            if (sfcViewController && [sfcViewController isKindOfClass:[SFCViewController class]]) {
                [sfcViewController clearBalls];
                [self.navigationController popToViewController:sfcViewController animated:YES];
                _pushView = YES;
            } else if ([self.navigationController.viewControllers count] >= 4) {
                sfcViewController = (SFCViewController *)[self.navigationController.viewControllers objectAtIndex:3];
                if (sfcViewController && [sfcViewController isKindOfClass:[SFCViewController class]]) {
                    [sfcViewController clearBalls];
                    [self.navigationController popToViewController:sfcViewController animated:YES];
                    _pushView = YES;
                }
            }
            
            
        } else if (_lotteryId == 75) {
            RJXViewController *rjxViewController = (RJXViewController *)[self.navigationController.viewControllers objectAtIndex:1];
            if (rjxViewController && [rjxViewController isKindOfClass:[RJXViewController class]]) {
                [rjxViewController clearBalls];
                [self.navigationController popToViewController:rjxViewController animated:YES];
                _pushView = YES;
            } else if ([self.navigationController.viewControllers count] >= 4) {
                rjxViewController = (RJXViewController *)[self.navigationController.viewControllers objectAtIndex:3];
                if (rjxViewController && [rjxViewController isKindOfClass:[RJXViewController class]]) {
                    [rjxViewController clearBalls];
                    [self.navigationController popToViewController:rjxViewController animated:YES];
                    _pushView = YES;
                }
            }
            
            
        } else {
            BOOL hasBaseView = NO;
            for (BaseSelectViewController *baseSelectViewController in self.navigationController.viewControllers) {
                if (baseSelectViewController && [baseSelectViewController isKindOfClass:[BaseSelectViewController class]]) {
                    baseSelectViewController.betViewController = nil;
                    [baseSelectViewController clearBalls];
                    UIView *midView = baseSelectViewController.navigationItem.titleView;
                    UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
                    midBtn.enabled = YES;
                    [self.navigationController popToViewController:baseSelectViewController animated:YES];
                    _pushView = YES;
                    hasBaseView = YES;
                    break;
                }
            }
            
            if (!hasBaseView) {
                NSDictionary *homeDict = _globals.homeViewInfoDict;
                NSObject *base = [homeDict objectForKey:[NSString stringWithFormat:@"%ld",(long)_lotteryId]];
                if (base) {
                    UIViewController *baseSelectViewController = [GlobalsProject viewController:_lotteryId initWithInfoData:base];
                    if (baseSelectViewController && [baseSelectViewController isKindOfClass:[BaseSelectViewController class]]) {
                        [self.navigationController pushViewController:baseSelectViewController animated:YES];
                    }
                }
            }
        }
    }
}

- (void)goBackTouchUpInside:(id)sender {
    if (_pushView) {
        return;
    }
    _pushView = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -Customized: Private (General)
- (void)fillViewText {
    
    NSString *balance = [_orderDetailDict objectForKey:@"balance"];                                 // 剩余总额
    NSString *handselMoney = [_orderDetailDict objectForKey:@"handselMoney"];                       // 剩余彩金
    CGFloat currentMoeny = [[_orderDetailDict objectForKey:@"currentMoeny"] floatValue];            // 当前消费金额
    CGFloat currentHandsel = [[_orderDetailDict objectForKey:@"currentHandsel"] floatValue];        // 当前消费彩金
    
    [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[_orderDetailDict objectForKey:@"handselMoney"]];

    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">金额消费 </font><font color=\"%@\">%.2f</font><font color=\"black\"> 元，彩金消费 </font><font color=\"%@\">%.2f</font><font color=\"black\"> 元</font>",tRedColorText, currentMoeny, tRedColorText, currentHandsel];
    NSString *text1 =[NSString stringWithFormat:@"<font color=\"black\">剩余金额:  </font><font color=\"%@\">%@</font><font color=\"black\"> 元</font>",tRedColorText, balance];
    NSString *text2 =[NSString stringWithFormat:@"<font color=\"black\">剩余彩金:  </font><font color=\"%@\">%@</font><font color=\"black\"> 元</font>",tRedColorText, handselMoney];

    NSAttributedString *attString =[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize14];
    NSAttributedString *attString1 =[Globals getAttriButedWithText:text1 fontSize:XFIponeIpadFontSize14];
    NSAttributedString *attString2 =[Globals getAttriButedWithText:text2 fontSize:XFIponeIpadFontSize14];
    
    CGSize payMoneyPromptLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize14];
    CGRect payMoneyPromptLabelRect = _payMoneyPromptLabel.frame;
    [_payMoneyPromptLabel setTag:2];
    [_payMoneyPromptLabel setFrame:CGRectMake((kWinSize.width - payMoneyPromptLabelSize.width) / 2.0f, CGRectGetMinY(payMoneyPromptLabelRect), payMoneyPromptLabelSize.width, CGRectGetHeight(payMoneyPromptLabelRect))];
    [_payMoneyPromptLabel setAttString:attString];
    
    // 剩余金额
    CGSize residualAmountLabelSize = [Globals defaultSizeWithString:attString1.string fontSize:XFIponeIpadFontSize14];
    CGRect residualAmountLabelRect = _residualAmountLabel.frame;
    [_residualAmountLabel setFrame:CGRectMake((kWinSize.width - residualAmountLabelSize.width) / 2.0f, CGRectGetMinY(residualAmountLabelRect), residualAmountLabelSize.width, CGRectGetHeight(residualAmountLabelRect))];
    [_residualAmountLabel setAttString:attString1];
    
    // 剩余彩金
    CGSize residualHandselLabelSize = [Globals defaultSizeWithString:attString2.string fontSize:XFIponeIpadFontSize14];
    CGRect residualHandselLabelRect = _residualHandselLabel.frame;
    [_residualHandselLabel setFrame:CGRectMake((kWinSize.width - residualHandselLabelSize.width) / 2.0f, CGRectGetMinY(residualHandselLabelRect), residualHandselLabelSize.width, CGRectGetHeight(residualHandselLabelRect))];
    [_residualHandselLabel setAttString:attString2];
    
}


- (void)requestOrderDetail {
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    NSString *lottoeryIds = [InterfaceHelper getAllLotteryString];
    [infoDic setObject:lottoeryIds forKey:@"lotteryId"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",1] forKey:@"pageIndex"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",10] forKey:@"pageSize"];
    if (_status != CHASED) {
        [infoDic setObject:@"5" forKey:@"sort"];
        [infoDic setObject:@"3" forKey:@"isPurchasing"];
        [infoDic setObject:[NSString stringWithFormat:@"0"] forKey:@"status"];
    } else {
        [infoDic setObject:@"0" forKey:@"sort"];
    }
    [infoDic setObject:@"0" forKey:@"sortType"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:_status == CHASED ? HTTP_REQUEST_GetAllChaseOrderTicket : HTTP_REQUEST_GetAllOrderTicket userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_httpRequest setDidFinishSelector:@selector(orderDetailRequestFinish:)];
    [_httpRequest setDidFailSelector:@selector(orderDetailRequestFail:)];
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
