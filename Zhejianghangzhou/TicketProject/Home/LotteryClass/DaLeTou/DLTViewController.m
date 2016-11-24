//
//  DLTViewController.m 购彩大厅－大乐透选号
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140916 09:11（洪晓彬）：修改代码规范，处理内存
//20140916 09:48（洪晓彬）：进行ipad适配

#define kDLTBallsViewHeaderCommonHeight        (IS_PHONE ? 40.0f : 60.0f)
#define kDLTBallsViewHeaderDantuoHeight        (IS_PHONE ? 40.0f : 60.0f)

#define kDLTBallsCountsPerRow                   (IS_PHONE ? 7 : 8)       // 每行显示球的数量
#define kDLTRedMinBall                          1       // 红球最小的索引
#define kDLTRedMaxBall                          35      // 红球最大的索引
#define kDLTBlueMinBall                         1       // 蓝球最小的索引
#define kDLTBlueMaxBall                         12      // 蓝球最大的索引
#define kDLTRedBallCanAutoSelectedMaxCounts     18      // 红球机选最多可选择的个数
#define kDLTRedBallCanAutoSelectedMinCounts     5       // 红球机选最少可选择的个数
#define kDLTBlueBallCanAutoSelectedMaxCounts    12      // 蓝球机选最多可选择的个数
#define kDLTBlueBallCanAutoSelectedMinCounts    2       // 蓝球机选最少可选择的个数
#define kDLTRedBallNormalCounts                 5       // 标准红球个数(开奖时)，也就是最少选择的个数
#define kDLTBlueBallNormalCounts                2       // 标准蓝球个数(开奖时)，也就是最少选择的个数
#define kDLTMaxAmounts                          20000   // 单方案不能超过的最大金额


#import "DLTViewController.h"
#import "Ball.h"
#import "DLTBetViewController.h"
#import "SelectBallBottomView.h"
#import "SSQPlayMethodView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "CalculateBetCount.h"
#import "DLTParserNumber.h"
#import "RandomNumber.h"
#import "Globals.h"
#import "MyTool.h"

@interface DLTViewController ()

@end

@implementation DLTViewController
- (void)dealloc {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    _blueballAutoView = nil;
    _playMethodView = nil;
    
    [super dealloc];
}

- (void) loadView {
    [self setTitle:@"大乐透"];
    [super loadView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _isSupportShake = YES;
    [self getPlayMethods];
    if(_selectedBallsDic == nil) {
        if (_zixuanBallsDic) {
            _playMethodID = [[_zixuanBallsDic objectForKey:kPlayID] integerValue];
            _selectBetType = [_zixuanBallsDic objectForKey:kBetType];
            _isSupportShake = [[_zixuanBallsDic objectForKey:kIsSupportShake] integerValue];
        } else  {
            _selectBetType = [_betTypeArray objectAtIndex:0];
        }
        [self initBallViews];
    } else {
        _isSupportShake = [[_selectedBallsDic objectForKey:kIsSupportShake] integerValue];
        _playMethodID = [[_selectedBallsDic objectForKey:kPlayID] integerValue];
        _selectBetType = [_selectedBallsDic objectForKey:kBetType];
        [self initBallViews];
        [self setBallStatus];
        [self showBetCount];
    }
    [self createNavMiddleView];
    [self createPlayMethodView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _blueballAutoView = nil;
        _playMethodView = nil;
        
        self.view = nil;
    }
}

- (void)initBallViews {
    switch (_playMethodID) {
        case 3901: {
            [self loadRedViewWithMinBallNum:kDLTRedMinBall
                                 maxBallNum:kDLTRedMaxBall
                           ballCountsPerRow:kDLTBallsCountsPerRow
                            totalBallCounts:kDLTRedMaxBall];
            [self loadBlueViewWithMinBallNum:kDLTBlueMinBall
                                  maxBallNum:kDLTBlueMaxBall
                            ballCountsPerRow:kDLTBallsCountsPerRow
                             totalBallCounts:kDLTBlueMaxBall];
        }
            break;
        case 3903: {
            [self loadDanViewForDantuoWithMinBallNum:kDLTRedMinBall
                                          maxBallNum:kDLTRedMaxBall
                                    ballCountsPerRow:kDLTBallsCountsPerRow
                                     totalBallCounts:kDLTRedMaxBall];
            [self loadTuoViewForDantuoWithMinBallNum:kDLTRedMinBall
                                          maxBallNum:kDLTRedMaxBall
                                    ballCountsPerRow:kDLTBallsCountsPerRow
                                     totalBallCounts:kDLTRedMaxBall];
            [self loadBlueViewForDantuoWithMinBallNum:kDLTBlueMinBall
                                           maxBallNum:kDLTBlueMaxBall
                                     ballCountsPerRow:kDLTBallsCountsPerRow
                                      totalBallCounts:kDLTBlueMaxBall];
        }
            break;
        case 3906: {
            [self loadDanViewForDantuoWithMinBallNum:kDLTRedMinBall
                                          maxBallNum:kDLTRedMaxBall
                                    ballCountsPerRow:kDLTBallsCountsPerRow
                                     totalBallCounts:kDLTRedMaxBall];
            [self loadBlueViewForDantuoWithMinBallNum:kDLTBlueMinBall
                                           maxBallNum:kDLTBlueMaxBall
                                     ballCountsPerRow:kDLTBallsCountsPerRow
                                      totalBallCounts:kDLTBlueMaxBall];
            [self loadBlueViewDantuoWithMinBallNum:kDLTBlueMinBall
                                        maxBallNum:kDLTBlueMaxBall
                                  ballCountsPerRow:kDLTBallsCountsPerRow
                                   totalBallCounts:kDLTBlueMaxBall];
        }
            break;
        case 3907: {
            [self loadDanViewForDantuoWithMinBallNum:kDLTRedMinBall
                                          maxBallNum:kDLTRedMaxBall
                                    ballCountsPerRow:kDLTBallsCountsPerRow
                                     totalBallCounts:kDLTRedMaxBall];
            [self loadTuoViewForDantuoWithMinBallNum:kDLTRedMinBall
                                          maxBallNum:kDLTRedMaxBall
                                    ballCountsPerRow:kDLTBallsCountsPerRow
                                     totalBallCounts:kDLTRedMaxBall];
            [self loadBlueViewForDantuoWithMinBallNum:kDLTBlueMinBall
                                           maxBallNum:kDLTBlueMaxBall
                                     ballCountsPerRow:kDLTBallsCountsPerRow
                                      totalBallCounts:kDLTBlueMaxBall];
            [self loadBlueViewDantuoWithMinBallNum:kDLTBlueMinBall
                                        maxBallNum:kDLTBlueMaxBall
                                  ballCountsPerRow:kDLTBallsCountsPerRow
                                   totalBallCounts:kDLTBlueMaxBall];
        }
            break;
        default:
            break;
    }
}

- (void)shakePhoneAndSelectBallAutomatic {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user objectForKey:kDefaultSettings];
    NSInteger isOk = [[dic objectForKey:kIsShakeToSelect]integerValue];
    if (isOk == 0) {
        return;
    }
    
    [self randomNumber];
    
}

- (void)randomNumber {
    [self clearBalls];
    if (_playMethodID == 3901) {
        [self getRandomBallAndFillViewWithExpectedCounts:kDLTRedBallNormalCounts
                                              maxBallNum:kDLTRedMaxBall
                                              minBallNum:kDLTRedMinBall
                                            inWitchArray:1];
        [self getRandomBallAndFillViewWithExpectedCounts:kDLTBlueBallNormalCounts
                                              maxBallNum:kDLTBlueMaxBall
                                              minBallNum:kDLTBlueMinBall
                                            inWitchArray:2];
    }
    [self setBallStatus];
    [self showBetCount];
}

- (void)submitBalls {
    if ((_playMethodID != 3902 && _playMethodID != 3901) && _totalBetCount < 2) {
        [XYMPromptView defaultShowInfo:@"请至少选择2注" isCenter:YES];
        return;
    }
    if (_totalBetCount < 1) {
        [XYMPromptView defaultShowInfo:@"请至少选择1注" isCenter:YES];
        return;
    }
    
    
    [self prepareGotoNextPage];
}

#pragma mark - For 普通投注

- (void)loadRedBallHeaderView {
    UIView *redballAutoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, kDLTBallsViewHeaderCommonHeight)];
    redballAutoView.tag = 210;  // 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:redballAutoView];
    [redballAutoView release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">请至少选择</font><font color=\"%@\">5</font><font color=\"black\">个前区号码</font>",tRedColorText];
    CustomLabel *betTypeLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, lastPromptLabelWidth, kPromptMsgLabelHeight)];
    betTypeLabel.backgroundColor = [UIColor clearColor];
    [betTypeLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [redballAutoView addSubview:betTypeLabel];
    [betTypeLabel release];
    
    [self makeShakeBtn];
    
}

- (void)loadBlueBallHeaderView:(float)coordY {
    _blueballAutoView = [[UIView alloc]initWithFrame:CGRectMake(0, coordY, _scrollView.frame.size.width, kDLTBallsViewHeaderCommonHeight)];
    _blueballAutoView.tag = 220; // 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:_blueballAutoView];
    [_blueballAutoView release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">请至少选择</font><font color=\"%@\">2</font><font color=\"black\">个后区号码</font>",tRedColorText];
    CustomLabel *betTypeLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY , lastPromptLabelWidth, kPromptMsgLabelHeight)];
    betTypeLabel.backgroundColor = [UIColor clearColor];
    [betTypeLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [_blueballAutoView addSubview:betTypeLabel];
    [betTypeLabel release];
    
}

- (void)loadRedViewWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    [self loadRedBallHeaderView];
    UIView *view = [_scrollView viewWithTag:210];
    float y = view.frame.origin.y + kDLTBallsViewHeaderCommonHeight;
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:7];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame
                      whichView:1
                     minBallNum:minNum maxBallNum:maxNum
               ballCountsPerRow:countsPerRow
                      ballColor:Red];

    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _oneView.frame.origin.y + _oneView.frame.size.height)];
}

- (void)loadBlueViewWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    float y = [self getFirstCoordYAfterView:_oneView];
    [self addLineBewteenBallViewWithCoordY:y];
    [self loadBlueBallHeaderView:y+2];
    UIView *view = [_scrollView viewWithTag:220];
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                andBallCountPerView:counts
                                                 andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, view.frame.origin.y + kDLTBallsViewHeaderCommonHeight + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame
                      whichView:2
                     minBallNum:minNum
                     maxBallNum:maxNum
               ballCountsPerRow:countsPerRow
                      ballColor:Blue];

    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _twoView.frame.origin.y + _twoView.frame.size.height)];
}

#pragma mark - For 胆拖投注

- (void)loadDanAreaHeaderView {
    if (_playMethodID == 3903 || _playMethodID == 3907) {
        UIView *danHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, kDLTBallsViewHeaderDantuoHeight)];
        danHeaderView.tag = 230;    // 设置tag以便之后能找到该view以计算位置
        [_scrollView addSubview:danHeaderView];
        [danHeaderView release];
        
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthC, kPromptMsgLabelHeight)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.textColor = [UIColor blackColor];
        leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
        leftLabel.text = @"前区胆码区";
        [danHeaderView addSubview:leftLabel];
        [leftLabel release];
        
        
        NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"%@\">1</font><font color=\"black\">个，最多</font><font color=\"%@\">4</font><font color=\"black\">个前区胆码</font>",tRedColorText,tRedColorText];
        CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(leftLabel.frame.origin.x + leftLabel.frame.size.width, promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight)];
        rightLabel.backgroundColor = [UIColor clearColor];
        [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
        [danHeaderView addSubview:rightLabel];
        [rightLabel release];

    } else {
        UIView *danHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, kDLTBallsViewHeaderDantuoHeight)];
        danHeaderView.tag = 230;    // 设置tag以便之后能找到该view以计算位置
        [_scrollView addSubview:danHeaderView];
        [danHeaderView release];
        
        NSString *text =[NSString stringWithFormat:@"<font color=\"black\">只能选择</font><font color=\"%@\">5</font><font color=\"black\">个前区号码</font>",tRedColorText];
        CustomLabel *leftLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, lastPromptLabelWidth, kPromptMsgLabelHeight)];
        leftLabel.backgroundColor = [UIColor clearColor];
        [leftLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
        [danHeaderView addSubview:leftLabel];
        [leftLabel release];
    }
}

- (void)loadTuoAreaHeaderView:(float)coordY {
    UIView *tuoHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, coordY, _scrollView.frame.size.width, kDLTBallsViewHeaderDantuoHeight)];
    tuoHeaderView.tag = 240;    // 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:tuoHeaderView];
    [tuoHeaderView release];
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthA, kPromptMsgLabelHeight)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
    leftLabel.text = @"前区拖码区";
    [tuoHeaderView addSubview:leftLabel];
    [leftLabel release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"%@\">2</font><font color=\"black\">个前区拖码</font>",tRedColorText];
    CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(leftLabel.frame.origin.x + leftLabel.frame.size.width, promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight)];
    rightLabel.backgroundColor = [UIColor clearColor];
    [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [tuoHeaderView addSubview:rightLabel];
    [rightLabel release];
}

- (void)loadBlueAreaHeaderView:(float)coordY {
    if (_playMethodID == 3903) {
        UIView *blueHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, coordY, _scrollView.frame.size.width, kDLTBallsViewHeaderDantuoHeight)];
        blueHeaderView.tag = 250;   // 设置tag以便之后能找到该view以计算位置
        [_scrollView addSubview:blueHeaderView];
        [blueHeaderView release];
        
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthB, kPromptMsgLabelHeight)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.textColor = [UIColor blackColor];
        leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
        leftLabel.text = @"后区号码";
        [blueHeaderView addSubview:leftLabel];
        [leftLabel release];
        
        NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"0074f0\">2</font><font color=\"black\">个后区号码</font>"];
        CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(leftLabel.frame.origin.x + leftLabel.frame.size.width, promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight)];
        rightLabel.backgroundColor = [UIColor clearColor];
        [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
        [blueHeaderView addSubview:rightLabel];
        [rightLabel release];

    } else if (_playMethodID == 3906 || _playMethodID == 3907) {
        UIView *blueHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, coordY, _scrollView.frame.size.width, kDLTBallsViewHeaderDantuoHeight)];
        blueHeaderView.tag = 250;   // 设置tag以便之后能找到该view以计算位置
        [_scrollView addSubview:blueHeaderView];
        [blueHeaderView release];
        
        UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthC, kPromptMsgLabelHeight)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.textColor = [UIColor blackColor];
        leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
        leftLabel.text = @"后区胆码区";
        [blueHeaderView addSubview:leftLabel];
        [leftLabel release];
        
        NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至多选出</font><font color=\"0074f0\">1</font><font color=\"black\">个后区胆码</font>"];
        CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(leftLabel.frame.origin.x + leftLabel.frame.size.width, promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight)];
        rightLabel.backgroundColor = [UIColor clearColor];
        [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
        [blueHeaderView addSubview:rightLabel];
        [rightLabel release];
    }
}

- (void)loadBlueHeaderView:(float)coordY {
    UIView *blueHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, coordY, _scrollView.frame.size.width, kDLTBallsViewHeaderDantuoHeight)];
    blueHeaderView.tag = 260;   // 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:blueHeaderView];
    [blueHeaderView release];
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthC, kPromptMsgLabelHeight)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
    leftLabel.text = @"后区拖码区";
    [blueHeaderView addSubview:leftLabel];
    [leftLabel release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"0074f0\">2</font><font color=\"black\">个后区拖码</font>"];
    CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(leftLabel.frame.origin.x + leftLabel.frame.size.width, promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight)];
    rightLabel.backgroundColor = [UIColor clearColor];
    [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [blueHeaderView addSubview:rightLabel];
    [rightLabel release];
}

- (void)loadDanViewForDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    [self loadDanAreaHeaderView];
    UIView *view = [_scrollView viewWithTag:230];
    float y = view.frame.origin.y + kDLTBallsViewHeaderDantuoHeight;
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                andBallCountPerView:counts
                                                 andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame
                      whichView:1
                     minBallNum:minNum
                     maxBallNum:maxNum
               ballCountsPerRow:countsPerRow
                      ballColor:Red];

    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _oneView.frame.origin.y + _oneView.frame.size.height)];
}

- (void)loadTuoViewForDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    float y1 = [self getFirstCoordYAfterView:_oneView];
    [self addLineBewteenBallViewWithCoordY:y1];
    [self loadTuoAreaHeaderView:y1+2];
    UIView *view = [_scrollView viewWithTag:240];
    float y = view.frame.origin.y + kDLTBallsViewHeaderDantuoHeight;
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                andBallCountPerView:counts
                                                 andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame
                      whichView:2
                     minBallNum:minNum
                     maxBallNum:maxNum
               ballCountsPerRow:countsPerRow
                      ballColor:Red];

    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _twoView.frame.origin.y + _twoView.frame.size.height)];
}

- (void)loadBlueViewForDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    if (_playMethodID == 3906) {
        float y1 = [self getFirstCoordYAfterView:_oneView];
        [self addLineBewteenBallViewWithCoordY:y1];
        [self loadBlueAreaHeaderView:y1+2];
        UIView *view = [_scrollView viewWithTag:250];
        float y = view.frame.origin.y + kDLTBallsViewHeaderDantuoHeight;
        CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                    andBallCountPerView:counts
                                                     andBallCountPerRow:countsPerRow];
        CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
        [self loadBallViewWithFrame:viewFrame
                          whichView:2
                         minBallNum:minNum
                         maxBallNum:maxNum
                   ballCountsPerRow:countsPerRow
                          ballColor:Blue];

        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _twoView.frame.origin.y + _twoView.frame.size.height)];
    } else {
        float y1 = [self getFirstCoordYAfterView:_twoView];
        [self addLineBewteenBallViewWithCoordY:y1];
        [self loadBlueAreaHeaderView:y1+2];
        UIView *view = [_scrollView viewWithTag:250];
        float y = view.frame.origin.y + kDLTBallsViewHeaderDantuoHeight;
        CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                    andBallCountPerView:counts
                                                     andBallCountPerRow:countsPerRow];
        CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
        [self loadBallViewWithFrame:viewFrame
                          whichView:3
                         minBallNum:minNum
                         maxBallNum:maxNum
                   ballCountsPerRow:countsPerRow
                          ballColor:Blue];
        
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _threeView.frame.origin.y + _threeView.frame.size.height)];
    }
}

- (void)loadBlueViewDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    if (_playMethodID == 3906) {
        float y1 = [self getFirstCoordYAfterView:_twoView];
        [self addLineBewteenBallViewWithCoordY:y1];
        [self loadBlueHeaderView:y1+2];
        UIView *view = [_scrollView viewWithTag:260];
        float y = view.frame.origin.y + kDLTBallsViewHeaderDantuoHeight;
        CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                    andBallCountPerView:counts
                                                     andBallCountPerRow:countsPerRow];
        CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
        [self loadBallViewWithFrame:viewFrame
                          whichView:3
                         minBallNum:minNum
                         maxBallNum:maxNum
                   ballCountsPerRow:countsPerRow
                          ballColor:Blue];

        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _threeView.frame.origin.y + _threeView.frame.size.height)];
    } else {
        float y1 = [self getFirstCoordYAfterView:_threeView];
        [self addLineBewteenBallViewWithCoordY:y1];
        [self loadBlueHeaderView:y1 + 2];
        UIView *view = [_scrollView viewWithTag:260];
        float y = view.frame.origin.y + kDLTBallsViewHeaderDantuoHeight;
        CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width
                                                    andBallCountPerView:counts
                                                     andBallCountPerRow:countsPerRow];
        CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
        [self loadBallViewWithFrame:viewFrame
                          whichView:4
                         minBallNum:minNum
                         maxBallNum:maxNum
                   ballCountsPerRow:countsPerRow
                          ballColor:Blue];
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _fourView.frame.origin.y + _fourView.frame.size.height)];
    }
    
}

- (void)loadBallViewWithFrame:(CGRect)frame whichView:(NSInteger)viewIndex minBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)ballCountPerView ballColor:(BallsType)type {
    switch (viewIndex) {
        case 1: {
            _oneView = [[UIView alloc]initWithFrame:frame];
            [_oneView setBackgroundColor:[UIColor clearColor]];
            [self createBallsWithBallsType:type
                                minBallNum:minNum
                                maxBallNum:maxNum
                          ballCountsPerRow:ballCountPerView
                                    onView:_oneView];
            [_scrollView addSubview:_oneView];
            [_oneView release];
            
        }
            break;
        case 2: {
            _twoView = [[UIView alloc]initWithFrame:frame];
            [_twoView setBackgroundColor:[UIColor clearColor]];
            [self createBallsWithBallsType:type
                                minBallNum:minNum
                                maxBallNum:maxNum
                          ballCountsPerRow:ballCountPerView
                                    onView:_twoView];
            [_scrollView addSubview:_twoView];
            [_twoView release];
            
        }
            break;
        case 3: {
            _threeView = [[UIView alloc]initWithFrame:frame];
            [_threeView setBackgroundColor:[UIColor clearColor]];
            [self createBallsWithBallsType:type
                                minBallNum:minNum
                                maxBallNum:maxNum
                          ballCountsPerRow:ballCountPerView
                                    onView:_threeView];
            [_scrollView addSubview:_threeView];
            [_threeView release];
            
        }
            break;
        case 4: {
            _fourView = [[UIView alloc]initWithFrame:frame];
            [_fourView setBackgroundColor:[UIColor clearColor]];
            [self createBallsWithBallsType:type
                                minBallNum:minNum
                                maxBallNum:maxNum
                          ballCountsPerRow:ballCountPerView
                                    onView:_fourView];
            [_scrollView addSubview:_fourView];
            [_fourView release];
            
        }
            break;
        default:
            break;
    }
}

- (void)showBetCount {
    _totalBetCount = [DLTParserNumber getCountForDLTWithOneArray:_oneArray
                                                             two:_twoArray
                                                           three:_threeArray
                                                            four:_fourArray
                                                     basedRedNum:kDLTRedBallNormalCounts
                                                    basedBlueNum:kDLTBlueBallNormalCounts
                                                       andPlayID:_playMethodID
                                               andPlayMethodName:_selectBetType];
    [_bottomView setTextWithCount:_totalBetCount money:_totalBetCount * 2];
}

#pragma mark - Delegate

- (void)addBallsToBallsArrayWithBallsType:(BallsType)type selectArray:(NSArray *)selectArray {
    switch (type) {
        case Red: {
            if (_oneArray.count > 0) {
                for (UIView *view in _oneView.subviews) {
                    if([view isKindOfClass:[Ball class]]) {
                        Ball *ball = (Ball *)view;
                        [ball setSelected:NO];
                    }
                }
            }
            [_oneArray removeAllObjects];
            [_oneArray addObjectsFromArray:selectArray];
        }
            break;
        case Blue: {
            if (_twoArray.count > 0) {
                for (UIView *view in _twoView.subviews) {
                    if([view isKindOfClass:[Ball class]])
                    {
                        Ball *ball = (Ball *)view;
                        [ball setSelected:NO];
                    }
                }
            }
            [_twoArray removeAllObjects];
            [_twoArray addObjectsFromArray:selectArray];
        }
            break;
        default:
            break;
    }
    
    [self setBallStatus];
    [self showBetCount];
}

- (void)createPlayMethodView {
    for (NSInteger i = 0;i < [_betTypeArray count]; i++) {
        if ([_selectBetType isEqualToString:[_betTypeArray objectAtIndex:i]]) {
            _btnIndex = i;
        }
    }
    _playMethodView = [[SSQPlayMethodView alloc]initWithPlayMethodNames:_betTypeArray lottery:self.title withIndex:_btnIndex];
    _playMethodView.delegate = self;
    [self.view addSubview:_playMethodView];
    [_playMethodView release];
}


- (void)navMiddleBtnSelect:(id)sender {
    UIButton *betTypeBtn = sender;
    if(_playMethodView.isHidden) {
        [betTypeBtn setBackgroundImage:[[UIImage imageNamed:@"bet_type_select.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_playMethodView setHidden:NO];
    } else {
        [betTypeBtn setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
        [_playMethodView setHidden:YES];
    }
}

- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    if (index>1) {
        NSString *str = [NSString stringWithFormat:@"%@",[_betTypeArray objectAtIndex:index]];
        [midButton setTitle:str forState:UIControlStateNormal];
        [midButton setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    } else {
        [midButton setTitle:[_betTypeArray objectAtIndex:index] forState:UIControlStateNormal];
        [midButton setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    }
    
    _selectBetType = [_betTypeArray objectAtIndex:index];
    
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    [_scrollView setContentSize:_scrollView.frame.size];
    
    switch (index) {
        case 0:
            _playMethodID = 3901;
            [self.shakeBtn setHidden:NO];
            break;
        case 1:
            _playMethodID = 3903;
            [self.shakeBtn setHidden:YES];
            break;
        case 2:
            _playMethodID = 3906;
            [self.shakeBtn setHidden:YES];
            break;
        case 3:
            _playMethodID = 3907;
            [self.shakeBtn setHidden:YES];
            break;
            
        default:
            break;
    }
    
    _isSupportShake = [DLTParserNumber isSupportShakeWithPalyType:_playMethodID];
    
    [self clearBalls];
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    [_scrollView setContentSize:_scrollView.frame.size];
        
    [self initBallViews];
}

- (void)tapBackView {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
}

#pragma mark - 判断选球条件

- (BOOL)checkForReduceAndIfOverMaxAmountsForDantuoWithView:(NSInteger)whichView {
    NSInteger counts = 0;
    if (whichView == 1) {
        NSMutableArray *one = [NSMutableArray arrayWithArray:_oneArray];
        [one removeLastObject];
        counts = [self getCounts:one two:_twoArray three:_threeArray four:_fourArray];
    }
    if (whichView == 2) {
        NSMutableArray *two = [NSMutableArray arrayWithArray:_twoArray];
        [two removeLastObject];
        counts = [self getCounts:_oneArray two:two three:_threeArray four:_fourArray];
    }
    if (whichView == 3) {
        NSMutableArray *three = [NSMutableArray arrayWithArray:_threeArray];
        [three removeLastObject];
        counts = [self getCounts:_oneArray two:_twoArray three:_threeArray four:_fourArray];
    }
    if (whichView == 4) {
        NSMutableArray *three = [NSMutableArray arrayWithArray:_fourArray];
        [three removeLastObject];
        counts = [self getCounts:_oneArray two:_twoArray three:_threeArray four:_fourArray];
    }
    
    if (counts * 2 > kDLTMaxAmounts) {
        [XYMPromptView defaultShowInfo:@"投注金额不能超过20000" isCenter:NO];
        return YES;
    }
    return NO;
}

- (BOOL)checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:(NSInteger)whichView {
    NSInteger counts = 0;
    if (whichView == 1) {
        NSMutableArray *one = [NSMutableArray arrayWithArray:_oneArray];
        [one addObject:[NSNumber numberWithInt:23]];
        counts = [self getCounts:one two:_twoArray three:_threeArray four:_fourArray];
    }
    if (whichView == 2) {
        NSMutableArray *two = [NSMutableArray arrayWithArray:_twoArray];
        [two addObject:[NSNumber numberWithInt:23]];
        counts = [self getCounts:_oneArray two:two three:_threeArray four:_fourArray];
    }
    if (whichView == 3) {
        NSMutableArray *three = [NSMutableArray arrayWithArray:_threeArray];
        [three removeLastObject];
        counts = [self getCounts:_oneArray two:_twoArray three:_threeArray four:_fourArray];
    }
    if (whichView == 4) {
        NSMutableArray *three = [NSMutableArray arrayWithArray:_fourArray];
        [three removeLastObject];
        counts = [self getCounts:_oneArray two:_twoArray three:_threeArray four:_fourArray];
    }
    
    if (counts * 2 > kDLTMaxAmounts) {
        [XYMPromptView defaultShowInfo:@"投注金额不能超过20000" isCenter:NO];
        return YES;
    }
    return NO;
}
// 检测view中是否有tag为ballTag的球，并且该球是选中状态
- (BOOL)checkHasSameBallAndIfOverMaxAmountsWithCurrentView:(UIView *)currentView otherView:(UIView *)otherView ballTag:(NSInteger)ballTag {
    BOOL isAboveAmounts = NO;
    // 1、预设otherView中的ballTag的球已经取消选中状态
    // 2、预设currentView中的ballTag的球为选中状态
    for (UIView *ballView in otherView.subviews) {
        Ball *ball = (Ball *)ballView;
        // 在otherView中找到tag值为ballTag的球
        if (ball.tag == ballTag) {
            
            if (ball.isSelected) {  // 该球刚好是处于选中状态
                // 在1和2下，金额是否超过2w
                if (_playMethodID == 3903) {
                    if ([currentView isEqual:_oneView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:2];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:1];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }
                    if ([currentView isEqual:_twoView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:1];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:2];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }
                }
                
                if (_playMethodID == 3906) {
                    if ([currentView isEqual:_twoView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:2];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:3];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }
                    if ([currentView isEqual:_threeView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:3];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:2];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }

                }
                
                if (_playMethodID == 3907) {
                    if ([currentView isEqual:_oneView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:2];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:1];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }
                    if ([currentView isEqual:_twoView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:1];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:2];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }

                    if ([currentView isEqual:_threeView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:3];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:4];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }
                    if ([currentView isEqual:_fourView]) {
                        BOOL checkOne = [self checkForReduceAndIfOverMaxAmountsForDantuoWithView:4];
                        BOOL checkTwo = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:3];
                        if (checkOne || checkTwo) {
                            isAboveAmounts = YES;
                        }
                    }
                    
                }
                                // 判断是否超额，如果是，则不进行任何操作，否则设置状态
                if (!isAboveAmounts) {
                    // 把currentView中的ballTag球设为选中状态，把otherView中的ballTag球设为未选中状态
                    Ball *currentViewSpecBall = (Ball *)[currentView viewWithTag:ballTag];
                    Ball *otherViewSpecBall = (Ball *)[otherView viewWithTag:ballTag];
                    [currentViewSpecBall setSelected:YES];
                    [otherViewSpecBall setSelected:NO];
                    
                    if (_playMethodID == 3903) {
                        if ([currentView isEqual:_oneView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                        }
                        if ([currentView isEqual:_twoView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
                        }
                    }
                    
                    if (_playMethodID == 3906) {
                        if ([currentView isEqual:_twoView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_threeView];
                        }
                        if ([currentView isEqual:_threeView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_threeView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                        }

                    }
                    
                    if (_playMethodID == 3907) {
                        if ([currentView isEqual:_oneView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                        }
                        if ([currentView isEqual:_twoView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
                        }

                        if ([currentView isEqual:_threeView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_threeView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_fourView];
                        }
                        if ([currentView isEqual:_fourView]) {
                            [self addBallInSpecifiedArrayWithTag:ballTag baseView:_fourView];
                            [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_threeView];
                        }
                        
                    }

                    [self showBetCount];
                }
            } else {                // 该球未处于选中状态，
                // 直接检测2
                if ([currentView isEqual:_oneView]) {
                    isAboveAmounts = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:1];
                    if (!isAboveAmounts) {
                        Ball *currentViewSpecBall = (Ball *)[currentView viewWithTag:ballTag];
                        [currentViewSpecBall setSelected:YES];
                        [self addBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
                    }
                }
                if ([currentView isEqual:_twoView]) {
                    isAboveAmounts = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:2];
                    if (!isAboveAmounts) {
                        Ball *currentViewSpecBall = (Ball *)[currentView viewWithTag:ballTag];
                        [currentViewSpecBall setSelected:YES];
                        [self addBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                    }
                }
                if ([currentView isEqual:_threeView]) {
                    isAboveAmounts = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:3];
                    if (! isAboveAmounts) {
                        Ball *currentViewSpecBall = (Ball *)[currentView viewWithTag:ballTag];
                        [currentViewSpecBall setSelected:YES];
                        [self addBallInSpecifiedArrayWithTag:ballTag baseView:_threeView];
                    }
                }
                if ([currentView isEqual:_fourView]) {
                    isAboveAmounts = [self checkForIncreaseAndIfOverMaxAmountsForDantuoWithView:4];
                    if (! isAboveAmounts) {
                        Ball *currentViewSpecBall = (Ball *)[currentView viewWithTag:ballTag];
                        [currentViewSpecBall setSelected:YES];
                        [self addBallInSpecifiedArrayWithTag:ballTag baseView:_fourView];
                    }
                }
                [self showBetCount];
            }
            
            break;
            
        }
    }
    return isAboveAmounts;
}

- (void)ballSelect:(id)sender {
    NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    if ([[def objectForKey:kIsShake]integerValue] == 1)
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    Ball *ball = sender;
    if(ball.isSelected) {
        if (_playMethodID == 3903) {
            if ([ball.superview isEqual:_oneView]) {
                if ([self checkForReduceAndIfOverMaxAmountsForDantuoWithView:1])
                    return;
            }
        }
        [ball setSelected:NO];
        [self removeBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
        [self showBetCount];
        
    } else {
        if (_playMethodID == 3903) {
            if ([ball.superview isEqual:_oneView]) {
                if (![self checkIsCorrect:1])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_oneView otherView:_twoView ballTag:ball.tag])
                    return;
            }
            if ([ball.superview isEqual:_twoView]) {
                if (![self checkIsCorrect:2])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_twoView otherView:_oneView ballTag:ball.tag])
                    return;
            }
            if ([ball.superview isEqual:_threeView]) {
                if (![self checkIsCorrect:3])
                    return;
                ball.selected = YES;
                [self addBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
            }
        }
        if (_playMethodID == 3906) {
            if ([ball.superview isEqual:_oneView]) {
                if (![self checkIsCorrect:1])
                    return;
                ball.selected = YES;
                [self addBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
            }
            if ([ball.superview isEqual:_twoView]) {
                if (![self checkIsCorrect:2])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_twoView otherView:_threeView ballTag:ball.tag])
                    return;
            }
            if ([ball.superview isEqual:_threeView]) {
                if (![self checkIsCorrect:3])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_threeView otherView:_twoView ballTag:ball.tag])
                    return;
            }
        }
        
        if (_playMethodID == 3907) {
            if ([ball.superview isEqual:_oneView]) {
                if (![self checkIsCorrect:1])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_oneView otherView:_twoView ballTag:ball.tag])
                    return;
            }
            if ([ball.superview isEqual:_twoView]) {
                if (![self checkIsCorrect:2])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_twoView otherView:_oneView ballTag:ball.tag])
                    return;
            }
            if ([ball.superview isEqual:_threeView]) {
                if (![self checkIsCorrect:3])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_threeView otherView:_fourView ballTag:ball.tag])
                    return;
            }
            if ([ball.superview isEqual:_fourView]) {
                if (![self checkIsCorrect:4])
                    return;
                if ([self checkHasSameBallAndIfOverMaxAmountsWithCurrentView:_fourView otherView:_threeView ballTag:ball.tag])
                    return;
            }
        }
        if (_playMethodID == 3901) {
            if ([ball.superview isEqual:_oneView]) {
                if (![self checkIsCorrect:1])
                    return;
            }
            if ([ball.superview isEqual:_twoView]) {
                if (![self checkIsCorrect:2])
                    return;
            }
            
            ball.selected = YES;
            [self addBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
        }
        
    }
    [self showBetCount];
}

- (NSInteger)getCounts:(NSArray *)one two:(NSArray *)two three:(NSArray *)three four:(NSArray *)four {
    if (_playMethodID == 3901) {
        if (one.count < kDLTRedBallNormalCounts
            || two.count < kDLTBlueBallNormalCounts)
            return 0;
        else
            return [CalculateBetCount combinationWithM:one.count N:kDLTRedBallNormalCounts] * [CalculateBetCount combinationWithM:two.count N:kDLTBlueBallNormalCounts];
    }
    if (_playMethodID == 3903) {
        if (one.count < 1 || two.count < 1)
            return 0;
        if (one.count + two.count < kDLTRedBallNormalCounts
            || three.count < kDLTBlueBallNormalCounts)
            return 0;
        return [CalculateBetCount combinationWithM:two.count N:kDLTRedBallNormalCounts - one.count] * [CalculateBetCount combinationWithM:three.count N:kDLTBlueBallNormalCounts];
    }
    if (_playMethodID == 3906) {
        if (two.count != 1 || one.count != 5)
            return 0;
        if (three.count < kDLTBlueBallNormalCounts)
            return 0;
        return [CalculateBetCount combinationWithM:one.count N:kDLTRedBallNormalCounts] * [CalculateBetCount combinationWithM:three.count N:kDLTBlueBallNormalCounts - two.count];
    }
    if (_playMethodID == 3907) {
        if (one.count < 1 || two.count < 1 || three.count != 1)
            return 0;
        if (one.count + two.count < kDLTRedBallNormalCounts
            || four.count < kDLTBlueBallNormalCounts)
            return 0;
        return [CalculateBetCount combinationWithM:two.count N:kDLTRedBallNormalCounts - one.count] * [CalculateBetCount combinationWithM:four.count N:kDLTBlueBallNormalCounts - three.count];
    }
    
    return 0;
}

- (BOOL)checkIsCorrect:(NSInteger)whichView {
    if (whichView == 1 && (_playMethodID == 3901 || _playMethodID == 3907)) {
        if (_oneArray.count >= kDLTRedBallCanAutoSelectedMaxCounts) {
            [XYMPromptView defaultShowInfo:[NSString stringWithFormat:@"前区号码数量不能超过%d个", kDLTRedBallCanAutoSelectedMaxCounts] isCenter:NO];
            return NO;
        }
    }
    if (whichView == 1 && (_playMethodID == 3903 || _playMethodID == 3907)) {
        if (_oneArray.count == 4) {
            [XYMPromptView defaultShowInfo:@"最多只能选4个前区胆码" isCenter:NO];
            return NO;
        }
    }
    if (whichView == 1 && _playMethodID == 3906) {
        if (_oneArray.count == 5) {
            [XYMPromptView defaultShowInfo:@"只能选择5个前区号码" isCenter:NO];
            return NO;
        }
    }
    if (whichView == 2 && _playMethodID == 3906) {
        if (_twoArray.count == 1) {
            [XYMPromptView defaultShowInfo:@"只能选择一个后区胆码" isCenter:NO];
            return NO;
        }
    }
    if (whichView == 3 && _playMethodID == 3907) {
        if (_threeArray.count == 1) {
            [XYMPromptView defaultShowInfo:@"只能选择一个后区胆码" isCenter:NO];
            return NO;
        }
    }
    
    NSMutableArray *one = [NSMutableArray arrayWithArray:_oneArray];
    NSMutableArray *two = [NSMutableArray arrayWithArray:_twoArray];
    NSMutableArray *three = [NSMutableArray arrayWithArray:_threeArray];
    NSMutableArray *four = [NSMutableArray arrayWithArray:_fourArray];
    if (whichView == 1)
        [one addObject:[NSNumber numberWithInt:23]];
    if (whichView == 2)
        [two addObject:[NSNumber numberWithInt:23]];
    if (whichView == 3)
        [three addObject:[NSNumber numberWithInt:23]];
    if (whichView == 4)
        [four addObject:[NSNumber numberWithInt:23]];
    NSInteger counts = [self getCounts:one two:two three:three four:four];
    if (counts * 2 > kDLTMaxAmounts) {
        [XYMPromptView defaultShowInfo:@"投注金额不能超过20000" isCenter:NO];
        return NO;
    }
    
    return YES;
}


#pragma mark - ff
- (void)prepareGotoNextPage {
    if (_playMethodID == 3903 && _twoArray.count < 2) {
        [XYMPromptView defaultShowInfo:@"前区拖码区至少选2个号码" isCenter:YES];
        return;
    }
    if (_playMethodID == 3907 && _twoArray.count < 2) {
        [XYMPromptView defaultShowInfo:@"前区拖码区至少选2个号码" isCenter:NO];
        return;
    }

    NSMutableDictionary *betsContentDic = [NSMutableDictionary dictionary];
    NSString *keyPerBets;   // 每选择一次时
    
    if (_betViewController == nil && _selectedBallsDic == nil) {  // 选完球后，按右下角的确认按钮，push到投注页面
        keyPerBets = [NSString stringWithFormat:@"%d",0];
        [betsContentDic setObject:[self combineBetContentDic] forKey:keyPerBets];
        _betViewController = [[DLTBetViewController alloc]initWithBallsInfoDic:betsContentDic LotteryDic:_lotteryDic isSupportShake:_isSupportShake];
        [self.navigationController pushViewController:_betViewController animated:YES];
        [_betViewController release];
        
    } else if (_selectedBallsDic != nil) {                       // 反选的时候走这里（修改已选号码的时候）
        [self.baseDelegate updateSelectBallsDic:[self combineBetContentDic] AtRowIndex:_specifiedIndex];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {                                                    // 从投注页面要添加一组手选号码时返回
        DLTBetViewController *viewController = (DLTBetViewController *)_betViewController;
        [betsContentDic setDictionary:viewController.betInfoDic];
        
        keyPerBets = [NSString stringWithFormat:@"%lu",(unsigned long)viewController.betInfoDic.count];
        [betsContentDic setObject:[self combineBetContentDic] forKey:keyPerBets];
        [viewController setBetInfoDic:betsContentDic];
        if (!IS_PHONE && !IS_IOS8) {
            [viewController reloadtableViews];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getSelectedBallNumbers {
    NSString *str = [DLTParserNumber getDLTBetNumberStringWithOneArray:[MyTool sortArrayFromSmallToLarge:_oneArray]
                                                                   two:[MyTool sortArrayFromSmallToLarge:_twoArray]
                                                                 three:[MyTool sortArrayFromSmallToLarge:_threeArray]
                                                                  four:[MyTool sortArrayFromSmallToLarge:_fourArray]
                                                             andPlayID:_playMethodID
                                                     andPlayMethodName:_selectBetType];

    return str;
}

@end
