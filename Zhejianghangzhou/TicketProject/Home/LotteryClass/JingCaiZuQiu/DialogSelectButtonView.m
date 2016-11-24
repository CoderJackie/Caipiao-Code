//
//  DialogSelectButtonView.m 购彩大厅－竞彩－弹窗选择   混合投注的下标从0开始的，因为混合以前的某个鸟人会将我们投的号码＋1，我们投100服务器会变为101，所以返回也就是101，
//  TicketProject
//
//  Created by KAI on 14-11-13.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "DialogSelectButtonView.h"
#import "CustomizedButton.h"

#import "Globals.h"

#define lineColor [UIColor colorWithRed:0xdd/255.0 green:0xdd/255.0 blue:0xdd/255.0 alpha:1.0]

#define firstScroeViewTagNumber 1
#define secondScroeViewTagNumber 14
#define threeScroeViewTagNumber 19

#define partViewVerticalInterval (IS_PHONE ? 10.0f : 15.0f) //各个区域视图之间的间隔

#define promptLabelMinX (IS_PHONE ? 8.0f : 30.0f)

#pragma mark -
#pragma mark @implementation DialogSelectButtonView
@implementation DialogSelectButtonView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame matchDict:(NSDictionary *)matchDict {
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:YES];
        _matchDict = [matchDict retain];
        _selectMatchNumberArray = [[NSMutableArray alloc] init];
        _selectMatchTextArray = [[NSMutableArray alloc] init];
        
        [self makeSubView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame matchDict:(NSDictionary *)matchDict playID:(NSInteger)playID {
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:YES];
        _matchDict = [matchDict retain];
        _palyID = playID;
        _selectMatchNumberArray = [[NSMutableArray alloc] init];
        _selectMatchTextArray = [[NSMutableArray alloc] init];
        
        [self makeSubView];
    }
    return self;
}

- (id)initWithMatchDict:(NSDictionary *)matchDict selectNumberArray:(NSMutableArray *)selectNumberArray {
    self = [super init];
    if (self) {
        [self setOpaque:YES];
        _matchDict = [matchDict retain];
        _selectMatchNumberArray = [selectNumberArray retain];
    }
    return self;
}

- (void)dealloc {
    [_overlayView release];
    _overlayView = nil;
    _mainTeamLabel = nil;
    _guestTeamLabel = nil;
    _confirmBtn = nil;
    _cancelBtn = nil;
    
    _selectButtonScrollView = nil;
    _letSecondPromptLabel = nil;
    
    [_matchDict release];
    [_selectMatchNumberArray release];
    [_selectMatchTextArray release];
    [_selectMatchIndexPath release];
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat selfViewWidth = self.bounds.size.width;
    CGFloat selfViewHeight = self.bounds.size.height;
    
    CGFloat redLineHeight = 1.0f;
    
    CGFloat labelInterval = 5.0f;
    CGFloat teamCenterLabelWidth = IS_PHONE ? 20.0 : 40.0f;
    CGFloat labelHeight = IS_PHONE ? 34.0f : 60.0f;
    
    CGFloat confirmCancelBtnWidth = IS_PHONE ? selfViewWidth / 2.0f : 250.0f;
    CGFloat confirmCancelBtnLandscapeInterval = IS_PHONE ? 0.0f : 40.0f;
    CGFloat confirmCancelBtnHeight = IS_PHONE ? 36.0f : 45.0f;
    CGFloat confirmCancelBtnBottomInterval = IS_PHONE ? 0.0f : 50.0f;
    /********************** adjustment end ***************************/
    
    //overlayView
    if (!_overlayView) {
        _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [_overlayView setOpaque:YES];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:0.5];
    }
    
    //backView
    UIImageView *backView = [[UIImageView alloc]initWithFrame:self.bounds];
    [backView setOpaque:YES];
    [backView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:backView];
    [backView release];
    
    [[self layer] setShadowOffset:CGSizeMake(1, 1)];
    [[self layer] setShadowOpacity:1];
    [[self layer] setShadowColor:[UIColor blackColor].CGColor];
    
    
    //mainTeamLabel
    CGRect mainTeamLabelRect = CGRectMake(0, 0, (selfViewWidth - teamCenterLabelWidth - labelInterval * 2) / 2.0f, labelHeight);
    _mainTeamLabel = [[UILabel alloc]initWithFrame:mainTeamLabelRect];
    [_mainTeamLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [_mainTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_mainTeamLabel setOpaque:YES];
    [_mainTeamLabel setTextAlignment:NSTextAlignmentRight];
    [_mainTeamLabel setTextColor:kRedColor];
    [self addSubview:_mainTeamLabel];
    [_mainTeamLabel release];
    
    //vsLabel
    CGRect vsLabelRect = CGRectMake(CGRectGetMaxX(mainTeamLabelRect) + labelInterval, CGRectGetMinY(mainTeamLabelRect), teamCenterLabelWidth, labelHeight);
    UILabel *vsLabel = [[UILabel alloc]initWithFrame:vsLabelRect];
    [vsLabel setOpaque:YES];
    [vsLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
    [vsLabel setText:@"VS"];
    [vsLabel setTextColor:kRedColor];
    [vsLabel setBackgroundColor:[UIColor clearColor]];
    [vsLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:vsLabel];
    [vsLabel release];
    
    //guestTeamLabel
    CGRect guestTeamLabelRect = CGRectMake(CGRectGetMaxX(vsLabelRect) + labelInterval, CGRectGetMinY(mainTeamLabelRect), CGRectGetWidth(mainTeamLabelRect), labelHeight);
    _guestTeamLabel = [[UILabel alloc]initWithFrame:guestTeamLabelRect];
    [_guestTeamLabel setOpaque:YES];
    [_guestTeamLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [_guestTeamLabel setBackgroundColor:[UIColor clearColor]];
    [_guestTeamLabel setTextAlignment:NSTextAlignmentLeft];
    [_guestTeamLabel setTextColor:kRedColor];
    [self addSubview:_guestTeamLabel];
    [_guestTeamLabel release];
    
    //redLineView
    CGRect redLineViewRect = CGRectMake(0, CGRectGetMaxY(mainTeamLabelRect), selfViewWidth, redLineHeight);
    _redLineView = [[UIView alloc] initWithFrame:redLineViewRect];
    [_redLineView setOpaque:YES];
    [_redLineView setBackgroundColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0]];
    [self addSubview:_redLineView];
    [_redLineView release];
    
    //cancelBtn
    CGRect cancelBtnRect = CGRectMake(self.center.x - confirmCancelBtnWidth - confirmCancelBtnLandscapeInterval / 2.0f,selfViewHeight - confirmCancelBtnHeight - confirmCancelBtnBottomInterval , confirmCancelBtnWidth, confirmCancelBtnHeight);
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setOpaque:YES];
    [_cancelBtn setFrame:cancelBtnRect];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0x9c/255.0f green:0x9c/255.0f blue:0x9c/255.0f alpha:1.0f]] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0x9c/255.0f green:0x9c/255.0f blue:0x9c/255.0f alpha:1.0f]] forState:UIControlStateHighlighted];
    [_cancelBtn addTarget:self action:@selector(cancelTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    
    //confirmBtn
    CGRect confirmBtnRect = CGRectMake(self.center.x + confirmCancelBtnLandscapeInterval / 2.0f, CGRectGetMinY(cancelBtnRect), confirmCancelBtnWidth, confirmCancelBtnHeight);
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmBtn setOpaque:YES];
    [_confirmBtn setFrame:confirmBtnRect];
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_confirmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateNormal];
    [_confirmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateHighlighted];
    [_confirmBtn addTarget:self action:@selector(confirmTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirmBtn];
}

#pragma mark -MakeUI
- (void)makeScrollView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat selectButtonScrollTopMagin = 0.0f;
    CGFloat selectButtonScrollBottomMagin = IS_PHONE ? 0.0f : 30.0f;
    /********************** adjustment end ***************************/
    CGRect mixScrollViewRect = CGRectMake(0, CGRectGetMaxY(_redLineView.frame) + selectButtonScrollTopMagin, CGRectGetWidth(self.frame), CGRectGetMinY(_confirmBtn.frame) - CGRectGetMaxY(_redLineView.frame) - selectButtonScrollBottomMagin);
    _selectButtonScrollView = [[UIScrollView alloc] initWithFrame:mixScrollViewRect];
    [_selectButtonScrollView setOpaque:YES];
    [self addSubview:_selectButtonScrollView];
    [_selectButtonScrollView release];
}

- (void)makeFootBallScoreView {
    [self makeScrollView];
    /********************** adjustment 控件调整 ***************************/
    CGFloat letPromptLabelHeight = IS_PHONE ? 31.0f : 50.0f;
    
    CGFloat promptLabelAddY = 5.0f;
    /********************** adjustment end ***************************/
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(promptLabelMinX, promptLabelAddY, CGRectGetWidth(self.frame) - promptLabelMinX * 2, letPromptLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setOpaque:YES];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [promptLabel setText:@"竞猜全场90分钟（含伤停补时）的比分"];
    [promptLabel setTextColor:kGrayColor];
    [_selectButtonScrollView addSubview:promptLabel];
    [promptLabel release];
    
    CGFloat partViewMinY = CGRectGetMaxY(promptLabelRect);
    
    if ((int)_palyID == 45) {
        partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bRedColor labelTextColor:tRedColor labelText:@"主胜" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:2 btnCol:5 butType:CustomizedButtonTypeVertical startTag:1 special:YES hasMatch:YES] + partViewVerticalInterval;
        
        partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bBlueColor labelTextColor:tBlueColor labelText:@"平" section:1 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:5 butType:CustomizedButtonTypeVertical startTag:11 special:YES hasMatch:YES] + partViewVerticalInterval;
        
        partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bGreenColor labelTextColor:tGreenColor labelText:@"主负" section:2 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:2 btnCol:5 butType:CustomizedButtonTypeVertical startTag:16 special:YES hasMatch:YES] + partViewVerticalInterval;
    } else {
        partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bRedColor labelTextColor:tRedColor labelText:@"主胜" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:2 btnCol:7 butType:CustomizedButtonTypeVertical startTag:firstScroeViewTagNumber special:YES hasMatch:YES] + partViewVerticalInterval;
        
        partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bBlueColor labelTextColor:tBlueColor labelText:@"平" section:1 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:7 butType:CustomizedButtonTypeVertical startTag:secondScroeViewTagNumber special:YES hasMatch:YES] + partViewVerticalInterval;
        
        partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bGreenColor labelTextColor:tGreenColor labelText:@"主负" section:2 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:2 btnCol:7 butType:CustomizedButtonTypeVertical startTag:threeScroeViewTagNumber special:YES hasMatch:YES] + partViewVerticalInterval;
    }
    
    [_selectButtonScrollView setContentSize:CGSizeMake(CGRectGetWidth(_selectButtonScrollView.frame), partViewMinY)];
}

- (void)makeFootBallTotalGoalView {
    [self makeScrollView];
    /********************** adjustment 控件调整 ***************************/
    CGFloat promptLabelAddY = 5.0f;
    /********************** adjustment end ***************************/
    CGFloat partViewMinY = promptLabelAddY;
    
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bBlueColor labelTextColor:tBlueColor labelText:@"总进球" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:2 btnCol:4 butType:CustomizedButtonTypeVertical startTag:1 special:NO hasMatch:YES] + partViewVerticalInterval;
    
    [_selectButtonScrollView setContentSize:CGSizeMake(CGRectGetWidth(_selectButtonScrollView.frame), partViewMinY)];
}

- (void)makeFootBallHalfView {
    [self makeScrollView];
    /********************** adjustment 控件调整 ***************************/
    CGFloat letPromptLabelHeight = IS_PHONE ? 40.0f : 50.0f;
    
    CGFloat promptLabelAddY = 5.0f;
    /********************** adjustment end ***************************/
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(promptLabelMinX, promptLabelAddY, CGRectGetWidth(self.frame) - promptLabelMinX * 2, letPromptLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setOpaque:YES];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [promptLabel setNumberOfLines:2];
    [promptLabel setText:@"竞猜主队在上半场和全场比赛（不含加时赛和点球大战）的胜平负结果"];
    [promptLabel setTextColor:kGrayColor];
    [_selectButtonScrollView addSubview:promptLabel];
    [promptLabel release];
    
    CGFloat partViewMinY = CGRectGetMaxY(promptLabelRect);
    
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bPurpleColor labelTextColor:tPurpleColor labelText:@"半全场" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:3 btnCol:3 butType:CustomizedButtonTypeVertical startTag:1 special:NO hasMatch:YES] + partViewVerticalInterval;
    
    [_selectButtonScrollView setContentSize:CGSizeMake(CGRectGetWidth(_selectButtonScrollView.frame), partViewMinY)];
}

- (void)makeFootBallMixView {
    [self makeScrollView];
    /********************** adjustment 控件调整 ***************************/
    CGFloat letPromptLabelHeight = IS_PHONE ? 31.0f : 50.0f;
    /********************** adjustment end ***************************/
    NSString *letPromptString = [NSString stringWithFormat:@"主队(%@)让球：",[_matchDict objectForKey:@"mainTeam"]];
    UIFont *letPromptLabelFont = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
    CGSize letPromptSize = [letPromptString sizeWithFont:letPromptLabelFont constrainedToSize:CGSizeMake(MAXFLOAT, 0.0) lineBreakMode:NSLineBreakByCharWrapping];
    
    
    BOOL positiveNumber = YES;
    NSString *letNumberString;
    if ([[_matchDict objectForKey:@"mainLoseBall"] integerValue] < 0) {
        positiveNumber = NO;
        letNumberString = [NSString stringWithFormat:@"%@",[_matchDict objectForKey:@"mainLoseBall"]];
    } else {
        letNumberString = [NSString stringWithFormat:@"+%@",[_matchDict objectForKey:@"mainLoseBall"]];
    }
    /**********************  ***************************/
    //letFirstPromptLabel
    CGRect letFirstPromptLabelRect = CGRectMake(promptLabelMinX, 0, letPromptSize.width, letPromptLabelHeight);
    UILabel *letFirstPromptLabel = [[UILabel alloc] initWithFrame:letFirstPromptLabelRect];
    [letFirstPromptLabel setOpaque:YES];
    [letFirstPromptLabel setFont:letPromptLabelFont];
    [letFirstPromptLabel setText:letPromptString];
    [letFirstPromptLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_selectButtonScrollView addSubview:letFirstPromptLabel];
    [letFirstPromptLabel release];
    
    //letSecondPromptLabel
    CGRect letSecondPromptLabelRect = CGRectMake(CGRectGetMaxX(letFirstPromptLabelRect), 0, CGRectGetWidth(_selectButtonScrollView.frame) - CGRectGetMaxX(letFirstPromptLabelRect) - promptLabelMinX, letPromptLabelHeight);
    _letSecondPromptLabel = [[UILabel alloc] initWithFrame:letSecondPromptLabelRect];
    [_letSecondPromptLabel setOpaque:YES];
    [_letSecondPromptLabel setFont:letPromptLabelFont];
    [_letSecondPromptLabel setText:letNumberString];
    [_letSecondPromptLabel setTextColor:positiveNumber ? kRedColor : kGreenColor];
    [_selectButtonScrollView addSubview:_letSecondPromptLabel];
    [_letSecondPromptLabel release];
    
    CGFloat partViewMinY = CGRectGetMaxY(letFirstPromptLabelRect);
    
    
    BOOL hasMatch = [self hasMatch:500];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bYellowColor labelTextColor:tYellowColor labelText:@"非让球" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:3 butType:CustomizedButtonTypeLandscape startTag:500 special:NO hasMatch:hasMatch];
    
    hasMatch = [self hasMatch:100];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bGreenColor labelTextColor:tGreenColor labelText:@"让球" section:1 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:3 butType:CustomizedButtonTypeLandscape startTag:100 special:NO hasMatch:hasMatch] + partViewVerticalInterval;
    
    hasMatch = [self hasMatch:300];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bRedColor labelTextColor:tRedColor labelText:@"比分" section:2 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:5 btnCol:7 butType:CustomizedButtonTypeVertical startTag:300 special:YES hasMatch:hasMatch] + partViewVerticalInterval;
    
    hasMatch = [self hasMatch:200];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bBlueColor labelTextColor:tBlueColor labelText:@"总进球" section:3 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:2 btnCol:4 butType:CustomizedButtonTypeVertical startTag:200 special:NO hasMatch:hasMatch] + partViewVerticalInterval;
    
    hasMatch = [self hasMatch:400];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bPurpleColor labelTextColor:tPurpleColor labelText:@"半全场" section:4 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:3 btnCol:3 butType:CustomizedButtonTypeVertical startTag:400 special:NO hasMatch:hasMatch] + partViewVerticalInterval;
    
    [_selectButtonScrollView setContentSize:CGSizeMake(CGRectGetWidth(_selectButtonScrollView.frame), partViewMinY)];
}

- (void)makeBasketBallMinusScoreView {
    [self makeScrollView];

    CGFloat partViewMinY = partViewVerticalInterval;
    
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bRedColor labelTextColor:tRedColor labelText:@"客胜" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:3 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:1 special:NO hasMatch:YES];
    
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bGreenColor labelTextColor:tGreenColor labelText:@"主胜" section:1 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:3 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:2 special:NO hasMatch:YES] + partViewVerticalInterval;
    
    [_selectButtonScrollView setContentSize:CGSizeMake(CGRectGetWidth(_selectButtonScrollView.frame), partViewMinY)];
}

- (void)makeBasketBallMixView {
    [self makeScrollView];
    /********************** adjustment 控件调整 ***************************/
    CGFloat letPromptLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    /********************** adjustment end ***************************/
    UIFont *letPromptLabelFont = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
    
    NSString *letPromptString = [NSString stringWithFormat:@"主队(%@)让分：",[_matchDict objectForKey:@"mainTeam"]];
    CGSize letPromptSize = [letPromptString sizeWithFont:letPromptLabelFont constrainedToSize:CGSizeMake(MAXFLOAT, 0.0) lineBreakMode:NSLineBreakByCharWrapping];
    
    NSString *letScore = [_matchDict objectForKey:@"letScore"];
    
    NSString *scorePromptString = @"预设总分：";
    CGSize scorePromptSize = [scorePromptString sizeWithFont:letPromptLabelFont constrainedToSize:CGSizeMake(MAXFLOAT, 0.0) lineBreakMode:NSLineBreakByCharWrapping];
    
    /**********************  ***************************/
    //letFirstPromptLabel
    CGRect letFirstPromptLabelRect = CGRectMake(promptLabelMinX, 0, letPromptSize.width, letPromptLabelHeight);
    UILabel *letFirstPromptLabel = [[UILabel alloc] initWithFrame:letFirstPromptLabelRect];
    [letFirstPromptLabel setOpaque:YES];
    [letFirstPromptLabel setFont:letPromptLabelFont];
    [letFirstPromptLabel setText:letPromptString];
    [letFirstPromptLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_selectButtonScrollView addSubview:letFirstPromptLabel];
    [letFirstPromptLabel release];
    
    //letSecondPromptLabel
    CGRect letSecondPromptLabelRect = CGRectMake(CGRectGetMaxX(letFirstPromptLabelRect), 0, CGRectGetWidth(_selectButtonScrollView.frame) - CGRectGetMaxX(letFirstPromptLabelRect) - promptLabelMinX, letPromptLabelHeight);
    _letSecondPromptLabel = [[UILabel alloc] initWithFrame:letSecondPromptLabelRect];
    [_letSecondPromptLabel setOpaque:YES];
    [_letSecondPromptLabel setText:[letScore doubleValue] > 0 ? [NSString stringWithFormat:@"+%@",letScore] : letScore];
    [_letSecondPromptLabel setTextColor:[letScore doubleValue] > 0 ? tRedColor : tGreenColor];
    [_letSecondPromptLabel setFont:letPromptLabelFont];
    [_selectButtonScrollView addSubview:_letSecondPromptLabel];
    [_letSecondPromptLabel release];
    
    CGFloat partViewMinY = CGRectGetMaxY(letFirstPromptLabelRect);
    
    BOOL hasMatch = [self hasMatch:100];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bYellowColor labelTextColor:tYellowColor labelText:@"胜负" section:0 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:100 special:NO hasMatch:hasMatch];
    
    hasMatch = [self hasMatch:200];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bGreenColor labelTextColor:tGreenColor labelText:@"让分" section:1 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:200 special:NO hasMatch:hasMatch];
    
    //scorePromptLabel
    CGRect scorePromptLabelRect = CGRectMake(promptLabelMinX, partViewMinY, scorePromptSize.width, letPromptLabelHeight);
    UILabel *scorePromptLabel = [[UILabel alloc] initWithFrame:scorePromptLabelRect];
    [scorePromptLabel setOpaque:YES];
    [scorePromptLabel setFont:letPromptLabelFont];
    [scorePromptLabel setText:scorePromptString];
    [scorePromptLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
    [_selectButtonScrollView addSubview:scorePromptLabel];
    [scorePromptLabel release];
    
    //scoreSecondPromptLabel
    CGRect scoreSecondPromptLabelRect = CGRectMake(CGRectGetMaxX(scorePromptLabelRect), partViewMinY, CGRectGetWidth(_selectButtonScrollView.frame) - CGRectGetMaxX(scorePromptLabelRect) - promptLabelMinX, letPromptLabelHeight);
    _scoreSecondPromptLabel = [[UILabel alloc] initWithFrame:scoreSecondPromptLabelRect];
    [_scoreSecondPromptLabel setOpaque:YES];
    [_scoreSecondPromptLabel setFont:letPromptLabelFont];
    [_scoreSecondPromptLabel setText:[NSString stringWithFormat:@"%.1f",[[_matchDict objectForKey:@"bigSmallScore"] doubleValue]]];
    [_selectButtonScrollView addSubview:_scoreSecondPromptLabel];
    [_scoreSecondPromptLabel release];
    
    partViewMinY = CGRectGetMaxY(scoreSecondPromptLabelRect);
    
    hasMatch = [self hasMatch:300];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bYellowColor labelTextColor:tYellowColor labelText:@"大小分" section:2 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:1 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:300 special:NO hasMatch:hasMatch] + partViewVerticalInterval;
    
    hasMatch = [self hasMatch:400];
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bRedColor labelTextColor:tRedColor labelText:@"客胜" section:3 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:3 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:400 special:NO hasMatch:hasMatch];
    
    partViewMinY = [self maxYInMakeMixViewWithLabelBackColor:bGreenColor labelTextColor:tGreenColor labelText:@"主胜" section:4 viewMinX:promptLabelMinX viewMinY:partViewMinY btnRow:3 btnCol:2 butType:CustomizedButtonTypeLandscape startTag:401 special:NO hasMatch:hasMatch] + partViewVerticalInterval;
    
    [_selectButtonScrollView setContentSize:CGSizeMake(CGRectGetWidth(_selectButtonScrollView.frame), partViewMinY)];
}

- (CGFloat)maxYInMakeMixViewWithLabelBackColor:(UIColor *)labelBackColor
                                labelTextColor:(UIColor *)labelTextColor
                                     labelText:(NSString *)labelText
                                       section:(NSInteger)section
                                      viewMinX:(CGFloat)viewMinX
                                      viewMinY:(CGFloat)viewMinY
                                        btnRow:(NSInteger)btnRow
                                        btnCol:(NSInteger)btnCol
                                       butType:(CustomizedButtonType)butType
                                      startTag:(NSInteger)startTag
                                       special:(BOOL)special
                                      hasMatch:(BOOL)hasMatch {
    /********************** adjustment 控件调整 ***************************/
    CGFloat promptLabelWidth = IS_PHONE ? 20.0f : 22.0f;
    
    CGFloat btnHeight = IS_PHONE ? 40.0f : 60.0f;
    
    CGFloat landscapeInterval = IS_PHONE ? 0.0f : 2.0f;
    CGFloat verticalInterval = IS_PHONE ? 0.0f : 2.0f;
    
    CGFloat btnWidth = (CGRectGetWidth(_selectButtonScrollView.frame) - viewMinX * 2 - promptLabelWidth - landscapeInterval * btnCol) / btnCol;
    
    /********************** adjustment end ***************************/
    
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(viewMinX, viewMinY - AllLineWidthOrHeight, promptLabelWidth, (btnHeight + verticalInterval) * btnRow + AllLineWidthOrHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setOpaque:YES];
    [promptLabel setBackgroundColor:labelBackColor];
    [promptLabel setTextColor:labelTextColor];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [promptLabel setNumberOfLines:5];
    [[promptLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [[promptLabel layer] setBorderColor:lineColor.CGColor];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setText:labelText];
    [_selectButtonScrollView addSubview:promptLabel];
    [promptLabel release];
    
    if(hasMatch) {
        NSInteger partStartTag = startTag;
        CGFloat   promptLabelMaxX = CGRectGetMaxX(promptLabelRect);
        
        CGRect btnBackViewRect = CGRectMake(promptLabelMaxX, CGRectGetMinY(promptLabelRect), CGRectGetWidth(_selectButtonScrollView.frame) - viewMinX * 2 - promptLabelWidth, CGRectGetHeight(promptLabelRect));
        UIView *btnBackView = [[UIView alloc] initWithFrame:btnBackViewRect];
        [btnBackView setBackgroundColor:lineColor];
        [_selectButtonScrollView addSubview:btnBackView];
        [btnBackView release];
        
        
        for(NSInteger row = 0; row < btnRow; row++) {
            for (NSInteger col = 0; col < btnCol; col++) {
                
                BOOL signBreak = NO;
                CGRect btnRect;
                if (special) {
                    if ((int)_palyID == 45) {
                        btnRect = CGRectMake(promptLabelMaxX + col * (btnWidth + landscapeInterval) - AllLineWidthOrHeight, viewMinY + row * (btnHeight + verticalInterval) - AllLineWidthOrHeight, btnWidth + AllLineWidthOrHeight, btnHeight + AllLineWidthOrHeight);
                    } else {
                        if ((DialogFootBallMix && col == 5 && (row == 1 || row == 4)) || (DialogFootBallScore && col == 5 && row == 1 && (section == 0 || section == 2))) {
                            btnRect = CGRectMake(promptLabelMaxX + col * (btnWidth + landscapeInterval) - AllLineWidthOrHeight, viewMinY + row * (btnHeight + verticalInterval) - AllLineWidthOrHeight, btnWidth * 2 + landscapeInterval + AllLineWidthOrHeight, btnHeight + AllLineWidthOrHeight);
                            signBreak = YES;
                        } else if ((DialogFootBallMix && row == 2 && col == 4) || (DialogFootBallScore && col == 4 && row == 0 && section == 1)) {
                            btnRect = CGRectMake(promptLabelMaxX + col * (btnWidth + landscapeInterval) - AllLineWidthOrHeight, viewMinY + row * (btnHeight + verticalInterval) - AllLineWidthOrHeight, btnWidth * 3 + landscapeInterval * 2 + AllLineWidthOrHeight, btnHeight + AllLineWidthOrHeight);
                            signBreak = YES;
                        } else {
                            btnRect = CGRectMake(promptLabelMaxX + col * (btnWidth + landscapeInterval) - AllLineWidthOrHeight, viewMinY + row * (btnHeight + verticalInterval) - AllLineWidthOrHeight, btnWidth + AllLineWidthOrHeight, btnHeight + AllLineWidthOrHeight);
                        }
                    }
                } else {
                    btnRect = CGRectMake(promptLabelMaxX + col * (btnWidth + landscapeInterval), viewMinY + row * (btnHeight + verticalInterval), btnWidth - AllLineWidthOrHeight, btnHeight - AllLineWidthOrHeight);
                    
                }
                
                CustomizedButton *btn = [[CustomizedButton alloc] initWithFrame:btnRect];
                [btn setOpaque:YES];
                [btn setBackgroundImage:[[UIImage imageNamed:@"singleMatchNormalBtn.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:8.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:8.0f topCapHeight:8.0f] forState:UIControlStateSelected];
                [btn setTag:partStartTag];
                [btn setTextString:[self textWithTag:partStartTag]];
                [btn setOddsString:[NSString stringWithFormat:@"%.2f",[[_matchDict objectForKey:[self serverKeyWithTag:partStartTag]] doubleValue]]];
                [btn setTextFontSize:XFIponeIpadFontSize14];
                [btn setOddsLabelFontSize:XFIponeIpadFontSize10];
                [btn setTextTextSelectColor:[UIColor whiteColor]];
                [btn setOddsTextColor:[UIColor colorWithRed:0x99/255.0f green:0x99/255.0f blue:0x99/255.0f alpha:1.0f]];
                [btn setOddsTextSelectColor:[UIColor whiteColor]];
                [btn setCustomizedButtonType:butType];
                [btn setLandscapeInterval:3.0f];
                [btn addTarget:self action:@selector(selectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [_selectButtonScrollView addSubview:btn];
                [btn release];
                partStartTag++;
                if (_dialogType == DialogBasketBallMinusScore || (_dialogType == DialogBasketBallMix && startTag >= 400 && startTag <= 499)) {//如果是胜分差，多加1，后台的神奇排序，混合的胜分差就正常
                    partStartTag++;
                }
                if (signBreak) {
                    break;
                }
            }
        }
    } else {
        
        CGRect noMatchPromptLabelRect = CGRectMake(CGRectGetMaxX(promptLabelRect) - AllLineWidthOrHeight, viewMinY - AllLineWidthOrHeight, (btnWidth + landscapeInterval) * btnCol + AllLineWidthOrHeight, (btnHeight + verticalInterval) * btnRow + AllLineWidthOrHeight);
        
        
        UILabel *noMatchPromptLabel = [[UILabel alloc] initWithFrame:noMatchPromptLabelRect];
        [noMatchPromptLabel setBackgroundColor:[UIColor clearColor]];
        [noMatchPromptLabel setTextAlignment:NSTextAlignmentCenter];
        [noMatchPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [noMatchPromptLabel setTextColor:kGrayColor];
        [noMatchPromptLabel setText:@"暂未开售"];
        [[noMatchPromptLabel layer] setBorderWidth:AllLineWidthOrHeight];
        [[noMatchPromptLabel layer] setBorderColor:lineColor.CGColor];
        [_selectButtonScrollView addSubview:noMatchPromptLabel];
        [noMatchPromptLabel release];
    }
    
    //篮球客队在前主队在后
    if (_dialogType == DialogBasketBallMinusScore || _dialogType == DialogBasketBallMix) {
        [_mainTeamLabel setText:[_matchDict objectForKey:@"guestTeam"]];
        [_guestTeamLabel setText:[_matchDict objectForKey:@"mainTeam"]];
    } else {
        [_mainTeamLabel setText:[_matchDict objectForKey:@"mainTeam"]];
        [_guestTeamLabel setText:[_matchDict objectForKey:@"guestTeam"]];
    }
        
    return (viewMinY + btnHeight * btnRow + verticalInterval * btnRow);
}

#pragma mark -AttributeMethod
- (void)setDialogType:(DialogType)dialogType {
    if (_dialogType != dialogType) {
        _dialogType = dialogType;
        if (_dialogType == DialogFootBallScore) {
            [self makeFootBallScoreView];
            _buildedSelectView = YES;
            if (!_selectButton) {
                [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
            }
        } else if (_dialogType == DialogFootBallTotalGoal) {
            [self makeFootBallTotalGoalView];
            _buildedSelectView = YES;
            if (!_selectButton) {
                [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
            }
        } else if (_dialogType == DialogFootBallHalf) {
            [self makeFootBallHalfView];
            _buildedSelectView = YES;
            if (!_selectButton) {
                [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
            }
        } else if (_dialogType == DialogFootBallMix) {
            [self makeFootBallMixView];
            _buildedSelectView = YES;
            if (!_selectButton) {
                [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
            }
        } else if (_dialogType == DialogBasketBallMinusScore) {
            [self makeBasketBallMinusScoreView];
            _buildedSelectView = YES;
            if (!_selectButton) {
                [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
            }
        } else if (_dialogType == DialogBasketBallMix) {
            [self makeBasketBallMixView];
            _buildedSelectView = YES;
            if (!_selectButton) {
                [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
            }
        }
        
    }
}

- (void)setSelectMatchIndexPath:(NSIndexPath *)selectMatchIndexPath {
    if (![_selectMatchIndexPath isEqual:selectMatchIndexPath]) {
        [_selectMatchIndexPath release];
        _selectMatchIndexPath = [selectMatchIndexPath retain];
    }
}

- (void)setSelectMatchNumberArray:(NSMutableArray *)selectMatchNumberArray {
    if (![_selectMatchNumberArray isEqualToArray:selectMatchNumberArray]) {
        [_selectMatchNumberArray removeAllObjects];
        [_selectMatchNumberArray addObjectsFromArray:selectMatchNumberArray];
        [self setSelectBtnSelectWithArray:_selectMatchNumberArray];
    }
}

#pragma mark -
#pragma mark -Delegate

#pragma mark -
#pragma mark -Customized(Action)
- (void)selectTouchUpInside:(id)sender {
    CustomizedButton *selectBtn = (CustomizedButton *)sender;
    [selectBtn setSelected:![selectBtn isSelected]];
    NSInteger selectBtnTag = selectBtn.tag;
    
    NSString *selectNumber = [NSString stringWithFormat:@"%ld",(long)(selectBtnTag)];
    if ([selectBtn isSelected] && selectNumber) {
        [_selectMatchNumberArray addObject:selectNumber];
    } else if (selectNumber) {
        [_selectMatchNumberArray removeObject:selectNumber];
    }
}

- (void)confirmTouchUpInside:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(dialogSelectMatch:selectMatchText:dialogType:indexPath:)]) {
    
        if (_selectMatchNumberArray) {
            [Globals sortWithNumberArray:_selectMatchNumberArray];
        }
        [self setSelectMatchTextWithNumberArray:_selectMatchNumberArray];
        [_delegate dialogSelectMatch:_selectMatchNumberArray selectMatchText:_selectMatchTextArray dialogType:_dialogType indexPath:_selectMatchIndexPath];
        
        [self fadeOut];
    }
}

- (void)cancelTouchUpInside:(id)sender {
    [self fadeOut];
}

#pragma mark -Customized: Private (General)
- (void)setSelectMatchTextWithNumberArray:(NSMutableArray *)numberArray {
    [_selectMatchTextArray removeAllObjects];
    if (_dialogType == DialogFootBallScore) {
        for (NSString *numberString in numberArray) {
            [_selectMatchTextArray addObject:[self textWithFootBallNumber:[numberString integerValue] + 300 - 1]];
        }
    } else if (_dialogType == DialogFootBallTotalGoal) {
        for (NSString *numberString in numberArray) {
            [_selectMatchTextArray addObject:[self textWithFootBallNumber:[numberString integerValue] + 200 - 1]];
        }
        
    } else if (_dialogType == DialogFootBallHalf) {
        for (NSString *numberString in numberArray) {
            [_selectMatchTextArray addObject:[self textWithFootBallNumber:[numberString integerValue] + 400 - 1]];
        }
    } else if (_dialogType == DialogFootBallMix) {
        for (NSString *numberString in numberArray) {
            [_selectMatchTextArray addObject:[self textWithFootBallNumber:[numberString integerValue]]];
        }
    } else if (_dialogType == DialogBasketBallMinusScore) {
        for (NSString *numberString in numberArray) {
            [_selectMatchTextArray addObject:[self textWithBasketBallNumber:[numberString integerValue] + 400 - 1]];
        }
    } else if (_dialogType == DialogBasketBallMix) {
        for (NSString *numberString in numberArray) {
            [_selectMatchTextArray addObject:[self textWithBasketBallNumber:[numberString integerValue]]];
        }
    }
}

- (NSString *)textWithFootBallNumber:(NSInteger)number {
    if (number >= 100 && number <= 199) {
        return [self letWinLoseTextWithTag:number];
        
    } else if (number >= 500 && number <= 599) {
        return [self winLoseTextWithTag:number];
        
    } else if (number >= 200 && number <= 299) {
        return [self totalBallTextWithTag:number];
        
    } else if (number >= 400 && number <= 499) {
        return [self halfTextWithTag:number];
        
    } else if (number >= 300 && number <= 399) {
        return [self scoreTextWithTag:number];
        
    }
    return @"";
}

- (NSString *)textWithBasketBallNumber:(NSInteger)number {
    if (number >= 100 && number <= 199) {
        return [self basketBallWinLoseTextWithTag:number];
        
    } else if (number >= 200 && number <= 299) {
        return [self basketBallLetWinLoseTextWithTag:number];
        
    } else if (number >= 400 && number <= 499) {
        return [self basketBallMinusScoreTextWithTag_4:number];
        
    } else if (number >= 300 && number <= 399) {
        return [self basketBallBigSmallScoreTextWithTag:number];
        
    }
    return @"";
}

- (NSString *)textWithTag:(NSInteger)tag {
    if (_dialogType == DialogFootBallScore) {
        return [self scoreTextWithTag:tag + 300 - 1];
        
    } else if (_dialogType == DialogFootBallTotalGoal) {
        return [self totalBallTextWithTag:tag + 200 - 1];
        
    } else if (_dialogType == DialogFootBallHalf) {
        return [self halfTextWithTag:tag + 400 - 1];
        
    } else if (_dialogType == DialogFootBallMix) {
        if (tag >= 100 && tag <= 199) {
            return [self winLoseTextWithTag:tag];
            
        } else if (tag >= 500 && tag <= 599) {
            return [self winLoseTextWithTag:tag];
            
        } else if (tag >= 200 && tag <= 299) {
            return [self totalBallTextWithTag:tag];
            
        } else if (tag >= 400 && tag <= 499) {
            return [self halfTextWithTag:tag];
            
        } else if (tag >= 300 && tag <= 399) {
            return [self scoreTextWithTag:tag];
            
        }
        
    } else if (_dialogType == DialogBasketBallMinusScore) { //胜分差
            return [self basketBallMinusScoreTextWithTag_3:tag + 400 - 1];
        
    } else if (_dialogType == DialogBasketBallMix) {
        if (tag >= 100 && tag <= 199) {
            return [self basketBallWinLoseTextWithTag:tag];
            
        } else if (tag >= 200 && tag <= 299) {
            return [self basketBallWinLoseTextWithTag:tag - 100];
            
        } else if (tag >= 300 && tag <= 399) {
            return [self basketBallBigSmallScoreTextWithTag:tag];
            
        } else if (tag >= 400 && tag <= 499) {
            return [self basketBallMinusScoreTextWithTag_3:tag];//混合的胜分差
            
        }
        
    }
    return @"";
}

- (NSString *)serverKeyWithTag:(NSInteger)tag {
    if (_dialogType == DialogFootBallScore) {
        return [self serverKeyOfScoreWithTag:(tag + 300 - 1)];
        
    } else if (_dialogType == DialogFootBallTotalGoal) {
        return [self serverKeyOfTotalBallWithTag:(tag + 200 - 1)];
        
    } else if (_dialogType == DialogFootBallHalf) {
        return [self serverKeyOfHalfWithTag:(tag + 400 - 1)];
        
    } else if (_dialogType == DialogFootBallMix) {
        if (tag >= 100 && tag <= 199) {
            return [self serverKeyOfWinLoseWithTag:tag];
            
        } else if (tag >= 500 && tag <= 599) {
            return [self serverKeyOfWinLoseWithTag:tag];
            
        } else if (tag >= 200 && tag <= 299) {
            return [self serverKeyOfTotalBallWithTag:tag];
            
        } else if (tag >= 400 && tag <= 499) {
            return [self serverKeyOfHalfWithTag:tag];
            
        } else if (tag >= 300 && tag <= 399) {
            return [self serverKeyOfScoreWithTag:tag];
            
        }
    } else if (_dialogType == DialogBasketBallMinusScore) { //胜分差
        return [self serverKeyOfBasketBallMinusScoreWithTag_2:tag + 400 - 1];
        
    } else if (_dialogType == DialogBasketBallMix) {
        if (tag >= 100 && tag <= 199) {
            return [self serverKeyOfBasketBallWinLoseWithTag:tag];
            
        } else if (tag >= 200 && tag <= 299) {
            return [self serverKeyOfBasketBallLetWinLoseWithTag:tag];
            
        } else if (tag >= 300 && tag <= 399) {
            return [self serverKeyOfBasketBallBigSmallScoreWithTag:tag];
            
        } else if (tag >= 400 && tag <= 499) {
            return [self serverKeyOfBasketBallMinusScoreWithTag_2:tag];//混合的胜分差
            
        }
    }
    return @"";
}

- (NSString *)winLoseTextWithTag:(NSInteger)tag {
    NSInteger indexSign = tag % 10;
    
    switch (indexSign) {
        case 0:
            return @"主胜";
            break;
        case 1:
            return @"平";
            break;
        case 2:
            return @"主负";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)letWinLoseTextWithTag:(NSInteger)tag {
    NSInteger indexSign = tag % 10;
    switch (indexSign) {
        case 0:
            return @"让主胜";
            break;
        case 1:
            return @"让平";
            break;
        case 2:
            return @"让主负";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)serverKeyOfWinLoseWithTag:(NSInteger)tag {
    switch (tag) {
        case 100:
            return @"win";
            break;
        case 101:
            return @"flat";
            break;
        case 102:
            return @"lose";
            break;
        case 500:
            return @"spfwin";
            break;
        case 501:
            return @"spfflat";
            break;
        case 502:
            return @"spflose";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)scoreTextWithTag:(NSInteger)tag {
    if ((int)_palyID == 45) {
        switch (tag) {
            case 300:
                return @"1:0";
                break;
            case 301:
                return @"2:0";
                break;
            case 302:
                return @"2:1";
                break;
            case 303:
                return @"3:0";
                break;
            case 304:
                return @"3:1";
                break;
            case 305:
                return @"3:2";
                break;
            case 306:
                return @"4:0";
                break;
            case 307:
                return @"4:1";
                break;
            case 308:
                return @"4:2";
                break;
            case 309:
                return @"胜其他";
                break;
            case 310:
                return @"0:0";
                break;
            case 311:
                return @"1:1";
                break;
            case 312:
                return @"2:2";
                break;
            case 313:
                return @"3:3";
                break;
            case 314:
                return @"平其他";
                break;
            case 315:
                return @"0:1";
                break;
            case 316:
                return @"0:2";
                break;
            case 317:
                return @"1:2";
                break;
            case 318:
                return @"0:3";
                break;
            case 319:
                return @"1:3";
                break;
            case 320:
                return @"2:3";
                break;
            case 321:
                return @"0:4";
                break;
            case 322:
                return @"1:4";
                break;
            case 323:
                return @"2:4";
                break;
            case 324:
                return @"负其他";
                break;
                
            default:
                break;
        }
    } else {
        switch (tag) {
            case 300:
                return @"1:0";
                break;
            case 301:
                return @"2:0";
                break;
            case 302:
                return @"2:1";
                break;
            case 303:
                return @"3:0";
                break;
            case 304:
                return @"3:1";
                break;
            case 305:
                return @"3:2";
                break;
            case 306:
                return @"4:0";
                break;
            case 307:
                return @"4:1";
                break;
            case 308:
                return @"4:2";
                break;
            case 309:
                return @"5:0";
                break;
            case 310:
                return @"5:1";
                break;
            case 311:
                return @"5:2";
                break;
            case 312:
                return @"胜其他";
                break;
            case 313:
                return @"0:0";
                break;
            case 314:
                return @"1:1";
                break;
            case 315:
                return @"2:2";
                break;
            case 316:
                return @"3:3";
                break;
            case 317:
                return @"平其他";
                break;
            case 318:
                return @"0:1";
                break;
            case 319:
                return @"0:2";
                break;
            case 320:
                return @"1:2";
                break;
            case 321:
                return @"0:3";
                break;
            case 322:
                return @"1:3";
                break;
            case 323:
                return @"2:3";
                break;
            case 324:
                return @"0:4";
                break;
            case 325:
                return @"1:4";
                break;
            case 326:
                return @"2:4";
                break;
            case 327:
                return @"0:5";
                break;
            case 328:
                return @"1:5";
                break;
            case 329:
                return @"2:5";
                break;
            case 330:
                return @"负其他";
                break;
                
            default:
                break;
        }
    }
    return @"";
}

- (NSString *)serverKeyOfScoreWithTag:(NSInteger)tag {
    if ((int)_palyID == 45) {
        switch (tag) {
            case 300:
                return @"bfWin10Sp";
                break;
            case 301:
                return @"bfWin20Sp";
                break;
            case 302:
                return @"bfWin21Sp";
                break;
            case 303:
                return @"bfWin30Sp";
                break;
            case 304:
                return @"bfWin31Sp";
                break;
            case 305:
                return @"bfWin32Sp";
                break;
            case 306:
                return @"bfWin40Sp";
                break;
            case 307:
                return @"bfWin41Sp";
                break;
            case 308:
                return @"bfWin42Sp";
                break;
            case 309:
                return @"bfWinSqtSp";
                break;
            case 310:
                return @"bfFlat00Sp";
                break;
            case 311:
                return @"bfFlat11Sp";
                break;
            case 312:
                return @"bfFlat22Sp";
                break;
            case 313:
                return @"bfFlat33Sp";
                break;
            case 314:
                return @"bfFlatPqtSp";
                break;
            case 315:
                return @"bfLose01Sp";
                break;
            case 316:
                return @"bfLose02Sp";
                break;
            case 317:
                return @"bfLose12Sp";
                break;
            case 318:
                return @"bfLose03Sp";
                break;
            case 319:
                return @"bfLose13Sp";
                break;
            case 320:
                return @"bfLose23Sp";
                break;
            case 321:
                return @"bfLose04Sp";
                break;
            case 322:
                return @"bfLose14Sp";
                break;
            case 323:
                return @"bfLose24Sp";
                break;
            case 324:
                return @"bfLoseFqtSp";
                break;
                
            default:
                break;
        }
    } else {
        switch (tag) {
            case 300:
                return @"s10";
                break;
            case 301:
                return @"s20";
                break;
            case 302:
                return @"s21";
                break;
            case 303:
                return @"s30";
                break;
            case 304:
                return @"s31";
                break;
            case 305:
                return @"s32";
                break;
            case 306:
                return @"s40";
                break;
            case 307:
                return @"s41";
                break;
            case 308:
                return @"s42";
                break;
            case 309:
                return @"s50";
                break;
            case 310:
                return @"s51";
                break;
            case 311:
                return @"s52";
                break;
            case 312:
                return @"sother";
                break;
            case 313:
                return @"p00";
                break;
            case 314:
                return @"p11";
                break;
            case 315:
                return @"p22";
                break;
            case 316:
                return @"p33";
                break;
            case 317:
                return @"pother";
                break;
            case 318:
                return @"f01";
                break;
            case 319:
                return @"f02";
                break;
            case 320:
                return @"f12";
                break;
            case 321:
                return @"f03";
                break;
            case 322:
                return @"f13";
                break;
            case 323:
                return @"f23";
                break;
            case 324:
                return @"f04";
                break;
            case 325:
                return @"f14";
                break;
            case 326:
                return @"f24";
                break;
            case 327:
                return @"f05";
                break;
            case 328:
                return @"f15";
                break;
            case 329:
                return @"f25";
                break;
            case 330:
                return @"fother";
                break;
                
            default:
                break;
        }
    }
    return @"";
}

- (NSString *)totalBallTextWithTag:(NSInteger)tag {
    if (tag % 10 >= 7) {
        return @"7+球";
    }
    return [NSString stringWithFormat:@"%ld球",(long)(tag % 10)];
}

- (NSString *)serverKeyOfTotalBallWithTag:(NSInteger)tag {
    if ((int)_palyID == 45) {
        if (tag % 10 >= 7) {
            return @"zjq7";
        }
        return [NSString stringWithFormat:@"zjq%ld",(long)(tag % 10)];
        
    } else {
        if (tag % 10 >= 7) {
            return @"in7";
        }
        return [NSString stringWithFormat:@"in%ld",(long)(tag % 10)];
    }
    
    return @"";
}

- (NSString *)halfTextWithTag:(NSInteger)tag {
    NSInteger indexSign = tag % 10;
    return [NSString stringWithFormat:@"%@%@",[self getTextWithIndex:(indexSign / 3)],[self getTextWithIndex:(indexSign % 3)]];
}

- (NSString *)serverKeyOfHalfWithTag:(NSInteger)tag {
    if ((int)_palyID == 45) {
        switch (tag) {
            case 400:
                return @"bqcSsSp";
                break;
            case 401:
                return @"bqcSpSp";
                break;
            case 402:
                return @"bqcSfSp";
                break;
            case 403:
                return @"bqcPsSp";
                break;
            case 404:
                return @"bqcPpSp";
                break;
            case 405:
                return @"bqcPfSp";
                break;
            case 406:
                return @"bqcFsSp";
                break;
            case 407:
                return @"bqcFpSp";
                break;
            case 408:
                return @"bqcFfSp";
                break;
                
            default:
                break;
        }
    } else {
        NSInteger indexSign = tag % 10;
        return [NSString stringWithFormat:@"%@%@",[self getMatchDictPartKeyStringWithIndex:(indexSign / 3)],[self getMatchDictPartKeyStringWithIndex:(indexSign % 3)]];
    }
    
    return @"";
}

- (NSString *)getTextWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"胜";
            break;
        case 1:
            return @"平";
            break;
        case 2:
            return @"负";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)getMatchDictPartKeyStringWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"s";//胜
            break;
        case 1:
            return @"p";//平
            break;
        case 2:
            return @"f";//负
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)basketBallWinLoseTextWithTag:(NSInteger)tag {
    switch (tag) {
        case 100:
            return @"客胜";
            break;
        case 101:
            return @"主胜";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)serverKeyOfBasketBallWinLoseWithTag:(NSInteger)tag {
    switch (tag) {
        case 100:
            return @"mainLose";
            break;
        case 101:
            return @"mainWin";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)basketBallLetWinLoseTextWithTag:(NSInteger)tag {
    switch (tag) {
        case 200:
            return @"让主负";
            break;
        case 201:
            return @"让主胜";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)serverKeyOfBasketBallLetWinLoseWithTag:(NSInteger)tag {
    switch (tag) {
        case 200:
            return @"letMainLose";
            break;
        case 201:
            return @"letMainWin";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)basketBallBigSmallScoreTextWithTag:(NSInteger)tag {
    switch (tag) {
        case 300:
            return @"大分";
            break;
        case 301:
            return @"小分";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)serverKeyOfBasketBallBigSmallScoreWithTag:(NSInteger)tag {
    switch (tag) {
        case 301:
            return @"small";
            break;
        case 300:
            return @"big";
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)basketBallMinusScoreTextWithTag_3:(NSInteger)tag { //胜分差
    switch (tag) {
        case 400:
        case 402:
        case 404:
        case 406:
        case 408:
        case 410:
            return [self numToNumWithTag_2:tag Chase:YES isText:YES];
            break;
        case 401:
        case 403:
        case 405:
        case 407:
        case 409:
        case 411:
            return [self numToNumWithTag_2:tag Chase:YES isText:YES];
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)basketBallMinusScoreTextWithTag_4:(NSInteger)tag { //文字的胜分差
    switch (tag) {
        case 400:
        case 402:
        case 404:
        case 406:
        case 408:
        case 410:
            return [NSString stringWithFormat:@"客胜%@",[self numToNumWithTag_2:tag Chase:YES isText:YES]];
            break;
        case 401:
        case 403:
        case 405:
        case 407:
        case 409:
        case 411:
            return [NSString stringWithFormat:@"主胜%@",[self numToNumWithTag_2:tag Chase:YES isText:YES]];
            break;
            
        default:
            break;
    }
    return @"";
}

- (NSString *)serverKeyOfBasketBallMinusScoreWithTag_2:(NSInteger)tag { //正常的胜分差
    switch (tag) {
        case 400:
        case 401:
        case 402:
        case 403:
        case 404:
        case 405:
        case 406:
        case 407:
        case 408:
        case 409:
        case 410:
        case 411:
            return [self keyWithTag_2:tag - 400];
            break;
            
        default:
            break;
    }
    return @"";
}


- (NSString *)keyWithTag_2:(NSInteger)tag {//正常胜分差
    NSString *keyString;
    if (tag % 2 == 0) {
        keyString = @"differGuest";
    } else {
        keyString = @"differMain";
    }
    
    keyString = [NSString stringWithFormat:@"%@%@",keyString ,[self numToNumWithTag_2:tag Chase:NO isText:NO]];
    return keyString;
}

- (NSString *)numToNumWithTag_2:(NSInteger)tag Chase:(BOOL)isChase isText:(BOOL)isText {//正常的胜分差
    NSString *numToNumString = @"";
    NSInteger sign = (tag % 100) / 2;
    numToNumString = [NSString stringWithFormat:@"%@%ld",numToNumString ,(long)(sign * 5 + 1)];
    if (sign < 5) {
        numToNumString = [NSString stringWithFormat:@"%@%@%ld",numToNumString,isText ? @"-" : @"_",(long)((sign + 1) * 5)];
    } else if (isChase) {
        numToNumString = [NSString stringWithFormat:@"%@+",numToNumString];
    }
    return numToNumString;
}

- (NSString *)hasFootBallMatchSeverKeyWithTag:(NSInteger)tag {
    if (tag >= 500 && tag < 599) {
        return @"isSPF";
        
    } else if (tag >= 200 && tag < 299) {
        return @"isZJQ";
        
    } else if (tag >= 300 && tag < 399) {
        return @"isCBF";
        
    } else if (tag >= 400 && tag < 499) {
        return @"isBQC";
        
    } else if (tag >= 100 && tag < 199) {
        return @"isNewSPF";
        
    }
    return @"";
}

- (NSString *)hasBasketBallMatchSeverKeyWithTag:(NSInteger)tag {
    if (tag >= 100 && tag < 199) {
        return @"isSF";
        
    } else if (tag >= 200 && tag < 299) {
        return @"isRFSF";
        
    } else if (tag >= 300 && tag < 399) {
        return @"isDXF";
        
    } else if (tag >= 400 && tag < 499) {
        return @"isSFC";
        
    }
    return @"";
}

- (BOOL)hasMatch:(NSInteger)tag {
    if (_dialogType == DialogFootBallMix) {
        if ([[_matchDict objectForKey:[self hasFootBallMatchSeverKeyWithTag:tag]] isEqualToString:@"True"]) {
            return YES;
        } else {
            return NO;
        }
        
    } else if (_dialogType == DialogBasketBallMix) {
        if ([[_matchDict objectForKey:[self hasBasketBallMatchSeverKeyWithTag:tag]] isEqualToString:@"True"]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)setSelectBtnSelectWithArray:(NSMutableArray *)selectNumberArray {
    if (_buildedSelectView) {
        for (NSString *selectNumberString in selectNumberArray) {
            CustomizedButton *selectBtn = (CustomizedButton *)[self viewWithTag:([selectNumberString integerValue])];
            [selectBtn setSelected:YES];
        }
        _selectButton = YES;
    } else {
        _selectButton = NO;
    }
}

- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.alpha = 0;
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.transform = CGAffineTransformMakeScale(1, 1);
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void)fadeOut {
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.alpha = 0;
    [UIView commitAnimations];
    
    [_overlayView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:_overlayView];
    [keyWindow addSubview:self];
    
    [self setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
    [self fadeIn];
}

#pragma mark -Customized: Private ()
- (void)setSelectMatchTextWithTextArray:(NSMutableArray *)textArray {
    [textArray removeAllObjects];
    if (_dialogType == DialogFootBallScore) {
        for (NSString *numberString in _selectMatchNumberArray) {
            [textArray addObject:[self textWithFootBallNumber:[numberString integerValue] + 300 - 1]];
        }
    } else if (_dialogType == DialogFootBallTotalGoal) {
        for (NSString *numberString in _selectMatchNumberArray) {
            [textArray addObject:[self textWithFootBallNumber:[numberString integerValue] + 200 - 1]];
        }
    } else if (_dialogType == DialogFootBallHalf) {
        for (NSString *numberString in _selectMatchNumberArray) {
            [textArray addObject:[self textWithFootBallNumber:[numberString integerValue] + 400 - 1]];
        }
    } else if(_dialogType == DialogFootBallMix) {
        for (NSString *numberString in _selectMatchNumberArray) {
            [textArray addObject:[self textWithFootBallNumber:[numberString integerValue]]];
        }
    } else if (_dialogType == DialogBasketBallMinusScore) {
        for (NSString *numberString in _selectMatchNumberArray) {
            [textArray addObject:[self textWithBasketBallNumber:[numberString integerValue] + 400 - 1]];
        }
    } else if (_dialogType == DialogBasketBallMix) {
        for (NSString *numberString in _selectMatchNumberArray) {
            [textArray addObject:[self textWithBasketBallNumber:[numberString integerValue]]];
        }
    }
    
}

@end
