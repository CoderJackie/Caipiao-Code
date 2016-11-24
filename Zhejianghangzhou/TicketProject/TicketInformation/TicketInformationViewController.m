//
//  TicketInformationViewController.m  彩票咨询
//  TicketProject
//
//  Created by sls002 on 13-6-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140808 10:22（洪晓彬）：修改代码规范，改进生命周期，处理各种内存问题
//  20140808 11:23（洪晓彬）：进行ipad适配
//  20150819 10:47（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "TicketInformationViewController.h"
#import "CustomSwitchView.h"
#import "InformationDetailViewController.h"
#import "TicketInformationCell.h"
#import "XFTabBarViewController.h"
#import "SVProgressHUD.h"

#import "Activity.h"
#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

#define kSwitchViewHeight (IS_PHONE ? 35.0f : 60.0f)
#define TicketInformationViewTableCellHeight (IS_PHONE ? 55.0f : 90.0f)
#define kPageSize 100

@interface TicketInformationViewController ()
@end
#pragma mark -
#pragma mark @implementation TicketInformationViewController
@implementation TicketInformationViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"彩票资讯"];
    }
    return self;
}

- (void)dealloc {
    _switchView = nil;
    _infoTableView = nil;
    
    [_ticketInformationArray release];
    _ticketInformationArray = nil;
    
    [_colorInformationArray release];
    _colorInformationArray = nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor whiteColor]];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
    
	[baseView release];
    
    //switchView 上部选项视图
    NSArray *items = [NSArray arrayWithObjects:@"热点资讯",@"专家推荐",@"站点公告", nil];
    CGRect switchViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), kSwitchViewHeight);
    _switchView = [[CustomSwitchView alloc]initWithFrame:switchViewRect Items:items];
    _switchView.delegate = self;
    [self.view addSubview:_switchView];
    [_switchView release];
    
    //tableListView 新闻信息表
    CGRect tableListViewRect = CGRectMake(0, kSwitchViewHeight, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kSwitchViewHeight - kTabBarHeight - IncreaseNavHeight + (IS_IOS7 ? 20.0f : 0.0f));
    _infoTableView = [[PullingRefreshTableView alloc]initWithFrame:tableListViewRect style:UITableViewStylePlain];
    [_infoTableView setBackgroundColor:[UIColor whiteColor]];
    [_infoTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_infoTableView setDataSource:self];
    [_infoTableView setDelegate:self];
    [_infoTableView setPullingDelegate:self];
    [self.view addSubview:_infoTableView];
    [_infoTableView release];
    
    CGFloat shadeHeight = 3.0f;
    //shadeImageView
    CGRect shadeImageViewRect = CGRectMake(0, CGRectGetMaxY(switchViewRect), CGRectGetWidth(appRect), shadeHeight);
    UIImageView *shadeImageView = [[UIImageView alloc] initWithFrame:shadeImageViewRect];
    [shadeImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shadeTop.png"]]];
    [self.view addSubview:shadeImageView];
    [shadeImageView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ticketInformationArray = [[NSMutableArray alloc] init];
    _colorInformationArray = [[NSMutableArray alloc] init];
    [self itemSelectTypeWithIndex:1];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _switchView = nil;
        _infoTableView = nil;
        
        [_ticketInformationArray release];
        _ticketInformationArray = nil;
        
        [_colorInformationArray release];
        _colorInformationArray = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];  
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TicketInformationViewTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketInformationActivity *activity = (TicketInformationActivity *)[_ticketInformationArray objectAtIndex:indexPath.row];
    
    if (activity) {
        InformationDetailViewController *detail = [[InformationDetailViewController alloc] initWithInfoType:_messageType ticketInfoActivity:_ticketInformationArray page:[_ticketInformationArray count] curPage:indexPath.row + 1];
        
        [self.navigationController pushViewController:detail animated:YES];
        [detail release];
    }
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_ticketInformationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ticketCellIdentifier = @"TicketInformationCell";
    TicketInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:ticketCellIdentifier];
    if (cell == nil) {
        cell = [[[TicketInformationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ticketCellIdentifier cellHeight:TicketInformationViewTableCellHeight cellWidth:CGRectGetWidth(tableView.frame)] autorelease];
    }
    
    TicketInformationActivity *activity = (TicketInformationActivity *)[_ticketInformationArray objectAtIndex:indexPath.row];
    [cell setTitle:activity.title color:[_colorInformationArray objectAtIndex:indexPath.row]];
    [cell setDate:activity.dateTime];
    
    return cell;
}

#pragma mark -CustomSwitchViewDelegate
- (void)switchItemDidSelectedAtIndex:(NSInteger)index {
    [_ticketInformationArray removeAllObjects];
    _pageIndex = 1;
    [self itemSelectTypeWithIndex:index];
    [self loadData];
}


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
    _pageIndex = 1;
    [_infoTableView setReachedTheEnd:NO];
    [_infoTableView setHeaderOnly:NO];
    [self loadData];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self loadData];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    return [NSDate date];
}

- (NSDate *)pullingTableViewLoadingFinishedDate{
    return [NSDate date];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
    
    [_infoTableView reloadData];
    [_infoTableView tableViewDidFinishedLoading];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    
    NSDictionary *responseDict = [[request responseString]objectFromJSONString];

    if(responseDict && [[responseDict objectForKey:@"msg"] isEqualToString:@""]) {
        if (_pageIndex == 1) {
            [_ticketInformationArray removeAllObjects];
            [_colorInformationArray removeAllObjects];
        }
        _pageIndex++;
        NSArray *list = [responseDict objectForKey:@"dtInformationTitles"];
        _hasMoreMessage = [list count] == kPageSize;
        
        for(NSDictionary *dict in list){
            if([dict objectForKey:@"id"] != nil) {
                TicketInformationActivity *activity = [[TicketInformationActivity alloc] init];
                activity.dateTime = [dict stringForKey:@"dateTime"];
                activity.informationId = [dict intValueForKey:@"id"];
                activity.title = [dict stringForKey:@"title"];
                
                [_ticketInformationArray addObject:activity];
                [_colorInformationArray addObject:[dict objectForKey:@"color"]];
                [activity release];
            }
        }
    } else {
        if (responseDict) {
            [XYMPromptView defaultShowInfo:[responseDict stringForKey:@"msg"] isCenter:NO];
        } else {
            [XYMPromptView defaultShowInfo:@"暂无咨询" isCenter:NO];
        }
    }
    
    [_infoTableView setReachedTheEnd:!_hasMoreMessage];
    [_infoTableView setHeaderOnly:!_hasMoreMessage];
    [_infoTableView reloadData];
    [_infoTableView tableViewDidFinishedLoading];
    
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)itemSelectTypeWithIndex:(NSInteger)index {
    _pageIndex = 1;
    if(index == 1){
        _messageType = 2;
        
    } else if(index == 3){
        _messageType = 1;
        
    } else{
        _messageType = 3;
    }
}

#pragma mark -Customized: Private (General)
- (void)loadData {
    [SVProgressHUD showWithStatus:@"加载中"];
    [self clearHTTPRequest];

    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%d",1] forKey:@"requestType"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_messageType] forKey:@"infoType"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_pageIndex] forKey:@"pageIndex"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",kPageSize] forKey:@"pageSize"];

    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetAnnouncementDetail userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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
