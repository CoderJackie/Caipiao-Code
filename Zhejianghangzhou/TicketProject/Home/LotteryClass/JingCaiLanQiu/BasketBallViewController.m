//
//  BasketBallViewController.m  购彩大厅－竞彩篮球选号
//  TicketProject
//
//  Created by sls002 on 13-7-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140712 08:23（洪晓彬）：修改代码规范，改进生命周期
//20140927 10:24（洪晓彬）：进行ipad适配

#import "BasketBallViewController.h"

#import "BasketBallBetViewController.h"
#import "CustomBottomView.h"
#import "CustomFootBallMainCell.h"
#import "CustomizedButton.h"
#import "CustomSegmentedControl.h"
#import "DialogFilterMatchView.h"
#import "DialogSelectButtonView.h"
#import "HelpViewController.h"
#import "SSQPlayMethodView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "GlobalsProject.h"

#define BasketBallViewControllerTabelCellHeight (IS_PHONE ? 90.0f : 140.0f)
#define BasketBallViewControllerTabelHeadViewHeight (IS_PHONE ? 30.0f : 60.0f)
#define BasketBallViewMatchTypeCustomSegmentedControl (IS_PHONE ? 30.0f : 60.0f)

@interface BasketBallViewController ()
/** 获取特定彩种的玩法 */
- (void)getPlayMethods;
/** 改变底部提示文字 
    @param  count  彩票注数 */
- (void)updateBottomViewDisplay:(NSInteger)count;
/** 从篮球竞彩购彩页面返回到篮球选彩页面，将判断上一个页面返回的数据，如果被取消的将删除被取消的数组 */
- (void)refreshMatchArray;
/** 猜比分  选中比分后将按钮的title 设置为选中的比分 */
- (void)replaceButtonTextWithArray:(NSArray *)array AtIndex:(NSIndexPath *)indexPath;
/** 猜比分  将数组转换成用","隔开的字符串 */
- (NSString *)convertArrayToString:(NSArray *)array;
/** 获取比赛信息 在 字典中的位置 */
- (NSInteger)indexOfDictionary:(NSDictionary *)dic;
/** 判断数组中是否存在字典类型的数组 */
- (BOOL)isArrayContainsDictionary:(NSDictionary *)dic;
@end
#pragma mark -
#pragma mark @implementation BasketBallViewController
@implementation BasketBallViewController
#pragma mark Lifecircle
- (id)initWithMatchData:(NSObject *)matchData {
    self = [super init];
    if(self) {
        _basketBallPlayType = BasketBallPlayType_mix;
        _completeMatchDict = [[(NSDictionary *)matchData objectForKey:@"dtMatch"] retain]; //完整比赛信息
        _singleCompleteMatchDict = [[(NSDictionary *)matchData objectForKey:@"singleMatch"] retain];
        
        _matchDict = [[NSMutableDictionary alloc] init];
        [self filterMatchesWithServerKey:[self serverKeyStringWithType:_basketBallPlayType] basketBallPassBarrierType:BasketBallPassBarrierType_moreMatch];
        
        _singleMatchDict = [[NSMutableDictionary alloc] init];
        [self filterMatchesWithServerKey:[self serverKeyStringWithType:_basketBallPlayType] basketBallPassBarrierType:BasketBallPassBarrierType_singleMacth];
        
        _tempDict = [[(NSDictionary *)matchData objectForKey:@"dtMatch"] retain];
        _singleTempDict = [[(NSDictionary *)matchData objectForKey:@"singleMatch"] retain];
        
        self.title = @"竞彩篮球";
        _playMethodArray = [[NSMutableArray alloc] init];
        [self getPlayMethods];
    }
    return self;
}

- (void)dealloc {
    [_dropDict release];
    _dropDict = nil;
    [_singleDropDict release];
    _singleDropDict = nil;
    
    [_playMethodArray release];
    _playMethodArray = nil;
    
    [_matchDict release];
    _matchDict = nil;
    [_singleMatchDict release];
    _singleMatchDict = nil;
    
    [_tempDict release];
    _tempDict = nil;
    [_singleTempDict release];
    _singleTempDict = nil;
    
    [_selectMatchArray release];
    _selectMatchArray = nil;
    [_singleSelectMatchArray release];
    _singleSelectMatchArray = nil;
    
    [_filterMatchDict release];
    _filterMatchDict = nil;
    [_singleFilterMatchDict release];
    _singleFilterMatchDict = nil;
    
    [_completeMatchDict release];
    _completeMatchDict = nil;
    [_singleCompleteMatchDict release];
    _singleCompleteMatchDict = nil;
    
    [super dealloc];
}

- (void)loadView {
    _lotteryID = 73;
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
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
    CGFloat midBtnContentCutWidth = IS_PHONE ? 40.0f : 100.0f;
    
    CGFloat bottomBtnHeight = IS_PHONE ? 45.0f : 70.0f;
    /********************** adjustment end ***************************/
    
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
    
    
    //玩法介绍
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
        //midView 顶部－背景
        CGRect midViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect) - CGRectGetWidth(comeBackBtnRect) - CGRectGetWidth(playingMethodBtnRect) - midViewCutWidht - filterBtnMaginPlayingMethodBtn * 2, midViewHeight);
        UIView *midView = [[UIView alloc]initWithFrame:midViewRect];
        [self.navigationItem setTitleView:midView];
        [midView release];
        
        //赛事选择
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
        [_midBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_midBtn setTitle:@"混合过关" forState:UIControlStateNormal];
        [_midBtn setTag:1000];
        [_midBtn setContentEdgeInsets:UIEdgeInsetsMake(0, -midBtnContentCutWidth, 0, 0)];
        [_midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_midBtn addTarget:self action:@selector(navMiddleBtnSelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [midView addSubview:_midBtn];
    }
    
    //matchTypeCustomSegmentedControl
    CGRect matchTypeCustomSegmentedControlRect = CGRectMake(0, 0, self.view.bounds.size.width, BasketBallViewMatchTypeCustomSegmentedControl);
    _matchTypeCustomSegmentedControl = [[CustomSegmentedControl alloc]initWithFrame:matchTypeCustomSegmentedControlRect Items:[NSArray arrayWithObjects:@"过关(至少选两场)", @"单关(一场 奖金固定)", nil] normalImageName:@"singleMatchNormalBtn.png" selectImageName:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]];
    [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:0];
    [_matchTypeCustomSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_matchTypeCustomSegmentedControl addTarget:self action:@selector(matchTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_matchTypeCustomSegmentedControl];
    [_matchTypeCustomSegmentedControl release];
    
    //basketBallScrollView
    CGRect basketBallScrollViewRect = CGRectMake( 0, BasketBallViewMatchTypeCustomSegmentedControl, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kNavigationBarHeight * 2 - BasketBallViewMatchTypeCustomSegmentedControl);
    _basketBallScrollView = [[UIScrollView alloc]initWithFrame:basketBallScrollViewRect];
    [_basketBallScrollView setClipsToBounds:YES];
    [_basketBallScrollView setPagingEnabled:YES];
    [_basketBallScrollView setDelegate:self];
    [_basketBallScrollView setTag:1010];
    [_basketBallScrollView setUserInteractionEnabled:YES];
    [_basketBallScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 2, CGRectGetWidth(appRect))];
    [_basketBallScrollView setContentOffset:CGPointMake(_basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch ? 0 : CGRectGetWidth(appRect), 0)];
    [_basketBallScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_basketBallScrollView];
    [_basketBallScrollView release];
    
    //matchTableList 中部－比赛选择的tableview
    CGRect matchTableListRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(basketBallScrollViewRect));
    _matchTableList = [[UITableView alloc]initWithFrame:matchTableListRect style:UITableViewStylePlain];
    [_matchTableList setBackgroundColor:kBackgroundColor];
    [_matchTableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_matchTableList setTag:BasketBallPassBarrierType_moreMatch];
    [_matchTableList setDataSource:self];
    [_matchTableList setDelegate:self];
    [_basketBallScrollView addSubview:_matchTableList];
    [_matchTableList release];
    
    //matchPromptLabel
    CGRect matchPromptLabelRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(matchTableListRect));
    _matchPromptLabel = [[UILabel alloc] initWithFrame:matchPromptLabelRect];
    [_matchPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_matchPromptLabel setText:@"当前暂无比赛"];
    [_matchPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize21]];
    [_matchPromptLabel setTextColor:[UIColor colorWithRed:192.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f]];
    [_matchPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_matchPromptLabel setHidden:[_matchDict count] > 0];
    [_basketBallScrollView addSubview:_matchPromptLabel];
    [_matchPromptLabel release];
    
    //singleMatchTableList
    CGRect singleMatchTableListRect = CGRectMake(CGRectGetWidth(appRect), 0, CGRectGetWidth(appRect), CGRectGetHeight(basketBallScrollViewRect));
    _singleMatchTableList = [[UITableView alloc]initWithFrame:singleMatchTableListRect style:UITableViewStylePlain];
    [_singleMatchTableList setBackgroundColor:kBackgroundColor];
    [_singleMatchTableList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_singleMatchTableList setTag:BasketBallPassBarrierType_singleMacth];
    [_singleMatchTableList setDataSource:self];
    [_singleMatchTableList setDelegate:self];
    [_basketBallScrollView addSubview:_singleMatchTableList];
    [_singleMatchTableList release];
    
    //singleMatchPromptLabel
    CGRect singleMatchPromptLabelRect = CGRectMake(CGRectGetWidth(appRect), 0, CGRectGetWidth(appRect), CGRectGetHeight(singleMatchTableListRect));
    _singleMatchPromptLabel = [[UILabel alloc] initWithFrame:singleMatchPromptLabelRect];
    [_singleMatchPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_singleMatchPromptLabel setText:@"当前暂无比赛"];
    [_singleMatchPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize21]];
    [_singleMatchPromptLabel setTextColor:[UIColor colorWithRed:192.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f]];
    [_singleMatchPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_singleMatchPromptLabel setHidden:[_singleMatchDict count] > 0];
    [_basketBallScrollView addSubview:_singleMatchPromptLabel];
    [_singleMatchPromptLabel release];
    
    //bottomView 底部框
    CGRect bottomViewRect = CGRectMake(0, self.view.bounds.size.height - 44.0f - bottomBtnHeight, CGRectGetWidth(appRect), bottomBtnHeight);
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
    _playMethodView = [[SSQPlayMethodView alloc]initWithPlayMethodNames:_playMethodArray lottery:self.title withIndex:[self getArrayIndexWithBasketBallBetSelectType:_basketBallPlayType]];
    [_playMethodView setDelegate:self];
    [self.view addSubview:_playMethodView];
    [_playMethodView release];
    
    [self selectSetFrameWithType:_basketBallPlayType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.xfTabBarController setTabBarHidden:YES];
    if (!_selectMatchArray) {
        _selectMatchArray = [[NSMutableArray alloc] init];
    }
    if (!_singleSelectMatchArray) {
        _singleSelectMatchArray = [[NSMutableArray alloc] init];
    }
    
    if (!_dropDict) {
        _dropDict = [[NSMutableDictionary alloc] init];
    }
    if (!_singleDropDict) {
        _singleDropDict = [[NSMutableDictionary alloc] init];
    }
    
    //第一次加载  全部展开
    for (int i = 0; i < _matchDict.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_dropDict setObject:dic forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    for (int i = 0; i < _singleMatchDict.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_singleDropDict setObject:dic forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    if (self.betViewController) {
        UIView *midView = self.navigationItem.titleView;
        UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
        [midBtn setEnabled:NO];
        NSString *strBetType =  [_playMethodArray objectAtIndex:[self getArrayIndexWithBasketBallBetSelectType:_basketBallPlayType]]; ;
        [midBtn setTitle:strBetType forState:UIControlStateNormal];
    }
    [self updateBottomViewDisplay:[[self getSelectMatchArrayWithType:_basketBallPassBarrierType] count]];
}

- (void)viewWillAppear:(BOOL)animated {
    //刷新数组  在投注页面清空后
    [self refreshMatchArray];
    
    [_matchTableList reloadData];
    [_singleMatchTableList reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _matchTableList = nil;
        _singleMatchTableList = nil;
        _bottomView = nil;
        _playMethodView = nil;
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

//选中投注方式下拉选项的委托方法
- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {
    UITableView *matchTableList = [self getMatchTableListWithType:_basketBallPassBarrierType];
    [matchTableList setHidden:NO];
    
    UIView *midView = self.navigationItem.titleView;
    UIButton *midBtn = (UIButton *)[midView viewWithTag:1000];
    [midBtn setTitle:(NSString *)obj forState:UIControlStateNormal];
    [midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    if (index>1) {
        NSString *str = [NSString stringWithFormat:@"%@",[_playMethodArray objectAtIndex:index]];
        [midButton setTitle:str forState:UIControlStateNormal];
    }
    else
        [midButton setTitle:[_playMethodArray objectAtIndex:index] forState:UIControlStateNormal];
    
    //切换时 清空选择项
    [_selectMatchArray removeAllObjects];
    [_singleSelectMatchArray removeAllObjects];
    
    //先删除上一页的buttons  否则会造成重叠
    for (NSInteger i = 0; i < [self getMatchDictWithType:_basketBallPassBarrierType].count; i++) {
        NSArray *array = [[self getMatchDictWithType:_basketBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)i + 1]];
        for (NSInteger j = 0; j < array.count; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            UITableViewCell *cell = [matchTableList cellForRowAtIndexPath:indexPath];
            
            for (UIView *view in cell.contentView.subviews) {
                if([view isKindOfClass:[UIButton class]]) {
                    [view removeFromSuperview];
                }
            }
        }
    }
    
    _basketBallPlayType = [self getBasketBallBetSelectTypeWithIndex:index];
    [self selectSetFrameWithType:_basketBallPlayType];
    [self filterMatchesWithServerKey:[self serverKeyStringWithType:_basketBallPlayType] basketBallPassBarrierType:_basketBallPassBarrierType];
    [self filterMatchesWithServerKey:[self serverKeyStringWithType:_basketBallPlayType] basketBallPassBarrierType:BasketBallPassBarrierType_singleMacth];
    [_basketBallScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self updateBottomViewDisplay:0];
    [_matchTableList reloadData];
    [_singleMatchTableList reloadData];
}

- (void)tapBackView {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == 1010) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:page];
        _basketBallPassBarrierType = page == 0 ? BasketBallPassBarrierType_moreMatch : BasketBallPassBarrierType_singleMacth;
        
        NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
        
        [self updateBottomViewDisplay:[selectMatchArray count]];
    }
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    
    NSMutableDictionary *matchDict = [self getMatchDictWithType:(int)tableView.tag];
    
    if (_basketBallPlayType != BasketBallPlayType_no) {
        BOOL promptLabelHidden = [self hasMatchWithMatchDict:matchDict basketBallPlayType:_basketBallPlayType];
        [[self getMatchPromptLabelWithType:(int)tableView.tag] setHidden:promptLabelHidden];
        if (!promptLabelHidden) {
            return 0;
        }
    }
    
    
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
    NSArray *rowsArray = [[self getMatchDictWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"table%ld",(long)section + 1]];
    
    NSDictionary *dic = [[self getDropDictWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    BOOL isDropdown = [[dic objectForKey:@"isDropDown"] boolValue];
    NSInteger dropSection = [[dic objectForKey:@"dropSection"] intValue];
    //如果 不是下拉状态 并且选中的section相等 则返回0  实现收缩的效果
    if(!isDropdown && dropSection == section)
        return 0;
    return rowsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FootBallMainCell";
    CustomFootBallMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[CustomFootBallMainCell alloc] initWithCellHight:BasketBallViewControllerTabelCellHeight reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //防止cell重用时  视图重叠,所以将元素移除
    if(cell) {
        for (UIView *view in cell.buttonImageView.subviews) {
            if([view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSArray *sectionArray = [[self getMatchDictWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
    
    cell.matchNO = [rowDic objectForKey:@"matchNumber"];
    cell.gameName = [rowDic objectForKey:@"game"];
    
    NSArray *matchDateArray = [[rowDic objectForKey:@"stopSellTime"] componentsSeparatedByString:@" "];
    cell.matchDate = [matchDateArray objectAtIndex:1];
    cell.mainTeam = [NSString stringWithFormat:@"%@(客)", [rowDic objectForKey:@"guestTeam"]];
    cell.guestTeam = [NSString stringWithFormat:@"%@(主)", [rowDic objectForKey:@"mainTeam"]];
    cell.mainLoseBall = @"VS";
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat buttonImageViewWidth =  CGRectGetWidth(cell.buttonImageView.frame);
    CGFloat buttonImageViewHeight = CGRectGetHeight(cell.buttonImageView.frame);
    
    CGFloat oneRowBtnHeight = IS_PHONE ? 30.0f : 60.0f;
    
    CGFloat twoButtonMinX = IS_PHONE ? 8.0f : 40.0f;//让球胜平负，胜平负，比分
    CGFloat twoButtonLandscapeInterval = IS_PHONE ? 0.0f : 0.0f;
    CGFloat twoBtnWidth = (buttonImageViewWidth - twoButtonLandscapeInterval - twoButtonMinX * 2) / 2.0f;
    
    CGFloat oneButtonMinX = 8.0f;
    
    CGFloat mixPromptLabelWidth = 13.0f;
    CGFloat mixButtonMinX = 28.0f;
    CGFloat mixSelectBtnWidth = IS_PHONE ? 33.0f : 50.0f;//展开全部按钮
    
    CGFloat mixLandscapeInterval = 0.0f;
    CGFloat mixButtonWidth = (buttonImageViewWidth - mixPromptLabelWidth - 3 * mixLandscapeInterval - mixSelectBtnWidth - mixButtonMinX) / 3.0f;
    CGFloat mixButtonHeight = buttonImageViewHeight / 2.0f;
    /********************** adjustment end ***************************/
    
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:(int)tableView.tag];
    
    NSMutableDictionary *indexDict = [self findDictInSelectMatchArray:selectMatchArray indexPath:indexPath];
    NSMutableArray *selectArray = [indexDict objectForKey:@"selectArray"];
    [cell.labelOne setHidden:YES];
    [cell.labelTwo setHidden:YES];
    
    if(_basketBallPlayType == BasketBallPlayType_winLose) { // 胜负
        [cell setBoldmainLoseBallLabel:NO];
        for (NSInteger i = 1; i < 3; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(twoButtonMinX + (i - 1) * (twoButtonLandscapeInterval + twoBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, twoBtnWidth, oneRowBtnHeight)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn.titleLabel setMinimumScaleFactor:0.75];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"mainLose"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                [btn setTag:i];
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"mainWin"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                [btn setTag:i];
            }
            [btn setSelected:[self isTheNumberOrTagInArray:selectArray number:btn.tag]];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            if (i == 1) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.buttonImageView addSubview:lineView];
                [lineView release];
            }
            
        }
        
    } else if (_basketBallPlayType == BasketBallPlayType_letWinLose) { //让球胜负
        [cell setBoldmainLoseBallLabel:YES];
        cell.mainLoseBall = [rowDic objectForKey:@"letScore"];;
        for (NSInteger i = 1; i < 3; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(twoButtonMinX + (i - 1) * (twoButtonLandscapeInterval + twoBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, twoBtnWidth, oneRowBtnHeight)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn.titleLabel setMinimumScaleFactor:0.75];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[rowDic objectForKey:@"letMainLose"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                [btn setTag:i];
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[rowDic objectForKey:@"letMainWin"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                [btn setTag:i];
            }
            [btn setSelected:[self isTheNumberOrTagInArray:selectArray number:btn.tag]];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            if (i == 1) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.buttonImageView addSubview:lineView];
                [lineView release];
            }
        }
        
    
    } else if (_basketBallPlayType == BasketBallPlayType_minusScore) {  //胜分差
        cell.mainLoseBall = @"VS";
        [cell setBoldmainLoseBallLabel:NO];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(oneButtonMinX, (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, buttonImageViewWidth - 2 * oneButtonMinX, oneRowBtnHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn.titleLabel setMinimumScaleFactor:0.75];
        [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
        btn.adjustsImageWhenHighlighted = NO;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        if (self.betViewController) {
            [btn setTitle:@"点击展开投注区" forState:UIControlStateNormal];
            for (NSInteger i = 0; i < [selectMatchArray count]; i++) {
                NSDictionary *dic = [selectMatchArray objectAtIndex:i];
                if([[dic objectForKey:@"selectRowDic"] isEqual:rowDic]) {
                    NSArray *selectTextArray = [dic objectForKey:@"selectTextArray"];
                    [btn setTitle:[self convertArrayToString:selectTextArray] forState:UIControlStateNormal];
                }
            }
        } else {
            [btn setTitle:@"点击展开投注区" forState:UIControlStateNormal];
        }
        //记录选中的比分
        NSMutableString *string = [[NSMutableString alloc]initWithCapacity:0];
        if([selectMatchArray count] > 0) {
            for(NSDictionary *dic in selectMatchArray) {
                if([rowDic isEqual:[dic objectForKey:@"selectRowDic"]]) {
                    NSMutableArray *selectTextArray = [dic objectForKey:@"selectTextArray"];
                    [btn setTitle:[self convertArrayToString:selectTextArray] forState:UIControlStateNormal];
                }
            }
            
        }
        [string release];
        
        [btn addTarget:self action:@selector(unfoldBetViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonImageView addSubview:btn];
        
    
    } else if(_basketBallPlayType == BasketBallPlayType_BigSmallScore) {    //大小分
        [cell setBoldmainLoseBallLabel:NO];
        [cell setMainLoseBall:[rowDic objectForKey:@"bigSmallScore"]];
        for (int i = 1; i < 3; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(twoButtonMinX + (i - 1) * (twoButtonLandscapeInterval + twoBtnWidth + AllLineWidthOrHeight), (buttonImageViewHeight - oneRowBtnHeight) / 2.0f, twoBtnWidth, oneRowBtnHeight)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [btn.titleLabel setMinimumScaleFactor:0.75];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn setAdjustsImageWhenHighlighted:NO];
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"大分%@",[rowDic objectForKey:@"big"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                [btn setTag:1];
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"小分%@",[rowDic objectForKey:@"small"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                [btn setTag:2];
            }
            [btn setSelected:[self isTheNumberOrTagInArray:selectArray number:btn.tag]];
            [btn addTarget:self action:@selector(buttonSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonImageView addSubview:btn];
            if (i == 1) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.buttonImageView addSubview:lineView];
                [lineView release];
            }
        
        }
    } else if(_basketBallPlayType == BasketBallPlayType_mix) {   //混合投注
        [cell setBoldmainLoseBallLabel:NO];
        [cell.labelOne setHidden:YES];
        [cell.labelTwo setHidden:YES];
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat labelWidth = IS_PHONE ? 15.0f : 25.0f;
        /********************** adjustment end ***************************/
        
        //btnOne
        CGRect btnOneRect = CGRectMake(mixButtonMinX - labelWidth, 0 - AllLineWidthOrHeight, labelWidth, mixButtonHeight + AllLineWidthOrHeight);
        UIButton *btnOne = [[UIButton alloc] initWithFrame:btnOneRect];
        [btnOne.layer setBorderColor:kLightGrayColor.CGColor];
        [btnOne setBackgroundColor:bYellowColor];
        [btnOne setTitle:@"让分" forState:UIControlStateNormal];
        [[btnOne titleLabel] setNumberOfLines:3];
        [btnOne setTitleColor:tYellowColor forState:UIControlStateNormal];
        [[btnOne titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize8]];
        [[btnOne layer] setBorderWidth:AllLineWidthOrHeight];
        [btnOne setTag:120];
        [cell.buttonImageView addSubview:btnOne];
        [btnOne release];
        
        //btnTwo
        CGRect btnTwoRect = CGRectMake(mixButtonMinX - labelWidth, CGRectGetMaxY(btnOneRect) - AllLineWidthOrHeight, labelWidth, mixButtonHeight + AllLineWidthOrHeight);
        UIButton *btnTwo = [[UIButton alloc] initWithFrame:btnTwoRect];
        [btnTwo.layer setBorderColor:kLightGrayColor.CGColor];
        [btnTwo setBackgroundColor:bGreenColor];
        [btnTwo setTitleColor:tGreenColor forState:UIControlStateNormal];
        [[btnTwo titleLabel] setNumberOfLines:3];
        [btnTwo setTitle:@"大小分" forState:UIControlStateNormal];
        [[btnTwo titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize8]];
        [[btnTwo layer] setBorderWidth:AllLineWidthOrHeight];
        [btnTwo setTag:121];
        [cell.buttonImageView addSubview:btnTwo];
        [btnTwo release];
        
        BOOL hasSF = [[rowDic objectForKey:@"isRFSF"] isEqualToString:@"True"];
        BOOL hasDXF = [[rowDic objectForKey:@"isDXF"] isEqualToString:@"True"];
        for (NSInteger row = 0; row < 2; row++) {
            for (NSInteger col = 0; col < 3; col++) {
                
                CGRect btnRect = CGRectMake(mixButtonMinX + (mixLandscapeInterval + mixButtonWidth) * col - AllLineWidthOrHeight, 0 + mixButtonHeight * row - AllLineWidthOrHeight, mixButtonWidth + AllLineWidthOrHeight, mixButtonHeight + AllLineWidthOrHeight);
                CustomizedButton *btn = [[CustomizedButton alloc] initWithFrame:btnRect];
                [btn setFrame:btnRect];
                [btn setCustomizedButtonType:CustomizedButtonTypeLandscape];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [btn setAdjustsImageWhenHighlighted:NO];
                [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [btn setTextFontSize:XFIponeIpadFontSize11];
                [btn setOddsLabelFontSize:XFIponeIpadFontSize9];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                
                if (col != 1) {
                    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:218.0f/255.0f green:33/255.0f blue:46/255.0f alpha:1.0f]] forState:UIControlStateSelected];
                    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:218.0f/255.0f green:33/255.0f blue:46/255.0f alpha:1.0f]] forState:UIControlStateSelected | UIControlStateHighlighted];
                    [btn addTarget:self action:@selector(btnSelectedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                    [btn.layer setBorderWidth:AllLineWidthOrHeight];
                    [btn.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
                    
                }
                if ((row * 3 + col) == 0) {
                    [btn setTextString:@"客胜"];
                    [btn setOddsString:[NSString stringWithFormat:@"%.2f",[[rowDic objectForKey:@"letMainLose"] doubleValue]]];
                    [btn setTag:200];
                }
                if ((row * 3 + col) == 1) {
                    double number = [[rowDic objectForKey:@"letScore"] doubleValue];
                    
                    if (number > 0) {
                        [btn setTitle:[NSString stringWithFormat:@"主+%.1f",number] forState:UIControlStateNormal];
                    } else {
                        [btn setTitle:[NSString stringWithFormat:@"主%.1f",number] forState:UIControlStateNormal];
                    }
                    [btn setTitleColor:number > 0 ? kRedColor : kGreenColor forState:UIControlStateNormal];
                    
                    
                    
                }
                if ((row * 3 + col) == 2) {
                    [btn setTextString:@"主胜"];
                    [btn setOddsString:[NSString stringWithFormat:@"%.2f",[[rowDic objectForKey:@"letMainWin"] doubleValue]]];
                    [btn setTag:201];
                }
                if ((row * 3 + col) == 3) {
                    [btn setTextString:@"大分"];
                    [btn setOddsString:[NSString stringWithFormat:@"%.2f",[[rowDic objectForKey:@"big"] doubleValue]]];
                    [btn setTag:300];
                }
                if ((row * 3 + col) == 4) {
                    [btn setTitle:[NSString stringWithFormat:@"%.1f",[[rowDic objectForKey:@"bigSmallScore"] doubleValue]] forState:UIControlStateNormal];
                    
                }
                if ((row * 3 + col) == 5) {
                    [btn setTextString:@"小分"];
                    [btn setOddsString:[NSString stringWithFormat:@"%.2f",[[rowDic objectForKey:@"small"] doubleValue]]];
                    [btn setTag:301];
                    
                }
                
                [btn setSelected:[self isTheNumberOrTagInArray:selectArray number:btn.tag]];
                if (col != 1) {
                    [btn setTextTextColor:[btn isSelected] ? [UIColor whiteColor] : kDarkGrayColor];
                    [btn setOddsTextColor:[btn isSelected] ? [UIColor whiteColor] : kDarkGrayColor];
                }
                if ((row == 0 && hasSF) || (row == 1 && hasDXF)) {
                    [cell.buttonImageView addSubview:btn];
                    
                    
                } else if (col == 0){
                    CGRect promptLabelRect = CGRectMake(mixButtonMinX - AllLineWidthOrHeight, 0 + mixButtonHeight * row - AllLineWidthOrHeight, (mixLandscapeInterval + mixButtonWidth) * 3 + AllLineWidthOrHeight, mixButtonHeight +AllLineWidthOrHeight);
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
                
                
                [btn release];
                
                if ((row * 3 + col) == 4) {
                    CGRect lineViewRect = CGRectMake(CGRectGetMinX(btnRect), CGRectGetMinY(btnRect), CGRectGetWidth(btnRect), AllLineWidthOrHeight);
                    UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                    [lineView setBackgroundColor:kLightGrayColor];
                    [cell.buttonImageView addSubview:lineView];
                    [lineView release];
                }
                
            }
        }
        CGRect mixButtonRect = CGRectMake(mixButtonMinX + 3 * (mixLandscapeInterval + mixButtonWidth) -AllLineWidthOrHeight, -AllLineWidthOrHeight, mixSelectBtnWidth, CGRectGetHeight(btnOneRect) * 2 - AllLineWidthOrHeight);
        UIButton *mixButton = [[UIButton alloc] initWithFrame:mixButtonRect];
        [mixButton.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [mixButton.titleLabel setNumberOfLines:2];
        [[mixButton layer] setBorderWidth:AllLineWidthOrHeight];
        [[mixButton layer] setBorderColor:kLightGrayColor.CGColor];
        if([selectArray count] == 0) {
            [mixButton setTitle:@"展开全部" forState:UIControlStateNormal];
            [mixButton setSelected:NO];
        } else {
            NSString *tempStr ;
            
            if ((long)[selectArray count] > 9) {
                tempStr = [NSString stringWithFormat:@"已选 %ld项",(long)[selectArray count]];
            }else {
                tempStr = [NSString stringWithFormat:@"已选 %ld 项",(long)[selectArray count]];
            }
            [mixButton setTitle:tempStr forState:UIControlStateNormal];
            [mixButton setSelected:YES];
        }
        [mixButton setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [mixButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [mixButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [mixButton setBackgroundImage:[UIImage imageWithColor:kRedColor] forState:UIControlStateSelected];
        [mixButton addTarget:self action:@selector(mixAllTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonImageView addSubview:mixButton];
        [mixButton release];
    }
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BasketBallViewControllerTabelCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return BasketBallViewControllerTabelHeadViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *sectionArray = [[self getMatchDictWithType:(int)tableView.tag] objectForKey:[NSString stringWithFormat:@"table%ld",(long)section + 1]];
    if([sectionArray count] == 0) {
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
    
    CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width, BasketBallViewControllerTabelHeadViewHeight);
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect]autorelease];
    
    UIButton *dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropBtn setFrame:CGRectMake(0, headViewDropBtnMinY, kWinSize.width, BasketBallViewControllerTabelHeadViewHeight - headViewDropBtnMinY)];
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
    
    NSDictionary *dic = [[self getDropDictWithType:_basketBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    //如果是下拉状态  让button选中
    if([[dic objectForKey:@"isDropDown"] boolValue] == YES) {
        [dropBtn setSelected:YES]; //设置btn的状态  因为在tableview reloadData的时候
    }
    
    return headerView;
}

//tableView滚动时 重用cell会刷掉已选的
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:(int)tableView.tag];
    for (NSInteger i = 0; i < selectMatchArray.count; i++) {
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

#pragma mark -DialogFilterMatchViewDelegate
//筛选过滤条件 点确认后调用
- (void)filterMatchesWithType:(NSInteger)type MatchDictionary:(NSDictionary *)matches {
    if (_basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        [_filterMatchDict release];
        _filterMatchDict = [matches retain];
    } else if (_basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        [_singleFilterMatchDict release];
        _singleFilterMatchDict = [matches retain];
        
    }
    
    _selectLetBallType = type;
    
    NSDictionary *tempDict = [self getTempDictWithType:_basketBallPassBarrierType];
    
    NSMutableDictionary *matchDictionary = [NSMutableDictionary dictionary];
    
    //从备份字典中过滤  因为备份字典中存储了所有的比赛
    //如果从matchDic中去取，此时matchDic中的比赛是经过过滤后的了 所以不完整
    for (NSInteger i = 0; i < [tempDict count]; i++) {
        NSMutableArray *matchArray = [NSMutableArray array];
        NSArray *array = [tempDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)i + 1]];
        for (NSInteger j = 0; j < array.count; j++) {
            NSDictionary *dic = [array objectAtIndex:j];
            NSArray *array = [matches objectForKey:@"selectText"];
            
            if(type == 2) {//让球
                if([array containsObject:[dic objectForKey:@"game"]] && [[dic objectForKey:@"mainLoseBall"] intValue] != 0) {
                    [matchArray addObject:dic];
                }
            }
            else if(type == 3) {//非让球
                if([array containsObject:[dic objectForKey:@"game"]] && [[dic objectForKey:@"mainLoseBall"] intValue] == 0) {
                    [matchArray addObject:dic];
                }
            }
            else {//全部
                if([array containsObject:[dic objectForKey:@"game"]]) {
                    [matchArray addObject:dic];
                }
            }
        }
        [matchDictionary setObject:matchArray forKey:[NSString stringWithFormat:@"table%ld",(long)i + 1]];
    }
    
    /**************   这是筛选后删除已经未选中场次的功能，不需要可以把中间这部分代码删除了 **************/
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    
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
    if (_basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        [_matchDict release];
        _matchDict = [matchDictionary retain];
        [_matchTableList reloadData];
    } else if (_basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        [_singleMatchDict release];
        _singleMatchDict = [matchDictionary retain];
        [_singleMatchTableList reloadData];
    }
    
}

#pragma mark -DialogSelectButtonViewDetegate
- (void)dialogSelectMatch:(NSMutableArray *)selectMatchArray selectMatchText:(NSMutableArray *)selectMatchText dialogType:(DialogType)dialogType indexPath:(NSIndexPath *)indexPath {
    if (_basketBallPlayType == BasketBallPlayType_mix || _basketBallPlayType == BasketBallPlayType_minusScore) {
        NSDictionary *rowDict = [self findRowDictWithIndexPath:indexPath];
        
        NSMutableArray *passBarrierSelectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableArray * selectArray = [NSMutableArray array];
        [selectArray addObjectsFromArray:selectMatchArray];
        
        NSMutableArray *selectTextArray = [NSMutableArray array];
        [selectTextArray addObjectsFromArray:selectMatchText];
        
        if([self isArrayContainsDictionary:rowDict]) {
            NSInteger index = [self indexOfDictionary:rowDict];
            
            if ([selectMatchArray count] == 0) {
                [passBarrierSelectMatchArray removeObjectAtIndex:index];
                
            } else {
                [dict setObject:rowDict forKey:@"selectRowDic"];
                [dict setObject:selectArray forKey:@"selectArray"];
                [dict setObject:selectTextArray forKey:@"selectTextArray"];
                [dict setObject:indexPath forKey:@"selectIndexPath"];
                [dict setObject:[NSString stringWithFormat:@"%ld",(long)_basketBallPlayType] forKey:@"selectType"];
                [passBarrierSelectMatchArray replaceObjectAtIndex:index withObject:dict];
            }
            
        } else if ([selectMatchArray count] != 0){
            [dict setObject:rowDict forKey:@"selectRowDic"];
            [dict setObject:selectArray forKey:@"selectArray"];
            [dict setObject:selectTextArray forKey:@"selectTextArray"];
            [dict setObject:indexPath forKey:@"selectIndexPath"];
            [dict setObject:[NSString stringWithFormat:@"%ld",(long)_basketBallPlayType] forKey:@"selectType"];
            [passBarrierSelectMatchArray addObject:dict];
        }
        
        [self updateBottomViewDisplay:[[self getSelectMatchArrayWithType:_basketBallPassBarrierType] count]];
        [[self getMatchTableListWithType:_basketBallPassBarrierType] reloadData];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)matchTypeChanged:(id)sender {
    CustomSegmentedControl *customSegmentedControl = sender;
    
    switch (customSegmentedControl.selectedSegmentIndex) {
        case 0:
            _basketBallPassBarrierType = BasketBallPassBarrierType_moreMatch;
            [_basketBallScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
        case 1:
            _basketBallPassBarrierType = BasketBallPassBarrierType_singleMacth;
            [_basketBallScrollView setContentOffset:CGPointMake(kWinSize.width, 0) animated:YES];
            break;
            
        default:
            break;
    }
    
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    
    [self updateBottomViewDisplay:[selectMatchArray count]];
}

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

//返回
- (void)getBackTouchUpInside:(id)sender {
    if (self.betViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//清空
- (void)clearAllTouchUpInside:(id)sender {
    [[self getSelectMatchArrayWithType:_basketBallPassBarrierType] removeAllObjects];
    [[self getMatchTableListWithType:_basketBallPassBarrierType] reloadData];
}

//确认 跳转到投注页面
- (void)okClickTouchUpInside:(id)sender {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    
    if((selectMatchArray.count < 2 && _basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) || (selectMatchArray.count < 1 && _basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth))
        return;
    
    if (self.betViewController) {
        [self.betViewController updateSelectMatchArray:selectMatchArray];
        self.betViewController.basketBallPlayType = _basketBallPlayType;
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    BasketBallBetViewController *betViewController = [[BasketBallBetViewController alloc]initWithMatchArray:selectMatchArray];
    betViewController.matchDic = [self getMatchDictWithType:_basketBallPassBarrierType];
    betViewController.basketBallPlayType = _basketBallPlayType;
    betViewController.basketBallPassBarrierType = _basketBallPassBarrierType;
    [_midBtn setEnabled:NO];
    [self.navigationController pushViewController:betViewController animated:YES];
    [betViewController release];
}

//玩法介绍
- (void)palyIntroduceTouchUpInside:(UIButton *)btn {
    HelpViewController *helpViewController = [[HelpViewController alloc]initWithLotteryId:_lotteryID];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:helpViewController];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [helpViewController release];
    [nav release];
}

//胜负 大小分
- (void)buttonSelectedTouchUpInside:(id)sender {
    UIButton *btn = sender;
    // iOS 7.0+ : UITableViewCell->UITableViewCellScrollView->UITableViewCellContentView->Your custom view
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    UITableView *matchTableList = [self getMatchTableListWithType:_basketBallPassBarrierType];
    NSIndexPath *indexPath = [matchTableList indexPathForCell:cell];
    NSArray *sectionArray = [[self getMatchDictWithType: _basketBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];//btn所在行的比赛信息
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];//包括比赛行的信息、选中按钮数组信息
    NSMutableArray *selectArray = [NSMutableArray array]; //选中按钮的数组
    
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    
    if(btn.isSelected) {
        NSInteger index = [self indexOfDictionary:rowDic];
        
        NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:@"selectArray"];
        selectArray = [NSMutableArray arrayWithArray:array];
        [selectArray removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        if(selectArray.count == 0) {
            [selectMatchArray removeObjectAtIndex:index];
        } else {
            [[selectMatchArray objectAtIndex:index] setObject:selectArray forKey:@"selectArray"];
        }
        
        [btn setSelected:NO];
    } else {
        if([self isArrayContainsDictionary:rowDic]) {
            NSInteger index = [self indexOfDictionary:rowDic];
            
            NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:@"selectArray"];
            selectArray = [NSMutableArray arrayWithArray:array];
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:@"selectArray"];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_basketBallPlayType] forKey:@"selectType"];
            [selectMatchArray replaceObjectAtIndex:index withObject:dic];
        } else {
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:@"selectArray"];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_basketBallPlayType] forKey:@"selectType"];
            [selectMatchArray addObject:dic];
        }
        
        [btn setSelected:YES];
    }
    
    if (_basketBallPlayType == BasketBallPlayType_mix) {
        [matchTableList reloadData];
    }
    
    [self updateBottomViewDisplay:[selectMatchArray count]];
}

#pragma mark 选择对阵信息
- (void)btnSelectedTouchUpInside:(id)sender {
    CustomizedButton *btn = sender;
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    UITableView *matchTableList = [self getMatchTableListWithType:_basketBallPassBarrierType];
    NSIndexPath *indexPath = [matchTableList indexPathForCell:cell];
    NSArray *sectionArray = [[self getMatchDictWithType:_basketBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    
    NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];//btn所在行的比赛信息
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];//包括比赛行的信息、选中按钮数组信息
    NSMutableArray *selectArray = [NSMutableArray array]; //选中按钮的数组
    NSMutableArray *textArray = [NSMutableArray array];
    
    if(btn.isSelected) {
        NSInteger index = [self indexOfDictionary:rowDic];
        NSArray *array = [[selectMatchArray objectAtIndex:index] objectForKey:kSelectedChangInfo];
        
        textArray = [NSMutableArray arrayWithArray:[[selectMatchArray objectAtIndex:index] objectForKey:@"selectTextArray"]];
        
        selectArray = [NSMutableArray arrayWithArray:array];
        [selectArray removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
        if(selectArray.count == 0) {
            [selectMatchArray removeObjectAtIndex:index];
        } else {
            [[selectMatchArray objectAtIndex:index] setObject:selectArray forKey:kSelectedChangInfo];
            [self updateTextArray:textArray rowDict:rowDic selectNumberArray:selectArray];
            if ([selectMatchArray count] > index && [selectMatchArray objectAtIndex:index]) {
                [[selectMatchArray objectAtIndex:index] setObject:textArray forKey:@"selectTextArray"];
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
            [dic setObject:textArray forKey:@"selectTextArray"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_basketBallPlayType] forKey:@"selectType"];
            [selectMatchArray replaceObjectAtIndex:index withObject:dic];
        } else {
            
            [selectArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            
            [self updateTextArray:textArray rowDict:rowDic selectNumberArray:selectArray];
            
            [dic setObject:rowDic forKey:@"selectRowDic"];
            [dic setObject:selectArray forKey:kSelectedChangInfo];
            [dic setObject:indexPath forKey:@"selectIndexPath"];
            [dic setObject:textArray forKey:@"selectTextArray"];
            [dic setObject:[NSString stringWithFormat:@"%ld",(long)_basketBallPlayType] forKey:@"selectType"];
            [selectMatchArray addObject:dic];
        }
        [btn setSelected:YES];
    }
    
    [matchTableList reloadData];
    [self updateBottomViewDisplay:[selectMatchArray count]];
    
}

- (void)mixAllTouchUpInside:(id)sender {
    /********************** adjustment 控件调整 ***************************/
    CGFloat selectViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat selectViewHeight = kWinSize.height - (IS_PHONE ? 70.0f : 200.0f);
    /********************** adjustment end ***************************/
    CGRect dialogSelectButtonViewRect = CGRectMake(0, 0, selectViewWidth, selectViewHeight);
    [self showDialogSelectViewWithFrame:dialogSelectButtonViewRect touchBtn:sender dialogType:DialogBasketBallMix];
}

- (void)showDialogSelectViewWithFrame:(CGRect)dialogSelectFrame touchBtn:(id)touchBtn dialogType:(DialogType)dialogType{
    NSIndexPath *indexPath = [self findButtonIndexPathWithTheButton:touchBtn];
    NSDictionary *rowDic = [self findRowDictWithIndexPath:indexPath];
    
    NSInteger index = [self indexOfDictionary:rowDic];
    
    NSDictionary *dict;
    if(index >= 0) {
        dict = [[self getSelectMatchArrayWithType:_basketBallPassBarrierType] objectAtIndex:index];
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

//下拉按钮
- (void)dropDownListTouchUpInside:(id)sender {
    UIButton *btn = sender;
    //获取选中section的 下拉状态字典
    NSMutableDictionary *dic = [[self getDropDictWithType:_basketBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    if(btn.isSelected) {
        //如果已经选中 再次点击  收回
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isDropDown"];
    } else {
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
    }
    [dic setObject:[NSNumber numberWithInteger:btn.tag] forKey:@"dropSection"];
    [[self getDropDictWithType:_basketBallPassBarrierType] setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    
    [[self getMatchTableListWithType:_basketBallPassBarrierType] reloadData];
}

- (void)unfoldBetViewTouchUpInside:(id)sender {
    /********************** adjustment 控件调整 ***************************/
    CGFloat selectViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat selectViewHeight = IS_PHONE ? 350.0f : 600.0f;
    /********************** adjustment end ***************************/
    CGRect selectViewRect = CGRectMake(0, 0, selectViewWidth, selectViewHeight);
    [self showDialogSelectViewWithFrame:selectViewRect touchBtn:sender dialogType:DialogBasketBallMinusScore];
}

#pragma mark -Customized: Private (General)
- (void)getPlayMethods {
    [GlobalsProject firstTypePlayIdWithTicketTypeName:self.title betTypeArray:_playMethodArray];
}

- (void)updateBottomViewDisplay:(NSInteger)count {
    if (count > 0) {
        [_bottomView setTextWithMatchCount:count hasMatch:YES];
    } else {
        if (_basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
            [_bottomView setTextWithMatchCount:1 hasMatch:NO];
        } else {
            [_bottomView setTextWithMatchCount:2 hasMatch:NO];
        }
    }
}

- (void)refreshMatchArray {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    
    NSInteger count = selectMatchArray.count;
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (int i = 0; i < count;i++) {
        NSArray *array = [[selectMatchArray objectAtIndex:i] objectForKey:@"selectArray"];
        if(array.count == 0) {
            [tempArray addObject:[selectMatchArray objectAtIndex:i]];
        }
    }
    
    [selectMatchArray removeObjectsInArray:tempArray];
}

- (NSMutableDictionary *)findDictInSelectMatchArray:(NSMutableArray *)matchArray indexPath:(NSIndexPath *)indexPath {
    for (NSMutableDictionary *dict in matchArray) {
        NSIndexPath *dictIndexPath = (NSIndexPath *)[dict objectForKey:@"selectIndexPath"];
        if ([dictIndexPath isEqual:indexPath]) {
            return dict;
        }
    }
    return nil;
}

- (BOOL)isTheNumberOrTagInArray:(NSMutableArray *)numberArray number:(NSInteger)number {
    if (numberArray == nil) {
        return NO;
    }
    for (NSNumber *arrayNumber in numberArray) {
        if ([arrayNumber integerValue] == number) {
            return YES;
        }
    }
    return NO;
}

- (void)updateTextArray:(NSMutableArray *)textArray rowDict:(NSDictionary *)rowDict selectNumberArray:selectNumberArray {
    DialogSelectButtonView *dialogSelectButtonView = [[DialogSelectButtonView alloc] initWithMatchDict:rowDict selectNumberArray:selectNumberArray];
    [dialogSelectButtonView setDialogType:DialogBasketBallMix];
    [dialogSelectButtonView setSelectMatchTextWithTextArray:textArray];
    [dialogSelectButtonView release];
}

- (void)replaceButtonTextWithArray:(NSArray *)array AtIndex:(NSIndexPath *)indexPath {
    CustomFootBallMainCell *cell = (CustomFootBallMainCell *)[[self getMatchTableListWithType:_basketBallPassBarrierType] cellForRowAtIndexPath:indexPath];
    
    for (UIView *view in cell.buttonImageView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:[self convertArrayToString:array] forState:UIControlStateNormal];
        }
    }
}

- (NSIndexPath *)findButtonIndexPathWithTheButton:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    NSIndexPath *indexPath = [[self getMatchTableListWithType:_basketBallPassBarrierType] indexPathForCell:cell];
    return indexPath;
}

- (NSMutableDictionary *)findRowDictWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [[self getMatchDictWithType:_basketBallPassBarrierType] objectForKey:[NSString stringWithFormat:@"table%ld",(long)indexPath.section + 1]];
    NSMutableDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
    return rowDic;
}

- (NSString *)convertArrayToString:(NSArray *)array {
    if (array.count == 0) {
        if (_basketBallPlayType == BasketBallPlayType_minusScore) {
            return @"点击展开投注区";
        }
    }
    
    NSString *result = [NSString string];
    if (_basketBallPlayType == BasketBallPlayType_minusScore) {
        for (NSString *numberString in array) {
            result = [result stringByAppendingFormat:@"%@ ",numberString];
        }
    }
    
    return result;
}

- (NSInteger)indexOfDictionary:(NSDictionary *)dic {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    for (NSDictionary *matchDics in selectMatchArray) {
        if([[matchDics objectForKey:@"selectRowDic"] isEqualToDictionary:dic]) {
            return [selectMatchArray indexOfObject:matchDics];
        }
    }
    return -1;
}

- (BOOL)isArrayContainsDictionary:(NSDictionary *)dic {
    NSMutableArray *selectMatchArray = [self getSelectMatchArrayWithType:_basketBallPassBarrierType];
    for (NSDictionary *matchDics in selectMatchArray) {
        if([[matchDics objectForKey:@"selectRowDic"] isEqualToDictionary:dic]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasMatchWithMatchDict:(NSDictionary *)matchDict basketBallPlayType:(BasketBallPlayType)basketBallPlayType {
    if ([matchDict objectForKey:@"table1"]) {
        NSArray * oneTabelMatchArray = [matchDict objectForKey:@"table1"];
        if ([oneTabelMatchArray count] > 0) { //后台的逻辑是一般第一个没有其他都没有
            NSDictionary *oneMatchMessageDict = [oneTabelMatchArray objectAtIndex:0];
            if (basketBallPlayType == BasketBallPlayType_mix) {
                return YES;
                
            } else {
                if (![[oneMatchMessageDict objectForKey:[self serverKeyStringWithType:basketBallPlayType]] isEqualToString:@"True"]) {
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

- (void)filterMatchesWithServerKey:(NSString *)serverKey basketBallPassBarrierType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        [_matchDict release];
        _matchDict = [[NSMutableDictionary alloc] init];
        
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        [_singleMatchDict release];
        _singleMatchDict = [[NSMutableDictionary alloc] init];
        
    }
    
    [self filterMatchesWithCompleteMatchDict:[self getCompleteMatchDictWithType:basketBallPassBarrierType] matchDict:[self getMatchDictWithType:basketBallPassBarrierType] serverKey:serverKey];
}

- (void)filterMatchesWithCompleteMatchDict:(NSDictionary *)completeMatchDict matchDict:(NSMutableDictionary *)matchDict serverKey:(NSString *)serverKey {
    NSInteger signIndex = 0;
    for (NSInteger tableIndex = 0; tableIndex < completeMatchDict.count; tableIndex++) {
        NSDictionary *tableDict = [completeMatchDict objectForKey:[NSString stringWithFormat:@"table%ld",(long)(tableIndex + 1)]];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *matchMessageDict in tableDict) {
            if ([serverKey isEqualToString:[self serverKeyStringWithType:BasketBallPlayType_mix]]) {
                
                if ([[matchMessageDict objectForKey:[self serverKeyStringWithType:BasketBallPlayType_winLose]] isEqualToString:@"True"] ||[[matchMessageDict objectForKey:[self serverKeyStringWithType:BasketBallPlayType_letWinLose]] isEqualToString:@"True"] ||[[matchMessageDict objectForKey:[self serverKeyStringWithType:BasketBallPlayType_minusScore]] isEqualToString:@"True"] ||[[matchMessageDict objectForKey:[self serverKeyStringWithType:BasketBallPlayType_BigSmallScore]] isEqualToString:@"True"]) {
                    [tempArray addObject:matchMessageDict];
                }
                
            } else {
                if ([[matchMessageDict objectForKey:serverKey] isEqualToString:@"True"]) {
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

- (void)selectSetFrameWithType:(NSInteger)selectType {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    if (_basketBallPlayType == BasketBallPlayType_mix) {
        [_matchTypeCustomSegmentedControl setHidden:YES];
        [_basketBallScrollView setFrame:CGRectMake( 0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f * 2)];
        [_basketBallScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 1, CGRectGetWidth(appRect))];
        _basketBallPassBarrierType = BasketBallPassBarrierType_moreMatch;
        [_basketBallScrollView setShowsHorizontalScrollIndicator:YES];
        
    } else {
        [_matchTypeCustomSegmentedControl setHidden:NO];
        [_matchTypeCustomSegmentedControl setSelectedSegmentIndex:0];
        [_basketBallScrollView setFrame:CGRectMake( 0, 0 + BasketBallViewMatchTypeCustomSegmentedControl, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f * 2 - BasketBallViewMatchTypeCustomSegmentedControl)];
        [_basketBallScrollView setContentSize:CGSizeMake(CGRectGetWidth(appRect) * 2, CGRectGetWidth(appRect))];
        _basketBallPassBarrierType = BasketBallPassBarrierType_moreMatch;
        [_basketBallScrollView setShowsHorizontalScrollIndicator:NO];
    }
    CGRect matchTableListRect = _matchTableList.frame;
    [_matchTableList setFrame:CGRectMake(CGRectGetMinX(matchTableListRect), CGRectGetMinY(matchTableListRect), CGRectGetWidth(matchTableListRect), CGRectGetHeight(_basketBallScrollView.frame))];
}

- (NSString *)serverKeyStringWithType:(BasketBallPlayType)basketBallPlayType {
    switch (basketBallPlayType) {
        case BasketBallPlayType_winLose:
            return @"isSF";
            break;
        case BasketBallPlayType_letWinLose:
            return @"isRFSF";
            break;
        case BasketBallPlayType_minusScore:
            return @"isSFC";
            break;
        case BasketBallPlayType_BigSmallScore:
            return @"isDXF";
            break;
        case BasketBallPlayType_mix:
            return @"mix";
            break;
            
        default:
            break;
    }
    
    return @"";
}

- (UITableView *)getMatchTableListWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _matchTableList;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleMatchTableList;
    }
    return nil;
}

- (UILabel *)getMatchPromptLabelWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _matchPromptLabel;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleMatchPromptLabel;
    }
    return nil;
}

- (NSMutableDictionary *)getDropDictWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _dropDict;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleDropDict;
    }
    return nil;
}

- (NSMutableDictionary *)getMatchDictWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _matchDict;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleMatchDict;
    }
    return nil;
}

- (NSDictionary *)getTempDictWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _tempDict;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleTempDict;
    }
    return nil;
}

- (NSDictionary *)getCompleteMatchDictWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _completeMatchDict;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleCompleteMatchDict;
    }
    return nil;
}

- (NSDictionary *)getFilterMatchDictWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _filterMatchDict;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleFilterMatchDict;
    }
    return nil;
}

- (NSMutableArray *)getSelectMatchArrayWithType:(BasketBallPassBarrierType)basketBallPassBarrierType {
    if (basketBallPassBarrierType == BasketBallPassBarrierType_moreMatch) {
        return _selectMatchArray;
    } else if (basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) {
        return _singleSelectMatchArray;
    }
    return nil;
}

//跟getArrayIndexWithBasketBallBetSelectType:对应
- (BasketBallPlayType)getBasketBallBetSelectTypeWithIndex:(NSInteger)index {
    switch (index) {
        case 1:
            return BasketBallPlayType_winLose;
            break;
        case 2:
            return BasketBallPlayType_letWinLose;
            break;
        case 3:
            return BasketBallPlayType_minusScore;
            break;
        case 4:
            return BasketBallPlayType_BigSmallScore;
            break;
        case 0:
            return BasketBallPlayType_mix;
            break;
            
        default:
            break;
    }
    
    return BasketBallPlayType_no;
}

//跟getBasketBallBetSelectTypeWithIndex:对应
- (NSInteger)getArrayIndexWithBasketBallBetSelectType:(BasketBallPlayType)basketBallPlayType {
    
    switch (basketBallPlayType) {
        case BasketBallPlayType_winLose:
            return 1;
            break;
        case BasketBallPlayType_letWinLose:
            return 2;
            break;
        case BasketBallPlayType_minusScore:
            return 3;
            break;
        case BasketBallPlayType_BigSmallScore:
            return 4;
            break;
        case BasketBallPlayType_mix:
            return 0;
            break;
            
        default:
            break;
    }
    return 101;
}

@end
