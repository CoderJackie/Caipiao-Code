//
//  AccountDetailViewController.m
//  TicketProject
//
//  Created by kiu on 15/7/13.
//  Copyright (c) 2015年 sls002. All rights reserved.
//
//  个人中心－账户明细

#import "AccountDetailViewController.h"
#import "CapitalRecordView.h"
#import "DialogDatePickerView.h"
#import "ChaseDetailViewController.h"
#import "ChippedDetailViewController.h"
#import "CustomSwitchView.h"
#import "TicketsDetailViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

#define kSwitchViewHeight (IS_PHONE ? 35.0f : 60.0f)
#define dateSelectViewSize (IS_PHONE ? CGSizeMake(300.0f, 280.0f) : CGSizeMake(480.0f, 360.0f))//日期选择框的大小

@interface AccountDetailViewController ()

@end

@implementation AccountDetailViewController

- (id)init {
    self = [super init];
    if (self) {
        _indexPage = 0;
        _arrCapitalRecordView = [[NSMutableArray alloc]init];
        
        [self setTitle:@"账户明细"];
    }
    return self;
}

- (void)dealloc {
    [_arrCapitalRecordView release];
    _arrCapitalRecordView = nil;
    _lableTitleArray = nil;
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
    
    //selectDateBtn 筛选按钮
    UIButton *selectDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectDateBtn setFrame:XFIponeIpadNavigationCalendarFiltrateButtonRect];
    [selectDateBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"calendar.png"]] forState:UIControlStateNormal];
    [selectDateBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"calendar.png"]] forState:UIControlStateHighlighted];
    [selectDateBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [selectDateBtn addTarget:self action:@selector(selectDateTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectDateItem = [[UIBarButtonItem alloc]initWithCustomView:selectDateBtn];
    [self.navigationItem setRightBarButtonItem:selectDateItem];
    [selectDateItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat scrollMinY = IS_PHONE ? 10.0f : 10.0f;
    CGFloat scrollContentCutY = 40.0f;//scroll滚动页的垂直范围为屏幕长度减去该值
    /********************** adjustment end ***************************/
    
    //switchView 上部选项视图
    NSArray *items = [NSArray arrayWithObjects:@"全部",@"投注",@"中奖",@"充值",@"提款", nil];
    CGRect switchViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), kSwitchViewHeight);
    _switchView = [[CustomSwitchView alloc]initWithFrame:switchViewRect Items:items];
    _switchView.delegate = self;
    [_switchView selectBtnIndex:_indexPage + 1];
    [self.view addSubview:_switchView];
    [_switchView release];
    
    _lableTitleArray = [NSArray arrayWithObjects:@"全部",@"投注记录",@"中奖",@"充值",@"提现", nil];
    
    //scroll 所有与我相关的彩票信息视图
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake( 0, CGRectGetMaxY(switchViewRect) + scrollMinY, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(switchViewRect) - scrollMinY - kNavigationBarHeight)];
    [_scroll setPagingEnabled:YES];
    [_scroll setDelegate:self];
    [_scroll setBackgroundColor:[UIColor clearColor]];
    [_scroll setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 5, CGRectGetHeight(appRect) - CGRectGetMaxY(switchViewRect) - scrollContentCutY - kNavigationBarHeight)];
    [_scroll setContentOffset:CGPointMake(_indexPage * CGRectGetWidth(appRect), 0)];
    [_scroll setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_scroll];
    [_scroll release];
    
    for (NSInteger i = 0; i < 5; i++) {
        NSInteger status = 0;
        switch (i) {
            case 0:
                status = -1;     // 全部
                break;
            case 1:
                status = 1;     // 投注
                break;
            case 2:
                status = 2;      // 中奖
                break;
            case 3:
                status = 3;   // 充值
                break;
            case 4:
                status = 4;      // 提现
                break;
            default:
                break;
        }
        
        //recordView 各个订单视图
        CGRect recordViewRect = CGRectMake(CGRectGetWidth(appRect) * i, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(switchViewRect)  - scrollMinY - kNavigationBarHeight);
        CapitalRecordView *recordView = [[CapitalRecordView alloc]initWithFrame:recordViewRect status:(int)status indexPage:_indexPage];
        recordView.delegate = self;
        [_scroll addSubview:recordView];
        [_arrCapitalRecordView addObject:recordView];
        [recordView release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CapitalRecordView *recordView = [_arrCapitalRecordView objectAtIndex:_indexPage];
    [recordView loadInitData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController  setTabBarHidden:YES];
    [self setHidesBottomBarWhenPushed:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        [_arrCapitalRecordView removeAllObjects];
        _lableTitleArray = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
    UIPageControl *pageControl = (UIPageControl *)[self.view viewWithTag:888];
    pageControl.currentPage = page;
    // 如果此页面在加载中，且此时滑动到下一页,则cancel掉此页面的请求
    CapitalRecordView *currCapitalRecordView = [_arrCapitalRecordView objectAtIndex:_indexPage];
    [currCapitalRecordView cancleRequest];
    
    // 进入滑动到的页面
    _indexPage = page;
    [_switchView selectBtnIndex:_indexPage + 1];
    
    CapitalRecordView *recordView=[_arrCapitalRecordView objectAtIndex:page];
    recordView.indexPage = page;
    [recordView loadInitData];
}

#pragma mark - CapitalViewDelegate
- (void)selectCapitalCell:(NSDictionary*)dic indexPage:(NSInteger)index {
    
    NSInteger orderType = [dic intValueForKey:@"orderType"];
    NSInteger lotteryID = [dic intValueForKey:@"lotteryID"];
    NSLog(@"lotteryID -> %ld, %ld", (long)orderType, (long)lotteryID);
    
    UIViewController *detailViewController = nil;
    if (orderType == 1) {
        detailViewController = [[TicketsDetailViewController alloc] initWithInfoDic:dic withLotteryID:lotteryID orderStatus:NORMAL];
    } else if (orderType == 2) {
        detailViewController = [[ChippedDetailViewController alloc] initWithInfoDic:dic];
        
    } else if (orderType == 3) {
        detailViewController = [[TicketsDetailViewController alloc] initWithInfoDic:dic withLotteryID:lotteryID orderStatus:CHASED];
        
//        detailViewController = [[ChaseDetailViewController alloc] initWithInfoDic:dic indexPage:(int)index];
        
    }
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
}

#pragma mark -CustomSwitchViewDelegate
- (void)switchItemDidSelectedAtIndex:(NSInteger)index {
    NSInteger page = index - 1;
    _indexPage = page;
    
    // 如果此页面在加载中，且此时滑动到下一页,则cancel掉此页面的请求
    CapitalRecordView *currCapitalRecordView = [_arrCapitalRecordView objectAtIndex:page];
    [currCapitalRecordView cancleRequest];
    
    [_scroll setContentOffset:CGPointMake(page * kWinSize.width, 0) animated:YES];
    
    CapitalRecordView *recordView=[_arrCapitalRecordView objectAtIndex:page];
    recordView.indexPage = page;
    [recordView loadInitData];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController  setTabBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

//选择日期
- (void)selectDateTouchUpInside:(id)sender {
    
    if (!_selectRowDic) {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *formateDate = [dateFormatter stringFromDate:currentDate];
        NSString *year = [formateDate substringToIndex:4];
        NSString *month = [formateDate substringWithRange:NSMakeRange(5, 2)];
        [dateFormatter release];
        NSDictionary *temp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)[year integerValue]-2015],@"selectYearRow",[NSString stringWithFormat:@"%ld",(long)[month integerValue]-1],@"selectMonthRow", nil];
        
        DialogDatePickerView *datePicker = [[DialogDatePickerView alloc]initWithFrame:CGRectMake(10, 50, dateSelectViewSize.width, dateSelectViewSize.height) SelectRowDic:temp];
        [datePicker setDelegate:self];
        [datePicker show];
        [datePicker release];
        [temp release];
        return;
    }
    
    DialogDatePickerView *datePicker = [[DialogDatePickerView alloc]initWithFrame:CGRectMake(10, 50, dateSelectViewSize.width, dateSelectViewSize.height) SelectRowDic:_selectRowDic];
    [datePicker setDelegate:self];
    [datePicker show];
    [datePicker release];
}

#pragma mark -DialogDatePickerViewDelegate
- (void)pickerViewDidSelectedDateDictionary:(NSDictionary *)selectDateDic {
    [_selectRowDic release];
    _selectRowDic = nil;
    _selectRowDic = [selectDateDic retain];
    if (_selectYear != nil) {
        [_selectYear release];
        _selectYear = nil;
    }
    _selectYear = [[selectDateDic objectForKey:@"selectYear"] copy];
    if (_selectMonth != nil) {
        [_selectMonth release];
        _selectMonth = nil;
    }
    _selectMonth = [[selectDateDic objectForKey:@"selectMonth"] copy];
    
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

// 通过时间选择器筛选，算出查询的开始、结束 日期。
- (void)loadDataWithYear:(NSString *)year Month:(NSString *)month {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
    [dateFormatter release];
    
    //获取一个月有多少天
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSInteger numberOfDaysInMonth = range.length;
    if (_startDate != nil) {
        [_startDate release];
        _startDate = nil;
    }
    _startDate = [[NSString stringWithFormat:@"%@-%@-1 00:00:00",_selectYear,_selectMonth] copy];
    if (_endDate != nil) {
        [_endDate release];
        _endDate = nil;
    }
    _endDate = [[NSString stringWithFormat:@"%@-%@-%ld 23:59:59",_selectYear,_selectMonth,(long)numberOfDaysInMonth] copy];
    
    [calendar release];
    
    CapitalRecordView *recordView=[_arrCapitalRecordView objectAtIndex:_indexPage];
    [recordView loadDataWithStart:_startDate loadDataWithEnd:_endDate indexPage:_indexPage];
    
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

#pragma mark -Customized: Private (General)

@end
