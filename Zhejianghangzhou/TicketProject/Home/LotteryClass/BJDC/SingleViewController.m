    //
//  SingleViewController.m   购彩大厅－竞彩足球选号
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140707 08:23（洪晓彬）：修改代码规范，改进生命周期
//20140923 10:30（洪晓彬）：进行ipad适配

#import "BaseSelectViewController.h"
#import "CustomBottomView.h"
#import "CustomSegmentedControl.h"
#import "CustomFootBallMainCell.h"
#import "CustomFootBallZJQButton.h"
#import "DialogFilterMatchView.h"
#import "DialogSelectButtonView.h"
#import "SingleBetViewController.h"
#import "SingleViewController.h"
#import "HelpViewController.h"
#import "SSQPlayMethodView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"
#import "UserInfo.h"

#import "Globals.h"
#import "GlobalsProject.h"

#define SingleViewControllerTabelCellHeight (IS_PHONE ? 64.5f : 100.0f)
#define SingleViewControllerTabelCellZJQHeight (IS_PHONE ? 80.0f : 130.0f)
#define SingleViewControllerTabelHeadViewHeight (IS_PHONE ? 27.5 : 55.0f)
#define SingleViewMatchTypeCustomSegmentedControl (IS_PHONE ? 30.0f : 60.0f)

@interface SingleViewController ()
/** 更新底部显示文字
    @param  count  选择的比赛场数 */
- (void)updateBottomViewDisplay:(NSInteger)count;
/** 刷新比赛数组 */
- (void)refreshMatchArrayWithSinglePassBarrierType:(SinglePassBarrierType)SinglePassBarrierType;
/** 猜比分  选中比分后将按钮的title 设置为选中的比分
    @param  array       选择的比分数组
    @param  indexPath   选择的下标路径 */
- (void)replaceButtonTextWithArray:(NSArray *)array AtIndex:(NSIndexPath *)indexPath;
/** 猜比分  将数组转换成用","隔开的字符串
    @param  array   选择的比分数组
    @return 用","隔开的字符串 */
- (NSString *)convertArrayToString:(NSArray *)array;
/** 获取比赛信息 在 字典中的位置
    @param  dic   比赛信息字典
    @return 比赛信息在字典中的位置 */
- (NSInteger)indexOfDictionary:(NSDictionary *)dic;
/**
    @param  dic
    @return  */
- (BOOL)isArrayContainsDictionary:(NSDictionary *)dic;
/** 获取特定彩种的玩法 */
- (void)getPlayMethods;
@end

#pragma mark -
#pragma mark @implementation SingleViewController
@implementation SingleViewController
@synthesize betViewController = _betViewController;
#pragma mark Lifecircle

- (id)initWithMatchData:(NSObject *)matchData SinglePassBarrierType:(SinglePassBarrierType)SinglePassBarrierType {
    self = [super init];
    if(self) {
        _completeMatchDict = [[(NSDictionary *)matchData objectForKey:@"dtMatch"] retain]; //完整比赛信息
        _matchDict = [[NSMutableDictionary alloc] init];
        _singleMatchDict = [[NSMutableDictionary alloc] init];
        
        _SinglePlayType = SinglePlayType_upAndDownSingle;
        [self filterMatchesWithServerKey:nil];

        _lotteryID = 45;
        self.title = @"北京单场";
        _betTypeArray = [[NSMutableArray alloc] init];
        [self getPlayMethods];
        
    }
    return self;
}

-(void)dealloc {
    _matchTableList = nil;
    _playMethodView = nil;
    _bottomView = nil;
    
    [_dropDic release];
    _dropDic = nil;
    [_singleDropDic release];
    _singleDropDic = nil;
    
    [_betTypeArray release];
    _betTypeArray = nil;
    
    [_completeMatchDict release];
    [_secmpleteMatchDict release];
    [_completeSingleMatchDict release];
    
    [_matchDict release];
    _matchDict = nil;
    [_singleMatchDict release];
    _singleMatchDict = nil;
    [_completeFilterMainMatchArray release];
    _completeFilterMainMatchArray = nil;
    
    [_selectScoreDic release];
    _selectScoreDic = nil;
    [_singleSelectScoreDic release];
    _singleSelectScoreDic = nil;
    
    [_selectHalfDict release];
    _selectHalfDict = nil;
    [_singleSelectHalfDict release];
    _singleSelectHalfDict = nil;
    
    [_selectMatchArray release];
    _selectMatchArray = nil;
    [_singleSelectMatchArray release];
    _singleSelectMatchArray = nil;
    
    [_filterMatchDic release];
    _filterMatchDic = nil;
    [_singleFilterMatchDic release];
    _singleFilterMatchDic = nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
	[baseView release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat midViewHeight = IS_PHONE ? 25.0f : 40.0f;
    CGFloat midViewCutWidht = IS_PHONE ? 35.0f : 60.0f;
    
    CGFloat filterBtnMaginPlayingMethodBtn = 10.0f;
    CGFloat filterBtnWidth = IS_PHONE ? 22.0f : 44.0f;
    CGFloat filterBtnHeight = IS_PHONE ? 22.0f : 44.0f;
    
    CGFloat midBtnWidht = IS_PHONE ? 80.0f : 122.0f;
    CGFloat midBtnContentCutWidth = 20.0f;
    
    CGFloat bottomBtnHeight = IS_PHONE ? 45.0f : 70.0f;
    /********************** adjustment end ***************************/
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(dismissViewControllerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //playingMethodBtn  顶部－玩法介绍按钮
    CGRect playingMethodBtnRect = XFIponeIpadNavigationplayingMethodButtonRect;
    UIButton *playingMethodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playingMethodBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"playingMethod.png"]] forState:UIControlStateNormal];
    [playingMethodBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"playingMethod.png"]] forState:UIControlStateHighlighted];
    [playingMethodBtn setFrame:playingMethodBtnRect];
    [playingMethodBtn addTarget:self action:@selector(palyIntroduceTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *playingMethodItem = [[UIBarButtonItem alloc]initWithCustomView:playingMethodBtn];
    [self.navigationItem setRightBarButtonItem:playingMethodItem];
    [playingMethodItem release];
    
    if (self.navigationItem.titleView == nil) {
        //midView 顶部－中间的view
        CGRect midViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect) - CGRectGetWidth(comeBackBtnRect) - CGRectGetWidth(playingMethodBtnRect) - midViewCutWidht - filterBtnMaginPlayingMethodBtn * 2, midViewHeight);
        UIView *midView = [[UIView alloc]initWithFrame:midViewRect];
        [midView setBackgroundColor:[UIColor clearColor]];
        [midView setTag:500];
        [self.navigationItem setTitleView:midView];
        [midView release];
    
        //filterBtn  顶部－筛选按钮
        CGRect filterBtnRect = CGRectMake(CGRectGetWidth(midViewRect) - filterBtnWidth, 0, filterBtnWidth, filterBtnHeight);
        UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterBtn setFrame:filterBtnRect];
        [filterBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"filter.png"]] forState:UIControlStateNormal];
        [filterBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"filter.png"]] forState:UIControlStateHighlighted];
        [filterBtn addTarget:self action:@selector(filterMatchesTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [filterBtn setClipsToBounds:YES];
        [midView addSubview:filterBtn];
        
        //midBtn 顶部－中间按钮
        CGRect midBtnRect = CGRectMake((CGRectGetWidth(midViewRect) - midBtnWidht) / 2 + midBtnContentCutWidth / 2.0, 0, midBtnWidht, CGRectGetHeight(midViewRect));
        _midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_midBtn setFrame:midBtnRect];
        [_midBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
        [_midBtn setTitle:@"上下单双" forState:UIControlStateNormal];
        [_midBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_midBtn setTag:1000];
        [_midBtn setAdjustsImageWhenHighlighted:NO];
        [_midBtn setContentEdgeInsets:UIEdgeInsetsMake(0, -midBtnContentCutWidth, 0, 0)];
        [_midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_midBtn addTarget:self action:@selector(navMiddleBtnSelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_midBtn];
    }
    
    //SingleScrollView
    CGRect SingleScrollViewRect = CGRectMake( 0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kNavigationBarHeight * 2   );
    _SingleScrollView = [[UIScrollView alloc]initWithFrame:SingleScrollViewRect];
    [_SingleScrollView setClipsToBounds:YES];
    [_SingleScrollView setPagingEnabled:YES];
    [_SingleScrollView setDelegate:self];
    [_SingleScrollView setTag:1010];
    [_SingleScrollView setUserInteractionEnabled:YES];
    [_SingleScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_SingleScrollView];
    [_SingleScrollView release];
    
    //matchTableList 中部－比赛选择的tableview
    CGRect matchTableListRect = CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetHeight(SingleScrollViewRect));
    _matchTableList = [[UITableView alloc]initWithFrame:matchTableListRect style:UITableViewStylePlain];
    [_matchTableList setBackgroundColor:kBackgroundColor];
    [_matchTableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_matchTableList setTag:SinglePassBarrierType_moreMatch];
    [_matchTableList setDataSource:self];
    [_matchTableList setDelegate:self];
    [_SingleScrollView addSubview:_matchTableList];
    [_matchTableList release];
    
    //matchPromptLabel
    CGRect matchPromptLabelRect = CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetHeight(SingleScrollViewRect));
    _matchPromptLabel = [[UILabel alloc] initWithFrame:matchPromptLabelRect];
    [_matchPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_matchPromptLabel setText:@"当前暂无比赛"];
    [_matchPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize21]];
    [_matchPromptLabel setTextColor:[UIColor colorWithRed:192.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f]];
    [_matchPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_matchPromptLabel setHidden:[_matchDict count] > 0];
    [_SingleScrollView addSubview:_matchPromptLabel];
    [_matchPromptLabel release];
    
    //bottomView 底部框
    CGRect bottomViewRect =CGRectMake(0, self.view.bounds.size.height -  kNavigationBarHeight - bottomBtnHeight, self.view.bounds.size.width, bottomBtnHeight);
    _bottomView = [[CustomBottomView alloc]initWithFrame:bottomViewRect Type:1];
    [self.view addSubview:_bottomView];
    [_bottomView release];
    
    //leftBtn 底部－清空按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:@"清空" forState:UIControlStateNormal];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(clearAllTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView setLeftButton:leftBtn];
    
    //rightBtn 底部－选好了按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"选好了" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(okClickTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView setRightButton:rightBtn];
    
    //playMethodView  玩法选择框，开始隐藏
    _playMethodView = [[SSQPlayMethodView alloc]initWithPlayMethodNames:_betTypeArray lottery:self.title withIndex:_btnIndex];
    [_playMethodView setDelegate:self];
    [self.view addSubview:_playMethodView];
    [_playMethodView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHidesBottomBarWhenPushed:YES];
    [self.xfTabBarController setTabBarHidden:YES];
    
    if (_selectMatchArray == nil) {
        _selectMatchArray = [[NSMutableArray alloc] init];
    }
    if (_singleSelectMatchArray == nil) {
        _singleSelectMatchArray = [[NSMutableArray alloc] init];
    }
    if (_selectScoreDic == nil) {
        _selectScoreDic = [[NSMutableDictionary alloc] init];
    }
    if (_singleSelectScoreDic == nil) {
        _singleSelectScoreDic = [[NSMutableDictionary alloc] init];
    }
    if (_selectHalfDict == nil) {
        _selectHalfDict = [[NSMutableDictionary alloc] init];
    }
    if (_singleSelectHalfDict == nil) {
        _singleSelectHalfDict = [[NSMutableDictionary alloc] init];
    }
    if (_filterMatchDic == nil) {
        _filterMatchDic = [[NSMutableDictionary alloc] init];
    }
    if (_singleFilterMatchDic == nil) {
        _singleFilterMatchDic = [[NSMutableDictionary alloc] init];
    }
    if (_completeFilterMainMatchArray == nil) {
        _completeFilterMainMatchArray = [[NSMutableArray alloc] init];
    }
    
    if (_selectHalfMTArray == nil) {
        _selectHalfMTArray = [[NSMutableArray alloc] init];
    }
    if (_singleSelectHalfMTArray == nil) {
        _singleSelectHalfMTArray = [[NSMutableArray alloc] init];
    }
    
    
    _dropDic = [[NSMutableDictionary alloc]init];
    _singleDropDic = [[NSMutableDictionary alloc]init];
    
    [self filterCompleteArray];
    
    //第一次加载  全部展开
    for (NSInteger i = 0; i < [_matchDict count]; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_dropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    for (NSInteger i = 0; i < [_singleMatchDict count]; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_singleDropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    
    NSInteger index = [self getArrayIndexWithSingleBetSelectType:_SinglePlayType];
    
    // 进行添加比赛场次操作
    if (self.betViewController) {
        UIView *midView = self.navigationItem.titleView;
        UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
        midBtn.enabled = NO;
        NSString *strBetType = index < [_betTypeArray count] ? [_betTypeArray objectAtIndex:index] : @"";
        [midBtn setTitle:strBetType forState:UIControlStateNormal];
        [self updateBottomViewDisplay:[_selectMatchArray count]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    //刷新数组  在投注页面清空后
    [self refreshMatchArrayWithSinglePassBarrierType:SinglePassBarrierType_moreMatch];
    
    [_matchTableList reloadData];
    
    [self updateBottomViewDisplay:[_selectMatchArray count]];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _matchTableList = nil;
        _playMethodView = nil;
        _bottomView = nil;
        
        [_dropDic release];
        _dropDic = nil;
        [_betTypeArray release];
        _betTypeArray = nil;
        
        [_selectScoreDic release];
        _selectScoreDic = nil;
        [_singleSelectScoreDic release];
        _singleSelectScoreDic = nil;
        
        [_selectMatchArray release];
        _selectMatchArray = nil;
        [_singleSelectMatchArray release];
        _singleSelectMatchArray = nil;
        
        [_filterMatchDic release];
        _filterMatchDic = nil;
        [_singleFilterMatchDic release];
        _singleFilterMatchDic = nil;
        self.view = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 1010) {
        [self updateBottomViewDisplay:[_selectMatchArray count]];
    }
    
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_SinglePlayType == SinglePlayType_winlose || _SinglePlayType == SinglePlayType_totalGoal) {
        return SingleViewControllerTabelCellZJQHeight;
    } else {
        return SingleViewControllerTabelCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SingleViewControllerTabelHeadViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *sectionArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)section + 1]];
    if(sectionArray.count == 0) {
        //没有比赛  就返回透明的headview
        UIView *view = [[UIView alloc]init];
        [view setBackgroundColor:[UIColor clearColor]];
        return [view autorelease];
    }
    /********************** adjustment 控件调整 ***************************/
    CGFloat promptLabelMinX = 10.0f;
    
    CGFloat headViewDropBtnMinY = 0.0f;
    /********************** adjustment end ***************************/

    NSString *date = [[sectionArray objectAtIndex:0] objectForKey:@"day"];
    NSInteger matchCount = sectionArray.count;
    
    CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width, SingleViewControllerTabelHeadViewHeight);

    
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect]autorelease];
    
    UIButton *dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropBtn setFrame:CGRectMake(0, headViewDropBtnMinY, kWinSize.width, SingleViewControllerTabelHeadViewHeight - headViewDropBtnMinY)];
    [dropBtn setAdjustsImageWhenHighlighted:NO];
    [dropBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_normal.png"]] forState:UIControlStateNormal];
    [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_select.png"]] forState:UIControlStateSelected];
    [dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [dropBtn setTag:section]; //标示是第几个section
    [dropBtn addTarget:self action:@selector(dropDownListTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:dropBtn];
    
    CGRect promptLabelRect = CGRectMake(promptLabelMinX, 0, CGRectGetWidth(headerViewRect) - promptLabelMinX, CGRectGetHeight(headerViewRect));
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setText:[NSString stringWithFormat:@"%@  %ld场比赛可投",date,(long)matchCount]];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [headerView addSubview:promptLabel];
    [promptLabel release];
    
    NSDictionary *dic;
    
    if (tableView.tag == 0) {
        dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    } else {
        dic = [_singleDropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    }
    
    //如果是下拉状态  让button选中
    if([[dic objectForKey:@"isDropDown"] boolValue] == YES) {
        [dropBtn setSelected:YES]; //设置btn的状态  因为在tableview reloadData的时候
    }
    
    return headerView;
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    
    if (_SinglePlayType != SinglePlayType_no) {
        BOOL promptLabelHidden = [self hasMatchWithMatchDict:_matchDict SinglePlayType:_SinglePlayType];
        [_matchPromptLabel setHidden:promptLabelHidden];
        if (!promptLabelHidden) {
            return 0;
        }
    }
    
//    //table表示一天的比赛场次信息，一般服务器最多返回3天的比赛场次信息
//    if ([[_matchDict objectForKey:@"table1"] count] > 0) {
//        count++;
//    }
//    if ([[_matchDict objectForKey:@"table2"] count] > 0) {
//        count++;
//    }
//    if ([[_matchDict objectForKey:@"table3"] count] > 0) {
//        count++;
//    }
    
    for (int i = 0; i < _matchDict.count; i++) {
        if ([[_matchDict objectForKey:[NSString stringWithFormat:@"table%d",i + 1]] count] > 0) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowsArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)section + 1]];;
    NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    
    BOOL isDropdown = [[dic objectForKey:@"isDropDown"] boolValue];
    NSInteger dropSection = [[dic objectForKey:@"dropSection"] intValue];
    //如果不是下拉状态 并且选中的section相等 则返回0  实现收缩的效果
    if(!isDropdown && dropSection == section) {
        return 0;
    }
    return rowsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomFootBallMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleMainCell"];
    CGFloat cellHeight;
    if (_SinglePlayType == SinglePlayType_winlose || _SinglePlayType == SinglePlayType_totalGoal) {
        cellHeight = SingleViewControllerTabelCellZJQHeight;
    } else {
        cellHeight = SingleViewControllerTabelCellHeight;
    }
    if (cell == nil) {
        cell = [[[CustomFootBallMainCell alloc] initWithCellHight:cellHeight reuseIdentifier:@"SingleMainCell"] autorelease];
    }
    
    [cell setCellHight:cellHeight];
    
    //防止cell重用时  视图重叠,所以将元素移除
    if(cell) {
        for (UIView *view in cell.buttonImageView.subviews) {
            if([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSArray *sectionArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];

    //周五001
    cell.matchNO = [rowDic objectForKey:@"matchNumber"];
    //法乙
    cell.gameName = [rowDic objectForKey:@"game"];
    //日期\时间
    NSArray *matchDateArray = [[rowDic objectForKey:@"stopSellTime"] componentsSeparatedByString:@" "];
    //时间
    cell.matchDate = [matchDateArray objectAtIndex:1];
    //球队名
    cell.mainTeam = [rowDic objectForKey:@"mainTeam"];
    cell.guestTeam = [rowDic objectForKey:@"guestTeam"];
    
    NSMutableArray *selectAry = [[[NSMutableArray alloc]init] autorelease];
    if([_selectMatchArray count] > 0){
        for(NSDictionary *dic in _selectMatchArray) {
            if([rowDic isEqualToDictionary:[dic objectForKey:@"selectRowDic"]]) {
                [selectAry addObjectsFromArray:[dic objectForKey:@"selectArray"]];
            }
        }
    }
    /********************** adjustment 控件调整 ***************************/
    CGFloat buttonImageViewWidth =  CGRectGetWidth(cell.buttonImageView.frame);
    CGFloat buttonImageViewHeight = CGRectGetHeight(cell.buttonImageView.frame);
    
    CGFloat oneRowBtnHeight = IS_PHONE ? 30.0f : 60.0f;
    CGFloat twoRowBtnHeight = IS_PHONE ? 25.0f : 40.0f;
    
    CGFloat twoButtonMinX = 20.0f;//胜负过关
    CGFloat twoButtonLandscapeInterval = 0.0f;
    CGFloat twoBtnWidth = (buttonImageViewWidth - 2 * twoButtonLandscapeInterval - twoButtonMinX * 2) / 2.0f;
    
    CGFloat threeButtonMinX = 20.0f;//让球胜平负，让球胜平负，比分
    CGFloat threeButtonLandscapeInterval = 0.0f;
    CGFloat threeBtnWidth = (buttonImageViewWidth - 2 * threeButtonLandscapeInterval - threeButtonMinX * 2) / 3.0f;
    
    CGFloat fourButtonMinX = 8.0f;//总进球
    CGFloat fourButtonLandscapeInterval = 2.0f;
    CGFloat fourButtonWidth = (buttonImageViewWidth - 2 * fourButtonLandscapeInterval - fourButtonMinX * 2) / 4.0f;
    
    CGFloat fourButtonVerticalIntetval = 1.0f;
    CGFloat fourButtonMinY = (buttonImageViewHeight - fourButtonVerticalIntetval - twoRowBtnHeight * 2) / 2.0f;
    
    
    CGFloat fourButtonMinXSingle = 0.0f;
    CGFloat fourButtonWidthSingle = (buttonImageViewWidth - 2 * fourButtonLandscapeInterval ) / 4.0f;
    CGFloat fourButtonMinYSingle = (buttonImageViewHeight - fourButtonVerticalIntetval - twoRowBtnHeight * 2) / 2.0f;
    /********************** adjustment end ***************************/
    if(_SinglePlayType == SinglePlayType_upAndDownSingle) {    //上下单双
        cell.mainLoseBall = @"VS";
        
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:NO];
        
        for (NSInteger i = 0; i < 4; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(fourButtonMinXSingle + i * (fourButtonLandscapeInterval + fourButtonWidthSingle), fourButtonMinYSingle+9, fourButtonWidthSingle, oneRowBtnHeight)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"上单%@",[rowDic objectForKey:@"shangDanSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"1"]){
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"上双%@",[rowDic objectForKey:@"shangShuangSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"2"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"下单%@",[rowDic objectForKey:@"xiaDanSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"3"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 3) {
                [btn setTitle:[NSString stringWithFormat:@"下双%@",[rowDic objectForKey:@"xiaShuangSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"4"]) {
                        [btn setSelected:YES];
                    }
                }
            }

            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            
            if (i < 2) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.buttonImageView addSubview:lineView];
                [lineView release];
            }
        }
    } else if(_SinglePlayType == SinglePlayType_score) {       // 比分
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:NO];
        cell.mainLoseBall = @"VS";
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(threeButtonMinX, (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, buttonImageViewWidth - 2 * threeButtonMinX, oneRowBtnHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn setAdjustsImageWhenHighlighted:NO];
        [[btn titleLabel] setTextAlignment:NSTextAlignmentCenter];
        if (self.betViewController) {
            [btn setTitle:@"点击展开比分投注区" forState:UIControlStateNormal];
            for (NSInteger i = 0; i < [_selectMatchArray count]; i++) {
                NSDictionary *dic = [_selectMatchArray objectAtIndex:i];
                if([[dic objectForKey:@"selectRowDic"] isEqual:rowDic]) {
                    NSArray *array = [dic objectForKey:@"selectedTextArray"];
                    [btn setTitle:[self convertArrayToString:array] forState:UIControlStateNormal];
                }
            }
        } else {
            [btn setTitle:@"点击展开比分投注区" forState:UIControlStateNormal];
        }
        //记录选中的比分
        NSMutableString *string = [[NSMutableString alloc]initWithCapacity:0];
        if([_selectMatchArray count] > 0) {
            for(NSDictionary *dic in _selectMatchArray) {
                if([rowDic isEqual:[dic objectForKey:@"selectRowDic"]]) {
                    selectAry = [dic objectForKey:@"selectedTextArray"];
                    for(NSString *text in selectAry)
                    {
                        [string appendString:[NSString stringWithFormat:@" %@",text]];
                    }
                    [btn setTitle:string forState:UIControlStateNormal];
                }
            }
            
        }
        [string release];
        
        [btn addTarget:self action:@selector(unfoldBetViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonImageView addSubview:btn];
    } else if(_SinglePlayType == SinglePlayType_totalGoal) {   // 总进球
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:NO];
        cell.mainLoseBall = @"VS";
        NSInteger temp = 0;
        for (NSInteger i = 0; i < 8; i++) {
            
            NSInteger col = i / 4;
            if(i % 4 == 0 && i > 0) {
                temp = 0;
            }
            CGRect btnRect = CGRectMake(fourButtonMinX + temp * (fourButtonLandscapeInterval + fourButtonWidth), fourButtonMinY + col * (fourButtonVerticalIntetval + twoRowBtnHeight), fourButtonWidth, twoRowBtnHeight);
            CustomFootBallZJQButton *btn = [[CustomFootBallZJQButton alloc] initWithFrame:btnRect];
            if(i == 7) {
                [btn.scoreLabel setText:[NSString stringWithFormat:@"%ld+",(long)i]];
                [btn.oddsLabel setText:[rowDic objectForKey:[NSString stringWithFormat:@"zjq%ld",(long)i]]];
            } else {
                [btn.scoreLabel setText:[NSString stringWithFormat:@"%ld",(long)i]];
                [btn.oddsLabel setText:[rowDic objectForKey:[NSString stringWithFormat:@"zjq%ld",(long)i]]];
            }
            for(NSInteger j = 0;j<selectAry.count;j++){
                if([[selectAry objectAtIndex:j]intValue] == i+1){
                    [btn setSelected:YES];
                }
            }
            
            [btn setTag:i + 1];
            [btn setTitle:btn.titleLabel.text forState:UIControlStateNormal];
            btn.adjustsImageWhenHighlighted = NO;
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            
            temp ++;
        }
    } else if(_SinglePlayType == SinglePlayType_winlose) {   // 胜负过关
        cell.mainLoseBall = @"VS";
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:NO];
        
        for (NSInteger i = 0; i < 2; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(twoButtonMinX + i * (twoButtonLandscapeInterval + twoBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, twoBtnWidth, oneRowBtnHeight)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"胜%@",[rowDic objectForKey:@"sfs"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"1"]){
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"负%@",[rowDic objectForKey:@"sff"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"2"]) {
                        [btn setSelected:YES];
                    }
                }
            }
           
            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            
            if (i < 2) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.buttonImageView addSubview:lineView];
                [lineView release];
            }
        }
        
    } else if (_SinglePlayType == SinglePlayType_winDogfallLose) {      // 让球胜平负
        cell.mainLoseBall = [rowDic objectForKey:@"giveBall"];
        
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:NO];
        for (NSInteger i = 0; i < 3; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(threeButtonMinX + i * (threeButtonLandscapeInterval + threeBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, threeBtnWidth, oneRowBtnHeight)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"winSp"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"1"]){
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"平%@",[rowDic objectForKey:@"flatSp"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"2"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"loseSp"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"3"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            
            if (i < 2) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.buttonImageView addSubview:lineView];
                [lineView release];
            }
        }
    } else if (_SinglePlayType == SinglePlayType_half) { //半全场
        cell.mainLoseBall = @"VS";
        
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(threeButtonMinX, (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, buttonImageViewWidth - 2 * threeButtonMinX, oneRowBtnHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn setAdjustsImageWhenHighlighted:NO];
        [[btn titleLabel] setTextAlignment:NSTextAlignmentCenter];
        if (self.betViewController) {
            [btn setTitle:@"点击展开投注区" forState:UIControlStateNormal];
            for (NSInteger i = 0; i < [_selectMatchArray count]; i++) {
                NSDictionary *dic = [_selectMatchArray objectAtIndex:i];
                if([[dic objectForKey:@"selectRowDic"] isEqual:rowDic]) {
                    NSArray *array = [dic objectForKey:@"selectedTextArray"];
                    [btn setTitle:[self convertArrayToString:array] forState:UIControlStateNormal];
                }
            }
        } else {
            [btn setTitle:@"点击展开投注区" forState:UIControlStateNormal];
        }
        
        NSMutableString *string = [[NSMutableString alloc]initWithCapacity:0];
        if([_selectMatchArray count] > 0) {
            for(NSDictionary *dic in _selectMatchArray) {
                if([rowDic isEqual:[dic objectForKey:@"selectRowDic"]]) {
                    selectAry = [dic objectForKey:@"selectedTextArray"];
                    for(NSString *textString in selectAry)
                    {
                        [string appendString:[NSString stringWithFormat:@"%@ ",textString]];
                    }
                    [btn setTitle:string forState:UIControlStateNormal];
                }
            }
            
        }
        [string release];
        
        [btn addTarget:self action:@selector(unfoldHalfViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonImageView addSubview:btn];
        
        
    }
    return cell;
}

//tableView滚动时 重用cell会刷掉已选的
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_SinglePlayType == SinglePlayType_upAndDownSingle) {
        for (NSInteger i = 0; i < [_selectMatchArray count]; i++) {
            NSDictionary *dic = [_selectMatchArray objectAtIndex:i];
            if([[dic objectForKey:@"selectIndexPath"] isEqual:indexPath]) {
                NSArray *array = [dic objectForKey:@"selectArray"];
                for (NSInteger j = 0; j < array.count; j++) {
                    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:[[array objectAtIndex:j] intValue]];
                    [btn setSelected:YES];
                }
            }
        }
    }
}

#pragma mark -DialogFilterMatchViewDelegate
- (void)filterMatchesWithType:(NSInteger)type MatchDictionary:(NSDictionary *)matches {
    [_filterMatchDic removeAllObjects];
    [_filterMatchDic addEntriesFromDictionary:matches];
    
    /**************   这是筛选后删除已经未选中场次的功能，不需要可以把中间这部分代码删除了 **************/
    NSArray *gameSelectTextArray = [matches objectForKey:@"selectText"];
    for (NSInteger i = 0; i < [_selectMatchArray count]; i++) {
        NSDictionary *selectDict = [_selectMatchArray objectAtIndex:i];
        NSDictionary *selectRowDic = [selectDict objectForKey:@"selectRowDic"];
        NSString *game = [selectRowDic objectForKey:@"game"];
        
        if (![gameSelectTextArray containsObject:game]) {
            [_selectMatchArray removeObjectAtIndex:i];
            i--;
        }
    }
    [self updateBottomViewDisplay:[_selectMatchArray count]];
    /************************************************************************************/
    _selectLetBallType = type;
    
    
    [_matchDict removeAllObjects];
    
    [self filterMatchesWithCompleteMatchDict:_completeMatchDict matchDict:_matchDict serverKey:nil];
    
    [_matchTableList reloadData];
}

#pragma mark -DropDownListViewDelegate
//选中投注方式下拉选项的委托方法
- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {
    _SinglePlayType = [self getSingleBetSelectTypeWithIndex:index];
    [self filterMatchesWithServerKey:nil];
    
    UIView *midView = self.navigationItem.titleView;
    UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
    [midBtn setTitle:(NSString *)obj forState:UIControlStateNormal];
    [midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    if (index>0) {
        NSString *str = [NSString stringWithFormat:@"%@",[_betTypeArray objectAtIndex:index]];
        [midButton setTitle:str forState:UIControlStateNormal];
    }
    else
        [midButton setTitle:[_betTypeArray objectAtIndex:index] forState:UIControlStateNormal];
        
    //切换时 清空选择项
    [_selectMatchArray removeAllObjects];
    [_singleSelectMatchArray removeAllObjects];
    [_selectScoreDic removeAllObjects];
    [_singleSelectScoreDic removeAllObjects];
    
    //先删除上一页的buttons  否则会造成重叠
    for (NSInteger i = 0; i < [_matchDict count]; i++) {
        NSArray *array = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)i + 1]];
        for (NSInteger j = 0; j < array.count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            UITableViewCell *cell = [_matchTableList cellForRowAtIndexPath:indexPath];
            
            for (UIView *view in cell.contentView.subviews) {
                if([view isKindOfClass:[UIButton class]]) {
                    [view removeFromSuperview];
                }
            }
        }
    }
    
    [_SingleScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self updateBottomViewDisplay:0];
    [_matchTableList reloadData];
}

- (void)tapBackView {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
}

#pragma mark -DialogSelectButtonViewDetegate
- (void)dialogSelectMatch:(NSMutableArray *)selectMatchArray selectMatchText:(NSMutableArray *)selectMatchText dialogType:(DialogType)dialogType indexPath:(NSIndexPath *)indexPath {//目前用于
    NSArray *sectionArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_SinglePlayType == SinglePlayType_half || _SinglePlayType == SinglePlayType_score || _SinglePlayType == SinglePlayType_winlose) {
        
        [dic setObject:rowDic forKey:@"selectRowDic"];
        [dic setObject:selectMatchArray forKey:kSelectedChangInfo];
        [dic setObject:indexPath forKey:@"selectIndexPath"];
        [dic setObject:selectMatchText forKey:@"selectedTextArray"];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)_SinglePlayType] forKey:@"selectType"];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
    }
    
    if([self isArrayContainsDictionary:rowDic]) {//如果比赛已被选中  则替换selectMatchArray中的字典
        //否则添加比赛信息
        NSInteger index = [self indexOfDictionary:rowDic];
        
        if ([selectMatchArray count] == 0) {
            // 如果反选时没有选择半全场，则删除该场次
            [_selectMatchArray removeObjectAtIndex:index];
        } else {
            [_selectMatchArray replaceObjectAtIndex:index withObject:dic];
        }
        
    } else {
        [_selectMatchArray addObject:dic];
    }
    
    NSSortDescriptor *priceSort = [NSSortDescriptor sortDescriptorWithKey:@"indexs" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        float value1 = [obj1 floatValue];
        float value2 = [obj2 floatValue];
        if (value1 == value2) {
            return NSOrderedSame;
        } else if (value1 > value2) { //value1比value2大则
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    NSArray *arr = [NSArray arrayWithObject:priceSort];
    [_selectMatchArray sortUsingDescriptors:arr];
    
    [self updateBottomViewDisplay:[_selectMatchArray count]];
    [_matchTableList reloadData];
}

#pragma mark -
#pragma mark -Customized(Action)
//点击玩法介绍
- (void)palyIntroduceTouchUpInside:(UIButton *)btn {
    HelpViewController *helpViewController = [[HelpViewController alloc]initWithLotteryId:_lotteryID];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:helpViewController];
    [self presentViewController:nav animated:YES completion:nil];
    [nav release];
    [helpViewController release];
}

//点击取消按钮
- (void)dismissViewControllerTouchUpInside:(id)sender {
    self.betViewController ? [self dismissViewControllerAnimated:YES completion:nil] : [self.navigationController popViewControllerAnimated:YES];
}

//点击筛选按钮  弹出过滤视图
- (void)filterMatchesTouchUpInside:(id)sender {
    CGRect filterMatchViewRect = IS_PHONE ? CGRectMake(0, kWinSize.height - 296.0f + 20.0f, kWinSize.width, 296.0f) : CGRectMake(0, 0, 500, 430);
    DialogFilterMatchView *filterMatchView = [[DialogFilterMatchView alloc]initWithFrame:filterMatchViewRect MatchItems:_completeFilterMainMatchArray];
    if(_filterMatchDic && _selectLetBallType == 0 && _SinglePassBarrierType == SinglePassBarrierType_moreMatch) {
        filterMatchView.filterMatchDic = _filterMatchDic;
        filterMatchView.selectLetBallType = _selectLetBallType;
    }
    
    filterMatchView.delegate = self;
    [filterMatchView show];
    [filterMatchView release];
}

//清空
- (void)clearAllTouchUpInside:(id)sender {
    [_selectMatchArray removeAllObjects];
    [_matchTableList reloadData];
    
    [_selectScoreDic removeAllObjects];
    [self updateBottomViewDisplay:0];
}

//确认 跳转到投注页面
- (void)okClickTouchUpInside:(id)sender {
    if([_selectMatchArray count] < 1) {
        [Globals alertWithMessage:@"请至少选择1场比赛"];
        return;
    }
    
    if (self.betViewController) {
        [self.betViewController updateSelectMatchArray:_selectMatchArray andScoreDic:_selectScoreDic];
        self.betViewController.SinglePlayType = _SinglePlayType;
        self.betViewController.SinglePassBarrierType = _SinglePassBarrierType;
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    SingleBetViewController *betViewControllers = [[SingleBetViewController alloc]initWithMatchArray:_selectMatchArray andScoreDic:_selectScoreDic];
    betViewControllers.matchDic = _matchDict;
    
    betViewControllers.SinglePlayType = _SinglePlayType;
    betViewControllers.selectedScoreDic = _selectScoreDic;
    betViewControllers.selectHalfDict = _selectHalfDict;
    betViewControllers.SinglePassBarrierType = _SinglePassBarrierType;
    [_midBtn setEnabled:YES];
    [self.navigationController pushViewController:betViewControllers animated:YES];
    [betViewControllers release];
}

//让球胜平负 和 总进球
- (void)buttonSelectedTouchUpInside:(id)sender {
    CustomFootBallZJQButton *btn = sender;
    // iOS 7.0+ : UITableViewCell->UITableViewCellScrollView->UITableViewCellContentView->Your custom view
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    
    NSIndexPath *indexPath = [_matchTableList indexPathForCell:cell];
    NSArray *sectionArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    
    if([sectionArray count] < indexPath.row) {
        return;
    }
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];//btn所在行的比赛信息
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];//包括比赛行的信息、选中按钮数组信息
    NSMutableArray *selectArray = [NSMutableArray array]; //选中按钮的数组
    
    if(btn.isSelected) {
        NSInteger index = [self indexOfDictionary:rowDic];
        
        NSArray *array = [[_selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
        selectArray = [NSMutableArray arrayWithArray:array];
        [selectArray removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        if(selectArray.count == 0) {
            [_selectMatchArray removeObjectAtIndex:index];
        } else {
            [[_selectMatchArray objectAtIndex:index] setObject:selectArray forKey:kSelectedChangInfo];
        }
        [btn setSelected:NO];
    } else if (rowDic) {
        if([self isArrayContainsDictionary:rowDic]) {
            NSInteger index = [self indexOfDictionary:rowDic];
            
            NSArray *array = [[_selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
            selectArray = [NSMutableArray arrayWithArray:array];
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_SinglePlayType] forKey:@"selectType"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
            [_selectMatchArray replaceObjectAtIndex:index withObject:dic];
        } else {
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_SinglePlayType] forKey:@"selectType"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
            [_selectMatchArray addObject:dic];
        }
        [btn setSelected:YES];
    }
    
    //将选择的场次进行排序
    NSSortDescriptor *priceSort = [NSSortDescriptor sortDescriptorWithKey:@"indexs" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        float value1 = [obj1 floatValue];
        float value2 = [obj2 floatValue];
        if (value1 == value2) {
            return NSOrderedSame;
        } else if (value1 > value2) { //value1比value2大则
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    NSArray *arr = [NSArray arrayWithObject:priceSort];
    [_selectMatchArray sortUsingDescriptors:arr];
    
    [self updateBottomViewDisplay:[_selectMatchArray count]];
    
}

/** 用来改进的方法 */
- (void)btnSelectedTouchUpInside:(id)sender {// 目前只有混合
    CustomFootBallZJQButton *btn = sender;
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    
    
    NSIndexPath *indexPath = [_matchTableList indexPathForCell:cell];
    NSArray *sectionArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableArray *selectMatchArray = _selectMatchArray;
    
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];//btn所在行的比赛信息
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];//包括比赛行的信息、选中按钮数组信息
    NSMutableArray *selectArray = [NSMutableArray array]; //选中按钮的数组
    NSMutableArray *textArray = [NSMutableArray array];
    
    
    if(btn.isSelected) {
        
        NSInteger index = [self indexOfDictionary:rowDic];
        NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
        textArray = [NSMutableArray arrayWithArray:[[selectMatchArray objectAtIndex:index] objectForKey:@"selectedTextArray"]];
        
        selectArray = [NSMutableArray arrayWithArray:array];
        [selectArray removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        if(selectArray.count == 0) {
            [selectMatchArray removeObjectAtIndex:index];
        } else {
            [[selectMatchArray objectAtIndex:index] setObject:selectArray forKey:kSelectedChangInfo];
            [self updateTextArray:textArray rowDict:rowDic selectNumberArray:selectArray];
            if ([selectMatchArray count] > index && [selectMatchArray objectAtIndex:index]) {
                [[selectMatchArray objectAtIndex:index] setObject:textArray forKey:@"selectedTextArray"];
            }
        }
        
        [btn setSelected:NO];
    } else if (rowDic) {
        if([self isArrayContainsDictionary:rowDic]) {
            NSInteger index = [self indexOfDictionary:rowDic];
            
            NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
            
            selectArray = [NSMutableArray arrayWithArray:array];
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            
            [self updateTextArray:textArray rowDict:rowDic selectNumberArray:selectArray];
            
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:textArray forKey:@"selectedTextArray"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_SinglePlayType] forKey:@"selectType"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
            [selectMatchArray replaceObjectAtIndex:index withObject:dic];
        } else {
            
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            
            [self updateTextArray:textArray rowDict:rowDic selectNumberArray:selectArray];
            
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:textArray forKey:@"selectedTextArray"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_SinglePlayType] forKey:@"selectType"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
            [selectMatchArray addObject:dic];
        }
        [btn setSelected:YES];
    }
    
    //将选择的场次进行排序
    NSSortDescriptor *priceSort = [NSSortDescriptor sortDescriptorWithKey:@"indexs" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        float value1 = [obj1 floatValue];
        float value2 = [obj2 floatValue];
        if (value1 == value2) {
            return NSOrderedSame;
        } else if (value1 > value2) { //value1比value2大则
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    NSArray *arr = [NSArray arrayWithObject:priceSort];
    [selectMatchArray sortUsingDescriptors:arr];
    
    [_matchTableList reloadData];
    [self updateBottomViewDisplay:[_selectMatchArray count]];
}

- (void)mixAllTouchUpInside:(id)sender {
    CGRect dialogSelectButtonViewRect = IS_PHONE ? CGRectMake(0, 0, 300, kWinSize.height - 70.0f) : CGRectMake(0, 0, 700, kWinSize.height - 200.0f);
    [self showDialogSelectViewWithFrame:dialogSelectButtonViewRect touchBtn:sender dialogType:DialogFootBallMix];
    
}

//猜比分
- (void)unfoldBetViewTouchUpInside:(id)sender {
    CGRect dialogSelectButtonViewRect = IS_PHONE ? CGRectMake(0, 0, 300, 350) : CGRectMake(0, 0, 700, kWinSize.height - 200.0f);
    [self showDialogSelectViewWithFrame:dialogSelectButtonViewRect touchBtn:sender dialogType:DialogFootBallScore];
    
}

- (void)unfoldHalfViewTouchUpInside:(id)sender {
    CGRect selectHalfViewRect = IS_PHONE ? CGRectMake(0, 0, 300, 250) : CGRectMake(0, 0, 600, 500);
    [self showDialogSelectViewWithFrame:selectHalfViewRect touchBtn:sender dialogType:DialogFootBallHalf];
    
}

- (void)showDialogSelectViewWithFrame:(CGRect)dialogSelectFrame touchBtn:(id)touchBtn dialogType:(DialogType)dialogType {
    NSIndexPath *indexPath = [self findButtonIndexPathWithTheButton:touchBtn];
    NSDictionary *rowDic = [self findRowDictWithIndexPath:indexPath];
    
    NSInteger index = [self indexOfDictionary:rowDic];
    
    NSDictionary *dict;
    if(index >= 0) {
        dict = [_selectMatchArray objectAtIndex:index];
    } else {
        dict = nil;
    }
    
    DialogSelectButtonView *dialogSelectButtonView = [[DialogSelectButtonView alloc] initWithFrame:dialogSelectFrame matchDict:rowDic playID:45];
    [dialogSelectButtonView setDialogType:dialogType];
    [dialogSelectButtonView setDelegate:self];
    [dialogSelectButtonView setSelectMatchNumberArray:[dict objectForKey:kSelectedChangInfo]];
    [dialogSelectButtonView setSelectMatchIndexPath:indexPath];
    [dialogSelectButtonView show];
    [dialogSelectButtonView release];
}

//弹出下拉列表  切换背景图片
- (void)navMiddleBtnSelectTouchUpInside:(id)sender {
    UIButton *betTypeBtn = sender;
    if(_playMethodView.isHidden) {
        [betTypeBtn setBackgroundImage:[[UIImage imageNamed:@"bet_type_select.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_playMethodView setHidden:NO];
    } else {
        [betTypeBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_playMethodView setHidden:YES];
    }

}

//中部tableview中的 下拉按钮点击事件
- (void)dropDownListTouchUpInside:(id)sender {
    UIButton *btn = sender;
    
    //获取选中section的 下拉状态字典
    NSMutableDictionary *dict = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    //下拉框状态每次点击后都是原来的反状态
    [dict setObject:[NSNumber numberWithBool:!btn.isSelected] forKey:@"isDropDown"];
    [dict setObject:[NSNumber numberWithInteger:btn.tag] forKey:@"dropSection"];
    [_dropDic setObject:dict forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    [_matchTableList reloadData];
}

#pragma mark -Customized: Private (General)
- (void)updateBottomViewDisplay:(NSInteger)count {
    if (count > 0) {
        [_bottomView setTextWithMatchCount:count hasMatch:YES];
    } else {
        if (_SinglePlayType == SinglePlayType_single || _SinglePassBarrierType == SinglePassBarrierType_singleMacth) {
            [_bottomView setTextWithMatchCount:1 hasMatch:NO];
        } else {
            [_bottomView setTextWithMatchCount:1 hasMatch:NO];
        }
    }
}

- (void)refreshMatchArrayWithSinglePassBarrierType:(SinglePassBarrierType)SinglePassBarrierType {
    NSInteger count = [_selectMatchArray count];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    //如果投注页面返回该选择比赛页面有比赛取消，将已经取消的数组下标字典删除，有选择的继续保留
    for (NSInteger i = 0; i < count;i++) {
        NSArray *array = [[_selectMatchArray objectAtIndex:i] objectForKey:@"selectArray"];
        if(array.count == 0) {
            [tempArray addObject:[_selectMatchArray objectAtIndex:i]];
        }
    }
    
    [_selectMatchArray removeObjectsInArray:tempArray];
    [tempArray release];
}

- (void)replaceButtonTextWithArray:(NSArray *)array AtIndex:(NSIndexPath *)indexPath {
    CustomFootBallMainCell *cell = (CustomFootBallMainCell *)[_matchTableList cellForRowAtIndexPath:indexPath];
    
    for (UIView *view in cell.buttonImageView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:[self convertArrayToString:array] forState:UIControlStateNormal];
        }
    }
}

- (NSString *)convertArrayToString:(NSArray *)array {
    if (array.count == 0) {
        if (_SinglePlayType == SinglePlayType_score) {
            return @"点击展开比分投注区";
        } else if (_SinglePlayType == SinglePlayType_half) {
            return @"点击展开投注区";
        }
        return @"点击展开比分投注区";
    }
        
    
    NSString *result = [NSString string];
    if (_SinglePlayType == SinglePlayType_score) {
        for (NSString *text in array) {
            result = [result stringByAppendingFormat:@"%@,",text];
        }
    } else {
        for (NSString *textString in array) {
            result = [result stringByAppendingFormat:@"%@ ",textString];
        }
    }
    
    NSRange range = NSMakeRange(0, result.length - 1);
    result = [result substringWithRange:range];
    
    return result;
}

- (NSInteger)indexOfDictionary:(NSDictionary *)dic {
    for (NSDictionary *matchDic in _selectMatchArray) {
        if([[matchDic objectForKey:@"selectRowDic"] isEqualToDictionary:dic]) {
            return [_selectMatchArray indexOfObject:matchDic];
        }
    }
    
    return -1;
}

- (BOOL)isArrayContainsDictionary:(NSDictionary *)dic {
    for (NSDictionary *matchDic in _selectMatchArray) {
        if([[matchDic objectForKey:@"selectRowDic"] isEqualToDictionary:dic]) {
            return YES;
        }
    }
    return NO;
}

- (void)getPlayMethods {
    [GlobalsProject firstTypePlayIdWithTicketTypeName:self.title betTypeArray:_betTypeArray];
}

- (NSIndexPath *)findButtonIndexPathWithTheButton:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    NSIndexPath *indexPath = [_matchTableList indexPathForCell:cell];
    return indexPath;
}

- (NSMutableDictionary *)findRowDictWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [_matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
    return rowDic;
}

- (void)updateTextArray:(NSMutableArray *)textArray rowDict:(NSDictionary *)rowDict selectNumberArray:selectNumberArray {
    DialogSelectButtonView *dialogSelectButtonView = [[DialogSelectButtonView alloc] initWithMatchDict:rowDict selectNumberArray:selectNumberArray];
    [dialogSelectButtonView setDialogType:DialogFootBallMix];
    [dialogSelectButtonView setSelectMatchTextWithTextArray:textArray];
    [dialogSelectButtonView release];
}

- (BOOL)hasMatchWithMatchDict:(NSDictionary *)matchDict SinglePlayType:(SinglePlayType)SinglePlayType {
    return YES;
}

/** 根据服务器的玩法字段筛选比较，同时筛选过关单关
 @param serverKey 服务器玩法字段
 */
- (void)filterMatchesWithServerKey:(NSString *)serverKey {
    [_matchDict removeAllObjects];
    [self filterMatchesWithCompleteMatchDict:_completeMatchDict matchDict:_matchDict serverKey:serverKey];
}

/** 根据服务器的玩法字段，将该玩法的比赛筛选出来
 @param completeMatchDict  完整的比赛
 @param matchDict 筛选存入比赛用的字典
 @param serverKey 服务器玩法字段
 */
- (void)filterMatchesWithCompleteMatchDict:(NSDictionary *)completeMatchDict matchDict:(NSMutableDictionary *)matchDict serverKey:(NSString *)serverKey {
    NSMutableDictionary *filterMatchDic = _filterMatchDic;  ////////
    
    NSArray *filterTextArray = [filterMatchDic objectForKey:@"selectText"];  //需要筛选的比赛类型
    
    NSInteger signIndex = 0;
    
    for (NSInteger tableIndex = 0; tableIndex < completeMatchDict.count; tableIndex++) {
        NSDictionary *tableDict = [completeMatchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)(tableIndex + 1)]];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *matchMessageDict in tableDict) {
            
            if ([filterTextArray containsObject:[matchMessageDict objectForKey:@"game"]] || [filterTextArray count] == 0) {
                [tempArray addObject:matchMessageDict];
            }
        }
        
        [matchDict setObject:tempArray forKey:[NSString stringWithFormat:@"table%ld",(long)(signIndex + 1)]];
        if ([tempArray count] > 0) {
            signIndex++;
        }
        [tempArray release];
    }
}

/** 获取比赛中的所有类型 */
- (void)filterCompleteArray {
    for (NSInteger i = 0; i < [_completeMatchDict count]; i++) {
        NSArray *array = [_completeMatchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)i + 1]];
        for (NSInteger j = 0; j < array.count; j++) {
            NSDictionary *dic = [array objectAtIndex:j];
            
            if(![_completeFilterMainMatchArray containsObject:[dic objectForKey:@"game"]]) {
                [_completeFilterMainMatchArray addObject:[dic objectForKey:@"game"]];
            }
        }
    }
}

//跟getArrayIndexWithSingleBetSelectType:对应
- (SinglePlayType)getSingleBetSelectTypeWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return SinglePlayType_upAndDownSingle;
            break;
        case 1:
            return SinglePlayType_winDogfallLose;
            break;
        case 2:
            return SinglePlayType_score;
            break;
        case 3:
            return SinglePlayType_totalGoal;
            break;
        case 4:
            return SinglePlayType_half;
            break;
        case 5:
            return SinglePlayType_winlose;
            break;
            
        default:
            break;
    }
    
    return SinglePlayType_no;
}

//跟getSingleBetSelectTypeWithIndex:对应
- (NSInteger)getArrayIndexWithSingleBetSelectType:(SinglePlayType)SinglePlayType {
    switch (SinglePlayType) {
        case SinglePlayType_upAndDownSingle:
            return 0;
            break;
        case SinglePlayType_winDogfallLose:
            return 1;
            break;
        case SinglePlayType_score:
            return 2;
            break;
        case SinglePlayType_totalGoal:
            return 3;
            break;
        case SinglePlayType_half:
            return 4;
            break;
        case SinglePlayType_winlose:
            return 5;
            break;
            
        default:
            break;
    }
    
    return 101;
}

@end
