//
//  CapitalDetailViewController.m 个人中心－资金明细
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140825 11:25（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//20140825 11:44（洪晓彬）：进行ipad适配

#import "CapitalDetailViewController.h"
#import "DialogDatePickerView.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "QuartzCore/QuartzCore.h"

#define kPageSize 30
#define CapitalDetailViewTabelCellHeight (IS_PHONE ? 35.0f : 50.0f)
#define dateSelectViewSize (IS_PHONE ? CGSizeMake(300.0f, 280.0f) : CGSizeMake(480.0f, 360.0f))//日期选择框的大小

@interface CapitalDetailViewController ()
/** 显示加载视图 */
- (void)showProgressHud;
/** 根据日期请求资金明细数据 */
- (void)getCurrentDate;
/** 根据传入的年月来计算该年月包含的天数，用来向服务器传入查询的时间范围（1个月）
 @param year 年
 @param month 月*/
- (void)getNumberOfDaysInMonthWithYear:(NSString *)year Month:(NSString *)month;
/** 根据日期加载数据 
 @param year 年
 @param month 月*/
- (void)loadDataWithYear:(NSString *)year Month:(NSString *)month;
/** 根据返回的数据填充显示的label
 @param dic 月详细的总支出，总收入，中奖的数据字典
 @param year 查询的年
 @param month 查询的月*/
- (void)fillTopDataWithInfo:(NSDictionary *)dic year:(NSString *)year month:(NSString *)month;
/** 处理服务器返回的明细数据，用来填充label和判断是否还有数据
 @param dic 用于填充用的月详细的总支出，总收入，中奖的数据字典*/
- (void)processData:(NSDictionary *)dic;
@end

#pragma mark -
#pragma mark @implementation CapitalDetailViewController
@implementation CapitalDetailViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"资金明细"];
    }
    return self;
}

- (void)dealloc {
    _dateLabel = nil;
    _sumIncomeLabel = nil;
    _sumExpendLabel = nil;
    _sumWinningLabel = nil;
    
    _allTypeBtn = nil;
    _incomeBtn = nil;
    _enpendBtn = nil;
    
    _amountTextField = nil;
    _typeTextField = nil;
    _timeTextField = nil;
    _memoTextField = nil;
    
    _infoTableView = nil;
    _progressHud = nil;
    
    [_recordsArray release];
    _recordsArray = nil;
    [_detailDic release];
    _detailDic = nil;
    [_selectRowDic release];
    _selectRowDic = nil;
    
    [_selectYear release];
    _selectYear = nil;
    [_selectMonth release];
    _selectMonth = nil;
    [_startDate release];
    _startDate = nil;
    [_endDate release];
    _endDate = nil;
    
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
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //selectDateBtn 筛选按钮
    UIButton *selectDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectDateBtn setFrame:XFIponeIpadNavigationCalendarFiltrateButtonRect];
    [selectDateBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"calendar.png"]] forState:UIControlStateNormal];
    [selectDateBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"calendar.png"]] forState:UIControlStateHighlighted];
    [selectDateBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [selectDateBtn addTarget:self action:@selector(selectDateTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectDateItem = [[UIBarButtonItem alloc]initWithCustomView:selectDateBtn];
    [self.navigationItem setRightBarButtonItem:selectDateItem];
    [selectDateItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat buttonWidth = CGRectGetWidth(appRect) / 3.0f;//button的宽度
    CGFloat buttonHeight = IS_PHONE ? 35.0f : 50.0f;//button的高度
    CGFloat buttonInterval = 0.0;//button之间的间距
    
    CGFloat firstTextFieldMinX = IS_PHONE ? 5.0f : 10.0f;//第一个TextField的x
    CGFloat allTextFieldHeight = IS_PHONE ? 30.0f : 50.0f;//所有TextField的高度
    
    CGFloat firstTextFieldWidth = 65.5f * (kWinSize.width / 320.0f);
    CGFloat secondTextFieldWidth = 62.5f * (kWinSize.width / 320.0f);
    CGFloat threeTextFieldWidth = 67.0 * (kWinSize.width / 320.0f);
    CGFloat fourTextFieldWidth = 114.5f * (kWinSize.width / 320.0f);
    
    CGFloat buttonTextFieldVerticalInterval = IS_PHONE ? 0.0f : 16.0f;//button和TextField之间的垂直间距
    /********************** adjustment end ***************************/
    
    //allTypeBtn 全部类型按钮
    CGRect allTypeBtnRect = CGRectMake(0, 0, buttonWidth, buttonHeight);
    _allTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allTypeBtn setFrame:allTypeBtnRect];
    [_allTypeBtn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [_allTypeBtn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [_allTypeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
    [_allTypeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateDisabled];
    [_allTypeBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_allTypeBtn setTitle:@"全部类型" forState:UIButtonTypeCustom];
    [_allTypeBtn setTitleColor:[UIColor blackColor] forState:UIButtonTypeCustom];
    [_allTypeBtn setTitleColor:[UIColor colorWithRed:0xff/255.0f green:0x8a/255.0f blue:0x00/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [_allTypeBtn addTarget:self action:@selector(getAllTypeDataTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_allTypeBtn setSelected:YES];
    [self.view addSubview:_allTypeBtn];
    
    //incomeBtn 收入按钮
    CGRect incomeBtnRect = CGRectMake(CGRectGetMaxX(allTypeBtnRect) + buttonInterval, CGRectGetMinY(allTypeBtnRect), buttonWidth, buttonHeight);
    _incomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_incomeBtn setFrame:incomeBtnRect];
    [_incomeBtn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [_incomeBtn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [_incomeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
    [_incomeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateDisabled];
    [_incomeBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_incomeBtn setTitle:@"收入" forState:UIButtonTypeCustom];
    [_incomeBtn setTitleColor:[UIColor blackColor] forState:UIButtonTypeCustom];
    [_incomeBtn setTitleColor:[UIColor colorWithRed:0xff/255.0f green:0x8a/255.0f blue:0x00/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [_incomeBtn addTarget:self action:@selector(getIncomeDataTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_incomeBtn];
    
    //enpendBtn 支出按钮
    CGRect enpendBtnRect = CGRectMake(CGRectGetMaxX(incomeBtnRect) + buttonInterval, CGRectGetMinY(incomeBtnRect), buttonWidth, buttonHeight);
    _enpendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_enpendBtn setFrame:enpendBtnRect];
    [_enpendBtn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [_enpendBtn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [_enpendBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
    [_enpendBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowBottomLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateDisabled];
    [_enpendBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_enpendBtn setTitle:@"支出" forState:UIButtonTypeCustom];
    [_enpendBtn setTitleColor:[UIColor blackColor] forState:UIButtonTypeCustom];
    [_enpendBtn setTitleColor:[UIColor colorWithRed:0xff/255.0f green:0x8a/255.0f blue:0x00/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [_enpendBtn addTarget:self action:@selector(getExpendDataTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_enpendBtn];
    
    //amountTextField 金额－提示文字
    CGRect amountTextFieldRect = CGRectMake(firstTextFieldMinX, CGRectGetMaxY(allTypeBtnRect) + buttonTextFieldVerticalInterval, firstTextFieldWidth, allTextFieldHeight);
    _amountTextField = [[UITextField alloc] initWithFrame:amountTextFieldRect];
    [_amountTextField setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [_amountTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_amountTextField setEnabled:NO];
    [_amountTextField setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [_amountTextField setTextAlignment:NSTextAlignmentCenter];
    [_amountTextField setText:@"金额"];
    [self.view addSubview:_amountTextField];
    [_amountTextField release];
    //卧槽，画个鸟线，为毛一定只能一像素
    CGRect line1_1Rect = CGRectMake(CGRectGetMinX(amountTextFieldRect), CGRectGetMinY(amountTextFieldRect), CGRectGetWidth(amountTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line1_1Rect inSuperView:self.view];
    
    CGRect line1_2Rect = CGRectMake(CGRectGetMinX(amountTextFieldRect), CGRectGetMinY(amountTextFieldRect), AllLineWidthOrHeight, CGRectGetHeight(amountTextFieldRect));
    [Globals makeLineWithFrame:line1_2Rect inSuperView:self.view];
    
    CGRect line1_3Rect = CGRectMake(CGRectGetMinX(amountTextFieldRect), CGRectGetMaxY(amountTextFieldRect), CGRectGetWidth(amountTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line1_3Rect inSuperView:self.view];
    
    
    //typeTextField 类型－提示文字
    CGRect typeTextFieldRect = CGRectMake(CGRectGetMaxX(amountTextFieldRect), CGRectGetMinY(amountTextFieldRect), secondTextFieldWidth, allTextFieldHeight);
    _typeTextField = [[UITextField alloc] initWithFrame:typeTextFieldRect];
    [_typeTextField setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [_typeTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_typeTextField setEnabled:NO];
    [_typeTextField setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [_typeTextField setTextAlignment:NSTextAlignmentCenter];
    [_typeTextField setText:@"类型"];
    [self.view addSubview:_typeTextField];
    [_typeTextField release];
    
    CGRect line2_1Rect = CGRectMake(CGRectGetMinX(typeTextFieldRect), CGRectGetMinY(typeTextFieldRect), CGRectGetWidth(typeTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line2_1Rect inSuperView:self.view];
    
    CGRect line2_2Rect = CGRectMake(CGRectGetMinX(typeTextFieldRect), CGRectGetMinY(typeTextFieldRect), AllLineWidthOrHeight, CGRectGetHeight(typeTextFieldRect));
    [Globals makeLineWithFrame:line2_2Rect inSuperView:self.view];
    
    CGRect line2_3Rect = CGRectMake(CGRectGetMinX(typeTextFieldRect), CGRectGetMaxY(typeTextFieldRect), CGRectGetWidth(typeTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line2_3Rect inSuperView:self.view];
    
    
    //timeTextField 时间－提示文字
    CGRect timeTextFieldRect = CGRectMake(CGRectGetMaxX(typeTextFieldRect), CGRectGetMinY(typeTextFieldRect), threeTextFieldWidth, allTextFieldHeight);
    _timeTextField = [[UITextField alloc] initWithFrame:timeTextFieldRect];
    [_timeTextField setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [_timeTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_timeTextField setEnabled:NO];
    [_timeTextField setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [_timeTextField setTextAlignment:NSTextAlignmentCenter];
    [_timeTextField setText:@"时间"];
    [self.view addSubview:_timeTextField];
    [_timeTextField release];
    
    CGRect line3_1Rect = CGRectMake(CGRectGetMinX(timeTextFieldRect), CGRectGetMinY(timeTextFieldRect), CGRectGetWidth(timeTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line3_1Rect inSuperView:self.view];
    
    CGRect line3_2Rect = CGRectMake(CGRectGetMinX(timeTextFieldRect), CGRectGetMinY(timeTextFieldRect), AllLineWidthOrHeight, CGRectGetHeight(timeTextFieldRect));
    [Globals makeLineWithFrame:line3_2Rect inSuperView:self.view];
    
    CGRect line3_3Rect = CGRectMake(CGRectGetMinX(timeTextFieldRect), CGRectGetMaxY(timeTextFieldRect), CGRectGetWidth(timeTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line3_3Rect inSuperView:self.view];
    
    //memoTextField 摘要－提示文字
    CGRect memoTextFieldRect = CGRectMake(CGRectGetMaxX(timeTextFieldRect), CGRectGetMinY(timeTextFieldRect), fourTextFieldWidth, allTextFieldHeight);
    _memoTextField = [[UITextField alloc] initWithFrame:memoTextFieldRect];
    [_memoTextField setBackgroundColor:[UIColor colorWithRed:0xfe/255.0 green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0]];
    [_memoTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_memoTextField setEnabled:NO];
    [_memoTextField setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
    [_memoTextField setTextAlignment:NSTextAlignmentCenter];
    [_memoTextField setText:@"摘要"];
    [self.view addSubview:_memoTextField];
    [_memoTextField release];
    
    CGRect line4_1Rect = CGRectMake(CGRectGetMinX(memoTextFieldRect), CGRectGetMinY(memoTextFieldRect), CGRectGetWidth(memoTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line4_1Rect inSuperView:self.view];
    
    CGRect line4_2Rect = CGRectMake(CGRectGetMinX(memoTextFieldRect), CGRectGetMinY(memoTextFieldRect), AllLineWidthOrHeight, CGRectGetHeight(memoTextFieldRect));
    [Globals makeLineWithFrame:line4_2Rect inSuperView:self.view];
    
    CGRect line4_3Rect = CGRectMake(CGRectGetMinX(memoTextFieldRect), CGRectGetMaxY(memoTextFieldRect), CGRectGetWidth(memoTextFieldRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line4_3Rect inSuperView:self.view];
    
    CGRect line4_4Rect = CGRectMake(CGRectGetMaxX(memoTextFieldRect) - AllLineWidthOrHeight, CGRectGetMinY(memoTextFieldRect), AllLineWidthOrHeight, CGRectGetHeight(memoTextFieldRect));
    [Globals makeLineWithFrame:line4_4Rect inSuperView:self.view];
    
    //infoTableView 资金明细表格视图
    CGRect infoTableViewRect = CGRectMake(CGRectGetMinX(amountTextFieldRect), CGRectGetMaxY(amountTextFieldRect), CGRectGetWidth(appRect) - CGRectGetMinX(amountTextFieldRect) * 2, CGRectGetHeight(appRect) - CGRectGetMaxY(amountTextFieldRect) -44);
    _infoTableView = [[PullingRefreshTableView alloc]initWithFrame:infoTableViewRect pullingDelegate:self];
    [_infoTableView setSeparatorStyle:UITableViewScrollPositionNone];
    [_infoTableView setBackgroundColor:[UIColor clearColor]];
    [_infoTableView setDataSource:self];
    [_infoTableView setDelegate:self];
    [_infoTableView setPullingDelegate:self];
    [self.view addSubview:_infoTableView];
    [_infoTableView release];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.xfTabBarController setTabBarHidden:YES];
    _pageIndex = 1;
    _searchIndex = @"-1";
    _changeTotalAccount = YES;
    _recordsArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self getCurrentDate];
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
        _dateLabel = nil;
        _sumIncomeLabel = nil;
        _sumExpendLabel = nil;
        _sumWinningLabel = nil;
        
        _allTypeBtn = nil;
        _incomeBtn = nil;
        _enpendBtn = nil;
        
        _amountTextField = nil;
        _typeTextField = nil;
        _timeTextField = nil;
        _memoTextField = nil;
        
        _infoTableView = nil;
        _progressHud = nil;
        
        [_recordsArray release];
        _recordsArray = nil;
        [_detailDic release];
        _detailDic = nil;
        [_selectRowDic release];
        _selectRowDic = nil;
        
        [_selectYear release];
        _selectYear = nil;
        [_selectMonth release];
        _selectMonth = nil;
        [_startDate release];
        _startDate = nil;
        [_endDate release];
        _endDate = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CapitalDetailViewTabelCellHeight;
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_recordsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CapitalDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor whiteColor]];

        //画线  高智商的别看
        CGFloat layerWidth = IS_PHONE ? 0.5f : 1.0f;
        
        //verticalLineView1 竖线1
        CGRect verticalLineView1Rect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), layerWidth);
        UIView *verticalLineView1 = [[UIView alloc] initWithFrame:verticalLineView1Rect];
        [verticalLineView1 setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:verticalLineView1];
        [verticalLineView1 release];
        
        //perpendicularLineView1 竖线1
        CGRect perpendicularLineView1Rect = CGRectMake(0, 0, layerWidth, CapitalDetailViewTabelCellHeight);
        UIView *perpendicularLineView1 = [[UIView alloc] initWithFrame:perpendicularLineView1Rect];
        [perpendicularLineView1 setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:perpendicularLineView1];
        [perpendicularLineView1 release];
        
        
        //perpendicularLineView2 竖线2
        CGRect perpendicularLineView2Rect = CGRectMake(CGRectGetWidth(_amountTextField.frame), 0, layerWidth, CapitalDetailViewTabelCellHeight);
        UIView *perpendicularLineView2 = [[UIView alloc] initWithFrame:perpendicularLineView2Rect];
        [perpendicularLineView2 setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:perpendicularLineView2];
        [perpendicularLineView2 release];
        
        //perpendicularLineView3 竖线3
        CGRect perpendicularLineView3Rect = CGRectMake(CGRectGetWidth(_amountTextField.frame) + CGRectGetWidth(_typeTextField.frame), 0, layerWidth, CapitalDetailViewTabelCellHeight);
        UIView *perpendicularLineView3 = [[UIView alloc] initWithFrame:perpendicularLineView3Rect];
        [perpendicularLineView3 setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:perpendicularLineView3];
        [perpendicularLineView3 release];
        
        //perpendicularLineView4 竖线4
        CGRect perpendicularLineView4Rect = CGRectMake(CGRectGetWidth(_amountTextField.frame) + CGRectGetWidth(_typeTextField.frame) + CGRectGetWidth(_timeTextField.frame), 0, layerWidth, CapitalDetailViewTabelCellHeight);
        UIView *perpendicularLineView4 = [[UIView alloc] initWithFrame:perpendicularLineView4Rect];
        [perpendicularLineView4 setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:perpendicularLineView4];
        [perpendicularLineView4 release];
        
        //perpendicularLineView5 竖线5
        CGRect perpendicularLineView5Rect = CGRectMake(CGRectGetWidth(_amountTextField.frame) + CGRectGetWidth(_typeTextField.frame) + CGRectGetWidth(_timeTextField.frame) + CGRectGetWidth(_memoTextField.frame) - layerWidth, 0, layerWidth, CapitalDetailViewTabelCellHeight);
        UIView *perpendicularLineView5 = [[UIView alloc] initWithFrame:perpendicularLineView5Rect];
        [perpendicularLineView5 setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:perpendicularLineView5];
        [perpendicularLineView5 release];
        
        //amountLabel 金额
        CGRect amountLabelRect = CGRectMake(0, 0, CGRectGetWidth(_amountTextField.frame), CapitalDetailViewTabelCellHeight);
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:amountLabelRect];
        [amountLabel setBackgroundColor:[UIColor clearColor]];
        [amountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
        [amountLabel setTextColor:[UIColor colorWithRed:0xe3/255.0 green:0x39/255.0 blue:0x3c/255.0 alpha:1.0]];
        [amountLabel setTextAlignment:NSTextAlignmentCenter];
        [amountLabel setTag:1301];
        [cell.contentView addSubview:amountLabel];
        [amountLabel release];
        
        //typeLabel 类型
        CGRect typeLabelRect = CGRectMake(CGRectGetMinX(perpendicularLineView2Rect), 0, CGRectGetWidth(_typeTextField.frame), CapitalDetailViewTabelCellHeight);
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:typeLabelRect];
        [typeLabel setBackgroundColor:[UIColor clearColor]];
        [typeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
        [typeLabel setTextAlignment:NSTextAlignmentCenter];
        [typeLabel setTag:1302];
        [cell.contentView addSubview:typeLabel];
        [typeLabel release];
        
        //dateLabel 时间-x年x月x日
        CGRect dateLabelRect = CGRectMake(CGRectGetMinX(perpendicularLineView3Rect), 0, CGRectGetWidth(_timeTextField.frame), CapitalDetailViewTabelCellHeight / 2.0f);
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateLabelRect];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
        [dateLabel setTextAlignment:NSTextAlignmentCenter];
        [dateLabel setTag:1303];
        [cell.contentView addSubview:dateLabel];
        [dateLabel release];
        
        //timeLabel 时间-x时x分x秒
        CGRect timeLabelRect = CGRectMake(CGRectGetMinX(dateLabelRect), CGRectGetMaxY(dateLabelRect), CGRectGetWidth(dateLabelRect), CapitalDetailViewTabelCellHeight / 2.0f);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeLabelRect];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
        [timeLabel setTextAlignment:NSTextAlignmentCenter];
        [timeLabel setTag:1304];
        [cell.contentView addSubview:timeLabel];
        [timeLabel release];
        
        //desLabel 摘要
        CGRect desLabelRect = CGRectMake(CGRectGetMinX(perpendicularLineView4Rect), 0, CGRectGetWidth(_memoTextField.frame), CapitalDetailViewTabelCellHeight);
        UILabel *desLabel = [[UILabel alloc] initWithFrame:desLabelRect];
        [desLabel setBackgroundColor:[UIColor clearColor]];
        [desLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
        [desLabel setTextAlignment:NSTextAlignmentCenter];
        [desLabel setTag:1305];
        [cell.contentView addSubview:desLabel];
        [desLabel release];
    }
    //amountLabel 金额
    UILabel *amountLabel = (UILabel *)[cell.contentView viewWithTag:1301];
    
    //typeLabel 类型
    UILabel *typeLabel = (UILabel *)[cell.contentView viewWithTag:1302];
    
    //dateLabel 时间-x年x月x日
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:1303];
    
    //timeLabel 时间-x时x分x秒
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:1304];
    
    //desLabel 摘要
    UILabel *desLabel = (UILabel *)[cell.contentView viewWithTag:1305];
    
    if (_recordsArray.count > 0) {
        NSDictionary *dic = [_recordsArray objectAtIndex:indexPath.row];
        if (dic) {
            amountLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"money"]];
            typeLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"in_out"]];
            desLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"memo"]];
            
            NSString *datetime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"datetime"]];
            if (datetime.length > 15) {
                NSArray *arr = [datetime componentsSeparatedByString:@" "];
                NSString *date = [arr objectAtIndex:0];
                NSString *time = [arr objectAtIndex:1];
                dateLabel.text = date;
                timeLabel.text = time;
            }
        }
    }
    return cell;
}

//下拉刷新,上拖加载更多
#pragma mark -UIScrollViewDelegate
//会在视图滚动时收到通知。包括一个指向被滚动视图的指针，从中可以读取contentOffset属性以确定其滚动到的位置。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_infoTableView tableViewDidScroll:scrollView];
}

//当用户抬起拖动的手指时得到通知。还会得到一个布尔值，知名报告滚动视图最后位置之前，是否需要减速。
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_infoTableView tableViewDidEndDragging:scrollView];
}

#pragma mark -PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    _pageIndex = 1;
    [_recordsArray removeAllObjects];
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    _pageIndex++;
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    return [NSDate date];
}

- (NSDate *)pullingTableViewLoadingFinishedDate{
    return [NSDate date];
}

#pragma mark -DialogDatePickerViewDelegate
- (void)pickerViewDidSelectedDateDictionary:(NSDictionary *)selectDateDic {
    [_selectRowDic release];
    _selectRowDic = nil;
    _selectRowDic = [selectDateDic retain];
    if (_selectYear != nil) {
        [_selectYear release];
        _selectYear = nil;
    }
    _selectYear = [[selectDateDic objectForKey:@"selectYear"] copy];
    if (_selectMonth != nil) {
        [_selectMonth release];
        _selectMonth = nil;
    }
    _selectMonth = [[selectDateDic objectForKey:@"selectMonth"] copy];
    [self getNumberOfDaysInMonthWithYear:_selectYear Month:_selectMonth];
    
    _dateLabel.text = [NSString stringWithFormat:@"%@年%@月份账户明细",_selectYear,_selectMonth];
    _sumExpendLabel.text = @"";
    _sumIncomeLabel.text = @"";
    _sumWinningLabel.text = @"";
    _changeTotalAccount = YES;
    [_recordsArray removeAllObjects];
    [_infoTableView reloadData];
    _pageIndex = 1;
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [_progressHud hide:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [_progressHud hide:YES];
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"msg"] integerValue] == 0) {
        [_detailDic release];
        _detailDic = nil;
        _detailDic = [responseDic retain];
        [self processData:responseDic];
    } else if (responseDic) {
        [XYMPromptView showInfo:[responseDic objectForKey:@"msg"] bgColor:[UIColor blackColor].CGColor inView:[(AppDelegate *)[UIApplication sharedApplication].delegate window] isCenter:NO vertical:1];
        [_infoTableView tableViewDidFinishedLoading];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.xfTabBarController setTabBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

//选择日期
- (void)selectDateTouchUpInside:(id)sender {
    DialogDatePickerView *datePicker = [[DialogDatePickerView alloc]initWithFrame:CGRectMake(10, 50, dateSelectViewSize.width, dateSelectViewSize.height) SelectRowDic:_selectRowDic];
    [datePicker setDelegate:self];
    [datePicker show];
    [datePicker release];
}

//全部类型
- (void)getAllTypeDataTouchUpInside:(id)sender {
    [_recordsArray removeAllObjects];
    [_infoTableView reloadData];
    _allTypeBtn.selected=YES;
    _incomeBtn.selected=NO;
    _enpendBtn.selected=NO;
    _searchIndex = @"-1";
    _pageIndex = 1;
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

//收入
- (void)getIncomeDataTouchUpInside:(id)sender {
    [_recordsArray removeAllObjects];
    [_infoTableView reloadData];
    _allTypeBtn.selected=NO;
    _incomeBtn.selected=YES;
    _enpendBtn.selected=NO;
    _searchIndex = @"1";
    _pageIndex = 1;
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

//支出
- (void)getExpendDataTouchUpInside:(id)sender {
    [_recordsArray removeAllObjects];
    [_infoTableView reloadData];
    _allTypeBtn.selected=NO;
    _incomeBtn.selected=NO;
    _enpendBtn.selected=YES;
    _searchIndex = @"2";
    _pageIndex = 1;
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

#pragma mark -Customized: Private (General)
- (void)showProgressHud {
    if (_progressHud == nil) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        [_progressHud setMode:MBProgressHUDModeIndeterminate];
        [_progressHud setLabelText:@"正在加载..."];
        [self.view addSubview:_progressHud];
        [_progressHud release];
    }
    [_progressHud show:YES];
}

- (void)getCurrentDate {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *formateDate = [dateFormatter stringFromDate:currentDate];
    [dateFormatter release];

    NSArray *dateArray = [formateDate componentsSeparatedByString:@"-"];
    if (_selectYear != nil) {
        [_selectYear release];
        _selectYear = nil;
    }
    _selectYear = [[NSString stringWithFormat:@"%@",[dateArray objectAtIndex:0]] copy];
    if (_selectMonth != nil) {
        [_selectMonth release];
        _selectMonth = nil;
    }
    _selectMonth = [[NSString stringWithFormat:@"%d",[[dateArray objectAtIndex:1]intValue]] copy];
    
    [self getNumberOfDaysInMonthWithYear:_selectYear Month:_selectMonth];
    
    [self loadDataWithYear:_selectYear Month:_selectMonth];
}

- (void)getNumberOfDaysInMonthWithYear:(NSString *)year Month:(NSString *)month {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-01",year,month]];
    [dateFormatter release];

    //获取一个月有多少天
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSInteger numberOfDaysInMonth = range.length;
    if (_startDate != nil) {
        [_startDate release];
        _startDate = nil;
    }
    _startDate = [[NSString stringWithFormat:@"%@-%@-1 00:00:00",_selectYear,_selectMonth] copy];
    if (_endDate != nil) {
        [_endDate release];
        _endDate = nil;
    }
    _endDate = [[NSString stringWithFormat:@"%@-%@-%ld 00:00:00",_selectYear,_selectMonth,(long)numberOfDaysInMonth] copy];

    [calendar release];
}

- (void)loadDataWithYear:(NSString *)year Month:(NSString *)month {
    [self showProgressHud];
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    // -1时
    [infoDic setObject:[NSString stringWithFormat:@"%@",_searchIndex] forKey:@"searchCondition"];
    
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_pageIndex] forKey:@"pageIndex"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",kPageSize] forKey:@"pageSize"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",0] forKey:@"sortType"];
    [infoDic setObject:[NSString stringWithFormat:@"%@",_startDate] forKey:@"startTime"];
    [infoDic setObject:[NSString stringWithFormat:@"%@",_endDate] forKey:@"endTime"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetFundDetail userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
    
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)fillTopDataWithInfo:(NSDictionary *)dic year:(NSString *)year month:(NSString *)month {
    _dateLabel.text = [NSString stringWithFormat:@"%@年%@月份账户明细",year,month];
    NSString *sumIncome = [[_detailDic objectForKey:@"sum_Income_Money"] isEqualToString:@""] ? @"0":[_detailDic objectForKey:@"sum_Income_Money"];
    _sumIncomeLabel.text = [NSString stringWithFormat:@"%@元",sumIncome];
    
    NSString *sumExpend = [[_detailDic objectForKey:@"sum_Expense_Money"] isEqualToString:@""] ? @"0":[_detailDic objectForKey:@"sum_Expense_Money"];
    _sumExpendLabel.text = [NSString stringWithFormat:@"%@元",sumExpend];
    
    NSString *sumBonus = [[_detailDic objectForKey:@"sum_Bonus_Money"] isEqualToString:@""] ? @"0":[_detailDic objectForKey:@"sum_Bonus_Money"];
    _sumWinningLabel.text = [NSString stringWithFormat:@"%@元",sumBonus];
}

- (void)processData:(NSDictionary *)dic {
    NSString *error = [NSString stringWithFormat:@"%@",[dic objectForKey:@"error"]];
    if (![error isEqualToString:@"0"])
        return;
    //填充顶部数据
    if (_changeTotalAccount) {
        [self fillTopDataWithInfo:dic year:_selectYear month:_selectMonth];
        _changeTotalAccount = NO;
    }
    
    id detailArray = [_detailDic objectForKey:@"dtAccountDetails"];
    if ([detailArray isKindOfClass:[NSArray class]]) {
        if (_pageIndex == 0) {
            [_recordsArray removeAllObjects];
            [_recordsArray addObjectsFromArray:detailArray];
        } else {
            [_recordsArray addObjectsFromArray:detailArray];
        }
        
        if ([(NSArray *)detailArray count] < 30) {
            _infoTableView.headerOnly = YES;
            _infoTableView.reachedTheEnd = YES;
        } else {
            _infoTableView.headerOnly = NO;
            _infoTableView.reachedTheEnd = NO;
        }
    }
    [_infoTableView tableViewDidFinishedLoading];
    [_infoTableView reloadData];
}

@end