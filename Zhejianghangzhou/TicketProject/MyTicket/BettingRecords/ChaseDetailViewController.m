//
//  ChaseDetailViewController.m 个人中心－追号投注详情
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140815 14:07（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//20140815 15:59（洪晓彬）：进行ipad适配

#import "ChaseDetailViewController.h"
#import "TicketsDetailViewController.h"
#import "XFTabBarViewController.h"

#import "CustomResultParser.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

#import "Globals.h"

#define ChaseTableViewHeadHeight (IS_PHONE ? 35.0f : 60.0f)
#define ChaseTableViewCellHeight (IS_PHONE ? 50.0f : 80.0f)

@interface ChaseDetailViewController ()
/** 请求订单的详细信息 */
- (void)getListWithStatus;
@end

#pragma mark -
#pragma mark @implementation ChaseDetailViewController
@implementation ChaseDetailViewController
#pragma mark Lifecircle

- (id)initWithInfoDic:(NSDictionary *)infoDic indexPage:(BetRecordType)index {
    self = [super init];
    if(self) {
        _originalTabBarState = self.xfTabBarController.tabBarHidden;
        [self.xfTabBarController setTabBarHidden:YES];
        _detailDic = [infoDic retain];
        _indexPage = index;
        [self setTitle:@"追号投注详情"];
        
        NSLog(@"_detailDic == %@",_detailDic);
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
    
    _completedLabel = nil;
    _unCompletedLabelBackImageView = nil;
    _unCompletedLabel = nil;
    
    [_detailDic release];
    [_responseDict release];
    _responseDict = nil;
    [_lotteryIDArray release];
    _lotteryIDArray = nil;
    [_imageArray release];
    _imageArray = nil;
    
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
    
    //scrollView 整个滑动视图
    CGRect scrollViewRect = CGRectMake(CGRectGetMinX(appRect), 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f);
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
    [_scrollView setTag:2200];
    [_scrollView setMultipleTouchEnabled:NO];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstBackImageViewHeight = IS_PHONE ? 48.0f : 88.0f;//头部背景的高度
    CGSize logoSize = IS_PHONE ? CGSizeMake(35.0f, 35.0f) : CGSizeMake(60.0f, 60.0f);//彩种图标大小
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
    CGRect lotteryNameLabelRect = CGRectMake(CGRectGetMaxX(logoImageViewRect) + lotteryNameLabelInterval, CGRectGetMinY(logoImageViewRect) + 5, CGRectGetWidth(firstBackImageViewRect) - CGRectGetMaxX(logoImageViewRect) - lotteryNameLabelInterval, lotteryNameLabelHeight) ;
    _lotteryNameLabel = [[UILabel alloc] initWithFrame:lotteryNameLabelRect];
    [_lotteryNameLabel setBackgroundColor:[UIColor clearColor]];
    [_lotteryNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_lotteryNameLabel setTextAlignment:NSTextAlignmentLeft];
    [firstBackImageView addSubview:_lotteryNameLabel];
    [_lotteryNameLabel release];
    
    //sumIssueLabel  总n期号
    CGRect sumIssueLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMinY(lotteryNameLabelRect), CGRectGetWidth(appRect) - CGRectGetMinX(lotteryNameLabelRect) - CGRectGetMinX(logoImageViewRect), CGRectGetHeight(lotteryNameLabelRect));
    _sumIssueLabel = [[UILabel alloc] initWithFrame:sumIssueLabelRect];
    [_sumIssueLabel setBackgroundColor:[UIColor clearColor]];
    [_sumIssueLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_sumIssueLabel setTextColor:kGrayColor];
    [_sumIssueLabel setTextAlignment:NSTextAlignmentRight];
    [firstBackImageView addSubview:_sumIssueLabel];
    [_sumIssueLabel release];
    
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
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat detailTableViewVerticalInterval = 5.0f;
    /********************** adjustment end ***************************/
    //detailTableView
    CGRect detailTableViewRect = CGRectMake(0, CGRectGetMaxY(sawToothImageViewRect) + detailTableViewVerticalInterval, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(sawToothImageViewRect) - detailTableViewVerticalInterval - 44.0f);
    _detailTableView = [[UITableView alloc]initWithFrame:detailTableViewRect];
    [_detailTableView setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    _detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _detailTableView.dataSource = self;
    _detailTableView.delegate = self;
    [self.view addSubview:_detailTableView];
    [_detailTableView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!_dropDic) {
        _dropDic = [[NSMutableDictionary alloc] init];
        //第一次加载  全部展开 分为已追和未追
        for (NSInteger i = 0; i < 2; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
            [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
            [_dropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
        }
    }
    _responseDict = [[NSMutableDictionary alloc] init];
    
    NSDictionary *dic = [InterfaceHelper getLotteryIDNameDic];
    _lotteryIDArray = [[dic objectForKey:@"id"] retain];
    _imageArray = [[dic objectForKey:@"image"] retain];
    
    _lotteryID = [[_detailDic objectForKey:@"lotteryID"] integerValue];
    NSInteger index = [_lotteryIDArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)_lotteryID]];
    _logoImageView.image = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[_imageArray objectAtIndex:index]]];
    _lotteryNameLabel.text = [_detailDic objectForKey:@"lotteryName"];
//    _solutionSumLabel.text = [NSString stringWithFormat:@"%d元",[[_detailDic objectForKey:@"money"] intValue]];
    _solutionSumLabel.text = [NSString stringWithFormat:@"%d元",[[_detailDic objectForKey:@"detailMoney"] intValue]];
    _orderStatusLabel.text = [_detailDic stringForKey:@"orderStatus"];
    if([[_detailDic stringForKey:@"isOpened"] isEqualToString:@"True"]) {
        [_betCountLabel setText:[NSString stringWithFormat:@"%.2f元",[_detailDic floatValueForKey:@"winMoneyNoWithTax"]]];
    }
    _oneIssueMoney = [_detailDic intValueForKey:@"money"];
    
    [self getListWithStatus];
}

- (void)viewWillAppear:(BOOL)animated {
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
        
        _completedLabel = nil;
        _unCompletedLabelBackImageView = nil;
        _unCompletedLabel = nil;
        
        [_lotteryIDArray release];
        _lotteryIDArray = nil;
        [_imageArray release];
        _imageArray = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChaseTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ChaseTableViewHeadHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    /********************** adjustment 控件调整 ***************************/
    CGFloat promptLabelMinX = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat dropButtonHeight = IS_PHONE ? 27.0f : 50.0f;
    /********************** adjustment end ***************************/
    CGRect headerViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), ChaseTableViewHeadHeight);
    
    
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect]autorelease];
    [headerView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
    
    UIButton *dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropBtn setFrame:CGRectMake(0, ChaseTableViewHeadHeight - dropButtonHeight, kWinSize.width, dropButtonHeight)];
    [dropBtn setAdjustsImageWhenHighlighted:NO];
    [dropBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_select.png"]] forState:UIControlStateNormal];
    [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_normal.png"]] forState:UIControlStateSelected];
    [dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [dropBtn setTag:section]; //标示是第几个section
    [dropBtn addTarget:self action:@selector(dropDownListTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:dropBtn];
    
    CGRect promptLabelRect = CGRectMake(promptLabelMinX, CGRectGetMinY(dropBtn.frame), CGRectGetWidth(headerViewRect) - promptLabelMinX, CGRectGetHeight(dropBtn.frame));
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [headerView addSubview:promptLabel];
    [promptLabel release];
    
    [promptLabel setText:[NSString stringWithFormat:@"%@期数    %ld期",section == 0 ? @"已追" : @"剩余",section == 0 ? (long)_firstSectionNum :(long)_secondSectionNum]];
    
    NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    
    //如果是下拉状态  让button选中
    if([[dic objectForKey:@"isDropDown"] boolValue] == YES) {
        [dropBtn setSelected:YES]; //设置btn的状态  因为在tableview reloadData的时候
    }
    
    //如果是下拉状态  让button选中
    if([[dic objectForKey:@"isDropDown"] boolValue] == YES) {
        [dropBtn setSelected:YES]; //设置btn的状态  因为在tableview reloadData的时候
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *completedArray =[[_responseDict objectForKey:@"chaseTaskDetailsList"] objectForKey:indexPath.section == 0 ? @"completed" : @"unCompleted"];
    NSDictionary *myItemDict = [self findItemDictInChaseArray:completedArray indexPath:indexPath];
    TicketsDetailViewController *ticketsDetailViewController = [[TicketsDetailViewController alloc] initWithInfoDic_forTicket:myItemDict withLotteryID:_lotteryID orderStatus:CHASED];
    [self.navigationController pushViewController:ticketsDetailViewController animated:YES];
    [ticketsDetailViewController release];
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    
    BOOL isDropdown = [[dic objectForKey:@"isDropDown"] boolValue];
    NSInteger dropSection = [[dic objectForKey:@"dropSection"] intValue];
    //如果不是下拉状态 并且选中的section相等 则返回0  实现收缩的效果
    if(!isDropdown && dropSection == section) {
        return 0;
    }
    
    return section == 0 ? _firstSectionNum : _secondSectionNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ChaseTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /********************** adjustment 控件调整 ***************************/
    CGFloat lotterLabelMinX = IS_PHONE ? 8.0f : 15.0f;//彩种标题和彩种信息的x起始坐标
    CGFloat lotterLabelMinY = IS_PHONE ? 2.0f : 8.0f;//彩种标题和彩种信息的y起始坐标
    CGFloat lotterLabelWidth = IS_PHONE ? 150.0f : 300.0f;//彩种标题和彩种信息的的label宽度
    CGFloat lotterLabelHeight = IS_PHONE ? 20.0f : 30.0f;//彩种标题和彩种信息的label高度
    CGFloat lotterLabelVerticalInterval = IS_PHONE ? 0.0f : 10.0f;//彩种标题和彩种信息之间的垂直距离
    CGFloat winningInfoLabelWidth = 80.0f;//获奖情况label的宽度
    
    CGFloat resultLabelMaginLeftSignX = 8.0f;
    
    CGFloat leftSignImageViewMaginRightX = IS_PHONE ? 8.0f : 16.0f;
    CGFloat leftSignImageViewWidth = IS_PHONE ? 15.0f : 22.5f;
    CGFloat leftSignImageViewHeight = IS_PHONE ? 14.0f : 21.0f;
    /********************** adjustment end ***************************/
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //lotterTitleLabel  彩种标题
        CGRect lotterTitleLabelRect = CGRectMake(lotterLabelMinX, lotterLabelMinY, lotterLabelWidth, lotterLabelHeight);
        UILabel *lotterTitleLabel = [[UILabel alloc] initWithFrame:lotterTitleLabelRect];
        [lotterTitleLabel setBackgroundColor:[UIColor clearColor]];
        [lotterTitleLabel setTextColor:[UIColor blackColor]];
        [lotterTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [lotterTitleLabel setTag:11];
        [lotterTitleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [cell.contentView addSubview:lotterTitleLabel];
        [lotterTitleLabel release];
        
        //lotterInfoLabel  彩种信息
        CGRect lotterInfoLabelRect = CGRectMake(lotterLabelMinX, CGRectGetMaxY(lotterTitleLabelRect) + lotterLabelVerticalInterval, lotterLabelWidth, CGRectGetHeight(lotterTitleLabelRect));
        UILabel *lotterInfoLabel = [[UILabel alloc] initWithFrame:lotterInfoLabelRect];
        [lotterInfoLabel setBackgroundColor:[UIColor clearColor]];
        [lotterInfoLabel setTextAlignment:NSTextAlignmentLeft];
        [lotterInfoLabel setTag:12];
        
        [lotterInfoLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [lotterInfoLabel setTextColor:kGrayColor];
        [cell.contentView addSubview:lotterInfoLabel];
        [lotterInfoLabel release];
        
        //winningInfoLabel  彩种获奖情况
        CGRect winningInfoLabelRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignImageViewWidth - leftSignImageViewMaginRightX - resultLabelMaginLeftSignX - winningInfoLabelWidth,( ChaseTableViewCellHeight - lotterLabelHeight) / 2, winningInfoLabelWidth, lotterLabelHeight);
        UILabel *winningInfoLabel = [[UILabel alloc] initWithFrame:winningInfoLabelRect];
        [winningInfoLabel setBackgroundColor:[UIColor clearColor]];
        [winningInfoLabel setTextColor:kGrayColor];
        [winningInfoLabel setTextAlignment:NSTextAlignmentRight];
        [winningInfoLabel setTag:13];
        [winningInfoLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [winningInfoLabel setMinimumScaleFactor:0.75];
        [winningInfoLabel setAdjustsFontSizeToFitWidth:YES];
        [cell.contentView addSubview:winningInfoLabel];
        [winningInfoLabel release];
        
        //leftSignImageView
        CGRect leftSignImageViewRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignImageViewWidth - leftSignImageViewMaginRightX, (ChaseTableViewCellHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
        UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
        [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        [cell.contentView addSubview:leftSignImageView];
        [leftSignImageView release];
        
        //bottomLineView
        CGRect bottomLineViewRect = CGRectMake(0, ChaseTableViewCellHeight- AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        UIView *bottomLineView = [[UIView alloc] initWithFrame:bottomLineViewRect];
        [bottomLineView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [bottomLineView setTag:14];
        [cell.contentView addSubview:bottomLineView];
        [bottomLineView release];
    }
    
    NSArray *completedArray =[[_responseDict objectForKey:@"chaseTaskDetailsList"] objectForKey:indexPath.section == 0 ? @"completed" : @"unCompleted"];
    NSDictionary *myItemDict = [self findItemDictInChaseArray:completedArray indexPath:indexPath];
    
    UILabel *lotterTitleLabel = (UILabel *)[cell.contentView viewWithTag:11];
    [lotterTitleLabel setText:[NSString stringWithFormat:@"%@期",[myItemDict objectForKey:@"issueName"]]];
    
    UILabel *lotterInfoLabel = (UILabel *)[cell.contentView viewWithTag:12];
    [lotterInfoLabel setText:[NSString stringWithFormat:@"%@元",[myItemDict objectForKey:@"money"]]];
    
    UILabel *winningInfoLabel = (UILabel *)[cell.contentView viewWithTag:13];
    [winningInfoLabel setText:[myItemDict stringForKey:@"orderMainStatus"]];
    
    NSRange yuanRange = [winningInfoLabel.text rangeOfString:@"元"];
    [winningInfoLabel setTextColor:yuanRange.length > 0 ? kRedColor : kGrayColor];
    
    UIView *bottomLineView = (UIView *)[cell.contentView viewWithTag:14];
    if ((indexPath.section == 0 && indexPath.row == _firstSectionNum - 1) || (indexPath.section == 1 && indexPath.row == _secondSectionNum - 1)) {
        [bottomLineView setFrame:CGRectMake(0, ChaseTableViewCellHeight- AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight)];
    } else {
        [bottomLineView setFrame:CGRectMake(lotterLabelMinX, ChaseTableViewCellHeight- AllLineWidthOrHeight, CGRectGetWidth(tableView.frame) - lotterLabelMinX * 2, AllLineWidthOrHeight)];
    }
    
    
    return cell;
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    [CustomResultParser parseResult:responseDic withChaseOrdersDict:_responseDict];
    
    
    id chaseTaskDetailsList = [_responseDict objectForKey:@"chaseTaskDetailsList"];
    
    
    _firstSectionNum = 0;
    _secondSectionNum = 0;
    
    if (![chaseTaskDetailsList isKindOfClass:[NSArray class]]) {
        id firstCompletedID = [[_responseDict objectForKey:@"chaseTaskDetailsList"] objectForKey:@"completed"];
        id secondCompletedID = [[_responseDict objectForKey:@"chaseTaskDetailsList"] objectForKey:@"unCompleted"];
        if ([firstCompletedID isKindOfClass:[NSArray class]]) {
            _firstSectionNum = [self calculateCountWithChaseArray:firstCompletedID];
        }
        if ([secondCompletedID isKindOfClass:[NSArray class]]) {
            _secondSectionNum = [self calculateCountWithChaseArray:secondCompletedID];
        }
    }
    
    NSInteger sumCompletedCount = [_responseDict intValueForKey:@"sumCompletedCount"];
    NSInteger sumUnCompletedCount = [_responseDict intValueForKey:@"sumUnCompletedCount"];
    
    [_sumIssueLabel setText:[NSString stringWithFormat:@"共%ld期，中奖后停止",(long)(sumCompletedCount + sumUnCompletedCount)]];
    if (_indexPage != BetRecordTypeOfChase) {
        
        _solutionSumLabel.text = [NSString stringWithFormat:@"%ld元",(long)(_oneIssueMoney * (sumCompletedCount))];
    }

    [_detailTableView reloadData];
}

#pragma mark -
#pragma mark -Customized(Action)
//中部tableview中的 下拉按钮点击事件
- (void)dropDownListTouchUpInside:(id)sender {
    UIButton *btn = sender;
    
    NSMutableDictionary *dropDict = _dropDic;
    //获取选中section的 下拉状态字典
    NSMutableDictionary *dict = [dropDict objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    //下拉框状态每次点击后都是原来的反状态
    [dict setObject:[NSNumber numberWithBool:!btn.isSelected] forKey:@"isDropDown"];
    [dict setObject:[NSNumber numberWithInteger:btn.tag] forKey:@"dropSection"];
    [dropDict setObject:dict forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    [_detailTableView reloadData];
}

- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController setTabBarHidden:_originalTabBarState];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Customized: Private (General)
- (NSInteger)calculateCountWithChaseArray:(NSArray *)chaseArray {
    if ([chaseArray count] == 0) {
        return 0;
    }
    NSDictionary *hasCompletedDic = [chaseArray objectAtIndex:0];
    NSArray *listArray = [hasCompletedDic objectForKey:@"list"];
    
    NSInteger count = 0;
    for (NSDictionary *dict in listArray) {
        NSArray *itemArray = [dict objectForKey:@"detail"];
        count += [itemArray count];
    }
    return count;
}

- (NSDictionary *)findItemDictInChaseArray:(NSArray *)chaseArray indexPath:(NSIndexPath *)indexPath {
    NSDictionary *hasCompletedDic = [chaseArray objectAtIndex:0];
    NSArray *listArray = [hasCompletedDic objectForKey:@"list"];
    
    NSInteger count = 0;
    for (NSDictionary *dict in listArray) {
        NSArray *itemArray = [dict objectForKey:@"detail"];
        if (count <= indexPath.row && (count + [itemArray count]) > indexPath.row) {
            return [itemArray objectAtIndex:indexPath.row - count];
        }
        
        count += [itemArray count];
    }
    return [NSDictionary dictionary];
}

- (void)getListWithStatus {
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[UserInfo shareUserInfo].userID forKey:@"uid"];
    if ([_detailDic objectForKey:@"ID"] && _indexPage == BetRecordTypeOfChase)
        [infoDic setObject:[_detailDic objectForKey:@"ID"] forKey:@"id"];
    else if ([_detailDic objectForKey:@"chaseTaskID"])
        [infoDic setObject:[_detailDic objectForKey:@"chaseTaskID"] forKey:@"id"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetChaseOrderDetailMessage userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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
