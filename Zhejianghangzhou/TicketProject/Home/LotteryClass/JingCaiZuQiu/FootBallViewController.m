    //
//  FootBallViewController.m   购彩大厅－竞彩足球选号
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140707 08:23（洪晓彬）：修改代码规范，改进生命周期
//20140923 10:30（洪晓彬）：进行ipad适配
//20150908 17:18（刘科）：新增主客标识

#import "BaseSelectViewController.h"
#import "CustomBottomView.h"
#import "CustomSegmentedControl.h"
#import "CustomFootBallMainCell.h"
#import "CustomFootBallZJQButton.h"
#import "DialogFilterMatchView.h"
#import "DialogSelectButtonView.h"
#import "FootBallBetViewController.h"
#import "FootBallViewController.h"
#import "HelpViewController.h"
#import "SSQPlayMethodView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "GlobalsProject.h"

#define FootBallViewControllerTabelCellHeight (IS_PHONE ? 64.5f : 100.0f)
#define FootBallViewControllerTabelCellZJQHeight (IS_PHONE ? 80.0f : 130.0f)
#define FootBallViewControllerTabelHeadViewHeight (IS_PHONE ? 27.5 : 55.0f)
#define FootBallViewMatchTypeCustomSegmentedControl (IS_PHONE ? 30.0f : 60.0f)

@interface FootBallViewController ()
/** 更新底部显示文字
    @param  count  选择的比赛场数 */
- (void)updateBottomViewDisplay:(NSInteger)count;
/** 刷新比赛数组 */
- (void)refreshMatchArrayWithFootBallPassBarrierType:(FootBallPassBarrierType)footBallPassBarrierType;
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
#pragma mark @implementation FootBallViewController
@implementation FootBallViewController
@synthesize betViewController = _betViewController;
#pragma mark Lifecircle

- (id)initWithMatchData:(NSObject *)matchData footBallPassBarrierType:(FootBallPassBarrierType)footBallPassBarrierType {
    self = [super init];
    if(self) {
        _completeMatchDict = [[(NSDictionary *)matchData objectForKey:@"dtMatch"] retain]; //完整比赛信息
        _completeSingleMatchDict = [[(NSDictionary *)matchData objectForKey:@"singleMatch"] retain];
        NSLog(@"_completeMatchDict == %ld",(long)_completeMatchDict.count);
        _matchDict = [[NSMutableDictionary alloc] init];
        _singleMatchDict = [[NSMutableDictionary alloc] init];
        
        _footBallPlayType = FootBallPlayType_mix;
        [self filterMatchesWithServerKey:[self serverKeyStringWithType:_footBallPlayType]];
        _lotteryID = 72;
        self.title = @"竞彩足球";
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
    CGFloat filterBtnWidth = IS_PHONE ? 22.0f : 35.0f;
    CGFloat filterBtnHeight = IS_PHONE ? 22.0f : 35.0f;
    
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
        [_midBtn setTitle:@"混合过关" forState:UIControlStateNormal];
        [_midBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_midBtn setTag:1000];
        [_midBtn setAdjustsImageWhenHighlighted:NO];
        [_midBtn setContentEdgeInsets:UIEdgeInsetsMake(0, -midBtnContentCutWidth, 0, 0)];
        [_midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_midBtn addTarget:self action:@selector(navMiddleBtnSelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_midBtn];
    }
    
    //matchTypeCustomSegmentedControl
    CGRect matchTypeCustomSegmentedControlRect = CGRectMake(0, 0, self.view.bounds.size.width, FootBallViewMatchTypeCustomSegmentedControl);
    _matchTypeCustomSegmentedControl = [[CustomSegmentedControl alloc]initWithFrame:matchTypeCustomSegmentedControlRect Items:[NSArray arrayWithObjects:@"过关(至少选两场)", @"单关(一场 奖金固定)", nil] normalImageName:@"singleMatchNormalBtn.png" selectImageName:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]];
    [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:0];
    [_matchTypeCustomSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_matchTypeCustomSegmentedControl addTarget:self action:@selector(matchTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_matchTypeCustomSegmentedControl];
    [_matchTypeCustomSegmentedControl release];
    
    //footBallScrollView
    CGRect footBallScrollViewRect = CGRectMake( 0, FootBallViewMatchTypeCustomSegmentedControl, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kNavigationBarHeight * 2 - FootBallViewMatchTypeCustomSegmentedControl);
    _footBallScrollView = [[UIScrollView alloc]initWithFrame:footBallScrollViewRect];
    [_footBallScrollView setClipsToBounds:YES];
    [_footBallScrollView setPagingEnabled:YES];
    [_footBallScrollView setDelegate:self];
    [_footBallScrollView setTag:1010];
    [_footBallScrollView setUserInteractionEnabled:YES];
    [_footBallScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 2, CGRectGetWidth(appRect))];
    [_footBallScrollView setContentOffset:CGPointMake(_footBallPassBarrierType == FootBallPassBarrierType_moreMatch ? 0 : CGRectGetWidth(appRect), 0)];
    [_footBallScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_footBallScrollView];
    [_footBallScrollView release];
    
    //matchTableList 中部－比赛选择的tableview
    CGRect matchTableListRect = CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetHeight(footBallScrollViewRect));
    _matchTableList = [[UITableView alloc]initWithFrame:matchTableListRect style:UITableViewStylePlain];
    [_matchTableList setBackgroundColor:kBackgroundColor];
    [_matchTableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_matchTableList setTag:FootBallPassBarrierType_moreMatch];
    [_matchTableList setDataSource:self];
    [_matchTableList setDelegate:self];
    [_footBallScrollView addSubview:_matchTableList];
    [_matchTableList release];
    
    //singleMatchTableList
    CGRect singleMatchTableListRect = CGRectMake(CGRectGetWidth(appRect), 0, self.view.bounds.size.width, CGRectGetHeight(footBallScrollViewRect));
    _singleMatchTableList = [[UITableView alloc]initWithFrame:singleMatchTableListRect style:UITableViewStylePlain];
    [_singleMatchTableList setBackgroundColor:kBackgroundColor];
    [_singleMatchTableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_singleMatchTableList setTag:FootBallPassBarrierType_singleMacth];
    [_singleMatchTableList setDataSource:self];
    [_singleMatchTableList setDelegate:self];
    [_footBallScrollView addSubview:_singleMatchTableList];
    [_singleMatchTableList release];
    
    //matchPromptLabel
    CGRect matchPromptLabelRect = CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetHeight(footBallScrollViewRect));
    _matchPromptLabel = [[UILabel alloc] initWithFrame:matchPromptLabelRect];
    [_matchPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_matchPromptLabel setText:@"当前暂无比赛"];
    [_matchPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize21]];
    [_matchPromptLabel setTextColor:[UIColor colorWithRed:192.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f]];
    [_matchPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_matchPromptLabel setHidden:[_matchDict count] > 0];
    [_footBallScrollView addSubview:_matchPromptLabel];
    [_matchPromptLabel release];
    
    //singleMatchPromptLabel
    CGRect singleMatchPromptLabelRect = CGRectMake(CGRectGetWidth(appRect), 0, self.view.bounds.size.width, CGRectGetHeight(footBallScrollViewRect));
    _singleMatchPromptLabel = [[UILabel alloc] initWithFrame:singleMatchPromptLabelRect];
    [_singleMatchPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_singleMatchPromptLabel setText:@"当前暂无比赛"];
    [_singleMatchPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize21]];
    [_singleMatchPromptLabel setTextColor:[UIColor colorWithRed:192.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f]];
    [_singleMatchPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_singleMatchPromptLabel setHidden:[_singleMatchDict count] > 0];
    [_footBallScrollView addSubview:_singleMatchPromptLabel];
    [_singleMatchPromptLabel release];
    
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
    
    [self selectSetFrameWithType:_footBallPlayType];
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
    
    NSLog(@"_dropDic == %ld %ld",(long)_dropDic.count,(long)_matchDict.count);
    
    for (NSInteger i = 0; i < [_singleMatchDict count]; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_singleDropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    
    NSInteger index = [self getArrayIndexWithFootBallBetSelectType:_footBallPlayType];
    
    // 进行添加比赛场次操作
    if (self.betViewController) {
        UIView *midView = self.navigationItem.titleView;
        UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
        midBtn.enabled = NO;
        NSString *strBetType = index < [_betTypeArray count] ? [_betTypeArray objectAtIndex:index] : @"";
        [midBtn setTitle:strBetType forState:UIControlStateNormal];
        [self updateBottomViewDisplay:[[self getSelectMatchArrayWithType:_footBallPassBarrierType] count]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    //刷新数组  在投注页面清空后
    [self refreshMatchArrayWithFootBallPassBarrierType:FootBallPassBarrierType_moreMatch];
    [self refreshMatchArrayWithFootBallPassBarrierType:FootBallPassBarrierType_singleMacth];
    
    if(_footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        [_matchTableList reloadData];
    } else {
        [_singleMatchTableList reloadData];
    }
    
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    [self updateBottomViewDisplay:[selectMatchArray count]];
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
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:page];
        _footBallPassBarrierType = page == 0 ? FootBallPassBarrierType_moreMatch : FootBallPassBarrierType_singleMacth;
        
        NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
        
        [self updateBottomViewDisplay:[selectMatchArray count]];
    }
    
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_footBallPlayType == FootBallPlayType_mix || _footBallPlayType == FootBallPlayType_totalGoal) {
        return FootBallViewControllerTabelCellZJQHeight;
    } else {
        return FootBallViewControllerTabelCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return FootBallViewControllerTabelHeadViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *matchDict;
    if (tableView.tag == 0) {
        matchDict = _matchDict;
    } else if (tableView.tag == 1) {
        matchDict = _singleMatchDict;
    } else {
        matchDict = nil;
    }
    
    NSArray *sectionArray = [matchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)section + 1]];
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
    
    CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width, FootBallViewControllerTabelHeadViewHeight);

    
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect]autorelease];
    
    UIButton *dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropBtn setFrame:CGRectMake(0, headViewDropBtnMinY, kWinSize.width, FootBallViewControllerTabelHeadViewHeight - headViewDropBtnMinY)];
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
    
    NSDictionary *matchDict = [self getMatchDictWithType:(int)tableView.tag];
    UILabel *promptLabel = [self getMatchPromptLabelWithType:(int)tableView.tag];
    
    
    if (_footBallPlayType != FootBallPlayType_no) {
        BOOL promptLabelHidden = [self hasMatchWithMatchDict:matchDict footBallPlayType:_footBallPlayType];
        [promptLabel setHidden:promptLabelHidden];
        if (!promptLabelHidden) {
            return 0;
        }
    }
    
    //table表示一天的比赛场次信息，一般服务器最多返回3天的比赛场次信息
//    if ([[matchDict objectForKey:@"table1"] count] > 0) {
//        count++;
//    }
//    if ([[matchDict objectForKey:@"table2"] count] > 0) {
//        count++;
//    }
//    if ([[matchDict objectForKey:@"table3"] count] > 0) {
//        count++;
//    }
    
    for (int i = 0; i < matchDict.count; i++) {
        if ([[matchDict objectForKey:[NSString stringWithFormat:@"table%d",i + 1]] count] > 0) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowsArray = [[self getMatchDictWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"table%ld",(long)section + 1]];;
    NSDictionary *dic = [[self getDropDicWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    
    BOOL isDropdown = [[dic objectForKey:@"isDropDown"] boolValue];
    NSInteger dropSection = [[dic objectForKey:@"dropSection"] intValue];
    //如果不是下拉状态 并且选中的section相等 则返回0  实现收缩的效果
    if(!isDropdown && dropSection == section) {
        return 0;
    }
    return rowsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FootBallMainCell";
    CustomFootBallMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CGFloat cellHeight;
    if (_footBallPlayType == FootBallPlayType_mix || _footBallPlayType == FootBallPlayType_totalGoal) {
        cellHeight = FootBallViewControllerTabelCellZJQHeight;
    } else {
        cellHeight = FootBallViewControllerTabelCellHeight;
    }
    if (cell == nil) {
        cell = [[[CustomFootBallMainCell alloc] initWithCellHight:cellHeight reuseIdentifier:cellIdentifier] autorelease];
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
    
    NSArray *sectionArray = [[self getMatchDictWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:(int)tableView.tag];
    
    
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
    cell.mainTeam = [NSString stringWithFormat:@"%@(主)", [rowDic objectForKey:@"mainTeam"]];
    cell.guestTeam = [NSString stringWithFormat:@"%@(客)", [rowDic objectForKey:@"guestTeam"]];
    
    NSMutableArray *selectAry = [[[NSMutableArray alloc]init] autorelease];
    if([selectMatchArray count] > 0){
        for(NSDictionary *dic in selectMatchArray) {
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
    
    CGFloat threeButtonMinX = 20.0f;//让球胜平负，胜平负，比分
    CGFloat threeButtonLandscapeInterval = 0.0f;
    CGFloat threeBtnWidth = (buttonImageViewWidth - 2 * threeButtonLandscapeInterval - threeButtonMinX * 2) / 3.0f;
    
    CGFloat threeButton2MinX = IS_PHONE ? 30.0f : 50.0f;//混合过关
    CGFloat threeButton2IntervalRight = 5.0f;
    CGFloat threeButton2LandscapeInterval = 0.0f;
    CGFloat threeButtonMixPromptButtonWidth = IS_PHONE ? 33.0f : 80.0f;
    CGFloat threeButton2Width = (buttonImageViewWidth - 2 * threeButton2LandscapeInterval - threeButton2MinX - threeButton2IntervalRight - threeButtonMixPromptButtonWidth) / 3.0f;
    CGFloat threeButtonVerticalIntetval = 0.0f;
    CGFloat threeButtonMinY = (buttonImageViewHeight - threeButtonVerticalIntetval - twoRowBtnHeight * 2) / 2.0f;
    
    CGFloat fourButtonLandscapeInterval = 2.0f;
    CGFloat fourButtonWidth = (buttonImageViewWidth - 2 * fourButtonLandscapeInterval) / 4.0f;
    CGFloat fourButtonVerticalIntetval = 1.0f;
    CGFloat fourButtonMinY = (buttonImageViewHeight - fourButtonVerticalIntetval - twoRowBtnHeight * 2) / 2.0f;
    /********************** adjustment end ***************************/
    if(_footBallPlayType == FootBallPlayType_letWinDogfallLose) {    //让球胜平负
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:YES];
        NSString *mainLoseBall = [NSString stringWithFormat:@"%@",[rowDic objectForKey:@"mainLoseBall"]];
        if ([mainLoseBall integerValue] > 0)
            mainLoseBall = [NSString stringWithFormat:@"+%@",mainLoseBall];
        //中间标签
        cell.mainLoseBall = mainLoseBall;
        for (NSInteger i = 0; i < 3; i ++) {

            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(threeButtonMinX + i * (threeButtonLandscapeInterval + threeBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, threeBtnWidth, oneRowBtnHeight)];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn.titleLabel setMinimumScaleFactor:0.75];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            btn.adjustsImageWhenHighlighted = NO;
            
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"win"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"1"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"平%@",[rowDic objectForKey:@"flat"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"2"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"lose"]] forState:UIControlStateNormal];
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
    } else if(_footBallPlayType == FootBallPlayType_score) {       // 比分
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
        [btn.titleLabel setMinimumScaleFactor:0.75];
        [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [btn setAdjustsImageWhenHighlighted:NO];
        [[btn titleLabel] setTextAlignment:NSTextAlignmentCenter];
        if (self.betViewController) {
            [btn setTitle:@"点击展开比分投注区" forState:UIControlStateNormal];
            for (NSInteger i = 0; i < [selectMatchArray count]; i++) {
                NSDictionary *dic = [selectMatchArray objectAtIndex:i];
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
        if([selectMatchArray count] > 0) {
            for(NSDictionary *dic in selectMatchArray) {
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
    } else if(_footBallPlayType == FootBallPlayType_totalGoal) {   // 总进球
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
            CGRect btnRect = CGRectMake(-20 + temp * (fourButtonLandscapeInterval + fourButtonWidth + 7), fourButtonMinY + col * (fourButtonVerticalIntetval + twoRowBtnHeight), fourButtonWidth + 7, twoRowBtnHeight);
            CustomFootBallZJQButton *btn = [[CustomFootBallZJQButton alloc] initWithFrame:btnRect];
            if(i == 7) {
                [btn.scoreLabel setText:[NSString stringWithFormat:@"%ld+",(long)i]];
                [btn.oddsLabel setText:[rowDic objectForKey:[NSString stringWithFormat:@"in%ld",(long)i]]];
                [btn.oddsLabel setTextAlignment:NSTextAlignmentCenter];
            } else {
                [btn.scoreLabel setText:[NSString stringWithFormat:@"%ld",(long)i]];
                [btn.oddsLabel setText:[rowDic objectForKey:[NSString stringWithFormat:@"in%ld",(long)i]]];
                [btn.oddsLabel setTextAlignment:NSTextAlignmentCenter];
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
            [btn release];
            
            temp ++;
        }
    } else if(_footBallPlayType == FootBallPlayType_mix) {   // 混合过关
        NSString *mainLoseBall = [NSString stringWithFormat:@"%@",[rowDic objectForKey:@"mainLoseBall"]];
        if ([mainLoseBall integerValue] > 0) {
            mainLoseBall = [NSString stringWithFormat:@"+%@",mainLoseBall];
        }
        /********************** adjustment 控件调整 ***************************/
        CGFloat labelWidth = 20.0f;
        /********************** adjustment end ***************************/
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        
        //btnOne
        CGRect btnOneRect = CGRectMake(threeButton2MinX - labelWidth, threeButtonMinY - AllLineWidthOrHeight, labelWidth, twoRowBtnHeight + AllLineWidthOrHeight);
        UIButton *btnOne = [[UIButton alloc] initWithFrame:btnOneRect];
        [btnOne.layer setBorderColor:kLightGrayColor.CGColor];
        [btnOne setBackgroundColor:bYellowColor];
        [btnOne setTitle:@"0" forState:UIControlStateNormal];
        [btnOne setTitleColor:tYellowColor forState:UIControlStateNormal];
        [[btnOne titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [[btnOne layer] setBorderWidth:AllLineWidthOrHeight];
        [btnOne setTag:120];
        [cell.buttonImageView addSubview:btnOne];
        [btnOne release];
        
        //btnTwo
        CGRect btnTwoRect = CGRectMake(threeButton2MinX - labelWidth, CGRectGetMaxY(btnOneRect) - AllLineWidthOrHeight, labelWidth, twoRowBtnHeight + AllLineWidthOrHeight);
        UIButton *btnTwo = [[UIButton alloc] initWithFrame:btnTwoRect];
        [btnTwo.layer setBorderColor:kLightGrayColor.CGColor];
        [btnTwo setBackgroundColor:[mainLoseBall integerValue] > 0 ? bRedColor : bGreenColor];
        [btnTwo setTitleColor:[mainLoseBall integerValue] > 0 ? tRedColor : tGreenColor forState:UIControlStateNormal];
        [btnTwo setTitle:mainLoseBall forState:UIControlStateNormal];
        [[btnTwo titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [[btnTwo layer] setBorderWidth:AllLineWidthOrHeight];
        [btnTwo setTag:121];
        [cell.buttonImageView addSubview:btnTwo];
        [btnTwo release];
        
        BOOL hasSPF = [[rowDic objectForKey:@"isNewSPF"] isEqualToString:@"True"];//5.2某个坑货规定的，new的就是胜平负，没有的就是让的
        BOOL hasLetSPF = [[rowDic objectForKey:@"isSPF"] isEqualToString:@"True"];
        cell.mainLoseBall = @"VS";
        NSInteger temp = 0;
        for (NSInteger i = 0; i < 6; i++) {
            CustomFootBallZJQButton *btn = [CustomFootBallZJQButton buttonWithType:UIButtonTypeCustom];
            [btn setLineHide:YES];
            [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn.titleLabel setMinimumScaleFactor:0.75];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

            NSInteger col = i / 3;
            if(i % 3 == 0 && i > 0) {
                temp = 0;
            }
            CGRect btnRect = CGRectMake(threeButton2MinX + temp * (threeButton2Width + threeButton2LandscapeInterval) - AllLineWidthOrHeight, threeButtonMinY + col * (threeButtonVerticalIntetval + twoRowBtnHeight) - AllLineWidthOrHeight, threeButton2Width + AllLineWidthOrHeight, twoRowBtnHeight + AllLineWidthOrHeight);
            [btn setFrame:btnRect];
            
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"spfwin"]] forState:UIControlStateNormal];
                [btn setTag:500];

            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"平%@",[rowDic objectForKey:@"spfflat"]] forState:UIControlStateNormal];
                [btn setTag:501];

            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"spflose"]] forState:UIControlStateNormal];
                [btn setTag:502];
   
            }
            if(i == 3) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"win"]] forState:UIControlStateNormal];
                [btn setTag:100];
                
            }
            if(i == 4) {
                [btn setTitle:[NSString stringWithFormat:@"平%@",[rowDic objectForKey:@"flat"]] forState:UIControlStateNormal];
                [btn setTag:101];

            }
            if(i == 5) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"lose"]] forState:UIControlStateNormal];
                [btn setTag:102];

            }
            
            if ((i/3 == 0 && hasSPF) || (i/3 == 1 && hasLetSPF)) {
                [cell.buttonImageView addSubview:btn];
                
                
            } else if (i%3 == 0){
                CGRect promptLabelRect = CGRectMake(threeButton2MinX -AllLineWidthOrHeight, threeButtonMinY + col * (threeButtonVerticalIntetval + twoRowBtnHeight) - AllLineWidthOrHeight, (threeButton2Width + threeButton2LandscapeInterval) * 3 + AllLineWidthOrHeight, twoRowBtnHeight + AllLineWidthOrHeight);
                UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
                [promptLabel setTextColor:kDarkGrayColor];
                [promptLabel setTextAlignment:NSTextAlignmentCenter];
                [promptLabel setText:@"暂未开售"];
                [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [[promptLabel layer] setBorderWidth:AllLineWidthOrHeight];
                [[promptLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
                [cell.buttonImageView addSubview:promptLabel];
                [promptLabel release];
            }

            [btn addTarget:self action:@selector(btnSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
            for(NSString *str in selectAry) {
                if([str isEqualToString:[NSString stringWithFormat:@"%ld",(long)btn.tag]]){
                    [btn setSelected:YES];
                }
            }
        
            
            temp ++;
        }
        
        CGRect mixButtonRect = CGRectMake(threeButton2MinX + 3 * (threeButton2Width + threeButton2LandscapeInterval) - AllLineWidthOrHeight, threeButtonMinY - AllLineWidthOrHeight, threeButtonMixPromptButtonWidth, threeButtonVerticalIntetval + twoRowBtnHeight * 2 + AllLineWidthOrHeight);
        UIButton *mixButton = [[UIButton alloc] initWithFrame:mixButtonRect];
        [mixButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [mixButton.titleLabel setNumberOfLines:2];
        [[mixButton layer] setBorderWidth:AllLineWidthOrHeight];
        [[mixButton layer] setBorderColor:kLightGrayColor.CGColor];
        if([selectAry count] == 0) {
            [mixButton setTitle:@"展开\n全部" forState:UIControlStateNormal];
            [mixButton setSelected:NO];
        } else {
            [mixButton setTitle:[NSString stringWithFormat:@"已选%ld项",(long)[selectAry count]] forState:UIControlStateNormal];
            [mixButton setSelected:YES];
        }
        [mixButton setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [mixButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [mixButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [mixButton setBackgroundImage:[UIImage imageWithColor:kRedColor] forState:UIControlStateSelected];
        [mixButton addTarget:self action:@selector(mixAllTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonImageView addSubview:mixButton];
        [mixButton release];
        
    } else if (_footBallPlayType == FootBallPlayType_winDogfallLose) {      // 胜平负
        cell.mainLoseBall = @"VS";
        
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        [cell setBoldmainLoseBallLabel:NO];
        
        for (NSInteger i = 0; i < 3; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(threeButtonMinX + i * (threeButtonLandscapeInterval + threeBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, threeBtnWidth, oneRowBtnHeight)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn.titleLabel setMinimumScaleFactor:0.75];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"spfwin"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"1"]){
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"平%@",[rowDic objectForKey:@"spfflat"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
                for(NSString *str in selectAry) {
                    if([str isEqualToString:@"2"]) {
                        [btn setSelected:YES];
                    }
                }
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"spflose"]] forState:UIControlStateNormal];
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
    } else if (_footBallPlayType == FootBallPlayType_half) { //半全场
        cell.mainLoseBall = @"VS";
        
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(threeButtonMinX, (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, buttonImageViewWidth - 2 * threeButtonMinX, oneRowBtnHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn.titleLabel setMinimumScaleFactor:0.75];
        [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [btn setAdjustsImageWhenHighlighted:NO];
        [[btn titleLabel] setTextAlignment:NSTextAlignmentCenter];
        if (self.betViewController) {
            [btn setTitle:@"点击展开投注区" forState:UIControlStateNormal];
            for (NSInteger i = 0; i < [selectMatchArray count]; i++) {
                NSDictionary *dic = [selectMatchArray objectAtIndex:i];
                if([[dic objectForKey:@"selectRowDic"] isEqual:rowDic]) {
                    NSArray *array = [dic objectForKey:@"selectedTextArray"];
                    [btn setTitle:[self convertArrayToString:array] forState:UIControlStateNormal];
                }
            }
        } else {
            [btn setTitle:@"点击展开投注区" forState:UIControlStateNormal];
        }
        
        NSMutableString *string = [[NSMutableString alloc]initWithCapacity:0];
        if([selectMatchArray count] > 0) {
            for(NSDictionary *dic in selectMatchArray) {
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
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:(int)tableView.tag];
    
    if (_footBallPlayType == FootBallPlayType_letWinDogfallLose) {
        for (NSInteger i = 0; i < [selectMatchArray count]; i++) {
            NSDictionary *dic = [selectMatchArray objectAtIndex:i];
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
    
    if (_footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        [_filterMatchDic removeAllObjects];
        [_filterMatchDic addEntriesFromDictionary:matches];
        
    } else if (_footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        [_singleFilterMatchDic removeAllObjects];
        [_singleFilterMatchDic addEntriesFromDictionary:matches];

    }
    
    
    /**************   这是筛选后删除已经未选中场次的功能，不需要可以把中间这部分代码删除了 **************/
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    
    NSArray *gameSelectTextArray = [matches objectForKey:@"selectText"];
    for (NSInteger i = 0; i < [selectMatchArray count]; i++) {
        NSDictionary *selectDict = [selectMatchArray objectAtIndex:i];
        NSDictionary *selectRowDic = [selectDict objectForKey:@"selectRowDic"];
        NSString *game = [selectRowDic objectForKey:@"game"];
        
        if (![gameSelectTextArray containsObject:game]) {
            [selectMatchArray removeObjectAtIndex:i];
            i--;
        }
    }
    [self updateBottomViewDisplay:[selectMatchArray count]];
    /************************************************************************************/
    _selectLetBallType = type;
    
    
    NSMutableDictionary *matchDict = [self getMatchDictWithType:_footBallPassBarrierType];
    [matchDict removeAllObjects];
    
    [self filterMatchesWithCompleteMatchDict:[self getCompleteMatchDictWithType:_footBallPassBarrierType] matchDict:matchDict serverKey:[self serverKeyStringWithType:_footBallPlayType]];
    
    [[self getMatchTableListWithType:_footBallPassBarrierType] reloadData];
}

#pragma mark -DropDownListViewDelegate
//选中投注方式下拉选项的委托方法
- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {
    _footBallPlayType = [self getFootBallBetSelectTypeWithIndex:index];
    [self filterMatchesWithServerKey:[self serverKeyStringWithType:_footBallPlayType]];
    
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
    
    
    [self selectSetFrameWithType:_footBallPlayType];
    
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
    
    [_footBallScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self updateBottomViewDisplay:0];
    [_matchTableList reloadData];
    [_singleMatchTableList reloadData];
    
}

- (void)tapBackView {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
}

#pragma mark -DialogSelectButtonViewDetegate
- (void)dialogSelectMatch:(NSMutableArray *)selectMatchArray selectMatchText:(NSMutableArray *)selectMatchText dialogType:(DialogType)dialogType indexPath:(NSIndexPath *)indexPath {//目前用于
    NSArray *sectionArray = [[self getMatchDictWithType:_footBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_footBallPlayType == FootBallPlayType_half || _footBallPlayType == FootBallPlayType_score || _footBallPlayType == FootBallPlayType_mix) {
        
        [dic setObject:rowDic forKey:@"selectRowDic"];
        [dic setObject:selectMatchArray forKey:kSelectedChangInfo];
        [dic setObject:indexPath forKey:@"selectIndexPath"];
        [dic setObject:selectMatchText forKey:@"selectedTextArray"];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)_footBallPlayType] forKey:@"selectType"];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
    }
    
    NSMutableArray *selectMatchMessageArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    
    if([self isArrayContainsDictionary:rowDic]) {//如果比赛已被选中  则替换selectMatchArray中的字典
        //否则添加比赛信息
        NSInteger index = [self indexOfDictionary:rowDic];
        
        if ([selectMatchArray count] == 0) {
            // 如果反选时没有选择半全场，则删除该场次
            [selectMatchMessageArray removeObjectAtIndex:index];
        } else {
            [selectMatchMessageArray replaceObjectAtIndex:index withObject:dic];
        }
        
    } else {
        [selectMatchMessageArray addObject:dic];
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
    [selectMatchMessageArray sortUsingDescriptors:arr];
    
    [self updateBottomViewDisplay:[selectMatchMessageArray count]];
    [[self getMatchTableListWithType:_footBallPassBarrierType] reloadData];
}

#pragma mark -
#pragma mark -Customized(Action)
//点击玩法介绍
- (void)palyIntroduceTouchUpInside:(UIButton *)btn {
    HelpViewController *helpViewController = [[HelpViewController alloc]initWithLotteryId:_lotteryID];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:helpViewController];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [nav release];
    [helpViewController release];
}

//点击取消按钮
- (void)dismissViewControllerTouchUpInside:(id)sender {
    self.betViewController ? [self dismissViewControllerAnimated:YES completion:nil] : [self.navigationController popViewControllerAnimated:YES];
}

//点击筛选按钮  弹出过滤视图
- (void)filterMatchesTouchUpInside:(id)sender {
    /********************** adjustment 控件调整 ***************************/
    CGFloat filterMatchViewHeight = IS_PHONE ? 296.0f : 430.0f;
    /********************** adjustment end ***************************/
    CGRect filterMatchViewRect = CGRectMake(0, kWinSize.height - filterMatchViewHeight + 20.0f, kWinSize.width, filterMatchViewHeight);
    DialogFilterMatchView *filterMatchView = [[DialogFilterMatchView alloc]initWithFrame:filterMatchViewRect MatchItems:_completeFilterMainMatchArray];
    if(_filterMatchDic && _selectLetBallType == 0 && _footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        filterMatchView.filterMatchDic = _filterMatchDic;
        filterMatchView.selectLetBallType = _selectLetBallType;
    } else if (_singleFilterMatchDic && _selectLetBallType == 0 && _footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        filterMatchView.filterMatchDic = _singleFilterMatchDic;
        filterMatchView.selectLetBallType = _selectLetBallType;
    }
    
    filterMatchView.delegate = self;
    [filterMatchView show];
    [filterMatchView release];
}

//清空
- (void)clearAllTouchUpInside:(id)sender {
    [_selectMatchArray removeAllObjects];
    [_singleSelectMatchArray removeAllObjects];
    
    [_matchTableList reloadData];
    [_singleMatchTableList reloadData];
    
    [_selectScoreDic removeAllObjects];
    [_singleSelectScoreDic removeAllObjects];
    [self updateBottomViewDisplay:0];
}

//确认 跳转到投注页面
- (void)okClickTouchUpInside:(id)sender {
    if(([_singleSelectMatchArray count] < 1 && _footBallPassBarrierType == FootBallPassBarrierType_singleMacth)) {
        [Globals alertWithMessage:@"请至少选择1场比赛"];
        return;
    }
    
    if(([_selectMatchArray count] < 2 && _footBallPlayType != FootBallPlayType_mix && _footBallPassBarrierType == FootBallPassBarrierType_moreMatch) || ([_selectMatchArray count] < 2 && _footBallPlayType == FootBallPlayType_mix)) {
        [Globals alertWithMessage:@"请至少选择2场比赛"];
        return;
    }
    
    NSMutableDictionary *selectScoreDic = [self getSelectScoreDicWithType:_footBallPassBarrierType];
    NSMutableDictionary *selectHalfDict = [self getSelectHalfDictWithType:_footBallPassBarrierType];
    
    if (self.betViewController) {
        [self.betViewController updateSelectMatchArray:_footBallPassBarrierType == FootBallPassBarrierType_moreMatch ? _selectMatchArray : _singleSelectMatchArray andScoreDic:selectScoreDic];
        self.betViewController.footBallPlayType = _footBallPlayType;
        self.betViewController.footBallPassBarrierType = _footBallPassBarrierType;
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    FootBallBetViewController *betViewControllers = [[FootBallBetViewController alloc]initWithMatchArray:_footBallPassBarrierType == FootBallPassBarrierType_moreMatch ? _selectMatchArray : _singleSelectMatchArray andScoreDic:selectScoreDic];
    betViewControllers.matchDic = [self getMatchDictWithType:_footBallPassBarrierType];
    
    betViewControllers.footBallPlayType = _footBallPlayType;
    betViewControllers.selectedScoreDic = selectScoreDic;
    betViewControllers.selectHalfDict = selectHalfDict;
    betViewControllers.footBallPassBarrierType = _footBallPassBarrierType;
    [_midBtn setEnabled:NO];
    [self.navigationController pushViewController:betViewControllers animated:YES];
    [betViewControllers release];
}

//胜平负 和 总进球
- (void)buttonSelectedTouchUpInside:(id)sender {
    CustomFootBallZJQButton *btn = sender;
    // iOS 7.0+ : UITableViewCell->UITableViewCellScrollView->UITableViewCellContentView->Your custom view
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    
    NSIndexPath *indexPath = [[self getMatchTableListWithType:_footBallPassBarrierType] indexPathForCell:cell];
    NSArray *sectionArray = [[self getMatchDictWithType:_footBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    
    if([sectionArray count] < indexPath.row) {
        return;
    }
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];//btn所在行的比赛信息
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];//包括比赛行的信息、选中按钮数组信息
    NSMutableArray *selectArray = [NSMutableArray array]; //选中按钮的数组
    
    if(btn.isSelected) {
        NSInteger index = [self indexOfDictionary:rowDic];
        
        NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
        selectArray = [NSMutableArray arrayWithArray:array];
        [selectArray removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        if(selectArray.count == 0) {
            [selectMatchArray removeObjectAtIndex:index];
        } else {
            [[selectMatchArray objectAtIndex:index] setObject:selectArray forKey:kSelectedChangInfo];
        }
        [btn setSelected:NO];
    } else if (rowDic) {
        if([self isArrayContainsDictionary:rowDic]) {
            NSInteger index = [self indexOfDictionary:rowDic];
            
            NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
            selectArray = [NSMutableArray arrayWithArray:array];
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_footBallPlayType] forKey:@"selectType"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
            [selectMatchArray replaceObjectAtIndex:index withObject:dic];
        } else {
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_footBallPlayType] forKey:@"selectType"];
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
    
    [self updateBottomViewDisplay:[[self getSelectMatchArrayWithType:_footBallPassBarrierType] count]];
    
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
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_footBallPlayType] forKey:@"selectType"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)[sectionArray indexOfObject:rowDic]] forKey:@"indexs"];
            [selectMatchArray replaceObjectAtIndex:index withObject:dic];
        } else {
            
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            
            [self updateTextArray:textArray rowDict:rowDic selectNumberArray:selectArray];
            
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:textArray forKey:@"selectedTextArray"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_footBallPlayType] forKey:@"selectType"];
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
    [self updateBottomViewDisplay:[[self getSelectMatchArrayWithType:_footBallPassBarrierType] count]];
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
        dict = [[self getSelectMatchArrayWithType:_footBallPassBarrierType] objectAtIndex:index];
    } else {
        dict = nil;
    }
    
    DialogSelectButtonView *dialogSelectButtonView = [[DialogSelectButtonView alloc] initWithFrame:dialogSelectFrame matchDict:rowDic];
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
    
    NSMutableDictionary *dropDict = [self getDropDicWithType:_footBallPassBarrierType];
    //获取选中section的 下拉状态字典
    NSMutableDictionary *dict = [dropDict objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    //下拉框状态每次点击后都是原来的反状态
    [dict setObject:[NSNumber numberWithBool:!btn.isSelected] forKey:@"isDropDown"];
    [dict setObject:[NSNumber numberWithInteger:btn.tag] forKey:@"dropSection"];
    [dropDict setObject:dict forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    [[self getMatchTableListWithType:_footBallPassBarrierType] reloadData];
}

- (void)matchTypeChanged:(id)sender {
    CustomSegmentedControl *customSegmentedControl = sender;
    
    switch (customSegmentedControl.selectedSegmentIndex) {
        case 0:
            _footBallPassBarrierType = FootBallPassBarrierType_moreMatch;
            [_footBallScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
        case 1:
            _footBallPassBarrierType = FootBallPassBarrierType_singleMacth;
            [_footBallScrollView setContentOffset:CGPointMake(kWinSize.width, 0) animated:YES];
            break;
            
        default:
            break;
    }
    
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    
    [self updateBottomViewDisplay:[selectMatchArray count]];
}

#pragma mark -Customized: Private (General)
- (void)updateBottomViewDisplay:(NSInteger)count {
    if (count > 0) {
        [_bottomView setTextWithMatchCount:count hasMatch:YES];
    } else {
        if (_footBallPlayType == FootBallPlayType_single || _footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
            [_bottomView setTextWithMatchCount:1 hasMatch:NO];
        } else {
            [_bottomView setTextWithMatchCount:2 hasMatch:NO];
        }
    }
}

- (void)refreshMatchArrayWithFootBallPassBarrierType:(FootBallPassBarrierType)footBallPassBarrierType {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:footBallPassBarrierType];
    
    NSInteger count = [selectMatchArray count];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    //如果投注页面返回该选择比赛页面有比赛取消，将已经取消的数组下标字典删除，有选择的继续保留
    for (NSInteger i = 0; i < count;i++) {
        NSArray *array = [[selectMatchArray objectAtIndex:i] objectForKey:@"selectArray"];
        if(array.count == 0) {
            [tempArray addObject:[selectMatchArray objectAtIndex:i]];
        }
    }
    
    [selectMatchArray removeObjectsInArray:tempArray];
    [tempArray release];
}

- (void)replaceButtonTextWithArray:(NSArray *)array AtIndex:(NSIndexPath *)indexPath {
    CustomFootBallMainCell *cell = (CustomFootBallMainCell *)[[self getMatchTableListWithType:_footBallPassBarrierType] cellForRowAtIndexPath:indexPath];
    
    for (UIView *view in cell.buttonImageView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:[self convertArrayToString:array] forState:UIControlStateNormal];
        }
    }
}

- (NSString *)convertArrayToString:(NSArray *)array {
    if (array.count == 0) {
        if (_footBallPlayType == FootBallPlayType_half) {
            return @"点击展开投注区";
        }
        return @"点击展开比分投注区";
    }
    
    NSString *result = [array componentsJoinedByString:(_footBallPlayType == FootBallPlayType_score ? @"," : @" ")];
    return result;
}

- (NSInteger)indexOfDictionary:(NSDictionary *)dic {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    for (NSDictionary *matchDic in selectMatchArray) {
        if([[matchDic objectForKey:@"selectRowDic"] isEqualToDictionary:dic]) {
            return [selectMatchArray indexOfObject:matchDic];
        }
    }
    
    return -1;
}

- (BOOL)isArrayContainsDictionary:(NSDictionary *)dic {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_footBallPassBarrierType];
    for (NSDictionary *matchDic in selectMatchArray) {
        if([[matchDic objectForKey:@"selectRowDic"] isEqualToDictionary:dic]) {
            return YES;
        }
    }
    return NO;
}

- (void)getPlayMethods {
    [GlobalsProject firstTypePlayIdWithTicketTypeName:self.title betTypeArray:_betTypeArray];
}

- (void)selectSetFrameWithType:(NSInteger)selectType {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    if (_footBallPlayType == FootBallPlayType_mix) {
        [_matchTypeCustomSegmentedControl setHidden:YES];
        [_footBallScrollView setFrame:CGRectMake( 0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f * 2)];
        [_footBallScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 1, CGRectGetWidth(appRect))];
        _footBallPassBarrierType = FootBallPassBarrierType_moreMatch;
        [_footBallScrollView setShowsHorizontalScrollIndicator:YES];
        
    } else {
        [_matchTypeCustomSegmentedControl setHidden:NO];
        [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:0];
        [_footBallScrollView setFrame:CGRectMake( 0, 0 + FootBallViewMatchTypeCustomSegmentedControl, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f * 2 - FootBallViewMatchTypeCustomSegmentedControl)];
        [_footBallScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 2, CGRectGetWidth(appRect))];
        _footBallPassBarrierType = FootBallPassBarrierType_moreMatch;
        [_footBallScrollView setShowsHorizontalScrollIndicator:NO];
    }
    CGRect matchTableListRect = _matchTableList.frame;
    [_matchTableList setFrame:CGRectMake(CGRectGetMinX(matchTableListRect), CGRectGetMinY(matchTableListRect), CGRectGetWidth(matchTableListRect), CGRectGetHeight(_footBallScrollView.frame))];
}

- (NSIndexPath *)findButtonIndexPathWithTheButton:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    NSIndexPath *indexPath = [[self getMatchTableListWithType:_footBallPassBarrierType] indexPathForCell:cell];
    return indexPath;
}

- (NSMutableDictionary *)findRowDictWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [[self getMatchDictWithType:_footBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
    return rowDic;
}

- (void)updateTextArray:(NSMutableArray *)textArray rowDict:(NSDictionary *)rowDict selectNumberArray:selectNumberArray {
    DialogSelectButtonView *dialogSelectButtonView = [[DialogSelectButtonView alloc] initWithMatchDict:rowDict selectNumberArray:selectNumberArray];
    [dialogSelectButtonView setDialogType:DialogFootBallMix];
    [dialogSelectButtonView setSelectMatchTextWithTextArray:textArray];
    [dialogSelectButtonView release];
}

- (UILabel *)getMatchPromptLabelWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _matchPromptLabel;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleMatchPromptLabel;
    }
    return nil;
}

- (UITableView *)getMatchTableListWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _matchTableList;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleMatchTableList;
    }
    return nil;
}

- (NSDictionary *)getCompleteMatchDictWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _completeMatchDict;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _completeSingleMatchDict;
    }
    return nil;
}

- (NSMutableDictionary *)getDropDicWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _dropDic;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleDropDic;
    }
    return nil;
}

- (NSMutableDictionary *)getSelectScoreDicWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _selectScoreDic;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleSelectScoreDic;
    }
    return nil;
}

- (NSMutableDictionary *)getSelectHalfDictWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _selectHalfDict;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleSelectHalfDict;
    }
    return nil;
}

- (NSMutableDictionary *)getFilterMatchDicWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _filterMatchDic;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleFilterMatchDic;
    }
    return nil;
}

- (NSMutableDictionary *)getMatchDictWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _matchDict;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleMatchDict;
    }
    return nil;
}

- (NSMutableArray *)getSelectMatchArrayWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _selectMatchArray;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleSelectMatchArray;
    }
    return nil;
}

- (NSMutableArray *)getSelectHalfMuArrayWithType:(FootBallPassBarrierType)footBallPassBarrierType {
    if (footBallPassBarrierType == FootBallPassBarrierType_moreMatch) {
        return _selectHalfMTArray;
    } else if (footBallPassBarrierType == FootBallPassBarrierType_singleMacth) {
        return _singleSelectHalfMTArray;
    }
    return nil;
}

- (BOOL)hasMatchWithMatchDict:(NSDictionary *)matchDict footBallPlayType:(FootBallPlayType)footBallPlayType {
    if ([matchDict objectForKey:@"table1"]) {
        NSArray * oneTabelMatchArray = [matchDict objectForKey:@"table1"];
        if ([oneTabelMatchArray count] > 0) { //一般第一个table没有,其他都没有
            NSDictionary *oneMatchMessageDict = [oneTabelMatchArray objectAtIndex:0];
            if (footBallPlayType == FootBallPlayType_mix) {
                return YES;
                
            } else {
                if (![[oneMatchMessageDict objectForKey:[self serverKeyStringWithType:footBallPlayType]] isEqualToString:@"True"]) {
                    return NO;
                }
            }
            
        } else {
            return NO;
        }
        return YES;
    } else {
        return NO;
    }
}

/** 根据服务器的玩法字段筛选比较，同时筛选过关单关
 @param serverKey 服务器玩法字段
 */
- (void)filterMatchesWithServerKey:(NSString *)serverKey {
    [_matchDict removeAllObjects];
    [self filterMatchesWithCompleteMatchDict:_completeMatchDict matchDict:_matchDict serverKey:serverKey];

    [_singleMatchDict removeAllObjects];
    [self filterMatchesWithCompleteMatchDict:_completeSingleMatchDict matchDict:_singleMatchDict serverKey:serverKey];
    
}

/** 根据服务器的玩法字段，将该玩法的比赛筛选出来
 @param completeMatchDict  完整的比赛
 @param matchDict 筛选存入比赛用的字典
 @param serverKey 服务器玩法字段
 */
- (void)filterMatchesWithCompleteMatchDict:(NSDictionary *)completeMatchDict matchDict:(NSMutableDictionary *)matchDict serverKey:(NSString *)serverKey {
    NSMutableDictionary *filterMatchDic = matchDict == _matchDict ? _filterMatchDic : _singleFilterMatchDic;  ////////
    
    NSArray *filterTextArray = [filterMatchDic objectForKey:@"selectText"];  //需要筛选的比赛类型
    
    NSInteger signIndex = 0;
        
    for (NSInteger tableIndex = 0; tableIndex < completeMatchDict.count; tableIndex++) {
        NSDictionary *tableDict = [completeMatchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)(tableIndex + 1)]];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *matchMessageDict in tableDict) {
            if ([serverKey isEqualToString:[self serverKeyStringWithType:FootBallPlayType_mix]]) {
                if (([[matchMessageDict objectForKey:[self serverKeyStringWithType:FootBallPlayType_letWinDogfallLose]] isEqualToString:@"True"] || [[matchMessageDict objectForKey:[self serverKeyStringWithType:FootBallPlayType_winDogfallLose]] isEqualToString:@"True"] || [[matchMessageDict objectForKey:[self serverKeyStringWithType:FootBallPlayType_score]] isEqualToString:@"True"] || [[matchMessageDict objectForKey:[self serverKeyStringWithType:FootBallPlayType_totalGoal]] isEqualToString:@"True"] || [[matchMessageDict objectForKey:[self serverKeyStringWithType:FootBallPlayType_half]] isEqualToString:@"True"]) && ([filterTextArray containsObject:[matchMessageDict objectForKey:@"game"]] || [filterTextArray count] == 0)) {
                    [tempArray addObject:matchMessageDict];
                }
                
            } else {
                if ([[matchMessageDict objectForKey:serverKey] isEqualToString:@"True"] && ([filterTextArray containsObject:[matchMessageDict objectForKey:@"game"]] || [filterTextArray count] == 0)) {
                    [tempArray addObject:matchMessageDict];
                }
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

/** 获取比赛中的所有类型
 */
- (NSString *)serverKeyStringWithType:(FootBallPlayType)footBallPlayType {
    switch (footBallPlayType) {
        case FootBallPlayType_letWinDogfallLose:
            return @"isSPF";
            break;
        case FootBallPlayType_winDogfallLose:
            return @"isNewSPF";
            break;
        case FootBallPlayType_score:
            return @"isCBF";
            break;
        case FootBallPlayType_totalGoal:
            return @"isZJQ";
            break;
        case FootBallPlayType_half:
            return @"isBQC";
            break;
        case FootBallPlayType_mix:
            return @"all";
            break;
            
        default:
            break;
    }
    
    return @"";
}

//跟getArrayIndexWithFootBallBetSelectType:对应
- (FootBallPlayType)getFootBallBetSelectTypeWithIndex:(NSInteger)index {
    switch (index) {
        case 1:
            return FootBallPlayType_letWinDogfallLose;
            break;
        case 2:
            return FootBallPlayType_winDogfallLose;
            break;
        case 3:
            return FootBallPlayType_score;
            break;
        case 4:
            return FootBallPlayType_totalGoal;
            break;
        case 5:
            return FootBallPlayType_half;
            break;
        case 0:
            return FootBallPlayType_mix;
            break;
            
        default:
            break;
    }
    
    return FootBallPlayType_no;
}

//跟getFootBallBetSelectTypeWithIndex:对应
- (NSInteger)getArrayIndexWithFootBallBetSelectType:(FootBallPlayType)footBallPlayType {
    switch (footBallPlayType) {
        case FootBallPlayType_letWinDogfallLose:
            return 1;
            break;
        case FootBallPlayType_winDogfallLose:
            return 2;
            break;
        case FootBallPlayType_score:
            return 3;
            break;
        case FootBallPlayType_totalGoal:
            return 4;
            break;
        case FootBallPlayType_half:
            return 5;
            break;
        case FootBallPlayType_mix:
            return 0;
            break;
            
        default:
            break;
    }
    
    return 101;
}

@end
