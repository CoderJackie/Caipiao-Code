//
//  BaseSelectViewController.m  购彩大厅－选号基本界面
//  TicketProject
//
//  Created by Michael on 10/9/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//
//20140702 17:23（洪晓彬）：修改代码规范，改进生命周期
//20140913 09:56（洪晓彬）：处理内存

#import "BaseSelectViewController.h"
#import "Ball.h"
#import "CustomLabel.h"
#import "HelpViewController.h"
#import "SelectBallBottomView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "CalculateBetCount.h"
#import "Globals.h"
#import "GlobalsProject.h"
#import "MyTool.h"
#import "RandomNumber.h"
#import "InterfaceHelper.h"
#import "TimerLabel.h"
#import "ASINetworkQueue.h"
#import "UserInfo.h"
#import "InterfaceHeader.h"

@interface BaseSelectViewController ()
/** 反选操作时初始化一些变量 */
- (void)initInvertSelectionVariable;
@end

#pragma mark -
#pragma mark @implementation BaseSelectViewController
@implementation BaseSelectViewController
@synthesize betTypeArray = _betTypeArray;
@synthesize baseDelegate = _baseDelegate;
@synthesize isPresentView = _isPresentView;;
@synthesize betViewController = _betViewController;
@synthesize shakeBtn;
#pragma mark Lifecircle
//从购彩大厅 进入时调用  参数为该彩种信息的字典
- (id)initWithInfoData:(NSObject *)infoData {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    self = [super  init];
    if (self) {
        _lotteryDic = [(NSDictionary *)infoData retain];
    }
    return self;
}

// 从开奖公告进入(适应与需要指定玩法)
- (id)initWithData:(NSObject *)infoData playMethod:(NSInteger)playID playMethodName:(NSString *)playName withPlayMethodButtonIndex:(NSInteger)index {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    self = [super init];
    if (self) {
        _lotteryDic = [(NSDictionary *)infoData retain];
        _playMethodID   = playID;
        _selectBetType   = playName;
        _btnIndex        = index;
    }
    return self;
}

// 反选进入
- (id)initWithSelectedBallsDic:(NSDictionary *)ballsDic lotteryDic:(NSDictionary *)dic atRowIndex:(NSInteger)index {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    self = [super init];
    if (self) {
        _selectedBallsDic = [ballsDic retain];
        _lotteryDic  = [dic retain];
        _specifiedIndex   = index;
        
    }
    return self;
}

// 自选进入
- (id)initWithBetViewController:(UIViewController *)viewController lotteryDic:(NSDictionary *)dic andBallsDic:(NSDictionary *)ballsDic {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    self = [super init];
    if (self) {
        _betViewController = viewController;
        _lotteryDic   = [dic retain];
        _zixuanBallsDic    = [ballsDic retain];
    }
    return self;
}

- (void)dealloc {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nil;
    _lastWinNumLabel = nil;
    _lastWinNumlabels = nil;
    _scrollView = nil;
    _bottomView = nil;
    
    [_betTypeArray release];
    _betTypeArray = nil;
    
    [_selectedBallsDic release];
    [_zixuanBallsDic release];
    [_lotteryDic release];
    
    _oneView = nil;
    _twoView = nil;
    _threeView = nil;
    _fourView = nil;
    _fiveView = nil;
    _sixView = nil;
    _sevenView = nil;
    
    [_oneArray release];
    _oneArray = nil;
    [_twoArray release];
    _twoArray = nil;
    [_threeArray release];
    _threeArray = nil;
    [_fourArray release];
    _fourArray = nil;
    [_fiveArray release];
    _fiveArray = nil;
    [_sixArray release];
    _sixArray = nil;
    [_sevenArray release];
    _sevenArray = nil;
    
    [_infoDic release];
    _infoDic = nil;
    
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
    CGFloat headViewHeight = IS_PHONE ? 30.0f : 45.0f;
    
    CGFloat promptLabelMinX = IS_PHONE ? 7.0f : 14.0f;
    
    CGFloat lastWinNumLabelWidth = IS_PHONE ? 180.0f : 200.0f;
    CGFloat buttonSize = IS_PHONE ? 32.0f : 55.0f;//button的大小
    CGFloat buttonInterval = IS_PHONE ? 4.0f : 6.0f;//button之间的间距
    /********************** adjustment end ***************************/

    //header 表头开奖栏
    NSInteger lotteryid = [[_lotteryDic objectForKey:@"lotteryid"] integerValue];
    CGRect headerRect = CGRectMake(0, 0, CGRectGetWidth(appRect), lotteryid == 83 ? headViewHeight * 3 : headViewHeight);
    _header = [[UIView alloc]initWithFrame:headerRect];
    [_header setBackgroundColor:kBackgroundColor];
    [self.view addSubview:_header];
    [_header release];
    
    _isQuickLotteryView = [InterfaceHelper isQuickLotteryWithLotteryID:[[_lotteryDic objectForKey:@"lotteryid"] integerValue]];

    if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83) {
        CGRect imageRect = CGRectMake(0, 0, CGRectGetWidth(appRect), headViewHeight * 3);
        UIImageView *image = [[UIImageView alloc] initWithFrame:imageRect];
        [image setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"GreenNavBar.png"]]];
        [_header addSubview:image];
        [image release];
        
        //blackWhiteLineView
        CGRect blackWhiteLineViewRect = CGRectMake(CGRectGetWidth(imageRect) / 2 - AllLineWidthOrHeight * 2, 0, AllLineWidthOrHeight * 2, CGRectGetHeight(imageRect));
        [Globals createBlackWithImageViewWithFrame:blackWhiteLineViewRect inSuperView:_header];
        
        //promptLabel 表头开奖栏开奖说明label
        NSString *text = [NSString stringWithFormat:@"%@期开奖:",[_lotteryDic objectForKey:@"lastIsuseName"]];
        CGSize textSize = [Globals defaultSizeWithString:text fontSize:XFIponeIpadFontSize14];
        CGRect promptLabelRect = CGRectMake(promptLabelMinX, 10, textSize.width + XFIponeIpadFontSize14, headViewHeight);
        UILabel *promptLabel = [[UILabel alloc]initWithFrame:promptLabelRect];
        [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [promptLabel setText:text];
        [promptLabel setBackgroundColor:[UIColor clearColor]];
        [promptLabel setTextColor:[UIColor whiteColor]];
        [promptLabel setTag:10];
        [_header addSubview:promptLabel];
        [promptLabel release];

        //lastWinNumlabels 单红色开奖
        CGRect lastWinNumlabelsRect = CGRectMake(CGRectGetMaxX(promptLabelRect) - 8, CGRectGetMinY(promptLabelRect), lastWinNumLabelWidth, headViewHeight);;
        _lassWinNumlabels = [[UILabel alloc]initWithFrame:lastWinNumlabelsRect];
        [_lassWinNumlabels setBackgroundColor:[UIColor clearColor]];
        [_lassWinNumlabels setContentMode:UIViewContentModeCenter];
        [_lassWinNumlabels setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_lassWinNumlabels setTextColor:[UIColor whiteColor]];
        [_header addSubview:_lassWinNumlabels];
        [_lassWinNumlabels release];
        
        CGRect btnRect = CGRectMake(0, CGRectGetMaxY(promptLabelRect), kWinSize.width / 2, buttonSize + (IS_PHONE ? 8 : 16));
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:btnRect];
        [btn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(halfBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
        [_header addSubview:btn];
        
        NSString *lastWinNumber = [_lotteryDic objectForKey:@"lastWinNumber"];
        for (int i = 0; i < [lastWinNumber length]; i++) {
            unichar c = [lastWinNumber characterAtIndex:i];
            NSString *str = [NSString stringWithFormat:@"%c",c];
            
            CGRect btnImageRect = CGRectMake((buttonSize + buttonInterval * 4) * i + promptLabelMinX, CGRectGetMaxY(promptLabelRect) + 5, buttonSize + (IS_PHONE ? 8 : 16), buttonSize + (IS_PHONE ? 8 : 16));
            UIImageView *btnImage = [[UIImageView alloc] initWithFrame:btnImageRect];
            
            switch ([str integerValue]) {
                case 1: {
                    [btnImage setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK31.png"]]];
                }
                    break;
                case 2: {
                    [btnImage setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK32.png"]]];
                }
                    break;
                case 3: {
                    [btnImage setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK33.png"]]];
                }
                    break;
                case 4: {
                    [btnImage setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK34.png"]]];
                }
                    break;
                case 5: {
                    [btnImage setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK35.png"]]];
                }
                    break;
                case 6: {
                    [btnImage setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK36.png"]]];
                }
                    break;
                    
                default:
                    break;
            }
            
            [_header addSubview:btnImage];
            [btnImage release];
        }
        
        //promptLabel 表头开奖栏开奖说明label
        NSString *texts = [NSString stringWithFormat:@"距%@期截止:",[_lotteryDic objectForKey:@"isuseName"]];
        CGRect promptLabelRects = CGRectMake(kWinSize.width / 2.0f + 10, 10, kWinSize.width / 2.0f - 10, headViewHeight);
        UILabel *promptLabels = [[UILabel alloc]initWithFrame:promptLabelRects];
        [promptLabels setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [promptLabels setText:texts];
        [promptLabel setTextAlignment:NSTextAlignmentCenter];
        [promptLabels setBackgroundColor:[UIColor clearColor]];
        [promptLabels setTextColor:[UIColor whiteColor]];
        [promptLabels setTag:100];
        [_header addSubview:promptLabels];
        [promptLabels release];
        
        //timeLabel 时间提示
        CGRect timeLabelRect = CGRectMake(CGRectGetWidth(headerRect) / 2, CGRectGetMaxY(promptLabelRects) + 5, lastWinNumLabelWidth, headViewHeight);
        _timeLabel = [[TimerLabel alloc] initWithFrame:timeLabelRect];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
        [_timeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_header addSubview:_timeLabel];
        [_timeLabel release];
        
    } else {
        //promptLabel 表头开奖栏开奖说明label
        NSString *text = [NSString stringWithFormat:@"%@ 上期开奖：",self.title];
        NSString *timeStr = [NSString stringWithFormat:@"%@期",[_lotteryDic objectForKey:@"isuseName"]];
        CGSize textSize = [Globals defaultSizeWithString:text fontSize:XFIponeIpadFontSize13];
        CGSize timeStrSize = [Globals defaultSizeWithString:[[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? @"" : timeStr fontSize:XFIponeIpadFontSize13];
        CGRect promptLabelRect = CGRectMake(promptLabelMinX, 0, _isQuickLotteryView ?  timeStrSize.width + XFIponeIpadFontSize13 : textSize.width + XFIponeIpadFontSize13, headViewHeight);
        UILabel *promptLabel = [[UILabel alloc]initWithFrame:promptLabelRect];
        [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [promptLabel setText:_isQuickLotteryView ? ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? @"" : timeStr) : text];
        [promptLabel setTag:101];
        [promptLabel setBackgroundColor:[UIColor clearColor]];
        if (_isQuickLotteryView) {
            [promptLabel setTextColor:[UIColor colorWithRed:0x96/255.0f green:0x96/255.0f blue:0x96/255.0f alpha:1.0f]];
        }
        [_header addSubview:promptLabel];
        [promptLabel release];
        
        //lastWinNumLabel 红蓝色开奖label
        CGRect lastWinNumLabelRect = CGRectMake(CGRectGetMaxX(promptLabelRect), (headViewHeight - XFIponeIpadFontSize14 - 2) / 2.0f, lastWinNumLabelWidth, XFIponeIpadFontSize14 + 2);
        _lastWinNumLabel = [[CustomLabel alloc]initWithFrame:lastWinNumLabelRect];
        [_lastWinNumLabel setBackgroundColor:[UIColor clearColor]];
        [_lastWinNumLabel setContentMode:UIViewContentModeCenter];
        [_lastWinNumLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_header addSubview:_lastWinNumLabel];
        [_lastWinNumLabel release];
        
        //lastWinNumlabels 单红色开奖
        CGRect lastWinNumlabelsRect = lastWinNumLabelRect;
        _lastWinNumlabels = [[UILabel alloc]initWithFrame:lastWinNumlabelsRect];
        [_lastWinNumlabels setBackgroundColor:[UIColor clearColor]];
        [_lastWinNumlabels setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
        [_lastWinNumlabels setContentMode:UIViewContentModeCenter];
        [_lastWinNumlabels setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [_lastWinNumlabels setHidden:_isQuickLotteryView];
        [_header addSubview:_lastWinNumlabels];
        [_lastWinNumlabels release];
        
        //timeLabel 时间提示
        CGRect timeLabelRect = lastWinNumLabelRect;
        _timeLabel = [[TimerLabel alloc] initWithFrame:timeLabelRect];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [_timeLabel setTextColor:[UIColor colorWithRed:0x96/255.0f green:0x96/255.0f blue:0x96/255.0f alpha:1.0f]];
        [_timeLabel setHidden:!_isQuickLotteryView];
        [_header addSubview:_timeLabel];
        [_timeLabel release];
    }
    
    //blackWhiteLineView
    CGRect blackWhiteLineViewRect = CGRectMake(0, CGRectGetHeight(headerRect) - AllLineWidthOrHeight * 2, CGRectGetWidth(headerRect), AllLineWidthOrHeight * 2);
    [Globals createBlackWithImageViewWithFrame:blackWhiteLineViewRect inSuperView:_header];
    
    if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83) {
        CGRect historyViewRect = CGRectMake(0, CGRectGetMaxY(headerRect), CGRectGetWidth(appRect), lastWinNumLabelWidth + 60);
        UIView *historyView = [[UIView alloc] initWithFrame:historyViewRect];
        [historyView setTag:123];
        [historyView setHidden:YES];
        [self.view addSubview:historyView];
        
        CGRect notificationTableViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(historyViewRect));
        _notificationTableView = [[UITableView alloc] initWithFrame:notificationTableViewRect style:UITableViewStylePlain];
        [_notificationTableView setBackgroundColor:[UIColor whiteColor]];
        [_notificationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _notificationTableView.dataSource = self;
        _notificationTableView.delegate = self;
        [historyView addSubview:_notificationTableView];
        [_notificationTableView release];
        [historyView release];
    }
    
    //scrollView 滚动视图
    CGRect scrollViewRect = CGRectMake(0, CGRectGetMaxY(headerRect), CGRectGetWidth(appRect),CGRectGetHeight(appRect) - CGRectGetMaxY(headerRect) - kBottomHeight -44.0f);
    _scrollView = [[UIScrollView alloc]initWithFrame:scrollViewRect];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    [_scrollView setMaximumZoomScale:1];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    if (_isQuickLotteryView && [[_lotteryDic objectForKey:@"lotteryid"] integerValue] != 83) {
        _leftView = [[UIView alloc] init];
        //把左侧边的view先隐藏
        _leftView.frame = CGRectMake(0, -200, kWinSize.width, 200);
        [self.view addSubview:_leftView];
        
        CGRect notificationTableViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), 200);
        _notificationTableView = [[UITableView alloc] initWithFrame:notificationTableViewRect style:UITableViewStylePlain];
        [_notificationTableView setBackgroundColor:[UIColor whiteColor]];
        [_notificationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _notificationTableView.dataSource = self;
        _notificationTableView.delegate = self;
        [_leftView addSubview:_notificationTableView];
        [_notificationTableView release];
        
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [_scrollView addGestureRecognizer:pan];
    }

    //bottomView 底部提示视图
    CGRect bottomViewRect = CGRectMake(0, kWinSize.height - kBottomHeight - kNavigationBarHeight, kWinSize.width, kBottomHeight);
    _bottomView = [[SelectBallBottomView alloc]initWithFrame:bottomViewRect];
    [_bottomView setTextWithCount:0 money:0];
    _bottomView.delegate = self;
    [self.view addSubview:_bottomView];
    [_bottomView release];
    
}

#pragma mark -
#pragma mark -Delegate
#pragma mark - 拖拽
- (void)handlePan:(UIPanGestureRecognizer*) recognizer {
    CGPoint translation = [recognizer translationInView:_scrollView];
    //增量后的y坐标位置
    CGFloat Xresult = translation.y + _leftView.frame.origin.y;
    
    //向下
    if (translation.y >= 0) {
        //leftView已全部拉出，则无法再向下
        if (_leftView.frame.origin.y >= 0 || Xresult >= 0) {
            _leftView.frame = CGRectMake(0, 0, kWinSize.width, 200);
            if (_isQuickLotteryView && [[_lotteryDic objectForKey:@"lotteryid"] integerValue] != 83) {
                [_scrollView setFrame:CGRectMake(CGRectGetMinX(_scrollView.frame), CGRectGetMaxY(_leftView.frame), CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
            }
            return;
        }
    } else if (translation.y < 0) {//向上
        //leftView已全部收回，则无法再向上
        if (_leftView.frame.origin.y <= -200 || Xresult <= -200) {
            _leftView.frame = CGRectMake(0, -200, kWinSize.width, 200);
            if (_isQuickLotteryView && [[_lotteryDic objectForKey:@"lotteryid"] integerValue] != 83) {
                [_scrollView setFrame:CGRectMake(CGRectGetMinX(_scrollView.frame), CGRectGetMaxY(_leftView.frame) + 30, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
            }
            
            return;
        }
    }
    
    CGRect frame = _leftView.frame;
    frame.origin.y += translation.y;
    _leftView.frame = frame;
    if (_isQuickLotteryView && [[_lotteryDic objectForKey:@"lotteryid"] integerValue] != 83) {
        [_scrollView setFrame:CGRectMake(CGRectGetMinX(_scrollView.frame), CGRectGetMaxY(_leftView.frame), CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
    }
    
    //清空移动的距离，这是关键
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    //做弹回效果，以中轴为界限
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_leftView.frame.origin.y > -50) {
            [self closeView:NO];
        } else {
            [self closeView:YES];
        }
    }
    
}

- (void)closeView:(BOOL)close {
    if (close) {
        [self moveView:CGRectMake(0, -200, kWinSize.width, 200)];
        
    } else {
        [self moveView:CGRectMake(0, 0, kWinSize.width, 200)];
    }
}

- (void)moveView:(CGRect)frame {
    [UIView animateWithDuration:0.3 animations:^{
        _leftView.frame = frame;
        if (_isQuickLotteryView && [[_lotteryDic objectForKey:@"lotteryid"] integerValue] != 83) {
            [_scrollView setFrame:CGRectMake(CGRectGetMinX(_scrollView.frame), CGRectGetMaxY(_leftView.frame) + 30, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[self.view class]]) {
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && _leftView.frame.origin.y == -200) {
            return YES;
        }
    }
    
    return NO;
}

//提供方便重写
- (void)halfBtnSelect:(id)sender {
    UIButton *betTypeBtn = sender;
    UIView *view = (UIView *)[self.view viewWithTag:123];
    
    if (view.isHidden) {
        [betTypeBtn setBackgroundImage:[[UIImage imageNamed:@"bet_type_select.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [view setHidden:NO];
        
        if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83) {
            CGRect scrollViewRect = CGRectMake(0, CGRectGetMaxY(view.frame), kWinSize.width,kWinSize.height - CGRectGetMaxY(_header.frame) - kBottomHeight * 5.5 -44.0f);
            [_scrollView setFrame:scrollViewRect];
        }
        
    } else {
        [betTypeBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [view setHidden:YES];
        
        if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83) {
            CGRect scrollViewRect = CGRectMake(0, CGRectGetMaxY(_header.frame), kWinSize.width,kWinSize.height - CGRectGetMaxY(_header.frame) - kBottomHeight -44.0f);
            [_scrollView setFrame:scrollViewRect];
        }
        
    }
}

- (void)viewDidLoad {
    missingValuesArray = [[NSMutableArray alloc] init];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    _lotteryID = [[_lotteryDic objectForKey:@"lotteryid"] integerValue];
    
    _betTypeArray = [[NSMutableArray alloc] init];
    historyLotteryNumbersArray = [[NSMutableArray alloc] init];
    
    if (_infoDic == nil) {
        _infoDic = [[NSMutableDictionary alloc]init];
    }
    
    if (_btnIndex == 0) {
        if (_selectedBallsDic) {     // 反选操作
            [self initInvertSelectionVariable];
            
        } else {                    // 非反选操作
            [self getPlayMethods];
            [self initArrays];
        }
        
    } else {
        [self initArrays];
    }
    
    [self fillHeadViewData];
    [shakeBtn setSelected:_globals.isShake];
    
    [self.xfTabBarController setTabBarHidden:YES];
    [super viewDidLoad];
    
    if (_isQuickLotteryView) {
        [self historyLotteryNumbersRequest];
    }
    
    [self missingValuesRequest:[NSString stringWithFormat:@"%ld",(long)_playMethodID]];
    
    //增加观察者，当某彩种到了时间的时候刷新数据。（see class TimerLabel）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"selected" object:nil];
}

//TimerLabel 的刷新通知方法
- (void)refreshTable:(NSNotification *)notification {
    // 针对某个彩种本期时间截止，刷新数据
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];

    [dic setObject:[_lotteryDic objectForKey:@"lotteryid"] forKey:@"lotteryId"];
    [dic setObject:@"-1" forKey:@"playType"];
    
    if (_queue) {
        [_queue cancelAllOperations];
        [_queue release];
        _queue = nil;
    }
    
    _queue = [[ASINetworkQueue alloc] init];
    [_queue reset];
    [_queue setDelegate:self];
    [_queue setRequestDidFailSelector:@selector(requestDidFailed:)];
    [_queue setRequestDidFinishSelector:@selector(requestDidFinished:)];
    [_queue setQueueDidFinishSelector:@selector(queueDidFinished:)];
    [_queue setShouldCancelAllRequestsOnFailure:NO];
    
    ASIFormDataRequest *httpRequest= [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_RRQUEDT_GetLotteryInformation userId:@"-1" infoDict:dic]];
    [httpRequest setTag:0];
    [httpRequest setTimeOutSeconds:10];
    [_queue addOperation:httpRequest];
    [httpRequest release];
    [dic release];
    
    [_queue go];
}

#pragma mark - 向服务器分别请求 普通彩种，足彩，篮彩  单个失败   时的处理方法
- (void)requestDidFailed:(ASIHTTPRequest *)request {
    _pushViewBegin = NO;
}

//向服务器分别请求 普通彩种，足彩，篮彩  单个成功   时的处理方法
- (void)requestDidFinished:(ASIHTTPRequest *)httpRequest {
    _globals.isNeedRefresh = YES;
    // 处理或保存从服务器获取的数据
    NSDictionary *responseDic = [[httpRequest responseString]objectFromJSONString];

    [_serverTime release];
    _serverTime = nil;
    _serverTime = [[responseDic objectForKey:@"serverTime"] copy];
    _globals.serverLocalTimeInterval = [Globals calculateCurrentTimeIntervalWithTime:_serverTime];
    
    NSArray *infoArray = [responseDic objectForKey:@"isusesInfo"];
    
    for (NSDictionary *dic in infoArray) {
        NSString *key = [dic objectForKey:@"lotteryid"];
        
        [_infoDic removeObjectForKey:key];
        [_globals.homeViewInfoDict removeObjectForKey:key];
        
        [_infoDic setObject:dic forKey:key];
        [_globals.homeViewInfoDict setObject:dic forKey:key];
        
    }
    
    NSDictionary *dic1 = [_infoDic objectForKey:[_lotteryDic objectForKey:@"lotteryid"]];
    
    if (_lotteryID == 83) {
        [_lassWinNumlabels setText:[dic1 objectForKey:@"lastWinNumber"]];
        UILabel *lable = (UILabel *)[_header viewWithTag:10];
        [lable setText:[dic1 objectForKey:@"lastIsuseName"]];
        
        UILabel *lable1 = (UILabel *)[_header viewWithTag:100];
        [lable1 setText:[dic1 objectForKey:@"isuseName"]];
        
    } else {
        UILabel *lable1 = (UILabel *)[_header viewWithTag:101];
        [lable1 setText:[dic1 objectForKey:@"isuseName"]];
    }
    
    NSDate *endDate = nil;
    NSTimeInterval intervall = 0;
    if(dic1 && [dic1 objectForKey:@"endtime"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        endDate = [dateFormatter dateFromString:[dic1 objectForKey:@"endtime"]];
        [dateFormatter release];
    }
    
    if (endDate) {
        intervall = [self getTimeIntervalWithEndDate:endDate];
    }
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // 系统返回时间
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[Globals getTimeWithIntervalTime:_globals.serverLocalTimeInterval]];
    NSTimeInterval currServiceInterval = [zone secondsFromGMTForDate:currentDate];
    NSDate *serviceDate = [currentDate  dateByAddingTimeInterval: currServiceInterval];
    
    // 下一期开始时间
    NSString *nextstarttimeStr = [dic1 objectForKey:@"originalTime"];
    NSDate *tmpNextStartDate = [dateFormatter dateFromString:nextstarttimeStr];
    NSTimeInterval nextInterval = [zone secondsFromGMTForDate:tmpNextStartDate];
    NSDate *nextStartDate = [tmpNextStartDate  dateByAddingTimeInterval: nextInterval];
    [dateFormatter release];
    
    NSTimeInterval startTimeInterval = 60.0f;
    //
    if (endDate) {
        startTimeInterval = [tmpNextStartDate timeIntervalSinceNow] - [endDate timeIntervalSinceNow];
        if (startTimeInterval < 60) {
            startTimeInterval = 60;
            
        }else if (startTimeInterval < 0){
            startTimeInterval = 0;
        }
    }
    
    if ([nextstarttimeStr isEqualToString:@""]) {
        [_timeLabel setText:@"已截止"];
        
    }else {
        // 下一期开始时间早于系统返回时间，则不显示
        if ([nextStartDate compare:serviceDate] == NSOrderedAscending) {
            
        } else {
            [_timeLabel updateText:[NSString stringWithFormat:@"%f",intervall + [[NSDate date] timeIntervalSinceReferenceDate]] updateTag:_lotteryID isStartSell:YES];
            [_timeLabel setNextStartTimeInterval:startTimeInterval];
            
        }
        
    }
}

//向服务器分别请求 普通彩种，足彩，篮彩 都请求完毕后   时的处理方法
- (void)queueDidFinished:(ASIHTTPRequest *)httpRequest {
    if (_queue.requestsCount == 0) {
        static BOOL isInDuration = NO;
        if (isInDuration) {
            return;
        }
        isInDuration = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    _pushViewBegin = NO;
    _globals.isInHomeView = YES;
    _isPlayHalf = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _lastWinNumLabel = nil;
        _lastWinNumlabels = nil;
        _scrollView = nil;
        _bottomView = nil;
        
        [_betTypeArray release];
        _betTypeArray = nil;
        
        _oneView = nil;
        _twoView = nil;
        _threeView = nil;
        _fourView = nil;
        _fiveView = nil;
        _sixView = nil;
        _sevenView = nil;
        
        [_oneArray release];
        _oneArray = nil;
        [_twoArray release];
        _twoArray = nil;
        [_threeArray release];
        _threeArray = nil;
        [_fourArray release];
        _fourArray = nil;
        [_fiveArray release];
        _fiveArray = nil;
        [_sixArray release];
        _sixArray = nil;
        [_sevenArray release];
        _sevenArray = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _globals.isInHomeView = NO;
}

#pragma mark -江苏快三历史开奖号码请求
- (void)historyLotteryNumbersRequest {
    if (_historyRequest) {
        [_historyRequest clearDelegatesAndCancel];
        [_historyRequest release];
        _historyRequest = nil;
    }
    
    NSString *infoStr = [_lotteryDic objectForKey:@"lotteryid"];
    NSString *currentDate = [InterfaceHelper getCurrentDateString];
    NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    
    _historyRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kBaseUrl]];
    [_historyRequest setNumberOfTimesToRetryOnTimeout:1];
    [_historyRequest setPostValue:infoStr forKey:kInfo];
    [_historyRequest setPostValue:auth == nil ? @"" : auth forKey:kAuth];
    [_historyRequest setPostValue:HTTP_REQUEST_WinningNumbers forKey:kOpt];
    [_historyRequest setPersistentConnectionTimeoutSeconds:60.0f];
    [_historyRequest setDidFinishSelector:@selector(winningNumbersFinished:)];
    [_historyRequest setDidFailSelector:@selector(winningNumbersFailed:)];
    [_historyRequest setDelegate:self];
    [_historyRequest startAsynchronous];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)winningNumbersFailed:(ASIHTTPRequest *)request {
    
}

- (void)winningNumbersFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    [historyLotteryNumbersArray removeAllObjects];
    [historyLotteryNumbersArray addObject:responseDic.count > 0 ? [responseDic objectForKey:@"OpenInfo"] : @""];
    [_notificationTableView reloadData];
}

#pragma mark -遗漏值请求
- (void)missingValuesRequest:(NSString *)playTypeIds {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:playTypeIds forKey:@"playTypeIds"];
    
    if (_asiRequest) {
        [_asiRequest clearDelegatesAndCancel];
        [_asiRequest release];
        _asiRequest = nil;
    }
    _asiRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_MissingValues userId:nil infoDict:dict]];
    [_asiRequest setDelegate:self];
    [_asiRequest setDidFinishSelector:@selector(checksFinished:)];
    [_asiRequest setDidFailSelector:@selector(checksFailed:)];
    [_asiRequest startAsynchronous];
    [dict release];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)checksFailed:(ASIHTTPRequest *)request {
    
}

- (void)checksFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    NSLog(@"responseDic == %@",responseDic);
    [missingValuesArray removeAllObjects];
    [missingValuesArray addObject:responseDic.count > 0 ? [responseDic objectForKey:@"miss"] : @""];
    
    [self initBallViews];
    
    if (_selectedBallsDic != nil) {
        if (_lotteryID == 83) {
            [self setStatus];
            
        } else {
           [self setBallStatus];
        }
        
        [self showBetCount];
    }
}

- (void)initBallViews {
    
}

- (void)setStatus {
    
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (IS_PHONE ? ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 22.0f : 30.0f) : ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 44.0f : 60.0f));
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (IS_PHONE ? ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 10.0f : 30.0f) : ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 40.0f : 60.0f));
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width, (IS_PHONE ? ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 20.0f : 30.0f) : ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 40.0f : 60.0f)));
    UIView *headerView = [[UIView alloc]initWithFrame:headerViewRect];
    NSArray *array;
    if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 62 || [[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 78 || [[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 70) {
        array = [NSArray arrayWithObjects:@"期次",@"开奖号码",nil];
    } else {
        array = [NSArray arrayWithObjects:@"期次",@"开奖号码",@"形态", nil];
    }
    for (int i = 0; i < array.count; i++) {
        CGRect lableRect = CGRectMake(i * (array.count == 2 ? kWinSize.width / 2.0f : kWinSize.width / 3.0f), 0, array.count == 2 ? kWinSize.width / 2.0f : kWinSize.width / 3.0f, (IS_PHONE ? ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 20.0f : 30.0f) : ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 40.0f : 60.0f)));
        UILabel *lable = [[UILabel alloc] initWithFrame:lableRect];
        [lable setText:[array objectAtIndex:i]];
        [lable setTextAlignment:NSTextAlignmentCenter];
        [lable setBackgroundColor:[UIColor whiteColor]];
        [lable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [headerView addSubview:lable];
        [lable release];
    }
    
    return [headerView autorelease];
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83 ? 10 : 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomNotificationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        //backView 背景视图 用来添加开奖信息
        UIView *backView = [[UIView alloc] init];
        [backView setBackgroundColor:[UIColor clearColor]];
        [backView setTag:501];
        [cell.contentView addSubview:backView];
        [backView release];
        
        if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 62 || [[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 78 || [[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 70) {
            CGRect issueLableRect = CGRectMake(0, 0, kWinSize.width / 2.0f, cell.height);
            UILabel *issueLable = [[UILabel alloc] initWithFrame:issueLableRect];
            [issueLable setBackgroundColor:[UIColor clearColor]];
            [issueLable setTextAlignment:NSTextAlignmentCenter];
            [issueLable setTag:601];
            [issueLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
            [issueLable setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
            [cell.contentView addSubview:issueLable];
            [issueLable release];
            
            CGRect winningNumbersLableRect = CGRectMake(CGRectGetMaxX(issueLableRect), 0, kWinSize.width / 2.0f, cell.height);
            UILabel *winningNumbersLable = [[UILabel alloc] initWithFrame:winningNumbersLableRect];
            [winningNumbersLable setBackgroundColor:[UIColor clearColor]];
            [winningNumbersLable setTextAlignment:NSTextAlignmentCenter];
            [winningNumbersLable setTag:605];
            [winningNumbersLable setTextColor:[UIColor redColor]];
            [winningNumbersLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
            [cell.contentView addSubview:winningNumbersLable];
            [winningNumbersLable release];
            
        } else {
            if ([[_lotteryDic objectForKey:@"lotteryid"] integerValue] == 83) {
                CGRect issueLableRect = CGRectMake(0, 0, kWinSize.width / 3.0f, cell.height);
                UILabel *issueLable = [[UILabel alloc] initWithFrame:issueLableRect];
                [issueLable setBackgroundColor:[UIColor clearColor]];
                [issueLable setTextAlignment:NSTextAlignmentCenter];
                [issueLable setTag:601];
                [issueLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [issueLable setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                [cell.contentView addSubview:issueLable];
                [issueLable release];
                
                CGRect image1Rect = CGRectMake(CGRectGetMaxX(issueLableRect), 12, kWinSize.width / 12.0f - 3, cell.height - 24);
                UIImageView *image1 = [[UIImageView alloc] initWithFrame:image1Rect];
                [image1 setTag:602];
                [cell.contentView addSubview:image1];
                [image1 release];
                
                CGRect image2Rect = CGRectMake(CGRectGetMaxX(image1Rect) + 3, 12, kWinSize.width / 12.0f - 3, cell.height - 24);
                UIImageView *image2 = [[UIImageView alloc] initWithFrame:image2Rect];
                [image2 setTag:603];
                [cell.contentView addSubview:image2];
                [image2 release];
                
                CGRect image3Rect = CGRectMake(CGRectGetMaxX(image2Rect) + 3, 12, kWinSize.width / 12.0f - 3, cell.height - 24);
                UIImageView *image3 = [[UIImageView alloc] initWithFrame:image3Rect];
                [image3 setTag:604];
                [cell.contentView addSubview:image3];
                [image3 release];
                
                CGRect winningNumbersLableRect = CGRectMake(CGRectGetMaxX(image3Rect) + 3, 0, kWinSize.width / 12.0f, cell.height);
                UILabel *winningNumbersLable = [[UILabel alloc] initWithFrame:winningNumbersLableRect];
                [winningNumbersLable setBackgroundColor:[UIColor clearColor]];
                [winningNumbersLable setTextAlignment:NSTextAlignmentCenter];
                [winningNumbersLable setTag:605];
                [winningNumbersLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [winningNumbersLable setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                [cell.contentView addSubview:winningNumbersLable];
                [winningNumbersLable release];
                
                CGRect playTypeLableRect = CGRectMake(kWinSize.width / 3.0f * 2, 0, kWinSize.width / 3.0f, cell.height);
                UILabel *playTypeLable = [[UILabel alloc] initWithFrame:playTypeLableRect];
                [playTypeLable setBackgroundColor:[UIColor clearColor]];
                [playTypeLable setTextAlignment:NSTextAlignmentCenter];
                [playTypeLable setTag:606];
                [playTypeLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
                [playTypeLable setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                [cell.contentView addSubview:playTypeLable];
                [playTypeLable release];
                
            } else {
                CGRect issueLableRect = CGRectMake(0, 0, kWinSize.width / 3.0f, cell.height);
                UILabel *issueLable = [[UILabel alloc] initWithFrame:issueLableRect];
                [issueLable setBackgroundColor:[UIColor clearColor]];
                [issueLable setTextAlignment:NSTextAlignmentCenter];
                [issueLable setTag:601];
                [issueLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [issueLable setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                [cell.contentView addSubview:issueLable];
                [issueLable release];
                
                CGRect winningNumbersLableRect = CGRectMake(CGRectGetMaxX(issueLableRect), 0, kWinSize.width / 3.0f, cell.height);
                UILabel *winningNumbersLable = [[UILabel alloc] initWithFrame:winningNumbersLableRect];
                [winningNumbersLable setBackgroundColor:[UIColor clearColor]];
                [winningNumbersLable setTextAlignment:NSTextAlignmentCenter];
                [winningNumbersLable setTag:605];
                [winningNumbersLable setTextColor:[UIColor redColor]];
                [winningNumbersLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [cell.contentView addSubview:winningNumbersLable];
                [winningNumbersLable release];
                
                CGRect playTypeLableRect = CGRectMake(kWinSize.width / 3.0f * 2, 0, kWinSize.width / 3.0f, cell.height);
                UILabel *playTypeLable = [[UILabel alloc] initWithFrame:playTypeLableRect];
                [playTypeLable setBackgroundColor:[UIColor clearColor]];
                [playTypeLable setTextAlignment:NSTextAlignmentCenter];
                [playTypeLable setTag:606];
                [playTypeLable setTextColor:[UIColor redColor]];
                [playTypeLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [cell.contentView addSubview:playTypeLable];
                [playTypeLable release];
            }
        }
    }
    //backView 背景视图 用来添加开奖信息
    UIView *backView = (UIView *)[cell.contentView viewWithTag:501];
    for(UIView *view in backView.subviews) {
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (historyLotteryNumbersArray.count > 0) {
        NSArray *array = [historyLotteryNumbersArray objectAtIndex:0];
        NSDictionary *dic = [array objectAtIndex:indexPath.row];
        
        UILabel *issueLable = (UILabel *)[cell.contentView viewWithTag:601];
        [issueLable setText:[NSString stringWithFormat:@"%@期",[dic objectForKey:@"Name"]]];
        
        UILabel *winningNumbersLable = (UILabel *)[cell.contentView viewWithTag:605];
        [winningNumbersLable setText:[dic objectForKey:@"WinLotteryNumber"]];
        
        UILabel *playTypeLable = (UILabel *)[cell.contentView viewWithTag:606];
        [playTypeLable setText:[dic objectForKey:@"NumberType"]];
        
        UIImageView *image1 = (UIImageView *)[cell.contentView viewWithTag:602];
        UIImageView *image2 = (UIImageView *)[cell.contentView viewWithTag:603];
        UIImageView *image3 = (UIImageView *)[cell.contentView viewWithTag:604];
        
        NSString *winLotteryNumber = [dic objectForKey:@"WinLotteryNumber"];
        for (int i = 0; i < [winLotteryNumber length]; i++) {
            unichar c = [winLotteryNumber characterAtIndex:i];
            NSString *str = [NSString stringWithFormat:@"%c",c];
            
            switch ([str integerValue]) {
                case 1: {
                    if (i == 0) {
                        [image1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK31.png"]]];
                        
                    } else if (i == 1) {
                        [image2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK31.png"]]];
                        
                    } else {
                        [image3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK31.png"]]];
                    }
                    
                }
                    break;
                case 2: {
                    if (i == 0) {
                        [image1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK32.png"]]];
                        
                    } else if (i == 1) {
                        [image2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK32.png"]]];
                        
                    } else {
                        [image3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK32.png"]]];
                    }
                }
                    break;
                case 3: {
                    if (i == 0) {
                        [image1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK33.png"]]];
                        
                    } else if (i == 1) {
                        [image2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK33.png"]]];
                        
                    } else {
                        [image3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK33.png"]]];
                    }
                }
                    break;
                case 4: {
                    if (i == 0) {
                        [image1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK34.png"]]];
                        
                    } else if (i == 1) {
                        [image2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK34.png"]]];
                        
                    } else {
                        [image3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK34.png"]]];
                    }
                }
                    break;
                case 5: {
                    if (i == 0) {
                        [image1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK35.png"]]];
                        
                    } else if (i == 1) {
                        [image2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK35.png"]]];
                        
                    } else {
                        [image3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK35.png"]]];
                    }
                }
                    break;
                case 6: {
                    if (i == 0) {
                        [image1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK36.png"]]];
                        
                    } else if (i == 1) {
                        [image2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK36.png"]]];
                        
                    } else {
                        [image3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK36.png"]]];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark -Delegate
#pragma mark - SelectBallBottomViewDelegate
- (void)clearBalls {
    [self emptySelectedBallInBallViews];
    [self emptyArrays];
    [self showBetCount];
}

- (void)submitBalls {
    if (_totalBetCount < 1) {
        [XYMPromptView defaultShowInfo:@"请至少选择1注" isCenter:YES];
        return;
    }
    
    [self prepareGotoNextPage];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)ballSelect:(id)sender {
    Ball *ball = (Ball *)sender;
    
    NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    if ([[def objectForKey:kIsShake]integerValue] == 1)
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    if (ball.isSelected) {
        [ball setSelected:NO];
        [self removeBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
        
    } else {        
        [ball setSelected:YES];
        [self addBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
    }
    
    [self showBetCount];
}

//摇一摇功能
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if(event.subtype == UIEventSubtypeMotionShake) {
        NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
        if ([[def objectForKey:kIsShake]integerValue] == 1)
            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        
        [self shakePhoneAndSelectBallAutomatic];
    }
}

- (void)dismissViewController:(id)sender {
    if(_betViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//玩法介绍
- (void)getHelp:(id)sender {
    HelpViewController *helpViewController = [[HelpViewController alloc]initWithLotteryId:_lotteryID];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:helpViewController];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [nav release];
    [helpViewController release];
}


//提供方便重写
- (void)navMiddleBtnSelect:(id)sender {
}
#pragma mark -Customized: Private (General)


#pragma mark - MySelf Methods

- (void)getPlayMethods {
    _playMethodID = [GlobalsProject firstTypePlayIdWithTicketTypeName:self.title betTypeArray:_betTypeArray];
}

- (void)initArrays {
    _oneArray   = [[NSMutableArray alloc] initWithCapacity:0];
    _twoArray   = [[NSMutableArray alloc] initWithCapacity:0];
    _threeArray = [[NSMutableArray alloc] initWithCapacity:0];
    _fourArray  = [[NSMutableArray alloc] initWithCapacity:0];
    _fiveArray  = [[NSMutableArray alloc] initWithCapacity:0];
    _sixArray   = [[NSMutableArray alloc] initWithCapacity:0];
    _sevenArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initInvertSelectionVariable {
    _oneArray   = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kOneViewBalls]];
    _twoArray   = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kTwoViewBalls]];
    _threeArray = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kThreeViewBalls]];
    _fourArray  = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kFourViewBalls]];
    _fiveArray  = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kFiveViewBalls]];
    _sixArray   = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kSixViewBalls]];
    _sevenArray = [[NSMutableArray alloc] initWithArray:[_selectedBallsDic objectForKey:kSevenViewBalls]];
    
    _playMethodID = [[_selectedBallsDic objectForKey:kPlayID] integerValue];
    _selectBetType = [_selectedBallsDic objectForKey:kBetType];
}

- (void)setBallStatus {
    [self viewBallSetSelect:_oneArray view:_oneView];
    [self viewBallSetSelect:_twoArray view:_twoView];
    [self viewBallSetSelect:_threeArray view:_threeView];
    [self viewBallSetSelect:_fourArray view:_fourView];
    [self viewBallSetSelect:_fiveArray view:_fiveView];
    [self viewBallSetSelect:_sixArray view:_sixView];
    [self viewBallSetSelect:_sevenArray view:_sevenView];
}

- (void)viewBallSetSelect:(NSMutableArray *)array view:(UIView *)views {
    for (NSInteger i = 0; i < [array count]; i++) {
        NSInteger ballTag = [(NSNumber *)[array objectAtIndex:i] intValue];
        Ball *ball = (Ball *)[views viewWithTag:ballTag + 1];
        [ball setSelected:YES];
    }
}

- (void)emptyArrays {
    [_oneArray   removeAllObjects];
    [_twoArray   removeAllObjects];
    [_threeArray removeAllObjects];
    [_fourArray  removeAllObjects];
    [_fiveArray  removeAllObjects];
    [_sixArray   removeAllObjects];
    [_sevenArray removeAllObjects];
}

- (void)emptySelectedBallInBallViews {
    [self viewBallSelectNO:_oneArray view:_oneView];
    [self viewBallSelectNO:_twoArray view:_twoView];
    [self viewBallSelectNO:_threeArray view:_threeView];
    [self viewBallSelectNO:_fourArray view:_fourView];
    [self viewBallSelectNO:_fiveArray view:_fiveView];
    [self viewBallSelectNO:_sixArray view:_sixView];
    [self viewBallSelectNO:_sevenArray view:_sevenView];
}

- (void)viewBallSelectNO:(NSMutableArray *)array view:(UIView *)views {
    if ([array count] > 0) {
        for (UIView *view in views.subviews) {
            if([view isKindOfClass:[Ball class]]) {
                Ball *ball = (Ball *)view;
                [ball setSelected:NO];
            }
        }
    }
}

#pragma mark - Shake
- (void)setIsSupportShake:(BOOL)isSupportShake {
    _isSupportShake = isSupportShake;
    if (isSupportShake) {
        shakeBtn.hidden = NO;
        NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
        if ([[def objectForKey:kIsShakeToSelect] integerValue] == 1) {
            [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
            [self becomeFirstResponder];
        }
        
    } else {
        shakeBtn.hidden = YES;
        [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
        [self resignFirstResponder];
    }
}

- (void)shakePhoneAndSelectBallAutomatic {
}

- (void)getRandomBallAndFillViewWithExpectedCounts:(NSInteger)ballCounts maxBallNum:(NSInteger)maxNum minBallNum:(NSInteger)minNum inWitchArray:(NSInteger)arrayIndex {
    switch (arrayIndex) {
        case 1:
            [_oneArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        case 2:
            [_twoArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        case 3:
            [_threeArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        case 4:
            [_fourArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        case 5:
            [_fiveArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        case 6:
            [_sixArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        case 7:
            [_sevenArray addObjectsFromArray:[RandomNumber getRandomsBetweenMaxNum:maxNum minNum:minNum andExpectedRandomCounts:ballCounts]];
            break;
        default:
            break;
    }
}

#pragma mark - Load Ball View
- (void)createBallsWithBallsType:(BallsType)type minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)ballCountPerView onView:(UIView *)view {
    NSInteger a = 0;
    
    for (NSInteger i = minNum; i <= maxNum; i++) {
        NSString *title = nil;
        if (maxNum > 10) {
            if (i <= 9)
                title = [NSString stringWithFormat:@"0%ld",(long)i];
            
            else
                title = [NSString stringWithFormat:@"%ld",(long)i];
            
        } else
            title = [NSString stringWithFormat:@"%ld",(long)i];
        
        NSInteger row = a / ballCountPerView;
        NSInteger column = a % ballCountPerView;
        NSInteger gap = (view.frame.size.width - kBallSize * ballCountPerView) / (ballCountPerView + 1);
        NSInteger x = column * kBallSize + gap * (column + 1) ;
        NSInteger y = row * (gap + kBallSize);
        
        Ball *ball = [[Ball alloc]initWithType:type Title:title];
        ball.frame = CGRectMake(x, y, kBallSize, kBallSize);
        ball.tag = i + 1;
        [ball addTarget:self action:@selector(ballSelect:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:ball];
        [ball release];
        
        a++;
    }
}

- (CGFloat)calculateBallViewHeightWithViewWidth:(CGFloat)viewWidth andBallCountPerView:(NSInteger)ballCountPerView andBallCountPerRow:(NSInteger)countPerRow isHidden:(BOOL)ishidden {
    if (ballCountPerView <= countPerRow) {
        return kBallSize + 4;
        
    } else {
        CGFloat gap = (viewWidth - kBallSize * countPerRow) / (countPerRow + 1);   // 7个球总共有8个空隙（包括左右两端的）
        CGFloat allBallHeight = 0.0;
        NSInteger a = ballCountPerView / countPerRow;   // 每行规定7个球
        NSInteger b = ballCountPerView % countPerRow;
        
        if (b == 0) {   // 有a行
            allBallHeight = (kBallSize + gap + (ishidden ? 0 : 20)) * a;
            
        } else {        // 有a+1行
            allBallHeight = (kBallSize + gap + (ishidden ? 0 : 20)) * (a + 1);
        }
        
        return allBallHeight;
    }
}

- (CGFloat)calculateBallViewHeightWithViewWidth:(CGFloat)viewWidth andBallCountPerView:(NSInteger)ballCountPerView andBallCountPerRow:(NSInteger)countPerRow {
    if (ballCountPerView <= countPerRow) {
        return kBallSize + 4;
        
    } else {
        CGFloat gap = (viewWidth - kBallSize * countPerRow) / (countPerRow + 1);   // 7个球总共有8个空隙（包括左右两端的）
        CGFloat allBallHeight = 0.0;
        NSInteger a = ballCountPerView / countPerRow;   // 每行规定7个球
        NSInteger b = ballCountPerView % countPerRow;
        
        if (b == 0) {   // 有a行
            allBallHeight = (kBallSize + gap) * a;
            
        } else {        // 有a+1行
            allBallHeight = (kBallSize + gap) * (a + 1);
        }
        
        return allBallHeight;
    }
}

- (void)addPromptMsgInBallView:(CGRect)frame message:(NSString *)msg {
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [label setTextColor:[UIColor grayColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:msg];
    [_scrollView addSubview:label];
    [label release];
}

- (void)addLineBewteenBallViewWithCoordY:(CGFloat)y {
    CGRect lineFrame = CGRectMake(kLineX, y, kLineWidth, kLineHeight);
    [Globals createBlackWithImageViewWithFrame:lineFrame inSuperView:_scrollView];
}

- (void)loadBallViewWithFrame:(CGRect)frame whichView:(NSInteger)viewIndex minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)ballCountPerView {
    switch (viewIndex) {
        case 1: {
            _oneView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_oneView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        case 2: {
            _twoView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_twoView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        case 3: {
            _threeView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_threeView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        case 4: {
            _fourView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_fourView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        case 5: {
            _fiveView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_fiveView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        case 6: {
            _sixView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_sixView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        case 7: {
            _sevenView = [[UIView alloc]initWithFrame:frame];
            [self makeView:_sevenView minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView];
        }
            break;
        default:
            break;
    }
}

- (void)makeView:(UIView *)views minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)ballCountPerView {
    [views setBackgroundColor:[UIColor clearColor]];
    [self createBallsWithBallsType:Red minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:ballCountPerView onView:views];
    [_scrollView addSubview:views];
    [views release];
}

- (void)loadGreaterOneBallViewWithCoordY:(CGFloat)y hasLabel:(BOOL)hasLabel whichView:(NSInteger)viewIndex totalBallCount:(NSInteger)counts ballCountsPerRow:(NSInteger)countsPerRow minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum msg:(NSString *)string {
    NSInteger labelY = y + 8;
    // 提示
    if (hasLabel) {
        [self addPromptMsgInBallView:CGRectMake(kPromptMsgLabelX, labelY, kPromptMsgLabelWidth, kPromptMsgLabelHeight) message:string];
    }
    
    // 很多球
    NSInteger oneviewY = labelY;
    if (hasLabel) {
        oneviewY = labelY + kPromptMsgLabelHeight + 3;
    }
    
    CGRect viewFrame = CGRectMake(0, oneviewY, kWinSize.width, [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:countsPerRow]);
    [self loadBallViewWithFrame:viewFrame whichView:viewIndex minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow];
}

- (CGFloat)getFirstCoordYAfterView:(UIView *)view {
    return CGRectGetMinY(view.frame) + CGRectGetHeight(view.frame);
}

- (void)loadOneView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
    NSInteger labelY = 4;
    // 提示
    if (hasLabel) {
        [self addPromptMsgInBallView:CGRectMake(kPromptMsgLabelX, labelY, kPromptMsgLabelWidth, kPromptMsgLabelHeight) message:_oneViewPromptString];
    }
    
    // 很多球
    NSInteger oneviewY = labelY;
    if (hasLabel) {
        oneviewY = labelY + kPromptMsgLabelHeight + 3;
    }
    
    CGRect viewFrame = CGRectMake(0, oneviewY, kWinSize.width, [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:countsPerRow]);
    [self loadBallViewWithFrame:viewFrame whichView:1 minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow];
}

- (void)loadTwoView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
    [self loadOneView:hasLabel minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow totalBallCounts:counts];
    
    CGFloat y = [self getFirstCoordYAfterView:_oneView];
    [self addLineBewteenBallViewWithCoordY:y];
    [self loadGreaterOneBallViewWithCoordY:y hasLabel:hasLabel whichView:2 totalBallCount:counts ballCountsPerRow:countsPerRow minBallNum:minNum maxBallNum:maxNum msg:_twoViewPromptString];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _twoView.frame.origin.y + _twoView.frame.size.height)];
}

- (void)loadThreeView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
    [self loadTwoView:hasLabel minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow totalBallCounts:counts];
    
    CGFloat y = [self getFirstCoordYAfterView:_twoView];
    [self addLineBewteenBallViewWithCoordY:y];
    [self loadGreaterOneBallViewWithCoordY:y hasLabel:hasLabel whichView:3 totalBallCount:counts ballCountsPerRow:countsPerRow minBallNum:minNum maxBallNum:maxNum msg:_threeViewPromptString];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _threeView.frame.origin.y + _threeView.frame.size.height)];
}

- (void)loadFourView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
    [self loadThreeView:hasLabel minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow totalBallCounts:counts];
    
    CGFloat y = [self getFirstCoordYAfterView:_threeView];
    [self addLineBewteenBallViewWithCoordY:y];
    [self loadGreaterOneBallViewWithCoordY:y hasLabel:hasLabel whichView:4 totalBallCount:counts ballCountsPerRow:countsPerRow minBallNum:minNum maxBallNum:maxNum msg:_fourViewPromptString];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _fourView.frame.origin.y + _fourView.frame.size.height)];
}

- (void)loadFiveView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
    [self loadFourView:hasLabel minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow totalBallCounts:counts];
    
    CGFloat y = [self getFirstCoordYAfterView:_fourView];
    [self addLineBewteenBallViewWithCoordY:y];
    [self loadGreaterOneBallViewWithCoordY:y hasLabel:hasLabel whichView:5 totalBallCount:counts ballCountsPerRow:countsPerRow minBallNum:minNum maxBallNum:maxNum msg:_fiveViewPromptString];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width,_fiveView.frame.origin.y + _fiveView.frame.size.height)];
}

- (void)loadSixView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
}

- (void)loadSevenView:(BOOL)hasLabel minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)countsPerRow totalBallCounts:(NSInteger)counts {
}

#pragma mark -
#pragma mark -Init UI
- (void)createNavMiddleView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat midViewWidth = IS_PHONE ? 145.0f : 200.0f;
    CGFloat midViewHeight = IS_PHONE ? 25.0f : 35.0f;
    /********************** adjustment end ***************************/
    
    CGRect midViewRect = CGRectMake(0, 0, midViewWidth, midViewHeight);
    UIView *midView = [[UIView alloc]initWithFrame:midViewRect];
    [self.navigationItem setTitleView:midView];
    [midView release];
    
    CGRect midBtnRect = CGRectMake(0, 0, midViewWidth, midViewHeight);
    UIButton *midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [midBtn setFrame:midBtnRect];
    [midBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [midBtn setTitle:_selectBetType forState:UIControlStateNormal];
    [midBtn setTag:1000];
    [midBtn setAdjustsImageWhenHighlighted:NO];
    [midBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [midBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    [midBtn addTarget:self action:@selector(navMiddleBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
    [midView addSubview:midBtn];
    // selectedBallsDic不为空则表示为反选
    if (_selectedBallsDic != nil || (_zixuanBallsDic && ([[_zixuanBallsDic objectForKey:@"hasBetDic"] integerValue] == 23))) {
        
    }
    
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
    
}

- (void)fillHeadViewData {
    NSString *openNumber = [self getLastOpenNumber];
    // 显示开奖号码
    if (!_isQuickLotteryView) {
        if (openNumber != nil && openNumber.length >= 3) {
            NSRange range = [openNumber rangeOfString:@"-"];
            if (range.location != NSNotFound) {
                // 有篮球
                NSArray *arr = [openNumber componentsSeparatedByString:@"-"];
                NSString *openRedNumber = [arr objectAtIndex:0];
                NSString *openBlueNumber = [arr objectAtIndex:1];
                
                // 显示上期开奖号码
                NSString *text = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font><font color=\"%@\">%@</font>",tRedColorText,openRedNumber,tBlueColorText,openBlueNumber];
                MarkupParser *p = [[MarkupParser alloc]init];
                NSAttributedString *attString = [p attrStringFromMarkup:text];
                [p release];
                [_lastWinNumLabel setAttString:attString];
                
            } else {
                // 只有红球
                [_lastWinNumlabels setText:openNumber];
            }
        }
    } else {
        if (_lotteryID == 83) {
            [_lassWinNumlabels setText:openNumber];
        }
        
        NSDate *endDate = nil;
        NSTimeInterval intervall = 0;
        
        if(_lotteryDic && [_lotteryDic objectForKey:@"endtime"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            endDate = [dateFormatter dateFromString:[_lotteryDic objectForKey:@"endtime"]];
            [dateFormatter release];
        }
        
        if (endDate) {
            intervall = [self getTimeIntervalWithEndDate:endDate];
        }
        
        NSTimeZone *zone = [NSTimeZone localTimeZone];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        // 系统返回时间
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[Globals getTimeWithIntervalTime:_globals.serverLocalTimeInterval]];
        NSTimeInterval currServiceInterval = [zone secondsFromGMTForDate:currentDate];
        NSDate *serviceDate = [currentDate  dateByAddingTimeInterval: currServiceInterval];
        
        // 下一期开始时间
        NSString *nextstarttimeStr = [_lotteryDic objectForKey:@"originalTime"];
        NSDate *tmpNextStartDate = [dateFormatter dateFromString:nextstarttimeStr];
        NSTimeInterval nextInterval = [zone secondsFromGMTForDate:tmpNextStartDate];
        NSDate *nextStartDate = [tmpNextStartDate  dateByAddingTimeInterval: nextInterval];
        [dateFormatter release];
        
        NSTimeInterval startTimeInterval = 60.0f;
        //
        if (endDate) {
            startTimeInterval = [tmpNextStartDate timeIntervalSinceNow] - [endDate timeIntervalSinceNow];
            if (startTimeInterval < 60) {
                startTimeInterval = 60;
                
            }else if (startTimeInterval < 0){
                startTimeInterval = 0;
            }
        }
        
        if ([nextstarttimeStr isEqualToString:@""]) {
            [_timeLabel setText:@"已截止"];
            
        }else {
            // 下一期开始时间早于系统返回时间，则不显示
            if ([nextStartDate compare:serviceDate] == NSOrderedAscending) {
                
            } else {
                [_timeLabel updateText:[NSString stringWithFormat:@"%f",intervall + [[NSDate date] timeIntervalSinceReferenceDate]] updateTag:_lotteryID isStartSell:YES];
                [_timeLabel setNextStartTimeInterval:startTimeInterval];
            }
        }
    }
}

- (NSTimeInterval)getTimeIntervalWithEndDate:(NSDate *)endDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:[Globals getTimeWithIntervalTime:_globals.serverLocalTimeInterval]];
    NSTimeInterval interval = [endDate timeIntervalSinceDate:serverDate];
    [dateFormatter release];
    
    return interval;
}

-(void)changeShakeButton:(UIButton *)sender {
    NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    if ([[def objectForKey:kIsShake]integerValue] == 1)
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    [self randomNumber];
}

- (void)makeShakeBtn {
    /********************** adjustment 控件调整 ***************************/
    CGFloat shakeBtnIntervalRight = IS_PHONE ? 10.0f : 20.0f;
    CGFloat shakeBtnAddY = IS_PHONE ? 6.0f : 10.0f;
    CGFloat shakeBtnWidth = IS_PHONE ? 58.0f : 87.0f;
    CGFloat shakeBtnHeight = IS_PHONE ? 22.5f : 33.6f;
    /********************** adjustment end ***************************/
    
    CGRect yellowShakeBtnRect = CGRectMake(kWinSize.width - shakeBtnIntervalRight - shakeBtnWidth, shakeBtnAddY, shakeBtnWidth, shakeBtnHeight);
    UIButton *yellowShakeBtn = [UIButton buttonWithType:UIButtonTypeCustom]; //按钮的类型
    [yellowShakeBtn setFrame:yellowShakeBtnRect];
    [yellowShakeBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ramdom.png"]] forState:UIControlStateNormal];
    [yellowShakeBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ramdom.png"]] forState:UIControlStateSelected];
    yellowShakeBtn.tag = 1;
    [yellowShakeBtn addTarget:self action:@selector(changeShakeButton:)forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:yellowShakeBtn];
}

#pragma mark - Display Label
//获取上一期的开奖号码
- (NSString *)getLastOpenNumber {
    NSString *openNumber = [NSString string];
    if([_lotteryDic objectForKey:@"lastWinNumber"]) {
        openNumber = [_lotteryDic objectForKey:@"lastWinNumber"];
    }
    
    return openNumber;
}

#pragma mark - Select Ball Events and Calculate bet counts
- (void)checkHasSameBallWithView:(UIView *)view ballTag:(NSInteger)ballTag {
    for (UIView *ballView in view.subviews) {
        Ball *ball = (Ball *)ballView;
        if (ball.tag == ballTag) {
            [ball setSelected:NO];
            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:view];
            [self showBetCount];
        }
    }
}

- (BOOL)isBallInViewWithCurrentBallTag:(NSNumber *)ballNum desArray:(NSArray *)array {
    for (NSNumber *num in array) {
        if([ballNum isEqualToNumber:num]) {
            return YES;
        }
    }
    return NO;
}

- (void)addBallInSpecifiedArrayWithTag:(NSInteger)ballTag baseView:(UIView *)baseView {
    if ([baseView isEqual:_oneView]) {
        [_oneArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_twoView]) {
        [_twoArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_threeView]) {
        [_threeArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_fourView]) {
        [_fourArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_fiveView]) {
        [_fiveArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_sixView]) {
        [_sixArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_sevenView]) {
        [_sevenArray addObject:[NSNumber numberWithInteger:ballTag - 1]];
    }
}

- (void)removeBallInSpecifiedArrayWithTag:(NSInteger)ballTag baseView:(UIView *)baseView {
    if ([baseView isEqual:_oneView]) {
        [_oneArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_twoView]) {
        [_twoArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_threeView]) {
        [_threeArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_fourView]) {
        [_fourArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_fiveView]) {
        [_fiveArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_sixView]) {
        [_sixArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
        
    } else if ([baseView isEqual:_sevenView]) {
        [_sevenArray removeObject:[NSNumber numberWithInteger:ballTag - 1]];
    }
}

- (void)showBetCount {
    [_bottomView setTextWithCount:0 money:0];
}

//提供方便重写
- (void)prepareGotoNextPage {
    
}

- (NSString *)getSelectedBallNumbers {
    NSString *str = @"";
    switch (_lotteryID) {
        case 69:    // 22选5
            str = [MyTool getESEXWBetNumberStringWithOneArray:[MyTool sortArrayFromSmallToLarge:_oneArray]
                                                    andPlayID:_playMethodID
                                            andPlayMethodName:_selectBetType];
            break;
        case 82:    // 幸运彩
            break;
        case 68:    // 快赢481
            str = [MyTool getKY481BetNumberStringWithOneArray:[MyTool sortArrayFromSmallToLarge:_oneArray]
                                                          two:[MyTool sortArrayFromSmallToLarge:_twoArray]
                                                        three:[MyTool sortArrayFromSmallToLarge:_threeArray]
                                                         four:[MyTool sortArrayFromSmallToLarge:_fourArray]
                                                    andPlayID:_playMethodID
                                            andPlayMethodName:_selectBetType];
            break;
        default:
            break;
    }
    return str;
}

- (NSMutableDictionary *)combineBetContentDic {
    NSMutableDictionary *aBetsDic = [NSMutableDictionary dictionary];
    [aBetsDic setObject:[self getSelectedBallNumbers] forKey:kSelectBalls];
    [aBetsDic setObject:_selectBetType forKey:kBetType];
    [aBetsDic setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
    [aBetsDic setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
    [aBetsDic setObject:[NSNumber numberWithInteger:_totalBetCount] forKey:kBetCount];
    
    [aBetsDic setObject:_oneArray forKey:kOneViewBalls];
    [aBetsDic setObject:_twoArray forKey:kTwoViewBalls];
    [aBetsDic setObject:_threeArray forKey:kThreeViewBalls];
    [aBetsDic setObject:_fourArray forKey:kFourViewBalls];
    [aBetsDic setObject:_fiveArray forKey:kFiveViewBalls];
    [aBetsDic setObject:_sixArray forKey:kSixViewBalls];
    [aBetsDic setObject:_sevenArray forKey:kSevenViewBalls];
    
    return aBetsDic;
}

- (void)randomNumber {
    
}

@end
