//
//  RJXViewController.m 购彩大厅－任选九选号
//  TicketProject
//
//  Created by sls002 on 13-6-4.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140924 10:11（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140924 10:43（洪晓彬）：进行ipad适配

#import "RJXViewController.h"
#import "CustomSFCTableViewCell.h"
#import "RJXBetViewController.h"
#import "XFTabBarViewController.h"
#import "HelpViewController.h"
#import "SelectBallBottomView.h"
#import "XFNavigationViewController.h"

#import "AwardInfo.h"
#import "CalculateBetCount.h"
#import "Globals.h"
#import "RJCParserNumber.h"
#import "Header.h"
#import "MyTool.h"

#define kMatchCount 14
#define RJXViewControllerTabelCellHeight (IS_PHONE ? 64.0f : 94.0f)

@interface RJXViewController ()

@end
#pragma mark -
#pragma mark @implementation RJXViewController
@implementation RJXViewController
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
        _selectRowIndex = index;
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
    [self setTitle:@"任选九"];
    _lotteryID = 75;
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
    [_matchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_matchTableView setDataSource:self];
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
        _selectMatchDic = [[NSMutableDictionary alloc] initWithDictionary:[_selectedBallsDic objectForKey:kSelectMatchDic]];
    }
    
    [self getMatchInfo];
    
    if(_selectedBallsDic != nil) {
        int count = [(NSNumber *)[_selectedBallsDic objectForKey:kBetCount]intValue];
        [_bottomView setTextWithCount:count money:count * 2];
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
    static NSString *cellIdentifier = @"CustomRJXViewCell";
    CustomSFCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[CustomSFCTableViewCell alloc] initWithCellHight:RJXViewControllerTabelCellHeight reuseIdentifier:cellIdentifier] autorelease];
    }
    BOOL needChangeColor = NO;

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
    [cell.contentView setBackgroundColor:needChangeColor ? [UIColor lightGrayColor] : [UIColor clearColor]];
    for (int i = 0; i < 3; i++) {
        CGRect btnRect = CGRectMake(btnMinX + i * (btnWidth + btnLandscapeInterval + AllLineWidthOrHeight), btnMinY, btnWidth, btnHeight);
        UIButton *btn = [[UIButton alloc] initWithFrame:btnRect];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn setTitleColor:[UIColor colorWithRed:0x65/255.0f green:0x65/255.0f blue:0x65/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setUserInteractionEnabled:!needChangeColor];
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
        [cell.contentView addSubview:btn];
        [btn release];
        
        if (i < 2) {
            CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
            UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
            [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
            [cell.contentView addSubview:lineView];
            [lineView release];
        }
    }
    return cell;
}

#pragma mark -UITableViewDelegate
//tableView滚动时 重用cell会刷掉已选的
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    
    for (NSString *str in array) {
        //机选的比赛  反选判断
        if([str isEqualToString:@"-"]) {
            continue;
        }
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RJXViewControllerTabelCellHeight;
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
    //选择场数不能小于9场
    if([self queryMatchCount] < 9){
        [Globals alertWithMessage:@"选择场数不能小于9场"];
        return;
    }
    
    NSInteger betCount = [self calculateBetCount];
    //注数为0  无法提交
    if(betCount == 0) {
        return;
    }
    if(betCount > 50000) {
        [Globals alertWithMessage:@"购买金额不能超过100000元"];
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[RJCParserNumber getRJCTextWithDict:_selectMatchDic matchCount:kMatchCount] forKey:kSelectBalls];
    [dic setObject:_selectBetType forKey:kBetType];
    [dic setObject:[NSNumber numberWithInteger:betCount] forKey:kBetCount];
    [dic setObject:_selectMatchDic forKey:kSelectMatchDic];
    
    RJXBetViewController *betViewControllers = [[RJXBetViewController alloc]initWithMatchArray:[_lotteryDic objectForKey:@"dtMatch"] andScoreDic:dic LotteryDic:_lotteryDic];
    
    [self.navigationController pushViewController:betViewControllers animated:YES];
    [betViewControllers release];
}

#pragma mark -
#pragma mark -Customized(Action)
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
        [_matchTableView reloadData];
        return;
    }
    
    [self addSelectedItemWithValue:[NSString stringWithFormat:@"%ld", (long)btn.tag] RowIndex:selectIndex];
    
    [btn setSelected:YES];
    [self showBetCount];
    [_matchTableView reloadData];
}

#pragma mark -Customized: Private (General)
//没有选择的比赛 用"-"填充字典
- (void)addPlaceHolderToDic {
    for (int i = 0; i < kMatchCount; i++) {
        if(![self isMatchExistsWithIndex:i]) {
            NSArray *array = [NSArray arrayWithObject:@"-"];
            [_selectMatchDic setObject:array forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
}

//检查某一场比赛 有没有选
- (BOOL)isMatchExistsWithIndex:(NSInteger)index {
    BOOL isExists = NO;
    for (NSString *keyStr in _selectMatchDic.allKeys) {
        if([[NSString stringWithFormat:@"%ld",(long)index] isEqualToString:keyStr] && [[_selectMatchDic objectForKey:keyStr] count] > 0) {
            isExists = YES;
        }
    }
    return isExists;
}

- (int)queryMatchCount {
    int count = 0;
    for (NSArray *arr in [_selectMatchDic allValues]) {
        for (NSString *str in arr) {
            if (![str isEqualToString:@"-"]) {
                count++;
                break;
            }
        }
    }
    return count;
}

//显示注数
- (void)showBetCount {
    NSInteger count = [self calculateBetCount];
    [_bottomView setTextWithCount:count money:count * 2];
}

//计算注数
- (NSInteger)calculateBetCount {
    if ([self queryMatchCount] < 9) {
        return 0;
    }
    return [RJCParserNumber getCountForRJXWithSelectMatchDic:_selectMatchDic];
}

//检查比赛还能不能被选中  不能超过9场
- (BOOL)checkMatchCanSelectedWithRowIndex:(NSInteger)index {
    if ([self queryMatchCount] < 9) {
        return YES;
    }
    //这一行已被选中，刚好九场
    NSArray *arr = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    for (NSString *str in arr) {
        if (![str isEqualToString:@"-"]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)makeOverlayView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat promptWidth = IS_PHONE ? 150.0f : 280.0f;
    
    CGFloat overlayViewHeight = IS_PHONE ? 30.0f : 60.0f;
    
    CGFloat labelHeight = IS_PHONE ? 20.0f : 30.0f;
    /********************** adjustment end ***************************/
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if(_overlayView == nil){
        CGRect overlayViewRect = CGRectMake(0, 0, promptWidth, overlayViewHeight);
        _overlayView = [[UIView alloc]initWithFrame:overlayViewRect];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:1];
        [keyWindow addSubview:_overlayView];
        [_overlayView release];
        
        CGRect labelRect = CGRectMake(0, 0, promptWidth, labelHeight);
        UILabel *lb = [[UILabel alloc]initWithFrame:labelRect];
        lb.backgroundColor = [UIColor clearColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
        lb.text = @"最多只能选择9场";
        lb.tag = 1;
        lb.textColor = [UIColor whiteColor];
        [lb setCenter:_overlayView.center];
        [_overlayView addSubview:lb];
        [lb release];
        
        [_overlayView setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
        [self performSelector:@selector(removeOverlayView:) withObject:nil afterDelay:1.0];
    }
}

- (void)removeOverlayView:(UIView *)lb {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

- (void)removeSelectedItemWithValue:(NSString *)value RowIndex:(NSInteger)index {
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    NSMutableArray *arrTemp = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if ([arrTemp count] > 0) {
        [selectedArray addObjectsFromArray:arrTemp];
    }
    
    [selectedArray removeObject:value];
    
    [_selectMatchDic setObject:selectedArray forKey:[NSString stringWithFormat:@"%ld",(long)index]];

}

- (void)addSelectedItemWithValue:(NSString *)value RowIndex:(NSInteger)index {
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    NSMutableArray *arrTemp = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if ([arrTemp count] > 0) {
        [selectedArray addObjectsFromArray:arrTemp];
    }
    if (value) {
        [selectedArray addObject:value];
    }
    
    [_selectMatchDic setObject:selectedArray forKey:[NSString stringWithFormat:@"%ld",(long)index]];
}

//获取比赛对阵信息
- (void)getMatchInfo {
    AwardInfo *award = [[[AwardInfo alloc]init]autorelease];
    
    NSInteger lotteryid = [[_lotteryDic objectForKey:@"lotteryid"] integerValue];
    _matchList = [[award getAwardInfoWithLotteryId:lotteryid] retain];
}

@end