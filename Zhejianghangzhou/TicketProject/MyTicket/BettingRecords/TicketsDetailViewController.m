//
//  TicketsDetailViewController.m  个人中心－普通投注详情
//  TicketProject
//
//  Created by sls002 on 13-6-17.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140818 16:01（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//20140818 16:21（洪晓彬）：进行ipad适配

#import "TicketsDetailViewController.h"
#import "BaseBetViewController.h"
#import "HomeViewController.h"
#import "SVProgressHUD.h"

#import "Globals.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "XFTabBarViewController.h"

#import "GlobalsProject.h"


#define JCBetDetailCellHeight (IS_PHONE ? 62.0f : 100.0f)
#define NormalDetailCellHeight (IS_PHONE ? 35.0f : 50.0f)
#define NormalTicketsDetailViewControllerTabelHeadViewHeight (IS_PHONE ? 27.0 : 60.0f)
#define NormalTicketsDetailViewControllerTabelFootViewHeight (IS_PHONE ? 100.0 : 150.0f)
#define kBottomContainLabelHeight (IS_PHONE ? 25.0f : 30.0f)

#define lotteryLabelFontSize XFIponeIpadFontSize12

#define playTypeLabelMinX (IS_PHONE ? 14.0 : 28.0f)
#define playTypeLabelWidth (IS_PHONE ? 68.0f : 120.0f)
#define numberLabelWidth (IS_PHONE ? 220.0f : 580.0f)


#define JCFisttLabelMinY (IS_PHONE ? 10.0f : 20.0f)
#define JCFisrtLabelHeight (IS_PHONE ? 30.0f : 45.0f)

// 优化前表格顶部标签宽度
#define JCDefaultLabelWidth (kWinSize.width - 10) / 8
#define JCFisrtColLabelMinX (kWinSize.width - kWinSize.width * (309.0f / 320.0)) / 2.0f

// 优化后表格顶部标签宽度
#define JCOptLabelWidth (kWinSize.width - 10) / 7

#define JCTableCellOneLineHeight (IS_PHONE ? 30.0f : 45.0f)

@interface TicketsDetailViewController (){
    UILabel *pickDetailsPromptLabel;//选号详情
    UILabel *_registNameLabel;      //发起人
    NSString *openString;           //开奖号码
    NSString *_passString;          //过关方式
}
@property(nonatomic)BOOL isForTicket;
/** 为界面填充数据 */
- (void)fillView;
/** 向服务器请求竞彩数据 */
- (void)jcDetailRequest;
@end

#pragma mark -
#pragma mark @implementation TicketsDetailViewController
@implementation TicketsDetailViewController
#pragma mark Lifecircle

- (id)initWithInfoDic:(NSDictionary *)infoDic withLotteryID:(NSInteger)lotteryid orderStatus:(OrderStatus)status {
    self = [super init];
    if(self) {
        _originalTabBarState = self.xfTabBarController.tabBarHidden;
        [self.xfTabBarController setTabBarHidden:YES];
        _detailDic = [infoDic retain];
        NSLog(@"_detaildic:\n%@",_detailDic);
        _lotteryID = [[NSString stringWithFormat:@"%ld",(long)lotteryid] retain];
        _orderStatus = status;
        _numberDict = [[NSMutableDictionary alloc] init];

        [GlobalsProject parserBetNumberWithRecordDictionart:_detailDic numberDictionary:_numberDict];
        
        [self setTitle:@"普通投注详情"];
    }
    return self;
}

- (id)initWithInfoDic_forTicket:(NSDictionary *)infoDic withLotteryID:(NSInteger)lotteryid orderStatus:(OrderStatus)status {
    self = [super init];
    if(self) {
        _originalTabBarState = self.xfTabBarController.tabBarHidden;
        self.isForTicket = YES;
        _detailDic = [infoDic retain];
        _lotteryID = [[NSString stringWithFormat:@"%ld",(long)lotteryid] retain];
        _orderStatus = status;
        _numberDict = [[NSMutableDictionary alloc] init];
        [GlobalsProject parserBetNumberWithRecordDictionart:_detailDic numberDictionary:_numberDict];
        [self setTitle:@"追号投注详情"];
    }
    return self;
}

- (void)dealloc {
    
    _scrollView = nil;
    _logoImageView = nil;
    _lotteryNameLabel = nil;
    
    _solutionSumLabel = nil;
    _orderStatusLabel = nil;
    _betCountLabel = nil;
    
    _openNumberLabel = nil;
    _pickDetailsLabel = nil;
    _betNumberLabel = nil;
    
    _bottomContainView = nil;
    _orderNumberLabel = nil;
    _nextSingleTimeLabel = nil;
    
    [_numberDict release];
    _numberDict = nil;
    [_detailDic release];
    [_dropDic release];
    _dropDic = nil;
    [_matchDeitalArray release];
    _matchDeitalArray = nil;
    [_promptLabelTitleArray release];
    _promptLabelTitleArray = nil;
    [_optimizationLabelTitleArray release];
    _optimizationLabelTitleArray = nil;
    [_lotteryID release];
    [_lotteryIDArray release];
    _lotteryIDArray = nil;
    [_imageArray release];
    _imageArray = nil;
    
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
    
    //scrollView 整个滑动视图
    CGRect scrollViewRect = CGRectMake(CGRectGetMinX(appRect), CGRectGetMinY(appRect), CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f);
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setMultipleTouchEnabled:NO];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstBackImageViewHeight = IS_PHONE ? 48.0f : 88.0f;//头部背景的高度
    CGSize logoSize = IS_PHONE ? CGSizeMake(35.0f, 35.0f) : CGSizeMake(60.0f, 60.0f);//彩种图标大小
    CGFloat lotteryNameLabelWidth = IS_PHONE ? 70.0f : 120.0f;
    CGFloat isuseNameLabelAddX = IS_PHONE ? 5.0f : 10.0f;
    CGFloat logoImageMinX = IS_PHONE ? 10.0f : 34.0f;//彩种图标与左边的距离
    CGFloat lotteryNameLabelInterval = IS_PHONE ? 6.0f :32.0f;//彩种名和彩种图标的距离
    CGFloat lotteryNameLabelHeight = IS_PHONE ? 21.0f : 30.0f; //彩种名高度
    /********************** adjustment end ***************************/
    
    //firstBackImageView 头部背景
    CGRect firstBackImageViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), firstBackImageViewHeight);
    UIImageView *firstBackImageView = [[UIImageView alloc] initWithFrame:firstBackImageViewRect];
    [firstBackImageView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:firstBackImageView];
    [firstBackImageView release];
    
    //lineView1
    CGRect lineView1Rect  =CGRectMake(0, CGRectGetHeight(firstBackImageViewRect) - AllLineWidthOrHeight, CGRectGetWidth(firstBackImageViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:lineView1Rect inSuperView:firstBackImageView];
    
    //logoView 彩种图标
    CGRect logoImageViewRect = CGRectMake(logoImageMinX, (CGRectGetHeight(firstBackImageViewRect) - logoSize.height) / 2, logoSize.width, logoSize.height);
    _logoImageView = [[UIImageView alloc] initWithFrame:logoImageViewRect];
    [_logoImageView setBackgroundColor:[UIColor clearColor]];
    [firstBackImageView addSubview:_logoImageView];
    [_logoImageView release];
    
    //lotteryNameLabel 彩种名
    CGRect lotteryNameLabelRect = CGRectMake(CGRectGetMaxX(logoImageViewRect) + lotteryNameLabelInterval, CGRectGetMinY(logoImageViewRect) + 5, lotteryNameLabelWidth, lotteryNameLabelHeight) ;
    _lotteryNameLabel = [[UILabel alloc] initWithFrame:lotteryNameLabelRect];
    [_lotteryNameLabel setBackgroundColor:[UIColor clearColor]];
    [_lotteryNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_lotteryNameLabel setTextAlignment:NSTextAlignmentLeft];
    [firstBackImageView addSubview:_lotteryNameLabel];
    [_lotteryNameLabel release];
    
    //_isuseNameLabel 期号
    CGRect isuseNameLabelRect = CGRectMake(CGRectGetMaxX(lotteryNameLabelRect) + isuseNameLabelAddX, CGRectGetMinY(lotteryNameLabelRect), CGRectGetWidth(firstBackImageViewRect) - CGRectGetMaxX(lotteryNameLabelRect) - isuseNameLabelAddX, CGRectGetHeight(lotteryNameLabelRect));
    _isuseNameLabel = [[UILabel alloc] initWithFrame:isuseNameLabelRect];
    [_isuseNameLabel setBackgroundColor:[UIColor clearColor]];
    [_isuseNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_isuseNameLabel setTextAlignment:NSTextAlignmentLeft];
    [_isuseNameLabel setTextColor:kGrayColor];
    [firstBackImageView addSubview:_isuseNameLabel];
    [_isuseNameLabel release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat secondImageViewHeight = IS_PHONE ? 43.0f : 90.0f;//第二视图的高度
    CGFloat secondViewLabelInterval = IS_PHONE ? 1.0f : 5.0f;//第二视图中垂直方向label之间的距离
    CGFloat secondViewLabelHeight = IS_PHONE ? 21.0f : 30.0f;//第二视图中所有label的高度
    
    CGFloat sawToothHeight = IS_PHONE ? 13.0f : 26.0f;
    
    CGFloat incisionImageViewWidth = IS_PHONE ? 1.0f : 2.0f;
    CGFloat incisionImageViewHeight = IS_PHONE ? 36.0f : 58.0f;
    /********************** adjustment end ***************************/
    
    //secondImageView  第二背景图
    CGRect secondImageViewRect = CGRectMake(CGRectGetMinX(firstBackImageViewRect), CGRectGetMaxY(firstBackImageViewRect), CGRectGetWidth(firstBackImageViewRect), secondImageViewHeight);
    UIImageView *secondImageView = [[UIImageView alloc] initWithFrame:secondImageViewRect];
    [secondImageView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:secondImageView];
    [secondImageView release];
    
    //sawToothImageView
    CGRect sawToothImageViewRect = CGRectMake(CGRectGetMinX(secondImageViewRect), CGRectGetMaxY(secondImageViewRect), CGRectGetWidth(secondImageViewRect), sawToothHeight);
    UIImageView *sawToothImageView = [[UIImageView alloc] initWithFrame:sawToothImageViewRect];
    [sawToothImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"sawtooth.png"]]];
    [_scrollView addSubview:sawToothImageView];
    [sawToothImageView release];
    
    //winningTextPromptLabel 订单金额－提示文字
    CGRect winningTextPromptLabelRect = CGRectMake(0, (CGRectGetHeight(secondImageViewRect) - secondViewLabelHeight * 2 - secondViewLabelInterval) / 2, CGRectGetWidth(secondImageViewRect) / 3, secondViewLabelHeight);
    UILabel *winningTextPromptLabel = [[UILabel alloc] initWithFrame:winningTextPromptLabelRect];
    [winningTextPromptLabel setBackgroundColor:[UIColor clearColor]];
    [winningTextPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [winningTextPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [winningTextPromptLabel setTextColor:[UIColor colorWithRed:0x88/255.0f green:0x84/255.0f blue:0x74/255.0f alpha:1.0f]];
    [winningTextPromptLabel setText:@"订单金额"];
    [secondImageView addSubview:winningTextPromptLabel];
    [winningTextPromptLabel release];
    
    //solutionSumLabel  订单金额
    CGRect solutionSumLabelRect = CGRectMake(CGRectGetMinX(winningTextPromptLabelRect), CGRectGetMaxY(winningTextPromptLabelRect) + secondViewLabelInterval, CGRectGetWidth(winningTextPromptLabelRect), secondViewLabelHeight);
    _solutionSumLabel = [[UILabel alloc] initWithFrame:solutionSumLabelRect];
    [_solutionSumLabel setBackgroundColor:[UIColor clearColor]];
    [_solutionSumLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_solutionSumLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [_solutionSumLabel setTextAlignment:NSTextAlignmentCenter];
    [secondImageView addSubview:_solutionSumLabel];
    [_solutionSumLabel release];
    
    //incisionImageView1
    CGRect incisionImageView1Rect = CGRectMake(CGRectGetMaxX(winningTextPromptLabelRect) - incisionImageViewWidth / 2.0f, (secondImageViewHeight + sawToothHeight - incisionImageViewHeight) / 2.0f, incisionImageViewWidth, incisionImageViewHeight);
    UIImageView *incisionImageView1 = [[UIImageView alloc] initWithFrame:incisionImageView1Rect];
    [incisionImageView1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"incision.png"]]];
    [secondImageView addSubview:incisionImageView1];
    [incisionImageView1 release];
    
    //resultStrPromptLabel  订单状态－提示文字
    CGRect resultStrPromptLabelRect = CGRectMake(CGRectGetMaxX(winningTextPromptLabelRect), CGRectGetMinY(winningTextPromptLabelRect), CGRectGetWidth(winningTextPromptLabelRect), secondViewLabelHeight);
    UILabel *resultStrPromptLabel = [[UILabel alloc] initWithFrame:resultStrPromptLabelRect];
    [resultStrPromptLabel setBackgroundColor:[UIColor clearColor]];
    [resultStrPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [resultStrPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [resultStrPromptLabel setTextColor:[UIColor colorWithRed:0x88/255.0f green:0x84/255.0f blue:0x74/255.0f alpha:1.0f]];
    [resultStrPromptLabel setText:@"订单状态"];
    [secondImageView addSubview:resultStrPromptLabel];
    [resultStrPromptLabel release];
    
    //orderStatusLabel  订单状态
    CGRect orderStatusLabelRect = CGRectMake(CGRectGetMaxX(solutionSumLabelRect), CGRectGetMinY(solutionSumLabelRect), CGRectGetWidth(solutionSumLabelRect), secondViewLabelHeight);
    _orderStatusLabel = [[UILabel alloc] initWithFrame:orderStatusLabelRect];
    [_orderStatusLabel setBackgroundColor:[UIColor clearColor]];
    [_orderStatusLabel setTextColor:[UIColor colorWithRed:217.0f/256.0f green:32.0f/256.0f blue:0.0f/256.0f alpha:1.0f]];
    [_orderStatusLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_orderStatusLabel setText:@"--"];
    [_orderStatusLabel setTextColor:kRedColor];
    [_orderStatusLabel setTextAlignment:NSTextAlignmentCenter];
    [secondImageView addSubview:_orderStatusLabel];
    [_orderStatusLabel release];
    
    //incisionImageView2
    CGRect incisionImageView2Rect = CGRectMake(CGRectGetMaxX(resultStrPromptLabelRect) - incisionImageViewWidth / 2.0f, (secondImageViewHeight + sawToothHeight - incisionImageViewHeight) / 2.0f, incisionImageViewWidth, incisionImageViewHeight);
    UIImageView *incisionImageView2 = [[UIImageView alloc] initWithFrame:incisionImageView2Rect];
    [incisionImageView2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"incision.png"]]];
    [secondImageView addSubview:incisionImageView2];
    [incisionImageView2 release];
    
    //betCountPromptLabel  奖金－提示文字
    CGRect betCountPromptLabelRect = CGRectMake(CGRectGetMaxX(resultStrPromptLabelRect), CGRectGetMinY(resultStrPromptLabelRect), CGRectGetWidth(winningTextPromptLabelRect), secondViewLabelHeight);
    UILabel *betCountPromptLabel = [[UILabel alloc] initWithFrame:betCountPromptLabelRect];
    [betCountPromptLabel setBackgroundColor:[UIColor clearColor]];
    [betCountPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [betCountPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [betCountPromptLabel setTextColor:[UIColor colorWithRed:0x88/255.0f green:0x84/255.0f blue:0x74/255.0f alpha:1.0f]];
    [betCountPromptLabel setText:@"奖金"];
    [secondImageView addSubview:betCountPromptLabel];
    [betCountPromptLabel release];
    
    //betCountLabel  奖金
    CGRect betCountLabelRect = CGRectMake(CGRectGetMinX(betCountPromptLabelRect), CGRectGetMinY(orderStatusLabelRect), CGRectGetWidth(betCountPromptLabelRect), secondViewLabelHeight);
    _betCountLabel = [[UILabel alloc] initWithFrame:betCountLabelRect];
    [_betCountLabel setBackgroundColor:[UIColor clearColor]];
    [_betCountLabel setTextColor:kRedColor];
    [_betCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_betCountLabel setMinimumScaleFactor:0.5];
    [_betCountLabel setAdjustsFontSizeToFitWidth:YES];
    [_betCountLabel setText:@"--"];
    [_betCountLabel setTextAlignment:NSTextAlignmentCenter];
    [secondImageView addSubview:_betCountLabel];
    [_betCountLabel release];
    
    [_scrollView setContentSize:CGSizeMake(kWinSize.width, kWinSize.height + CGRectGetMaxY(sawToothImageViewRect) - 44.0f)];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat openNumberPromptLabelMinX = IS_PHONE ? 14.0f : 25.0f;//开奖号码－提示文字的x坐标
    CGFloat openNumberPromptLabelWidth = IS_PHONE ? 68.0f : 100.0f;//开奖号码－提示文字的宽度
    
    CGFloat threePartLabelVerticalInterval = IS_PHONE ? 8.0f : 15.0f;//第三部份控件部分的垂直距离
    
    CGFloat tableViewAddY = 5.0f;
    /********************** adjustment end ***************************/
    
    BOOL isJC = ([_lotteryID integerValue] == 72 || [_lotteryID integerValue] == 73 || [_lotteryID integerValue] == 45);
    
    //是否复制
    BOOL iscCopy = [[_detailDic stringForKey:@"isCopy"] isEqualToString:@"True"];
    NSLog(@"%@",_detailDic);
    
    //openNumberPromptLabel 开奖号码－提示文字
    CGRect registPromptLabelRect = CGRectMake(openNumberPromptLabelMinX, CGRectGetMaxY(sawToothImageViewRect) + threePartLabelVerticalInterval, openNumberPromptLabelWidth, secondViewLabelHeight);
    UILabel *registPromptLabel = [[UILabel alloc] initWithFrame:registPromptLabelRect];
    [registPromptLabel setBackgroundColor:[UIColor clearColor]];
    [registPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [registPromptLabel setText:@"发起人:"];
    [_scrollView addSubview:registPromptLabel];
    [registPromptLabel release];
    [registPromptLabel setHidden:!iscCopy];
    
    
    //发起人
    CGRect registNamelRect = CGRectMake(CGRectGetMaxX(registPromptLabelRect), CGRectGetMinY(registPromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(registPromptLabelRect), secondViewLabelHeight);
    _registNameLabel = [[UILabel alloc] initWithFrame:registNamelRect];
    [_registNameLabel setBackgroundColor:[UIColor clearColor]];
    [_registNameLabel setTextColor:[UIColor colorWithRed:0xe3/256.0f green:0x39/256.0f blue:0x3c/256.0f alpha:1.0f]];
    [_registNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_scrollView addSubview:_registNameLabel];
    [_registNameLabel release];
    [_registNameLabel setText:[NSString stringWithFormat:@"%@",[_detailDic stringForKey:@"initiateName"]]];
    NSLog(@"发起人%@\nhiddent:%i",[_detailDic stringForKey:@"initiateName"],iscCopy);
    [_registNameLabel setHidden:!iscCopy];
    
    //openNumberPromptLabel 开奖号码－提示文字
    CGRect openNumberPromptLabelRect = CGRectMake(openNumberPromptLabelMinX, CGRectGetMaxY(registPromptLabelRect) + threePartLabelVerticalInterval, openNumberPromptLabelWidth, secondViewLabelHeight);
    if (registPromptLabel.hidden) {
        openNumberPromptLabelRect = CGRectMake(openNumberPromptLabelMinX, CGRectGetMaxY(sawToothImageViewRect) + threePartLabelVerticalInterval, openNumberPromptLabelWidth, secondViewLabelHeight);
    }
    UILabel *openNumberPromptLabel = [[UILabel alloc] initWithFrame:openNumberPromptLabelRect];
    [openNumberPromptLabel setBackgroundColor:[UIColor clearColor]];
    [openNumberPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    if (isJC) {
        [openNumberPromptLabel setText:@"投注信息:"];
    }else {
        [openNumberPromptLabel setText:@"开奖号码:"];
    }
    [_scrollView addSubview:openNumberPromptLabel];
    [openNumberPromptLabel release];
    
//    //openNumberLabel 开奖号码
    CGRect openNumberLabelRect = CGRectMake(CGRectGetMaxX(openNumberPromptLabelRect), CGRectGetMaxY(registNamelRect) + threePartLabelVerticalInterval, CGRectGetWidth(appRect) - CGRectGetMaxX(openNumberPromptLabelRect), secondViewLabelHeight);
    
    if (registPromptLabel.hidden) {
        openNumberLabelRect =  CGRectMake(CGRectGetMaxX(registPromptLabelRect), CGRectGetMinY(registPromptLabelRect), CGRectGetWidth(appRect) - CGRectGetMaxX(registPromptLabelRect), secondViewLabelHeight);
    }
    
    _openNumberLabel = [[UILabel alloc] initWithFrame:openNumberLabelRect];
    [_openNumberLabel setBackgroundColor:[UIColor clearColor]];
    [_openNumberLabel setTextColor:[UIColor colorWithRed:0xe3/256.0f green:0x39/256.0f blue:0x3c/256.0f alpha:1.0f]];
    [_openNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_scrollView addSubview:_openNumberLabel];
    [_openNumberLabel release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat bottomBtnMaginX = IS_PHONE ? 0.0f : 0.0f;
    CGFloat bottomBtnWidth = (CGRectGetWidth(appRect) - bottomBtnMaginX * 3) / 2.0;
    
    CGFloat betBtnMinX = 0.0f;
    /********************** adjustment end ***************************/

    CGRect lotteryNumberTableView = CGRectMake(0,(CGRectGetMaxY(openNumberLabelRect) + tableViewAddY), CGRectGetWidth(appRect), _scrollView.contentSize.height - (CGRectGetMaxY(openNumberLabelRect)) - 44.0f);
    _lotteryNumberTableView = [[UITableView alloc]initWithFrame:lotteryNumberTableView style:UITableViewStylePlain];
    [_lotteryNumberTableView setBackgroundColor:kBackgroundColor];
    [_lotteryNumberTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_lotteryNumberTableView setDataSource:self];
    [_lotteryNumberTableView setDelegate:self];
    [_scrollView addSubview:_lotteryNumberTableView];
    [_lotteryNumberTableView release];
    
    
    //bottomView 底部框
    CGRect bottomViewRect = CGRectMake(0, CGRectGetHeight(appRect) - kBottomHeight -44.0f, CGRectGetWidth(appRect), kBottomHeight);
    UIView *bottomView = [[UIView alloc] initWithFrame:bottomViewRect];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setUserInteractionEnabled:YES];
    [self.view addSubview:bottomView];
    [bottomView release];
    
    //continueBetNumberBtn 继续投注号码按钮
    CGRect continueBetNumberBtnRect = CGRectMake(bottomBtnMaginX, 0, bottomBtnWidth, kBottomHeight);
    UIButton *continueBetNumberBtn = [[UIButton alloc] initWithFrame:continueBetNumberBtnRect];
    [continueBetNumberBtn setBackgroundColor:[UIColor colorWithRed:138.0/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1.0f]];
    [continueBetNumberBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [continueBetNumberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueBetNumberBtn setTitle:@"继续投注本次号码" forState:UIControlStateNormal];
    [continueBetNumberBtn setHidden:![GlobalsProject recordContinueBet:[_lotteryID intValue]]];
    [continueBetNumberBtn addTarget:self action:@selector(gotoContinueBetNumber:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:continueBetNumberBtn];
    [continueBetNumberBtn release];
    
    //betBtn 投注按钮
    betBtnMinX = CGRectGetMaxX(continueBetNumberBtnRect) + bottomBtnMaginX;
    if (![GlobalsProject recordContinueBet:[_lotteryID intValue]]) {
        betBtnMinX = 0;
        bottomBtnWidth = CGRectGetWidth(appRect);
    }
    CGRect betBtnRect = CGRectMake(betBtnMinX, 0, bottomBtnWidth, kBottomHeight);
    UIButton *betBtn = [[UIButton alloc] initWithFrame:betBtnRect];
    [betBtn setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:159.0f/255.0f blue:29.0f/255.0f alpha:1.0f]];
    [betBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [betBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [betBtn setTitle:[NSString stringWithFormat:@"%@投注",[_detailDic objectForKey:@"lotteryName"]] forState:UIControlStateNormal];
    [betBtn addTarget:self action:@selector(gotoBet:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:betBtn];
    [betBtn release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    _matchDeitalArray = [[NSMutableArray alloc] init];
    
    _dropDic = [[NSMutableDictionary alloc] init];
    _promptLabelTitleArray = [[NSMutableArray alloc] initWithObjects:@"场次",@"主队VS客队",@"玩法",@"投注",@"赛果", nil];
    _optimizationLabelTitleArray = [[NSMutableArray alloc] initWithObjects:@"序号",@"过关方式",@"注数",@"投注内容",@"赛果", nil];
    //第一次加载  全部展开 分为已追和未追
    for (NSInteger i = 0; i < 2; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_dropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    
    NSDictionary *dic = [InterfaceHelper getLotteryIDNameDic];
    _lotteryIDArray = [[dic objectForKey:@"id"] retain];
    _imageArray = [[dic objectForKey:@"image"] retain];
    
    [self fillView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //设置发起人隐藏
    if (_registNameLabel.text && _registNameLabel.text.length>2) {
        _registNameLabel.text = [NSString stringWithFormat:@"%@**",[_registNameLabel.text substringToIndex:_registNameLabel.text.length-2]];
    }
    
    //设置已中奖状态
    if ([[_detailDic objectForKey:@"winMoneyNoWithTax"] integerValue] > 0) {
        _orderStatusLabel.text = @"已中奖";
    }
    
    _pushView = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _scrollView = nil;
        _logoImageView = nil;
        _lotteryNameLabel = nil;
        
        _solutionSumLabel = nil;
        _orderStatusLabel = nil;
        _betCountLabel = nil;
        
        _openNumberLabel = nil;
        _pickDetailsLabel = nil;
        _betNumberLabel = nil;
        
        _bottomContainView = nil;
        _orderNumberLabel = nil;
        _nextSingleTimeLabel = nil;
        
        [_lotteryIDArray release];
        _lotteryIDArray = nil;
        [_imageArray release];
        _imageArray = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisAppear:(BOOL)animated {
    [self clearJCRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_matchDeitalArray.count != 0) {
        NSArray *arr = [_matchDeitalArray[0] objectForKey:@"optimization"];
        if (arr.count != 0) {
            return 2;
        }
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
            
    BOOL isDropdown = [[dic objectForKey:@"isDropDown"] boolValue];
    NSInteger dropSection = [[dic objectForKey:@"dropSection"] intValue];
    //如果不是下拉状态 并且选中的section相等 则返回0  实现收缩的效果
    if(!isDropdown && dropSection == section) {
        return 0;
    }
    
    if ([_lotteryID integerValue] != 72 && [_lotteryID integerValue] != 73 && [_lotteryID integerValue] != 45) {
        if (section == 0) {
            NSArray *buyContentArray = [_detailDic objectForKey:@"buyContent"];
            if ([buyContentArray count] > 0) {
                return [buyContentArray count];
            }
        }
    } else {
        if (section == 0) {
            if (_matchDeitalArray.count != 0) {
                NSArray *arr = [_matchDeitalArray[0] objectForKey:@"informationId"];
                
                return [arr count];
            }
            
        } else {
            if (_matchDeitalArray.count != 0) {
                NSArray *arr = [_matchDeitalArray[0] objectForKey:@"optimization"];
                
                return [arr count];
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([_lotteryID integerValue] != 72 && [_lotteryID integerValue] != 73 && [_lotteryID integerValue] != 45) {
        /********************** adjustment 控件调整 ***************************/
        CGFloat lineMinX = 10.0f;
        /********************** adjustment end ***************************/
        static NSString *ticketsCellIdentifier = @"TicketsDetailViewNormalCell";
        cell = [tableView dequeueReusableCellWithIdentifier:ticketsCellIdentifier];
        CGFloat cellHeight = [self tableCellHeight:indexPath tableView:tableView];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ticketsCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //playTypeLabel
            CGRect playTypeLabelRect = CGRectMake(playTypeLabelMinX, 0, playTypeLabelWidth, cellHeight);
            UILabel *playTypeLabel = [[UILabel alloc]initWithFrame:playTypeLabelRect];
            [playTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [playTypeLabel setBackgroundColor:[UIColor clearColor]];
            [playTypeLabel setTextAlignment:NSTextAlignmentLeft];
            [playTypeLabel setTextColor:kGrayColor];
            [playTypeLabel setMinimumScaleFactor:0.75];
            [playTypeLabel setAdjustsFontSizeToFitWidth:YES];
            [playTypeLabel setTag:2600];
            [cell.contentView addSubview:playTypeLabel];
            [playTypeLabel release];
            
            //numbersLabel
            CGRect numbersLabelRect = CGRectMake(CGRectGetMaxX(playTypeLabelRect), 0, numberLabelWidth, cellHeight);
            CustomLabel *numbersLabel = [[CustomLabel alloc]initWithFrame:numbersLabelRect];
            [numbersLabel setBackgroundColor:[UIColor clearColor]];
            [numbersLabel setTextAlignment:NSTextAlignmentCenter];
            [numbersLabel setFont:[UIFont systemFontOfSize:lotteryLabelFontSize]];
            [numbersLabel setTag:2601];
            [cell.contentView addSubview:numbersLabel];
            [numbersLabel release];
            
            //lineView
            CGRect lineViewRect = CGRectMake(lineMinX, cellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame) - lineMinX, AllLineWidthOrHeight);
            UIView *lineView = [[UIView alloc]initWithFrame:lineViewRect];
            [lineView setBackgroundColor:kLightGrayColor];
            [lineView setTag:2602];
            [cell.contentView addSubview:lineView];
            [lineView release];
        }
        
        //playTypeLabel
        UILabel *playTypeLabel = (UILabel *)[cell.contentView viewWithTag:2600];
        CGRect playTypeLabelRect = CGRectMake(playTypeLabelMinX, 0, playTypeLabelWidth, cellHeight);
        [playTypeLabel setFrame:playTypeLabelRect];
        
        //numbersLabel
        CustomLabel *numbersLabel = (CustomLabel *)[cell.contentView viewWithTag:2601];
        
        //lineView
        CGRect lineViewRect;
        UIView *lineView = (UIView *)[cell.contentView viewWithTag:2602];
        
        NSArray *buyContentArray = [_detailDic objectForKey:@"buyContent"];
        
        if (indexPath.row == [buyContentArray count] - 1) {
            lineViewRect = CGRectMake(0, cellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        } else {
            lineViewRect = CGRectMake(lineMinX, cellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame) - lineMinX, AllLineWidthOrHeight);
        }
        [lineView setFrame:lineViewRect];
        
        
        if ([buyContentArray count] > 0 && indexPath.row < [buyContentArray count]) {
            NSArray *numberArray = [buyContentArray objectAtIndex:indexPath.row];
            
            if ([numberArray count] > 0) {
                NSDictionary *oneLotteryDict;
                if ([numberArray isKindOfClass:[NSArray class]]) {
                    oneLotteryDict = [numberArray objectAtIndex:0];
                } else {
                    oneLotteryDict = [NSDictionary dictionaryWithDictionary:(NSDictionary *)numberArray];
                }
                
                NSString *numbers = [oneLotteryDict objectForKey:@"lotteryNumber"];
                NSInteger playType = [[oneLotteryDict objectForKey:@"playType"] integerValue];
                NSString *playName = [GlobalsProject judgeRecordPlayNameWithLotteryID:[_lotteryID integerValue] playId:playType number:numbers];
                [playTypeLabel setText:playName];
                
                numbers = [numbers stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSString *colorText = nil;
                
                NSDictionary *colorDetailDict = [_numberDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                if (colorDetailDict) {
                    colorText = [colorDetailDict objectForKey:@"colorText"];
                }
                
                if (colorText.length == 0) {
                    if ([_lotteryID integerValue] == 5 || [_lotteryID integerValue] == 39) {
                        NSArray *array = [numbers componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+"]];
                        if ([array count] > 1) {
                            NSString *redNumber=[[array objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            NSString *blueNumber= [[array objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            colorText = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font><font color=\"%@\">%@</font>",tRedColorText,redNumber,tBlueColorText,blueNumber];
                        }
                    } else {
                        colorText = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font>",tRedColorText,numbers];
                    }
                }
                
                MarkupParser *p = [[MarkupParser alloc]initWithFontSize:lotteryLabelFontSize];
                NSAttributedString *attString = [p attrStringFromMarkup:colorText];
                [p release];
                
                CGRect attStringRect;
                if (IS_IOS7) {
                    attStringRect = [attString boundingRectWithSize:CGSizeMake(numberLabelWidth, NSIntegerMax) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                } else {
                    CGSize textSize = [numbers sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13] constrainedToSize:CGSizeMake(numberLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
                    attStringRect = CGRectMake(0, 0, textSize.width, textSize.height);
                }
                
                // 定义中奖信息位置、大小。（由于是把画出来，所以位置、大小很重要。否则看不到结果）
                CGRect numbersLabelRect = CGRectMake(CGRectGetMaxX(playTypeLabelRect), (cellHeight - attStringRect.size.height - (IS_PHONE ? 2.0f : 4.0f)) / 2.0f, attStringRect.size.width + 20, attStringRect.size.height + (IS_PHONE ? 2.0f : 4.0f)+20);
                [numbersLabel setFrame:numbersLabelRect];
                [numbersLabel setAttString:attString];
                [numbersLabel setNeedsDisplay];
            }
        }
        
    } else {
        static NSString *JCCellIdentifier = @"JCMatchDetailCell";
        cell = [tableView dequeueReusableCellWithIdentifier:JCCellIdentifier];
        CGFloat cellHeight = [self tableCellHeight:indexPath tableView:tableView];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JCCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:kBackgroundColor];
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat labelMinX = JCFisrtColLabelMinX;
        /********************** adjustment end ***************************/
        NSArray *arr;
        
        if (indexPath.section == 0) { // 竞彩未优化数据UI布局
            arr = [_matchDeitalArray[0] objectForKey:@"informationId"];
            
            NSMutableDictionary *oneMatchDetailDict = arr[indexPath.row]; //该数组的数据都是IOS自己处理过的，不是服务器原始数据
            NSInteger oneMatchCount = [oneMatchDetailDict intValueForKey:@"oneMatchCount"];
            //dateLabel
            CGRect dateLabelRect = CGRectMake(JCFisrtColLabelMinX - AllLineWidthOrHeight - 1, - AllLineWidthOrHeight, JCDefaultLabelWidth + 10, cellHeight + AllLineWidthOrHeight);
            [self makeLabelWithFrame:dateLabelRect title:[oneMatchDetailDict objectForKey:@"matchTime"] superView:cell.contentView isColor:NO];
            
            labelMinX = CGRectGetMaxX(dateLabelRect);
            
            //teamLabel
            CGRect teamLabelRect = CGRectMake(labelMinX - AllLineWidthOrHeight, - AllLineWidthOrHeight, JCDefaultLabelWidth * 2 + AllLineWidthOrHeight, cellHeight + AllLineWidthOrHeight);
            [self makeLabelWithFrame:teamLabelRect title:[oneMatchDetailDict objectForKey:@"teamsMessage"] superView:cell.contentView isColor:NO];
            
            labelMinX = CGRectGetMaxX(teamLabelRect);
            
            /********************** adjustment 控件调整 ***************************/
            CGFloat playTypeLabelMinY = 0.0f;
            CGFloat oddLabelMinY = 0.0f;
            CGFloat oddLabelMinX = 0.0f;
            /********************** adjustment end ***************************/
            
            NSArray *jcPlayTypeDetailNumberArray = [oneMatchDetailDict objectForKey:@"jcPlayTypeDetailNumber"];
            CGFloat letball = [oneMatchDetailDict floatValueForKey:@"letBall"];
            
            for (NSInteger i = 0; i < [jcPlayTypeDetailNumberArray count]; i++) {
                
                NSDictionary *jcPlayTypeDetailNumberDict = [jcPlayTypeDetailNumberArray objectAtIndex:i];
                NSInteger playTypeCount = [jcPlayTypeDetailNumberDict intValueForKey:@"playTypeMatchCount"];
                
                //playTypeLabel
                CGRect playTypeLabelRect = CGRectMake(labelMinX - AllLineWidthOrHeight,playTypeLabelMinY - AllLineWidthOrHeight, JCDefaultLabelWidth * 2 - 10 + AllLineWidthOrHeight, oneMatchCount < 2 ? (JCTableCellOneLineHeight * 2 + AllLineWidthOrHeight) : (playTypeCount * JCTableCellOneLineHeight + AllLineWidthOrHeight));
                
                NSString *playName = @"";
                if ([[jcPlayTypeDetailNumberDict stringForKey:@"isLet"] isEqualToString:@"YES"]) {
                    if (letball > 0) {
                        if ([_lotteryID isEqualToString:@"72"] || [_lotteryID isEqualToString:@"45"]) {
                            playName = [NSString stringWithFormat:@"%@(+%ld)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],(long)letball];
                        } else {
                            playName = [NSString stringWithFormat:@"%@(+%.1f)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],letball];
                        }
                        
                    } else {
                        if ([_lotteryID isEqualToString:@"72"] || [_lotteryID isEqualToString:@"45"]) {
                            playName = [NSString stringWithFormat:@"%@(%ld)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],(long)letball];
                        } else {
                            playName = [NSString stringWithFormat:@"%@(%.1f)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],letball];
                        }
                        
                    }
                    
                } else if ([[jcPlayTypeDetailNumberDict stringForKey:@"isBigSmall"] isEqualToString:@"YES"]) {
                    CGFloat bigSmallScore = [oneMatchDetailDict floatValueForKey:@"bigSmallScore"];
                    playName = [NSString stringWithFormat:@"%@(%.1f)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],bigSmallScore];
                } else {
                    playName = [jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"];
                }
                
                [self makeLabelWithFrame:playTypeLabelRect title:playName superView:cell.contentView isColor:NO];
                
                playTypeLabelMinY = CGRectGetMaxY(playTypeLabelRect);
                
                NSArray *typeNumberArray = [jcPlayTypeDetailNumberDict objectForKey:@"typeNumber"];
                
                for (NSInteger j = 0; j < [typeNumberArray count]; j++) {
                    
                    NSDictionary *dict = [typeNumberArray objectAtIndex:j];
                    
                    //oddLabel
                    CGRect oddLabelRect = CGRectMake(CGRectGetMaxX(playTypeLabelRect) - AllLineWidthOrHeight, oddLabelMinY - AllLineWidthOrHeight, JCDefaultLabelWidth * 2 - 10 - AllLineWidthOrHeight, oneMatchCount < 2 ? (JCTableCellOneLineHeight * 2 + AllLineWidthOrHeight) : (JCTableCellOneLineHeight + AllLineWidthOrHeight));
                    NSString *oddTitleString = nil;
                    oddTitleString = [NSString stringWithFormat:@"%@\n%@",[dict stringForKey:@"text"],[dict stringForKey:@"odds"]];
                    [self makeLabelWithFrame:oddLabelRect title:oddTitleString superView:cell.contentView isColor:NO];
                    
                    oddLabelMinY = CGRectGetMaxY(oddLabelRect);
                    oddLabelMinX = CGRectGetMaxX(oddLabelRect);
                }
                
                //matchResultLabel
                CGRect matchResultLabelRect = CGRectMake(oddLabelMinX - AllLineWidthOrHeight, CGRectGetMinY(playTypeLabelRect), JCDefaultLabelWidth + 10 + AllLineWidthOrHeight, CGRectGetHeight(playTypeLabelRect));
                [self makeLabelWithFrame:matchResultLabelRect title:[jcPlayTypeDetailNumberDict objectForKey:@"oneMatchResult"] superView:cell.contentView isColor:NO];
                
            }
        }else {  // 竞彩奖金优化后对阵UI布局
            arr = [_matchDeitalArray[0] objectForKey:@"optimization"];
            
            NSMutableDictionary *oneMatchDetailDict = arr[indexPath.row]; //该数组的数据都是IOS自己处理过的，不是服务器原始数据
            NSInteger oneMatchCount = [oneMatchDetailDict intValueForKey:@"oneMatchCount"];
            
            // 序号
            CGRect orderLabelRect = CGRectMake(JCFisrtColLabelMinX - AllLineWidthOrHeight - 1, - AllLineWidthOrHeight, JCOptLabelWidth, cellHeight + AllLineWidthOrHeight);
            NSString *tempOrder = [NSString stringWithFormat:@"%d", (int)indexPath.row + 1];
            [self makeLabelWithFrame:orderLabelRect title:tempOrder superView:cell.contentView isColor:NO];
            
            // 过关方式
            CGRect ggWayLabelRect = CGRectMake(CGRectGetMaxX(orderLabelRect) - AllLineWidthOrHeight, - AllLineWidthOrHeight, JCOptLabelWidth * 2 + AllLineWidthOrHeight, cellHeight + AllLineWidthOrHeight);
            [self makeLabelWithFrame:ggWayLabelRect title:[oneMatchDetailDict valueForKey:@"ggWay"] superView:cell.contentView isColor:NO];
            
            // 注数
            CGRect investNumLabelRect = CGRectMake(CGRectGetMaxX(ggWayLabelRect) - AllLineWidthOrHeight, - AllLineWidthOrHeight, JCOptLabelWidth + AllLineWidthOrHeight, cellHeight + AllLineWidthOrHeight);
            [self makeLabelWithFrame:investNumLabelRect title:[oneMatchDetailDict valueForKey:@"investNum"] superView:cell.contentView isColor:NO];
            
            
            for (int i = 0; i < oneMatchCount; i++) {
                
                NSArray *markRedArr = [oneMatchDetailDict valueForKey:@"markRedArr"];
                
                BOOL isWin = (int)markRedArr[i] == 1;
                
                // 投注内容
                NSArray *buyContentArr = [oneMatchDetailDict valueForKey:@"buyContentArr"];
                CGRect buyContentLabelRect = CGRectMake(CGRectGetMaxX(investNumLabelRect) - AllLineWidthOrHeight - 0.5, - AllLineWidthOrHeight + i * JCTableCellOneLineHeight, JCOptLabelWidth * 2 + AllLineWidthOrHeight, JCTableCellOneLineHeight + AllLineWidthOrHeight);
                [self makeLabelWithFrame:buyContentLabelRect title:buyContentArr[i] superView:cell.contentView isColor:isWin];
                
                
                // 赛果
                NSArray *resultArr = [oneMatchDetailDict valueForKey:@"resultArr"];
                CGRect resultLabelRect = CGRectMake(CGRectGetMaxX(buyContentLabelRect) - AllLineWidthOrHeight, - AllLineWidthOrHeight + i * JCTableCellOneLineHeight, JCOptLabelWidth + 2 + AllLineWidthOrHeight, JCTableCellOneLineHeight + AllLineWidthOrHeight);
                [self makeLabelWithFrame:resultLabelRect title:resultArr[i] superView:cell.contentView isColor:isWin];
            }
        }
        
        //发起人
        if (_registNameLabel.text.length == 0) {
            _registNameLabel.text = [_matchDeitalArray[0] objectForKey:@"initiateName"];
        }
        
        // 投注信息 (竞彩详情借用开奖号码Label显示投注信息)
        if (!_passString || _passString.length == 0) {
            _passString = [_matchDeitalArray[0] objectForKey:@"passTypeInfo"];
        }
        _openNumberLabel.text = _passString;
        _openNumberLabel.text = [_openNumberLabel.text stringByAppendingString:[NSString stringWithFormat:@"  %@",[_detailDic stringForKey:@"secretMsg"]]];
    }
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableCellHeight:indexPath tableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    BOOL isJC = ([_lotteryID integerValue] == 72 || [_lotteryID integerValue] == 73 || [_lotteryID integerValue] == 45);
    //如果是下拉状态  增加高度的哦
    if([[dic objectForKey:@"isDropDown"] boolValue] == YES && isJC) {
        return NormalTicketsDetailViewControllerTabelHeadViewHeight + JCFisrtLabelHeight;
    }
    return NormalTicketsDetailViewControllerTabelHeadViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    BOOL isDropDown = [[dic objectForKey:@"isDropDown"] boolValue];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat pickDetailsPromptLabelMinX = 14.0f;
    CGFloat headViewDropBtnMinY = 0.0f;
    
    /********************** adjustment end ***************************/
    
    CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width,  NormalTicketsDetailViewControllerTabelHeadViewHeight + (isDropDown ? 0 : JCFisrtLabelHeight));
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect] autorelease];
    
    //dropBtn
    CGRect dropBtnRect = CGRectMake(0, headViewDropBtnMinY, CGRectGetWidth(tableView.frame), NormalTicketsDetailViewControllerTabelHeadViewHeight - headViewDropBtnMinY);
    UIButton *dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropBtn setFrame:dropBtnRect];
    [dropBtn setAdjustsImageWhenHighlighted:NO];
    [dropBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_normal.png"]] forState:UIControlStateNormal];
    [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_select.png"]] forState:UIControlStateSelected];
    [dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [dropBtn setSelected:isDropDown];
    [dropBtn setTag:section]; //标示是第几个section
    [dropBtn addTarget:self action:@selector(dropDownListTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:dropBtn];
    
    //pickDetailsPromptLabel 选号详情－提示文字
    CGRect pickDetailsPromptLabelRect = CGRectMake(pickDetailsPromptLabelMinX, 0, 160, CGRectGetHeight(dropBtnRect));
    pickDetailsPromptLabel = [[UILabel alloc] initWithFrame:pickDetailsPromptLabelRect];
    [pickDetailsPromptLabel setBackgroundColor:[UIColor clearColor]];
    [pickDetailsPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [pickDetailsPromptLabel setText:@"选号详情"];
    [pickDetailsPromptLabel setTag:616];
    [headerView addSubview:pickDetailsPromptLabel];
    [pickDetailsPromptLabel release];
    
    //pickDetailsLabel 选号详情
    CGRect pickDetailsLabelRect = CGRectMake(CGRectGetMaxX(pickDetailsPromptLabelRect) - 36, CGRectGetMinY(pickDetailsPromptLabelRect), CGRectGetWidth(tableView.frame) - CGRectGetMaxX(pickDetailsPromptLabelRect) - CGRectGetMinX(pickDetailsPromptLabelRect), CGRectGetHeight(pickDetailsPromptLabelRect));
    UILabel *pickDetailsLabel = [[UILabel alloc] initWithFrame:pickDetailsLabelRect];
    [pickDetailsLabel setBackgroundColor:[UIColor clearColor]];
    [pickDetailsLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [headerView addSubview:pickDetailsLabel];
    [pickDetailsLabel release];
    
    // 是否是竞彩彩种
    BOOL isJC = ([_lotteryID integerValue] == 72 || [_lotteryID integerValue] == 73 || [_lotteryID integerValue] == 45);
    BOOL isBonusOpt = NO;
    
    if (isJC) {
        // 判断是否是竞彩优化数据，更换提示文字
        if (_matchDeitalArray.count != 0) {
            // 奖金优化数据
            NSArray *arr = [_matchDeitalArray[0] objectForKey:@"optimization"];
            
            if (arr.count != 0) {
                if (section == 0) {
                    [pickDetailsPromptLabel setText:@"优化前方案内容:"];
                    
                }else {
                    isBonusOpt = YES;
                    [pickDetailsPromptLabel setText:@"优化后方案内容:"];
                }
            }
        }
    }
    
    if (isBonusOpt) { // 奖金优化UI布局
        UILabel *preBetLabel = [[UILabel alloc] initWithFrame:CGRectMake(pickDetailsPromptLabel.frame.origin.x + 100, pickDetailsPromptLabel.frame.origin.y, 100, pickDetailsPromptLabel.frame.size.height)];
        preBetLabel.text = [_matchDeitalArray[0] objectForKey:@"preBetType"];
        preBetLabel.textColor = kRedColor;
        [preBetLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [headerView addSubview:preBetLabel];
        [preBetLabel release];
        
        NSInteger promptLabelMinX = JCFisrtColLabelMinX;
        NSInteger promptLabelWidth = JCOptLabelWidth;
        for (NSInteger index = 0; index < [_optimizationLabelTitleArray count]; index++) {
            if (index == 1) {
                promptLabelWidth = JCOptLabelWidth * 2;
                
            } else if (index == 2) {
                promptLabelWidth = JCOptLabelWidth ;
                
            } else if (index == 3) {
                promptLabelWidth = JCOptLabelWidth * 2;
                
            }else if (index == 4) {
                promptLabelWidth = JCOptLabelWidth + 3;
            }
            
            //promptLabel
            CGRect promptLabelRect = CGRectMake(promptLabelMinX - AllLineWidthOrHeight, CGRectGetMaxY(dropBtnRect), promptLabelWidth + AllLineWidthOrHeight, JCFisrtLabelHeight);
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
            [promptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
            [promptLabel setText:[_optimizationLabelTitleArray objectAtIndex:index]];
            [promptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
            [promptLabel setTextAlignment:NSTextAlignmentCenter];
            [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [[promptLabel layer] setBorderWidth:AllLineWidthOrHeight];
            [[promptLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
            [promptLabel setHidden:(!isDropDown || !isJC)];
            [headerView addSubview:promptLabel];
            [promptLabel release];
            
            promptLabelMinX = CGRectGetMaxX(promptLabelRect);
        }
    }else {
        NSInteger promptLabelMinX = JCFisrtColLabelMinX;
        NSInteger promptLabelWidth = JCDefaultLabelWidth + 10;
        for (NSInteger index = 0; index < [_promptLabelTitleArray count]; index++) {
            if (index == 1) {
                promptLabelWidth = JCDefaultLabelWidth * 2;
                
            } else if (index == 2) {
                promptLabelWidth = JCDefaultLabelWidth * 2 - 10;
                
            } else if (index == 3) {
                promptLabelWidth = JCDefaultLabelWidth * 2 - 10;
                
            } else if (index == 4) {
                promptLabelWidth = JCDefaultLabelWidth + 10;
                
            }
            
            //promptLabel
            CGRect promptLabelRect = CGRectMake(promptLabelMinX - AllLineWidthOrHeight, CGRectGetMaxY(dropBtnRect), promptLabelWidth + AllLineWidthOrHeight, JCFisrtLabelHeight);
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
            [promptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
            [promptLabel setText:[_promptLabelTitleArray objectAtIndex:index]];
            [promptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
            [promptLabel setTextAlignment:NSTextAlignmentCenter];
            [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [[promptLabel layer] setBorderWidth:AllLineWidthOrHeight];
            [[promptLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
            [promptLabel setHidden:(!isDropDown || !isJC)];
            [headerView addSubview:promptLabel];
            [promptLabel release];
            
            promptLabelMinX = CGRectGetMaxX(promptLabelRect);
        }
    }
    
    NSArray *buyContentArray = [_detailDic objectForKey:@"buyContent"];
    
    [pickDetailsLabel setHidden:isJC];  // 竞彩详情时隐藏
    pickDetailsLabel.text = [NSString stringWithFormat:@"%lu条   %ld倍",(unsigned long)(isJC ? [_matchDeitalArray count] : [buyContentArray count]),(long)[[_detailDic objectForKey:@"multiple"] integerValue]];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_matchDeitalArray.count != 0) {
        // 奖金优化数据
        NSArray *arr = [_matchDeitalArray[0] objectForKey:@"optimization"];
        
        if (section == 0 && arr.count != 0) {
            return 0.1;
        } else {
            return NormalTicketsDetailViewControllerTabelFootViewHeight;
        }
    }
    return NormalTicketsDetailViewControllerTabelFootViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //footView
    CGRect footViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), NormalTicketsDetailViewControllerTabelFootViewHeight);
    if ([_lotteryID isEqualToString:@"72"] || [_lotteryID isEqualToString:@"73"] || [_lotteryID isEqualToString:@"45"]) {
        footViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), NormalTicketsDetailViewControllerTabelFootViewHeight + kBottomContainLabelHeight);
    }
    UIView *footView = [[UIView alloc]initWithFrame:footViewRect];
    [footView setClipsToBounds:YES];
    [footView setBackgroundColor:kBackgroundColor];
        
    /********************** adjustment 控件调整 ***************************/
    CGFloat nextSingleTimePromptLabelMinY = 2.5;
    
    CGFloat bottomContainLabelMinX = IS_PHONE ? 14.0f : 25.0f;//该视图中label的x
    CGFloat bottomContainLeftLabelWidth = IS_PHONE ? 68.0f : 100.0f;//左边一排label的宽度
    CGFloat bottomContainLabelHeight = kBottomContainLabelHeight; //该视图中label的高度
    CGFloat bottomLabelVerticalInterval = IS_PHONE ? 1.0f : 2.0f; //该视图中label的垂直高度间距
    
//    CGFloat bottomPromptTextViewHeight = 35.0f;//“温馨提示”内容框的高度
    /********************** adjustment end ***************************/
    
    //nextSingleTimePromptLabel 下单时间－提示文字
    CGRect nextSingleTimePromptLabelRect = CGRectMake(bottomContainLabelMinX, nextSingleTimePromptLabelMinY, bottomContainLeftLabelWidth, bottomContainLabelHeight);
    UILabel *nextSingleTimePromptLabel = [[UILabel alloc] initWithFrame:nextSingleTimePromptLabelRect];
    [nextSingleTimePromptLabel setBackgroundColor:[UIColor clearColor]];
    [nextSingleTimePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [nextSingleTimePromptLabel setText:@"下单时间"];
    [footView addSubview:nextSingleTimePromptLabel];
    [nextSingleTimePromptLabel release];
    
    //nextSingleTimeLabel 下单时间－提示文字
    CGRect nextSingleTimeLabelRect = CGRectMake(CGRectGetMaxX(nextSingleTimePromptLabelRect), CGRectGetMinY(nextSingleTimePromptLabelRect), CGRectGetWidth(tableView.frame) - CGRectGetMaxX(nextSingleTimePromptLabelRect) - CGRectGetMinX(nextSingleTimePromptLabelRect), bottomContainLabelHeight);
    UILabel *nextSingleTimeLabel = [[UILabel alloc] initWithFrame:nextSingleTimeLabelRect];
    [nextSingleTimeLabel setBackgroundColor:[UIColor clearColor]];
    [nextSingleTimeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [footView addSubview:nextSingleTimeLabel];
    [nextSingleTimeLabel release];
    
    //orderNumberPromptLabel 订单号－提示文字
    CGRect orderNumberPromptLabelRect = CGRectMake(bottomContainLabelMinX, CGRectGetMaxY(nextSingleTimePromptLabelRect) + bottomLabelVerticalInterval, CGRectGetWidth(nextSingleTimePromptLabelRect), bottomContainLabelHeight);
    UILabel *orderNumberPromptLabel = [[UILabel alloc] initWithFrame:orderNumberPromptLabelRect];
    [orderNumberPromptLabel setBackgroundColor:[UIColor clearColor]];
    [orderNumberPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [orderNumberPromptLabel setText:@"订单编号"];
    [footView addSubview:orderNumberPromptLabel];
    [orderNumberPromptLabel release];
    
    //orderNumberLabel 订单号
    CGRect orderNumberLabelRect = CGRectMake(CGRectGetMinX(nextSingleTimeLabelRect), CGRectGetMinY(orderNumberPromptLabelRect), CGRectGetWidth(nextSingleTimeLabelRect), bottomContainLabelHeight);
    UILabel *orderNumberLabel = [[UILabel alloc] initWithFrame:orderNumberLabelRect];
    [orderNumberLabel setBackgroundColor:[UIColor clearColor]];
    [orderNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [orderNumberLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [footView addSubview:orderNumberLabel];
    [orderNumberLabel release];
    
    if ([_lotteryID integerValue] == 72 || [_lotteryID integerValue] == 73 || [_lotteryID integerValue] == 45){
        //过关方式－提示文字
        CGRect passtypetLabelRect = CGRectMake(bottomContainLabelMinX, CGRectGetMaxY(orderNumberLabelRect) + bottomLabelVerticalInterval, CGRectGetWidth(nextSingleTimePromptLabelRect), bottomContainLabelHeight);
        UILabel *passTypeLabel = [[UILabel alloc] initWithFrame:passtypetLabelRect];
        [passTypeLabel setBackgroundColor:[UIColor clearColor]];
        [passTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [passTypeLabel setText:@"过关方式"];
        [footView addSubview:passTypeLabel];
        [passTypeLabel release];
        
        //orderNumberLabel 订单号
        CGRect passContentRect = CGRectMake(CGRectGetMinX(nextSingleTimeLabelRect), CGRectGetMinY(passtypetLabelRect), CGRectGetWidth(nextSingleTimeLabelRect), bottomContainLabelHeight);
        UILabel * paddContentLabel = [[UILabel alloc] initWithFrame:passContentRect];
        [paddContentLabel setBackgroundColor:[UIColor clearColor]];
        [paddContentLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [paddContentLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
        [footView addSubview:paddContentLabel];
        [paddContentLabel release];
        [paddContentLabel setText:_passString];
    }
    
//    //promptLabel 温馨提示－提示文字
//    CGRect promptLabelRect = CGRectMake(bottomContainLabelMinX, CGRectGetMaxY(orderNumberPromptLabelRect) + bottomLabelVerticalInterval, CGRectGetWidth(orderNumberPromptLabelRect), bottomContainLabelHeight);
//    
//    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
//    [promptLabel setBackgroundColor:[UIColor clearColor]];
//    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [promptLabel setText:@"温馨提示"];
//    [promptLabel setTextColor:[UIColor blackColor]];
//    [footView addSubview:promptLabel];
//    [promptLabel release];
//    
//    //promptTextView 温馨提示－内容
//    CGRect promptTextLabelRect = CGRectMake(CGRectGetMinX(orderNumberLabelRect), CGRectGetMinY(promptLabelRect), CGRectGetWidth(orderNumberLabelRect), bottomPromptTextViewHeight);
//    UILabel *promptTextLabel = [[UILabel alloc] initWithFrame:promptTextLabelRect];
//    [promptTextLabel setBackgroundColor:[UIColor clearColor]];
//    [promptTextLabel setNumberOfLines:3];
//    [promptTextLabel setText:@"中奖万元以上专人第一时间联系你，万元以下奖金自动打入您的帐户"];
//    [promptTextLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//    [footView addSubview:promptTextLabel];
//    [promptTextLabel release];
    
    NSString *datetime = [_detailDic objectForKey:@"datetime"];

    if (datetime.length > 10) {
        datetime = [datetime substringToIndex:11];
    }
    [nextSingleTimeLabel setText:datetime];
    orderNumberLabel.text = [_detailDic objectForKey:@"schemeNumber"];
//    openContentLabel.text = openString;
//    betcontenLabel.text = [NSString stringWithFormat:@"%@",[_detailDic stringForKey:@"secretMsg"]];
    return [footView autorelease];
    
    
}

#pragma mark - ASIHTTPRequestDelegate
- (void)jcRequestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"查询成功"];
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];

    _passString = [responseDic objectForKey:@"passTypeInfo"];
    
    if (_passString && _openNumberLabel) {
        _openNumberLabel.text = _passString;
    }
    
    [_matchDeitalArray removeAllObjects];
    [GlobalsProject customParserJCOrderMatchDeitalWithDict:responseDic matchDeitalArray:_matchDeitalArray lotteryId:[_lotteryID integerValue]];
    
    // 有奖金优化数据时，默认展开优化数据，隐藏未优化数据
    if (_matchDeitalArray.count != 0 && [[_matchDeitalArray[0] objectForKey:@"optimization"] count] > 0) {
        
        NSMutableDictionary *dropDict = _dropDic;
        //获取选中section的 下拉状态字典
        NSMutableDictionary *dict = [dropDict objectForKey:@"0"];
        //下拉框状态每次点击后都是原来的反状态
        [dict setObject:@"0" forKey:@"isDropDown"];
        [dict setObject:@"0" forKey:@"dropSection"];
        [dropDict setObject:dict forKey:@"0"];
    }
    
    // 刷新数据
    [_lotteryNumberTableView reloadData];
}

- (void)jcRequestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)dropDownListTouchUpInside:(id)sender {
    UIButton *btn = sender;
    
    NSMutableDictionary *dropDict = _dropDic;
    //获取选中section的 下拉状态字典
    NSMutableDictionary *dict = [dropDict objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    //下拉框状态每次点击后都是原来的反状态
    [dict setObject:[NSNumber numberWithBool:!btn.isSelected] forKey:@"isDropDown"];
    [dict setObject:[NSNumber numberWithInteger:btn.tag] forKey:@"dropSection"];
    [dropDict setObject:dict forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    [_lotteryNumberTableView reloadData];
}

- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController setTabBarHidden:_originalTabBarState];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoContinueBetNumber:(id)sender {
    NSArray *buyContentArray = [_detailDic objectForKey:@"buyContent"];
    if ([buyContentArray count] == 0) {
        return;
    }
    if ([[buyContentArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (_pushView) {
        return;
    }
    _pushView = YES;
    if (![GlobalsProject recordContinueBet:[_lotteryID intValue]]) {
        return;
    }
    NSDictionary *lotteryDict = [_globals.homeViewInfoDict objectForKey:_lotteryID];
    UIViewController *dataVC = [GlobalsProject betViewControllerBallsInfoDict:_numberDict lotteryDict:lotteryDict lotteryId:[_lotteryID intValue] initWithPlayType:[[_detailDic objectForKey:@"playTypeID"] intValue]];
    if (dataVC != nil) {
        if ([dataVC isKindOfClass:[BaseBetViewController class]]) {
            BaseBetViewController *baseBetViewController = (BaseBetViewController *)dataVC;
            [baseBetViewController setMultiple:[_detailDic intValueForKey:@"multiple"]];
            [self.navigationController pushViewController:baseBetViewController animated:YES];
        } else {
            [self.navigationController pushViewController:dataVC animated:YES];
        }
        
    }
    
}

- (void)gotoBet:(id)sender {
    if (_pushView) {
        return;
    }
    
    // 由于数据过大，竞彩彩种点击才调用接口请求数据
    if ([_lotteryID isEqualToString:@"72"] || [_lotteryID isEqualToString:@"73"] || [_lotteryID isEqualToString:@"45"]) {
        // 竞彩彩种需重新调用接口，请求详情数据。
        [self getCompetingData:_lotteryID];
    }else {
        // 直接跳转到普通彩种投注页面
        [self gotoView];
    }
    
}

#pragma mark -Customized: Private (General)
- (void)jcDetailRequest {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    if ([_detailDic objectForKey:@"ID"]) {
        [infoDic setObject:[_detailDic objectForKey:@"ID"] forKey:@"schemeId"];
    }
    
    [self clearJCRequest];
    
    _jcRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetJCOrderDetailMessage userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_jcRequest setDelegate:self];
    [_jcRequest setDidFinishSelector:@selector(jcRequestFinished:)];
    [_jcRequest setDidFailSelector:@selector(jcRequestFailed:)];
    [_jcRequest startAsynchronous];
    
    [SVProgressHUD showWithStatus:@"加载中"];
}

- (void)clearJCRequest {
    if (_jcRequest != nil) {
        [_jcRequest clearDelegatesAndCancel];
        [_jcRequest release];
        _jcRequest = nil;
    }
}

#pragma mark 填充数据
- (void)fillView {
    //头部第一部分数据
    NSInteger index = [_lotteryIDArray indexOfObject:_lotteryID];
    NSDictionary *lotteryLogoOrNameDict = [InterfaceHelper getLotteryInfoWithID:_lotteryID];
    if(!(index < 0 || index > [_imageArray count])) {
        _logoImageView.image = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[_imageArray objectAtIndex:index]]];
    }
    _lotteryNameLabel.text = [lotteryLogoOrNameDict objectForKey:@"name"];
    CGSize lotteryNameLabelSize = [Globals defaultSizeWithString:[lotteryLogoOrNameDict objectForKey:@"name"] fontSize:XFIponeIpadFontSize14];
    
    //lotteryNameLabel
    CGRect originalLotteryNameLabelRect = _lotteryNameLabel.frame;
    CGRect lotteryNameLabelRect = CGRectMake(CGRectGetMinX(originalLotteryNameLabelRect), CGRectGetMinY(originalLotteryNameLabelRect), lotteryNameLabelSize.width + XFIponeIpadFontSize14 / 2.0f, CGRectGetHeight(originalLotteryNameLabelRect));
    [_lotteryNameLabel setFrame:lotteryNameLabelRect];
    
    //isuseNameLabel
    CGRect originalIsuseNameLabelRect = _isuseNameLabel.frame;
    CGRect isuseNameLabelRect = CGRectMake(CGRectGetMinX(originalIsuseNameLabelRect) - CGRectGetMaxX(originalLotteryNameLabelRect) + CGRectGetMaxX(lotteryNameLabelRect), CGRectGetMinY(originalIsuseNameLabelRect), CGRectGetWidth(originalIsuseNameLabelRect), CGRectGetHeight(originalIsuseNameLabelRect));
    [_isuseNameLabel setFrame:isuseNameLabelRect];
    
    [_isuseNameLabel setText:[NSString stringWithFormat:@"%@期",[_detailDic stringForKey:@"issueName"]]];

    //头部第二部分数据
//    NSMutableAttributedString *mString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"选号详情  %@",[_detailDic stringForKey:@"secretMsg"]]];
//    [mString addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(6, mString.length-6)];
//    [pickDetailsPromptLabel setAttributedText:mString];
    
    _solutionSumLabel.text = [NSString stringWithFormat:@"%d元",[[_detailDic objectForKey:@"money"] intValue]];
    _orderStatusLabel.text = [_detailDic stringForKey:@"orderStatus"];
    if ([[_detailDic stringForKey:@"isOpened"] isEqualToString:@"False"]) {
        [_betCountLabel setText:@"--"];
    } else if ([[_detailDic objectForKey:@"winMoneyNoWithTax"] integerValue] > 0) {
        _betCountLabel.textColor = kRedColor;
        _betCountLabel.text = [NSString stringWithFormat:@"%.2f元",[_detailDic floatValueForKey:@"winMoneyNoWithTax"]];
    } else {
        _betCountLabel.text = @"0元";
    }
    
    // 显示中奖号码
    NSInteger lotteryId = [[_detailDic objectForKey:@"lotteryID"] integerValue];
    NSString *winNumber = [_detailDic objectForKey:@"winNumber"];
    winNumber = [winNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // 需要判断是否是双色球、大乐透、七乐彩和其他彩种，因为双色球、大乐透和七乐彩有三种颜色
    if (lotteryId == 5 || lotteryId == 39 || lotteryId == 13) {
        if (winNumber.length > 0) {
            _openNumberLabel.hidden = YES;
            
            // 有时候返回+，有时候返回-，尼玛
            NSArray *array = [NSArray array];
            if ([MyTool string:winNumber containCharacter:@"+"])
                array = [winNumber componentsSeparatedByString:@"+"];
            if ([MyTool string:winNumber containCharacter:@"-"])
                array = [winNumber componentsSeparatedByString:@"-"];
            
            NSString *redNumber = [array objectAtIndex:0];
            NSString *blueNumber = [array objectAtIndex:1];
            
            NSString *text = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font><font color=\"%@\">%@</font>", tRedColorText,redNumber,tBlueColorText,blueNumber];
            MarkupParser *p = [[MarkupParser alloc]init];
            NSAttributedString *attString = [p attrStringFromMarkup:text];
            [p release];
            
            CustomLabel *tempOpenNumberLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(_openNumberLabel.frame.origin.x - 1, _openNumberLabel.frame.origin.y + 2, _openNumberLabel.frame.size.width, _openNumberLabel.frame.size.height)];
            [tempOpenNumberLabel setBackgroundColor:[UIColor clearColor]];
            [tempOpenNumberLabel setAttString:attString];
            [_scrollView addSubview:tempOpenNumberLabel];
            [tempOpenNumberLabel release];
            
        } else {
            _openNumberLabel.text = @"----------";
            openString = @"----------";
        }
    } else {
        if (lotteryId == 72 || lotteryId == 73 || lotteryId == 45) {
            if (_passString || _passString.length != 0) {
                _openNumberLabel.text = _passString;
            }
        }else{
            if (winNumber.length == 0) {
                _openNumberLabel.text = @"----------";
                openString = @"----------";
            } else {
                _openNumberLabel.text = winNumber;
                openString = winNumber;
            }
        }
    }
    
    
    // 竞彩部分，特别显示
    if ([_lotteryID integerValue] == 72 || [_lotteryID integerValue] == 73 || [_lotteryID integerValue] == 45) {
        UILabel *label = (UILabel *)[_scrollView viewWithTag:250];
        label.hidden = YES;
        [self jcDetailRequest];
        
    }
}

- (CGFloat)tableCellHeight:(NSIndexPath *)indexPath tableView:(UITableView *)tableView  {
    if([[_detailDic objectForKey:@"lotteryID"] integerValue] == 72 || [[_detailDic objectForKey:@"lotteryID"] integerValue] == 73 || [[_detailDic objectForKey:@"lotteryID"] integerValue] == 45){
        NSArray *arr;
        if (indexPath.section == 0) {
            // 优化前数据
            arr = [_matchDeitalArray[0] objectForKey:@"informationId"];
        }else {
            // 优化后数据
            arr = [_matchDeitalArray[0] objectForKey:@"optimization"];
        }
        
        NSMutableDictionary *oneMatchDetailDict = arr[indexPath.row];
        NSInteger oneMatchCount = [oneMatchDetailDict intValueForKey:@"oneMatchCount"];
        if (oneMatchCount <= 1) {
            return JCTableCellOneLineHeight * 2;
        } else {
            return JCTableCellOneLineHeight * oneMatchCount;
        }
    } else {
    
        NSArray *buyContentArray = [_detailDic objectForKey:@"buyContent"];
        
        if ([buyContentArray count] > 0 && indexPath.row < [buyContentArray count]) {
            
            NSArray *numberArray = [buyContentArray objectAtIndex:indexPath.row];
                
            if ([numberArray isKindOfClass:[NSArray class]] && [numberArray count] > 0) {
                
                NSDictionary *oneLotteryDict = [numberArray objectAtIndex:0];
                
                NSString *numbers = [oneLotteryDict objectForKey:@"lotteryNumber"];
                numbers = [numbers stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([[_detailDic objectForKey:@"lotteryID"] integerValue] == 5 || [[_detailDic objectForKey:@"lotteryID"] integerValue] == 39) {
                    NSArray *array = [numbers componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+"]];
                    if ([array count] > 1) {
                        NSString *redNumber=[[array objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        NSString *blueNumber= [[array objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        NSString *text = [NSString stringWithFormat:@"%@ %@",redNumber,blueNumber];
                        
                        CGSize comparisonTextSize = [@"lotteryNum" sizeWithFont:[UIFont systemFontOfSize:lotteryLabelFontSize] constrainedToSize:CGSizeMake(numberLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];//用来做对比实验的
                        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:lotteryLabelFontSize] constrainedToSize:CGSizeMake(numberLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
                        
                        return (NormalDetailCellHeight - comparisonTextSize.height + textSize.height);
                    }
                } else {
                    CGSize comparisonTextSize = [@"lotteryNum" sizeWithFont:[UIFont systemFontOfSize:lotteryLabelFontSize] constrainedToSize:CGSizeMake(numberLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];//用来做对比实验的
                    CGSize textSize = [numbers sizeWithFont:[UIFont systemFontOfSize:lotteryLabelFontSize] constrainedToSize:CGSizeMake(numberLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
                    return (NormalDetailCellHeight - comparisonTextSize.height + textSize.height);
                }
                
            }
        }
        
    }
    return 0.0f;
}

- (CGRect)makeLabelWithFrame:(CGRect)frame title:(NSString *)title superView:(UIView *)superView isColor:(BOOL)isColor{//感觉要返回什么，又不知道可以返回啥，随便返回吧
    UILabel *playTypeLabel = [[UILabel alloc] initWithFrame:frame];
    [playTypeLabel setBackgroundColor:[UIColor whiteColor]];
    [playTypeLabel setTextAlignment:NSTextAlignmentCenter];
    [playTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [[playTypeLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [playTypeLabel setNumberOfLines:10];
    [[playTypeLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
    [playTypeLabel setText:title];
    
    // 若中奖则标红(针对竞彩彩种奖金优化投注内容)。
    if (isColor) {
        playTypeLabel.textColor = kRedColor;
    }
    
    [superView addSubview:playTypeLabel];
    [playTypeLabel release];
    return frame;
}

#pragma mark - 进入竞彩投注模块
// 请求竞彩对阵数据
- (void)getCompetingData: (NSString *)lotteryId {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:lotteryId forKey:@"lotteryId"];
    [infoDic setObject:@"-1" forKey:@"playType"];
    
    [self clearHttpRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_RRQUEDT_GetLotteryInformation userId:@"-1" infoDict:infoDic]];
    [_httpRequest setTimeOutSeconds:20];
    [_httpRequest setDelegate:self];
    [_httpRequest setDidFinishSelector:@selector(getRequestFinished:)];
    [_httpRequest setDidFailSelector:@selector(getRequestFailed:)];
    [_httpRequest startAsynchronous];
    
    [SVProgressHUD showWithStatus:@"加载中"];
}

- (void)clearHttpRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

#pragma mark - ASIHTTPRequestDelegate 获取竞彩投注对阵
- (void)getRequestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    [SVProgressHUD showSuccessWithStatus:@"查询成功"];
    
    NSArray *infoArray = nil;
    
    if ([_lotteryID isEqualToString:@"72"]) {  // 竞彩足球
        
        infoArray = [responseDic objectForKey:@"dtMatch"];
        NSArray *singleArray = [responseDic objectForKey:@"Singlepass"];
        if([infoArray count] != 0) {
            
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            if ([singleArray count] > 0) {
                [matchDict setObject:[singleArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [singleArray objectAtIndex:0] forKey:@"singleMatch"];
                
            }
            
            [_globals.homeViewInfoDict removeObjectForKey:@"72"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"72"];
            
            [self gotoView];
            
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"竞彩足球数据为空");
#endif
            
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
        
    } else if ([_lotteryID isEqualToString:@"73"]) {  // 竞彩篮球
        // 获取对阵信息
        infoArray = [responseDic objectForKey:@"dtMatch"];
        NSArray *singleArray = [responseDic objectForKey:@"Singlepass"];
        
        if(infoArray.count != 0) {
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            if ([singleArray count] > 0) {
                [matchDict setObject:[singleArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [singleArray objectAtIndex:0] forKey:@"singleMatch"];
            }
            
            [_globals.homeViewInfoDict removeObjectForKey:@"73"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"73"];
            
            [self gotoView];
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"竞彩篮球数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
    } else if ([_lotteryID isEqualToString:@"45"]) {  // 北京单场
        // 获取对阵信息
        infoArray = [responseDic objectForKey:@"dtMatch"];
        
        if(infoArray.count != 0) {
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            
            [_globals.homeViewInfoDict removeObjectForKey:@"45"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"45"];
            
            [self gotoView];
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"北京单场数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
    }
    responseDic = nil;
}

- (void)getRequestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"获取对阵失败"];
}

- (void)gotoView {
    
    Service *oneS = [Service getDefaultService];
    [oneS setLotteryTypes:_lotteryID];
    
    HomeViewController *homeCtl = [[HomeViewController alloc] init];
    _pushView = YES;
    NSObject *obj = [_globals.homeViewInfoDict objectForKey:_lotteryID];
    
    UIViewController *dataVC = [GlobalsProject viewController:[_lotteryID intValue] initWithInfoData:obj];
    if (dataVC != nil) {
        [self.navigationController pushViewController:dataVC animated:YES];
    }
    [homeCtl release];
}

@end
