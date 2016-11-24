//
//  SSQViewController.m 购彩大厅－双色球选号
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140915 09:11（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140915 09:48（洪晓彬）：进行ipad适配

#import "SSQViewController.h"
#import "Ball.h"
#import "SSQBetViewController.h"
#import "SSQPlayMethodView.h"
#import "SelectBallBottomView.h"

#import "CalculateBetCount.h"
#import "Globals.h"
#import "MyTool.h"
#import "RandomNumber.h"
#import "SSQParserNumber.h"


#define kSSQBallsViewHeaderCommonHeight        (IS_PHONE ? 40.0f : 60.0f)
#define kSSQBallsViewHeaderDantuoHeight        (IS_PHONE ? 40.0f : 60.0f)

#define kSSQBallsCountsPerRow                   (IS_PHONE ? 7 : 8)      // 每行显示球的数量
#define kSSQRedMinBall                          1       // 红球最小的索引
#define kSSQRedMaxBall                          33      // 红球最大的索引
#define kSSQBlueMinBall                         1       // 蓝球最小的索引
#define kSSQBlueMaxBall                         16      // 蓝球最大的索引
#define kSSQRedBallCanAutoSelectedMaxCounts     16      // 红球机选最多可选择的个数
#define kSSQRedBallCanAutoSelectedMinCounts     6       // 红球机选最少可选择的个数
#define kSSQBlueBallCanAutoSelectedMaxCounts    16      // 蓝球机选最多可选择的个数
#define kSSQBlueBallCanAutoSelectedMinCounts    1       // 蓝球机选最少可选择的个数
#define kSSQRedBallNormalCounts                 6       // 标准红球个数(开奖时)，也就是最少选择的个数
#define kSSQBlueBallNormalCounts                1       // 标准蓝球个数(开奖时)，也就是最少选择的个数
#define kSSQMaxAmounts                          20000   // 单方案不能超过的最大金额

@interface SSQViewController ()

@end
#pragma mark -
#pragma mark @implementation SSQViewController
@implementation SSQViewController
#pragma mark Lifecircle

- (id)init {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
#if LOG_SWITCH_VIEWFUNCTION
    NSLog(@"%s",__FUNCTION__);
#endif
    
    _redballAutoView = nil;
    _blueballAutoView = nil;
    
    _playMethodView = nil;
    
    [super dealloc];
}

- (void)loadView {
    [self setTitle:@"双色球"];
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
        _redballAutoView = nil;
        _blueballAutoView = nil;
        
        _playMethodView = nil;
        self.view = nil;
    }
}

#pragma mark -
#pragma mark Delegate
#pragma mark -AutoSelectViewDelegate
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
                    if([view isKindOfClass:[Ball class]]) {
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

#pragma mark -DropDownListViewDelegate
- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    if (index > 1) {
        NSString *str = [NSString stringWithFormat:@"%@",[_betTypeArray objectAtIndex:index]];
        [midButton setTitle:str forState:UIControlStateNormal];
        [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    } else {
        [midButton setTitle:[_betTypeArray objectAtIndex:index] forState:UIControlStateNormal];
        [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    }
    
    _selectBetType = [_betTypeArray objectAtIndex:index];
    
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    [_scrollView setContentSize:_scrollView.frame.size];
    
    _playMethodID = (index == 0 ? 501 : 502);
    _isSupportShake = [SSQParserNumber isSupportShakeWithPalyType:_playMethodID];
    
    [self clearBalls];
    
    [self initBallViews];
}

- (void)tapBackView {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
}

- (void)submitBalls {
    if (_playMethodID == 502 && _totalBetCount < 2) {
        [XYMPromptView defaultShowInfo:@"请至少选择2注" isCenter:YES];
        return;
    }
    if (_totalBetCount < 1) {
        [XYMPromptView defaultShowInfo:@"请至少选择1注" isCenter:YES];
        return;
    }
    
    [self prepareGotoNextPage];
}

#pragma mark -
#pragma mark -Customized(Action)
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

#pragma mark -Customized: Private (General)
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

- (void)initBallViews {
    switch (_playMethodID) {
        case 501: {
            [self.shakeBtn setHidden:NO];
            [self loadRedViewWithMinBallNum:kSSQRedMinBall
                                 maxBallNum:kSSQRedMaxBall
                           ballCountsPerRow:kSSQBallsCountsPerRow
                            totalBallCounts:kSSQRedMaxBall];
            [self loadBlueViewWithMinBallNum:kSSQBlueMinBall
                                  maxBallNum:kSSQBlueMaxBall
                            ballCountsPerRow:kSSQBallsCountsPerRow
                             totalBallCounts:kSSQBlueMaxBall];
        }
            break;
        case 502: {
            [self.shakeBtn setHidden:YES];
            [self loadDanViewForDantuoWithMinBallNum:kSSQRedMinBall
                                          maxBallNum:kSSQRedMaxBall
                                    ballCountsPerRow:kSSQBallsCountsPerRow
                                     totalBallCounts:kSSQRedMaxBall];
            [self loadTuoViewForDantuoWithMinBallNum:kSSQRedMinBall
                                          maxBallNum:kSSQRedMaxBall
                                    ballCountsPerRow:kSSQBallsCountsPerRow
                                     totalBallCounts:kSSQRedMaxBall];
            [self loadBlueViewForDantuoWithMinBallNum:kSSQBlueMinBall
                                           maxBallNum:kSSQBlueMaxBall
                                     ballCountsPerRow:kSSQBallsCountsPerRow
                                      totalBallCounts:kSSQBlueMaxBall];
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
    if (_playMethodID == 501) {
        [self getRandomBallAndFillViewWithExpectedCounts:kSSQRedBallNormalCounts
                                              maxBallNum:kSSQRedMaxBall
                                              minBallNum:kSSQRedMinBall
                                            inWitchArray:1];
        [self getRandomBallAndFillViewWithExpectedCounts:kSSQBlueBallNormalCounts
                                              maxBallNum:kSSQBlueMaxBall
                                              minBallNum:kSSQBlueMinBall
                                            inWitchArray:2];
        
    }
    [self setBallStatus];
    [self showBetCount];
}

#pragma mark - For 普通投注
- (void)loadRedBallHeaderView {
    //redballAutoView
    CGRect redballAutoViewRect = CGRectMake(0, 0, _scrollView.frame.size.width, kSSQBallsViewHeaderCommonHeight);
    _redballAutoView = [[UIView alloc]initWithFrame:redballAutoViewRect];
    [_redballAutoView setTag:210];// 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:_redballAutoView];
    [_redballAutoView release];
    
    //betTypeLabel
    CGRect betTypeLabelRect = CGRectMake(kPromptMsgLabelX, promptLabelMinY, lastPromptLabelWidth, kPromptMsgLabelHeight);
    CustomLabel *betTypeLabel = [[CustomLabel alloc]initWithFrame:betTypeLabelRect];
    [betTypeLabel setBackgroundColor:[UIColor clearColor]];
    [betTypeLabel setTextColor:[UIColor blackColor]];
    [betTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_redballAutoView addSubview:betTypeLabel];
    [betTypeLabel release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">请至少选择</font><font color=\"%@\">6</font><font color=\"black\">个红球</font>",tRedColorText];
    [betTypeLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    
    [self makeShakeBtn];
}

- (void)loadBlueBallHeaderView:(float)coordY {
    //blueballAutoView
    CGRect blueballAutoViewRect = CGRectMake(0, coordY, _scrollView.frame.size.width, kSSQBallsViewHeaderCommonHeight);
    _blueballAutoView = [[UIView alloc]initWithFrame:blueballAutoViewRect];
    [_blueballAutoView setTag:220];// 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:_blueballAutoView];
    [_blueballAutoView release];
    
    //betTypeLabel
    CGRect betTypeLabelRect = CGRectMake(kPromptMsgLabelX, promptLabelMinY , lastPromptLabelWidth, kPromptMsgLabelHeight);
    CustomLabel *betTypeLabel = [[CustomLabel alloc]initWithFrame:betTypeLabelRect];
    [betTypeLabel setBackgroundColor:[UIColor clearColor]];
    [betTypeLabel setTextColor:[UIColor blackColor]];
    [betTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_blueballAutoView addSubview:betTypeLabel];
    [betTypeLabel release];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">请至少选择</font><font color=\"%@\">1</font><font color=\"black\">个蓝球</font>",tBlueColorText];
    [betTypeLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
}

- (void)loadRedViewWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    [self loadRedBallHeaderView];
    UIView *view = [_scrollView viewWithTag:210];
    float y = view.frame.origin.y + kSSQBallsViewHeaderCommonHeight;
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame whichView:1 minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow ballColor:Red];
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
    CGRect viewFrame = CGRectMake(0, view.frame.origin.y + kSSQBallsViewHeaderCommonHeight + 3, kWinSize.width, viewHeight);
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
    //danHeaderView
    CGRect danHeaderViewRect = CGRectMake(0, 0, _scrollView.frame.size.width, kSSQBallsViewHeaderDantuoHeight);
    UIView *danHeaderView = [[UIView alloc]initWithFrame:danHeaderViewRect];
    [danHeaderView setTag:230];// 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:danHeaderView];
    [danHeaderView release];
    
    //leftLabel
    CGRect leftLabelRect = CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthA, kPromptMsgLabelHeight);
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:leftLabelRect];
    [leftLabel setBackgroundColor:[UIColor clearColor]];
    [leftLabel setTextColor:[UIColor blackColor]];
    [leftLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
    [leftLabel setText:@"胆码区-红球"];
    [danHeaderView addSubview:leftLabel];
    [leftLabel release];
    
    //rightLabel
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"%@\">1</font><font color=\"black\">个红球，最多</font><font color=\"%@\">5</font><font color=\"black\">个红球</font>",tRedColorText,tRedColorText];
    CGRect rightLabelRect = CGRectMake(CGRectGetMaxX(leftLabelRect), promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight);
    CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:rightLabelRect];
    [rightLabel setBackgroundColor:[UIColor clearColor]];
    [rightLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [danHeaderView addSubview:rightLabel];
    [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [rightLabel release];
}

- (void)loadTuoAreaHeaderView:(float)coordY {
    //tuoHeaderView
    CGRect tuoHeaderViewRect = CGRectMake(0, coordY, _scrollView.frame.size.width, kSSQBallsViewHeaderDantuoHeight);
    UIView *tuoHeaderView = [[UIView alloc]initWithFrame:tuoHeaderViewRect];
    [tuoHeaderView setTag:240];// 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:tuoHeaderView];
    [tuoHeaderView release];
    
    //leftLabel
    CGRect leftLabelRect = CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthA, kPromptMsgLabelHeight);
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:leftLabelRect];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
    leftLabel.text = @"拖码区-红球";
    [tuoHeaderView addSubview:leftLabel];
    [leftLabel release];
    
    //rightLabel
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"%@\">2</font><font color=\"black\">个红球</font>",tRedColorText];
    CGRect rightLabelRect = CGRectMake(CGRectGetMaxX(leftLabelRect), promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0f, lastPromptLabelWidth, kPromptMsgLabelHeight);
    CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:rightLabelRect];
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
    [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [tuoHeaderView addSubview:rightLabel];
    [rightLabel release];
}

- (void)loadBlueAreaHeaderView:(float)coordY {
    UIView *blueHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, coordY, _scrollView.frame.size.width, kSSQBallsViewHeaderDantuoHeight)];
    [blueHeaderView setTag:250];// 设置tag以便之后能找到该view以计算位置
    [_scrollView addSubview:blueHeaderView];
    [blueHeaderView release];
    
    //leftLabel
    CGRect leftLabelRect = CGRectMake(kPromptMsgLabelX, promptLabelMinY, firstPromptLabelWidthB, kPromptMsgLabelHeight);
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:leftLabelRect];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize15];
    leftLabel.text = @"蓝球";
    [blueHeaderView addSubview:leftLabel];
    [leftLabel release];
    
    //rightLabel
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">至少选出</font><font color=\"0074f0\">1</font><font color=\"black\">个蓝球</font>"];
    CGRect rightLabelRect = CGRectMake(CGRectGetMaxX(leftLabelRect), promptLabelMinY + (XFIponeIpadFontSize15 - XFIponeIpadFontSize13) / 2.0, lastPromptLabelWidth, kPromptMsgLabelHeight);
    CustomLabel *rightLabel = [[CustomLabel alloc]initWithFrame:rightLabelRect];
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
    [rightLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [blueHeaderView addSubview:rightLabel];
    [rightLabel release];
}

- (void)loadDanViewForDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    [self loadDanAreaHeaderView];
    UIView *view = [_scrollView viewWithTag:230];
    float y = view.frame.origin.y + kSSQBallsViewHeaderDantuoHeight;
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame whichView:1 minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow ballColor:Red];
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _oneView.frame.origin.y + _oneView.frame.size.height)];
}

- (void)loadTuoViewForDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    float y1 = [self getFirstCoordYAfterView:_oneView];
    [self addLineBewteenBallViewWithCoordY:y1];
    [self loadTuoAreaHeaderView:y1 + 2];
    UIView *view = [_scrollView viewWithTag:240];
    float y = view.frame.origin.y + kSSQBallsViewHeaderDantuoHeight;
    CGFloat viewHeight =  [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame whichView:2 minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow ballColor:Red];
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _twoView.frame.origin.y + _twoView.frame.size.height)];
}

- (void)loadBlueViewForDantuoWithMinBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts {
    float y1 = [self getFirstCoordYAfterView:_twoView];
    [self addLineBewteenBallViewWithCoordY:y1];
    [self loadBlueAreaHeaderView:y1 + 2];
    UIView *view = [_scrollView viewWithTag:250];
    float y = view.frame.origin.y + kSSQBallsViewHeaderDantuoHeight;
    CGFloat viewHeight = [self calculateBallViewHeightWithViewWidth:kWinSize.width andBallCountPerView:counts andBallCountPerRow:countsPerRow];
    CGRect viewFrame = CGRectMake(0, y + 3, kWinSize.width, viewHeight);
    [self loadBallViewWithFrame:viewFrame whichView:3 minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow ballColor:Blue];
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _threeView.frame.origin.y + _threeView.frame.size.height)];
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
        default:
            break;
    }
}

- (void)showBetCount {
    _totalBetCount = [SSQParserNumber getCountForSSQWithOneArray:_oneArray
                                                             two:_twoArray
                                                           three:_threeArray
                                                            four:_fourArray
                                                     basedRedNum:kSSQRedBallNormalCounts
                                                    basedBlueNum:kSSQBlueBallNormalCounts
                                                       andPlayID:_playMethodID
                                               andPlayMethodName:_selectBetType];
    [_bottomView setTextWithCount:_totalBetCount money:_totalBetCount * 2];
}

#pragma mark - 判断选球条件
- (BOOL)checkForReduceAndIfOverMaxAmountsForDantuoWithView:(NSInteger)whichView {
    NSInteger counts = 0;
    if (whichView == 1) {
        NSMutableArray *one = [NSMutableArray arrayWithArray:_oneArray];
        [one removeLastObject];
        counts = [self getCounts:one two:_twoArray three:_threeArray];
    }
    if (whichView == 2) {
        NSMutableArray *two = [NSMutableArray arrayWithArray:_twoArray];
        [two removeLastObject];
        counts = [self getCounts:_oneArray two:two three:_threeArray];
    }
    
    if (counts * 2 > kSSQMaxAmounts) {
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
        counts = [self getCounts:one two:_twoArray three:_threeArray];
    }
    if (whichView == 2) {
        NSMutableArray *two = [NSMutableArray arrayWithArray:_twoArray];
        [two addObject:[NSNumber numberWithInt:23]];
        counts = [self getCounts:_oneArray two:two three:_threeArray];
    }
    
    if (counts * 2 > kSSQMaxAmounts) {
        [XYMPromptView defaultShowInfo:@"投注金额不能超过20000" isCenter:NO];
        return YES;
    }
    if ([_oneArray count] + [_twoArray count] >= 20) {
        [XYMPromptView defaultShowInfo:@"总的红球不能超过20个" isCenter:NO];
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
                // 判断是否超额，如果是，则不进行任何操作，否则设置状态
                if (!isAboveAmounts) {
                    // 把currentView中的ballTag球设为选中状态，把otherView中的ballTag球设为未选中状态
                    Ball *currentViewSpecBall = (Ball *)[currentView viewWithTag:ballTag];
                    Ball *otherViewSpecBall = (Ball *)[otherView viewWithTag:ballTag];
                    [currentViewSpecBall setSelected:YES];
                    [otherViewSpecBall setSelected:NO];
                    if ([currentView isEqual:_oneView]) {
                        [self addBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
                        [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                    }
                    if ([currentView isEqual:_twoView]) {
                        [self addBallInSpecifiedArrayWithTag:ballTag baseView:_twoView];
                        [self removeBallInSpecifiedArrayWithTag:ballTag baseView:_oneView];
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
        if (_playMethodID == 502) {
            if ([ball.superview isEqual:_oneView]) {
                if ([self checkForReduceAndIfOverMaxAmountsForDantuoWithView:1])
                    return;
            }
        }
        [ball setSelected:NO];
        [self removeBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
        [self showBetCount];
        
    } else {
        if (_playMethodID == 502) {
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
        if (_playMethodID == 501) {
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

- (NSInteger)getCounts:(NSArray *)one two:(NSArray *)two three:(NSArray *)three {
    if (_playMethodID == 501) {
        if (one.count < kSSQRedBallNormalCounts || two.count < kSSQBlueBallNormalCounts)
            return 0;
        else
            return [self SSQ_ArrangeWithM:one.count N:kSSQRedBallNormalCounts] * [self SSQ_ArrangeWithM:two.count N:kSSQBlueBallNormalCounts];
    }
    if (_playMethodID == 502) {
        if (one.count < 1 || two.count < 1)
            return 0;
        if (one.count + two.count < kSSQRedBallNormalCounts || three.count < kSSQBlueBallNormalCounts)
            return 0;
        return [self SSQ_ArrangeWithM:two.count N:kSSQRedBallNormalCounts - one.count] * [self SSQ_ArrangeWithM:three.count N:kSSQBlueBallNormalCounts];
    }
    return 0;
}

- (BOOL)checkIsCorrect:(NSInteger)whichView {
    if (whichView == 1 && _playMethodID == 501) {
        if (_oneArray.count >= kSSQRedBallCanAutoSelectedMaxCounts) {
            [XYMPromptView defaultShowInfo:[NSString stringWithFormat:@"红球数量不能超过%d个", kSSQRedBallCanAutoSelectedMaxCounts] isCenter:NO];
            return NO;
        }
    }
    if (whichView == 1 && _playMethodID == 502) {
        if (_oneArray.count == 5) {
            [XYMPromptView defaultShowInfo:@"最多只能选5个" isCenter:NO];
            return NO;
        }
    }
    NSMutableArray *one = [NSMutableArray arrayWithArray:_oneArray];
    NSMutableArray *two = [NSMutableArray arrayWithArray:_twoArray];
    NSMutableArray *three = [NSMutableArray arrayWithArray:_threeArray];
    if (whichView == 1)
        [one addObject:[NSNumber numberWithInt:23]];
    if (whichView == 2)
        [two addObject:[NSNumber numberWithInt:23]];
    if (whichView == 3)
        [three addObject:[NSNumber numberWithInt:23]];
    NSInteger counts = [self getCounts:one two:two three:three];
    if (counts * 2 > kSSQMaxAmounts) {
        [XYMPromptView defaultShowInfo:@"投注金额不能超过20000" isCenter:NO];
        return NO;
    }
    return YES;
}

//排列组合C m取n
- (NSInteger)SSQ_ArrangeWithM:(NSInteger)m N:(NSInteger)n {
    NSInteger Count = 1;
    if (m / 2 < n) {
        n = m - n;
    }
    for (NSInteger i = 0; i < n; i ++) {
        Count *= (m - i);
        Count /= (i + 1);
    }
    return Count;
}

#pragma mark
- (void)prepareGotoNextPage {
    if (_playMethodID == 502) {
        if (_totalBetCount == 1) {
            [XYMPromptView defaultShowInfo:@"请至少选择2注" isCenter:YES];
            return;
        }
        if (_twoArray.count < 2) {
            [XYMPromptView defaultShowInfo:@"拖码区至少选2个红球" isCenter:NO];
            return;
        }
    }
    NSMutableDictionary *betsContentDic = [NSMutableDictionary dictionary];
    NSString *keyPerBets;   // 每选择一次时
    
    if (_betViewController == nil && _selectedBallsDic == nil) {  // 选完球后，按右下角的确认按钮，push到投注页面
        keyPerBets = [NSString stringWithFormat:@"%d",0];
        [betsContentDic setObject:[self combineBetContentDic] forKey:keyPerBets];
        _betViewController = [[SSQBetViewController alloc]initWithBallsInfoDic:betsContentDic LotteryDic:_lotteryDic isSupportShake:_isSupportShake];
        [self.navigationController pushViewController:_betViewController animated:YES];
        [_betViewController release];
        
    } else if (_selectedBallsDic != nil) {                       // 反选的时候走这里（修改已选号码的时候）
        [self.baseDelegate updateSelectBallsDic:[self combineBetContentDic] AtRowIndex:_specifiedIndex];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {                                                    // 从投注页面要添加一组手选号码时返回
        SSQBetViewController *viewController = (SSQBetViewController *)_betViewController;
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
    NSString *str = [SSQParserNumber getSSQBetNumberStringWithOneArray:[MyTool sortArrayFromSmallToLarge:_oneArray]
                                                                   two:[MyTool sortArrayFromSmallToLarge:_twoArray]
                                                                 three:[MyTool sortArrayFromSmallToLarge:_threeArray]
                                                                  four:[MyTool sortArrayFromSmallToLarge:_fourArray]
                                                             andPlayID:_playMethodID
                                                     andPlayMethodName:_selectBetType];
    return str;
}

@end
