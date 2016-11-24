//
//  SFCViewController.m 购彩大厅－胜负彩选号
//  TicketProject
//
//  Created by sls002 on 13-6-3.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140922 15:44（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140923 10:30（洪晓彬）：进行ipad适配

#import "SFCViewController.h"
#import "CustomSFCTableViewCell.h"
#import "AwardInfo.h"
#import "CalculateBetCount.h"
#import "Header.h"
#import "HelpViewController.h"
#import "SelectBallBottomView.h"
#import "SFCBetViewController.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "MyTool.h"
#import "SFCParserNumber.h"


#define SFCViewControllerTabelCellHeight (IS_PHONE ? 65.0f : 94.0f)

@interface SFCViewController ()

@end

#pragma mark -
#pragma mark @implementation SFCViewController
@implementation SFCViewController
@synthesize delegate = _delegate;
#pragma mark Lifecircle

//从购彩大厅 进入时调用  参数为该彩种信息的字典
- (id)initWithInfoData:(NSObject *)infoData {
    self = [super  init];
    if(self) {
        _lotteryDic = [(NSDictionary *)infoData retain];
    }
    return self;
}

//详细信息
- (id)initWithSelectedBallsDic:(NSDictionary *)ballsDic LotteryDic:(NSDictionary *)dic {
    self = [super init];
    if(self) {
        _selectedBallsDic = [ballsDic retain];
        _lotteryDic = [dic retain];
    }
    return self;
}

- (void)dealloc {
    _matchTableView = nil;
    _bottomView = nil;
    
    [_matchList release];
    [_selectMatchDic release];
    [_betViewController release];
    [_selectedBallsDic release];
    [_lotteryDic release];
    
    [super dealloc];
}

- (void)loadView {
    [self setTitle:@"胜负彩"];
    _lotteryID = 74;
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
	[baseView release];
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    /********************** adjustment end ***************************/
    
    //playingMethodBtn 帮助按钮
    CGRect playingMethodBtnRect = XFIponeIpadNavigationplayingMethodButtonRect;
    UIButton *playingMethodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playingMethodBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"playingMethod.png"]] forState:UIControlStateNormal];
    [playingMethodBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"playingMethod.png"]] forState:UIControlStateHighlighted];
    [playingMethodBtn setFrame:playingMethodBtnRect];
    [playingMethodBtn addTarget:self action:@selector(getHelp:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *playingMethodItem = [[UIBarButtonItem alloc]initWithCustomView:playingMethodBtn];
    [self.navigationItem setRightBarButtonItem:playingMethodItem];
    [playingMethodItem release];
    
    //matchTableView
    _matchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWinSize.width, CGRectGetHeight(appRect) - kBottomHeight -44.0f) style:UITableViewStylePlain];
    [_matchTableView setBackgroundColor:kBackgroundColor];
    [_matchTableView setDataSource:self];
    [_matchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_matchTableView setDelegate:self];
    [self.view addSubview:_matchTableView];
    [_matchTableView release];
    
    //bottomView 底部视图
    _bottomView = [[SelectBallBottomView alloc]initWithBackImage:[UIImage imageNamed:@""]];
    [_bottomView setDelegate:self];
    [_bottomView setbetCountLabelCenterAddX:0 AddY:3];
    [self.view addSubview:_bottomView];
    [_bottomView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHidesBottomBarWhenPushed:YES];
    [self.xfTabBarController setTabBarHidden:YES];
    
    
    [self.view setBackgroundColor:kBackgroundColor];
    
    _selectBetType = @"普通投注";
    
    if(_selectedBallsDic == nil) {
        _selectMatchDic = [[NSMutableDictionary alloc]init];
    } else {
        _selectMatchDic = [[NSMutableDictionary alloc]initWithDictionary:[_selectedBallsDic objectForKey:kSelectMatchDic]];
    }
    
    [self getMatchInfo];
    
    if(_selectedBallsDic != nil) {
        int count = [(NSNumber *)[_selectedBallsDic objectForKey:kBetCount]intValue];
        [_bottomView setTextWithCount:count money:count * 2];
    } else {
        [self showBetCount];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _matchTableView = nil;
        _bottomView = nil;
        
        [_matchList release];
        self.view = nil;
    }
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _matchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomSFCViewCell";
    CustomSFCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[CustomSFCTableViewCell alloc] initWithCellHight:SFCViewControllerTabelCellHeight reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //重用机制  清除重用btn选择状态
    if(cell != nil) {
        for (UIView *view in cell.contentView.subviews) {
            if([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
    }
    /********************** adjustment 控件调整 ***************************/
    CGRect cellSecondColLabelFrame = cell.hostTeamLabelFrame;
    
    CGFloat btnMaginLeftRight = IS_PHONE ? 10.0f : 30.0f;
    CGFloat btnMinX = CGRectGetMinX(cellSecondColLabelFrame);
    CGFloat btnMinY = IS_PHONE ? 30.0f : 38.0f;
    CGFloat btnLandscapeInterval = IS_PHONE ? 0.0f : 20.0f;
    CGFloat btnWidth = (CGRectGetWidth(tableView.frame) - btnMinX - btnMaginLeftRight - btnLandscapeInterval * 2.0f) / 3.0f;
    CGFloat btnHeight = IS_PHONE ? 30.0f : 45.0f;
    /********************** adjustment end ***************************/
    NSDictionary *matchDic = [_matchList objectAtIndex:indexPath.row];
    NSString *stopTime = [matchDic stringForKey:@"datetime"];
    
    NSArray *timeArray = [stopTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSString *stopTimeStr = @"";
    if ([timeArray count] >= 2) {
        stopTimeStr = [NSString stringWithFormat:@"%@ 开赛",[timeArray objectAtIndex:1]];
    }
    
    cell.hostTeamName = [matchDic objectForKey:@"hostTeam"];
    cell.guestTeamName = [matchDic objectForKey:@"questTeam"];
    cell.matchNumber = [matchDic objectForKey:@"matchnumber"];;
    cell.matchTime = stopTimeStr;
    cell.game = [matchDic objectForKey:@"game"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; //取消cell的选中效果
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(btnMinX + i * (btnWidth + btnLandscapeInterval + AllLineWidthOrHeight), btnMinY, btnWidth, btnHeight)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn setTitleColor:[UIColor colorWithRed:0x65/255.0f green:0x65/255.0f blue:0x65/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *title = [NSString string];
        switch (i) {
            case 0:
                title = [NSString stringWithFormat:@"胜%@",[matchDic objectForKey:@"s"]];
                btn.tag = 3;
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                break;
            case 1:
                title = [NSString stringWithFormat:@"平%@",[matchDic objectForKey:@"p"]];
                btn.tag = 1;
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
                break;
            case 2:
                title = [NSString stringWithFormat:@"负%@",[matchDic objectForKey:@"f"]];
                btn.tag = 0;
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                break;
            default:
                break;
        }
        [btn setTitle:title forState:UIControlStateNormal];
        if (i < 2) {
            CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
            UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
            [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
            [cell.contentView addSubview:lineView];
            [lineView release];
        }
        [cell.contentView addSubview:btn];
    }
    return cell;
}

#pragma mark -UITableViewDelegate
//tableView滚动时 重用cell会刷掉已选的
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    for (NSString *str in array) {
        for (UIView *view in cell.contentView.subviews) {
            if([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                if([[NSString stringWithFormat:@"%ld", (long)btn.tag] isEqualToString:str]) {
                    [btn setSelected:YES];
                }
            }
        }
    }
}

//cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SFCViewControllerTabelCellHeight;
}

#pragma mark -BottomViewDelegate
//清空选球
- (void)clearBalls {
    [self.selectMatchDic removeAllObjects];
    [_matchTableView reloadData];
    [self showBetCount];
}

//提交选球
- (void)submitBalls {
    NSString *formateSelectBalls = [SFCParserNumber getSFCTextWithDict:_selectMatchDic];
    
    NSInteger betCount = [SFCParserNumber getCountForSFCWithSelectMatchDic:_selectMatchDic];
    //注数为0  无法提交
    if(betCount == 0) {
        return;
    }
    if(betCount > 50000) {
        [Globals alertWithMessage:@"购买金额不能超过100000元"];
        return;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:formateSelectBalls forKey:kSelectBalls];
    [dic setObject:_selectBetType forKey:kBetType];
    [dic setObject:[NSNumber numberWithInteger:betCount] forKey:kBetCount];
    [dic setObject:_selectMatchDic forKey:kSelectMatchDic];
    
    SFCBetViewController *betViewControllers = [[SFCBetViewController alloc]initWithMatchArray:[_lotteryDic objectForKey:@"dtMatch"] andScoreDic:dic LotteryDic:_lotteryDic];
    
    [self.navigationController pushViewController:betViewControllers animated:YES];
    [betViewControllers release];
}

#pragma mark -
#pragma mark -Customized(Action)
//点击按钮
- (void)buttonSelected:(id)sender {
    UIButton *btn = sender;
    
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    
    NSInteger selectIndex = [_matchTableView indexPathForCell:cell].row;
    
    if(btn.isSelected) {
        [self removeSelectedItemWithValue:[NSString stringWithFormat:@"%ld", (long)btn.tag] RowIndex:selectIndex];
        [self showBetCount];
        
        [btn setSelected:NO];
        return;
    }
    
    [self addSelectedItemWithValue:[NSString stringWithFormat:@"%ld", (long)btn.tag] RowIndex:selectIndex];
    [self showBetCount];
    [btn setSelected:YES];
}

//玩法介绍
- (void)getHelp:(id)sender {
    HelpViewController *helpViewController = [[HelpViewController alloc]initWithLotteryId:_lotteryID];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:helpViewController];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [helpViewController release];
    [nav release];
}

//点击取消按钮
- (void)dismissViewController:(id)sender {
    if(_betViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -Customized: Private (General)
//显示注数
- (void)showBetCount {
    NSInteger count = [SFCParserNumber getCountForSFCWithSelectMatchDic:_selectMatchDic];
    [_bottomView setTextWithCount:count money:count * 2];
}

- (void)removeSelectedItemWithValue:(NSString *)value RowIndex:(NSInteger)index {
    NSMutableArray *selectedArray = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if(selectedArray == nil){
        return;
    }
    [selectedArray removeObject:value];
    
    [_selectMatchDic setObject:selectedArray forKey:[NSString stringWithFormat:@"%ld",(long)index]];
}

- (void)addSelectedItemWithValue:(NSString *)value RowIndex:(NSInteger)index {
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    NSMutableArray *arrTemp = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if ([arrTemp count]>0) {
        [selectedArray addObjectsFromArray:arrTemp];
    }
    
    if (value) {
        [selectedArray addObject:value];
    }
    
    [_selectMatchDic setObject:selectedArray forKey:[NSString stringWithFormat:@"%ld",(long)index]];
}

//获取比赛对阵信息
- (void)getMatchInfo {
    AwardInfo *award = [[AwardInfo alloc]init];
    
    NSInteger lotteryid = [[_lotteryDic objectForKey:@"lotteryid"] integerValue];
    _matchList = [[award getAwardInfoWithLotteryId:lotteryid] retain];
    [award release];
}

@end
