//
//  MyTicketsViewController.m 个人中心－我的账号
//  SSQDemo
//
//  Created by sls002 on 13-5-16.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140811 10:44（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140811 11:21（洪晓彬）：进行ipad适配
//20141215 08:15（洪晓彬）：改版5.2，内存整理，不适配ipad
//20150710 15:40（刘科）：修改个人账号头部UI，新增彩金显示
//20150820 10:49（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "MyTicketsViewController.h"

#import "AccountInfoViewController.h"
#import "AllBetViewController.h"
#import "AppSettingViewController.h"
#import "AccountDetailViewController.h"
#import "IntegralCenterViewController.h"
#import "PayOutViewController.h"
#import "SelectRechargeTypeViewController.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "CustomResultParser.h"
#import "Globals.h"
#import "Header.h"
#import "UserInfo.h"
#import "BankCardManageViewController.h"
#import "AddBankCardViewController.h"

#define MyTicketsTabelViewCellHeight (IS_PHONE ? 40.0f : 60.0f)
#define MyTicketsTabelViewHeadHeight (IS_PHONE ? 154.0f : 240.0f)
#define MyTicketsTabelViewHeightHeight (IS_PHONE ? 10.0f : 20.0f)
#define KViewWidth self.view.frame.size.width / 3

@interface MyTicketsViewController ()

@end

#pragma mark -
#pragma mark @implementation MyTicketsViewController
@implementation MyTicketsViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"我的账号"];
    }
    return self;
}

- (void)dealloc {
    _userNameLabel = nil;
    _accountBalanceLabel = nil;
    _accountFrostLabel = nil;
    _handselLabel = nil;
    
    [_imageArray release];
    _imageArray = nil;
    [_nameArray release];
    _nameArray = nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
	[baseView release];

    //settingBtn 设置按钮
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setFrame:XFIponeIpadNavigationSettingPromptButtonRect];
    [settingBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"settingPrompt.png"]] forState:UIControlStateNormal];
//    [settingBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"settingPrompt.png"]] forState:UIControlStateHighlighted];
    [settingBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [settingBtn addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc]initWithCustomView:settingBtn];
    [self.navigationItem setRightBarButtonItem:settingItem];
    [settingItem release];
    
    //listTabelView
    CGRect listTabelViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f * 2 - 10);
    _listTabelView = [[UITableView alloc] initWithFrame:listTabelViewRect];
    [_listTabelView setBackgroundColor:[UIColor clearColor]];
    [_listTabelView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_listTabelView setDataSource:self];
    [_listTabelView setDelegate:self];
    [self.view addSubview:_listTabelView];
    [_listTabelView release];
    
    //refreshTableHeaderView 彩种表格顶部的刷新控件
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0 - CGRectGetHeight(listTabelViewRect), CGRectGetWidth(appRect), _listTabelView.bounds.size.height)];
    [_refreshTableHeaderView setDelegate:self];
    [_listTabelView addSubview:_refreshTableHeaderView];
    [_refreshTableHeaderView release];
}

- (void)viewDidLoad {
    _imageArray = [[NSArray alloc ] initWithObjects:@"myTicketsAll.png", @"myTicketsWin.png", @"myTicketsLose.png", @"myTicketsChase.png", @"myTicketsTogether.png", @"myTicketsMessage.png", @"myTicketsDetail.png", @"myTicketsIntegral.png", @"myTicketsIntegral.png", nil];
    _nameArray = [[NSArray alloc] initWithObjects:@"我的彩票", @"中奖记录", @"未开奖", @"我的追号", @"我的复制",@"账户信息", @"账户明细", @"积分中心", @"银行卡管理", nil];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    _controlCanTouch = YES;
    [self loadUserInfo];
//    if ([UserInfo shareUserInfo].userID) {
//        [self login];
//    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _userNameLabel = nil;
        _accountBalanceLabel = nil;
        _accountFrostLabel = nil;
        
        [_imageArray release];
        _imageArray = nil;
        [_nameArray release];
        _nameArray = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHttpRequest];
    [self clearBindingRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 4;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MyTicketsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /********************** adjustment 控件调整 ***************************/
    CGFloat imageViewMinX = IS_PHONE ? 9.0f : 15.0f;
    CGFloat imageViewMinY = IS_PHONE ? 9.0f : 15.0f;
    CGFloat imageViewSize = IS_PHONE ? 18.0f : 30.0f;
    
    CGFloat nameLabelAddX = IS_PHONE ? 6.0f : 10.0f;
    CGFloat nameLabelWidth = IS_PHONE ? 100.0f : 400.0f;
    
    CGFloat promptImageViewMaiginRight = IS_PHONE ? 14.0f : 28.0f;
    CGFloat promptImageViewWidht = IS_PHONE ? 15.0f : 22.5f;
    CGFloat promptImageViewHeight = IS_PHONE ? 14.0f : 21.0f;
    /********************** adjustment end ***************************/
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //topLineView
        CGRect topLineViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        UIView *topLineView = [[UIView alloc] initWithFrame:topLineViewRect];
        [topLineView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [topLineView setTag:2501];
        [topLineView setClipsToBounds:YES];
        [cell.contentView addSubview:topLineView];
        [topLineView release];
        
        //imageView
        CGRect imageViewRect = CGRectMake(imageViewMinX, imageViewMinY, imageViewSize, imageViewSize);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setTag:2502];
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        //promptImageView
        CGRect promptImageViewRect = CGRectMake(CGRectGetWidth(tableView.frame) - promptImageViewMaiginRight - promptImageViewWidht, (MyTicketsTabelViewCellHeight - promptImageViewHeight) / 2.0f, promptImageViewWidht, promptImageViewHeight);
        UIImageView *promptImageView = [[UIImageView alloc] initWithFrame:promptImageViewRect];
        [promptImageView setBackgroundColor:[UIColor clearColor]];
        [promptImageView setTag:2503];
        [cell.contentView addSubview:promptImageView];
        [promptImageView release];
        
        //nameLabel
        CGRect nameLabelRect = CGRectMake(CGRectGetMaxX(imageViewRect) + nameLabelAddX, CGRectGetMinY(imageViewRect), nameLabelWidth, CGRectGetHeight(imageViewRect));
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [nameLabel setTextColor:[UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f]];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setTag:2504];
        [cell.contentView addSubview:nameLabel];
        [nameLabel release];
        
        //topLineView
        CGRect bottomLineViewRect = CGRectMake(0, MyTicketsTabelViewCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        UIView *bottomLineView = [[UIView alloc] initWithFrame:bottomLineViewRect];
        [bottomLineView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [bottomLineView setTag:2505];
        [bottomLineView setClipsToBounds:YES];
        [cell.contentView addSubview:bottomLineView];
        [bottomLineView release];
    }
    
    
    UIView *topLineView = (UIView *)[cell.contentView viewWithTag:2501];
    UIView *bottomLineView = (UIView *)[cell.contentView viewWithTag:2505];
    
    
    if ((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 0)) {//第一个cell
        [topLineView setHidden:NO];
        CGRect topLineViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        [topLineView setFrame:topLineViewRect];
        
        
        [bottomLineView setHidden:NO];
        CGRect bottomLineViewRect = CGRectMake(imageViewMinX, MyTicketsTabelViewCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        [bottomLineView setFrame:bottomLineViewRect];
        
    } else if ((indexPath.section == 0 && indexPath.row == 4) || (indexPath.section == 1 && indexPath.row == 1)) {//最后一个cell
        [topLineView setHidden:YES];
        CGRect topLineViewRect = CGRectMake(imageViewMinX, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        [topLineView setFrame:topLineViewRect];
        
        [bottomLineView setHidden:NO];
        CGRect bottomLineViewRect = CGRectMake(0, MyTicketsTabelViewCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        [bottomLineView setFrame:bottomLineViewRect];
        
    } else { //中间部分
        [topLineView setHidden:YES];
        
        [bottomLineView setHidden:NO];
        
        CGRect bottomLineViewRect = CGRectMake(imageViewMinX, MyTicketsTabelViewCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        [bottomLineView setFrame:bottomLineViewRect];
        
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:2502];
    UIImageView *promptImageView = (UIImageView *)[cell.contentView viewWithTag:2503];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2504];
    
    if ((indexPath.section * 5 + indexPath.row < [_imageArray count]) && (indexPath.section * 5 + indexPath.row < [_nameArray count])) {
        [imageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[_imageArray objectAtIndex:(indexPath.section * 5 + indexPath.row)]]]];
        [promptImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        [nameLabel setText:[_nameArray objectAtIndex:(indexPath.section * 5 + indexPath.row)]];
    }
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MyTicketsTabelViewCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect viewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), MyTicketsTabelViewHeadHeight);
    UIView *headView = [[UIView alloc] init];
    if (section == 0) {
        [headView setFrame:viewRect];
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat topBackImageViewHeight = IS_PHONE ? 150.0f : 220.0f;
        
        CGFloat personImageViewMinX = IS_PHONE ? 10.0f : 20.0f;
        CGFloat personImageViewMinY = IS_PHONE ? 13.0f : 26.0f;
        CGFloat personImageViewSize = IS_PHONE ? 34.0f : 30.0f;
        
        CGFloat userNameLabelMaginPersonImageViewX = IS_PHONE ? 7.0f : 14.0f;//用户名label的x
        CGFloat userNameLabelWidth =  IS_PHONE ? 150.0f : 250.0f;//用户名label的宽
        
        CGFloat allLabelHeight = IS_PHONE ? 18.0f : 30.0f;//所有label的高

        CGFloat buttonHeight = IS_PHONE ? 40.0f : 60.0f;
        /********************** adjustment end ***************************/
        
        //topBackImageView
        CGRect topBackImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), topBackImageViewHeight);
        UIImageView *topBackImageView = [[UIImageView alloc] initWithFrame:topBackImageViewRect];
        [topBackImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"myTicketBack.png"]]];
        [topBackImageView setUserInteractionEnabled:YES];
        [headView addSubview:topBackImageView];
        [topBackImageView release];
        
        //personImageView
        CGRect personImageViewRect = CGRectMake(personImageViewMinX, personImageViewMinY, personImageViewSize, personImageViewSize);
        UIImageView *personImageView = [[UIImageView alloc] initWithFrame:personImageViewRect];
        [personImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"person.png"]]];
        [topBackImageView addSubview:personImageView];
        [personImageView release];
        
        //userNameLabel  用户名
        CGRect userNameLabelRect = CGRectMake(CGRectGetMaxX(personImageViewRect) + userNameLabelMaginPersonImageViewX, 10, userNameLabelWidth, 40);
        _userNameLabel = [[UILabel alloc] initWithFrame:userNameLabelRect];
        [_userNameLabel setBackgroundColor:[UIColor clearColor]];
        [_userNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize18]];
        [_userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [topBackImageView addSubview:_userNameLabel];
        [_userNameLabel release];
        
        // 虚线
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setBounds:topBackImageView.bounds];
        [shapeLayer setPosition:topBackImageView.center];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setStrokeColor:[[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f] CGColor]];
        [shapeLayer setLineWidth:1.0f];
        [shapeLayer setLineJoin:kCALineJoinRound];
        [shapeLayer setLineDashPattern:
        [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
        [NSNumber numberWithInt:5],nil]];
        // Setup the path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, 55);
        CGPathAddLineToPoint(path, NULL, self.view.frame.size.width,55);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        [[topBackImageView layer] addSublayer:shapeLayer];
        
        // 竖线
        for (int i = 0; i < 2; i ++) {
            
            UIView *sxView = [[UILabel alloc] initWithFrame:CGRectMake(KViewWidth + i * KViewWidth, 65, 2, 40)];
            sxView.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f];
            [topBackImageView addSubview:sxView];
            [sxView release];
            
        }
        
        //accountBalancePromptLabel 账户余额 - 提示文字
        CGRect accountBalancePromptLabelRect = CGRectMake(0, 66, KViewWidth, allLabelHeight);
        UILabel *accountBalancePromptLabel = [[UILabel alloc] initWithFrame:accountBalancePromptLabelRect];
        [accountBalancePromptLabel setBackgroundColor:[UIColor clearColor]];
        [accountBalancePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];
        [accountBalancePromptLabel setTextColor:[UIColor blackColor]];
        [accountBalancePromptLabel setTextAlignment:NSTextAlignmentCenter];
        [accountBalancePromptLabel setText:@"可用金额"];
        [topBackImageView addSubview:accountBalancePromptLabel];
        [accountBalancePromptLabel release];
        
        //accountBalanceLabel 可用金额
        CGRect accountBalanceLabelRect = CGRectMake(0, 79, KViewWidth, 35);
        _accountBalanceLabel = [[UILabel alloc] initWithFrame:accountBalanceLabelRect];
        [_accountBalanceLabel setBackgroundColor:[UIColor clearColor]];
        [_accountBalanceLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_accountBalanceLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
        [_accountBalanceLabel setTextAlignment:NSTextAlignmentCenter];
        [topBackImageView addSubview:_accountBalanceLabel];
        [_accountBalanceLabel release];
        
        //accountFrostPromptLabel 冻结 - 提示文字
        CGRect accountFrostPromptLabelRect = CGRectMake(KViewWidth, 66, KViewWidth, allLabelHeight);
        UILabel *accountFrostPromptLabel = [[UILabel alloc] initWithFrame:accountFrostPromptLabelRect];
        [accountFrostPromptLabel setBackgroundColor:[UIColor clearColor]];
        [accountFrostPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];
        [accountFrostPromptLabel setTextColor:[UIColor blackColor]];
        [accountFrostPromptLabel setTextAlignment:NSTextAlignmentCenter];
        [accountFrostPromptLabel setText:@"冻结金额"];
        [topBackImageView addSubview:accountFrostPromptLabel];
        [accountFrostPromptLabel release];
        
        //accountFrostLabel 冻结金额
        CGRect accountFrostLabelRect = CGRectMake(KViewWidth, 79, KViewWidth, 35);
        _accountFrostLabel = [[UILabel alloc] initWithFrame:accountFrostLabelRect];
        [_accountFrostLabel setBackgroundColor:[UIColor clearColor]];
        [_accountFrostLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_accountFrostLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
        [_accountFrostLabel setTextAlignment:NSTextAlignmentCenter];
        [topBackImageView addSubview:_accountFrostLabel];
        [_accountFrostLabel release];
        
        // handselPromptLabel 彩金 - 提示文字
        CGRect handselPromptLabelRect = CGRectMake(KViewWidth * 2, 66, KViewWidth, allLabelHeight);
        UILabel *handselPromptLabel = [[UILabel alloc] initWithFrame:handselPromptLabelRect];
        [handselPromptLabel setBackgroundColor:[UIColor clearColor]];
        [handselPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];
        [handselPromptLabel setTextColor:[UIColor blackColor]];
        [handselPromptLabel setTextAlignment:NSTextAlignmentCenter];
        [handselPromptLabel setText:@"彩金"];
        [topBackImageView addSubview:handselPromptLabel];
        [handselPromptLabel release];
        
        // handselLabel 彩金
        CGRect handselLabelRect = CGRectMake(KViewWidth * 2, 79, KViewWidth, 35);
        _handselLabel = [[UILabel alloc] initWithFrame:handselLabelRect];
        [_handselLabel setBackgroundColor:[UIColor clearColor]];
        [_handselLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_handselLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
        [_handselLabel setTextAlignment:NSTextAlignmentCenter];
        [topBackImageView addSubview:_handselLabel];
        [_handselLabel release];
        
        //addMoneyButton
        CGRect addMoneyButtonRect = CGRectMake(0, (CGRectGetHeight(topBackImageViewRect) - buttonHeight), self.view.frame.size.width / 2 + 1, buttonHeight);
        UIButton *addMoneyButton = [[UIButton alloc] initWithFrame:addMoneyButtonRect];
//        [addMoneyButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
        [addMoneyButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
        [addMoneyButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
        [addMoneyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
        [addMoneyButton.layer setBorderWidth:1.0];
        [addMoneyButton.layer setBorderColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f].CGColor];
        [addMoneyButton setTitleColor:[UIColor colorWithRed:0xfd/255.0 green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [addMoneyButton setTitle:@"我要充值" forState:UIControlStateNormal];
        [addMoneyButton addTarget:self action:@selector(addMoneyTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [topBackImageView addSubview:addMoneyButton];
        [addMoneyButton release];
        
        // 动态红包加载方法
//        CGRect frame = CGRectMake(0,(CGRectGetHeight(topBackImageViewRect) - buttonHeight),0,0);
//        frame.size = [UIImage imageNamed:@"hb.gif"].size;
//        // 读取gif图片数据
//        NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"hb" ofType:@"gif"]];
//        // view生成
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
//        webView.userInteractionEnabled = NO;//用户不可交互
//        [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//        [self.view addSubview:webView];
//        [webView release];
        
        //drawMoneyButton
        CGRect drawMoneyButtonRect = CGRectMake(self.view.frame.size.width / 2, (CGRectGetHeight(topBackImageViewRect) - buttonHeight), self.view.frame.size.width / 2, buttonHeight);
        UIButton *drawMoneyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        drawMoneyButton.frame = drawMoneyButtonRect;
        [drawMoneyButton.layer setBorderColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f].CGColor];
        [drawMoneyButton.layer setBorderWidth:1.0];
        [drawMoneyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
        [drawMoneyButton setTitleColor:[UIColor colorWithRed:0xfd/255.0 green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [drawMoneyButton setTitle:@"我要提款" forState:UIControlStateNormal];
        [drawMoneyButton addTarget:self action:@selector(drawMoneyTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [topBackImageView addSubview:drawMoneyButton];
        [drawMoneyButton release];
        
        [drawMoneyButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
        [drawMoneyButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
        
        [self loadUserInfo];
    }
    
    return headView;
//    return [headView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return MyTicketsTabelViewHeadHeight + MyTicketsTabelViewHeightHeight;
    }
    return MyTicketsTabelViewHeightHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_controlCanTouch == NO) {
        return;
    }
    _controlCanTouch = NO;
    if (indexPath.section == 0 && indexPath.row <= 4) {     //0.全部彩票  1.中奖彩票  2.我的追号  3.合买彩票
        AllBetViewController *allBet = [[AllBetViewController alloc]initWithStatus:NORMAL withIndexPage:indexPath.row];
        [self.navigationController pushViewController:allBet animated:YES];
        [allBet release];
    } else if (indexPath.section == 1 && indexPath.row == 0) {//账户信息
        AccountInfoViewController *accountInfo = [[AccountInfoViewController alloc]init];
        [self.navigationController pushViewController:accountInfo animated:YES];
        [accountInfo release];
    } else if (indexPath .section == 1 && indexPath.row == 1) {//账户明细
        AccountDetailViewController *accountDetail = [[AccountDetailViewController alloc] init];
        [self.navigationController pushViewController:accountDetail animated:YES];
        [accountDetail release];
    } else if (indexPath .section == 1 && indexPath.row == 2) {//积分中心
        IntegralCenterViewController *integralCenterViewController = [[IntegralCenterViewController alloc] init];
        [self.navigationController pushViewController:integralCenterViewController animated:YES];
        [integralCenterViewController  release];
    } else if (indexPath.section == 1 && indexPath.row == 3){//银行卡管理
        BankCardManageViewController *bankcardMVC = [[BankCardManageViewController alloc] init];
        [self.navigationController pushViewController:bankcardMVC animated:YES];
        [bankcardMVC  release];
    }
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)deceleratescrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    _isLoading = YES;
    [self login];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)bindingRequestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    NSString *isBinded = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"isBinded"]];
    NSInteger cardCount = [[responseDic objectForKey:@"bankCardCount"] integerValue];
    if (responseDic && ![isBinded isEqualToString:@"Yes"] ) {    // 没有绑定隐含卡信息，直接进入填写信息页面
        AccountInfoViewController *accountInfoViewController = [[AccountInfoViewController alloc] init];
        [self.navigationController pushViewController:accountInfoViewController animated:YES];
        [accountInfoViewController release];
        
    } else if (responseDic && cardCount < 1){
        AddBankCardViewController *addVc = [[AddBankCardViewController alloc] initWithisDetail:NO info:nil succeed:^{
            [self getIsBindingStatusRequest];
        }];
        [self.navigationController pushViewController:addVc animated:YES];
        
    } else if (responseDic) {
        BankCardManageViewController *bankCard = [[BankCardManageViewController alloc] initWithSelct:YES callBack:^(NSDictionary *retDi) {
            // 已绑定身份证信息和银行卡信息,直接进入提款申请界面
            PayOutViewController *payout = [[PayOutViewController alloc] initWithDic:retDi];
            [payout setDelegate:self];
            [self.navigationController pushViewController:payout animated:YES];
            [payout release];
        }];
        [self.navigationController pushViewController:bankCard animated:YES];
        [bankCard release];
        
    }
}

- (void)bindingRequestFailed:(ASIHTTPRequest *)request {
}


- (void)getAutoFinshed:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    NSLog(@"responseDic -> %@", responseDic);
    
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        //再解析
        NSMutableDictionary *autoLoginDict = [[NSMutableDictionary alloc] init];
        
        [CustomResultParser parseResult:responseDic toUserInfoDict:autoLoginDict];
        NSLog(@"autoLoginDict -> %@", autoLoginDict);
        
        [UserInfo shareUserInfo].userID = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"uid"]];
        [UserInfo shareUserInfo].userName = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"name"]];
        [UserInfo shareUserInfo].realName = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"realityName"]];
        [UserInfo shareUserInfo].cardNumber = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"idcardnumber"]];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"balance"]];
        [UserInfo shareUserInfo].freeze = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"freeze"]];
        [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"handselAmount"]];
        [autoLoginDict release];
        
        [_listTabelView reloadData];
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
    [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_listTabelView];
    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
    _isLoading = NO;
}

- (void)getAutoFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"登录失败"];
    _isLoading = NO;
}

- (void)didPaySucceed {
    [self.xfTabBarController setSelectControllerIndex:1];
}

#pragma mark -
#pragma mark -Customized(Action)
//我要充值
- (void)addMoneyTouchUpInside:(id)sender {
    if (_controlCanTouch == NO) {
        return;
    }
    _controlCanTouch = NO;
    SelectRechargeTypeViewController *selectRechargeTypeViewController = [[SelectRechargeTypeViewController alloc]init];
    [self.navigationController pushViewController:selectRechargeTypeViewController animated:YES];
    [selectRechargeTypeViewController release];
}

//我要提款
- (void)drawMoneyTouchUpInside:(id)sender {
    if (_controlCanTouch == NO) {
        return;
    }
    if([[UserInfo shareUserInfo].balance integerValue] < 20) {
        [Globals alertWithMessage:@"可用金额不足20元，不能进行提款操作"];
        return;
    }
    _controlCanTouch = NO;
    // 如果已经登录了，登录之后会返回真实姓名和身份证号，保存了这两个字段，在进行提款申请时判断这两个字段有没有值或者是否为空，如果没值
    // 或为空，则表示需要进行身份证和真实姓名绑定
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
    NSString *realName = [UserInfo shareUserInfo].realName;
    NSString *cardNo = [UserInfo shareUserInfo].cardNumber;
    if (realName == nil || realName.length == 0 || cardNo == nil || cardNo.length == 0) {
        // 填写并绑定身份证信息
        if(self.view.window) {
            AccountInfoViewController *accountInfoViewController = [[AccountInfoViewController alloc] init];
            [self.navigationController pushViewController:accountInfoViewController animated:YES];
            [accountInfoViewController release];
        }
        
    } else {
        // 已绑定身份证信息，请求是否绑定银行卡信息
        [self getIsBindingStatusRequest];
    }
}

//进入该页面填入用户数据
- (void)loadUserInfo {
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"];
    
    if (userinfo) {
        _userNameLabel.text = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"name"]];
    
        NSString *accountBalanceLabelText = [NSString stringWithFormat:@"%.2f",[[UserInfo shareUserInfo].balance doubleValue]];
        
        _accountBalanceLabel.text = [NSString stringWithFormat:@"%@元", accountBalanceLabelText];
        _accountFrostLabel.text = [NSString stringWithFormat:@"%@元", [UserInfo shareUserInfo].freeze];
        
        if ([[UserInfo shareUserInfo].handselAmount isEqualToString:@""]) {
            _handselLabel.text = @"0.00元";
        }else {
            _handselLabel.text = [NSString stringWithFormat:@"%@元", [UserInfo shareUserInfo].handselAmount];
        }
    }
    
}

//设置
- (void)setting:(id)sender {
    AppSettingViewController *appSetting = [[AppSettingViewController alloc]init];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc] initWithRootViewController:appSetting];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [nav release];
    [appSetting release];
}

#pragma mark -Customized: Private (General)
- (void)login {
    [self clearHttpRequest];
    
    if ([UserInfo shareUserInfo].userName.length > 0 && [UserInfo shareUserInfo].password.length > 0) {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:[UserInfo shareUserInfo].userName forKey:@"name"];
        [infoDic setObject:[UserInfo shareUserInfo].password forKey:@"password"];
        
        [self clearHttpRequest];
        [SVProgressHUD showWithStatus:@"加载中"];
        _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_Login userId:@"-1" infoDict:infoDic]];
        [_httpRequest setDelegate:self];
        [_httpRequest setDidFinishSelector:@selector(getAutoFinshed:)];
        [_httpRequest setDidFailSelector:@selector(getAutoFailed:)];
        [_httpRequest startAsynchronous];
    } else {
        [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_listTabelView];
    }
}

- (void)clearHttpRequest {
    if (_httpRequest != nil){
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

//判断是否已经绑定信息
- (void)getIsBindingStatusRequest {
    [self clearBindingRequest];
    
    _bindingRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_BindInformation userId:[UserInfo shareUserInfo].userID infoDict:nil]];
    _bindingRequest.delegate = self;
    [_bindingRequest setDidFinishSelector:@selector(bindingRequestFinished:)];
    [_bindingRequest setDidFailSelector:@selector(bindingRequestFailed:)];
    [_bindingRequest startAsynchronous];
}

- (void)clearBindingRequest {
    if (_bindingRequest != nil){
        [_bindingRequest clearDelegatesAndCancel];
        [_bindingRequest release];
        _bindingRequest = nil;
    }
}

@end
