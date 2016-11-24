//
//  SDViewController.m 购彩大厅－3D选球
//  TicketProject
//
//  Created by Michael on 13-5-30.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140916 15:41（洪晓彬）：修改代码规范，处理内存
//20140916 15:54（洪晓彬）：进行ipad适配

#import "SDViewController.h"
#import "Ball.h"
#import "CustomButton.h"
#import "SDBetViewController.h"
#import "SelectBallBottomView.h"
#import "SSQPlayMethodView.h"
#import "XFTabBarViewController.h"

#import "CalculateBetCount.h"
#import "RandomNumber.h"
#import "Globals.h"
#import "MyTool.h"
#import "SDParserNumber.h"

#define kSDPromptLabelWidth 43.5
#define kSSLPromptMsgLabelX 10
#define kSSLPromptMsgLabelHeight  43.5
#define kSSLPromptMsgLabelAddY 20.0f

@interface SDViewController ()

@end

@implementation SDViewController

- (void)dealloc {
    _playMethodView = nil;
    _betTypeLabel = nil;
    [super dealloc];
}

- (void)loadView {
    [self setTitle:@"3D"];
    [super loadView];
    CGFloat betTypeLabelMinY = 13.0f;
    CGFloat betTypeLabelHeight = (IS_PHONE ? 40.0f : (XFIponeIpadFontSize13 * 2 + 7)) - betTypeLabelMinY;
    
    //betTypeLabel
    CGRect betTypeLabelRect = CGRectMake(kPromptMsgLabelX, CGRectGetMaxY(_header.frame) + betTypeLabelMinY, kWinSize.width - kPromptMsgLabelX * 2, betTypeLabelHeight);
    _betTypeLabel = [[CustomLabel alloc]initWithFrame:betTypeLabelRect];
    _betTypeLabel.backgroundColor = [UIColor clearColor];
    _betTypeLabel.textColor = [UIColor blackColor];
    _betTypeLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
    [_betTypeLabel setNumberOfLines:0];      //注意这里UILabel的numberoflines(即最大行数限制)设置成0，即不做行数限制。
    [_betTypeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:_betTypeLabel];
    [_betTypeLabel release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat shakeBtnIntervalRight = IS_PHONE ? 10.0f : 20.0f;
    CGFloat shakeBtnAddY = IS_PHONE ? 6.0f : 10.0f;
    CGFloat shakeBtnWidth = IS_PHONE ? 58.0f : 87.0f;
    CGFloat shakeBtnHeight = IS_PHONE ? 22.5f : 33.6f;
    /********************** adjustment end ***************************/
    CGRect secondShakeBtnRect = CGRectMake(kWinSize.width - shakeBtnIntervalRight - shakeBtnWidth,CGRectGetMinY(betTypeLabelRect) + shakeBtnAddY - betTypeLabelMinY, shakeBtnWidth, shakeBtnHeight);
    _secondShakeBtn = [UIButton buttonWithType:UIButtonTypeCustom]; //按钮的类型
    [_secondShakeBtn setFrame:secondShakeBtnRect];
    [_secondShakeBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ramdom.png"]] forState:UIControlStateNormal];
    [_secondShakeBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ramdom.png"]] forState:UIControlStateSelected];
    _secondShakeBtn.tag = 1;
    [_secondShakeBtn addTarget:self action:@selector(changeShakeButton:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_secondShakeBtn];
    
    [_scrollView setFrame:CGRectMake(_scrollView.frame.origin.x, CGRectGetMaxY(betTypeLabelRect), _scrollView.frame.size.width, _scrollView.frame.size.height - CGRectGetHeight(betTypeLabelRect) - betTypeLabelMinY)];
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
        if (_playMethodID == 614 || _playMethodID == 615) {
            [self setStatus];
        } else {
            [self setBallStatus];
        }

        [self showBetCount];
    }
    [self createNavMiddleView];
    [self createLabel];
    [self createPlayMethodView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _playMethodView = nil;
        _betTypeLabel = nil;
        
        self.view = nil;
    }
}

- (void)createLabel {
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">每位至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];
    if (_playMethodID == 601 || _playMethodID == 609 || _playMethodID == 612) {
        text = [NSString stringWithFormat:@"<font color=\"black\">每位至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];
        
    } else if (_playMethodID == 602 || _playMethodID == 608) {
        text = [NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">2</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if (_playMethodID == 603) {
        text = [NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">3</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if (_playMethodID == 606) {
        text = [NSString stringWithFormat:@"<font color=\"black\">至少在</font><font color=\"%@\">2</font><font color=\"black\">个位置上选号</font>",tRedColorText];

    } else if (_playMethodID == 610) {
        text = [NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">1</font><font color=\"black\">个和值</font>",tRedColorText];

    } else if (_playMethodID == 613) {
        text = [NSString stringWithFormat:@"<font color=\"black\">请选择大小</font>"];

    } else if (_playMethodID == 614) {
        text = [NSString stringWithFormat:@"<font color=\"black\">开奖结果为三同号即中奖</font>"];

    } else if (_playMethodID == 615) {
        text = [NSString stringWithFormat:@"<font color=\"black\">当期开奖号码的三个号码为以升序或降序连续排列的号码（890、098、901、109除外），即中奖。"];

    } else if (_playMethodID == 616) {
        text = [NSString stringWithFormat:@"<font color=\"black\">请选择奇偶</font>"];

    } else if (_playMethodID == 605 || _playMethodID == 607) {
        text = [NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if (_playMethodID == 604) {
        text = [NSString stringWithFormat:@"<font color=\"black\">至少在</font><font color=\"%@\">1</font><font color=\"black\">个位置上选号</font>",tRedColorText];

    } else if (_playMethodID == 611) {
        text = [NSString stringWithFormat:@"<font color=\"black\">只能选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    }
    [_betTypeLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [_betTypeLabel setNeedsDisplay];
}

#pragma mark - Override

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
    switch (_playMethodID) {
        case 601:   // 直选
        case 609: {  //通选
            [self getRandomBallAndFillViewWithExpectedCounts:1 maxBallNum:9 minBallNum:0 inWitchArray:1];
            [self getRandomBallAndFillViewWithExpectedCounts:1 maxBallNum:9 minBallNum:0 inWitchArray:2];
            [self getRandomBallAndFillViewWithExpectedCounts:1 maxBallNum:9 minBallNum:0 inWitchArray:3];
        }
            break;
        default:
            break;
    }
    
    [self setBallStatus];
    [self showBetCount];
}

- (void)initBallViews {
    if (_playMethodID == 601 || _playMethodID == 609) {
        [_secondShakeBtn setHidden:NO];
    } else {
        [_secondShakeBtn setHidden:YES];
    }
    switch (_playMethodID) {
        case 601:       // 直选
        case 604:       // 1D
        case 606:       // 2D
        case 609:       // 通选
        case 611:       // 包选3
        {
            [self loadOneView:YES minBallNum:0 maxBallNum:9 ballCountsPerRow:5 totalBallCounts:10 msg:@"百位"];
            [self loadTwoView:YES minBallNum:0 maxBallNum:9 ballCountsPerRow:5 totalBallCounts:10 msg:@"十位"];
            [self loadThreeView:YES minBallNum:0 maxBallNum:9 ballCountsPerRow:5 totalBallCounts:10 msg:@"个位"];
        }
            break;
        case 612: {     // 包选6
            [self loadOneView:YES minBallNum:0 maxBallNum:9 ballCountsPerRow:5 totalBallCounts:10 msg:@"百位"];
            [self loadTwoView:YES minBallNum:0 maxBallNum:9 ballCountsPerRow:5 totalBallCounts:10 msg:@"十位"];
            [self loadThreeView:YES minBallNum:0 maxBallNum:9 ballCountsPerRow:5 totalBallCounts:10 msg:@"个位"];
        }
            break;
        case 603: {      // 组六复式
            [self loadOneView:NO minBallNum:0 maxBallNum:9 ballCountsPerRow:7 totalBallCounts:10 msg:@""];
        }
            break;
        case 602:       // 组三复式
        case 605:       // 猜1D
        case 607:       // 猜2D-二同号
        case 608: {     // 猜2D-不二同号
            [self loadOneView:NO minBallNum:0 maxBallNum:9 ballCountsPerRow:7 totalBallCounts:10 msg:@""];
        }
            break;
        case 610: {      // 和数
            [self loadOneView:NO minBallNum:0 maxBallNum:27 ballCountsPerRow:7 totalBallCounts:28 msg:@""];
        }
            break;
        case 613:        // 猜大小
        case 616: {      // 猜奇偶
            [self loadOneView:YES minBallNum:0 maxBallNum:5 ballCountsPerRow:1 totalBallCounts:2 msg:@"选择"];//应付高度，因为用的不是圆球
        }
            break;
        case 614:        // 猜三同
        case 615: {      // 拖拉机
            [self initSixViews];
        }
            break;
        default:
            break;
    }
}

//三同\拖拉机选球页面
- (void)initSixViews {
    _oneView = [[UIView alloc]initWithFrame:_scrollView.bounds];
    [_oneView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:_oneView];
    
    [self addPromptMsgInBallView:CGRectMake(10, 20, kSDPromptLabelWidth, kSSLPromptMsgLabelHeight) message:@"选择" withViewIndex:0];
    
    CGFloat selectBtnWidth = IS_PHONE ? 213.0f : 150.0f;
    CGFloat selectBtnHeight = IS_PHONE ? 43.0f : 66.0f;
    
    CustomButton *numberButton = [[CustomButton alloc] initWithFrame:CGRectMake(70.0f, 20, selectBtnWidth , selectBtnHeight)];
    if (_playMethodID == 614) {
        [numberButton setTitle:@"三同号" forState:UIControlStateNormal];
    } else {
        [numberButton setTitle:@"拖拉机" forState:UIControlStateNormal];
    }
    [[numberButton titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [numberButton setTag:1];
    [numberButton addTarget:self action:@selector(ballSelect2:) forControlEvents:UIControlEventTouchUpInside];
    [_oneView addSubview:numberButton];
    [numberButton release];
}

- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setTitle:[_betTypeArray objectAtIndex:index] forState:UIControlStateNormal];
    [midButton setBackgroundImage:[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
    
    _selectBetType = [_betTypeArray objectAtIndex:index];
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    [_scrollView setContentSize:_scrollView.frame.size];
    [self clearBalls];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">每位至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];
    if ([_selectBetType isEqualToString:@"直选"]) {
        _playMethodID = 601;
        text =[NSString stringWithFormat:@"<font color=\"black\">每位至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"组三"]) {
        _playMethodID = 602;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">2</font><font color=\"black\">个号码</font>",tRedColorText];
 
    } else if ([_selectBetType isEqualToString:@"组六"]) {
        _playMethodID = 603;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">3</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"1D"]) {
        _playMethodID = 604;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少在</font><font color=\"%@\">1</font><font color=\"black\">个位置上选号</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"猜1D"]) {
        _playMethodID = 605;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"2D"]) {
        _playMethodID = 606;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少在</font><font color=\"%@\">2</font><font color=\"black\">个位置上选号</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"猜2D-二同号"]) {
        _playMethodID = 607;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"猜2D-二不同号"]) {
        _playMethodID = 608;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">2</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"通选"]) {
        _playMethodID = 609;
        text =[NSString stringWithFormat:@"<font color=\"black\">每位至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"和数"]) {
        _playMethodID = 610;
        text =[NSString stringWithFormat:@"<font color=\"black\">至少选择</font><font color=\"%@\">1</font><font color=\"black\">个和值</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"包选3"]) {
        _playMethodID = 611;
        text =[NSString stringWithFormat:@"<font color=\"black\">投注任意</font><font color=\"%@\">2</font><font color=\"black\">位相同号码与开奖号码一致（顺序不限)</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"包选6"]) {
        _playMethodID = 612;
        text =[NSString stringWithFormat:@"<font color=\"black\">每位至少选择</font><font color=\"%@\">1</font><font color=\"black\">个号码</font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"猜大小"]) {
        _playMethodID = 613;
        text =[NSString stringWithFormat:@"<font color=\"black\">和值0含－8含为小，19含－27含为大</font><font color=\"%@\"></font><font color=\"black\"></font>",tRedColorText];

    } else if ([_selectBetType isEqualToString:@"猜三同"]) {
        _playMethodID = 614;
        text =[NSString stringWithFormat:@"<font color=\"black\">开奖号码为三个相同的号码，即豹子号就中奖</font>"];

    } else if ([_selectBetType isEqualToString:@"拖拉机"]) {
        _playMethodID = 615;
        text =[NSString stringWithFormat:@"<font color=\"black\">当期开奖号码的三个号码为以升序或降序连续排列的号码（890、098、901、109除外），即中奖。</font>"];
        
    } else if ([_selectBetType isEqualToString:@"猜奇偶"]) {
        _playMethodID = 616;
        text =[NSString stringWithFormat:@"<font color=\"black\">请选择奇偶</font>"];
        
    }
    _isSupportShake = [SDParserNumber isSupportShakeWithPalyType:_playMethodID];
    [self.shakeBtn setHidden:!_isSupportShake];
    
    [_betTypeLabel setAttString:[Globals getAttriButedWithText:text fontSize:XFIponeIpadFontSize13]];
    [_betTypeLabel setNeedsDisplay];
    [self initBallViews];
}

- (void)tapBackView {
    UIButton *midButton = (UIButton *)[self.navigationItem.titleView viewWithTag:1000];
    [midButton setBackgroundImage:[[[UIImage imageNamed:@"bettype.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f] forState:UIControlStateNormal];
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

- (void)addPromptMsgInBallView:(CGRect)frame message:(NSString *)msg withViewIndex:(NSInteger)viewIndex {
    UIButton *repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeatBtn setFrame:frame];
    [repeatBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [repeatBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"flag.png"]] forState:UIControlStateNormal];
    [repeatBtn setTitle:msg forState:UIControlStateNormal];
    [repeatBtn setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [repeatBtn setAdjustsImageWhenHighlighted:NO];
    [_scrollView addSubview:repeatBtn];
}

- (void)loadGreaterOneBallViewWithCoordY:(CGFloat)y hasLabel:(BOOL)hasLabel whichView:(NSInteger)viewIndex totalBallCount:(NSInteger)counts ballCountsPerRow:(NSInteger)countsPerRow minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum msg:(NSString *)string {
    int viewY = y + 15;
    float x = 0.0;
    float width = kWinSize.width;
    if (hasLabel) {
        x = kSDPromptLabelWidth + kSSLPromptMsgLabelX + 10;
        width = kWinSize.width - (kSDPromptLabelWidth * 2);
    }
    float height = [self calculateBallViewHeightWithViewWidth:kWinSize.width - x andBallCountPerView:counts andBallCountPerRow:countsPerRow isHidden:YES];
    
    CGRect viewFrame = CGRectMake(x, viewY, width, height);
    
    [self loadBallViewWithFrame:viewFrame whichView:viewIndex minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow];
    
    if (hasLabel) {
        [self addPromptMsgInBallView:CGRectMake(kSSLPromptMsgLabelX, viewY + kSSLPromptMsgLabelAddY,kSDPromptLabelWidth, kSSLPromptMsgLabelHeight) message:string withViewIndex:viewIndex];
    }
}

- (void)loadOneView:(BOOL)hasLabel minBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts msg:(NSString *)msg {
    int viewY = 0;
    float x = 0.0;
    float width = kWinSize.width;
    if (hasLabel) {
        x = kSDPromptLabelWidth + kSSLPromptMsgLabelX + 10;
        width = kWinSize.width - (kSDPromptLabelWidth * 2);
    }
    float height = [self calculateBallViewHeightWithViewWidth:kWinSize.width - x
                                          andBallCountPerView:counts
                                           andBallCountPerRow:countsPerRow isHidden:YES];
    CGRect viewFrame = CGRectMake(x, viewY, width, height);
    
    [self loadBallViewWithFrame:viewFrame whichView:1 minBallNum:minNum maxBallNum:maxNum ballCountsPerRow:countsPerRow];
    
    if (hasLabel) {
        [self addPromptMsgInBallView:CGRectMake(kSSLPromptMsgLabelX, viewY + kSSLPromptMsgLabelAddY, kSDPromptLabelWidth, kSSLPromptMsgLabelHeight) message:msg withViewIndex:1];
    }
}

- (void)loadTwoView:(BOOL)hasLabel minBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts msg:(NSString *)msg {
    float y = [self getFirstCoordYAfterView:_oneView];
    [self addLineBewteenBallViewWithCoordY:y + 5];
    [self loadGreaterOneBallViewWithCoordY:y hasLabel:hasLabel whichView:2 totalBallCount:counts ballCountsPerRow:countsPerRow minBallNum:minNum maxBallNum:maxNum msg:msg];
}

- (void)loadThreeView:(BOOL)hasLabel minBallNum:(int)minNum maxBallNum:(int)maxNum ballCountsPerRow:(int)countsPerRow totalBallCounts:(int)counts msg:(NSString *)msg {
    float y = [self getFirstCoordYAfterView:_twoView];
    [self addLineBewteenBallViewWithCoordY:y + 5];
    [self loadGreaterOneBallViewWithCoordY:y hasLabel:hasLabel whichView:3 totalBallCount:counts ballCountsPerRow:countsPerRow minBallNum:minNum maxBallNum:maxNum msg:msg];
}

- (void)showBetCount {
    _totalBetCount = [SDParserNumber getCountFor3DWithOneArray:_oneArray
                                                           two:_twoArray
                                                         three:_threeArray
                                                     andPlayID:_playMethodID
                                             andPlayMethodName:_selectBetType];
    [_bottomView setTextWithCount:_totalBetCount money:_totalBetCount * 2];
}

- (void)createBallsWithBallsType:(BallsType)type minBallNum:(NSInteger)minNum maxBallNum:(NSInteger)maxNum ballCountsPerRow:(NSInteger)ballCountPerView onView:(UIView *)view {
    int aa = 0;
    if (_playMethodID == 613 || _playMethodID == 616) {
        NSArray *names;
        if (_playMethodID == 613) {
            names = [NSArray arrayWithObjects:@"大",@"小", nil];
        } else {
            names = [NSArray arrayWithObjects:@"奇",@"偶", nil];
        }
        
        for (NSInteger i = 0; i < [names count]; i++) {
            NSString *title = [names objectAtIndex:i];
            /********************** adjustment 控件调整 ***************************/
            CGFloat selectBtnMinX = 8.0f;
            CGFloat selectBtnWidth = 213.0f;
            CGFloat selectBtnHeight = 43.0f;
            
            CGFloat selectVerticalInterval = 10.0f;
            /********************** adjustment end ***************************/
            //selectBtn
            CGRect selectBtnRect = CGRectMake(selectBtnMinX, (selectVerticalInterval + selectBtnHeight) * i, selectBtnWidth, selectBtnHeight);
            CustomButton *numberButton = [[CustomButton alloc] initWithFrame:selectBtnRect];
            [numberButton setTag:i+1];
            [numberButton setTitle:title forState:UIControlStateNormal];
            [[numberButton titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
            [numberButton addTarget:self action:@selector(ballSelect2:) forControlEvents:UIControlEventTouchUpInside];
            [_oneView addSubview:numberButton];
            [numberButton release];
            
        }
        
    } else {
        for (NSInteger i = minNum; i <= maxNum; i++) {
            NSString *title = [NSString stringWithFormat:@"%ld",(long)i];
            int row = aa / ballCountPerView;
            int column = aa % ballCountPerView;
            int gap = (view.frame.size.width - kBallSize * ballCountPerView) / (ballCountPerView + 1);
            int x = column * kBallSize + gap * (column + 1) ;
            int y = row * (gap + kBallSize);
            
            Ball *ball = [[Ball alloc]initWithType:type Title:title];
            ball.frame = CGRectMake(x, y, kBallSize, kBallSize);
            ball.tag = i + 1;
            [ball addTarget:self action:@selector(ballSelect:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:ball];
            [ball release];
            
            aa++;
        }
    }
}

- (void)ballSelect:(id)sender {
    NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    if ([[def objectForKey:kIsShake]integerValue] == 1)
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    Ball *ball = sender;
    if(ball.isSelected) {
        [ball setSelected:NO];
        [self removeBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
        [self showBetCount];
        
    } else {
            if([_selectBetType isEqual:@"包选6"]) {
            NSInteger curTag = [(UIButton *)sender tag];
            if ([ball.superview isEqual:_oneView]) {
                ball.selected = YES;
                [self checkHasSameBallWithView:_twoView ballTag:curTag];
                [self checkHasSameBallWithView:_threeView ballTag:curTag];
                [self addBallInSpecifiedArrayWithTag:ball.tag baseView:_oneView];
                
            } else  if ([ball.superview isEqual:_twoView]) {
                ball.selected = YES;
                [self checkHasSameBallWithView:_oneView ballTag:curTag];
                [self checkHasSameBallWithView:_threeView ballTag:curTag];
                [self addBallInSpecifiedArrayWithTag:ball.tag baseView:_twoView];
                
            } else  if ([ball.superview isEqual:_threeView]) {
                ball.selected = YES;
                [self checkHasSameBallWithView:_oneView ballTag:curTag];
                [self checkHasSameBallWithView:_twoView ballTag:curTag];
                [self addBallInSpecifiedArrayWithTag:ball.tag baseView:_threeView];
            }
            
        } else {
            [ball setSelected:YES];
            [self addBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
            [self showBetCount];
        }
    }
    
    [self showBetCount];
}

- (void)ballSelect2:(id)sender {
    [_oneArray count];
    UIButton *ball = (UIButton *)sender;
    
    if (_playMethodID == 613 || _playMethodID == 616) {
        
        if(ball.isSelected) {
            [ball setSelected:NO];
            [self removeBallInSpecifiedArrayWithTag:ball.tag baseView:ball.superview];
            [self showBetCount];
            
        } else {
            NSInteger curTag = [(UIButton *)sender tag];
            for (UIView *view in _oneView.subviews) {
                UIButton *btn = (UIButton *)view;
                if (btn.tag != curTag)
                {
                    [(CustomButton *)ball setSelected:ball.isSelected];
                    [_oneArray removeObject:[NSNumber numberWithInteger:btn.tag]];
                    btn.selected = NO;
                    if ([_oneArray containsObject:[NSNumber numberWithInteger:btn.tag]])
                        [_oneArray removeObject:[NSNumber numberWithInteger:btn.tag]];
                }
                else{
                    btn.selected = YES;
                    [_oneArray removeAllObjects];
                }
            }
            [self addBallInSpecifiedArrayWithTag:ball.tag baseView:_oneView];
        }
        
    } else {
        if (ball.isSelected) {
            [ball setSelected:NO];
            [(CustomButton *)ball setSelected:ball.isSelected];
            
            [_oneArray removeObject:[NSNumber numberWithInteger:ball.tag]];
            
        } else {
            
            [ball setSelected:YES];
            [_oneArray addObject:[NSNumber numberWithInteger:ball.tag]];
            [(CustomButton*)ball setSelected:ball.isSelected];
        }
    }
    
    [self showBetCount];
}

- (void)setStatus {
    for (int i = 0; i < _oneArray.count; i++) {
        for (UIButton *btn in _oneView.subviews) {
            if ([_oneArray[i] integerValue] == btn.tag) {
                [btn setSelected:YES];
                [(CustomButton*)btn setSelected:btn.isSelected];
            }
        }
    }
}

- (void)clearBalls {
    if (_playMethodID == 614 || _playMethodID == 615 || _playMethodID == 613 || _playMethodID == 616) {
        if (_oneArray.count > 0) {
            for (UIView *view in _oneView.subviews) {
                if ([view isKindOfClass:[CustomButton class]]) {
                    CustomButton *btn = (CustomButton *)view;
                    if (btn.isSelected) {
                        [btn setSelected:NO];
                        [(CustomButton*)btn setSelected:btn.isSelected];
                    }
                }
            }
        }
        [_oneArray removeAllObjects];
    } else {
        [self emptySelectedBallInBallViews];
        [self emptyArrays];
    }
    
    [self showBetCount];
}


- (void)viewBallSetSelect:(NSMutableArray *)array view:(UIView *)views {
    if ([_selectBetType isEqualToString:@"猜三同"] || [_selectBetType isEqualToString:@"拖拉机"]) {
        for (NSInteger i = 0; i < [array count]; i++) {
            NSInteger ballTag = [(NSNumber *)[array objectAtIndex:i] intValue];
            UIButton *ball = (UIButton *)[views viewWithTag:ballTag];
            [ball setSelected:YES];
        }
    } else {
        for (NSInteger i = 0; i < [array count]; i++) {
            NSInteger ballTag = [(NSNumber *)[array objectAtIndex:i] intValue];
            Ball *ball = (Ball *)[views viewWithTag:ballTag + 1];
            [ball setSelected:YES];
        }
    }
    
}

- (void)prepareGotoNextPage {
    NSMutableDictionary *betsContentDic = [NSMutableDictionary dictionary];
    NSString *keyPerBets;   // 每选择一次时
    
    if (_betViewController == nil && _selectedBallsDic == nil) {  // 选完球后，按右下角的确认按钮，push到投注页面
        keyPerBets = [NSString stringWithFormat:@"%d",0];
        [betsContentDic setObject:[self combineBetContentDic] forKey:keyPerBets];
        _betViewController = [[SDBetViewController alloc]initWithBallsInfoDic:betsContentDic LotteryDic:_lotteryDic isSupportShake:_isSupportShake];
        [self.navigationController pushViewController:_betViewController animated:YES];
        [_betViewController release];
        
    } else if (_selectedBallsDic != nil) {                       // 反选的时候走这里（修改已选号码的时候）
        [self.baseDelegate updateSelectBallsDic:[self combineBetContentDic] AtRowIndex:_specifiedIndex];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {                                                    // 从投注页面要添加一组手选号码时返回
        SDBetViewController *viewController = (SDBetViewController *)_betViewController;
        [betsContentDic setDictionary:viewController.betInfoDic];
        
        keyPerBets = [NSString stringWithFormat:@"%lu",(unsigned long)viewController.betInfoDic.count];
        [betsContentDic setObject:[self combineBetContentDic] forKey:keyPerBets];
        [viewController setBetInfoDic:betsContentDic];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getSelectedBallNumbers {
    NSString *str = [SDParserNumber get3DBetNumberStringWithOneArray:[MyTool sortArrayFromSmallToLarge:_oneArray]
                                                                 two:[MyTool sortArrayFromSmallToLarge:_twoArray]
                                                               three:[MyTool sortArrayFromSmallToLarge:_threeArray]
                                                           andPlayID:_playMethodID
                                                   andPlayMethodName:_selectBetType];
    NSLog(@"str -> %@", str);
    return str;
}

@end
