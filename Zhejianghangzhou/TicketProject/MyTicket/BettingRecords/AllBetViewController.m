    //
//  AllBetViewController.m 个人中心－所有订单彩票
//  TicketProject
//
//  Created by sls002 on 13-6-17.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140813 17:01（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140813 17:17（洪晓彬）：进行ipad适配

#import "AllBetViewController.h"
#import "BetRecordView.h"
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

@interface AllBetViewController ()

@end
#pragma mark -
#pragma mark @implementation AllBetViewController
@implementation AllBetViewController
#pragma mark Lifecircle

- (id)initWithStatus:(OrderStatus)status withIndexPage:(NSInteger)index{
    self = [super init];
    if(self){
        _indexPage = index;
        _orderStatus = status;
        
        [self setTitle:@"我的彩票"];
        _arrBetRecordView = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc {
    [_arrBetRecordView release];
    _arrBetRecordView = nil;
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
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat scrollMinY = IS_PHONE ? 10.0f : 10.0f;
    CGFloat scrollContentCutY = 40.0f;//scroll滚动页的垂直范围为屏幕长度减去该值
    /********************** adjustment end ***************************/
    
    //switchView 上部选项视图
    NSArray *items = [NSArray arrayWithObjects:@"全部",@"中奖",@"未开奖",@"追号",@"复制", nil];
    CGRect switchViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), kSwitchViewHeight);
    _switchView = [[CustomSwitchView alloc]initWithFrame:switchViewRect Items:items];
    _switchView.delegate = self;
    [_switchView selectBtnIndex:_indexPage + 1];
    [self.view addSubview:_switchView];
    [_switchView release];
    
    _lableTitleArray = [NSArray arrayWithObjects:@"全部彩票",@"中奖记录",@"未开奖",@"我的追号",@"我的复制", nil];
    
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
                status = -1;    // 全部订单
                break;
            case 1:
                status = 1;     // 中奖订单
                break;
            case 2:
                status = 2;     // 待中奖订单
                break;
            case 3:
                status = 3;     // 追号订单
                break;
            case 4:
                status = 4;     // 合买订单
                break;
        
            default:
                break;
        }
        
        //recordView 各个订单视图
        CGRect recordViewRect = CGRectMake(CGRectGetWidth(appRect) * i, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(switchViewRect)  - scrollMinY - kNavigationBarHeight);
        BetRecordView *recordView = [[BetRecordView alloc]initWithFrame:recordViewRect status:(int)status indexPage:_indexPage];
        [recordView setDelegate:self];
        [_scroll addSubview:recordView];
        [_arrBetRecordView addObject:recordView];
        [recordView release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BetRecordView *recordView = [_arrBetRecordView objectAtIndex:_indexPage];
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
        [_arrBetRecordView removeAllObjects];
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
    BetRecordView *currBetRecordView = [_arrBetRecordView objectAtIndex:_indexPage];
    [currBetRecordView cancleRequest];
    
    // 进入滑动到的页面
    _indexPage = page;
    [_switchView selectBtnIndex:_indexPage + 1];
    
    BetRecordView *recordView=[_arrBetRecordView objectAtIndex:page];
    recordView.indexPage = page;
    [recordView loadInitData];
}

#pragma mark -BetRecordViewDelegate
- (void)selectBetRecordCell:(NSDictionary*)dic indexPage:(NSInteger)index {
    
    NSInteger orderType = [dic intValueForKey:@"orderType"];
    NSInteger lotteryid = [dic intValueForKey:@"lotteryID"];
    
    UIViewController *detailViewController = nil;
    if (orderType == 1) {
        detailViewController = [[TicketsDetailViewController alloc] initWithInfoDic:dic withLotteryID:lotteryid orderStatus:NORMAL];
    } else if (orderType == 2) {
        detailViewController = [[ChippedDetailViewController alloc] initWithInfoDic:dic];
        
    } else if (orderType == 3) {
        detailViewController = [[ChaseDetailViewController alloc] initWithInfoDic:dic indexPage:(int)index];
        
    }
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];

}

#pragma mark -CustomSwitchViewDelegate
- (void)switchItemDidSelectedAtIndex:(NSInteger)index {
    NSInteger page = index - 1;
    
    // 如果此页面在加载中，且此时滑动到下一页,则cancel掉此页面的请求
    BetRecordView *currBetRecordView = [_arrBetRecordView objectAtIndex:page];
    [currBetRecordView cancleRequest];
    
    [_scroll setContentOffset:CGPointMake(page * kWinSize.width, 0) animated:YES];

    BetRecordView *recordView=[_arrBetRecordView objectAtIndex:page];
    recordView.indexPage = page;
    [recordView loadInitData];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController  setTabBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Customized: Private (General)
@end
