//
//  LaunchChippedListViewController.m   名人名单
//  TicketProject
//
//  Created by sls002 on 13-6-4.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140716 15:44（洪晓彬）：修改代码规范，改进生命周期，处理内存
//  20140806 10:30（洪晓彬）：进行ipad适配
//  20150819 10:57（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "LaunchChippedListViewController.h"
#import "HelpViewController.h"
#import "MDRadialProgressView.h"
#import "SelectLotteryNameDialogView.h"
#import "SolutionDetailViewController.h"
#import "SortButton.h"
#import "XFTabBarViewController.h"
#import "SVProgressHUD.h"
#import "NameModel.h"

#import "NSString+CustomString.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import "UserInfo.h"
#import "Model.h"
#import "MyTableViewCell.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "PaySucceedViewController.h"

#define kOncePageSize 30
#define LaunchChippedListViewTabelCellHeight (IS_PHONE ? 85.0f : 130.0f)

@interface LaunchChippedListViewController ()<UITextFieldDelegate,CustomAlertViewDelegate>
{
    CGFloat _Allprice;
    NSString *_AllIDstr;
    NSString *_Allmultiple;
    UIView   *_nameView;
    UIWindow *_nameWindow;
    NSString *_Userstr;
}
@property(nonatomic,strong)NSMutableArray *MyArray;
@property(nonatomic,strong)UIView *bgview;
@property(nonatomic,strong)NSMutableArray *redMut;
@property(nonatomic,strong)NSMutableArray *redNameArray;
@property(nonatomic,strong)NSArray *tempArray;
/** 根据彩种ID 排序方式 获取合买方案列表
 @param   lotteryID   彩种id
 @param   index
 @param   sort
 @param   type */
- (void)requestWithLotteryId:(NSInteger)lotteryID pageIndex:(NSInteger)index sort:(NSInteger)sort sortType:(NSInteger)type;
/** 获取合买列表数据源 */
- (void)getList;
/** 刷新表头调用，正在刷新数据，用来更新合买列表 */
- (void)reloadTableViewDataSource;
/** 刷新表头调用，已经刷新数据，收回刷新表头 */
-(void)doneLoadingTableViewData;
@end

#pragma mark -
#pragma mark @implementation LaunchChippedListViewController
@implementation LaunchChippedListViewController
#pragma mark Lifecircle

- (id)init {
    self  = [super init];
    if (self) {
    }
    return self;
}

//-(void)dealloc {
//    _tableListView = nil;
//    _refreshTableHeaderView = nil;
//    _dialogView = nil;
//    
//    [_ticketNameArray release];
//    _ticketNameArray = nil;
//    [_ticketIDArray release];
//    _ticketIDArray = nil;
//    [_schemeArray release];
//    _schemeArray = nil;
//    [_MyArray release];
//    _MyArray = nil;
//    [super dealloc];
//}

- (void)loadView {
    
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor whiteColor]];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
//	[baseView release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat navigationMidViewWidth = 100.0f;// 顶部－中间背景按钮的宽度
    CGFloat navigationMidViewHeight = 25.0f;//
    
    NSArray *btnTitles = [NSArray arrayWithObjects:@"全部",@"红人方案", nil];//顶部按钮的名字
    CGFloat sortBtnMinX = IS_PHONE ? 0.0f : 0.0f;//顶部按钮的x
    CGFloat sortBtnMinY = IS_PHONE ? 0.0f : 5.0f;
    CGFloat sortBtnInterval = 0.0f;//顶部按钮与按钮之间的水平间距
    CGFloat sortBtnWidth = (CGRectGetWidth(appRect) - sortBtnMinX * 2 - sortBtnInterval * ([btnTitles count] - 1)) / [btnTitles count];
    CGFloat sortBtnHeight = IS_PHONE ? 35.0f : 45.0f;
    CGFloat sortBtnVerticalInterval = IS_PHONE ? 0.0f : 0.0f;//顶部按钮控件的上下间距
    
    CGFloat shadeLineImageViewHeight = 3.0f;
    /********************** adjustment end ***************************/
    
    //midView 顶部－中间背景图
    CGRect midViewRect = CGRectMake(0, 0, navigationMidViewWidth, navigationMidViewHeight);
    UIView *midView = [[UIView alloc]initWithFrame:midViewRect];
    [self.navigationItem setTitleView:midView];
//    [midView release];
    
    //midBtn 顶部－中间
    CGRect midBtnRect = CGRectMake(0, 0, navigationMidViewWidth, navigationMidViewHeight);
    UIButton *midBtn = [[UIButton alloc] initWithFrame:midBtnRect];
    [midBtn setTag:1000];
    [midBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize18]];
    [midBtn setTitle:@"全部彩种" forState:UIControlStateNormal];
    [midBtn setContentEdgeInsets:UIEdgeInsetsMake(0,-20, 0, 0)];
    [midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    [midBtn addTarget:self action:@selector(selectTicketTypeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [midView addSubview:midBtn];
//    [midBtn release];
    
    //创建顶部两个
    for (NSInteger i = 0; i < [btnTitles count]; i++) {
        CGRect sortBtnRect = CGRectMake(sortBtnMinX + i * (sortBtnWidth + sortBtnInterval), sortBtnMinY, sortBtnWidth, sortBtnHeight);
        SortButton *sortBtn = [[SortButton alloc] initWithFrame:sortBtnRect];
        [sortBtn setFrame:sortBtnRect];
        [sortBtn setTitle:[btnTitles objectAtIndex:i]];
        [sortBtn setTag:i+100];
        if (sortBtn.tag == 100) {
            [sortBtn addTarget:self action:@selector(sortTableListTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [sortBtn addTarget:self action:@selector(rednamecome:) forControlEvents:UIControlEventTouchUpInside];
        }

        
        [sortBtn setSelected:i == 0];
        [self.view addSubview:sortBtn];
//        [sortBtn release];
    }
    
    //shadeLineImageView
    CGRect shadeLineImageViewRect = CGRectMake(0, sortBtnVerticalInterval * 2 + sortBtnHeight, CGRectGetWidth(appRect), shadeLineImageViewHeight);
    UIImageView *shadeLineImageView = [[UIImageView alloc] initWithFrame:shadeLineImageViewRect];
    [shadeLineImageView setBackgroundColor:[UIColor clearColor]];
    [shadeLineImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shadeTop.png"]]];
    [self.view addSubview:shadeLineImageView];
//    [shadeLineImageView release];
    
    //tableListView 合买方案表格视图
    CGRect tableListViewRect = CGRectMake(0,CGRectGetMaxY(shadeLineImageViewRect), CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(shadeLineImageViewRect) - kTabBarHeight - kNavigationBarHeight);
    _tableListView = [[UITableView alloc]initWithFrame:tableListViewRect style:UITableViewStylePlain];
    [_tableListView setBackgroundColor:[UIColor whiteColor]];
    [_tableListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableListView setDataSource:self];
    [_tableListView setDelegate:self];
    [self.view addSubview:_tableListView];
//    [_tableListView release];
    
    //refreshTableHeaderView 合买表格顶部的刷新控件
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0 - CGRectGetHeight(tableListViewRect), CGRectGetWidth(appRect), CGRectGetHeight(tableListViewRect))];
    [_refreshTableHeaderView setDelegate:self];
    [_tableListView addSubview:_refreshTableHeaderView];
//    [_refreshTableHeaderView release];
    
    //dialog 彩种筛选框
    _dialogView = [[SelectLotteryNameDialogView alloc]initWithPlayMethodNames:_ticketNameArray lottery:self.title withIndex:_btnIndex];
    [_dialogView setDelegate:self];
    [self.view addSubview:_dialogView];
//    _redlogView
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _MyArray = [[NSMutableArray alloc]init];
    _redMut = [[NSMutableArray alloc]init];
    _redNameArray = [[NSMutableArray alloc]init];
//    _schemeArray = [[NSMutableArray alloc]initWithCapacity:0];
    _pageIndex = 1;
    _sortType = 0;
    _Userstr = @"-1";
    
    NSDictionary *dic = [InterfaceHelper getLotteryIDNameDic];
    NSArray *nameArray = [dic objectForKey:@"name"];
    _ticketNameArray = [[NSMutableArray alloc]init];
    [_ticketNameArray addObject:@"全部"];
    [_ticketNameArray addObjectsFromArray:nameArray];
    
    NSArray *idArray = [dic objectForKey:@"id"];
    _ticketIDArray = [[NSMutableArray alloc]init];
    [_ticketIDArray addObject:@""];
    [_ticketIDArray addObjectsFromArray:idArray];
    
    [self getname];
    
    
    [self getList];
    
    [_refreshTableHeaderView refreshLastUpdatedDate];
    
    [self createBgview];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewWillAppear:animated];
    
    [self getList];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    if (self.isViewLoaded && !self.view.window) {
//        _tableListView = nil;
//        _refreshTableHeaderView = nil;
//        _dialogView = nil;
//        [_ticketNameArray release];
//        _ticketNameArray = nil;
//        [_ticketIDArray release];
//        _ticketIDArray = nil;
//        [_schemeArray release];
//        _schemeArray = nil;
//        self.view = nil;
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [self clearLaunchChippedRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _MyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
#warning 提交审核时记得确认复制按钮隐藏
    Model *model = [[Model alloc]init];
    model = _MyArray[indexPath.row];
    NSLog(@"%@",model.fuzhiCount);
    static NSString *cellIdentifier = @"CustomLaunchChippedCell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier target:self];

        cell.ticketNameLabel.text = model.lotteryName;
        
        NSString *tempS = model.initiateName;
        if (tempS.length>2) {
            //发起人隐藏
            tempS = [[tempS substringToIndex:tempS.length-2] stringByAppendingString:@"**"];
        }
        cell.namelabel.text = [NSString stringWithFormat:@"发起人:%@",tempS];//model.initiateName;
//        if (_redNameArray.count>0) {//之前无名人字段时标红方法
//            for (NameModel *ele in _redNameArray) {
//                if ([model.initiateName isEqualToString:ele.userName]) {
//                    [cell.namelabel setTextColor:kRedColor];
//                    break;
//                }else{
//                    [cell.namelabel setTextColor:[UIColor blackColor]];
//                }
//            }
//        }
        
        if (model.isRedName) {
            [cell.namelabel setTextColor:kRedColor];
        }else{
            [cell.namelabel setTextColor:[UIColor blackColor]];
        }
        
        cell.littleticketNameLabel.text = model.passType;
        CGFloat haha = [model.money floatValue];
        cell.eachAmountLabel.text = [NSString stringWithFormat:@"%.1f元",haha];
        CGFloat hehe = [model.sumMoney floatValue];
        cell.solutionAmountLabel.text = [NSString stringWithFormat:@"%.1f元",hehe];
        cell.remainCopiesLabel.text = [NSString stringWithFormat:@"%@人",model.fuzhiCount];
        [cell.top addTarget:self action:@selector(copydetail:) forControlEvents:UIControlEventTouchUpInside];
        [cell.down addTarget:self action:@selector(detail:) forControlEvents:UIControlEventTouchUpInside];
        
        }
    cell.top.tag = 600+indexPath.row;
    cell.down.tag = 600+indexPath.row;
    cell.ticketNameLabel.text = model.lotteryName;
    
    NSString *tempS = model.initiateName;
    if (tempS.length>2) {
        //发起人隐藏
        tempS = [[tempS substringToIndex:tempS.length-2] stringByAppendingString:@"**"];
    }
    cell.namelabel.text = [NSString stringWithFormat:@"发起人:%@",tempS];//model.initiateName;
//    if (_redNameArray.count>0) {//之前无名人字段时标红方法
//        for (NameModel *ele in _redNameArray) {
//            if ([model.initiateName isEqualToString:ele.userName]) {
//                [cell.namelabel setTextColor:kRedColor];
//                break;
//            }else{
//                [cell.namelabel setTextColor:[UIColor blackColor]];
//            }
//        }
//    }
    
    if (model.isRedName) {
        [cell.namelabel setTextColor:kRedColor];
    }else{
        [cell.namelabel setTextColor:[UIColor blackColor]];
    }

    
    cell.littleticketNameLabel.text = model.passType;
    CGFloat haha = [model.money floatValue];
    cell.eachAmountLabel.text = [NSString stringWithFormat:@"%.1f元",haha];
    CGFloat hehe = [model.sumMoney floatValue];
    cell.solutionAmountLabel.text = [NSString stringWithFormat:@"%.1f元",hehe];
    cell.remainCopiesLabel.text = [NSString stringWithFormat:@"%@人",model.fuzhiCount];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LaunchChippedListViewTabelCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)deceleratescrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _tableListView) {
        NSArray *visibleRows = [_tableListView visibleCells];
        UITableViewCell *lasVisibleCell = [visibleRows lastObject];
        NSIndexPath *path = [_tableListView indexPathForCell:lasVisibleCell];
        if (path.section == 0 && path.row == [_schemeArray count]-1 && _hasMore) {
            _isAddMore = YES;
            _pageIndex++;
            _Userstr = @"-1";
            [self requestWithLotteryId:_selectLotteryID pageIndex:_pageIndex sort:_sortRule sortType:_sortType];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

#pragma mark -ASIHTTPRequestDelegate
//根据彩种ID 排序方式 获取合买方案列表   成功   处理方法
//-(void)requestFinished:(ASIHTTPRequest *)httpRequest {
//    [SVProgressHUD showSuccessWithStatus:@"查询成功"];
//    
//    NSDictionary *responseDic = [[httpRequest responseString] objectFromJSONString];
//    
//    if (responseDic) {
//        
//        NSArray *list = [responseDic objectForKey:@"schemeList"];
//        if ([list count] == 0) {
//            NSString *prompt = @"没有数据";
//            if (_hasMore)
//                prompt = @"数据加载完";
//            _hasMore = NO;
//            [XYMPromptView showInfo:prompt bgColor:[UIColor blackColor].CGColor inView:[MyAppDelegate shareAppDelegate].window isCenter:NO vertical:1];
//            [XYMPromptView defaultShowInfo:prompt isCenter:NO];
//            return;
//        } else if (list.count < kOncePageSize && list.count > 0) {
//            _hasMore = NO;
//        } else {
//            _hasMore = YES;
//        }
//        if(_isAddMore) {
//            [_schemeArray addObjectsFromArray:list];
//        } else {
//            [_schemeArray removeAllObjects];
//            [_schemeArray addObjectsFromArray:list];
//        }
////        [_tableListView reloadData];
//        list = nil;
//    }
//    
//    responseDic = nil;
//    _isLoading = NO;
//}

//根据彩种ID 排序方式 获取合买方案列表   失败   处理方法
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"数据获取失败"];
    _isLoading = NO;
}

#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

#pragma mark DropDownListViewDelegate
//下拉选项框
- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {

        UIView *midView = self.navigationItem.titleView;
        UIButton *midButton = (UIButton *)[midView viewWithTag:1000];
        [midButton setTitle:[_dialogView.nameArray objectAtIndex:index] forState:UIControlStateNormal];
        [midButton setBackgroundImage:[UIImage imageNamed:@"bettype.png"] forState:UIControlStateNormal];
        
        [self.navigationItem setTitleView:midView];
        
        _pageIndex = 1;
        _selectLotteryID = [[_dialogView.idArray objectAtIndex:index] intValue];
        _Userstr = @"-1";
        [self requestWithLotteryId:_selectLotteryID pageIndex:_pageIndex sort:_sortRule sortType:_sortType];
}

#pragma mark -
#pragma mark -Customized(Action)
//弹出选择彩种列表
- (void)selectTicketTypeTouchUpInside:(id)sender {
    [_dialogView setHidden:NO];
    [_dialogView show];
}

#pragma mark 各排序按钮事件
- (void)sortTableListTouchUpInside:(UIButton *)sender {
    if (sender.tag == 100) {
        [(UIButton *)[sender.superview viewWithTag:101] setSelected:NO];
        SortButton *sortBtn = (SortButton *)sender;
        if ([sortBtn isSelected]) {
            [sortBtn setIsAscendingOrder:![sortBtn isAscendingOrder]];
        }
        for (UIView *view in self.view.subviews) {
            if([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                [btn setSelected:NO];
            }
        }
        
        [_MyArray removeAllObjects];
        [_tableListView reloadData];
        
        _pageIndex = 1;
        _sortRule = sortBtn.tag;
        [sortBtn setSelected:!sortBtn.isSelected];
        _sortType = [sortBtn isAscendingOrder] ? 1 : 0;// 1是升序  0是降序
        _Userstr = @"-1";
        [self requestWithLotteryId:_selectLotteryID pageIndex:_pageIndex sort:_sortRule sortType:_sortType];
    }else{
    
    }
    
}

- (void)requestWithLotteryId:(NSInteger)lotteryID pageIndex:(NSInteger)index sort:(NSInteger)sort sortType:(NSInteger)type {
    
    
    [SVProgressHUD showWithStatus:@"加载中"];

    [_launchChippedRequest clearDelegatesAndCancel];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    NSString *Idstr = [NSString stringWithFormat:@"%ld",(long)lotteryID];
    [infoDic setObject:@"1" forKey:@"pageIndex"];
    [infoDic setObject:@"0" forKey:@"allCelebrity"];
    [infoDic setObject:_Userstr forKey:@"userId"];
    [infoDic setObject:@"-1" forKey:@"pageSize"];
    if (![Idstr isEqualToString:@"0"]) {
        [infoDic setObject:Idstr forKey:@"lotteryid"];
    }
    
    UserInfo *userInfo = [UserInfo shareUserInfo];
    _launchChippedRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_FormNumbers userId:userInfo.userID infoDict:infoDic]];

    [_launchChippedRequest setDelegate:self];
    
    [_launchChippedRequest startAsynchronous];
    
    [_launchChippedRequest setDidFinishSelector:@selector(checksFinished:)];
}
- (void)checksFinished:(ASIHTTPRequest *)request {
   
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    NSArray *array = responseDic[@"dataList"];
    _tempArray = array;
    [_MyArray removeAllObjects];
    NSLog(@"77-------->%@",[request responseString]);

    for (NSDictionary *dicc in array) {
        Model *mymodel = [[Model alloc]init];
        mymodel.ID = dicc[@"id"];
        mymodel.lotteryId = dicc[@"lotteryId"];
        mymodel.lotteryName = dicc[@"lotteryName"];
        mymodel.initiateName = dicc[@"initiateName"];
        mymodel.fuzhiCount = dicc[@"copyCount"];
        mymodel.passType = dicc[@"passType"];
        mymodel.schemeBonusScale = dicc[@"schemeBonusScale"];
        mymodel.multiple = dicc[@"multiple"];
        mymodel.money = dicc[@"money"];
        mymodel.sumMoney = dicc[@"sumMoney"];
        mymodel.schemeCount = dicc[@"schemeCount"];
        mymodel.schemeWin = dicc[@"schemeWin"];
        mymodel.winMoney = dicc[@"winMoney"];
        mymodel.isRedName = [[NSString stringWithFormat:@"%@",dicc[@"IsPersonages"]] isEqualToString:@"True"];
        [_MyArray addObject:mymodel];
    }
    [SVProgressHUD dismiss];
    if (_MyArray.count == 0) {
        [XYMPromptView defaultShowInfo:@"没有该彩种的数据" isCenter:NO];
    }
    [_tableListView reloadData];
}

- (void)clearLaunchChippedRequest {
    if (_launchChippedRequest != nil) {
        [_launchChippedRequest clearDelegatesAndCancel];
    }
}
-(void)getname
{
    
    [_nameRequest clearDelegatesAndCancel];
    _nameRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_NameNumbers userId:nil infoDict:nil]];
    
    
    [_nameRequest setDelegate:self];
    
    [_nameRequest startAsynchronous];
    NSLog(@"%@",_nameRequest.url);
    
    [_nameRequest setDidFinishSelector:@selector(namesFinished:)];
}

- (void)namesFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    NSLog(@"%@",responseDic);
    NSArray *array = responseDic[@"dataList"];
    for (NSDictionary *dicc in array) {
        NameModel *model = [[NameModel alloc]init];
//        model.lotteryID = dicc[@"lotterID"];
//        model.order = dicc[@"order"];
        model.userID = dicc[@"userID"];
        model.userName = dicc[@"userName"];
        [_redMut addObject:model];
        [_redNameArray addObject:model];
     
    }
    NSLog(@"%@",_redMut);
    NSLog(@"%@",_redNameArray);

    

    [self createnameView];
    
}
- (void)getList {
    _selectLotteryID = nil;
    _Userstr = @"-1";
    [self requestWithLotteryId:_selectLotteryID pageIndex:_pageIndex sort:0 sortType:0];
    
}

- (void)reloadTableViewDataSource {
    _isLoading = YES;
    _isAddMore = NO;
    _pageIndex = 1;
    _Userstr = @"-1";
    [self requestWithLotteryId:_selectLotteryID pageIndex:_pageIndex sort:_sortRule sortType:_sortType];
}

-(void)doneLoadingTableViewData {
    _isLoading = NO;
    [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableListView];
}
-(void)detail:(UIButton *)button
{
    NSDictionary *dic = [_tempArray objectAtIndex:button.tag-600];
    SolutionDetailViewController *detail = [[SolutionDetailViewController alloc]initWithSolutionDic:dic];
    
    Model *model = [_MyArray objectAtIndex:button.tag-600];
    
    detail.moeny = model.money;
    detail.schemeId = model.ID;
    [self.navigationController pushViewController:detail animated:YES];
    
//    NSDictionary *dic = [_MyArray objectAtIndex:button.tag - 600];
//    SolutionDetailViewController *detail = [[SolutionDetailViewController alloc]initWithSolutionDic:dic];
//    [self.navigationController pushViewController:detail animated:YES];
}
-(void)copydetail:(UIButton *)button
{
    Model *model = [[Model alloc]init];
    model = _MyArray[button.tag-600];

    UILabel *label1 = (UILabel *)[_bgview viewWithTag:1001];
    UILabel *label2 = (UILabel *)[_bgview viewWithTag:1002];
    UILabel *label3 = (UILabel *)[_bgview viewWithTag:1003];
    UILabel *label4 = (UILabel *)[_bgview viewWithTag:1004];
    UILabel *label5 = (UILabel *)[_bgview viewWithTag:1005];
    UILabel *label6 = (UILabel *)[_bgview viewWithTag:1006];
    UITextField *textField = (UITextField *)[_bgview viewWithTag:1007];
    
    label1.text = model.initiateName;
    CGFloat hehe = [model.money floatValue];
    _Allprice = hehe;
    _AllIDstr = model.ID;
    _Allmultiple = model.multiple;
    label2.text = [NSString stringWithFormat:@"%.2f",hehe];
    label3.text = model.passType;
    CGFloat haha = [model.schemeBonusScale floatValue];
    label4.text = [NSString stringWithFormat:@"%.2f%%",haha*100];
    label5.text = @"(可投99999倍)";
    label6.text = [NSString stringWithFormat:@"%.2f",hehe];
    textField.text = @"1";
    
    _bgview.hidden = NO;
}
//复制的弹出框
-(void)createBgview
{
    _bgview = [[UIView alloc]initWithFrame:self.view.frame];
    _bgview.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:_bgview];
    _bgview.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_bgTap)];
    [_bgview addGestureRecognizer:tap];
    
    UIView *selecview = [[UIView alloc]initWithFrame:CGRectMake(40, 80, self.view.bounds.size.width-80, self.view.bounds.size.height/2)];
    
    selecview.backgroundColor = [UIColor whiteColor];
    selecview.layer.masksToBounds = YES;
    selecview.layer.cornerRadius = 10;
    
    [_bgview addSubview: selecview];
    
    for (NSInteger x = 0; x < 7; x ++) {
        UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(0, selecview.frame.size.height/8*(x + 1), selecview.frame.size.width, 1)];
        if (x == 0) {
            lineview.backgroundColor = [UIColor redColor];
        }else{
            lineview.backgroundColor = [UIColor lightGrayColor];
        }
       
        [selecview addSubview:lineview];
    }
    
    UILabel *namelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, selecview.frame.size.width, selecview.frame.size.height/8)];
    namelabel.text = @"复制跟单";
    namelabel.textColor = [UIColor redColor];
    namelabel.textAlignment = NSTextAlignmentCenter;
    namelabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize14];
    [selecview addSubview:namelabel];
    NSArray *titleArray = @[@"方案发起人",@"单倍金额",@"投注方式",@"佣金比例",@"购买倍数",@"实付金额",];
    for (NSInteger y = 0; y < 6; y ++) {
        UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(20, selecview.frame.size.height/8*(y + 1), selecview.frame.size.width/2-20, selecview.frame.size.height/8)];
        titlelabel.text = titleArray[y];
        titlelabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
        [selecview addSubview:titlelabel];
    }
    
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, selecview.frame.size.height/8*7, selecview.frame.size.width/2, selecview.frame.size.height/8);
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(quxiao:) forControlEvents:UIControlEventTouchUpInside];
    [selecview addSubview:btn];
    
    
    
    
    UIButton *btn2 = [UIButton buttonWithType:0];
    btn2.frame = CGRectMake(selecview.frame.size.width/2, selecview.frame.size.height/8*7, selecview.frame.size.width/2, selecview.frame.size.height/8);
    [btn2 setTitle:@"确定" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(queding:) forControlEvents:UIControlEventTouchUpInside];
    btn2.backgroundColor = [UIColor orangeColor];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selecview addSubview:btn2];
    
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(selecview.frame.size.width/2-20, selecview.frame.size.height/8, selecview.frame.size.width/2+20, selecview.frame.size.height/8)];
    label1.text = @"label1";
    label1.tag = 1001;
    label1.textColor = [UIColor redColor];
    [selecview addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(selecview.frame.size.width/2-20, selecview.frame.size.height/8*2, selecview.frame.size.width/2+20, selecview.frame.size.height/8)];
    label2.text = @"label2";
    label2.tag = 1002;
    [selecview addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(selecview.frame.size.width/2-20, selecview.frame.size.height/8*3, selecview.frame.size.width/2+20, selecview.frame.size.height/8)];
    label3.text = @"label3";
    label3.tag = 1003;
    [selecview addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(selecview.frame.size.width/2-20, selecview.frame.size.height/8*4, selecview.frame.size.width/2+20, selecview.frame.size.height/8)];
    label4.text = @"label4";
    label4.tag = 1004;
    [selecview addSubview:label4];

    
    UILabel *label6 = [[UILabel alloc]initWithFrame:CGRectMake(selecview.frame.size.width/2-20, selecview.frame.size.height/8*6, selecview.frame.size.width/2+20, selecview.frame.size.height/8)];
    label6.text = @"label6";
    label6.tag = 1006;
    [selecview addSubview:label6];
    
    UITextField *textfield = [[UITextField alloc]initWithFrame:CGRectMake(selecview.frame.size.width/2-20, selecview.frame.size.height/8*5+5, 40, selecview.frame.size.height/8-10)];
    textfield.borderStyle = UITextBorderStyleLine;
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.text = @"1";
    textfield.delegate = self;
    textfield.tag = 1007;
    textfield.textColor = [UIColor lightGrayColor];
    textfield.clearsOnBeginEditing = YES;
    textfield.keyboardType = UIKeyboardTypeNumberPad;
    [selecview addSubview:textfield];
    
    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(textfield.frame)+5, selecview.frame.size.height/8*5, selecview.frame.size.width/2, selecview.frame.size.height/8)];
    label5.text = @"label5";
    label5.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
    label5.tag = 1005;
    [selecview addSubview:label5];
}

-(void)quxiao:(UIButton *)button
{
    UITextField *text = (UITextField *)[_bgview viewWithTag:1007];
    _bgview.hidden = YES;
    [text resignFirstResponder];
}
-(void)queding:(UIButton *)button
{
    CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%.2f元",[[(UILabel *)[_bgview viewWithTag:1006] text] floatValue]] leftText:@"取消" rightText:@"确定"];
    [customAlert setTag:76];
    [customAlert show];
}

#pragma mark 确认金钱
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if([UserInfo shareUserInfo].userID) {
            UITextField *text = (UITextField *)[_bgview viewWithTag:1007];
            UILabel *label = (UILabel *)[_bgview viewWithTag:1006];
            CGFloat haha = [label.text floatValue];
            NSString *strr = [NSString stringWithFormat:@"%0.f",haha];
            NSString *textstr = [NSString stringWithFormat:@"%@",text.text];
            if ([textstr isEqualToString:@""]) {
                textstr = @"1";
            }
            [text resignFirstResponder];
            
            [SVProgressHUD showWithStatus:@"加载中"];
            
            [_copyRequest clearDelegatesAndCancel];
            
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            
            [infoDic setObject:_AllIDstr forKey:@"schemeId"];
            [infoDic setObject:textstr forKey:@"multiple"];
            [infoDic setObject:strr forKey:@"money"];
            
            _copyRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_CopyNumbers userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
            NSLog(@"%@",infoDic);
            NSLog(@"%@",_copyRequest.url);
            
            [_copyRequest setDelegate:self];
            
            [_copyRequest startAsynchronous];
            
            [_copyRequest setDidFinishSelector:@selector(copyFinished:)];
            
            
        }else{
            UITextField *text = (UITextField *)[_bgview viewWithTag:1007];
            _bgview.hidden = YES;
            [text resignFirstResponder];
            [XYMPromptView defaultShowInfo:@"请先登录才能复制哦~" isCenter:NO];
        }

    }
}

- (void)copyFinished:(ASIHTTPRequest *)request
{
    UITextField *text = (UITextField *)[_bgview viewWithTag:1007];
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    NSString *str = responseDic[@"msg"];
    NSLog(@"78---------->%@",[request responseString]);
    [SVProgressHUD dismiss];
    _bgview.hidden = YES;
    [text resignFirstResponder];
    [XYMPromptView defaultShowInfo:str isCenter:NO];
    
    //    NSLog(@"responseDic == %@",[request responseString]);
//    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
//        // 购买成功后，会返回余额和冻结金额，保存起来
////        [[UserInfo shareUserInfo] setBalance:[responseDic objectForKey:@"balance"]];
////        [[UserInfo shareUserInfo] setFreeze:[responseDic objectForKey:@"freeze"]];
////        
////        // 保存到NSUserDefaults
////        NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
////        [userinfo setObject:[responseDic objectForKey:@"balance"] forKey:@"balance"];
////        [userinfo setObject:[responseDic objectForKey:@"freeze"] forKey:@"freeze"];
////        [[NSUserDefaults standardUserDefaults]setObject:userinfo forKey:@"userinfo"];
////        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        NSMutableDictionary *_orderDetailDict = [NSMutableDictionary dictionary];
//        [_orderDetailDict addEntriesFromDictionary:responseDic];
//        [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",_selectLotteryID] forKey:@"lotteryId"];
//        
//        PaySucceedViewController *paySucceedViewController = [[PaySucceedViewController alloc] initWithDict:_orderDetailDict buyType:NORMAL];
//        [self.navigationController pushViewController:paySucceedViewController animated:YES];
//        
//    } else if (responseDic && [[responseDic objectForKey:@"error"] intValue] == -134) {
//        [Globals alertWithMessage:[responseDic objectForKey:@"msg"] delegate:self tag:2];
//    } else if(responseDic) {
//        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
//    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textChange:%@",textField.text);
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([text length] > 5)
        return NO;

    NSString *str = [textField.text stringByAppendingString:string];
    NSInteger haha = [str integerValue];
    UILabel *label6 = (UILabel *)[_bgview viewWithTag:1006];
    label6.text = [NSString stringWithFormat:@"%.2f",haha*_Allprice];
    return YES;
}

#pragma mark 点击红人方案
-(void)rednamecome:(UIButton *)btn
{
    [(UIButton *)[btn.superview viewWithTag:100] setSelected:NO];
    [btn setSelected:YES];
    _nameView.hidden = NO;
}
-(void)createnameView{
    _nameView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _nameView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    
//    _nameWindow = [UIApplication sharedApplication].keyWindow;
//    [_nameWindow addSubview:_nameView];
//    [_nameWindow addSubview:self.view];
    [self.view addSubview:_nameView];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTap:)];
    [tap setCancelsTouchesInView:NO];
    [_nameView addGestureRecognizer:tap];
    UIView *whiteview;
   
    whiteview  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, (_redNameArray.count/3)*40+40)];
    
    whiteview.backgroundColor = [UIColor whiteColor];
    [_nameView addSubview:whiteview];

    for (NSInteger y = 0; y < _redNameArray.count; y ++) {
        NameModel *model = _redNameArray[y];
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(y%3 * self.view.bounds.size.width/3, y/3*40, self.view.bounds.size.width/3, 40);
        [btn setTitle:model.userName forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn setBackgroundImage:[UIImage imageNamed:@"singleMatchNormalBtn.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected | UIControlStateHighlighted];
        btn.tag = 200 + y;
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [whiteview addSubview:btn];
    }
    _nameView.hidden = YES;
}
- (void)dismissTap:(UITapGestureRecognizer *)gesture {
    _nameView.hidden = YES;
}
-(void)onClick:(UIButton *)sender
{
    for (int i = 0; i<_redNameArray.count; i++) {
        [(UIButton *)[sender.superview viewWithTag:200+i] setSelected:NO];
    }
    [sender setSelected:YES];
    NameModel *model = _redNameArray[sender.tag-200];
    NSLog(@"%@",model.userName);
    _Userstr = [NSString stringWithFormat:@"%@",model.userID];
    [self requestWithLotteryId:_selectLotteryID pageIndex:_pageIndex sort:0 sortType:0];
}

- (void)_bgTap{
    [_bgview endEditing:YES];
}


@end
