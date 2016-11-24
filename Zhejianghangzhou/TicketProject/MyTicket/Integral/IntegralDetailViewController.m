//
//  IntegralDetailViewController.m  积分详细  (整体滑动是晓洁要干的)
//  TicketProject
//
//  Created by KAI on 15-4-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//
//  20150820 10:47（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "IntegralDetailViewController.h"
#import "CircleBtn.h"
#import "IntegralCenterViewController.h"
#import "IntegralDetailTableViewCell.h"
#import "IntegralExchangeViewController.h"

#import "Activity.h"
#import "CustomResultParser.h"
#import "Globals.h"
#import "UserInfo.h"

#define kPageSize 30
#define IntegralDetailViewTabelHeaderHeight (IS_PHONE ? 168.5f : 50.0f)
#define IntegralDetailViewTabelCellHeight (IS_PHONE ? 35.0f : 50.0f)

#define kFirstLabelMinX (IS_PHONE ? 5.0f : 10.0f)
#define kFirstLabelWidth 65.5f * (kWinSize.width / 320.0f)
#define kSecondLabelWidth 62.5f * (kWinSize.width / 320.0f)
#define kThreeLabelWidth 67.0 * (kWinSize.width / 320.0f)
#define kFourLabelWidth 114.5f * (kWinSize.width / 320.0f)

#pragma mark -
#pragma mark @implementation IntegralDetailViewController
@implementation IntegralDetailViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"积分明细"];
    }
    return self;
}

- (void)dealloc {
    _circleBtn = nil;
    _accumulatePromptLabel = nil;
    _infoTableView = nil;
    
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
    
    //changeBtnRect 更改试图
    CGRect changeBtnRect = XFIponeIpadNavigationChangeButtonRect;
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeBtn setFrame:changeBtnRect];
    [[changeBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [changeBtn setTitle:@"积分兑换" forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *changeBtnItem = [[UIBarButtonItem alloc]initWithCustomView:changeBtn];
    [self.navigationItem setRightBarButtonItem:changeBtnItem];
    [changeBtnItem release];
    
    //infoTableView 资金明细表格视图
    CGRect infoTableViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44);
    _infoTableView = [[PullingRefreshTableView alloc] initWithFrame:infoTableViewRect pullingDelegate:self];
    [_infoTableView setSeparatorStyle:UITableViewScrollPositionNone];
    [_infoTableView setBackgroundColor:[UIColor clearColor]];
    [_infoTableView setDataSource:self];
    [_infoTableView setDelegate:self];
    [_infoTableView setPullingDelegate:self];
    [self.view addSubview:_infoTableView];
    [_infoTableView release];
}

- (void)viewDidLoad {
    _integralDetailArray = [[NSMutableArray alloc] init];
    _pageIndex = 0;
    _lastCalculateNumber = [UserInfo shareUserInfo].surplusIntegral;
    [self requestData];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHttpRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IntegralDetailViewTabelCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return IntegralDetailViewTabelHeaderHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), IntegralDetailViewTabelHeaderHeight);
    UIView *header = [[UIView alloc] initWithFrame:headerRect];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat circleBtnMinY = IS_PHONE ? 5.0f : 10.0f;
    CGSize circleBtnSize = IS_PHONE ? CGSizeMake(80.0f, 80.0f) : CGSizeMake(180.0f, 180.0f);

    CGFloat promptIntegralLabelHeight = IS_PHONE ? 21.0f : 50.0f;
    
    CGFloat accumulatePromptLabelMaginCircleBtnY = 7.0f;
    
    CGFloat lineMaginAccumulatePromptLabelY = 10.0f;
    CGFloat lineWidth = IS_PHONE ? 100.0f : 200.0f;
    
    CGFloat lineLabelVerticalInterval = IS_PHONE ? 15.0f : 30.0f;
    CGFloat allLabelHeight = IS_PHONE ? 30.0f : 50.0f;
    /********************** adjustment end ***************************/
    //circleBtn
    CGRect circleBtnRect = CGRectMake((CGRectGetWidth(tableView.frame) - circleBtnSize.width) / 2.0f, circleBtnMinY, circleBtnSize.width, circleBtnSize.height);
    _circleBtn = [[CircleBtn alloc] initWithFrame:circleBtnRect];
    [_circleBtn setIntegral:[UserInfo shareUserInfo].surplusIntegral];
    [_circleBtn addTarget:self action:@selector(changeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:_circleBtn];
    [_circleBtn release];
    
    //accumulatePromptLabel
    CGRect accumulatePromptLabelRect = CGRectMake(0, CGRectGetMaxY(circleBtnRect) + accumulatePromptLabelMaginCircleBtnY, CGRectGetWidth(tableView.frame), promptIntegralLabelHeight);
    _accumulatePromptLabel = [[UILabel alloc] initWithFrame:accumulatePromptLabelRect];
    [_accumulatePromptLabel setBackgroundColor:[UIColor clearColor]];
    [_accumulatePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_accumulatePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_accumulatePromptLabel setTextColor:kGrayColor];
    [_accumulatePromptLabel setMinimumScaleFactor:0.75];
    [_accumulatePromptLabel setAdjustsFontSizeToFitWidth:YES];
    [_accumulatePromptLabel setText:[self getIntegralDetailPrompt]];
    [header addSubview:_accumulatePromptLabel];
    [_accumulatePromptLabel release];
    
    //lineView1
    CGRect lineView1Rect = CGRectMake(0, CGRectGetMaxY(accumulatePromptLabelRect) + lineMaginAccumulatePromptLabelY, lineWidth, AllLineWidthOrHeight);
    UIView *lineView1 = [[UIView alloc] initWithFrame:lineView1Rect];
    [lineView1 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine3.png"]]]];
    [header addSubview:lineView1];
    [lineView1 release];
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(CGRectGetMaxX(lineView1Rect), CGRectGetMidY(lineView1Rect) - promptIntegralLabelHeight / 2.0f, CGRectGetWidth(tableView.frame) - lineWidth * 2, promptIntegralLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setText:@"积分明细"];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [header addSubview:promptLabel];
    [promptLabel release];
    
    //lineView2
    CGRect lineView2Rect = CGRectMake(CGRectGetMaxX(promptLabelRect), CGRectGetMaxY(accumulatePromptLabelRect) + lineMaginAccumulatePromptLabelY, lineWidth, AllLineWidthOrHeight);
    UIView *lineView2 = [[UIView alloc] initWithFrame:lineView2Rect];
    [lineView2 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine3.png"]]]];
    [header addSubview:lineView2];
    [lineView2 release];
    
    //_integralTimePromptLabel 时间－提示文字
    CGRect integralTimePromptLabelRect = CGRectMake(kFirstLabelMinX, CGRectGetMaxY(lineView1Rect) + lineLabelVerticalInterval, kFirstLabelWidth, allLabelHeight);
    UILabel *integralTimePromptLabel = [[UILabel alloc] initWithFrame:integralTimePromptLabelRect];
    [integralTimePromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [[integralTimePromptLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [[integralTimePromptLabel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [integralTimePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [integralTimePromptLabel setEnabled:NO];
    [integralTimePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [integralTimePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [integralTimePromptLabel setText:@"时间"];
    [header addSubview:integralTimePromptLabel];
    [integralTimePromptLabel release];
    
    //integralPromptLabel 积分－提示文字
    CGRect integralPromptLabelRect = CGRectMake(CGRectGetMaxX(integralTimePromptLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(integralTimePromptLabelRect), kSecondLabelWidth + AllLineWidthOrHeight, allLabelHeight);
    UILabel *integralPromptLabel = [[UILabel alloc] initWithFrame:integralPromptLabelRect];
    [integralPromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [[integralPromptLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [[integralPromptLabel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [integralPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [integralPromptLabel setEnabled:NO];
    [integralPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [integralPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [integralPromptLabel setText:@"积分"];
    [header addSubview:integralPromptLabel];
    [integralPromptLabel release];
    
    //integralTypePromptLabel 方式－提示文字
    CGRect integralTypePromptLabelRect = CGRectMake(CGRectGetMaxX(integralPromptLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(integralPromptLabelRect), kThreeLabelWidth + AllLineWidthOrHeight, allLabelHeight);
    UILabel *integralTypePromptLabel = [[UILabel alloc] initWithFrame:integralTypePromptLabelRect];
    [integralTypePromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [[integralTypePromptLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [[integralTypePromptLabel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [integralTypePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [integralTypePromptLabel setEnabled:NO];
    [integralTypePromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [integralTypePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [integralTypePromptLabel setText:@"方式"];
    [header addSubview:integralTypePromptLabel];
    [integralTypePromptLabel release];
    
    //totalIntegralPromptLabel 总积分－提示文字
    CGRect totalIntegralPromptLabelRect = CGRectMake(CGRectGetMaxX(integralTypePromptLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(integralTypePromptLabelRect), kFourLabelWidth + AllLineWidthOrHeight, allLabelHeight);
    UILabel *totalIntegralPromptLabel = [[UILabel alloc] initWithFrame:totalIntegralPromptLabelRect];
    [totalIntegralPromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [[totalIntegralPromptLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [[totalIntegralPromptLabel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [totalIntegralPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [totalIntegralPromptLabel setEnabled:NO];
    [totalIntegralPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [totalIntegralPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [totalIntegralPromptLabel setText:@"总积分"];
    [header addSubview:totalIntegralPromptLabel];
    [totalIntegralPromptLabel release];
    
    return [header autorelease];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return [_integralDetailArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CapitalDetailCell";
    IntegralDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[IntegralDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier cellWidth:CGRectGetWidth(tableView.frame) cellHeight:IntegralDetailViewTabelCellHeight] autorelease];
    }
    
    IntegralActivity *activity = (IntegralActivity *)[_integralDetailArray objectAtIndex:indexPath.row];
    if (activity) {
        
        [cell setYearMonthDayDateTimeString:activity.yearDate];
        [cell setHourMinuteSecondDateTimeString:activity.hourDate];
        [cell setIntegral:activity.integral];
        [cell setIntegralType:activity.integralType];
        [cell setTotalIntegral:activity.totalIntegral];

    }
    return cell;
}

//下拉刷新,上拖加载更多
#pragma mark -UIScrollViewDelegate
//会在视图滚动时收到通知。包括一个指向被滚动视图的指针，从中可以读取contentOffset属性以确定其滚动到的位置。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_infoTableView tableViewDidScroll:scrollView];
}

//当用户抬起拖动的手指时得到通知。还会得到一个布尔值，知名报告滚动视图最后位置之前，是否需要减速。
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_infoTableView tableViewDidEndDragging:scrollView];
}

#pragma mark -PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    _pageIndex = 0;
    [_infoTableView setReachedTheEnd:NO];
    [_infoTableView setHeaderOnly:NO];
    [self requestData];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self requestData];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    return [NSDate date];
}

- (NSDate *)pullingTableViewLoadingFinishedDate{
    return [NSDate date];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"查询失败"];
    [_infoTableView reloadData];
    [_infoTableView tableViewDidFinishedLoading];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"查询成功"];
    NSDictionary *responseDict = [[request responseString] objectFromJSONString];
    if(responseDict && [[responseDict objectForKey:@"error"] isEqualToString:@"0"]) {
        if (_pageIndex == 0) {
            _lastCalculateNumber = [UserInfo shareUserInfo].surplusIntegral;
            [_integralDetailArray removeAllObjects];
        }
        _pageIndex++;
        
        NSArray *scoringDetailsArray = [responseDict objectForKey:@"scoringDetails"];
        _hasMoreMessage = [scoringDetailsArray count] == kPageSize;
        _lastCalculateNumber = [self lastCalculateNumberParseResultArray:scoringDetailsArray integralDetailArray:_integralDetailArray calculateNumber:_lastCalculateNumber];
        if (!_hasMoreMessage) {
            [XYMPromptView defaultShowInfo:@"没有更多数据了" isCenter:NO];
        }
        
    } else if (responseDict) {
        [XYMPromptView showInfo:[responseDict stringForKey:@"msg"] bgColor:[UIColor blackColor].CGColor inView:[(AppDelegate *)[UIApplication sharedApplication].delegate window] isCenter:NO vertical:1];
    }
    
    
    [_infoTableView setReachedTheEnd:!_hasMoreMessage];
    [_infoTableView setHeaderOnly:!_hasMoreMessage];
    [_infoTableView reloadData];
    [_infoTableView tableViewDidFinishedLoading];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    IntegralCenterViewController *integralCenterViewController = (IntegralCenterViewController *)[self.navigationController.viewControllers objectAtIndex:1];
    if (integralCenterViewController && [integralCenterViewController isKindOfClass:[IntegralCenterViewController class]]) {
        [self.navigationController popToViewController:integralCenterViewController animated:YES];
    }
}

- (void)changeTouchUpInside:(id)sender {
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    
    if ([viewControllerArray count] >= 4) {
        IntegralExchangeViewController *integralExchangeViewController = (IntegralExchangeViewController *)[self.navigationController.viewControllers objectAtIndex:2];
        if (integralExchangeViewController && [integralExchangeViewController isKindOfClass:[IntegralExchangeViewController class]]) {
            [self.navigationController popToViewController:integralExchangeViewController animated:YES];
        }
    } else {
        IntegralExchangeViewController *integralExchangeViewController = [[IntegralExchangeViewController alloc] init];
        [self.navigationController pushViewController:integralExchangeViewController animated:YES];
        [integralExchangeViewController release];
    }
}

- (NSString *)getIntegralDetailPrompt {
    return [NSString stringWithFormat:@"累计获得积分：%ld分     累计兑换积分：%ld分",(long)[UserInfo shareUserInfo].totalIntegral, (long)[UserInfo shareUserInfo].exchangeIntegral];
}

- (NSInteger)lastCalculateNumberParseResultArray:(NSArray *)resultArray integralDetailArray:(NSMutableArray *)integralDetailArray calculateNumber:(NSInteger)calculateNumber {
    
    NSString * (^ getoperatorTypeString)(NSInteger) = ^(NSInteger operatorType){
        NSString *typeName = @"";
        switch (operatorType) {
            case 1:
                typeName = @"购彩赠送积分";
                break;
            case 2:
                typeName = @"下级购彩赠送积分";
                break;
            case 3:
                typeName = @"系统赠送积分";
                break;
            case 4:
                typeName = @"手工赠加积分";
                break;
            case 5:
                typeName = @"中奖送积分";
                break;
            case 101:
                typeName = @"兑换积分";
                break;
            case 201:
                typeName = @"惩罚扣积分";
                break;
            default:
                typeName = @"购彩赠送积分";
                break;
        }
        return typeName;
    };
    
    NSInteger currentCalculateNumber = calculateNumber;
    for (NSDictionary *integralDetailDict in resultArray) {
        if (integralDetailDict && [integralDetailDict isKindOfClass:[NSDictionary class]]) {
            IntegralActivity *activity = [[IntegralActivity alloc] init];
            
            NSString *datetime = [integralDetailDict stringForKey:@"dateTime"];
            NSInteger operatorType = [integralDetailDict intValueForKey:@"operatorType"];
            NSInteger scoring = [integralDetailDict intValueForKey:@"scoring"];
            
            if (datetime.length > 15) {
                NSArray *arr = [datetime componentsSeparatedByString:@" "];
                NSString *date = [arr objectAtIndex:0];
                NSString *time = [arr objectAtIndex:1];
                activity.yearDate = date;
                activity.hourDate = time;
            }
            if (operatorType == 101 || operatorType == 201) {
                scoring = -scoring;
            }
            if (scoring > 0) {
                activity.integral = [NSString stringWithFormat:@"+%ld",(long)scoring];
            } else {
                activity.integral = [NSString stringWithFormat:@"%ld",(long)scoring];
            }
            activity.integralType = getoperatorTypeString(operatorType);
            activity.totalIntegral = currentCalculateNumber;
            currentCalculateNumber -= scoring;
            [integralDetailArray addObject:activity];
            [activity release];
        }
    }
    return currentCalculateNumber;
}

- (void)requestData {
    [SVProgressHUD showWithStatus:@"正在请求数据"];
    [self clearHttpRequest];
    [self httpRequest];
}

- (void)httpRequest {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_pageIndex] forKey:@"pageIndex"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetIntegralDetail userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

- (void)clearHttpRequest {
    if (_httpRequest) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

@end
