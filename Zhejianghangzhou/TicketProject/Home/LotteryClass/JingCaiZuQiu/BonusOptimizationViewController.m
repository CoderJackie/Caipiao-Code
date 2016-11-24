//
//  BonusOptimizationViewController.m 购彩大厅－竞彩足球投注 - 奖金优化
//  TicketProject
//
//  Created by kiu on 15/7/29.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "BonusOptimizationViewController.h"
#import "XFNavigationViewController.h"
#import "HelpViewController.h"
#import "LaunchChippedViewController.h"
#import "PassWayUtility.h"
#import "UserLoginViewController.h"
#import "PaySucceedViewController.h"

#import "SVProgressHUD.h"
#import "UserInfo.h"
#import "Globals.h"
#import "CustomBottomView.h"
#import "CalculateBetCount.h"
#import "InterfaceHelper.h"
#import "DuangAlert.h"

#define kInputViewHeight (IS_PHONE ? 44.0f : 64.0f)
#define kFootBallTableViewFootViewHeight (IS_PHONE ? 53.0f : 90.0f)
#define FootBallBetViewCellHeight (IS_PHONE ? 90.0f : 150.0f)
#define lineWidth [UIScreen mainScreen].bounds.size.width / 3

#define JCFisrtColLabelWidth (kWinSize.width - 20) / 7 * 1.2
#define JCSecondColLabelWidth (kWinSize.width - 20) / 7 * 3
#define JCThreeColLabelWidth (kWinSize.width - 20) / 7 * 1.2
#define JCFourColLabelWidth (kWinSize.width - 20) / 7 * 1.6

@implementation BonusOptimizationViewController
{
    NSString *_allstr;
}
- (id)initWithMatchArray:(NSMutableArray *)matchArray andScoreDic:(NSMutableDictionary *)scoreDic andBetCount:(NSInteger) betCount lotteryId:(NSString *)lotteryId{
    self = [super init];
    if(self) {
        self.selectMatchArray = matchArray;
        self.selectedScoreDic = scoreDic;
        _betCount = betCount;
        _lotteryId = lotteryId;
        _preBetType = 1;
        self.title = @"奖金优化";
    }
    
    return self;
}

- (void)dealloc {
    _inputView = nil;
    _inputField = nil;
    _bottomView = nil;
    _moneyField = nil;
    _secrecyLevel = nil;
    _description = nil;
    
    [_resultArray release];
    [_orderDetailDict release];
    _orderDetailDict = nil;
    [_promptLabelTitleArray release];
    _promptLabelTitleArray = nil;
    [_selectMatchArray release];
    _selectMatchArray = nil;
    [_passWayArray release];
    _passWayArray = nil;
    [_passWayTagArray release];
    _passWayTagArray = nil;
    [_launchChippedProportionRequest release];
    _launchChippedProportionRequest = nil;
    
    [super dealloc];
}

- (void)loadView {
    
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
    UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
    [baseView release];
    
    //scrollView 整个滑动视图
    CGRect scrollViewRect = CGRectMake(CGRectGetMinX(appRect), CGRectGetMinY(appRect), CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 88.0f - kInputViewHeight);
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView setMultipleTouchEnabled:NO];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    //给背景加上点击事件  让键盘消失
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToHideKeyboard:)];
    [_scrollView addGestureRecognizer:tapGesture1];
    [tapGesture1 release];
    
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
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat inputViewPassWayBtnHeight = IS_PHONE ? 28.0f : 40.0f;
    CGFloat inputViewPromptLabelWidth = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat touPromptLabelInputFieldLandscapeInterval = IS_PHONE ? 10.0f : 20.0f;
    CGFloat inputFieldWidth = IS_PHONE ? 80.0f : 160.0f;
    /********************** adjustment end ***************************/
    
    // 计划购买文案
    UILabel *buyTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(appRect) - 240) / 2, 15, 70, 30)];
    buyTitleLabel.text = @"计划购买:";
    [buyTitleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_scrollView addSubview:buyTitleLabel];
    [buyTitleLabel release];
    
    UIButton *minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    minusBtn.frame = CGRectMake(buyTitleLabel.frame.origin.x + 70, 15, 30, 30);
    [minusBtn setTitle:@"-" forState:UIControlStateNormal];
    [minusBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [minusBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] forState:UIControlStateNormal];
    [minusBtn addTarget:self action:@selector(bonusChange:) forControlEvents:UIControlEventTouchUpInside];
    minusBtn.tag = 1;
    [minusBtn setTintColor:[UIColor grayColor]];
    [_scrollView addSubview:minusBtn];
    
    // 购买金额
    _moneyField = [[UITextField alloc] initWithFrame:CGRectMake(minusBtn.frame.origin.x + 29, 15, 80, 30)];
    _moneyField.textAlignment = NSTextAlignmentCenter;
    _moneyField.backgroundColor = [UIColor whiteColor];
    [_moneyField setKeyboardType:UIKeyboardTypeNumberPad];
    [_moneyField.layer setBorderWidth:1.0f];
    _moneyField.tag = 998;
    [_moneyField.layer setBorderColor:[[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f] CGColor]];
    _moneyField.userInteractionEnabled = NO;
    [_scrollView addSubview:_moneyField];
    [_moneyField release];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(_moneyField.frame.origin.x + 80, 15, 30, 30);
    [addBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] forState:UIControlStateNormal];
    [addBtn setTitle:@"+" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(bonusChange:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.tag = 2;
    [_scrollView addSubview:addBtn];
    
    // 元
    UILabel *yuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(addBtn.frame.origin.x + 40, 15, 15, 30)];
    yuanLabel.text = @"元";
    [yuanLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_scrollView addSubview:yuanLabel];
    [yuanLabel release];
    
    // ******** 中间区域 *******
    // 平均优化
    UIButton *averageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    averageBtn.frame = CGRectMake(0, 55, CGRectGetWidth(appRect) / 3, 40);
    [averageBtn setTitle:@"平均优化" forState:UIControlStateNormal];
    averageBtn.titleLabel.font =  [UIFont systemFontOfSize:XFIponeIpadFontSize14];
    [averageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [averageBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    averageBtn.selected = YES;
    averageBtn.tag = 11;
    [averageBtn addTarget:self action:@selector(contentChange:) forControlEvents:UIControlEventTouchDown];
    [_scrollView addSubview:averageBtn];
    
    // 博热优化
    UIButton *heatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    heatBtn.frame = CGRectMake(CGRectGetWidth(appRect) / 3, 55, CGRectGetWidth(appRect) / 3, 40);
    [heatBtn setTitle:@"搏热优化" forState:UIControlStateNormal];
    heatBtn.titleLabel.font =  [UIFont systemFontOfSize:XFIponeIpadFontSize14];
    [heatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [heatBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    heatBtn.tag = 12;
    [heatBtn addTarget:self action:@selector(contentChange:) forControlEvents:UIControlEventTouchDown];
    [_scrollView addSubview:heatBtn];
    
    // 搏冷优化
    UIButton *coldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    coldBtn.frame = CGRectMake(CGRectGetWidth(appRect) / 3 * 2, 55, CGRectGetWidth(appRect) / 3, 40);
    [coldBtn setTitle:@"搏冷优化" forState:UIControlStateNormal];
    coldBtn.titleLabel.font =  [UIFont systemFontOfSize:XFIponeIpadFontSize14];
    [coldBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [coldBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    coldBtn.tag = 13;
    [coldBtn addTarget:self action:@selector(contentChange:) forControlEvents:UIControlEventTouchDown];
    [_scrollView addSubview:coldBtn];
    
    // 固定线条
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 95, CGRectGetWidth(appRect), 1)];
    lineV.backgroundColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
    [_scrollView addSubview:lineV];
    [lineV release];
    
    // 动画线条，根据选择优化类别，移动到此button下方
    _lineView = [[UIView alloc] init];
    _lineView.frame = CGRectMake(0, 94.5, CGRectGetWidth(appRect) / 3, 2);
    _lineView.backgroundColor = [UIColor redColor];
    [_scrollView addSubview:_lineView];
    [_lineView release];
    
    // ************************
    
    //inputView
    CGRect inputViewRect =CGRectMake(0, self.view.bounds.size.height - 44.0f - kBottomHeight - kInputViewHeight, CGRectGetWidth(appRect), kInputViewHeight);
    _inputView = [[UIView alloc]initWithFrame:inputViewRect];
    [_inputView setBackgroundColor:[UIColor colorWithRed:0xf1/255.0f green:0xf1/255.0f blue:0xf1/255.0f alpha:1.0f]];
    [self.view addSubview:_inputView];
    [_inputView release];
    
    //inputField
    CGRect inputFieldRect = CGRectMake((CGRectGetWidth(appRect) - inputFieldWidth) / 2, (kInputViewHeight - inputViewPassWayBtnHeight) / 2.0f, inputFieldWidth, inputViewPassWayBtnHeight);
    UIImageView *inputFieldBackImageView = [[UIImageView alloc] initWithFrame:inputFieldRect];
    [inputFieldBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f]];
    [_inputView addSubview:inputFieldBackImageView];
    [inputFieldBackImageView release];
    
    //touPromptLabel
    CGRect touPromptLabelRect = CGRectMake(CGRectGetMinX(inputFieldRect) - 30, CGRectGetMinY(inputFieldRect), inputViewPromptLabelWidth, inputViewPassWayBtnHeight);
    UILabel *touPromptLabel = [[UILabel alloc]initWithFrame:touPromptLabelRect];
    [touPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [touPromptLabel setText:@"投"];
    [touPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_inputView addSubview:touPromptLabel];
    [touPromptLabel release];
    
    // 倍数
    _inputField = [[UITextField alloc]initWithFrame:inputFieldRect];
    [_inputField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_inputField setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_inputField setTextAlignment:NSTextAlignmentCenter];
    [_inputField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_inputField setText:@"1"];
    [_inputField setDelegate:self];
    _inputField.tag = 999;
    [_inputView addSubview:_inputField];
    [_inputField release];
    
    //beiPromptLabel
    CGRect beiPromptLabelRect = CGRectMake(CGRectGetMaxX(inputFieldRect) + touPromptLabelInputFieldLandscapeInterval, CGRectGetMinY(inputFieldRect), inputViewPromptLabelWidth, CGRectGetHeight(touPromptLabelRect));
    UILabel *beiPromptLabel = [[UILabel alloc]initWithFrame:beiPromptLabelRect];
    [beiPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [beiPromptLabel setTextAlignment:NSTextAlignmentRight];
    [beiPromptLabel setText:@"倍"];
    [beiPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_inputView addSubview:beiPromptLabel];
    [beiPromptLabel release];
    
    //bottomView
    CGRect bottomViewRect = CGRectMake(0, CGRectGetHeight(appRect) - kBottomHeight - 44.0f, CGRectGetWidth(appRect), kBottomHeight);
    _bottomView = [[CustomBottomView alloc]initWithFrame:bottomViewRect Type:1];
    [_bottomView setMatchCount:0 money:0];
    [self.view addSubview:_bottomView];
    [_bottomView release];
    
    
//    //chippedBtn
//    UIButton *chippedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [chippedBtn setTitle:@"发起复制" forState:UIControlStateNormal];
//    [chippedBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
//    [chippedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [chippedBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
//    [chippedBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
//    [chippedBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView setLeftButton:chippedBtn];
//    
//    CGRect checkBtnRect = CGRectMake(CGRectGetMaxX(chippedBtn.frame)+5, chippedBtn.frame.origin.y, chippedBtn.frame.size.height, chippedBtn.frame.size.height);
//    UIButton *checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
//    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton_Normal.png"]] forState:UIControlStateNormal];
//    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
//    checkBtn.tag = 10086;
//    [checkBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView addSubview:checkBtn];
//    [checkBtn release];
    
    //payBtn
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setTitle:@"付款" forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [payBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView setRightButton:payBtn];
    
    // 优化组合对阵列表
    _lotteryNumberTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 96, kWinSize.width, kWinSize.height) style:UITableViewStylePlain];
    [_lotteryNumberTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_lotteryNumberTableView setDataSource:self];
    [_lotteryNumberTableView setDelegate:self];
    _lotteryNumberTableView.scrollEnabled = NO;
    [_scrollView addSubview:_lotteryNumberTableView];
    [_lotteryNumberTableView release];
    
    [_scrollView setContentSize:CGSizeMake(kWinSize.width, kWinSize.height)];
}
-(void)zhuiQiSelected:(UIButton *)sender
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:10086];
    btn.selected = !btn.selected;
    NSString *str;
    if (btn.selected == YES) {
        str = @"true";
    }else{
        str = @"";
    }
    _allstr = str;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    
    _preBetType = 1;
    _orderDetailDict = [[NSMutableDictionary alloc] init];
    _resultArray = [[NSMutableArray alloc] init];
    _promptLabelTitleArray = [[NSMutableArray alloc] initWithObjects:@"过关",@"单注组合",@"注数",@"预测奖金", nil];
    [self getAgainst];
    
}

#pragma Delegate
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *JCCellIdentifier = @"JCMatchDetailCell";
    cell = [tableView dequeueReusableCellWithIdentifier:JCCellIdentifier];
    CGFloat cellHeight = [self tableCellHeight:indexPath tableView:tableView];
    if (_footBallPassBarrierType == FootBallPassBarrierType_singleMacth || _basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) { //单关
        cellHeight = 40;
    }
    CGFloat cellY = 0;

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JCCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *oneMatchDetailDict = [_resultArray objectAtIndex:indexPath.row];//该数组的数据都是IOS自己处理过的，不是服务器原始数据
    
    // 过关Label
    CGRect passLabelRect = CGRectMake(11, cellY, JCFisrtColLabelWidth, cellHeight);
    [self makeLabelWithFrame:passLabelRect row:indexPath.row superView:cell.contentView matchDetailDict:oneMatchDetailDict tag:0];
    
    //teamLabel
    CGRect teamLabelRect = CGRectMake(JCFisrtColLabelWidth + 10, cellY, JCSecondColLabelWidth, cellHeight);
    [self makeLabelWithFrame:teamLabelRect row:indexPath.row superView:cell.contentView matchDetailDict:oneMatchDetailDict tag:1];
    
    // 注数Label
    CGRect zhuLabelRect = CGRectMake(JCFisrtColLabelWidth + JCSecondColLabelWidth + 10, cellY, JCThreeColLabelWidth, cellHeight);
    [self makeLabelWithFrame:zhuLabelRect row:indexPath.row superView:cell.contentView matchDetailDict:oneMatchDetailDict tag:2];
    
    //forecastBonusLabel
    CGRect forecastBonusLabelRect = CGRectMake(kWinSize.width - JCFourColLabelWidth - 11, cellY, JCFourColLabelWidth, cellHeight);
    [self makeLabelWithFrame:forecastBonusLabelRect row:indexPath.row superView:cell.contentView matchDetailDict:oneMatchDetailDict tag:3];
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_footBallPassBarrierType == FootBallPassBarrierType_singleMacth || _basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) { //单关
        return 40;
    }else {
        NSDictionary *dic = _resultArray[indexPath.row];
        NSArray *array =  [dic objectForKey:@"team"];
        
        return array.count * 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40.0f;
    
}

// 头部标签
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width, 30);
    UIView *headerView = [[[UIView alloc]initWithFrame:headerViewRect] autorelease];
    
    CGRect promptLabelRect;
    for (NSInteger index = 0; index < [_promptLabelTitleArray count]; index++) {
        if (index == 0) {
            promptLabelRect = CGRectMake(11, 10, JCFisrtColLabelWidth, 30);
            
        } else if (index == 1) {
            promptLabelRect = CGRectMake(JCFisrtColLabelWidth + 10, 10, JCSecondColLabelWidth, 30);
            
        } else if (index == 2) {
            promptLabelRect = CGRectMake(JCFisrtColLabelWidth + JCSecondColLabelWidth + 10, 10, JCThreeColLabelWidth, 30);
            
        } else if (index == 3) {
            promptLabelRect = CGRectMake(kWinSize.width - JCFourColLabelWidth - 11, 10, JCFourColLabelWidth, 30);
        }
        
        //promptLabel
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
        [promptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
        [promptLabel setText:[_promptLabelTitleArray objectAtIndex:index]];
        [promptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [promptLabel setTextAlignment:NSTextAlignmentCenter];
        [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [[promptLabel layer] setBorderWidth:AllLineWidthOrHeight];
        [[promptLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
        [headerView addSubview:promptLabel];
        [promptLabel release];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.1;
}

// 获取每一个Cell高度
- (CGFloat)tableCellHeight:(NSIndexPath *)indexPath tableView:(UITableView *)tableView  {
    
    NSArray *array = [_resultArray[indexPath.row] objectForKey:@"team"];
    return array.count * 30;
    
}

// 画出每一个 UITableViewCell 模块的布局跟值
- (CGRect)makeLabelWithFrame:(CGRect)frame row:(NSInteger)rowP superView:(UIView *)superView matchDetailDict:(NSDictionary *)matchDetailDict tag:(int)mark{
    
    NSArray *passArr = [matchDetailDict objectForKey:@"team"];
    
    // 单注组合信息处理方法
    _bgView = [[UIView alloc] initWithFrame:frame];
    [_bgView setBackgroundColor:[UIColor whiteColor]];
    [[_bgView layer] setBorderWidth:AllLineWidthOrHeight];
    [[_bgView layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
    [superView addSubview:_bgView];
    [_bgView release];
    
    // temp对应数据 (0:过关  1: 单注组合  2: 注数  3: 预测奖金)
    switch (mark) {
        case 0:
        {
            
            UILabel *playTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - 20) / 2, frame.size.width, 20)];
            [playTypeLabel setTextAlignment:NSTextAlignmentCenter];
            [playTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            if (_footBallPassBarrierType == FootBallPassBarrierType_singleMacth || _basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) { //单关
                [playTypeLabel setText:@"单关"];
            }else {
                [playTypeLabel setText:[NSString stringWithFormat:@"%@串1",[matchDetailDict objectForKey:@"passNumber"]]];
            }
            
            [_bgView addSubview:playTypeLabel];
            [playTypeLabel release];
            
        }
            break;
        case 1:
        {
            for (int i = 0; i < passArr.count; i ++) {
                NSDictionary *dicTemp = passArr[i];
                
                UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                
                if (i == 0) {
                    teamLabel.frame = CGRectMake(10, 5 , 100, 28);
                }else {
                    teamLabel.frame = CGRectMake(10, i * 30, 100, 26);
                }
                [teamLabel setTextAlignment:NSTextAlignmentLeft];
                [teamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [teamLabel setText:[dicTemp objectForKey:@"teamName"]];
                [_bgView addSubview:teamLabel];
                [teamLabel release];
                
                NSString *oddsStr = [NSString stringWithFormat:@"%@(%@)",[dicTemp objectForKey:@"results"], [dicTemp objectForKey:@"odds"]];
                UILabel *oddsLabel = [[UILabel alloc] init];
                oddsLabel.frame = CGRectMake(frame.size.width - 95, teamLabel.frame.origin.y, 90, 26);
                [oddsLabel setTextAlignment:NSTextAlignmentRight];
                [oddsLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [oddsLabel setText:oddsStr];
                [_bgView addSubview:oddsLabel];
                [oddsLabel release];
            }
        }
            break;
        case 2:
        {
            UITextField *cellTextF = [[UITextField alloc] initWithFrame:CGRectMake(5, (frame.size.height - 30) / 2, frame.size.width - 10, 30)];
            cellTextF.text = [NSString stringWithFormat:@"%@",[matchDetailDict objectForKey:@"playCount"]];
            cellTextF.returnKeyType = UIReturnKeyDone;
            cellTextF.tag = 2015 + rowP;
            cellTextF.delegate = self;
            cellTextF.backgroundColor = kBackgroundColor;
            cellTextF.textAlignment = NSTextAlignmentCenter;
            [cellTextF.layer setCornerRadius:8.0f];
            [cellTextF.layer setMasksToBounds:YES];
            [cellTextF setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_bgView addSubview:cellTextF];
            
            [cellTextF release];
            
        }
            break;
        case 3:
        {
            UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - 20) / 2, frame.size.width, 20)];
            [teamLabel setTextAlignment:NSTextAlignmentCenter];
            [teamLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [teamLabel setText:[matchDetailDict objectForKey:@"castMoney"]];
            [_bgView addSubview:teamLabel];
            [teamLabel release];
            
        }
            break;
        default:
            break;
    }
    
    return frame;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBack:(id)sender {
    [Globals alertWithMessage:@"退出将清空当前方案信息" delegate:self tag:1];
}

#pragma mark -UIAlertViewdelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 76) { //确认付款
        if(buttonIndex == 1) {
            [self payRequest];
            return;
        }
    }
    
    if(buttonIndex == 1) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
}

#pragma mark - 奖金优化玩法说明
- (void)palyIntroduceTouchUpInside:(UIButton *)btn {
    Service *service=[Service getDefaultService];
    service.lotteryTypes = 1111;    // 奖金优化玩法说明唯一标识
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithLotteryId:1111];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc] initWithRootViewController:helpViewController];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [helpViewController release];
    [nav release];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 999) {     // 注数
        //监听键盘出现和消失的事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }else if(textField.tag != 998){
        
        // 弹出键盘时,更改scrollView的坐标
        [UIView beginAnimations:@"kiu" context:nil];
        [UIView setAnimationDuration:0.28];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        CGRect rect = _scrollView.frame;
        rect.size.height = _scrollView.frame.size.height - 170;
        _scrollView.frame = rect;
        
        [UIView commitAnimations];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([text length] > 5)
        return NO;
    return YES;
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0)
        textField.text = @"1";
    
    // 修改底下倍数，如果是修改倍数文本，则不进行下面操作。(倍数：textField tag = 999)
    if (textField.tag != 999 && textField.tag != 998) {
        // 收回键盘时，还原scrollView的坐标。(动画效果)
        [UIView beginAnimations:@"kiu" context:nil];
        [UIView setAnimationDuration:0.28];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        CGRect rect = _scrollView.frame;
        rect.size.height = _scrollView.frame.size.height + 170;
        _scrollView.frame = rect;
        
        [UIView commitAnimations];
        
        
        NSInteger temp = textField.tag - 2015;
        NSString *castMoney = [NSString stringWithFormat:@"%.2f", [textField.text intValue] * [[_resultArray[temp] objectForKey:@"castMoney"] floatValue]];
        [_resultArray[temp] setObject:textField.text forKey:@"playCount"];
        [_resultArray[temp] setObject:castMoney forKey:@"castMoney"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:temp inSection:0];
        [_lotteryNumberTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self updateBottomView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
    
}

//点击背景让键盘消失
- (void)tapToHideKeyboard:(UITapGestureRecognizer *)gesture {
    for (UITextField *textf in _inputView.subviews) {
        if([textf isKindOfClass:[UITextField class]]) {
            [_inputField resignFirstResponder];
        }
    }
    
    for (UITextField *textf1 in _scrollView.subviews) {
        if([textf1 isKindOfClass:[UITextField class]]) {
            [_moneyField resignFirstResponder];
        }
    }
}

//键盘出现的时候响应
- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!_overlayView) {
        _overlayView = [[UIView alloc]initWithFrame:self.view.bounds];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:0.5];
        [self.view addSubview:_overlayView];
        [_overlayView release];
    } else {
        [_overlayView setHidden:NO];
        [self.view bringSubviewToFront:_overlayView];
    }
    [self.view bringSubviewToFront:_inputView];
    
    //给半透明背景加上点击事件  让键盘消失
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToHideKeyboard:)];
    [_overlayView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    //获得键盘的高度
    NSDictionary *userInfo = notification.userInfo;
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardRect = [value CGRectValue];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.28];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [_inputView setFrame:CGRectMake(0, kScreenSize.height - keyBoardRect.size.height - kInputViewHeight - 64.0f, kWinSize.width, kInputViewHeight)];
    
    [UIView commitAnimations];
}

//键盘消失时响应
- (void)keyboardWillHide:(NSNotification *)notification {
    
    [_overlayView setHidden:YES];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [_inputView setFrame:CGRectMake(0, kScreenSize.height - kBottomHeight - kInputViewHeight - 64.0f, kWinSize.width, kInputViewHeight)];
    
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 时刻监测购买金额的变化
- (void)moneyChange:(id)sender {
    UITextField *textField = sender;
    
    if([textField.text integerValue] > 20000) {
        textField.text = [NSString stringWithFormat:@"2000"];
        
        [XYMPromptView defaultShowInfo:@"最多只能投1000注" isCenter:YES];
    }
}

#pragma mark - 增减购买金额
- (void)bonusChange:(UIButton *)btn {
    NSInteger temp = [_moneyField.text integerValue];
    
    switch (btn.tag) {
        case 1:
        {
            temp -= 2;
            _betCount --;
            
            if (temp < _tbCount * 2) {
                temp = _tbCount * 2;
                
                _betCount = _tbCount;
                [XYMPromptView defaultShowInfo:[NSString stringWithFormat:@"最少投%d注", _tbCount] isCenter:NO];
            }
            
            _moneyField.text = [NSString stringWithFormat:@"%ld", (long)temp];
            [_bottomView setMatchCount:_betCount money:temp];
            
            [self optimizedDataSort:0];
        }
            break;
        case 2:
        {
            temp += 2;
            _betCount ++;
            
            if (temp > 20000) {
                temp = 20000;
                
                _betCount = 10000;
                [XYMPromptView defaultShowInfo:@"最多只能投10000注" isCenter:NO];
            }
            
            _moneyField.text = [NSString stringWithFormat:@"%ld", (long)temp];
            [_bottomView setMatchCount:_betCount money:temp];
            [self optimizedDataSort:1];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 优化分类切换 （平均、搏冷、博热）
- (void)contentChange:(UIButton *)btn
{
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:11];
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:12];
    UIButton *btn3 = (UIButton *)[self.view viewWithTag:13];
    
    // 搏冷、博热不支持组合玩法
    if (btn.tag == 12 || btn.tag == 13) {
        
        if (_passWayArray.count > 1) {
            [XYMPromptView defaultShowInfo:@"暂不支持组合玩法" isCenter:YES];
            
            return;
        }
        
        if (btn.tag == 12) {
            // 获取搏热对阵
            [self heatTeam];
            
        }else {
            // 获取博冷对阵
            [self coldTeam];
        }
    }
    // 切换优化类型，还原数据
    [self getAgainst];
    
    switch (btn.tag) {
        case 11:    // 平均优化
        {
            if (!btn1.selected) {
                btn1.selected = !btn1.selected;
                btn2.selected = NO;
                btn3.selected = NO;
                
                _preBetType = 1;
                [self lineAnimation:0];
            }
        }
            break;
        case 12:    // 博热优化
        {
            if (!btn2.selected) {
                btn2.selected = !btn2.selected;
                btn1.selected = NO;
                btn3.selected = NO;
                
                _preBetType = 2;
                [self lineAnimation:1];
            }
            
        }
            break;
        case 13:    // 搏冷优化
        {
            if (!btn3.selected) {
                btn3.selected = !btn3.selected;
                btn1.selected = NO;
                btn2.selected = NO;
                
                _preBetType = 3;
                [self lineAnimation:2];
            }
        }
            break;
    }
    
}

// 线条动画效果
- (void)lineAnimation: (int)tab {
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = _lineView.frame;
        rect.origin.x = lineWidth * tab;
        _lineView.frame = rect;
    }];
    
}

#pragma mark - updateBottomView更新底部注数金额
// 更新底部注数及金额
- (void)updateBottomView {
    
    NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
    
    _betCount = 0;
    for (NSDictionary *dic in _resultArray) {
        // 所有注数
        _betCount += [[dic objectForKey:@"playCount"] integerValue];
    }
    
    // 金额
    _moneyField.text = [NSString stringWithFormat:@"%ld", (long)(_betCount * multiple * 2)];
    [_bottomView setMatchCount:_betCount money:_betCount * multiple * 2];
}

#pragma mark - 获取对阵信息
- (void)getAgainst {
    
    NSMutableArray *arrSelectMatch = [NSMutableArray array];
    for (NSDictionary *dic in _selectMatchArray) {
        [arrSelectMatch addObject:[dic objectForKey:@"selectArray"]];
    }
    
    [_resultArray removeAllObjects];
    
    if (_footBallPassBarrierType == FootBallPassBarrierType_singleMacth || _basketBallPassBarrierType == BasketBallPassBarrierType_singleMacth) { //单关
        
        _resultArray = [CalculateBetCount getOneMatchWithArray:_selectMatchArray ballType:_ballType];
        
    } else {
        
        // 拆分原对阵数据，获取优化后的对阵数据
        for (NSString *str in _passWayArray) {
            
            NSArray *numberArray = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"串"]];
            _resultArray = [CalculateBetCount getAgainstWithN:[[numberArray objectAtIndex:0] integerValue] m:1 selectMatchArray:_selectMatchArray arrayWithResult:_resultArray ballType:_ballType];
        }
    }
    // 根据对阵的数量，算出页面的高度
    CGFloat tableViewHeight = 40;
    for (int cur = 0; cur < _resultArray.count; cur++) {
        
        NSArray *array =  [[_resultArray objectAtIndex:cur] objectForKey:@"team"];
        tableViewHeight += array.count * 30;
    }
    
    // 最少注数
    _tbCount = (int)_resultArray.count;
    // 重新格式化tableView宽高
    _lotteryNumberTableView.frame = CGRectMake(0, 96, kWinSize.width, tableViewHeight);
    [_scrollView setContentSize:CGSizeMake(kWinSize.width, tableViewHeight + 96 + 10)];
    [_lotteryNumberTableView reloadData];
    
    [self updateBottomView];
}

#pragma mark - 进入合买模块
- (void)chippedClick:(id)sender {
    if(_passWayArray == nil || _passWayArray.count == 0) {
        [Globals alertWithMessage:@"未选择过关方式，不能进行合买"];
        return;
    }
    [self loadLaunchChippedProportion];
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

- (void)getlaunchChippedProportionFailed:(ASIHTTPRequest *)request {
    
}

- (void)getlaunchChippedProportionFinshed:(ASIHTTPRequest *)request {
    NSDictionary *dict = [[request responseString]objectFromJSONString];
    
    if (dict) {
        _globals.commission = [dict floatValueForKey:@"yongjin"];
        _globals.minBuyScale = [dict floatValueForKey:@"rengou"];
        
        NSMutableDictionary *chippedDic = [NSMutableDictionary dictionary];
        NSMutableDictionary *lotteryDic = [NSMutableDictionary dictionary];
        [lotteryDic setObject:_lotteryId forKey:@"lotteryid"];
        [lotteryDic setObject:@"-1" forKey:@"isuseId"];
        
        [chippedDic setObject:lotteryDic forKey:@"lotteryDic"];
        [chippedDic setObject:[self getBuyContent] forKey:@"buyContent"];
        [chippedDic setObject:[NSString stringWithFormat:@"%ld", (long)_betCount] forKey:@"betCount"];
        [chippedDic setObject:_inputField.text forKey:@"multiple"];
        
        LaunchChippedViewController *launchChipped = [[LaunchChippedViewController alloc]initWithBetDictionary:chippedDic];
        launchChipped.isBonusOptimization = 1;
        launchChipped.schemeCodes = [self getSchemeCodes];
        launchChipped.gGWay = [self getGGWay];
        launchChipped.investNum = [self getInvestNum];
        launchChipped.playTeam = [self getPlayTeam];
        launchChipped.playTypeID = _playType;
        launchChipped.matchID = [self getMatchID];
        launchChipped.codeFormat = _codeFormat;
        launchChipped.castMoney = [self getCastMoney];
        launchChipped.preBetType = [NSString stringWithFormat:@"%ld", (long)_preBetType];
        [self.navigationController pushViewController:launchChipped animated:YES];
        [launchChipped release];
    }
}

- (NSArray *)getBuyContent {
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSInteger mul = [_inputField.text integerValue];
    
    [dic setObject:_playType forKey:@"playType"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)(_betCount * 2 * (mul == 0 ? 1 : mul))] forKey:@"sumMoney"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)_betCount] forKey:@"sumNum"];
    [dic setObject:[self getPlayTeam] forKey:@"lotteryNumber"];
    [array addObject:dic];
    return array;
}

- (NSArray *)selectNormalArray {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in _selectMatchArray) {
        if(![[dic objectForKey:@"isDan"] boolValue]) {
            [array addObject:dic];
        }
    }
    return array;
}

#pragma mark - 付款
- (void)pay:(id)sender {
    
    if([UserInfo shareUserInfo].userID) {
        
        if (_betCount < 0) {
            [Globals alertWithMessage:@"计算结果超出范围，请重新选号"];
            return;
        }
        
        if (_allstr && _allstr.length>0) {
            DuangAlert *duang = [[DuangAlert alloc] initWithTitle:@"发起复制需要填写以下内容" settings:@[@"永久公开",@"开赛后公开"] selected:^(NSInteger index, NSDictionary *backDic) {
                if (index == 1) {
                    _secrecyLevel = [[backDic objectForKey:@"index"] integerValue] == 0 ? @"0" : @"2";
                    _description = [[backDic objectForKey:@"text"] copy];
                    
                    CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%@元",_moneyField.text] leftText:@"取消" rightText:@"确定"];
                    [customAlert setTag:76];
                    [customAlert show];
                    [customAlert release];

                }
            }];
            [duang show];
            [duang release];
        }else{
            CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%@元",_moneyField.text] leftText:@"取消" rightText:@"确定"];
            [customAlert setTag:76];
            [customAlert show];
            [customAlert release];
        }
        
    } else {
        // 登录
        UserLoginViewController *login = [[UserLoginViewController alloc]init];
        XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
        [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = loginNav;
        [self.view.window.rootViewController presentViewController:loginNav animated:YES completion:nil];
        [login release];
        [loginNav release];
        return;
    }
}

- (void)payRequest{
    [SVProgressHUD showWithStatus:@"正在付款"];
    NSInteger mul = [_inputField.text integerValue];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    if (_ballType == 0) {
        [infoDic setObject:[NSString stringWithFormat:@"72"] forKey:@"lotteryId"];
    }else {
        [infoDic setObject:[NSString stringWithFormat:@"73"] forKey:@"lotteryId"];
    }
    
    [infoDic setObject:[self getSchemeCodes] forKey:@"SchemeCodes"];
    [infoDic setObject:[self getGGWay] forKey:@"GGWay"];
    [infoDic setObject:[self getInvestNum] forKey:@"InvestNum"];
    [infoDic setObject:[self getPlayTeam] forKey:@"PlayTeam"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)(mul == 0 ? 1 : mul)] forKey:@"Multiple"];
    [infoDic setObject:[self getCastMoney] forKey:@"CastMoney"];
    [infoDic setObject:_playType forKey:@"PlayTypeID"];
    [infoDic setObject:[self getMatchID] forKey:@"MatchID"];
    [infoDic setObject:_codeFormat forKey:@"CodeFormat"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)_preBetType] forKey:@"PreBetType"];
    [infoDic setObject:@"" forKey:@"SchemeTitle"];
    [infoDic setObject:@"" forKey:@"SchemeContent"];
    [infoDic setObject:@"0.00" forKey:@"AssureMoney"];
    [infoDic setObject:@"1" forKey:@"Share"];
    [infoDic setObject:@"1" forKey:@"BuyShare"];
    [infoDic setObject:@"0" forKey:@"SecrecyLevel"];
    [infoDic setObject:@"0" forKey:@"SchemeBonusScale"];
    if (_allstr == nil || [_allstr isEqualToString:@""]) {
        
    }else{
        [infoDic setObject:_secrecyLevel forKey:@"secrecyLevel"];
        [infoDic setObject:_description forKey:@"description"];
        [infoDic setObject:_allstr forKey:@"isMayCopy"];
    }
    
    [_orderDetailDict removeAllObjects];
    [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",(long)(_betCount * (mul == 0 ? 1 : mul) * 2)] forKey:@"consumeMoney"];
    
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
    NSLog(@"infoDic -> %@", infoDic);
    
    // 奖金优化购买数据特殊处理
    // 对阵过多，采用POST方法发送数据。
    NSString *str = [NSString stringWithFormat:@"%@", kBaseUrl];
    NSURL *urlStr1 = [NSURL URLWithString:str];
    _httpRequest = [ASIFormDataRequest requestWithURL:urlStr1];
    _httpRequest.requestMethod = @"POST";
    _httpRequest.timeOutSeconds = 60;
    //2.POST将请求参数放在请求体中
    // auth
    NSString *infoStr = [[infoDic JSONString] copy];
    NSString *currentDate = [InterfaceHelper getCurrentDateString];
    NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    
    [_httpRequest addPostValue:auth forKey:@"auth"];
    [_httpRequest addPostValue:infoStr forKey:@"info"];
    [_httpRequest addPostValue:@"72" forKey:@"opt"];
    
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];

}

#pragma mark - ASIHTTPRequestDelegate 付款代理
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"支付失败"];
    
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    [SVProgressHUD showSuccessWithStatus:@"支付成功"];
    
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
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
        if (_ballType == 0) {
            [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",(long)72] forKey:@"lotteryId"];
        }else {
            [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",(long)73] forKey:@"lotteryId"];
        }
        
        PaySucceedViewController *paySucceedViewController = [[PaySucceedViewController alloc] initWithDict:_orderDetailDict buyType:NORMAL];
        [self.navigationController pushViewController:paySucceedViewController animated:YES];
        [paySucceedViewController release];
        
    } else if (responseDic && [[responseDic objectForKey:@"error"] intValue] == -134) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"] delegate:self tag:2];
    } else if(responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }else {
        
        [Globals alertWithMessage:@"数据请求失败。"];
        
    }
}

#pragma mark - 获取付款 串数 参数
- (NSString *)getGGWay {
    
    // 创建可变字符串
    NSMutableString *joinString = [[NSMutableString alloc] init];
    
    // 遍历串数数组
    for (int i = 0; i < _resultArray.count; i++) {
        [joinString appendString:[NSString stringWithFormat:@"%@-",[_resultArray[i] objectForKey:@"GGWay"]]];
    }
    NSString *gGWay = [joinString substringWithRange:NSMakeRange(0, [joinString length] - 1)];
    
    return gGWay;
    [joinString release];
}

#pragma mark - 获取付款 赛事ID 参数
- (NSString *)getCastMoney {
    // 创建可变字符串
    NSMutableString *joinString = [[NSMutableString alloc] init];

    for (int i = 0; i < _resultArray.count; i++) {
        [joinString appendString:[NSString stringWithFormat:@"%@-",[_resultArray[i] objectForKey:@"castMoney"]]];
    }
    
    NSString *castMoney = [joinString substringWithRange:NSMakeRange(0, [joinString length] - 1)];
    return castMoney;
    [castMoney release];
}

#pragma mark - 获取付款 赛事ID 参数
- (NSString *)getMatchID {
    
    // 创建可变字符串
    NSMutableString *joinString = [[NSMutableString alloc] init];
    
    if ([self.selectNormalArray count] > 0) {
        
        for (NSDictionary *dic in self.selectNormalArray) {
            NSString *matchId = [[dic objectForKey:@"selectRowDic"] objectForKey:@"matchId"];
            NSArray *selectArray = [dic objectForKey:@"selectArray"];
            if (selectArray.count == 0)
                continue;
            [joinString appendString:[NSString stringWithFormat:@"%@,", matchId]];
        }
    }
    
    NSString *matchID = [joinString substringWithRange:NSMakeRange(0, [joinString length] - 1)];
    return matchID;
    [matchID release];
}

#pragma mark - 获取付款 注数 参数
- (NSString *)getInvestNum {
    
    // 创建可变字符串
    NSMutableString *joinString = [[NSMutableString alloc] init];
    
    for (int i = 0; i < _resultArray.count; i++) {
        [joinString appendString:[NSString stringWithFormat:@"%@-", [_resultArray[i] objectForKey:@"playCount"]]];
    }
    
    NSString *investNum = [joinString substringWithRange:NSMakeRange(0, [joinString length] - 1)];
    return investNum;
    [investNum release];
}

#pragma mark - 获取付款 方案代码 参数
- (NSString *)getSchemeCodes {
    
    // 创建可变字符串
    NSMutableString *joinString = [[NSMutableString alloc] init];
    
    for (int i = 0; i < _resultArray.count; i++) {
        
        [joinString appendString:[NSString stringWithFormat:@"%@;[", _playType]];
        
        NSArray *teamArr = [_resultArray[i] objectForKey:@"team"];
        
        for (NSDictionary *dic in teamArr) {
            
            [joinString appendString:[NSString stringWithFormat:@"%@(%@)|", [dic objectForKey:@"matchId"], [dic objectForKey:@"resultsKey"]]];
            
        }
        // 把串数转换成 内置处理表达方式，方便处理
        NSString *chuanStr = [PassWayUtility getPassWayCodeWithString:[_resultArray[i] objectForKey:@"GGWay"]];
        
        [joinString appendString:[NSString stringWithFormat:@"];[%@%d];-", chuanStr, [_inputField.text intValue] * [[_resultArray[i] objectForKey:@"playCount"] intValue]]];
    }
    
    // 去除多余的 "|"
    [joinString replaceOccurrencesOfString:@")|]" withString:@")]" options:NSLiteralSearch range:NSMakeRange(0, [joinString length])];
    NSString *schemeCodes = [joinString substringWithRange:NSMakeRange(0, [joinString length] - 1)];
    
    return schemeCodes;
    [joinString release];
}

#pragma mark - 获取付款 对阵信息 参数
// 7207;[536(1)|537(2)];[AA1];-7207;[536(1)|538(1)];[AA1];
- (NSString *)getPlayTeam {
    
    // 创建可变字符串
    NSMutableString *joinString = [[NSMutableString alloc] init];
    
    for (int i = 0; i < _resultArray.count; i++) {
    
        NSArray *teamArr = [_resultArray[i] objectForKey:@"team"];
        
        for (NSDictionary *dic in teamArr) {
            
            [joinString appendString:[NSString stringWithFormat:@"%@(%@);%@|", [dic objectForKey:@"matchId"], [dic objectForKey:@"resultsKey"], [dic objectForKey:@"odds"]]];
        }
        
        [joinString appendString:@"-"];
    }
    
    NSString *playTeam = [joinString substringWithRange:NSMakeRange(0, [joinString length] - 1)];
    
    return playTeam;
    [joinString release];
}

#pragma mark - OptimizedDataSort 优化对阵数据处理
// 平均优化: 每个对阵预测奖金不低于购买金额
// 搏热优化: 在其他对阵预测奖金不低于购买金额时，新增加的注数全都加在最热门对阵上。 (赔率最低)
// 搏冷优化: 在其他对阵预测奖金不低于购买金额时，新增加的注数全都加在最冷门对阵上。 (赔率最高)

// type: 增减金额（1: 增加   0: 减少）
- (void) optimizedDataSort: (int)type {
    
    switch (_preBetType) {
        case 1:     // 平均
        {
            if (type == 1) {
                [self averageAdd];
            }else if (type == 0){
                [self averageReduce];
            }
            
        }
            break;
        case 2:     // 博热
        {
                [self fightTeamTag:_heat oddsWithFightTeam:_heatCastMoney addAndSubtract:type];
        }
            break;
        case 3:     // 搏冷
        {
            [self fightTeamTag:_cold oddsWithFightTeam:_coldCastMoney addAndSubtract:type];
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark  平均优化
// 平均优化 点击 + 调用方法
-(void)averageAdd {
    
    int s = 0;
    float temp = [[_resultArray[0] objectForKey:@"castMoney"] floatValue];
    
    for (int i = 0; i < _resultArray.count; i++) {
        if ((temp > [[_resultArray[i] objectForKey:@"castMoney"] floatValue])) {
            
            temp = [[_resultArray[i] objectForKey:@"castMoney"] floatValue];
            
            s = i;
        }
    }
    
    
    int playCount = [[_resultArray[s] objectForKey:@"playCount"] intValue];
    NSArray *teamArr = [_resultArray[s] objectForKey:@"team"];
    float castMoney = teamArr.count;
    for (NSDictionary *dic in teamArr) {
        // 获取对阵最初预测奖金
        castMoney = castMoney * [[dic objectForKey:@"odds"] floatValue];
    }
    
    // 更新对阵注数
    [_resultArray[s] setObject:[NSString stringWithFormat:@"%d", playCount + 1] forKey:@"playCount"];
    // 更新对阵预测奖金
    [_resultArray[s] setObject:[NSString stringWithFormat:@"%.2f", (playCount + 1) * castMoney] forKey:@"castMoney"];
    
    // 刷新数据
    [_lotteryNumberTableView reloadData];
}

// 平均优化 点击 - 调用方法
- (void)averageReduce {
    
    int s = 0;
    float temp = [[_resultArray[0] objectForKey:@"castMoney"] floatValue];
    
    for (int i = 0; i < _resultArray.count; i++) {
        if ([[_resultArray[i] objectForKey:@"playCount"] intValue] > 1) {
            if ((temp < [[_resultArray[i] objectForKey:@"castMoney"] floatValue])) {
                
                temp = [[_resultArray[i] objectForKey:@"castMoney"] floatValue];
                
                s = i;
            }
        }
    }
    
    
    int playCount = [[_resultArray[s] objectForKey:@"playCount"] intValue];
    
    NSArray *teamArr = [_resultArray[s] objectForKey:@"team"];
    float castMoney = teamArr.count;
    for (NSDictionary *dic in teamArr) {
        
        castMoney = castMoney * [[dic objectForKey:@"odds"] floatValue];
    }
    
    if (playCount > 1) {
        [_resultArray[s] setObject:[NSString stringWithFormat:@"%d", playCount - 1] forKey:@"playCount"];
        [_resultArray[s] setObject:[NSString stringWithFormat:@"%.2f", (playCount - 1) * castMoney] forKey:@"castMoney"];
    }
    
    [_lotteryNumberTableView reloadData];
    
}

#pragma mark  博热优化、搏冷 点击 +- 调用方法
// tag: 优化对阵索引
// fightTeamOdds: 优化对阵赔率
// addOrSub: 增加、减少购买金额按钮
- (void)fightTeamTag: (int)tag oddsWithFightTeam: (float)fightTeamOdds addAndSubtract:(int) addOrSub{
    
    // 对阵索引
    int s = 0;
    float temp = [[_resultArray[0] objectForKey:@"castMoney"] floatValue];
    
    // 获取赔率最低对阵 (除优化博热、搏冷优化对阵外)
    for (int i = 0; i < _resultArray.count; i++) {
        if ([[_resultArray[i] objectForKey:@"playCount"] intValue] > 0) {
            
            // 增加、减少按钮 （1: 增加    0: 减少）
            // 取出最低赔率的对阵索引
            if (addOrSub == 1) {
                if ((temp > [[_resultArray[i] objectForKey:@"castMoney"] floatValue] && i != tag)) {
                    
                    temp = [[_resultArray[i] objectForKey:@"castMoney"] floatValue];
                    
                    s = i;
                }
            }else {
                if ((temp <[[_resultArray[i] objectForKey:@"castMoney"] floatValue] && i != tag)) {
                    
                    temp = [[_resultArray[i] objectForKey:@"castMoney"] floatValue];
                    
                    s = i;
                }
            }
        }
    }

    NSArray *teamArr = [_resultArray[s] objectForKey:@"team"];
    float castMoney = teamArr.count;
    for (NSDictionary *dic in teamArr) {
        // 得出对阵赔率 (除去优化对阵外的最低对阵赔率)
        castMoney = castMoney * [[dic objectForKey:@"odds"] floatValue];
    }
    
    // 判断其他对阵预测奖励是否低于购买金额。
    // 如果低于，则增加注数
    // 否则增加博热对阵
    int playCount = [[_resultArray[s] objectForKey:@"playCount"] intValue];
    int index;      // 优化对阵对应 tableViewCell 索引
    
    if (addOrSub == 1) {
        if ([[_resultArray[s] objectForKey:@"castMoney"] floatValue] < [_moneyField.text floatValue] && playCount < 20000) {
            
            // 更新对阵注数
            [_resultArray[s] setObject:[NSString stringWithFormat:@"%d", playCount + 1] forKey:@"playCount"];
            // 更新对阵预测奖金
            [_resultArray[s] setObject:[NSString stringWithFormat:@"%.2f", (playCount + 1) * castMoney] forKey:@"castMoney"];
            
            index = s;
        }else {
            playCount = [[_resultArray[tag] objectForKey:@"playCount"] intValue];
            index = tag;
            
            // 更新对阵注数
            [_resultArray[tag] setObject:[NSString stringWithFormat:@"%d", playCount + 1] forKey:@"playCount"];
            // 更新对阵预测奖金
            [_resultArray[tag] setObject:[NSString stringWithFormat:@"%.2f", (playCount + 1) * fightTeamOdds] forKey:@"castMoney"];
            
        }
        
    }else {
        
        if ([[_resultArray[s] objectForKey:@"castMoney"] floatValue] > [_moneyField.text floatValue] && playCount > 1) {
            
            // 更新对阵注数
            [_resultArray[s] setObject:[NSString stringWithFormat:@"%d", playCount - 1] forKey:@"playCount"];
            // 更新对阵预测奖金
            [_resultArray[s] setObject:[NSString stringWithFormat:@"%.2f", (playCount - 1) * castMoney] forKey:@"castMoney"];
            
            index = s;
        }else {
            playCount = [[_resultArray[tag] objectForKey:@"playCount"] intValue];
            index = tag;
            
            if (playCount > 1) {
                // 更新对阵注数
                [_resultArray[tag] setObject:[NSString stringWithFormat:@"%d", playCount - 1] forKey:@"playCount"];
                // 更新对阵预测奖金
                [_resultArray[tag] setObject:[NSString stringWithFormat:@"%.2f", (playCount - 1) * fightTeamOdds] forKey:@"castMoney"];
            }
            
        }
    }
    
    // 单条刷新数据
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_lotteryNumberTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - 取出博热对阵
- (void)heatTeam {
    
    _heat = 0;
    float temp = [[_resultArray[0] objectForKey:@"castMoney"] floatValue];
    
    for (int i = 0; i < _resultArray.count; i++) {
        if ((temp > [[_resultArray[i] objectForKey:@"castMoney"] floatValue])) {
            
            temp = [[_resultArray[i] objectForKey:@"castMoney"] floatValue];
            
            _heat = i;
        }
    }
    
    NSArray *teamArr = [_resultArray[_heat] objectForKey:@"team"];
    _heatCastMoney = teamArr.count;
    for (NSDictionary *dic in teamArr) {
        // 获取对阵最初预测奖金
        _heatCastMoney = _heatCastMoney * [[dic objectForKey:@"odds"] floatValue];
    }
    
}

#pragma mark - 取出博冷对阵
- (void)coldTeam {
    
    _cold = 0;
    float temp = [[_resultArray[0] objectForKey:@"castMoney"] floatValue];
    
    for (int i = 0; i < _resultArray.count; i++) {
        if ((temp < [[_resultArray[i] objectForKey:@"castMoney"] floatValue])) {
            
            temp = [[_resultArray[i] objectForKey:@"castMoney"] floatValue];
            
            _cold = i;
        }
    }
    
    NSArray *teamArr = [_resultArray[_cold] objectForKey:@"team"];
    _coldCastMoney = teamArr.count;
    for (NSDictionary *dic in teamArr) {
        // 获取对阵最初预测奖金
        _coldCastMoney = _coldCastMoney * [[dic objectForKey:@"odds"] floatValue];
    }
    
}

@end
