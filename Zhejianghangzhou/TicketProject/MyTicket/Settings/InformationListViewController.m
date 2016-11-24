//
//  InformationListViewController.m 个人中心－消息中心
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140811 18:14（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140812 08:55（洪晓彬）：进行ipad适配

#import "InformationListViewController.h"
#import "CustomSegmentedControl.h"
#import "DetailInformationViewController.h"

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

#define kPageSize (IS_PHONE ? 10 : 15)

@interface InformationListViewController ()
/** 请求消息
 @param infoType 消息类型，1为用户消息 */
- (void)loadPushMessageDataWithType:(NSInteger)infoType;
@end

#define InformationListViewCellHeight (IS_PHONE ? 64.0f : 80.0f)
#define InformationViewMatchTypeCustomSegmentedControl (IS_PHONE ? 30.0f : 60.0f)

#pragma mark -
#pragma mark @implementation InformationListViewController
@implementation InformationListViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"消息中心"];
        _systemMessageHasMore = YES;
        _pushMessageHasMore = YES;
    }
    return self;
}

- (void)dealloc {
    _systemMessageTableList = nil;
    _pushMessagetableList = nil;
    
    [_systemMessageArray release];
    _systemMessageArray = nil;
    [_pushMessageArray release];
    _pushMessageArray = nil;
    
    [_currIndexPath release];
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
    [comeBackBtn addTarget:self action:@selector(getBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //matchTypeCustomSegmentedControl
    CGRect matchTypeCustomSegmentedControlRect = CGRectMake(0, 0, CGRectGetWidth(appRect), InformationViewMatchTypeCustomSegmentedControl);
    _matchTypeCustomSegmentedControl = [[CustomSegmentedControl alloc]initWithFrame:matchTypeCustomSegmentedControlRect Items:[NSArray arrayWithObjects:@"系统消息", @"推送消息", nil] normalImageName:@"singleMatchNormalBtn.png" selectImageName:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]];
    [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:0];
    [_matchTypeCustomSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_matchTypeCustomSegmentedControl addTarget:self action:@selector(matchTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_matchTypeCustomSegmentedControl];
    [_matchTypeCustomSegmentedControl release];
    
    CGRect lineViewRect = CGRectMake(0, CGRectGetMaxY(matchTypeCustomSegmentedControlRect), CGRectGetWidth(appRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:lineViewRect inSuperView:self.view];
    
    //footBallScrollView
    CGRect footBallScrollViewRect = CGRectMake( 0, InformationViewMatchTypeCustomSegmentedControl + AllLineWidthOrHeight, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kNavigationBarHeight - InformationViewMatchTypeCustomSegmentedControl - AllLineWidthOrHeight);
    _messageScrollView = [[UIScrollView alloc]initWithFrame:footBallScrollViewRect];
    [_messageScrollView setClipsToBounds:YES];
    [_messageScrollView setPagingEnabled:YES];
    [_messageScrollView setDelegate:self];
    [_messageScrollView setTag:1010];
    [_messageScrollView setUserInteractionEnabled:YES];
    [_messageScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 2, 0)];
    [_messageScrollView setContentOffset:CGPointMake(0, 0)];
    [_messageScrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_messageScrollView];
    [_messageScrollView release];

    //tableList 表格列表
    CGRect systemMessageTableListRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(footBallScrollViewRect));
    _systemMessageTableList = [[UITableView alloc]initWithFrame:systemMessageTableListRect];
    [_systemMessageTableList setBackgroundColor:kBackgroundColor];
    [_systemMessageTableList setSeparatorColor:[UIColor grayColor]];
    [_systemMessageTableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_systemMessageTableList setDataSource:self];
    [_systemMessageTableList setDelegate:self];
    [_systemMessageTableList setTag:2100];
    [_messageScrollView addSubview:_systemMessageTableList];
    [_systemMessageTableList release];
    
    //tableList 表格列表
    CGRect pushMessagetableListRect = CGRectMake(CGRectGetWidth(appRect), 0, CGRectGetWidth(appRect), CGRectGetHeight(footBallScrollViewRect));
    _pushMessagetableList = [[UITableView alloc]initWithFrame:pushMessagetableListRect];
    [_pushMessagetableList setBackgroundColor:kBackgroundColor];
    [_pushMessagetableList setSeparatorColor:[UIColor grayColor]];
    [_pushMessagetableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_pushMessagetableList setDataSource:self];
    [_pushMessagetableList setDelegate:self];
    [_pushMessagetableList setTag:2101];
    [_messageScrollView addSubview:_pushMessagetableList];
    [_pushMessagetableList release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _systemMessageArray = [[NSMutableArray alloc] init];
    _pushMessageArray = [[NSMutableArray alloc] init];
    _systemMessagePageIndex = 1;
    _pushMessagePageIndex = 1;
    [self loadSystemMessageDataWithType:2];
    [self loadPushMessageDataWithType:3];
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
        _systemMessageTableList = nil;
        _pushMessagetableList = nil;
        [_systemMessageArray release];
        _systemMessageArray = nil;
        [_pushMessageArray release];
        _pushMessageArray = nil;
        
        [_currIndexPath release];
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearSystemMessageRequest];
    [self clearPushMessageRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 1010) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:page];
        _currentSelectType = page;
    }
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return InformationListViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 2100) {
        [_currIndexPath release];
        _currIndexPath = [indexPath retain];
        NSDictionary *dic = [_systemMessageArray objectAtIndex:indexPath.row];
        DetailInformationViewController *detail = [[DetailInformationViewController alloc] initWithDetailDictionary:dic withType:2];
        [detail setDelegate:self];
        [self.navigationController pushViewController:detail animated:YES];
        [detail release];
    } else if (tableView.tag == 2101) {
        NSDictionary *dic = [_pushMessageArray objectAtIndex:indexPath.row];
        DetailInformationViewController *detail = [[DetailInformationViewController alloc] initWithDetailDictionary:dic withType:3];
        [detail setDelegate:self];
        [self.navigationController pushViewController:detail animated:YES];
    }
    
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 2100) {
        return [_systemMessageArray count] + 1;
    } else if (tableView.tag == 2101) {
        return [_pushMessageArray count] + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomInformationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //backImageView 背景图
        CGRect backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), InformationListViewCellHeight);
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
        [backImageView setImage:[UIImage imageNamed:@"gray.png"]];
        [cell.contentView addSubview:backImageView];
        [backImageView release];
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;//左右label的高度
        
        CGFloat titleLabelMinX = IS_PHONE ? 15.0f : 30.0f;//标题label的x
        CGFloat titleLabelMinY = IS_PHONE ? 4.0f : 6.0f;
        CGFloat titleLabelWidth = IS_PHONE ? 200.0f : 400.0f;
        
        CGFloat dateLabelIntervalRight = 20.0f;//时间label与左边屏幕的边框的距离
        CGFloat dateLabelWidth = IS_PHONE ? 120.0f : 200.0f;//时间label的宽度
        
        CGFloat contentLabelMinX = IS_PHONE ? 15.0f : 30.0f;//正文label的x
        
        CGFloat lineMinX = 15.0f;
        /********************** adjustment end ***************************/
        
        //titleLabel 标题
        CGRect titleLabelRect = CGRectMake(titleLabelMinX, titleLabelMinY, titleLabelWidth, allLabelHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
        [titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTag:901];
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
        
        //dateLabel 时间
        CGRect dateLabelRect = CGRectMake(CGRectGetWidth(tableView.frame) - dateLabelWidth - dateLabelIntervalRight, CGRectGetMinY(titleLabelRect), dateLabelWidth, allLabelHeight);
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateLabelRect];
        [dateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [dateLabel setTextAlignment:NSTextAlignmentRight];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setTag:902];
        [cell.contentView addSubview:dateLabel];
        [dateLabel release];
        
        //contentLabel 正文
        CGRect contentLabelRect = CGRectMake(contentLabelMinX, CGRectGetMaxY(titleLabelRect), CGRectGetWidth(tableView.frame) - contentLabelMinX * 2, CGRectGetHeight(backImageViewRect) - CGRectGetMaxY(titleLabelRect) - 2);
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:contentLabelRect];
        [contentLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [contentLabel setTextAlignment:NSTextAlignmentLeft];
        [contentLabel setBackgroundColor:[UIColor clearColor]];
        [contentLabel setTag:903];
        [cell.contentView addSubview:contentLabel];
        [contentLabel release];
        
        //line
        CGRect lineRect = CGRectMake(lineMinX, InformationListViewCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame) - lineMinX, AllLineWidthOrHeight);
        [Globals makeLineWithFrame:lineRect inSuperView:cell.contentView];
    }
    
    NSMutableArray *messageArray = nil;
    if (tableView.tag == 2100) {
        messageArray = _systemMessageArray;
    } else if (tableView.tag == 2101) {
        messageArray = _pushMessageArray;
    }
    if (indexPath.row == [messageArray count]) {
        static NSString *customCellIdentifier = @"MoreCell";
        cell = [tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIdentifier] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            CGRect viewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), InformationListViewCellHeight);
            UIView *view = [[UIView alloc]initWithFrame:viewRect];
            [view setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:view];
            [view release];
            
            UIButton *loadMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [loadMoreBtn setFrame:viewRect];
            [loadMoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [loadMoreBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
            [loadMoreBtn setTag:tableView.tag];
            [loadMoreBtn setAdjustsImageWhenHighlighted:NO];
            [loadMoreBtn setTitle:@"点击加载更多..." forState:UIControlStateNormal];
            [loadMoreBtn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:loadMoreBtn];

        }
        
        UIButton *loadMoreBtn = (UIButton *)[cell.contentView viewWithTag:tableView.tag];
        if ((_systemMessageHasMore && tableView.tag == 2100) || (_pushMessageHasMore && tableView.tag == 2101)) {
            [loadMoreBtn setTitle:@"点击加载更多..." forState:UIControlStateNormal];
            [loadMoreBtn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [loadMoreBtn setTitle:@"没有更多了" forState:UIControlStateNormal];
            [loadMoreBtn removeTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if ([messageArray count] == 0) {
            [loadMoreBtn setTitle:@"暂无消息" forState:UIControlStateNormal];
        }
        
    }
    
    
    
    if (indexPath.row < [messageArray count] && tableView.tag == 2100) {
        NSDictionary *dic = [messageArray objectAtIndex:indexPath.row];
        //titleLabel 标题
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:901];
        [titleLabel setFont:[[dic objectForKey:@"isRead"] isEqualToString:@"True"] ? [UIFont systemFontOfSize:XFIponeIpadFontSize13] : [UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
        [titleLabel setText:[dic objectForKey:@"title"]];
        //dateLabel 时间
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:902];
        [dateLabel setText:[dic objectForKey:@"dateTime"]];
        //contentLabel 正文
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:903];
        [contentLabel setText:[dic objectForKey:@"content"]];
    } else if (indexPath.row < [messageArray count] && tableView.tag == 2101) {
        NSDictionary *dic = [messageArray objectAtIndex:indexPath.row];
        //titleLabel 标题
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:901];
        [titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [titleLabel setText:[dic objectForKey:@"MessageTitle"]];
        //dateLabel 时间
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:902];
        [dateLabel setText:[dic objectForKey:@"DateTime"]];
        //contentLabel 正文
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:903];
        [contentLabel setText:[dic objectForKey:@"MessageContent"]];
    }
    return cell;
}

#pragma mark -ASIHTTPRequestDelegate
- (void)getSystemMessageFailed:(ASIHTTPRequest *)request {
    
}

- (void)getSystemMessageFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    NSArray *list = [responseDic objectForKey:@"stationSMSList"];
    if(responseDic && [[responseDic objectForKey:@"msg"] isEqualToString:@""]) {
        if(_isAddMore) {//追加
            [_systemMessageArray addObjectsFromArray:list];
            _isAddMore = NO;
        } else {
            [_systemMessageArray removeAllObjects];
            [_systemMessageArray addObjectsFromArray:list];
        }
        if ([list count] < kPageSize) {
            _systemMessageHasMore = NO;
        }
        [_systemMessageTableList reloadData];
        
    } else if (responseDic){
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

- (void)getPushMessageFailed:(ASIHTTPRequest *)request {
    
}

- (void)getPushMessageFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    NSArray *list = [responseDic objectForKey:@"info"];
    if(responseDic && [[responseDic objectForKey:@"error"] isEqualToString:@"0"]) {
        if ([list count] == 1) {
            NSDictionary *dic = [list objectAtIndex:0];
            if (dic && [dic count] == 0) {
                _pushMessageHasMore = NO;
                [_pushMessagetableList reloadData];
                return;
            }
        }
        if(_isAddMore) {//追加
            
            [_pushMessageArray removeAllObjects];
            [_pushMessageArray addObjectsFromArray:list];
            _isAddMore = NO;
        } else {
            [_pushMessageArray removeAllObjects];
            [_pushMessageArray addObjectsFromArray:list];
        }
        if ([list count] < kPageSize) {
            _pushMessageHasMore = NO;
        }
        [_pushMessagetableList reloadData];
        
    } else if (responseDic){
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

#pragma mark -UpdateIsReadedStatusDelegate
- (void)updateIsReadedStatus:(BOOL)isReaded {
    // 已读，更改显示状态
    if (isReaded) {
        if (_currentSelectType == 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[_systemMessageArray objectAtIndex:_currIndexPath.row]];
            [dic setObject:@"True" forKey:@"isRead"];
            [_systemMessageArray replaceObjectAtIndex:_currIndexPath.row withObject:dic];
            NSArray *indexPaths = [NSArray arrayWithObjects:_currIndexPath, nil];
            [_systemMessageTableList reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        } else {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[_pushMessageArray objectAtIndex:_currIndexPath.row]];
            [dic setObject:@"True" forKey:@"isRead"];
            [_pushMessageArray replaceObjectAtIndex:_currIndexPath.row withObject:dic];
            NSArray *indexPaths = [NSArray arrayWithObjects:_currIndexPath, nil];
            [_pushMessagetableList reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//加载更多
- (void)loadMore:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 2100) {
        _systemMessagePageIndex++;
        _isAddMore = YES;
        _systemMessageHasMore = YES;
        [self loadSystemMessageDataWithType:2];
        [_systemMessageTableList reloadData];
    } else if (btn.tag == 2101) {
        _pushMessagePageIndex++;
        _isAddMore = YES;
        _pushMessageHasMore = YES;
        [self loadPushMessageDataWithType:3];
        [_pushMessagetableList reloadData];
    }
    
}

- (void)matchTypeChanged:(id)sender {
    CustomSegmentedControl *customSegmentedControl = sender;
    
    switch (customSegmentedControl.selectedSegmentIndex) {
        case 0:
            [_messageScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            _currentSelectType = 0;
            break;
        case 1:
            [_messageScrollView setContentOffset:CGPointMake(kWinSize.width, 0) animated:YES];
            _currentSelectType = 1;
            break;
            
        default:
            break;
    }
}

#pragma mark -Customized: Private (General)
- (void)loadSystemMessageDataWithType:(NSInteger)infoType {
    [self clearSystemMessageRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%d",2] forKey:@"typeId"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_systemMessagePageIndex] forKey:@"pageIndex"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",kPageSize] forKey:@"pageSize"];
    [infoDic setObject:@"-1" forKey:@"isRead"];
    [infoDic setObject:@"0" forKey:@"sortType"];
    
    _systemMessageRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetMessageCenterAndReadState userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_systemMessageRequest setDidFinishSelector:@selector(getSystemMessageFinished:)];
    [_systemMessageRequest setDidFailSelector:@selector(getSystemMessageFailed:)];
    [_systemMessageRequest setDelegate:self];
    [_systemMessageRequest startAsynchronous];
}

- (void)clearSystemMessageRequest {
    if (_systemMessageRequest != nil) {
        [_systemMessageRequest clearDelegatesAndCancel];
        [_systemMessageRequest release];
        _systemMessageRequest = nil;
    }
}

- (void)loadPushMessageDataWithType:(NSInteger)infoType {
    [self clearPushMessageRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[UserInfo shareUserInfo].userID forKey:@"UserId"];
    
    _pushMessageRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetPushMessage userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_pushMessageRequest setDidFinishSelector:@selector(getPushMessageFinished:)];
    [_pushMessageRequest setDidFailSelector:@selector(getPushMessageFailed:)];
    [_pushMessageRequest setDelegate:self];
    [_pushMessageRequest startAsynchronous];
}

- (void)clearPushMessageRequest {
    if (_pushMessageRequest != nil) {
        [_pushMessageRequest clearDelegatesAndCancel];
        [_pushMessageRequest release];
        _pushMessageRequest = nil;
    }
}

@end
