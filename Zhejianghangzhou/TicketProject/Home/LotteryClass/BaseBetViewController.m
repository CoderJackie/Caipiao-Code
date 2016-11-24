//
//  BaseBetViewController.m 购彩大厅－投注基本界面
//  TicketProject
//
//  Created by Michael on 8/31/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//
//  20141008 11:42（洪晓彬）：修改代码规范，改进生命周期，处理各种内存问题
//  20141008 14:31（洪晓彬）：进行ipad适配
//  20150820 12:05（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#define kAutoSelectRedBallCount             6
#define kAutoSelectBlueBallCount            1
#define kAutoSelectRedMaxNumber             33
#define kAutoSelectBlueMaxNumber            16

#import "BaseBetViewController.h"
#import "BetButtomView.h"
#import "BetTableViewCell.h"
#import "BetRuleViewController.h"
#import "HomeViewController.h"
#import "LaunchChippedViewController.h"
#import "SetIssueAndTimeView.h"
#import "SetIssueAndTimeView.h"
#import "SelectRechargeTypeViewController.h"
#import "PaySucceedViewController.h"
#import "UserLoginViewController.h"
#import "XFNavigationViewController.h"

#import "CalculateBetCount.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import "Header.h"
#import "RandomNumber.h"
#import "Service.h"
#import "UserInfo.h"
#import "DuangAlert.h"

@interface BaseBetViewController ()

@property(nonatomic, assign)Service * oneS;
@property(nonatomic,copy)NSString *allstr;

@end

#pragma mark -
#pragma mark @implementation BaseBetViewController
@implementation BaseBetViewController
#pragma mark Lifecircle

- (id)initWithBallsInfoDic:(NSMutableDictionary *)infoDic LotteryDic:(NSDictionary *)dic isSupportShake:(BOOL)flag {
    self = [super init];
    if(self) {
        _betInfoDic = [infoDic retain];
        _lotteryDic = [dic retain];
        _isSupportShake = flag;
        _hasChaseView = NO;
        _hasWinStopView = YES;
        
    }
    return self;
}

- (id)initWithBallsInfoDic:(NSMutableDictionary *)infoDic LotteryDic:(NSDictionary *)dic isSupportShake:(BOOL)flag isRecordView:(BOOL)isRecordView {
    self = [super init];
    if(self) {
        _isRecordView = isRecordView;
        _betInfoDic = [infoDic retain];
        _lotteryDic = [dic retain];
        _isSupportShake = flag;
        _hasChaseView = NO;
        _hasWinStopView = YES;
    }
    return self;
}

- (id)initWithBallsInfoDic:(NSMutableDictionary *)infoDic LotteryDic:(NSDictionary *)dic {
    self = [super init];
    if(self) {
        self.betInfoDic = [infoDic retain];
        _lotteryDic = [dic retain];
    }
    return self;
}

- (void)dealloc {
    _tableViews = nil;
    _autoAddBtn = nil;
    _bottomView = nil;
    _issueView = nil;
    _secrecyLevel = nil;
    _description = nil;
    
    [_launchChippedProportionRequest release];
    _launchChippedProportionRequest = nil;;
    
    [_orderDetailDict release];
    [_betInfoDic release];
    [_lotteryDic release];
    
    [_dataRequest release];
    _dataRequest = nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
    UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
    [baseView release];
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat addBtnMinY = IS_PHONE ? 10.0f : 20.0f;
    CGFloat addBtnMarginLeftRight = IS_PHONE ? 15.0f : 30.0f;
    CGFloat addBtnWidth = (CGRectGetWidth(appRect) - addBtnMarginLeftRight * 3) / 2;
    CGFloat addBtnHeight = IS_PHONE ? 30.0f : 50.0f;
    
    CGFloat issueViewHeight = IS_PHONE ? 84.0f : 100.0f;
    if ([_lotteryDic intValueForKey:@"lotteryid"] == 74 || [_lotteryDic intValueForKey:@"lotteryid"] == 75) {
        issueViewHeight = 42.0f;
        _hasWinStopView = NO;
    }
    CGFloat tableViewAddY = 12.0f;
    /********************** adjustment end ***************************/
    
    //handAddBtn
    CGRect handAddBtnRect = CGRectMake(addBtnMarginLeftRight, addBtnMinY, addBtnWidth, addBtnHeight);
    UIButton *handAddBtn = [[UIButton alloc] initWithFrame:handAddBtnRect];
    [handAddBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"handAddBalls.png"]] forState:UIControlStateNormal];
    [handAddBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"handAddBalls.png"]] forState:UIControlStateHighlighted];
    [handAddBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"handAddBalls.png"]] forState:UIControlStateSelected];
    [handAddBtn addTarget:self action:@selector(handAddBalls:) forControlEvents:UIControlEventTouchUpInside];
    [handAddBtn setAdjustsImageWhenDisabled:NO];
    [handAddBtn setAdjustsImageWhenHighlighted:NO];
    [self.view addSubview:handAddBtn];
    [handAddBtn release];
    
    //autoAddBtn
    CGRect autoAddBtnRect = CGRectMake(CGRectGetWidth(appRect) - addBtnMarginLeftRight - addBtnWidth, CGRectGetMinY(handAddBtnRect), addBtnWidth, addBtnHeight);
    _autoAddBtn = [[UIButton alloc] initWithFrame:autoAddBtnRect];
    [_autoAddBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"autoAddBalls.png"]] forState:UIControlStateNormal];
    [_autoAddBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"autoAddBalls.png"]] forState:UIControlStateHighlighted];
    [_autoAddBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"autoAddBalls.png"]] forState:UIControlStateSelected];
    [_autoAddBtn addTarget:self action:@selector(autoAddBalls:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_autoAddBtn];
    [_autoAddBtn release];
    
    
    //tableViews
    CGRect tableViewsRect = CGRectMake(0, CGRectGetMaxY(handAddBtnRect) + tableViewAddY, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(handAddBtnRect) - kBottomHeight - issueViewHeight -44 - tableViewAddY);
    _tableViews = [[UITableView alloc]initWithFrame:tableViewsRect];
    [_tableViews setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    _tableViews.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViews.dataSource = self;
    _tableViews.delegate = self;
    [self.view addSubview:_tableViews];
    [_tableViews release];
    
    //issueView
    CGRect issueViewRect = CGRectMake(0, CGRectGetHeight(appRect) - issueViewHeight - kBottomHeight -44, CGRectGetWidth(appRect), issueViewHeight);
    _issueView = [[SetIssueAndTimeView alloc]initWithFrame:issueViewRect superView:self.view isDLT:_hasChaseView hasWinStopView:_hasWinStopView];
    [_issueView setMultiple:_multiple == 0 ? 1 : _multiple];
    _issueView.delegate = self;
    [self.view addSubview:_issueView];
    [_issueView release];
    
    //bottomView
    _bottomView = [[BetButtomView alloc]initWithBackImage:[UIImage imageNamed:@"singleMatchNormalBtn.png"]];
    _bottomView.delegate = self;
    [self.view addSubview:_bottomView];
    [_bottomView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"tongzhi" object:nil];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    
    _orderDetailDict = [[NSMutableDictionary alloc] init];
    
    self.oneS = [Service getDefaultService];
    self.oneS.baseBetViewController = self;

    // 服务器返回最多能追多少期,如果为空数组，则表明不能追期，返回1个表明
    self.chaseList = [_lotteryDic objectForKey:@"dtCanChaseIsuses"];
    
    [_bottomView didSelcet_once];
}

- (void)viewWillAppear:(BOOL)animated {
    _pushViewBegin = NO;
    [self updateBetCountOfBottomView];
    [_tableViews reloadData];
    
    _requestData = NO;
    if (self.betInfoDic.count > 0) {
        NSInteger countIndex = self.betInfoDic.count - 1;

        // 获得当前的玩法
        _playtype = [[self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)countIndex]] objectForKey:kBetType];
        _playMethodID = [[[self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)countIndex]] objectForKey:kPlayID] integerValue];
        _isSupportShake = [[[self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)countIndex]] objectForKey:kIsSupportShake] boolValue];
        [_autoAddBtn setHidden:!_isSupportShake];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _tableViews = nil;
        _autoAddBtn = nil;
        _bottomView = nil;
        _issueView = nil;
        
        [_dataRequest release];
        _dataRequest = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([_dataRequest isExecuting]){
        [_dataRequest cancel];
    }
    if (_launchChippedProportionRequest) {
        [_launchChippedProportionRequest clearDelegatesAndCancel];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setMultiple:(NSInteger)multiple {
    _multiple = multiple;
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([self.betInfoDic count] == 0) {
            return 1;
        } else {
            return [self.betInfoDic count];
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BetTableViewCell";
    BetTableViewCell *cell = (BetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CGFloat cellHeight = [self tableCellHeight:indexPath tableView:tableView];
    if (cell == nil) {
        cell = [[[BetTableViewCell alloc] initWithCellWidth:CGRectGetWidth(tableView.frame) Height:cellHeight Style:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        [cell setBackImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betCenter.png"]] stretchableImageWithLeftCapWidth:20.0f topCapHeight:20.0f]];
        
        UIButton *deleteBtn = [cell getDeleteButton];
        [deleteBtn addTarget:self action:@selector(deleteBetTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    CGRect cellAfterFrame = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), cellHeight);
    [cell setFrame:cellAfterFrame];
    [cell backImageViewFrame:cellAfterFrame];
    [cell setDeleteButtonFrameWithCellHeight:cellHeight];
    
    
    if (self.betInfoDic.count != 0) {
        [cell setLineWithCellHeight:cellHeight];
    }
    
    [[cell getDeleteButton] setTag:(self.betInfoDic.count - indexPath.row - 1)];
    
    NSDictionary *infoDic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)(self.betInfoDic.count - indexPath.row - 1)]];
    NSString *betNumber = [infoDic objectForKey:kSelectBalls];
    
    if ([self isDoubleColorText]) {
        cell.betNumberString = betNumber;
    } else {
        [cell setSelectedNumberString:betNumber];
    }
    
    cell.betTypeString = [self showPlayTypeNameWithPlayName:[infoDic objectForKey:kBetType]];
    int count = [[infoDic objectForKey:kBetCount] intValue];
    cell.betCountString = [NSString stringWithFormat:@"共%d注 %d元",count,count * 2];
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_pushViewBegin) {
        return;
    }
    if (self.betInfoDic.count == 0) {
        return;
    }
    NSInteger count = self.betInfoDic.count;
    //选中的记录  在self.betInfoDic中的顺序与indexpath.row相反
    NSDictionary *dic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld", (long)(count - indexPath.row - 1)]];
    
    _pushViewBegin = YES;
    UIViewController *detailView = [self pushViewCOntrollerWithSelectedBallsDic:dic lotteryDic:_lotteryDic atRowIndex:indexPath.row];
    [self.navigationController pushViewController:detailView animated:YES];
    [detailView release];
}

- (UIViewController *)pushViewCOntrollerWithSelectedBallsDic:(NSDictionary *)ballsDic lotteryDic:(NSDictionary *)dic atRowIndex:(NSInteger)index {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 8.5f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 8.5f);
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect]autorelease];
    [headerView setClipsToBounds:YES];
    
    CGRect headImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 75.0f);
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:headImageViewRect];
    [headImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betTop.png"]]];
    [headerView addSubview:headImageView];
    [headImageView release];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self tableCellHeight:indexPath tableView:tableView];
    } else {
        return 0.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    } else {
        return kTableViewFootViewHeight;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        //删除一行数据   因为数据显示是(key)从大往小显示  所以需要反转
        NSInteger count = self.betInfoDic.count;
        for (int i = 0; i < indexPath.row; i++) {
            [dic setObject:[self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)count - i - 1]] forKey:[NSString stringWithFormat:@"%ld",(long)count - i - 2]];
        }
        for (int j = (int)indexPath.row + 1; j < self.betInfoDic.count; j++) {
            [dic setObject:[self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)count - j - 1]] forKey:[NSString stringWithFormat:@"%ld",(long)count - j - 1]];
        }
        
        self.betInfoDic = dic;
        [_tableViews reloadData];
        [self updateBetCountOfBottomView];
        
        if (self.betInfoDic.count == 0) {
            _playtype = @"无玩法";
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    /********************** adjustment 控件调整 ***************************/
    CGFloat checkBtnMinX = 30.0f;
    CGFloat checkBtnSize = IS_PHONE ? 18.0f : 27.0f;
    CGFloat checkBtnMagin = (kTableViewFootViewHeight - checkBtnSize) / 2.0f - 5.0f;
    
    CGFloat promptLabelAddX = 5.0f;
    CGFloat promptLabelWidth = IS_PHONE ? 80.0f : 120.0f;
    CGFloat ruleBtnWidht = IS_PHONE ? 90.0f : 150.0f;
    /********************** adjustment end ***************************/
    //footView
    CGRect footViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kTableViewFootViewHeight);
    UIView *footView = [[UIView alloc]initWithFrame:footViewRect];
    [footView setClipsToBounds:YES];
    [footView setBackgroundColor:kBackgroundColor];
    
    //footBackImageView
    CGRect footBackImageViewRect = CGRectMake(0, -1, CGRectGetWidth(tableView.frame), kTableViewFootViewHeight + 1);
    UIImageView *footBackImageView = [[UIImageView alloc] initWithFrame:footBackImageViewRect];
    [footBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betBottom.png"]] stretchableImageWithLeftCapWidth:100.0f topCapHeight:15.0f]];
    [footView addSubview:footBackImageView];
    [footBackImageView release];
    
    //checkBtn
    CGRect checkBtnRect = CGRectMake(checkBtnMinX, checkBtnMagin, checkBtnSize, checkBtnSize);
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateNormal];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateHighlighted];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
    [footView addSubview:checkBtn];
    [checkBtn release];
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(CGRectGetMaxX(checkBtnRect) + promptLabelAddX, CGRectGetMinY(checkBtnRect), promptLabelWidth, CGRectGetHeight(checkBtnRect));
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:promptLabelRect];
    [promptLabel setTextAlignment:NSTextAlignmentLeft];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [promptLabel setText:@"我已阅读并同意"];
    [promptLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [footView addSubview:promptLabel];
    [promptLabel release];
    
    //ruleBtn
    CGRect ruleBtnRect = CGRectMake(CGRectGetMaxX(promptLabelRect), CGRectGetMinY(checkBtnRect), ruleBtnWidht, CGRectGetHeight(checkBtnRect));
    UIButton *ruleBtn = [[UIButton alloc] initWithFrame:ruleBtnRect];
    [ruleBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [ruleBtn setTitleColor:[UIColor colorWithRed:0x1a/255.0f green:0x65/255.0f blue:0xcb/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [ruleBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [ruleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [ruleBtn setTitle:@"《委托投注规则》" forState:UIControlStateNormal];
    [ruleBtn addTarget:self action:@selector(showRuleView:) forControlEvents:UIControlEventTouchUpInside];
    [ruleBtn setBackgroundColor:[UIColor clearColor]];
    [footView addSubview:ruleBtn];
    [ruleBtn release];
    
    //clearBtn
    CGRect clearBtnRect = CGRectMake(CGRectGetWidth(tableView.frame) - checkBtnSize - deleteBtnMaginRight, checkBtnMagin, checkBtnSize, checkBtnSize);
    UIButton *clearBtn = [[UIButton alloc] initWithFrame:clearBtnRect];
    [clearBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearButton.png"]] forState:UIControlStateNormal];
    [clearBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearButton.png"]] forState:UIControlStateHighlighted];
    [clearBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearButton.png"]] forState:UIControlStateSelected];
    [clearBtn addTarget:self action:@selector(clearBetTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:clearBtn];
    [clearBtn release];
    
    
    return [footView autorelease];
}

#pragma mark -UIAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) { //返回购彩大厅
        if (buttonIndex == 1) {
            [self clearNumber];
            
            NSArray *viewControllerArray = self.navigationController.viewControllers;
            if ([[viewControllerArray objectAtIndex:0] isKindOfClass:[HomeViewController class]]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];        //幸运选号的时候是present
            } else {
                if ([viewControllerArray count] >= 2) {
                    [self.navigationController popToViewController:[viewControllerArray objectAtIndex:1] animated:YES];
                }
            }
        }
    }
    
    if (alertView.tag == 3) { //清空号码
        if (buttonIndex == 1) {
            [self clearNumber];
        }
    }
    
    if (alertView.tag == 2) { //push到在线充值页面
        if(buttonIndex == 1) {
            if (_pushViewBegin)
                return;
            
            _pushViewBegin = YES;
            SelectRechargeTypeViewController *selectRechargeTypeViewController = [[SelectRechargeTypeViewController alloc]init];
            [self.navigationController pushViewController:selectRechargeTypeViewController animated:YES];
            [selectRechargeTypeViewController release];
            
        }
    }
    
    if (alertView.tag == 76) { //确认付款
        if(buttonIndex == 1) {
        [self paymoneyRequest:[self combineInfosOfPayoff]];
        }
    }
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    _requestData = NO;
    [SVProgressHUD dismiss];
    [self alertViewDefaultWithTitle:@"提示" message:@"连接失败" otherButtonTitle:@"取消"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    _requestData = NO;
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
//    NSLog(@"responseDic == %@",[responseDic JSONString]);
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        [SVProgressHUD showSuccessWithStatus:@"购买成功"];
        
        // 购买成功后，会返回余额和冻结金额，保存起来
        [[UserInfo shareUserInfo] setBalance:[responseDic objectForKey:@"balance"]];
        [[UserInfo shareUserInfo] setFreeze:[responseDic objectForKey:@"freeze"]];
        [[UserInfo shareUserInfo] setHandselAmount:[responseDic objectForKey:@"handselAmount"]];
        
        // 保存到NSUserDefaults
        NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
        [userinfo setObject:[responseDic objectForKey:@"balance"] forKey:@"balance"];
        [userinfo setObject:[responseDic objectForKey:@"freeze"] forKey:@"freeze"];
        [[NSUserDefaults standardUserDefaults]setObject:userinfo forKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [_orderDetailDict addEntriesFromDictionary:responseDic];
        NSString *lotteryID = [_lotteryDic objectForKey:@"lotteryid"];
        [_orderDetailDict setObject:lotteryID forKey:@"lotteryId"];
        [_orderDetailDict setObject:[NSString stringWithFormat:@"%@",self.luckyNumber ? @"YES" : @"NO"] forKey:@"isLuckyNumber"];
        
        NSInteger chasetaskids = [responseDic intValueForKey:@"chasetaskids"];
        OrderStatus status;
        if (chasetaskids > 0) {
            status = CHASED;
        } else {
            status = NORMAL;
        }
        
        
        PaySucceedViewController *paySucceedViewController = [[PaySucceedViewController alloc] initWithDict:_orderDetailDict buyType:status];
        if (paySucceedViewController && [paySucceedViewController isKindOfClass:[PaySucceedViewController class]]) {
            if (_pushViewBegin) {
                return;
            }
            _pushViewBegin = YES;
            [self.navigationController pushViewController:paySucceedViewController animated:YES];
        }
        [paySucceedViewController release];
       
        
    } else if (responseDic && [[responseDic objectForKey:@"error"] intValue] == -134) {
        
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"] delegate:self tag:2];
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    } else {
        [Globals alertWithMessage:@"购买失败，该期已经开奖或该期该彩种可发起的购买方案已达上限"];
    }
    [SVProgressHUD dismiss];
    
}

- (void)getlaunchChippedProportionFailed:(ASIHTTPRequest *)request {
    
}

- (void)getlaunchChippedProportionFinshed:(ASIHTTPRequest *)request {
    NSDictionary *dict = [[request responseString]objectFromJSONString];
    if (dict) {
        _globals.commission = [dict floatValueForKey:@"yongjin"];
        _globals.minBuyScale = [dict floatValueForKey:@"rengou"];
        
        NSMutableDictionary *chippedDic = [NSMutableDictionary dictionary];
        [chippedDic setObject:_lotteryDic forKey:@"lotteryDic"];
        [chippedDic setObject:[self getBuyContentString] forKey:@"buyContent"];
        [chippedDic setObject:[NSString stringWithFormat:@"%ld",(long)_betCount] forKey:@"betCount"];
        [chippedDic setObject:[NSString stringWithFormat:@"%ld",(long)_issueView.multiple] forKey:@"multiple"];
        
        if (_pushViewBegin) {
            return;
        }
        _pushViewBegin = YES;
        LaunchChippedViewController *chipped = [[LaunchChippedViewController alloc]initWithBetDictionary:chippedDic];
        [self.navigationController pushViewController:chipped animated:YES];
        [chipped release];
    }
    
}


#pragma mark -BetButtomViewDelegate
- (void)showAlertViewAndClear {
    // 每个彩种独有的ID(5:双色球 39:大乐透 等等)
    
    // 彩种进行发起合买的时候要满足注数条件
    if(_betCount < 1) {
        [self alertViewDefaultWithTitle:@"提示" message:@"发起复制至少需要一注" otherButtonTitle:@"取消"];
        return;
    }
    
    // 发起合买不能进行追期
    if (_issueView.chase > 1) {
        [self alertViewDefaultWithTitle:@"提示" message:@"发起复制不能进行追期" otherButtonTitle:@"取消"];
        return;
    }
    
    // 判断该彩种有没有过期
    if ([Globals judgeIsOutOfDate:[_lotteryDic objectForKey:@"endtime"]]) {
        [self alertViewDefaultWithTitle:@"提示" message:@"该奖期已结束,请等下一期" otherButtonTitle:@"确定"];
        return;
    }
    
    [self loadLaunchChippedProportion];
}

- (void)payMoney {
    if([UserInfo shareUserInfo].userID) {
        NSInteger count = _issueView.chase;    // 填写的要追多少期
        self.chaseList = [_lotteryDic objectForKey:@"dtCanChaseIsuses"];
        
        // 能追一期
        NSInteger totalChaseCount = [self.chaseList count];
        if (count > 1 && totalChaseCount == 0) {
            [self alertViewDefaultWithTitle:@"提示" message:@"最多只能追1期" otherButtonTitle:@"确认"];
        } else if (count > totalChaseCount && totalChaseCount != 0) {
            [self alertViewDefaultWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能追%ld期",(long)totalChaseCount] otherButtonTitle:@"确认"];
        } else if ([self calculateTotalAmountAndBetCounts] < 1) {
            [self alertViewDefaultWithTitle:@"提示" message:@"至少选择一注" otherButtonTitle:@"确认"];
        } else {
            if (_allstr && _allstr.length>0) {
                DuangAlert *duang = [[DuangAlert alloc] initWithTitle:@"发起复制需要填写以下内容" settings:@[@"永久公开",@"开奖后公开"] selected:^(NSInteger index, NSDictionary *backDic) {
                    if (index == 1) {
                        _secrecyLevel = [[backDic objectForKey:@"index"] integerValue] == 0 ? @"0" : @"2";
                        _description = [[backDic objectForKey:@"text"] copy];
                        
                        CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)[self calculateTotalAmountAndBetCounts] * 2 * _issueView.multiple] leftText:@"取消" rightText:@"确定"];
                        [customAlert setTag:76];
                        [customAlert show];
                        [customAlert release];
                    }
                }];
                [duang show];
                [duang release];
            }else{
                CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)[self calculateTotalAmountAndBetCounts] * 2 * _issueView.multiple] leftText:@"取消" rightText:@"确定"];
                [customAlert setTag:76];
                [customAlert show];
                [customAlert release];
            }

        }
        
    } else {
        UserLoginViewController *login = [[UserLoginViewController alloc]init];
        login.isNeedDelegate = NO;
        XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
        [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = loginNav;
        [self.view.window.rootViewController presentViewController:loginNav animated:YES completion:nil];
        [login release];
        [loginNav release];
        return;
    }
}

#pragma mark -SelectBallsDetailViewControllerDelegate
- (void)updateSelect {
    [_tableViews reloadData];
    [self updateBetCountOfBottomView];
}

- (void)updateSelectBallsDic:(NSDictionary *)dic AtRowIndex:(NSInteger)index {
    NSInteger count = self.betInfoDic.count;
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:self.betInfoDic];
    [dicInfo setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)(count - index - 1)]];
    
    self.betInfoDic = dicInfo;
    // 页面返回自动调用viewWillAppear方法，刷新表格和底部试图
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)deleteBetTouchUpInside:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    for (NSInteger index = tag; index  < [self.betInfoDic count] - 1; index++) {
        NSMutableDictionary *dict = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)(index + 1)]];
        if (dict) {
            [self.betInfoDic setObject:dict forKey:[NSString stringWithFormat:@"%ld",(long)index]];
        }
    }
    [self.betInfoDic removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)([self.betInfoDic count] - 1)]];
    [_tableViews reloadData];
    [self updateBetCountOfBottomView];
}

- (void)clearBetTouchUpInside:(id)sender {
    if (self.betInfoDic.count != 0) {
        [Globals alertWithMessage:@"您确认要清空投注列表么?" delegate:self tag:3];
    } else {
        [Globals alertWithMessage:@"请先选择投注内容！"];
    }
}

- (void)backToHome:(id)sende {
    if(_issueView) {
        [_issueView tapResignKeyboard:nil];
    }
    if(_betInfoDic.count > 0) {
        // 如果有数据则弹出，没有则返回
        
        [Globals alertWithMessage:@"您退出后号码将会清空" delegate:self tag:1];
        
    } else {
        
        
        
        NSArray *viewControllerArray = self.navigationController.viewControllers;
        if ([[viewControllerArray objectAtIndex:0] isKindOfClass:[HomeViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];        //幸运选号的时候是present
        } else {
            if ([viewControllerArray count] >= 2) {
                [self.navigationController popToViewController:[viewControllerArray objectAtIndex:1] animated:YES];
            }
        }
        
        
    }
}

- (void)showRuleView:(id)sender {
    BetRuleViewController *betRuleVC = [[BetRuleViewController alloc] init];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:betRuleVC];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [betRuleVC release];
    [nav release];
}

- (void)handAddBalls:(id)sender {
}

- (void)autoAddBalls:(id)sender {
}
#pragma mark -Customized: Private (General)
- (void)loadLaunchChippedProportion {
    if (_launchChippedProportionRequest) {
        [_launchChippedProportionRequest clearDelegatesAndCancel];
        [_launchChippedProportionRequest release];
        _launchChippedProportionRequest = nil;
    }
    _launchChippedProportionRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetTogetherBuyMinScale userId:@"-1"infoDict:nil]];
    [_launchChippedProportionRequest setDelegate:self];
    [_launchChippedProportionRequest setDidFinishSelector:@selector(getlaunchChippedProportionFinshed:)];
    [_launchChippedProportionRequest setDidFailSelector:@selector(getlaunchChippedProportionFailed:)];
    [_launchChippedProportionRequest startAsynchronous];
}

#pragma mark - 付款按钮
- (void)paymoneyRequest:(NSDictionary *)infoDic {
    if (_requestData) {
        return;
    }
    _requestData = YES;
    [SVProgressHUD showWithStatus:@"加载中"];
    if (_dataRequest) {
        [_dataRequest clearDelegatesAndCancel];
        [_dataRequest release];
        _dataRequest = nil;
    }
    
    
    /** 就这里的通信没用实验室的验证加密方法，因为后台也没加，这里可能出现大数据量的传输，加密过程会出现丢失情况 */
    NSString *infoStr = [infoDic JSONString];
    NSString *currentDate = [InterfaceHelper getCurrentDateString];
    NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    NSLog(@"infoStr == %@",infoStr);
    _dataRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kBaseUrl]];
    [_dataRequest setNumberOfTimesToRetryOnTimeout:1];
    [_dataRequest setPostValue:infoStr forKey:kInfo];
    [_dataRequest setPostValue:auth == nil ? @"" : auth forKey:kAuth];
    [_dataRequest setPostValue:HTTP_REQUEST_BuyLotteryTicket forKey:kOpt];
    [_dataRequest setPersistentConnectionTimeoutSeconds:60.0f];
    [_dataRequest setDelegate:self];

    [_dataRequest startAsynchronous];
}

- (NSArray *)getBuyContentString {
    return [NSArray arrayWithObject:@""];
}

- (void)alertViewDefaultWithTitle:(NSString *)title message:(NSString *)message otherButtonTitle:(NSString *)otherButtonTitle {
    [Globals alertWithMessage:message];
}

//付款
- (NSDictionary *)combineInfosOfPayoff {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *lotteryID = [_lotteryDic objectForKey:@"lotteryid"];
    NSString *issueID = [_lotteryDic objectForKey:@"isuseId"];
    NSString *multiple = [NSString stringWithFormat:@"%ld",(long)_issueView.multiple];      // 倍数
    
    // schemeSumMoney = 总注数 * 追的期数 * 2
    NSString *schemeSumMoney = [NSString stringWithFormat:@"%ld",(long)[self calculateTotalAmountAndBetCounts] * 2 * _issueView.multiple];
    // 总注数
    NSString *schemeSumNum = [NSString stringWithFormat:@"%ld",(long)[self calculateTotalAmountAndBetCounts]];
    // 追多少期,如果为1，则为0；
    NSString *chase = [NSString stringWithFormat:@"%ld",(long)(_issueView.chase < 2 ? 0 : _issueView.chase)];
    // 追期的时候是否中奖后停止追号
    NSString *autoStopAtWinMoney = [NSString stringWithFormat:@"%d",_issueView.isZhuiQiStop];
    // chaseBuyedMoney = 总注数 * 倍数 *  追的期数 * 每注的价钱; （大乐透追加玩法 3元一注）    // 子类重写该方法
    NSString *chaseBuyedMoney = [NSString stringWithFormat:@"%ld",(long)(_issueView.chase < 2 ? 0 : [self calculateTotalAmountAndBetCounts] * _issueView.multiple * 2 * _issueView.chase)];
    
    NSArray *buyContent = [self getBuyContentString];
    
    NSArray *chaseList = [self getChaseListString];
    
    [dic setObject:lotteryID == nil ? @"" : lotteryID forKey:@"lotteryId"];
    [dic setObject:issueID == nil ? @"" : issueID forKey:@"isuseId"];
    [dic setObject:multiple == nil ? @"" : multiple forKey:@"multiple"];
    [dic setObject:@"1" forKey:@"share"];
    [dic setObject:@"1" forKey:@"buyShare"];
    [dic setObject:@"0" forKey:@"assureShare"];
    [dic setObject:@"0" forKey:@"schemeBonusScale"];
    [dic setObject:@"" forKey:@"title"];
    [dic setObject:@"" forKey:@"description"];
    [dic setObject:@"0" forKey:@"secrecyLevel"];
    if (_allstr == nil || [_allstr isEqualToString:@""]) {
        
    }else{
        [dic setObject:_secrecyLevel forKey:@"secrecyLevel"];
        [dic setObject:_description forKey:@"description"];
        [dic setObject:_allstr forKey:@"isMayCopy"];
    }
    
    [dic setObject:schemeSumMoney == nil ? @"" : schemeSumMoney forKey:@"schemeSumMoney"];
    [dic setObject:schemeSumNum == nil ? @"" : schemeSumNum forKey:@"schemeSumNum"];
    [dic setObject:schemeSumMoney == nil ? @"" : schemeSumMoney forKey:@"sumMoney"];
    [dic setObject:schemeSumNum == nil ? @"" : schemeSumNum forKey:@"sumNum"];
    [dic setObject:autoStopAtWinMoney == nil ? @"" : autoStopAtWinMoney forKey:@"autoStopAtWinMoney"];
    [dic setObject:chase == nil ? @"" : chase forKey:@"chase"];
    [dic setObject:chaseBuyedMoney == nil ? @"" : chaseBuyedMoney forKey:@"chaseBuyedMoney"];
    [dic setObject:buyContent == nil ? @"" : buyContent forKey:@"buyContent"];
    [dic setObject:chaseList == nil ? @"" : chaseList forKey:@"chaseList"];
    
    NSInteger detailMoney = [chaseBuyedMoney integerValue] > 0 ? [chaseBuyedMoney integerValue] : [schemeSumMoney integerValue];
    [_orderDetailDict removeAllObjects];
    [_orderDetailDict setObject:[NSNumber numberWithInteger:detailMoney] forKey:@"consumeMoney"];
    
    return dic;
}
- (void)tongzhi:(NSNotification *)text{
//    NSLog(@"%@",text.userInfo[@"textOne"]);
    NSLog(@"－－－－－接收到通知------");
    _allstr = text.userInfo[@"textOne"];
}
//清除号码
- (void)clearNumber {
    self.betInfoDic = nil;
    [_tableViews reloadData];
    [self updateBetCountOfBottomView];
}

- (NSInteger)calculateTotalAmountAndBetCounts {
    int count=0;
    for (int i = 0; i < self.betInfoDic.count; i++) {
        NSDictionary *dic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%d",i]];
        count += [[dic objectForKey:kBetCount] intValue];
    }
    return count;
}

- (void)updateBetCountOfBottomView {
    NSInteger count = [self calculateTotalAmountAndBetCounts];
    _betCount = count;
    // 总注数 = 表格里的总注数;
    // 总金额 = 表格里的总注数 * 追期数 * 追号的倍数 * 2;_issueView.multiple,(long)_issueView.chase]];
    if(_issueView.isZhuiHao) {
        [_bottomView setCount:count money:count * 3 * _issueView.multiple * _issueView.chase];
    } else{
        [_bottomView setCount:count money:count * 2 * _issueView.multiple * _issueView.chase];
    }
}

- (NSArray *)getChaseListString {
    NSMutableArray *chaseArray = [NSMutableArray array];
    NSInteger count = _issueView.chase;    // 追多少期
    
    NSArray *chaseList = [_lotteryDic objectForKey:@"dtCanChaseIsuses"]; //  服务器返回能追的期
    if (chaseList.count > 0) {      // 有的话才能进行追期
        
        if (count == 1) {   // 如果输入的为1，则不进行追期
        
        } else if (count >= 2) {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *chaseDic = [NSMutableDictionary dictionary];
                
                NSString *isuseId = [[chaseList objectAtIndex:i] objectForKey:@"isuseId"];
                // 投多少倍
                NSString *multiple = [NSString stringWithFormat:@"%ld",(long)_issueView.multiple];
                // 所投的注数需要花费的金额
                NSString *money = [NSString stringWithFormat:@"%ld",(long)(_betCount * _issueView.multiple * 2)];
                
                [chaseDic setObject:isuseId forKey:@"isuseId"];
                [chaseDic setObject:multiple forKey:@"multiple"];
                [chaseDic setObject:money forKey:@"money"];
                
                [chaseArray addObject:chaseDic];
            }
        }
    }
    return chaseArray;
}

- (void)reloadtableViews {
    [_tableViews reloadData];
}

//提供可用于重写
- (CGFloat)tableCellHeight:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (self.betInfoDic.count == 0) {
        return 20.0f;
    }
    NSDictionary *infoDic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)(self.betInfoDic.count - indexPath.row - 1)]];
    
    NSString *numberStr = [infoDic objectForKey:kSelectBalls];
    CGSize expectedSize = [numberStr sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]
                                constrainedToSize:CGSizeMake(CGRectGetWidth(tableView.frame) - betNumberLabelMaginRight - betNumberLabelMinX * 2 - XFIponeIpadFontSize14 / 2.0f, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    return (expectedSize.height + tableCellLabelHeight <= tableCellHeihgt ? tableCellHeihgt : expectedSize.height + tableCellLabelHeight + tabelCellLabelImageInterval) + 20.0f;
}

//提供可用于重写
- (BOOL)isDoubleColorText {
    return NO;
}

//提供可用于重写
- (NSString *)showPlayTypeNameWithPlayName:(NSString *)playName {
    return playName;
}

@end
