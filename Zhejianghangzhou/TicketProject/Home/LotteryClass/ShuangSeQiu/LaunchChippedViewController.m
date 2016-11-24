//
//  LaunchChippedViewController.m  发起合买
//  TicketProject
//
//  Created by sls002 on 13-5-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20141015 17:22（洪晓彬）：修改代码规范，改进生命周期，处理各种内存问题
//  20141015 17:59（洪晓彬）：进行ipad适配
//  20150820 09:24（刘科）: 修复奖金优化后发起合买购买失败的BUG。

#import "LaunchChippedViewController.h"
#import "CustomSegmentedControl.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "MSKeyboardScrollView.h"
#import "UserInfo.h"
#import "UserLoginViewController.h"
#import "XFNavigationViewController.h"
#import "PaySucceedViewController.h"
#import "HelpViewController.h"
#import "Service.h"
#import "HomeViewController.h"
#import "SVProgressHUD.h"

#import "Globals.h"

#define kBrokerageSelectViewHight (IS_PHONE ? 60.0f : 120.0f) //选择佣金view的高度
#define kLabelFontSize XFIponeIpadFontSize12  //所有label的字体大小

#define kBuyScale 0.05 //认购比例

@interface LaunchChippedViewController ()

@end

#pragma mark -
#pragma mark @implementation LaunchChippedViewController
@implementation LaunchChippedViewController

- (id)initWithBetDictionary:(NSDictionary *)betDic {
    self = [super init];
    if(self) {
        self.lotteryDic = [betDic objectForKey:@"lotteryDic"];
        self.buyContent = [betDic objectForKey:@"buyContent"];
        multiple = [[betDic objectForKey:@"multiple"] intValue];
        
        _playId = [[[self.buyContent objectAtIndex:0] objectForKey:@"playType"] integerValue];
        
        _oneOfTicketMonery = [self isChaseTicketMoneryWithPlayId:_playId];

        NSMutableDictionary *dic = [self.buyContent objectAtIndex:0];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)[[dic objectForKey:@"sumNum"] intValue] * _oneOfTicketMonery * multiple] forKey:@"sumMoney"];
        
        projectTotal = [[betDic objectForKey:@"betCount"] intValue] * multiple * _oneOfTicketMonery;
        copies = projectTotal;
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _globals = _appDelegate.globals;
        _minBuyScale = 0.0f;
        _subscriptioncopies = _globals.commission;
        if (_globals.minBuyScale <= 0) {
            _minBuyScale = kBuyScale;
        } else {
            _minBuyScale = _globals.minBuyScale;
        }
        buyCopy = [[self notRounding:copies * _minBuyScale afterPoint:1] intValue];
        [self setTitle:@"发起复制"];
    }
    return self;
}

- (void)dealloc {
    _scrollView = nil;
    _totalLabel = nil;
    _copiesLabel = nil;
    
    [_orderDetailDict release];
    _orderDetailDict = nil;
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
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
    
    //playingMethodBtn  玩法介绍按钮
    CGRect playingMethodBtnRect = XFIponeIpadNavigationplayingMethodButtonRect;
    UIButton *playingMethodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playingMethodBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"playingMethod.png"]] forState:UIControlStateNormal];
    [playingMethodBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"playingMethod.png"]] forState:UIControlStateHighlighted];
    [playingMethodBtn setFrame:playingMethodBtnRect];
    [playingMethodBtn addTarget:self action:@selector(getHelp:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *playingMethodItem = [[UIBarButtonItem alloc]initWithCustomView:playingMethodBtn];
    [self.navigationItem setRightBarButtonItem:playingMethodItem];
    [playingMethodItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat leftLabeLMinX = IS_PHONE ? 10.0f : 20.0f;//左边所有label的x
    CGFloat leftLabelWidth = IS_PHONE ? 65.0f : 100.0f;
    CGFloat leftLabelHeight = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat viewMaginRight = IS_PHONE ? 10.0f : 20.0f;//右边的控件和右边视图边框的间距
    
    CGFloat firstLineHeight = IS_PHONE ? 38.0f : 60.0f;
    CGFloat otherLineHeight = IS_PHONE ? 45.0f : 80.0f;
    
    CGFloat firstSegmentedControlWidth = IS_PHONE ? 160.0f : 400.0f;
    
    /********************************************/
    CGFloat firstViewHeight = firstLineHeight + otherLineHeight * 2; //上部分视图的高度
   
    CGFloat firstViewAmountPerServingHeight = IS_PHONE ? 28.0f : 45.0f;//每份金额选择按钮 的高度
    /********************************************/
    CGFloat secondViewHeight = IS_PHONE ? 250.0f : 450.0f; //下部分视图的高度
    
    CGFloat secondViewTextFieldHeight = IS_PHONE ? 28.0f : 50.0f;
    
    CGFloat secondViewSegmentedControlHeight = IS_PHONE ? 28.0f : 42.0f;
    
    CGFloat cutAddButtonSize = IS_PHONE ? 28.0f : 52.0f;
    CGFloat cutAddTextFieldWidth = IS_PHONE ? 78.0f : 130.0f;
    CGFloat btnLabelInterval = 5.0f;
    /********************************************/
    CGFloat bottomViewHeihgt = IS_PHONE ? 44.0f : 66.0f; //底部栏的高度
    
    CGFloat bottomViewFirstLabelMinX = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat bottomPayBtnMaginRight = IS_PHONE ? 10.0f : 20.0f;
    CGFloat bottomPayBtnWidth = IS_PHONE ? 45.0f : 90.0f;
    CGFloat bottomPayBtnHeight = IS_PHONE ? 25.0f : 45.0f;
    /********************** adjustment end ***************************/
    
    //scrollView 整个滚动栏
    CGRect scrollViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - bottomViewHeihgt);
    _scrollView = [[MSKeyboardScrollView alloc]initWithFrame:scrollViewRect];
    if(!IS_PHONE) {
        [_scrollView removeNotificationCenter];
    }
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    /********************** 由选择佣金的按钮分开的  上部分视图 **********************/
    //firstView 选择佣金的按钮上部分视图
    CGRect firstViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), firstViewHeight);
    UIView *firstView = [[UIView alloc]initWithFrame:firstViewRect];
    [firstView setUserInteractionEnabled:YES];
    [_scrollView addSubview:firstView];
    [firstView release];
    
    //totalPromptLabel 方案金额-提示文字
    CGRect totalPromptLabelRect = CGRectMake(leftLabeLMinX, (firstLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *totalPromptLabel = [[UILabel alloc]initWithFrame:totalPromptLabelRect];
    [totalPromptLabel setBackgroundColor:[UIColor clearColor]];
    [totalPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [totalPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [totalPromptLabel setText:@"方案金额"];
    [firstView addSubview:totalPromptLabel];
    [totalPromptLabel release];
    
    //totalLabel 方案金额
    NSString *prompt_1 = [NSString stringWithFormat:@"%ld",(long)projectTotal];
    CGSize promptSize_1 = [Globals defaultSizeWithString:prompt_1 fontSize:kLabelFontSize];
    CGRect totalLabelRect = CGRectMake(CGRectGetMaxX(totalPromptLabelRect), CGRectGetMinY(totalPromptLabelRect), promptSize_1.width , leftLabelHeight);
    _totalLabel = [[UILabel alloc]initWithFrame:totalLabelRect];
    [_totalLabel setBackgroundColor:[UIColor clearColor]];
    [_totalLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_totalLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
    [_totalLabel setText:prompt_1];
    [firstView addSubview:_totalLabel];
    [_totalLabel release];
    
    //copiesPromptLabel 份数-提示文字
    NSString *prompt_2 = @" 元  分成 ";
    CGSize promptSize_2 = [Globals defaultSizeWithString:prompt_2 fontSize:kLabelFontSize];
    CGRect copiesPromptLabelRect = CGRectMake(CGRectGetMaxX(totalLabelRect), CGRectGetMinY(totalPromptLabelRect), promptSize_2.width, leftLabelHeight);
    UILabel *copiesPromptLabel = [[UILabel alloc]initWithFrame:copiesPromptLabelRect];
    [copiesPromptLabel setBackgroundColor:[UIColor clearColor]];
    [copiesPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [copiesPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [copiesPromptLabel setTextAlignment:NSTextAlignmentLeft];
    [copiesPromptLabel setText:prompt_2];
    [firstView addSubview:copiesPromptLabel];
    [copiesPromptLabel release];
    
    //copiesLabel 份数
    NSString *prompt_3 = [NSString stringWithFormat:@"%ld",(long)copies];
    CGSize promptSize_3 = [Globals defaultSizeWithString:prompt_3 fontSize:kLabelFontSize];
    CGRect copiesLabelRect = CGRectMake(CGRectGetMaxX(copiesPromptLabelRect), CGRectGetMinY(totalPromptLabelRect), promptSize_3.width , leftLabelHeight);
    _copiesLabel = [[UILabel alloc]initWithFrame:copiesLabelRect];
    [_copiesLabel setBackgroundColor:[UIColor clearColor]];
    [_copiesLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_copiesLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
    [_copiesLabel setText:prompt_3];
    [firstView addSubview:_copiesLabel];
    [_copiesLabel release];
    
    //copiesLabelPromptLabel
    NSString *prompt_4 = @" 份";
    CGSize promptSize_4 = [Globals defaultSizeWithString:prompt_4 fontSize:kLabelFontSize];
    CGRect copiesLabelPromptLabelRect = CGRectMake(CGRectGetMaxX(copiesLabelRect), CGRectGetMinY(totalPromptLabelRect), promptSize_4.width, leftLabelHeight);
    _copiesLabelPromptLabel = [[UILabel alloc] initWithFrame:copiesLabelPromptLabelRect];
    [_copiesLabelPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_copiesLabelPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_copiesLabelPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [_copiesLabelPromptLabel setTextAlignment:NSTextAlignmentLeft];
    [_copiesLabelPromptLabel setText:prompt_4];
    [firstView addSubview:_copiesLabelPromptLabel];
    [_copiesLabelPromptLabel release];
    
    CGRect line_1Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(totalPromptLabelRect) + (firstLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_1Rect inSuperView:firstView];
    
    /*************************************************/
    
    //amountPromptLabel 每份金额－提示文字
    CGRect amountPromptLabelRect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(line_1Rect) + (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *amountPromptLabel = [[UILabel alloc]initWithFrame:amountPromptLabelRect];
    [amountPromptLabel setBackgroundColor:[UIColor clearColor]];
    [amountPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [amountPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [amountPromptLabel setText:@"每份金额"];
    [firstView addSubview:amountPromptLabel];
    [amountPromptLabel release];
    
    //amountPerServing 每份金额选择按钮
    CGRect amountPerServingRect = CGRectMake(CGRectGetMaxX(amountPromptLabelRect), CGRectGetMinY(amountPromptLabelRect) - (firstViewAmountPerServingHeight - leftLabelHeight) / 2.0f, firstSegmentedControlWidth, firstViewAmountPerServingHeight);
    _amountPerServingCustomSegmentedControl = [[CustomSegmentedControl alloc]initWithFrame:amountPerServingRect Items:[NSArray arrayWithObjects:@"1.0元", [self isChaseTicketWithPlayId:_playId] ? @"3.0元" : @"2.0元", nil]];
    [_amountPerServingCustomSegmentedControl setSelectedSegmentIndex:0];
    [_amountPerServingCustomSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_amountPerServingCustomSegmentedControl addTarget:self action:@selector(amountChanged:) forControlEvents:UIControlEventValueChanged];
    [firstView addSubview:_amountPerServingCustomSegmentedControl];
    [_amountPerServingCustomSegmentedControl release];
    
    CGRect line_2Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(amountPromptLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_2Rect inSuperView:firstView];
    
    /*************************************************/
    
    //winBrokeragePromptLabel 中奖佣金－提示文字
    CGRect winBrokeragePromptLabelRect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(line_2Rect) + (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *winBrokeragePromptLabel = [[UILabel alloc]initWithFrame:winBrokeragePromptLabelRect];
    [winBrokeragePromptLabel setBackgroundColor:[UIColor clearColor]];
    [winBrokeragePromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [winBrokeragePromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [winBrokeragePromptLabel setText:@"方案提成"];
    [firstView addSubview:winBrokeragePromptLabel];
    [winBrokeragePromptLabel release];
    
    //cutButton_1
    CGRect cutButton_1Rect = CGRectMake(CGRectGetMinX(amountPerServingRect), CGRectGetMinY(winBrokeragePromptLabelRect) - (cutAddButtonSize - leftLabelHeight) / 2.0f, cutAddButtonSize, cutAddButtonSize);
    UIButton *cutButton_1 = [[UIButton alloc] initWithFrame:cutButton_1Rect];
    [cutButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateNormal];
    [cutButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateHighlighted];
    [cutButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateSelected];
    [cutButton_1 setTag:0];
    [cutButton_1 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [firstView addSubview:cutButton_1];
    [cutButton_1 release];
    
    //winBrokerageTextField
    CGRect winBrokerageTextFieldRect = CGRectMake(CGRectGetMaxX(cutButton_1Rect), CGRectGetMinY(cutButton_1Rect), cutAddTextFieldWidth, CGRectGetHeight(cutButton_1Rect));
    _winBrokerageTextField = [[UITextField alloc]initWithFrame:winBrokerageTextFieldRect];
    [_winBrokerageTextField setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_winBrokerageTextField setReturnKeyType:UIReturnKeyDone];
    [_winBrokerageTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_winBrokerageTextField setText:[NSString stringWithFormat:@"%.0f",_subscriptioncopies * 100]];
    [_winBrokerageTextField setTextAlignment:NSTextAlignmentCenter];
    [_winBrokerageTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_winBrokerageTextField setBackground:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [_winBrokerageTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [firstView addSubview:_winBrokerageTextField];
    [_winBrokerageTextField release];
    
    //addButton_1
    CGRect addButton_1Rect = CGRectMake(CGRectGetMaxX(winBrokerageTextFieldRect), CGRectGetMinY(cutButton_1Rect), cutAddButtonSize, cutAddButtonSize);
    UIButton *addButton_1 = [[UIButton alloc] initWithFrame:addButton_1Rect];
    [addButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateNormal];
    [addButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateHighlighted];
    [addButton_1 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateSelected];
    [addButton_1 setTag:1];
    [addButton_1 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [firstView addSubview:addButton_1];
    [addButton_1 release];
    
    //promptAddLabel
    CGRect promptAddLabelRect = CGRectMake(CGRectGetMaxX(addButton_1Rect), CGRectGetMinY(addButton_1Rect), CGRectGetWidth(addButton_1Rect), CGRectGetHeight(addButton_1Rect));
    UILabel *promptAddLabel = [[UILabel alloc] initWithFrame:promptAddLabelRect];
    [promptAddLabel setBackgroundColor:[UIColor clearColor]];
    [promptAddLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [promptAddLabel setText:@" %"];
    [firstView addSubview:promptAddLabel];
    [promptAddLabel release];
    
    CGRect line_3Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(winBrokeragePromptLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_3Rect inSuperView:firstView];
    /********************** 由选择佣金的按钮分开的  下部分视图 **********************/
    //secondView 选择佣金的按钮下部分视图
    CGRect secondViewRect = CGRectMake(0, CGRectGetMaxY(firstViewRect), CGRectGetWidth(appRect), secondViewHeight);
    _secondView = [[UIView alloc]initWithFrame:secondViewRect];
    [_secondView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
    [_secondView setUserInteractionEnabled:YES];
    [_scrollView addSubview:_secondView];
    [_secondView release];
    
    /********************************************/
    
    //buyPromptLabel 购买份数－提示文字
    CGRect buyPromptLabelRect = CGRectMake(leftLabeLMinX, (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *buyPromptLabel = [[UILabel alloc]initWithFrame:buyPromptLabelRect];
    [buyPromptLabel setBackgroundColor:[UIColor clearColor]];
    [buyPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [buyPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [buyPromptLabel setText:@"我要购买"];
    [_secondView addSubview:buyPromptLabel];
    [buyPromptLabel release];
    
    //cutButton_2
    CGRect cutButton_2Rect = CGRectMake(CGRectGetMinX(amountPerServingRect), CGRectGetMinY(buyPromptLabelRect) - (cutAddButtonSize - leftLabelHeight) / 2.0f, cutAddButtonSize, cutAddButtonSize);
    UIButton *cutButton_2 = [[UIButton alloc] initWithFrame:cutButton_2Rect];
    [cutButton_2 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateNormal];
    [cutButton_2 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateHighlighted];
    [cutButton_2 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateSelected];
    [cutButton_2 setTag:2];
    [cutButton_2 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_secondView addSubview:cutButton_2];
    [cutButton_2 release];
    
    //buyCopiesTextField 购买份数输入框
    CGRect buyCopiesTextFieldRect = CGRectMake(CGRectGetMaxX(cutButton_2Rect), CGRectGetMinY(cutButton_2Rect), cutAddTextFieldWidth, CGRectGetHeight(cutButton_1Rect));
    _buyCopiesTextField = [[UITextField alloc]initWithFrame:buyCopiesTextFieldRect];
    [_buyCopiesTextField setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_buyCopiesTextField setText:[NSString stringWithFormat:@"%@",[self notRounding:projectTotal * _minBuyScale afterPoint:1]]];
    [_buyCopiesTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_buyCopiesTextField setTextAlignment:NSTextAlignmentCenter];
    [_buyCopiesTextField setPlaceholder:[NSString stringWithFormat:@"至少%@份",[self notRounding:projectTotal * _minBuyScale afterPoint:1]]];
    [_buyCopiesTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_buyCopiesTextField setBackground:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [_buyCopiesTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_secondView addSubview:_buyCopiesTextField];
    [_buyCopiesTextField release];
    
    
    //addButton_2
    CGRect addButton_2Rect = CGRectMake(CGRectGetMaxX(winBrokerageTextFieldRect), CGRectGetMinY(cutButton_2Rect), cutAddButtonSize, cutAddButtonSize);
    UIButton *addButton_2 = [[UIButton alloc] initWithFrame:addButton_2Rect];
    [addButton_2 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateNormal];
    [addButton_2 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateHighlighted];
    [addButton_2 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateSelected];
    [addButton_2 setTag:3];
    [addButton_2 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_secondView addSubview:addButton_2];
    [addButton_2 release];
    
    //promptFenLabel
    CGRect promptFenLabelRect = CGRectMake(CGRectGetMaxX(addButton_2Rect), CGRectGetMinY(addButton_2Rect), CGRectGetWidth(addButton_2Rect), CGRectGetHeight(addButton_2Rect));
    UILabel *promptFenLabel = [[UILabel alloc] initWithFrame:promptFenLabelRect];
    [promptFenLabel setBackgroundColor:[UIColor clearColor]];
    [promptFenLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [promptFenLabel setText:@" 份"];
    [_secondView addSubview:promptFenLabel];
    [promptFenLabel release];
    
    
    CGRect line_4Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(buyPromptLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_4Rect inSuperView:_secondView];
    
    /********************************************/
    
    //guaranteedPromptLabel 保底份数-提示文字
    CGRect guaranteedPromptLabelRect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(line_4Rect) + (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *guaranteedPromptLabel = [[UILabel alloc]initWithFrame:guaranteedPromptLabelRect];
    [guaranteedPromptLabel setBackgroundColor:[UIColor clearColor]];
    [guaranteedPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [guaranteedPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [guaranteedPromptLabel setText:@"我要保底"];
    [_secondView addSubview:guaranteedPromptLabel];
    [guaranteedPromptLabel release];
    
    
    //cutButton_3
    CGRect cutButton_3Rect = CGRectMake(CGRectGetMinX(amountPerServingRect), CGRectGetMinY(guaranteedPromptLabelRect) - (cutAddButtonSize - leftLabelHeight) / 2.0f, cutAddButtonSize, cutAddButtonSize);
    UIButton *cutButton_3 = [[UIButton alloc] initWithFrame:cutButton_3Rect];
    [cutButton_3 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateNormal];
    [cutButton_3 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateHighlighted];
    [cutButton_3 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"cutButton.png"]] forState:UIControlStateSelected];
    [cutButton_3 setTag:4];
    [cutButton_3 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_secondView addSubview:cutButton_3];
    [cutButton_3 release];
    
    //guaranteedCopiesTextField 保底份数
    CGRect guaranteedCopiesTextFieldRect = CGRectMake(CGRectGetMaxX(cutButton_3Rect), CGRectGetMinY(cutButton_3Rect), cutAddTextFieldWidth, CGRectGetHeight(cutButton_1Rect));
    _guaranteedCopiesTextField = [[UITextField alloc]initWithFrame:guaranteedCopiesTextFieldRect];
    [_guaranteedCopiesTextField setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_guaranteedCopiesTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_guaranteedCopiesTextField setTextAlignment:NSTextAlignmentCenter];
    [_guaranteedCopiesTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_guaranteedCopiesTextField setText:@"0"];
    [_guaranteedCopiesTextField setPlaceholder:@"0"];
    [_guaranteedCopiesTextField setBackground:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [_guaranteedCopiesTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_secondView addSubview:_guaranteedCopiesTextField];
    [_guaranteedCopiesTextField release];
    
    //addButton_3
    CGRect addButton_3Rect = CGRectMake(CGRectGetMaxX(winBrokerageTextFieldRect), CGRectGetMinY(cutButton_3Rect), cutAddButtonSize, cutAddButtonSize);
    UIButton *addButton_3 = [[UIButton alloc] initWithFrame:addButton_3Rect];
    [addButton_3 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateNormal];
    [addButton_3 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateHighlighted];
    [addButton_3 setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"addButton.png"]] forState:UIControlStateSelected];
    [addButton_3 setTag:5];
    [addButton_3 addTarget:self action:@selector(addCutTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_secondView addSubview:addButton_3];
    [addButton_3 release];
    
    //promptFenLabel
    CGRect promptFen2LabelRect = CGRectMake(CGRectGetMaxX(addButton_3Rect), CGRectGetMinY(addButton_3Rect), CGRectGetWidth(addButton_3Rect), CGRectGetHeight(addButton_3Rect));
    UILabel *promptFen2Label = [[UILabel alloc] initWithFrame:promptFen2LabelRect];
    [promptFen2Label setBackgroundColor:[UIColor clearColor]];
    [promptFen2Label setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [promptFen2Label setText:@" 份"];
    [_secondView addSubview:promptFen2Label];
    [promptFen2Label release];
    
    //checkBtn
    CGRect checkBtnRect = CGRectMake(CGRectGetMaxX(promptFen2LabelRect), CGRectGetMinY(promptFen2LabelRect), cutAddButtonSize, cutAddButtonSize);
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton_Normal.png"]] forState:UIControlStateNormal];
    [checkBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_secondView addSubview:checkBtn];
    [checkBtn release];
    
    //checkPromptLabel
    CGRect checkPromptLabelRect = CGRectMake(CGRectGetMaxX(checkBtnRect) + btnLabelInterval, CGRectGetMinY(checkBtnRect), leftLabelWidth * 2, CGRectGetHeight(checkBtnRect));
    UILabel *checkPromptLabel = [[UILabel alloc]initWithFrame:checkPromptLabelRect];
    [checkPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [checkPromptLabel setText:@"全保"];
    [checkPromptLabel setTextColor:[UIColor colorWithRed:156.0f/255.0f green:156.0f/255.0f blue:156.0f/255.0f alpha:1.0f]];
    [checkPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_secondView addSubview:checkPromptLabel];
    [checkPromptLabel release];
    
    CGRect line_5Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(guaranteedPromptLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_5Rect inSuperView:_secondView];
    
    /********************************************/
    
    //secretPromptLabel 保密设置－提示文字
    CGRect secretPromptLabelRect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(line_5Rect) + (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *secretPromptLabel = [[UILabel alloc]initWithFrame:secretPromptLabelRect];
    [secretPromptLabel setBackgroundColor:[UIColor clearColor]];
    [secretPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [secretPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [secretPromptLabel setText:@"保密设置"];
    [_secondView addSubview:secretPromptLabel];
    [secretPromptLabel release];
    
    //secretSetting 保密设置选择按钮
    CGRect secretSettingRect = CGRectMake(CGRectGetMaxX(secretPromptLabelRect), CGRectGetMinY(secretPromptLabelRect) - (secondViewSegmentedControlHeight - leftLabelHeight) / 2.0f, CGRectGetWidth(appRect) - viewMaginRight - CGRectGetMaxX(secretPromptLabelRect), secondViewSegmentedControlHeight);
    _secretSettingCustomSegmentedControl = [[CustomSegmentedControl alloc]initWithFrame:secretSettingRect Items:[NSArray arrayWithObjects:@"公开",@"跟单可见",@"开奖可见",@"永久保密", nil]];
    [_secretSettingCustomSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_secretSettingCustomSegmentedControl setSelectedSegmentIndex:0];
    [_secondView addSubview:_secretSettingCustomSegmentedControl];
    [_secretSettingCustomSegmentedControl release];
    
    CGRect line_6Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(secretPromptLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_6Rect inSuperView:_secondView];
    
    /********************************************/
    
    //titleLabel 方案标题－提示文字
    CGRect titleLabelRect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(line_6Rect) + (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleLabelRect];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [titleLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [titleLabel setText:@"方案标题"];
    [_secondView addSubview:titleLabel];
    [titleLabel release];
    
    //titleTextField 方案标题输入框
    CGRect titleTextFieldRect = CGRectMake(CGRectGetMaxX(titleLabelRect), CGRectGetMinY(titleLabelRect) - (secondViewTextFieldHeight - leftLabelHeight) / 2.0f, CGRectGetWidth(appRect) - viewMaginRight - CGRectGetMaxX(titleLabelRect), secondViewTextFieldHeight);
    _titleTextField = [[UITextField alloc]initWithFrame:titleTextFieldRect];
    [_titleTextField setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_titleTextField setPlaceholder:@"可选"];
    [_titleTextField setKeyboardType:UIKeyboardTypeDefault];
    [_titleTextField setContentVerticalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_titleTextField setReturnKeyType:UIReturnKeyDone];
    [_titleTextField setBorderStyle:UITextBorderStyleBezel];
    [_titleTextField.layer setBorderWidth:0.0f];
    [_titleTextField setBackground:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [_secondView addSubview:_titleTextField];
    [_titleTextField release];
    
    CGRect line_7Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(titleLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_7Rect inSuperView:_secondView];
    
    /********************************************/
    
    //memoPromptLabel 方案描述-提示文字
    CGRect memoPromptLabelRect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(line_7Rect) + (otherLineHeight - leftLabelHeight) / 2.0f, leftLabelWidth, leftLabelHeight);
    UILabel *memoPromptLabel = [[UILabel alloc]initWithFrame:memoPromptLabelRect];
    [memoPromptLabel setBackgroundColor:[UIColor clearColor]];
    [memoPromptLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [memoPromptLabel setTextColor:[UIColor colorWithRed:0x85/255.0f green:0x85/255.0f blue:0x85/255.0f alpha:1.0f]];
    [memoPromptLabel setText:@"方案描述"];
    [_secondView addSubview:memoPromptLabel];
    [memoPromptLabel release];
    
    //memoTextField
    CGRect memoTextFieldRect = CGRectMake(CGRectGetMaxX(memoPromptLabelRect), CGRectGetMinY(memoPromptLabelRect) - (secondViewTextFieldHeight - leftLabelHeight) / 2.0f, CGRectGetWidth(appRect) - viewMaginRight - CGRectGetMaxX(memoPromptLabelRect), secondViewTextFieldHeight);
    _memoTextField = [[UITextField alloc]initWithFrame:memoTextFieldRect];
    [_memoTextField setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    [_memoTextField setPlaceholder:@"可选"];
    [_memoTextField setKeyboardType:UIKeyboardTypeDefault];
    [_memoTextField setBorderStyle:UITextBorderStyleBezel];
    [_memoTextField.layer setBorderWidth:0.0f];
    [_memoTextField setBackground:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blackLineAngleButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [_memoTextField setContentVerticalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_memoTextField setReturnKeyType:UIReturnKeyDone];
    [_secondView addSubview:_memoTextField];
    [_memoTextField release];
    
    CGRect line_8Rect = CGRectMake(leftLabeLMinX, CGRectGetMaxY(memoPromptLabelRect) + (otherLineHeight - leftLabelHeight) / 2.0f - AllLineWidthOrHeight, CGRectGetWidth(appRect) - leftLabeLMinX * 2, AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line_8Rect inSuperView:_secondView];
    
    /********************** 底部视图 **********************/
    //bottomView 底部视图
    CGRect bottomViewRect = CGRectMake(0, self.view.bounds.size.height - bottomViewHeihgt - 44.0f, CGRectGetWidth(appRect), bottomViewHeihgt);
    UIView *bottomView = [[UIView alloc]initWithFrame:bottomViewRect];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    [bottomView release];
    
    //shadeImageView
    CGRect shadeImageViewRect = CGRectMake(0, -3, CGRectGetWidth(bottomViewRect), 3);
    UIImageView *shadeImageView = [[UIImageView alloc] initWithFrame:shadeImageViewRect];
    [shadeImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shade.png"]]];
    [bottomView addSubview:shadeImageView];
    [shadeImageView release];
    
    //promptLabel 应付金额－提示文字
    NSString *promptText = @"共";
    CGSize promptTextSize = [Globals defaultSizeWithString:promptText fontSize:XFIponeIpadFontSize15];
    CGRect promptLabelRect = CGRectMake(bottomViewFirstLabelMinX, (bottomViewHeihgt - leftLabelHeight) / 2.0f, promptTextSize.width, leftLabelHeight);
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [promptLabel setText:promptText];
    [promptLabel setTextColor:[UIColor blackColor]];
    [bottomView addSubview:promptLabel];
    [promptLabel release];
    
    //bottomLabel 应付金额
    NSString *bottomLabelText = @"0.00";
    CGSize bottomLabelSize = [Globals defaultSizeWithString:bottomLabelText fontSize:XFIponeIpadFontSize14];
    CGRect bottomLabelRect = CGRectMake(CGRectGetMaxX(promptLabelRect), CGRectGetMinY(promptLabelRect), bottomLabelSize.width, leftLabelHeight);
    _bottomLabel = [[UILabel alloc]initWithFrame:bottomLabelRect];
    [_bottomLabel setBackgroundColor:[UIColor clearColor]];
    [_bottomLabel setTextAlignment:NSTextAlignmentCenter];
    [_bottomLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_bottomLabel setText:bottomLabelText];
    [_bottomLabel setTextColor:[UIColor colorWithRed:0xe3/255.0 green:0x39/255.0 blue:0x3c/255.0f alpha:1.0]];
    [bottomView addSubview:_bottomLabel];
    [_bottomLabel release];
    
    NSString *yuanPromptText = @"元";
    CGSize yuanPromptLabelSize = [Globals defaultSizeWithString:yuanPromptText fontSize:XFIponeIpadFontSize14];
    CGRect yuanPromptLabelRect = CGRectMake(CGRectGetMaxX(bottomLabelRect), CGRectGetMinY(promptLabelRect), yuanPromptLabelSize.width, leftLabelHeight);
    _yuanPromptLabel = [[UILabel alloc] initWithFrame:yuanPromptLabelRect];
    [_yuanPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_yuanPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_yuanPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_yuanPromptLabel setText:yuanPromptText];
    [bottomView addSubview:_yuanPromptLabel];
    [_yuanPromptLabel release];
    
    //payBtn 付款按钮
    CGRect payBtnRect = CGRectMake(CGRectGetWidth(appRect) - bottomPayBtnMaginRight - bottomPayBtnWidth, (bottomViewHeihgt - bottomPayBtnHeight) / 2.0f, bottomPayBtnWidth, bottomPayBtnHeight);
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setFrame:payBtnRect];
    [payBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setTitle:@"付款" forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(payClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:payBtn];
}

- (void)zhuiQiSelected:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:![btn isSelected]];
    
    if (btn.selected) {
        [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(copies - [_buyCopiesTextField.text integerValue])]];
    } else {
        [_guaranteedCopiesTextField setText:@"0"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _orderDetailDict = [[NSMutableDictionary alloc] init];
    [self showPayCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"连接失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"购买成功"];
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        // 合买成功后，会返回余额和冻结金额，保存起来
        [[UserInfo shareUserInfo] setBalance:[responseDic objectForKey:@"balance"]];
        [[UserInfo shareUserInfo] setFreeze:[responseDic objectForKey:@"freeze"]];
        
        // 保存到NSUserDefaults
        NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
        [userinfo setObject:[responseDic objectForKey:@"balance"] forKey:@"balance"];
        [userinfo setObject:[responseDic objectForKey:@"freeze"] forKey:@"freeze"];
        [[NSUserDefaults standardUserDefaults]setObject:userinfo forKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [_orderDetailDict addEntriesFromDictionary:responseDic];
        
        // 如果订单发起人购买份数等于总分数时，则该订单为普通订单。
        OrderStatus temp;
        if (buyCopy == copies) {
            temp = NORMAL;
        }else {
            temp = CHIPPED;
        }
        
        PaySucceedViewController *paySucceedViewController = [[PaySucceedViewController alloc] initWithDict:_orderDetailDict buyType:temp];
        [self.navigationController pushViewController:paySucceedViewController animated:YES];
        [paySucceedViewController release];
        
    
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    } else {
        [Globals alertWithMessage:@"发起复制失败，该期已经开奖或该期该彩种可发起的购买方案已达上限"];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
//返回
- (void)getBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//帮助
- (void)getHelp:(id)sender {
    Service *service=[Service getDefaultService];
    service.lotteryTypes = 1000;
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithLotteryId:1000];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc] initWithRootViewController:helpViewController];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [helpViewController release];
    [nav release];
    
}

- (void)addCutTouchUpInside:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag / 2 == 0) {
        NSInteger winBrokerage = [_winBrokerageTextField.text integerValue];
        if (btn.tag % 2 == 0) {
            if (winBrokerage - 1 < 0) {
                [_winBrokerageTextField setText:[NSString stringWithFormat:@"0"]];
                [XYMPromptView defaultShowInfo:@"佣金至少为0" isCenter:YES];
            } else {
                [_winBrokerageTextField setText:[NSString stringWithFormat:@"%ld",(long)(winBrokerage - 1)]];
            }
        } else {
            if (winBrokerage + 1 > 10) {
                [_winBrokerageTextField setText:[NSString stringWithFormat:@"10"]];
                [XYMPromptView defaultShowInfo:@"佣金不能超过10%" isCenter:YES];
            } else {
                [_winBrokerageTextField setText:[NSString stringWithFormat:@"%ld",(long)(winBrokerage + 1)]];
            }
        }
    } else if (btn.tag / 2 == 1) {
        NSInteger winBrokerage = [_buyCopiesTextField.text integerValue];
        if (btn.tag % 2 == 0) {
            if (winBrokerage - 1 < (projectTotal * _minBuyScale + ((projectTotal * _minBuyScale - (NSInteger)(projectTotal * _minBuyScale)) > 0 ? 1 : 0))) {
                NSInteger buyCount = (projectTotal * _minBuyScale + ((projectTotal * _minBuyScale - (NSInteger)(projectTotal * _minBuyScale)) > 0 ? 1 : 0));
                
                [_buyCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)buyCount]];
                [XYMPromptView defaultShowInfo:[NSString stringWithFormat:@"至少认购%ld份",(long)buyCount] isCenter:YES];
            } else {
                [_buyCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(winBrokerage - 1)]];
            }
        } else {
            if (winBrokerage + 1 > copies) {
                [_buyCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)copies]];
                [XYMPromptView defaultShowInfo:[NSString stringWithFormat:@"最多认购%ld份",(long)copies] isCenter:YES];
            } else {
                [_buyCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(winBrokerage + 1)]];
                
                if ([_buyCopiesTextField.text integerValue] + [_guaranteedCopiesTextField.text integerValue] > copies) {
                    [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(copies - [_buyCopiesTextField.text integerValue])]];
                }
            }
        }
        [self showPayCount];
    } else if (btn.tag / 2 == 2) {
        NSInteger winBrokerage = [_guaranteedCopiesTextField.text integerValue];
        if (btn.tag % 2 == 0) {
            if (winBrokerage - 1 < 0) {
                [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"0"]];
            } else {
                [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(winBrokerage - 1)]];
            }
        } else {
            if (winBrokerage + 1 > copies - buyCopy) {
                [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(copies - buyCopy)]];
                [XYMPromptView defaultShowInfo:[NSString stringWithFormat:@"最多保底%ld份",(long)(copies - buyCopy)] isCenter:YES];
            } else {
                [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(winBrokerage + 1)]];
            }
        }
    }
}

//购买份数 和 保底份数 输入控制
- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    }
    if (textField == _winBrokerageTextField) {
        int intValue = [_winBrokerageTextField.text intValue];
        if (intValue <= 0) {
            [textField setText:@"0"];
        } else if (intValue > 10) {
            [textField setText:@"10"];
        }
    }
    if(textField == _buyCopiesTextField) {
        if (_buyCopiesTextField.text.length != 0) {
            int intValue = [_buyCopiesTextField.text intValue];
            if (intValue <= 0) {
                [textField setText:[NSString stringWithFormat:@"%ld",(long)(projectTotal * _minBuyScale + ((projectTotal * _minBuyScale - (NSInteger)(projectTotal * _minBuyScale)) > 0 ? 1 : 0))]];
            } else if(intValue > copies) {
                textField.text = [NSString stringWithFormat:@"%ld",(long)copies];
            }
            buyCopy = [textField.text intValue];
        }
        if ([_buyCopiesTextField.text integerValue] + [_guaranteedCopiesTextField.text integerValue] > copies) {
            [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(copies - [_buyCopiesTextField.text integerValue])]];
        }
        
    }
    if(textField == _guaranteedCopiesTextField) {
        if (_guaranteedCopiesTextField.text.length != 0) {
            int intValue = [_guaranteedCopiesTextField.text intValue];
            if (intValue <= 0) {
                [textField setText:@"0"];
            } else if(intValue > copies - buyCopy) {
                textField.text = [NSString stringWithFormat:@"%ld",(long)(copies - buyCopy)];
            }
            guaranteed = [textField.text intValue];
        }
    }
    
    [self showPayCount];
}

//付款
- (void)payClick:(id)sender {
    [self getDefaultValue];
    
    if (_buyCopiesTextField.text.length == 0) {
        [Globals alertWithMessage:@"请输入购买份数"];
        
        return;
    }
    
    if (buyCopy < [[self notRounding:copies * _minBuyScale afterPoint:1] intValue]) {
        NSString *str = [NSString stringWithFormat:@"购买份数不能小于%d份",[[self notRounding:copies * _minBuyScale afterPoint:1] intValue]];
        [Globals alertWithMessage:str];
        
        return;
    }
    
    if([UserInfo shareUserInfo].userID == nil) {
        UserLoginViewController *login = [[UserLoginViewController alloc]init];
        XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
        [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = loginNav;
        [self.view.window.rootViewController presentViewController:loginNav animated:YES completion:nil];
        [loginNav release];
        [login release];
    
    } else {
        [SVProgressHUD showWithStatus:@"正在提交"];
        [_orderDetailDict removeAllObjects];
        guaranteed = [_guaranteedCopiesTextField.text intValue];
        
        NSInteger temp = [[_lotteryDic objectForKey:@"lotteryid"] integerValue];
        if (_isBonusOptimization) { // 竞彩奖金优化后对阵数据合买
            
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)temp] forKey:@"lotteryId"];
            [infoDic setObject:_schemeCodes forKey:@"SchemeCodes"];
            [infoDic setObject:_gGWay forKey:@"GGWay"];
            [infoDic setObject:_investNum forKey:@"InvestNum"];
            [infoDic setObject:_playTeam forKey:@"PlayTeam"];
            [infoDic setObject:[NSString stringWithFormat:@"%d",multiple] forKey:@"Multiple"];
            [infoDic setObject:_castMoney forKey:@"CastMoney"];
            [infoDic setObject:_playTypeID forKey:@"PlayTypeID"];
            [infoDic setObject:_matchID forKey:@"MatchID"];
            [infoDic setObject:_codeFormat forKey:@"CodeFormat"];
            [infoDic setObject:@"1" forKey:@"PreBetType"];
            [infoDic setObject:_titleTextField.text == nil ? @"" : _titleTextField.text forKey:@"SchemeTitle"];
            [infoDic setObject:_memoTextField.text == nil ? @"" : _memoTextField.text forKey:@"SchemeContent"];
            [infoDic setObject:[NSString stringWithFormat:@"%d",guaranteed] forKey:@"AssureMoney"];
            [infoDic setObject:@"1" forKey:@"PreBetType"];
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)copies] forKey:@"Share"];
            [infoDic setObject:[NSString stringWithFormat:@"%d",buyCopy] forKey:@"BuyShare"];
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_secretSettingCustomSegmentedControl.selectedSegmentIndex] forKey:@"SecrecyLevel"];
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)([_winBrokerageTextField.text integerValue] > 10 ? 10 : ([_winBrokerageTextField.text integerValue] < 0 ? 0 : [_winBrokerageTextField.text integerValue])) / 100] forKey:@"SchemeBonusScale"];
            
            NSInteger buyMoney = projectTotal / copies * (buyCopy + guaranteed);
            
            [_orderDetailDict addEntriesFromDictionary:infoDic];
            [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld", (long)buyMoney] forKey:@"consumeMoney"];
            
            [self clearHTTPRequest];
            
            // 奖金优化购买数据特殊处理
            // 对阵过多，采用POST方法发送数据。
            NSString *str = [NSString stringWithFormat:@"%@", kBaseUrl];
            NSURL *urlStr1 = [NSURL URLWithString:str];
            _httpRequest = [ASIFormDataRequest requestWithURL:urlStr1];
            _httpRequest.requestMethod = @"POST";
            _httpRequest.timeOutSeconds = 60;
            //2.POST将请求参数放在请求体中
            // auth
            NSString *infoStr = [[infoDic JSONString] copy];
            NSString *currentDate = [InterfaceHelper getCurrentDateString];
            NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
            NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];

            [_httpRequest addPostValue:auth forKey:@"auth"];
            [_httpRequest addPostValue:infoStr forKey:@"info"];
            [_httpRequest addPostValue:@"72" forKey:@"opt"];
            
            [_httpRequest setDelegate:self];
            [_httpRequest startAsynchronous];

        }else {
            
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            NSMutableArray *array=[NSMutableArray array];
            [infoDic setObject:[_lotteryDic objectForKey:@"lotteryid"] forKey:@"lotteryId"];        // 彩种ID
            [infoDic setObject:[_lotteryDic objectForKey:@"isuseId"] forKey:@"isuseId"];            //
            [infoDic setObject:[NSString stringWithFormat:@"%d",multiple] forKey:@"multiple"];      // 倍数
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)copies] forKey:@"share"];           // 总份数
            [infoDic setObject:[NSString stringWithFormat:@"%d",buyCopy] forKey:@"buyShare"];       // 购买的份数
            [infoDic setObject:[NSString stringWithFormat:@"%d",guaranteed] forKey:@"assureShare"]; // 保底份数
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)([_winBrokerageTextField.text integerValue] > 10 ? 10 : ([_winBrokerageTextField.text integerValue] < 0 ? 0 : [_winBrokerageTextField.text integerValue]))] forKey:@"schemeBonusScale"];// 佣金
            [infoDic setObject:_titleTextField.text == nil ? @"" : _titleTextField.text forKey:@"title"];
            [infoDic setObject:_memoTextField.text == nil ? @"" : _memoTextField.text forKey:@"description"];
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_secretSettingCustomSegmentedControl.selectedSegmentIndex] forKey:@"secrecyLevel"];
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)projectTotal] forKey:@"schemeSumMoney"];    // 方案总金额
            
            NSInteger count = 0;
            for (NSDictionary *dict in self.buyContent) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    count += [dict intValueForKey:@"sumNum"];
                }
            }
            
            [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)count] forKey:@"schemeSumNum"];        // 方案总注数
            [infoDic setObject:_buyContent forKey:@"buyContent"];   // 购买内容
            [infoDic setObject:@"0" forKey:@"chase"];
            [infoDic setObject:@"0" forKey:@"chaseBuyedMoney"];
            [infoDic setObject:@"0" forKey:@"autoStopAtWinMoney"];
            [infoDic setObject:array forKey:@"chaseList"];
            
            NSInteger buyMoney = projectTotal / copies * (buyCopy + guaranteed);
            
            [_orderDetailDict addEntriesFromDictionary:infoDic];
            [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",(long)buyMoney] forKey:@"consumeMoney"];
            
            [self clearHTTPRequest];
            
            _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_BuyLotteryTicket userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
            [_httpRequest setDelegate:self];
            [_httpRequest startAsynchronous];
        }
    }
}

//计算佣金
- (void)selectBrokerage:(id)sender {
    for (UIView *view in _brokerageView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setSelected:NO];
        }
    }
    
    UIButton *btn = sender;
    [btn setSelected:!btn.isSelected];
    
    brokerage = btn.tag;
}

//每份金额改变调用的方法
- (void)amountChanged:(id)sender {
    CustomSegmentedControl *amountSeg = sender;
    
    switch (amountSeg.selectedSegmentIndex) {
        case 0:
            amount = 1;
            break;
        case 1:
            amount = [self isChaseTicketMoneryWithPlayId:_playId];
            break;
            
        default:
            break;
    }
    copies = projectTotal / amount;
    _buyCopiesTextField.text = [NSString stringWithFormat:@"%@",[self notRounding:copies * _minBuyScale afterPoint:1]];
    if ([_guaranteedCopiesTextField.text integerValue] > copies) {
        [_guaranteedCopiesTextField setText:[NSString stringWithFormat:@"%ld",(long)(copies - copies * _minBuyScale)]];
    }
    _copiesLabel.text = [NSString stringWithFormat:@"%ld",(long)copies];

    [self showPayCount];
}

//中奖佣金开关
- (void)brokerageSwitchValueChanged:(id)sender {
    UISwitch *swith = sender;
    CGRect lastSecondViewFrame = _secondView.frame;
    CGFloat secondViewMinY = 0.0f;
    if([swith isOn]) {
        secondViewMinY = CGRectGetMinY(lastSecondViewFrame) + kBrokerageSelectViewHight;
    } else {
        secondViewMinY = CGRectGetMinY(lastSecondViewFrame) - kBrokerageSelectViewHight;
    }
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [_secondView setFrame:CGRectMake(CGRectGetMinX(lastSecondViewFrame), secondViewMinY, CGRectGetWidth(lastSecondViewFrame), CGRectGetHeight(lastSecondViewFrame))];
    [UIView commitAnimations];
}

#pragma mark -Customized: Private (General)
//显示应付金额
- (void)showPayCount {
    if(!_buyCopiesTextField.text) {
        buyCopy = 0;
    } else {
        buyCopy = [_buyCopiesTextField.text intValue];
    }
    if(!_guaranteedCopiesTextField.text) {
        guaranteed = 0;
    }
    if(amount == 0) {
        amount = 1;
    }
    NSString *bottomText = [NSString stringWithFormat:@"%.2f",(buyCopy + guaranteed) * amount];
    CGSize bottomTextSize = [Globals defaultSizeWithString:bottomText fontSize:XFIponeIpadFontSize14];
    CGRect bottomTextLabelRect = _bottomLabel.frame;
    [_bottomLabel setFrame:CGRectMake(CGRectGetMinX(bottomTextLabelRect), CGRectGetMinY(bottomTextLabelRect), bottomTextSize.width, CGRectGetHeight(bottomTextLabelRect))];
    _bottomLabel.text = bottomText;
    
    CGRect yuanPromptLabelRect = _yuanPromptLabel.frame;
    [_yuanPromptLabel setFrame:CGRectMake(CGRectGetMaxX(_bottomLabel.frame), CGRectGetMinY(yuanPromptLabelRect), CGRectGetWidth(yuanPromptLabelRect), CGRectGetHeight(yuanPromptLabelRect))];
}

- (void)getDefaultValue {
    if(_buyCopiesTextField.text == nil) {
        buyCopy = 1;
    }
    
    if(_guaranteedCopiesTextField.text == nil) {
        guaranteed = 0;
    }
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (NSString *)notRounding:(CGFloat)price afterPoint:(int)position {
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                                      scale:position
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    [ouncesDecimal release];
    
    // 判断小数点后一位是否大于0，如果是，则整数加1
    NSString *results = [NSString stringWithFormat:@"%@",roundedOunces];
    NSString *lastStr = [results substringWithRange:NSMakeRange(results.length - 1, 1)];
    NSArray *ar = [results componentsSeparatedByString:@"."];
    NSString *firstStr = [ar objectAtIndex:0];
    NSInteger first = [firstStr integerValue];
    if ([lastStr integerValue] > 0 && [ar count] > 1)
        first += 1;
    if (first == 0) {
        first = 1;
    }
    return [NSString stringWithFormat:@"%ld",(long)first];
}

- (NSInteger)isChaseTicketMoneryWithPlayId:(NSInteger)playId {
    return [self isChaseTicketWithPlayId:playId] ? 3 : 2;
}

- (BOOL)isChaseTicketWithPlayId:(NSInteger)playId {
    if (playId == 3902 || playId == 3904 || playId == 3908 || playId == 3909) {
        return YES;
    }
    return NO;
}

@end
