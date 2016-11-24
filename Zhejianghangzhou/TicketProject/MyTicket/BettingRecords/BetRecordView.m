//
//  BetRecordView.m  个人中心－所有订单彩票－单订单页面信息
//  TicketProject
//
//  Created by md005 on 13-9-4.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140814 14:31（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140814 15:02（洪晓彬）：进行ipad适配
//20150713 15:02（刘科）：增加彩金消费
//20150813 11:23（刘科）：增加竞彩彩种奖金优化"优"字标识

#import "BetRecordView.h"

#import "CustomResultParser.h"
#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"

#define CustomMyTicketsCellHeight (IS_PHONE ? 70.0f : 100.0f)

#define requestSize 12

@interface BetRecordView (){
    NSString *_registName;
}
/** 取消数据申请 */
- (void)cancleRequest;
@end

#pragma mark -
#pragma mark @implementation BetRecordView
@implementation BetRecordView
#pragma mark Lifecircle
@synthesize indexPage = _indexPage;
@synthesize delegate = _delegate;

- (void)dealloc {
    _m_tableView = nil;

    [self cancleRequest];
    [_schemeList release];
    _schemeList = nil;
    [_lotteryIDArray release];
    _lotteryIDArray = nil;
    [_lotteryNameArray release];
    _lotteryNameArray = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame status:(OrderStatus)status indexPage:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        _m_status = status;

        _page = 1;
        _indexPage = index;
        _schemeList = [[NSMutableArray alloc]init];
        
        _m_tableView = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)) pullingDelegate:self];
        [_m_tableView setSeparatorStyle:UITableViewScrollPositionNone];
        [_m_tableView setBackgroundColor:[UIColor clearColor]];
        [_m_tableView setDataSource:self];
        [_m_tableView setDelegate:self];
        [self addSubview:_m_tableView];
        [_m_tableView release];
        
        NSDictionary *_lotteryDetailDict = [InterfaceHelper getLotteryIDNameDic];
        _lotteryIDArray = [[_lotteryDetailDict objectForKey:@"id"] retain];
        _lotteryNameArray = [[_lotteryDetailDict objectForKey:@"name"] retain];
        _isFirstLoading = YES;
    }
    return self;
}

#pragma Delegate
#pragma mark -
#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _schemeList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_indexPage == BetRecordTypeOfChase) {
        NSDictionary *dic = [_schemeList objectAtIndex:section];
        NSArray *arr = [dic objectForKey:@"chaseTaskDetail"];
        return arr.count;
    } else {
        NSDictionary *dic = [_schemeList objectAtIndex:section];
        NSArray *arr = [dic objectForKey:@"dateDetail"];
        return arr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomMyTicketsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /********************** adjustment 控件调整 ***************************/
    CGFloat backImageViewMinX = IS_PHONE ? 32.0f : 80.0f;
    /********************** adjustment end ***************************/
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat datefirstLabelMinY = IS_PHONE ? 0 : 5.0f;
        CGFloat dateLabelHeight = 25.0f;
        
        CGFloat backImageViewLabelHeight = IS_PHONE ? 21.0f : 30.0f;//在背景图内label的高度
        CGFloat issueNumberLabelMinX = 9.0f;//彩种名的x
        CGFloat issueNumberLabelMinY = IS_PHONE ? 5.0f : 8.0f;
        CGFloat issueNumberLabelWidht = 150.0f;
        
        CGFloat betCountLabelWidht = self.width / 2 - 50;//购买金额的宽度
        
        CGFloat betTypeLabelWidht = 100.0f;//订单类型的宽度
        
        CGFloat resultLabelWidth = IS_PHONE ? 120.0f : 150.0f;
        
        CGFloat labelVerticalInterval = IS_PHONE ? 0.0f : 5.0f;//label和label在垂直方向上的间距
        
        CGFloat resultLabelMaginLeftSignX = IS_PHONE ? 8.0f : 16.0f;
        
        CGFloat leftSignImageViewMaginRightX = IS_PHONE ? 8.0f : 16.0f;
        CGFloat leftSignImageViewWidth = IS_PHONE ? 15.0f : 22.5f;
        CGFloat leftSignImageViewHeight = IS_PHONE ? 14.0f : 21.0f;
        /********************** adjustment end ***************************/
        
        //dateBackImageView
        CGRect datebackImageViewRect = CGRectMake(0, 0, backImageViewMinX, CustomMyTicketsCellHeight);
        UIImageView *datebackImageView = [[UIImageView alloc] initWithFrame:datebackImageViewRect];
        [datebackImageView setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
        [cell.contentView addSubview:datebackImageView];
        [datebackImageView release];
        
        //backImageView 背景图
        CGRect backImageViewRect = CGRectMake(backImageViewMinX, 0, CGRectGetWidth(self.frame) - backImageViewMinX, CustomMyTicketsCellHeight);
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
        [backImageView setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview:backImageView];
        [backImageView release];
        
        //topLineImageView
        CGRect topLineImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        UIImageView *topLineImageView = [[UIImageView alloc] initWithFrame:topLineImageViewRect];
        [topLineImageView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [topLineImageView setTag:1150];
        [cell.contentView addSubview:topLineImageView];
        [topLineImageView release];
        
        //verticalLineImageView
        CGRect verticalLineImageViewRect = CGRectMake(CGRectGetMaxX(datebackImageViewRect), 0, AllLineWidthOrHeight, CustomMyTicketsCellHeight);
        UIImageView *verticalLineImageView = [[UIImageView alloc] initWithFrame:verticalLineImageViewRect];
        [verticalLineImageView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [cell.contentView addSubview:verticalLineImageView];
        [verticalLineImageView release];
        
        //bottomLineImageView
        CGRect bottomLineImageViewRect = CGRectMake(0, CustomMyTicketsCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        UIImageView *bottomLineImageView = [[UIImageView alloc] initWithFrame:bottomLineImageViewRect];
        [bottomLineImageView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [bottomLineImageView setTag:1151];
        [cell.contentView addSubview:bottomLineImageView];
        [bottomLineImageView release];
        
        //buyDateMonthLabel  彩票订单购买月份
        CGRect buyDateMonthLabelRect = CGRectMake(0, datefirstLabelMinY, CGRectGetWidth(datebackImageViewRect), dateLabelHeight);
        UILabel *buyDateMonthLabel = [[UILabel alloc] initWithFrame:buyDateMonthLabelRect];
        [buyDateMonthLabel setBackgroundColor:[UIColor clearColor]];
        [buyDateMonthLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [buyDateMonthLabel setTextColor:[UIColor colorWithRed:0x88/255.0 green:0x84/255.0 blue:0x74/255.0 alpha:1.0f]];
        [buyDateMonthLabel setTextAlignment:NSTextAlignmentCenter];
        [buyDateMonthLabel setTag:1100];
        [cell.contentView addSubview:buyDateMonthLabel];
        [buyDateMonthLabel release];
        
        //buyDateDayLabel 彩票订单购买日
        CGRect buyDateDayLabelRect = CGRectMake(0, CGRectGetMaxY(buyDateMonthLabelRect), CGRectGetWidth(datebackImageViewRect), dateLabelHeight);
        UILabel *buyDateDayLabel = [[UILabel alloc] initWithFrame:buyDateDayLabelRect];
        [buyDateDayLabel setBackgroundColor:[UIColor clearColor]];
        [buyDateDayLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize21]];
        [buyDateDayLabel setTextColor:[UIColor colorWithRed:0x88/255.0 green:0x84/255.0 blue:0x74/255.0 alpha:1.0f]];
        [buyDateDayLabel setTextAlignment:NSTextAlignmentCenter];
        [buyDateDayLabel setTag:1101];
        [cell.contentView addSubview:buyDateDayLabel];
        [buyDateDayLabel release];
        
        // 奖金优化"优"字标
        UILabel *youLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 6, 18, 18)];
        [youLabel setBackgroundColor:[UIColor clearColor]];
        [youLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [youLabel setTextAlignment:NSTextAlignmentCenter];
        [youLabel setTag:1108];
        youLabel.text = @"优";
        youLabel.alpha = 0.8;
        youLabel.textColor = [UIColor redColor];
        [youLabel.layer setBorderColor:[[UIColor redColor] CGColor]];
        [youLabel.layer setBorderWidth:0.6f];
        [youLabel.layer setCornerRadius:9.0f];
        [cell.contentView addSubview:youLabel];
        [youLabel release];

        //issueNumberLabel 彩种名
        CGRect issueNumberLabelRect = CGRectMake(CGRectGetMinX(backImageViewRect) + issueNumberLabelMinX, issueNumberLabelMinY, issueNumberLabelWidht, backImageViewLabelHeight);
        UILabel *issueNumberLabel = [[UILabel alloc] initWithFrame:issueNumberLabelRect];
        [issueNumberLabel setBackgroundColor:[UIColor clearColor]];
        [issueNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [issueNumberLabel setTextAlignment:NSTextAlignmentLeft];
        [issueNumberLabel setTag:1102];
        [cell.contentView addSubview:issueNumberLabel];
        [issueNumberLabel release];
        
        //betCountLabel 彩金消费
        CGRect handselLabelRect = CGRectMake(CGRectGetMinX(issueNumberLabelRect), CGRectGetMaxY(issueNumberLabelRect) + labelVerticalInterval, betCountLabelWidht, backImageViewLabelHeight);
        UILabel *handselLabel = [[UILabel alloc] initWithFrame:handselLabelRect];
        [handselLabel setBackgroundColor:[UIColor clearColor]];
        [handselLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [handselLabel setTextColor:[UIColor colorWithRed:0x88/255.0 green:0x84/255.0 blue:0x87/255.0 alpha:1.0f]];
        [handselLabel setTextAlignment:NSTextAlignmentLeft];
        [handselLabel setTag:1106];
        [cell.contentView addSubview:handselLabel];
        [handselLabel release];
        
        //amountLabel 金额消费
        CGRect amountLabelRect = CGRectMake(CGRectGetMinX(issueNumberLabelRect), CGRectGetMaxY(handselLabelRect) + labelVerticalInterval, betCountLabelWidht, backImageViewLabelHeight);
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:amountLabelRect];
        [amountLabel setBackgroundColor:[UIColor clearColor]];
        [amountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [amountLabel setTextColor:[UIColor colorWithRed:0x88/255.0 green:0x84/255.0 blue:0x87/255.0 alpha:1.0f]];
        [amountLabel setTextAlignment:NSTextAlignmentLeft];
        [amountLabel setTag:1103];
        [cell.contentView addSubview:amountLabel];
        [amountLabel release];
        
        //betTypeLabel 订单类型
        CGRect betTypeLabelRect = CGRectMake(CGRectGetMaxX(amountLabelRect), CGRectGetMinY(handselLabelRect), betTypeLabelWidht, backImageViewLabelHeight);
        UILabel *betTypeLabel = [[UILabel alloc] initWithFrame:betTypeLabelRect];
        [betTypeLabel setBackgroundColor:[UIColor clearColor]];
        [betTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [betTypeLabel setTextColor:[UIColor colorWithRed:0x88/255.0 green:0x84/255.0 blue:0x87/255.0 alpha:1.0f]];
        [betTypeLabel setTextAlignment:NSTextAlignmentLeft];
        [betTypeLabel setTag:1104];
        [cell.contentView addSubview:betTypeLabel];
        [betTypeLabel release];
        
        //resultLabel 订单情况
        CGRect resultLabelRect = CGRectMake(CGRectGetWidth(self.frame) - leftSignImageViewMaginRightX - leftSignImageViewWidth - resultLabelMaginLeftSignX - resultLabelWidth, (CustomMyTicketsCellHeight - CGRectGetHeight(amountLabelRect)) / 2, resultLabelWidth, backImageViewLabelHeight);
        UILabel *resultLabel = [[UILabel alloc] initWithFrame:resultLabelRect];
        [resultLabel setBackgroundColor:[UIColor clearColor]];
        [resultLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [resultLabel setTextColor:[UIColor blackColor]];
        [resultLabel setTextAlignment:NSTextAlignmentRight];
        [resultLabel setTag:1105];
        [cell.contentView addSubview:resultLabel];
        [resultLabel release];
        
        CGRect leftSignImageViewRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignImageViewWidth - leftSignImageViewMaginRightX, (CustomMyTicketsCellHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
        UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
        [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        [cell.contentView addSubview:leftSignImageView];
        [leftSignImageView release];
    }
    
    if (_schemeList.count > 0) {
        //topLineImageView
        UIImageView *topLineImageView = (UIImageView *)[cell.contentView viewWithTag:1150];
        if (indexPath.row == 0) {
            [topLineImageView setHidden:NO];
        } else {
            [topLineImageView setHidden:YES];
        }
        
        //bottomLineImageView
        UIImageView *bottomLineImageView = (UIImageView *)[cell.contentView viewWithTag:1151];
        
        NSDictionary *schemeDict = [_schemeList objectAtIndex:indexPath.section];
        NSString *buyDate = [schemeDict objectForKey:@"date"];
        
        //buyDateMonthLabel  彩票订单购买月份
        UILabel *buyDateMonthLabel = (UILabel *)[cell.contentView viewWithTag:1100];
        NSString *month = [buyDate substringWithRange:NSMakeRange(5, 2)];
        [buyDateMonthLabel setText:(indexPath.row == 0 ? [NSString stringWithFormat:@"%@月",month] : @"")];
        
        //buyDateDayLabel 彩票订单购买日
        UILabel *buyDateDayLabel = (UILabel *)[cell.contentView viewWithTag:1101];
        NSString *day = [buyDate substringWithRange:NSMakeRange(8, 2)];
        [buyDateDayLabel setText:(indexPath.row == 0 ? day : @"")];
        
        NSMutableArray *detailArray =  [schemeDict objectForKey:(_indexPage != BetRecordTypeOfChase ? @"dateDetail" : @"chaseTaskDetail")];
        NSDictionary *detailDict = [detailArray objectAtIndex:indexPath.row];
        if (indexPath.row + 1 == [detailArray count]) {
            [bottomLineImageView setFrame:CGRectMake(0, CGRectGetMinY(bottomLineImageView.frame), CGRectGetWidth(tableView.frame), CGRectGetHeight(bottomLineImageView.frame))];
        } else {
            [bottomLineImageView setFrame:CGRectMake(backImageViewMinX, CGRectGetMinY(bottomLineImageView.frame), CGRectGetWidth(tableView.frame) - backImageViewMinX, CGRectGetHeight(bottomLineImageView.frame))];
        }
        
        NSInteger lotteryIndex = [Globals findDetailIndexWithLotteryId:[detailDict intValueForKey:@"lotteryID"] lotteryIDArray:_lotteryIDArray];
        NSString *lotteryName = @"";
        if (lotteryIndex >= 0 && lotteryIndex < [_lotteryNameArray count]) {
            lotteryName = [_lotteryNameArray objectAtIndex:lotteryIndex];
        }
        
        //issueNumberLabel 彩种名
        UILabel *issueNumberLabel = (UILabel *)[cell.contentView viewWithTag:1102];
        if (lotteryName.length > 0) {
            [issueNumberLabel setText:lotteryName];
        } else {
            [issueNumberLabel setText:[detailDict objectForKey:@"lotteryName"]];
        }
        
        // 优化“优”字
        UILabel *youLabel = (UILabel *)[cell.contentView viewWithTag:1108];
        BOOL isPreBet = [[detailDict objectForKey:@"isPreBet"] boolValue];
        if (_indexPage != BetRecordTypeOfChase && isPreBet) {
            youLabel.hidden = NO;
        }else {
            youLabel.hidden = YES;
        }
        
        //amountLabel 金额消费
        UILabel *amountLabel = (UILabel *)[cell.contentView viewWithTag:1103];
        [amountLabel setText:[NSString stringWithFormat:@"金额消费%@元",[detailDict objectForKey:@"detailMoney"]]];
        
        //handselLabel 彩金消费
        UILabel *handselLabel = (UILabel *)[cell.contentView viewWithTag:1106];
        [handselLabel setText:[NSString stringWithFormat:@"彩金消费%@元",[detailDict objectForKey:@"handselMoney"]]];
        
        //betTypeLabel 订单类型
        UILabel *betTypeLabel = (UILabel *)[cell.contentView viewWithTag:1104];
        [betTypeLabel setText:[detailDict stringForKey:@"orderTypeStr"]];
        
        //resultLabel 订单情况
        UILabel *resultLabel = (UILabel *)[cell.contentView viewWithTag:1105];
        NSLog(@"%@",[detailDict stringForKey:@"orderMainStatus"]);
        [resultLabel setText:[detailDict stringForKey:@"orderMainStatus"]];
        [resultLabel setTextColor: (resultLabel.text.length > 3 ? kRedColor : [UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f])];
    }
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 20)];
    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CustomMyTicketsCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicSection = [_schemeList objectAtIndex:indexPath.section];
    if (_indexPage != BetRecordTypeOfChase) {
        NSDictionary *dicRow = [[dicSection objectForKey:@"dateDetail"] objectAtIndex:indexPath.row];
        if ([_delegate respondsToSelector:@selector(selectBetRecordCell:indexPage:)]) {
            [_delegate selectBetRecordCell:dicRow indexPage:_indexPage];
        }
    } else {
        NSDictionary *dicRow = [[dicSection objectForKey:@"chaseTaskDetail"] objectAtIndex:indexPath.row];
        if ([_delegate respondsToSelector:@selector(selectBetRecordCell:indexPage:)]) {
            [_delegate selectBetRecordCell:dicRow indexPage:_indexPage];
        }
    }
}

//下拉刷新,上拖加载更多
#pragma mark -UIScrollViewDelegate
//会在视图滚动时收到通知。包括一个指向被滚动视图的指针，从中可以读取contentOffset属性以确定其滚动到的位置。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tracking || _isFirstLoading) {
        _isFirstLoading = NO;
        [_m_tableView tableViewDidScroll:scrollView];
    }
}

//当用户抬起拖动的手指时得到通知。还会得到一个布尔值，知名报告滚动视图最后位置之前，是否需要减速。
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_m_tableView tableViewDidEndDragging:scrollView];
}

#pragma mark -PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView {
    _isAddMore = NO;
    _page = 1;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0f];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView {
    _isAddMore = YES;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0f];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate {
    return [NSDate date];
}

- (NSDate *)pullingTableViewLoadingFinishedDate {
    return [NSDate date];
}

#pragma mark -ASIHTTPRequestDelegate
- (void) GetErr:(ASIHTTPRequest *)request {
    [_m_tableView tableViewDidFinishedLoading];
}

- (void) GetResult:(ASIHTTPRequest *)request {
    //上拖加载更多
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if (responseDic) {
        NSArray *tmpSchemeList;
        
        if (_indexPage == BetRecordTypeOfChase) {
            tmpSchemeList = [responseDic objectForKey:@"chaseTaskDetailsList"];
        } else {
            tmpSchemeList = [responseDic objectForKey:@"schemeList"];
        }
        
        if (!_isAddMore) {
            [_schemeList removeAllObjects];
        }
        NSInteger timeInt = [Globals timeConvertToIndegerWithStringWithStringTime:[responseDic stringForKey:@"serverTime"] beforeMonth:3];
        
        NSInteger count = 0;
        if (_indexPage == BetRecordTypeOfChase) {
            count = [CustomResultParser parseResult:tmpSchemeList withChaseOrderArray:_schemeList timeInt:timeInt];
        } else {
            count = [CustomResultParser parseResult:tmpSchemeList withNormalOrderArray:_schemeList timeInt:timeInt];
        }
        
        // 每一次请求30条数据，如果当前请求获取的数据少于30条，则表明已经请求完毕，无需再上拉表格获取更多
        // 如果刚好30条，则继续加载；
        // 总数据数量
        if (count == 0) {
            _m_tableView.headerOnly = YES;
            _m_tableView.reachedTheEnd  = YES;
            [XYMPromptView defaultShowInfo:@"没有数据" isCenter:NO];

        } else if (count < requestSize && count > 0) {
            _m_tableView.headerOnly = YES;
            _m_tableView.reachedTheEnd  = YES;
        } else {
            _m_tableView.headerOnly = NO;
            _m_tableView.reachedTheEnd  = NO;
        }
        
        
        _page++;
        [_m_tableView tableViewDidFinishedLoading];
        [_m_tableView reloadData];
    }
}

#pragma mark -
#pragma mark -Customized(Action)

#pragma mark -Customized: Private (General)
- (void)loadInitData {
    if (_page == 1) {
        [_m_tableView launchRefreshing];
    }
}

- (void)cancleRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

//加载数据
- (void)loadData {
    // 判断第一次点击进来（针对 全部 模块）
    if (_m_status != 1 && _m_status != 2 && _m_status != 3 && _m_status != 4) {
        _m_status = -1;
    }
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    NSString *lottoeryIds = [InterfaceHelper getAllLotteryString];
    [infoDic setObject:lottoeryIds forKey:@"lotteryId"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_page] forKey:@"pageIndex"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",requestSize] forKey:@"pageSize"];
    if (_indexPage != BetRecordTypeOfChase) {
        [infoDic setObject:@"5" forKey:@"sort"];
        [infoDic setObject:@"-1" forKey:@"isPurchasing"];
        [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_m_status] forKey:@"status"];
    } else {
        [infoDic setObject:@"0" forKey:@"sort"];
    }
    [infoDic setObject:@"0" forKey:@"sortType"];
    
    [self cancleRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:_indexPage == BetRecordTypeOfChase ? HTTP_REQUEST_GetAllChaseOrderTicket : HTTP_REQUEST_GetAllOrderTicket userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    NSLog(@"%@",_httpRequest.url);
    [_httpRequest setDidFinishSelector:@selector(GetResult:)];
    [_httpRequest setDidFailSelector:@selector(GetErr:)];
    [_httpRequest startAsynchronous];
}


@end
