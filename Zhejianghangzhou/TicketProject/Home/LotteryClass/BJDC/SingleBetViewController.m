//
//  SingleBetViewController.m 购彩大厅－竞彩足球投注
//  TicketProject
//
//  Created by sls002 on 13-7-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140811 10:44（洪晓彬）：修改代码规范，改进生命周期
//20140811 11:21（洪晓彬）：进行ipad适配

#import "SingleBetViewController.h"
#import "BetTableViewCell.h"
#import "CustomBetViewCell.h"
#import "CustomBottomView.h"
#import "CalculateBetCount.h"
#import "CustomFootBallZJQButton.h"
#import "DialogSelectButtonView.h"
#import "BetRuleViewController.h"

#import "ASIFormDataRequest.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "JSONKit.h"
#import "UserInfo.h"
#import "PassWayUtility.h"
#import "PaySucceedViewController.h"
#import "UserLoginViewController.h"
#import "LaunchChippedViewController.h"
#import "XFNavigationViewController.h"

#import "SingleViewController.h"
#import "RechargeViewController.h"

#import "Globals.h"
#import "DuangAlert.h"

#define kInputViewHeight (IS_PHONE ? 45.0f : 60.0f)

#define SingleBetViewCellHeight (IS_PHONE ? 90.0f : 150.0f)

#define kTableViewFootViewHeight (IS_PHONE ? 53.0f : 60.0f)
#define tableCellHeihgt (IS_PHONE ? 44.0f : 66.0f)
#define tableCellLabelHeight (IS_PHONE ? 20.0f : 30.0f)
#define tabelCellLabelImageInterval (IS_PHONE ? 5.0f : 8.0f)

@interface SingleBetViewController ()
@property(nonatomic,copy)NSString *allstr;
@end

#pragma mark -
#pragma mark @implementation SingleBetViewController
@implementation SingleBetViewController
#pragma mark Lifecircle

- (id)initWithMatchArray:(NSMutableArray *)matchArray andScoreDic:(NSMutableDictionary *)scoreDic {
    self = [super init];
    if(self) {
        self.selectMatchArray = matchArray;
        self.selectedScoreDic = scoreDic;
        self.title = @"北京单场投注";
        
    }
    
    return self;
}

- (void)dealloc {
    _betTableView = nil;
    _inputView = nil;
    _passWayBtn = nil;
    _inputField = nil;
    _bottomView = nil;
    _secrecyLevel = nil;
    _description = nil;
    
    _overlayView = nil;
    
    [_launchChippedProportionRequest release];
    _launchChippedProportionRequest = nil;;
    
    [_selectArray release];
    [_selectMatchArray release];
    [_selectNormalArray release];
    [_selectDanArray release];
    [_selectDanInfoArray release];
    [_passWayArray release];
    [_passWayTagArray release];
    [_selectHalfDict release];
    [_orderDetailDict release];
    _orderDetailDict = nil;
    
    [maxArray release];
    [minArray release];
    [maxNumberArray release];
    [minNumberArray release];
    
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
    CGFloat topBtnMinY = IS_PHONE ? 10.0f : 20.0f;
    CGFloat topBtnWidht = 300.0f;
    CGFloat topBtnHeight = IS_PHONE ? 32.5f : 50.0f;
    
    CGFloat topBtnBetTableViewLandscapeInterval = IS_PHONE ? 12.0f : 24.0f;
    
    CGFloat inputViewTouPromptLabelCenterMinX = 10.0f;
    CGFloat inputViewPromptLabelWidth = IS_PHONE ? 20.0f : 30.0f;
    CGFloat inputViewPassWayBtnHeight = IS_PHONE ? 28.0f : 40.0f;
    
    CGFloat touPromptLabelMinX = self.view.center.x + inputViewTouPromptLabelCenterMinX;
    CGFloat touPromptLabelInputFieldLandscapeInterval = IS_PHONE ? 10.0f : 20.0f;
    CGFloat inputFieldWidth = IS_PHONE ? 80.0f : 160.0f;
    CGFloat lineImageViewWidth = IS_PHONE ? 1.0f : 2.0f;
    /********************** adjustment end ***************************/
    
    //topBtn
    CGRect topBtnRect = CGRectMake((CGRectGetWidth(appRect) - topBtnWidht) / 2.0f, topBtnMinY, topBtnWidht, topBtnHeight);
    UIButton *topBtn = [[UIButton alloc] initWithFrame:topBtnRect];
    [topBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [topBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topBtn setAdjustsImageWhenHighlighted:NO];
    [topBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"continueSelectMatch.png"]] forState:UIControlStateNormal];
    [topBtn addTarget:self action:@selector(goonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBtn];
    [topBtn release];
    
    //betTableView
    CGRect betTableViewRect = CGRectMake(0, CGRectGetMaxY(topBtnRect) + topBtnBetTableViewLandscapeInterval, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - (CGRectGetMaxY(topBtnRect) + topBtnBetTableViewLandscapeInterval) - kInputViewHeight - kBottomHeight -44);
    _betTableView = [[UITableView alloc]initWithFrame:betTableViewRect style:UITableViewStylePlain];
    [_betTableView setBackgroundColor:kBackgroundColor];
    [_betTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_betTableView setDataSource:self];
    [_betTableView setDelegate:self];
    [self.view addSubview:_betTableView];
    [_betTableView release];
    
    //inputView
    CGRect inputViewRect =CGRectMake(0, self.view.bounds.size.height - 44.0f - kBottomHeight - kInputViewHeight, CGRectGetWidth(appRect), kInputViewHeight);
    _inputView = [[UIView alloc]initWithFrame:inputViewRect];
    [_inputView setBackgroundColor:[UIColor colorWithRed:0xf1/255.0f green:0xf1/255.0f blue:0xf1/255.0f alpha:1.0f]];
    [self.view addSubview:_inputView];
    [_inputView release];
        
    //passWayBtn
    CGRect passWayBtnRect = CGRectMake(0, 0, CGRectGetWidth(appRect) / 2.0f, CGRectGetHeight(inputViewRect));
    _passWayBtn = [[UIButton alloc] initWithFrame:passWayBtnRect];
    [_passWayBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_passWayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_passWayBtn setTitleColor:kYellowColor forState:UIControlStateHighlighted];
    [_passWayBtn setTitle:_SinglePassBarrierType == SinglePassBarrierType_singleMacth ? @"单关" : @"过关方式(必选)" forState:UIControlStateNormal];
    [_passWayBtn addTarget:self action:@selector(selectPassWay:) forControlEvents:UIControlEventTouchUpInside];
    [_passWayBtn setEnabled: _SinglePassBarrierType == SinglePassBarrierType_moreMatch];
    [_inputView addSubview:_passWayBtn];
    [_passWayBtn release];
    
    CGRect lineImageViewRect = CGRectMake(CGRectGetMaxX(passWayBtnRect), 0, lineImageViewWidth, CGRectGetHeight(_inputView.frame));
    UIView *lineView = [[UIView alloc] initWithFrame:lineImageViewRect];
    [lineView setBackgroundColor:[UIColor whiteColor]];
    [_inputView addSubview:lineView];
    [lineView release];
    
    //touPromptLabel
    CGRect touPromptLabelRect = CGRectMake(touPromptLabelMinX, CGRectGetMinY(passWayBtnRect), inputViewPromptLabelWidth, CGRectGetHeight(passWayBtnRect));
    UILabel *touPromptLabel = [[UILabel alloc]initWithFrame:touPromptLabelRect];
    [touPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [touPromptLabel setText:@"投"];
    [touPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_inputView addSubview:touPromptLabel];
    [touPromptLabel release];
    
    //inputField
    CGRect inputFieldRect = CGRectMake(CGRectGetMaxX(touPromptLabelRect) + touPromptLabelInputFieldLandscapeInterval, (kInputViewHeight - inputViewPassWayBtnHeight) / 2.0f, inputFieldWidth, inputViewPassWayBtnHeight);
    UIImageView *inputFieldBackImageView = [[UIImageView alloc] initWithFrame:inputFieldRect];
    [inputFieldBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f]];
    [_inputView addSubview:inputFieldBackImageView];
    [inputFieldBackImageView release];
    
    _inputField = [[UITextField alloc]initWithFrame:inputFieldRect];
    [_inputField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_inputField setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_inputField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_inputField setTextAlignment:NSTextAlignmentCenter];
    [_inputField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_inputField setText:@"1"];
    [_inputField setPlaceholder:@"1倍"];
    [_inputField setDelegate:self];
    [_inputView addSubview:_inputField];
    [_inputField release];
    
    //beiPromptLabel
    CGRect beiPromptLabelRect = CGRectMake(CGRectGetMaxX(inputFieldRect) + touPromptLabelInputFieldLandscapeInterval, CGRectGetMinY(passWayBtnRect), inputViewPromptLabelWidth, CGRectGetHeight(passWayBtnRect));
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
    
    
    //chippedBtn
    UIButton *chippedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chippedBtn setTitle:@"发起复制" forState:UIControlStateNormal];
    [chippedBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [chippedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [chippedBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [chippedBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [chippedBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView setLeftButton:chippedBtn];
    
    CGRect checkBtnRect = CGRectMake(CGRectGetMaxX(chippedBtn.frame)+5, chippedBtn.frame.origin.y, chippedBtn.frame.size.height, chippedBtn.frame.size.height);
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton_Normal.png"]] forState:UIControlStateNormal];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
    checkBtn.tag = 10086;
    [checkBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:checkBtn];
    [checkBtn release];
    
    //payBtn
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setTitle:@"付款" forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [payBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView setRightButton:payBtn];
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
    
    maxArray       = [[NSMutableArray alloc] init];
    minArray       = [[NSMutableArray alloc] init];
    maxNumberArray = [[NSMutableArray alloc] init];
    minNumberArray = [[NSMutableArray alloc] init];
    
    _orderDetailDict = [[NSMutableDictionary alloc] init];
    [self updateBottomView];
    
    [self setMatchDate];
    [self zhuiQiSelected:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
    if (_launchChippedProportionRequest) {
        [_launchChippedProportionRequest clearDelegatesAndCancel];
    }

    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    //监听键盘出现和消失的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    isSeceltPaly = YES;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 预测奖金数据处理
- (void)setMatchDate {
    [maxArray removeAllObjects];
    [minArray removeAllObjects];
    [maxNumberArray removeAllObjects];
    [minNumberArray removeAllObjects];
    
    NSInteger selectTypes = 0;
    NSString  *numberString = [NSString string];
    
    for (int i = 0; i < self.selectMatchArray.count; i++) {
        NSDictionary *dic = [self.selectMatchArray objectAtIndex:i];      //选中对阵的所有信息字典
        NSArray      *array = [dic objectForKey:@"selectArray"];          //选择的赛果数组
        NSDictionary *selectRowDic = [dic objectForKey:@"selectRowDic"];  //该场对阵的赔率字典
        selectTypes = [[dic objectForKey:@"selectType"] integerValue];    //该场比赛选择的玩法
        
        NSMutableArray *aArray = [NSMutableArray array];
        
        for (int j = 0; j < array.count; j++) {
            NSInteger result = [[array objectAtIndex:j] integerValue];
            
            if (selectTypes == 0) {
                if (result == 1) {
                    numberString = [selectRowDic objectForKey:@"shangDanSP"];
                    
                } else if (result == 2) {
                    numberString = [selectRowDic objectForKey:@"shangShuangSP"];
                    
                } else if (result == 3) {
                    numberString = [selectRowDic objectForKey:@"xiaDanSP"];
                    
                } else {
                    numberString = [selectRowDic objectForKey:@"xiaShuangSP"];
                }
            } else if (selectTypes == 1) {
                if (result == 1) {
                    numberString = [selectRowDic objectForKey:@"winSp"];
                    
                } else if (result == 2) {
                    numberString = [selectRowDic objectForKey:@"flatSp"];
                    
                } else {
                    numberString = [selectRowDic objectForKey:@"loseSp"];
                }
            } else if (selectTypes == 2) {
                switch (result) {
                    case 1:
                        numberString = [selectRowDic objectForKey:@"bfWin10Sp"];
                        break;
                    case 2:
                        numberString = [selectRowDic objectForKey:@"bfWin20Sp"];
                        break;
                    case 3:
                        numberString = [selectRowDic objectForKey:@"bfWin21Sp"];
                        break;
                    case 4:
                        numberString = [selectRowDic objectForKey:@"bfWin30Sp"];
                        break;
                    case 5:
                        numberString = [selectRowDic objectForKey:@"bfWin31Sp"];
                        break;
                    case 6:
                        numberString = [selectRowDic objectForKey:@"bfWin32Sp"];
                        break;
                    case 7:
                        numberString = [selectRowDic objectForKey:@"bfWin40Sp"];
                        break;
                    case 8:
                        numberString = [selectRowDic objectForKey:@"bfWin41Sp"];
                        break;
                    case 9:
                        numberString = [selectRowDic objectForKey:@"bfWin42Sp"];
                        break;
                    case 10:
                        numberString = [selectRowDic objectForKey:@"bfWinSqtSp"];
                        break;
                    case 11:
                        numberString = [selectRowDic objectForKey:@"bfFlat00Sp"];
                        break;
                    case 12:
                        numberString = [selectRowDic objectForKey:@"bfFlat11Sp"];
                        break;
                    case 13:
                        numberString = [selectRowDic objectForKey:@"bfFlat22Sp"];
                        break;
                    case 14:
                        numberString = [selectRowDic objectForKey:@"bfFlat33Sp"];
                        break;
                    case 15:
                        numberString = [selectRowDic objectForKey:@"bfFlatPqtSp"];
                        break;
                    case 16:
                        numberString = [selectRowDic objectForKey:@"bfLose01Sp"];
                        break;
                    case 17:
                        numberString = [selectRowDic objectForKey:@"bfLose02Sp"];
                        break;
                    case 18:
                        numberString = [selectRowDic objectForKey:@"bfLose12Sp"];
                        break;
                    case 19:
                        numberString = [selectRowDic objectForKey:@"bfLose03Sp"];
                        break;
                    case 20:
                        numberString = [selectRowDic objectForKey:@"bfLose13Sp"];
                        break;
                    case 21:
                        numberString = [selectRowDic objectForKey:@"bfLose23Sp"];
                        break;
                    case 22:
                        numberString = [selectRowDic objectForKey:@"bfLose04Sp"];
                        break;
                    case 23:
                        numberString = [selectRowDic objectForKey:@"bfLose14Sp"];
                        break;
                    case 24:
                        numberString = [selectRowDic objectForKey:@"bfLose24Sp"];
                        break;
                    case 25:
                        numberString = [selectRowDic objectForKey:@"bfLoseFqtSp"];
                        break;
                        
                    default:
                        break;
                }
            } else if (selectTypes == 3) {
                switch (result) {
                    case 1:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",0]];
                        break;
                    case 2:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",1]];
                        break;
                    case 3:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",2]];
                        break;
                    case 4:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",3]];
                        break;
                    case 5:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",4]];
                        break;
                    case 6:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",5]];
                        break;
                    case 7:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",6]];
                        break;
                    case 8:
                        numberString = [selectRowDic objectForKey:[NSString stringWithFormat:@"zjq%d",7]];
                        break;
                        
                    default:
                        break;
                }
            } else if (selectTypes == 4) {
                switch (result) {
                    case 1:
                        numberString = [selectRowDic objectForKey:@"bqcSsSp"];
                        break;
                    case 2:
                        numberString = [selectRowDic objectForKey:@"bqcSpSp"];
                        break;
                    case 3:
                        numberString = [selectRowDic objectForKey:@"bqcSfSp"];
                        break;
                    case 4:
                        numberString = [selectRowDic objectForKey:@"bqcPsSp"];
                        break;
                    case 5:
                        numberString = [selectRowDic objectForKey:@"bqcPpSp"];
                        break;
                    case 6:
                        numberString = [selectRowDic objectForKey:@"bqcPfSp"];
                        break;
                    case 7:
                        numberString = [selectRowDic objectForKey:@"bqcFsSp"];
                        break;
                    case 8:
                        numberString = [selectRowDic objectForKey:@"bqcFpSp"];
                        break;
                    case 9:
                        numberString = [selectRowDic objectForKey:@"bqcFfSp"];
                        break;
                        
                    default:
                        break;
                }
            }
            
            [aArray addObject:numberString];
        }
        
        NSNumber *max = [aArray valueForKeyPath:@"@max.floatValue"];
        NSNumber *min = [aArray valueForKeyPath:@"@min.floatValue"];
        
        [maxArray addObject:[NSString stringWithFormat:@"%@",max]];
        [minArray addObject:[NSString stringWithFormat:@"%@",min]];
    }
    
    for (NSString *str in _passWayArray) {
        if ([str isEqualToString:@"单关"]) {
            NSNumber *sum = [maxArray valueForKeyPath:@"@sum.floatValue"];
            NSNumber *min1 = [minArray valueForKeyPath:@"@min.floatValue"];
            [minNumberArray addObject:[NSString stringWithFormat:@"%@",min1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%@",sum]];
            
        } else if ([str isEqualToString:@"2串1"]) {
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min2Number]]];
            
        } else if ([str isEqualToString:@"2串3"]) { // 2个一关
            NSNumber *sum = [maxArray valueForKeyPath:@"@sum.floatValue"];
            NSNumber *min = [minArray valueForKeyPath:@"@min.floatValue"];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[sum floatValue] * (maxArray.count - 1)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[min floatValue] * (minArray.count - 1)]];
            
        } else if ([str isEqualToString:@"3串1"]) {
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min3Number]]];
            
        } else if ([str isEqualToString:@"3串4"]) { //3个两关 + 1个三关
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * (maxArray.count - 2)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min2Number] * (minArray.count - 2)]];
            
        } else if ([str isEqualToString:@"3串7"]) { //3个一关 + 3个两关 + 1个三关
            NSInteger beishu = [CalculateBetCount combinationWithM:maxArray.count - 1 N:2];
            NSNumber *sum = [maxArray valueForKeyPath:@"@sum.floatValue"];
            NSNumber *min = [minArray valueForKeyPath:@"@min.floatValue"];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[sum floatValue] * beishu]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * (maxArray.count - 2)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[min floatValue] * beishu]];
            
        } else if ([str isEqualToString:@"4串1"]) {
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min4Number]]];
            
        } else if ([str isEqualToString:@"4串5"]) { //4个三关 + 1个四关
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * (maxArray.count - 3)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min3Number] * (minArray.count - 3)]];
            
        } else if ([str isEqualToString:@"4串11"]) { //6个两关 + 4个三关 + 1个四关
            NSInteger n = maxArray.count - 3;
            NSInteger beishu = n * (n+1) / 2;
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * beishu]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * (maxArray.count - 3)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min2Number] * beishu]];
            
        } else if ([str isEqualToString:@"4串15"]) { //4个一关 + 6个两关 + 4个三关 + 1个四关
            NSInteger n = maxArray.count - 3;
            NSInteger beishu = n * (n+1) / 2;
            NSInteger beishu_1x1 = [CalculateBetCount combinationWithM:maxArray.count - 1 N:3];
            NSNumber *sum = [maxArray valueForKeyPath:@"@sum.floatValue"];
            NSNumber *min = [minArray valueForKeyPath:@"@min.floatValue"];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[sum floatValue] * beishu_1x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * beishu]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * (maxArray.count - 3)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[min floatValue] * beishu_1x1]];
            
        } else if ([str isEqualToString:@"5串1"]) {
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min5Number]]];
            
        } else if ([str isEqualToString:@"5串6"]) { //5个四关 + 1个五关
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * (maxArray.count - 4)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min4Number] * (minArray.count - 4)]];
            
        } else if ([str isEqualToString:@"5串16"]) { //10个三关 + 5个四关 + 1个五关
            NSInteger n = maxArray.count - 4;
            NSInteger beishu = n * (n + 1) / 2;
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * beishu]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * n]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min3Number] * beishu]];
            
        } else if ([str isEqualToString:@"5串26"]) { //10个两关 + 10个三关 + 5个四关 + 1个五关
            NSInteger n = maxArray.count - 4;
            NSInteger beishu = n * (n + 1) * (n + 2) / 6;
            NSInteger beishm = n * (n + 1) / 2;
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * beishu]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * beishm]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * (maxArray.count - 4)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min2Number] * beishu]];
            
        } else if ([str isEqualToString:@"5串31"]) { //5个一关 + 10个两关 + 10个三关 + 5个四关 + 1个五关
            NSInteger n = maxArray.count - 4;
            NSInteger beishu = n * (n + 1) * (n + 2) / 6;
            NSInteger beishm = n * (n + 1) / 2;
            NSInteger beishu_1x1 = [CalculateBetCount combinationWithM:maxArray.count - 1 N:4];
            NSNumber *sum = [maxArray valueForKeyPath:@"@sum.floatValue"];
            NSNumber *min = [minArray valueForKeyPath:@"@min.floatValue"];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[sum floatValue] * beishu_1x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * beishu]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * beishm]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * (maxArray.count - 4)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[min floatValue] * beishu_1x1]];
            
        } else if ([str isEqualToString:@"6串1"]) {
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max6Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min6Number]]];
            
        } else if ([str isEqualToString:@"6串7"]) { //6个五关 + 1个六关
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number] * (maxArray.count - 5)]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max6Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min5Number] * (minArray.count - 5)]];
            
        } else if ([str isEqualToString:@"6串22"]) { //15个四关 + 6个五关 + 1个六关
            NSInteger n = maxArray.count - 5;
            NSInteger beishu_4x1 = n * (n + 1) / 2;
            NSInteger beishu_5x1 = maxArray.count - 5;
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * beishu_4x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number] * beishu_5x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max6Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min4Number] * beishu_4x1]];
            
        } else if ([str isEqualToString:@"6串42"]) { //20个三关 + 15个四关 + 6个五关 + 1个六关
            NSInteger n = maxArray.count - 5;
            NSInteger beishu_4x1 = n * (n + 1) / 2;
            NSInteger beishu_5x1 = maxArray.count - 5;
            NSInteger beishu_3x1 = [CalculateBetCount combinationWithM:maxArray.count - 3 N:3];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * beishu_3x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * beishu_4x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number] * beishu_5x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max6Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min3Number] * beishu_3x1]];
            
        } else if ([str isEqualToString:@"6串57"]) { //15个两关 + 20个三关 + 15个四关 + 6个五关 + 1个六关
            NSInteger n = maxArray.count - 5;
            NSInteger beishu_4x1 = n * (n + 1) / 2;
            NSInteger beishu_5x1 = maxArray.count - 5;
            NSInteger beishu_3x1 = [CalculateBetCount combinationWithM:maxArray.count - 3 N:3];
            NSInteger beishu_2x1 = [CalculateBetCount combinationWithM:maxArray.count - 2 N:4];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * beishu_2x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * beishu_3x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * beishu_4x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number] * beishu_5x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max6Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self min2Number] * beishu_2x1]];
            
        } else if ([str isEqualToString:@"6串63"]) { //6个一关 + 15个两关 + 20个三关 + 15个四关 + 6个五关 + 1个六关
            NSInteger n = maxArray.count - 5;
            NSInteger beishu_4x1 = n * (n + 1) / 2;
            NSInteger beishu_5x1 = maxArray.count - 5;
            NSInteger beishu_3x1 = [CalculateBetCount combinationWithM:maxArray.count - 3 N:3];
            NSInteger beishu_2x1 = [CalculateBetCount combinationWithM:maxArray.count - 2 N:4];
            NSInteger beishu_1x1 = [CalculateBetCount combinationWithM:maxArray.count - 1 N:5];
            NSNumber *sum = [maxArray valueForKeyPath:@"@sum.floatValue"];
            NSNumber *min = [minArray valueForKeyPath:@"@min.floatValue"];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[sum floatValue] * beishu_1x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max2Number] * beishu_2x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max3Number] * beishu_3x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max4Number] * beishu_4x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max5Number] * beishu_5x1]];
            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",[self max6Number]]];
            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",[min floatValue] * beishu_1x1]];
            
        } else if ([str isEqualToString:@"7串1"]) {
            for (int a = 0; a < maxArray.count - 6; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 5; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 4; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 3; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 2; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 1; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue];
                                        CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue];
                                        
                                        [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                        [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"8串1"]) {
            for (int a = 0; a < maxArray.count - 7; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 6; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 5; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 4; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 3; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 2; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 1; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue];
                                            CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue];
                                            
                                            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"9串1"]) {
            for (int a = 0; a < maxArray.count - 8; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 7; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 6; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 5; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 4; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 3; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 2; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 1; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue];
                                                CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue];
                                                
                                                [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"10串1"]) {
            for (int a = 0; a < maxArray.count - 9; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 8; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 7; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 6; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 5; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 4; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 3; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 2; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count - 1; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                for (int j = i + 1; j < maxArray.count; j++) {
                                                    NSString *maxStr10 = [maxArray objectAtIndex:j];
                                                    NSString *minStr10 = [minArray objectAtIndex:j];
                                                    
                                                    CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue] * [maxStr10 floatValue];
                                                    CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue] * [minStr10 floatValue];
                                                    
                                                    [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                    [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"11串1"]) {
            for (int a = 0; a < maxArray.count - 10; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 9; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 8; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 7; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 6; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 5; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 4; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 3; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count - 2; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                for (int j = i + 1; j < maxArray.count - 1; j++) {
                                                    NSString *maxStr10 = [maxArray objectAtIndex:j];
                                                    NSString *minStr10 = [minArray objectAtIndex:j];
                                                    
                                                    for (int k = j + 1; k < maxArray.count; k++) {
                                                        NSString *maxStr11 = [maxArray objectAtIndex:k];
                                                        NSString *minStr11 = [minArray objectAtIndex:k];
                                                        
                                                        CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue] * [maxStr10 floatValue] * [maxStr11 floatValue];
                                                        CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue] * [minStr10 floatValue] * [minStr11 floatValue];
                                                        
                                                        [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                        [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"12串1"]) {
            for (int a = 0; a < maxArray.count - 11; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 10; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 9; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 8; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 7; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 6; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 5; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 4; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count - 3; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                for (int j = i + 1; j < maxArray.count - 2; j++) {
                                                    NSString *maxStr10 = [maxArray objectAtIndex:j];
                                                    NSString *minStr10 = [minArray objectAtIndex:j];
                                                    
                                                    for (int k = j + 1; k < maxArray.count - 1; k++) {
                                                        NSString *maxStr11 = [maxArray objectAtIndex:k];
                                                        NSString *minStr11 = [minArray objectAtIndex:k];
                                                        
                                                        for (int l = k + 1; l < maxArray.count; l++) {
                                                            NSString *maxStr12 = [maxArray objectAtIndex:l];
                                                            NSString *minStr12 = [minArray objectAtIndex:l];
                                                            
                                                            CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue] * [maxStr10 floatValue] * [maxStr11 floatValue] * [maxStr12 floatValue];
                                                            CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue] * [minStr10 floatValue] * [minStr11 floatValue] * [minStr12 floatValue];
                                                            
                                                            [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                            [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"13串1"]) {
            for (int a = 0; a < maxArray.count - 12; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 11; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 10; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 9; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 8; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 7; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 6; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 5; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count - 4; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                for (int j = i + 1; j < maxArray.count - 3; j++) {
                                                    NSString *maxStr10 = [maxArray objectAtIndex:j];
                                                    NSString *minStr10 = [minArray objectAtIndex:j];
                                                    
                                                    for (int k = j + 1; k < maxArray.count - 2; k++) {
                                                        NSString *maxStr11 = [maxArray objectAtIndex:k];
                                                        NSString *minStr11 = [minArray objectAtIndex:k];
                                                        
                                                        for (int l = k + 1; l < maxArray.count - 1; l++) {
                                                            NSString *maxStr12 = [maxArray objectAtIndex:l];
                                                            NSString *minStr12 = [minArray objectAtIndex:l];
                                                            
                                                            for (int m = l + 1; m < maxArray.count; m++) {
                                                                NSString *maxStr13 = [maxArray objectAtIndex:m];
                                                                NSString *minStr13 = [minArray objectAtIndex:m];
                                                                
                                                                CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue] * [maxStr10 floatValue] * [maxStr11 floatValue] * [maxStr12 floatValue] * [maxStr13 floatValue];
                                                                CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue] * [minStr10 floatValue] * [minStr11 floatValue] * [minStr12 floatValue] * [minStr13 floatValue];
                                                                
                                                                [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                                [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"14串1"]) {
            for (int a = 0; a < maxArray.count - 13; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 12; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 11; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 10; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 9; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 8; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 7; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 6; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count - 5; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                for (int j = i + 1; j < maxArray.count - 4; j++) {
                                                    NSString *maxStr10 = [maxArray objectAtIndex:j];
                                                    NSString *minStr10 = [minArray objectAtIndex:j];
                                                    
                                                    for (int k = j + 1; k < maxArray.count - 3; k++) {
                                                        NSString *maxStr11 = [maxArray objectAtIndex:k];
                                                        NSString *minStr11 = [minArray objectAtIndex:k];
                                                        
                                                        for (int l = k + 1; l < maxArray.count - 2; l++) {
                                                            NSString *maxStr12 = [maxArray objectAtIndex:l];
                                                            NSString *minStr12 = [minArray objectAtIndex:l];
                                                            
                                                            for (int m = l + 1; m < maxArray.count - 1; m++) {
                                                                NSString *maxStr13 = [maxArray objectAtIndex:m];
                                                                NSString *minStr13 = [minArray objectAtIndex:m];
                                                                
                                                                for (int n = m + 1; n < maxArray.count; n++) {
                                                                    NSString *maxStr14 = [maxArray objectAtIndex:m];
                                                                    NSString *minStr14 = [minArray objectAtIndex:m];
                                                                    
                                                                    CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue] * [maxStr10 floatValue] * [maxStr11 floatValue] * [maxStr12 floatValue] * [maxStr13 floatValue] * [maxStr14 floatValue];
                                                                    CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue] * [minStr10 floatValue] * [minStr11 floatValue] * [minStr12 floatValue] * [minStr13 floatValue] * [minStr14 floatValue];
                                                                    
                                                                    [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                                    [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if ([str isEqualToString:@"15串1"]) {
            for (int a = 0; a < maxArray.count - 14; a++) {
                NSString *maxStr1 = [maxArray objectAtIndex:a];
                NSString *minStr1 = [minArray objectAtIndex:a];
                
                for (int b = a + 1; b < maxArray.count - 13; b++) {
                    NSString *maxStr2 = [maxArray objectAtIndex:b];
                    NSString *minStr2 = [minArray objectAtIndex:b];
                    
                    for (int c = b + 1; c < maxArray.count - 12; c++) {
                        NSString *maxStr3 = [maxArray objectAtIndex:c];
                        NSString *minStr3 = [minArray objectAtIndex:c];
                        
                        for (int d = c + 1; d < maxArray.count - 11; d ++) {
                            NSString *maxStr4 = [maxArray objectAtIndex:d];
                            NSString *minStr4 = [minArray objectAtIndex:d];
                            
                            for (int e = d + 1; e < maxArray.count - 10; e++) {
                                NSString *maxStr5 = [maxArray objectAtIndex:e];
                                NSString *minStr5 = [minArray objectAtIndex:e];
                                
                                for (int f = e + 1; f < maxArray.count - 9; f++) {
                                    NSString *maxStr6 = [maxArray objectAtIndex:f];
                                    NSString *minStr6 = [minArray objectAtIndex:f];
                                    
                                    for (int g = f + 1; g < maxArray.count - 8; g++) {
                                        NSString *maxStr7 = [maxArray objectAtIndex:g];
                                        NSString *minStr7 = [minArray objectAtIndex:g];
                                        
                                        for (int h = g + 1; h < maxArray.count - 7; h++) {
                                            NSString *maxStr8 = [maxArray objectAtIndex:h];
                                            NSString *minStr8 = [minArray objectAtIndex:h];
                                            
                                            for (int i = h + 1; i < maxArray.count - 6; i++) {
                                                NSString *maxStr9 = [maxArray objectAtIndex:i];
                                                NSString *minStr9 = [minArray objectAtIndex:i];
                                                
                                                for (int j = i + 1; j < maxArray.count - 5; j++) {
                                                    NSString *maxStr10 = [maxArray objectAtIndex:j];
                                                    NSString *minStr10 = [minArray objectAtIndex:j];
                                                    
                                                    for (int k = j + 1; k < maxArray.count - 4; k++) {
                                                        NSString *maxStr11 = [maxArray objectAtIndex:k];
                                                        NSString *minStr11 = [minArray objectAtIndex:k];
                                                        
                                                        for (int l = k + 1; l < maxArray.count - 3; l++) {
                                                            NSString *maxStr12 = [maxArray objectAtIndex:l];
                                                            NSString *minStr12 = [minArray objectAtIndex:l];
                                                            
                                                            for (int m = l + 1; m < maxArray.count - 2; m++) {
                                                                NSString *maxStr13 = [maxArray objectAtIndex:m];
                                                                NSString *minStr13 = [minArray objectAtIndex:m];
                                                                
                                                                for (int n = m + 1; n < maxArray.count - 1; n++) {
                                                                    NSString *maxStr14 = [maxArray objectAtIndex:m];
                                                                    NSString *minStr14 = [minArray objectAtIndex:m];
                                                                    
                                                                    for (int o = n + 1; o < maxArray.count; o++) {
                                                                        NSString *maxStr15 = [maxArray objectAtIndex:m];
                                                                        NSString *minStr15 = [minArray objectAtIndex:m];
                                                                        
                                                                        CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue] * [maxStr7 floatValue] * [maxStr8 floatValue] * [maxStr9 floatValue] * [maxStr10 floatValue] * [maxStr11 floatValue] * [maxStr12 floatValue] * [maxStr13 floatValue] * [maxStr14 floatValue] * [maxStr15 floatValue];
                                                                        CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue] * [minStr7 floatValue] * [minStr8 floatValue] * [minStr9 floatValue] * [minStr10 floatValue] * [minStr11 floatValue] * [minStr12 floatValue] * [minStr13 floatValue] * [minStr14 floatValue] * [minStr15 floatValue];
                                                                        
                                                                        [maxNumberArray addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                                                                        [minNumberArray addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

//2窜1
- (float)max2Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < maxArray.count - 1; a++) {
        NSString *maxStr1 = [maxArray objectAtIndex:a];
        
        for (int b = a + 1; b < maxArray.count; b++) {
            NSString *maxStr2 = [maxArray objectAtIndex:b];
            
            CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue];
            [array addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
        }
    }
    
    NSNumber *sum = [array valueForKeyPath:@"@sum.floatValue"];
    
    return [sum floatValue];
}

- (float)min2Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < minArray.count - 1; a++) {
        NSString *minStr1 = [minArray objectAtIndex:a];
        
        for (int b = a + 1; b < minArray.count; b++) {
            NSString *minStr2 = [minArray objectAtIndex:b];
            
            CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue];
            [array addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
        }
    }
    
    NSNumber *min = [array valueForKeyPath:@"@min.floatValue"];
    
    return [min floatValue];
}

//3窜1
- (float)max3Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < maxArray.count - 2; a++) {
        NSString *maxStr1 = [maxArray objectAtIndex:a];
        
        for (int b = a + 1; b < maxArray.count - 1; b++) {
            NSString *maxStr2 = [maxArray objectAtIndex:b];
            
            for (int c = b + 1; c < maxArray.count; c++) {
                NSString *maxStr3 = [maxArray objectAtIndex:c];
                
                CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue];
                [array addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
            }
        }
    }
    
    NSNumber *sum = [array valueForKeyPath:@"@sum.floatValue"];
    
    return [sum floatValue];
}

- (float)min3Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < minArray.count - 2; a++) {
        NSString *minStr1 = [minArray objectAtIndex:a];
        
        for (int b = a + 1; b < minArray.count - 1; b++) {
            NSString *minStr2 = [minArray objectAtIndex:b];
            
            for (int c = b + 1; c < minArray.count; c++) {
                NSString *minStr3 = [minArray objectAtIndex:c];
                
                CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue];
                [array addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
            }
        }
    }
    
    NSNumber *min = [array valueForKeyPath:@"@min.floatValue"];
    
    return [min floatValue];
}

//4窜1
- (float)max4Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < maxArray.count - 3; a++) {
        NSString *maxStr1 = [maxArray objectAtIndex:a];
        
        for (int b = a + 1; b < maxArray.count - 2; b++) {
            NSString *maxStr2 = [maxArray objectAtIndex:b];
            
            for (int c = b + 1; c < maxArray.count - 1; c++) {
                NSString *maxStr3 = [maxArray objectAtIndex:c];
                
                for (int d = c + 1; d < maxArray.count; d++) {
                    NSString *maxStr4 = [maxArray objectAtIndex:d];
                    
                    CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue];
                    [array addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                }
            }
        }
    }
    
    NSNumber *sum = [array valueForKeyPath:@"@sum.floatValue"];
    
    return [sum floatValue];
}

- (float)min4Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < minArray.count - 3; a++) {
        NSString *minStr1 = [minArray objectAtIndex:a];
        
        for (int b = a + 1; b < minArray.count - 2; b++) {
            NSString *minStr2 = [minArray objectAtIndex:b];
            
            for (int c = b + 1; c < minArray.count - 1; c++) {
                NSString *minStr3 = [minArray objectAtIndex:c];
                
                for (int d = c + 1; d < minArray.count; d++) {
                    NSString *minStr4 = [minArray objectAtIndex:d];
                    
                    CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue];
                    [array addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                }
            }
        }
    }
    
    NSNumber *min = [array valueForKeyPath:@"@min.floatValue"];
    
    return [min floatValue];
}

//5窜1
- (float)max5Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < maxArray.count - 4; a++) {
        NSString *maxStr1 = [maxArray objectAtIndex:a];
        
        for (int b = a + 1; b < maxArray.count - 3; b++) {
            NSString *maxStr2 = [maxArray objectAtIndex:b];
            
            for (int c = b + 1; c < maxArray.count - 2; c++) {
                NSString *maxStr3 = [maxArray objectAtIndex:c];
                
                for (int d = c + 1; d < maxArray.count - 1; d++) {
                    NSString *maxStr4 = [maxArray objectAtIndex:d];
                    
                    for (int e = d + 1; e < maxArray.count; e++) {
                        NSString *maxStr5 = [maxArray objectAtIndex:e];
                        
                        CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue];
                        [array addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                    }
                }
            }
        }
    }
    
    NSNumber *sum = [array valueForKeyPath:@"@sum.floatValue"];
    
    return [sum floatValue];
}

- (float)min5Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < minArray.count - 4; a++) {
        NSString *minStr1 = [minArray objectAtIndex:a];
        
        for (int b = a + 1; b < minArray.count - 3; b++) {
            NSString *minStr2 = [minArray objectAtIndex:b];
            
            for (int c = b + 1; c < minArray.count - 2; c++) {
                NSString *minStr3 = [minArray objectAtIndex:c];
                
                for (int d = c + 1; d < maxArray.count - 1; d++) {
                    NSString *minStr4 = [minArray objectAtIndex:d];
                    
                    for (int e = d + 1; e < minArray.count; e++) {
                        NSString *minStr5 = [minArray objectAtIndex:e];
                        
                        CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue];
                        [array addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                    }
                }
            }
        }
    }
    
    NSNumber *min = [array valueForKeyPath:@"@min.floatValue"];
    
    return [min floatValue];
}

//6窜1
- (float)max6Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < maxArray.count - 5; a++) {
        NSString *maxStr1 = [maxArray objectAtIndex:a];
        
        for (int b = a + 1; b < maxArray.count - 4; b++) {
            NSString *maxStr2 = [maxArray objectAtIndex:b];
            
            for (int c = b + 1; c < maxArray.count - 3; c++) {
                NSString *maxStr3 = [maxArray objectAtIndex:c];
                
                for (int d = c + 1; d < maxArray.count - 2; d ++) {
                    NSString *maxStr4 = [maxArray objectAtIndex:d];
                    
                    for (int e = d + 1; e < maxArray.count - 1; e++) {
                        NSString *maxStr5 = [maxArray objectAtIndex:e];
                        
                        for (int f = e + 1; f < maxArray.count; f++) {
                            NSString *maxStr6 = [maxArray objectAtIndex:f];
                            
                            CGFloat maxFloatStr = [maxStr1 floatValue] * [maxStr2 floatValue] * [maxStr3 floatValue] * [maxStr4 floatValue] * [maxStr5 floatValue] * [maxStr6 floatValue];
                            [array addObject:[NSString stringWithFormat:@"%.4f",maxFloatStr]];
                        }
                    }
                }
            }
        }
    }
    
    NSNumber *sum = [array valueForKeyPath:@"@sum.floatValue"];
    
    return [sum floatValue];
}

- (float)min6Number {
    NSMutableArray *array = [NSMutableArray array];
    for (int a = 0; a < minArray.count - 5; a++) {
        NSString *minStr1 = [minArray objectAtIndex:a];
        
        for (int b = a + 1; b < minArray.count - 4; b++) {
            NSString *minStr2 = [minArray objectAtIndex:b];
            
            for (int c = b + 1; c < minArray.count - 3; c++) {
                NSString *minStr3 = [minArray objectAtIndex:c];
                
                for (int d = c + 1; d < minArray.count - 2; d ++) {
                    NSString *minStr4 = [minArray objectAtIndex:d];
                    
                    for (int e = d + 1; e < minArray.count - 1; e++) {
                        NSString *minStr5 = [minArray objectAtIndex:e];
                        
                        for (int f = e + 1; f < minArray.count; f++) {
                            NSString *minStr6 = [minArray objectAtIndex:f];
                            
                            CGFloat minFloatStr = [minStr1 floatValue] * [minStr2 floatValue] * [minStr3 floatValue] * [minStr4 floatValue] * [minStr5 floatValue] * [minStr6 floatValue];
                            [array addObject:[NSString stringWithFormat:@"%.4f",minFloatStr]];
                        }
                    }
                }
            }
        }
    }
    
    NSNumber *min = [array valueForKeyPath:@"@min.floatValue"];
    
    return [min floatValue];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([_selectMatchArray count] == 0) {
            return 0;
        } else {
            return [_selectMatchArray count];
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomBetViewCell *cell = (CustomBetViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SingleBetViewCell"];
    if (cell == nil) {
        cell = [[[CustomBetViewCell alloc] initWithHeihgt:SingleBetViewCellHeight style:UITableViewCellStyleDefault reuseIdentifier:@"SingleBetViewCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setBackImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betCenter.png"]] stretchableImageWithLeftCapWidth:20.0f topCapHeight:20.0f]];
        
    }
    if(cell) {
        for (UIView *view in cell.contentView.subviews) {
            if([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:2000];
        [label removeFromSuperview];
    }
    NSDictionary *dic = nil;
    if (indexPath.row < [_selectMatchArray count]) {
        dic = [_selectMatchArray objectAtIndex:indexPath.row];
    }
    NSDictionary *matchDic = [dic objectForKey:@"selectRowDic"];
    
    cell.mainTeamName = [matchDic objectForKey:@"mainTeam"];
    cell.guestTeamName = [matchDic objectForKey:@"guestTeam"];
    /********************** adjustment 控件调整 ***************************/
    CGFloat oneRowOneLabelMinX = IS_PHONE ? 20.0f : 50.0f;//一行一个label     :比分
    CGFloat oneRowOneLabelMinY = IS_PHONE ? 30.0f : 40.0f;
    CGFloat oneRowOneLabelWidth = IS_PHONE ? 200.0f : 540.0f;
    CGFloat oneRowOneLabelHeight = IS_PHONE ? 50.0f : 85.0f;
    
    CGFloat oneRowBtnMinX = 30.0f;
    CGFloat oneRowBtnMinY = 35.0f;
    CGFloat oneRowBtnWidth = 180.0f;
    CGFloat oneRowBtnHeight = 33.0f;
    
    CGFloat oneRowTwoBtnMinX = IS_PHONE ? 40.0f : 100.0f;//一行两个btn的    :胜负过关
    CGFloat oneRowTwoBtnMinY = IS_PHONE ? 36.0f : 58.0f;
    CGFloat oneRowTwoBtnWidth = IS_PHONE ? 85.0f : 150.0f;
    CGFloat oneRowTwoBtnLandscapeInterval = IS_PHONE ? 0.0f : 10.0f;
    CGFloat oneRowTwoBtnHeight = IS_PHONE ? 32.0f : 60.0f;

    CGFloat oneRowThreeBtnMinX = IS_PHONE ? 25.0f : 90.0f;//一行三个btn的    :让球胜平负  胜平负
    CGFloat oneRowThreeBtnMinY = IS_PHONE ? 36.0f : 58.0f;
    CGFloat oneRowThreeBtnWidth = IS_PHONE ? 65.0f : 130.0f;
    CGFloat oneRowThreeBtnLandscapeInterval = IS_PHONE ? 0.0f : 10.0f;
    CGFloat oneRowThreeBtnHeight = IS_PHONE ? 32.0f : 60.0f;
    
    CGFloat oneRowFourBtnMinX = IS_PHONE ? 17.0f : 75.0f;//一行四个btn的    :上下单双
    CGFloat oneRowFourBtnMinY = IS_PHONE ? 36.0f : 58.0f;
    CGFloat oneRowFourBtnWidth = IS_PHONE ? 60.0f : 125.0f;
    CGFloat oneRowFourBtnLandscapeInterval = IS_PHONE ? 0.0f : 10.0f;
    CGFloat oneRowFourBtnHeight = IS_PHONE ? 32.0f : 60.0f;
    
    CGFloat danBtnMinX = 0;
    CGFloat danBtnMaginX = 5.0;
    CGFloat danBtnMinY = 0.0;
    CGFloat danBtnWidth = IS_PHONE ? 31.0f : 54.0f;
    CGFloat danBtnHeight = IS_PHONE ? 31.0f : 54.0f;    

    danBtnMinY = (SingleBetViewCellHeight - danBtnHeight) / 2.0f;
    
    CGFloat deleteBtnSize = 18.0f;
    /********************** adjustment end ***************************/
    if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_upAndDownSingle) {  //上下单双
        cell.letBall = @"VS";
        [cell.oneLabel setHidden:YES];
        [cell.twoLabel setHidden:YES];
        
        for (int i = 0; i < 4; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(oneRowFourBtnMinX + i * (oneRowFourBtnWidth + oneRowFourBtnLandscapeInterval + AllLineWidthOrHeight), oneRowFourBtnMinY, oneRowFourBtnWidth, oneRowFourBtnHeight)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"上单%@",[matchDic objectForKey:@"shangDanSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
               
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"上双%@",[matchDic objectForKey:@"shangShuangSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
            }
            if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"下单%@",[matchDic objectForKey:@"xiaDanSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
            }
            if(i == 3) {
                [btn setTitle:[NSString stringWithFormat:@"下双%@",[matchDic objectForKey:@"xiaShuangSP"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
            }
            
            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
            danBtnMinX = CGRectGetMaxX(btn.frame) + danBtnMaginX;
            danBtnMinY = CGRectGetMinY(btn.frame);
            
            if (i < 2) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.contentView addSubview:lineView];
                [lineView release];
            }
            
        }
    } else if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_score) { //比分
        cell.letBall = @"VS";
        [cell.oneLabel setHidden:YES];
        [cell.twoLabel setHidden:YES];
        
        NSArray *array = [[_selectMatchArray objectAtIndex:indexPath.row] objectForKey:@"selectedTextArray"];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(oneRowOneLabelMinX, oneRowOneLabelMinY, oneRowOneLabelWidth, oneRowOneLabelHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [[btn titleLabel] setNumberOfLines:4];
        [[btn titleLabel] setMinimumScaleFactor:0.8];
        [[btn titleLabel] setAdjustsLetterSpacingToFitWidth:YES];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [btn setTitle:[self convertArrayToString:array separator:@","] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(unfoldBetViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        [btn release];
        danBtnMinX = CGRectGetMaxX(btn.frame) + danBtnMaginX;
        danBtnMinY = CGRectGetMinY(btn.frame);
        
    } else if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_totalGoal) { //总进球
        
        cell.letBall = @"VS";
        [cell.oneLabel setHidden:YES];
        [cell.twoLabel setHidden:YES];
        
        NSMutableArray *array = [[_selectMatchArray objectAtIndex:indexPath.row] objectForKey:kSelectedChangInfo];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(oneRowBtnMinX, oneRowBtnMinY, oneRowBtnWidth, oneRowBtnHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn setTitle:[self convertTotalGoalArrayToString:array separator:@"|"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(unfoldTotalGoalViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [[btn titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:btn];
        
        
        danBtnMinX = CGRectGetMaxX(btn.frame) + danBtnMaginX;
        danBtnMinY = CGRectGetMinY(btn.frame);

    } else if ([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_half) {//半全场

        cell.letBall = @"VS";
        [cell.oneLabel setHidden:YES];
        [cell.twoLabel setHidden:YES];
        
        NSArray *array = [[_selectMatchArray objectAtIndex:indexPath.row] objectForKey:@"selectedTextArray"];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(oneRowOneLabelMinX, oneRowOneLabelMinY, oneRowOneLabelWidth, oneRowOneLabelHeight)];
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        [[btn titleLabel] setNumberOfLines:4];
        [[btn titleLabel] setMinimumScaleFactor:0.8];
        [[btn titleLabel] setAdjustsLetterSpacingToFitWidth:YES];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [btn setTitle:[self convertHalfArrayToString:array] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(unfoldHalfViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        [btn release];
        danBtnMinX = CGRectGetMaxX(btn.frame) + danBtnMaginX;
        danBtnMinY = CGRectGetMinY(btn.frame);
        
    } else if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_winlose) { //胜负过关
        cell.letBall = @"VS";
        [cell.oneLabel setHidden:YES];
        [cell.twoLabel setHidden:YES];
        for (int i = 0; i < 2; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(oneRowTwoBtnMinX + i * (oneRowTwoBtnWidth + oneRowTwoBtnLandscapeInterval + AllLineWidthOrHeight), oneRowTwoBtnMinY, oneRowTwoBtnWidth, oneRowTwoBtnHeight)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"胜%@",[matchDic objectForKey:@"sfs"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
            }
            if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"负%@",[matchDic objectForKey:@"sff"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
            }
            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
            danBtnMinX = CGRectGetMaxX(btn.frame) + danBtnMaginX;
            danBtnMinY = CGRectGetMinY(btn.frame);
            
            
            if (i < 2) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.contentView addSubview:lineView];
                [lineView release];
            }
        }
        
        
    } else if ([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_winDogfallLose || [[dic objectForKey:@"selectType"] intValue] == SinglePlayType_single) {//胜平负
        cell.letBall = [matchDic objectForKey:@"giveBall"];
        [cell.oneLabel setHidden:YES];
        [cell.twoLabel setHidden:YES];
        for (int i = 0; i < 3; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(oneRowThreeBtnMinX + i * (oneRowThreeBtnWidth + oneRowThreeBtnLandscapeInterval + AllLineWidthOrHeight), oneRowThreeBtnMinY, oneRowThreeBtnWidth, oneRowThreeBtnHeight)];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
            if(i == 0) {
                [btn setTitle:[NSString stringWithFormat:@"主胜%@",[matchDic objectForKey:@"winSp"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                
            } else if(i == 1) {
                [btn setTitle:[NSString stringWithFormat:@"平%@",[matchDic objectForKey:@"flatSp"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
                
            } else if(i == 2) {
                [btn setTitle:[NSString stringWithFormat:@"主负%@",[matchDic objectForKey:@"loseSp"]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
                
            }
            [btn setTag:i + 1];
            [btn addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
            danBtnMinX = CGRectGetMaxX(btn.frame) + danBtnMaginX;
            danBtnMinY = CGRectGetMinY(btn.frame);
            
            
            if (i < 2) {
                CGRect lineViewRect = CGRectMake(CGRectGetMaxX(btn.frame), CGRectGetMinY(btn.frame), AllLineWidthOrHeight, CGRectGetHeight(btn.frame));
                UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
                [lineView setBackgroundColor:[UIColor colorWithRed:0xdd/255.0f green:0xdd/255.0f blue:0xdd/255.0f alpha:1.0f]];
                [cell.contentView addSubview:lineView];
                [lineView release];
            }
        }
    }
    
    if ([self getActualCounts] > 2 && [[dic objectForKey:@"selectType"] intValue] != SinglePlayType_single && _SinglePassBarrierType != SinglePassBarrierType_singleMacth ) { //胆按钮 混合网站上没混合胆算法，写了也投注不了
        if ([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_no) {
            [cell.oneLabel setHidden:YES];
            [cell.twoLabel setHidden:YES];
        } else {
            [cell.oneLabel setHidden:YES];
            [cell.twoLabel setHidden:YES];
            //设胆按钮
            UIButton *setDanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [setDanBtn setFrame:CGRectMake(danBtnMinX, danBtnMinY, danBtnWidth, danBtnHeight)];
            [setDanBtn setAdjustsImageWhenHighlighted:NO];
            [setDanBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"danButton.png"]] forState:UIControlStateNormal];
            [setDanBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"danButton_Select.png"]] forState:UIControlStateSelected];
            [setDanBtn setTitleColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]forState:UIControlStateNormal];
            [setDanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [setDanBtn setTitle:@"胆" forState:UIControlStateNormal];
            [setDanBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];
            [setDanBtn setTag:1001];
            [setDanBtn addTarget:self action:@selector(setDan:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:setDanBtn];
        }
    }
    //deleteBtn
    CGRect deleteBtnRect = CGRectMake(CGRectGetWidth(tableView.frame) - deleteBtnMaginRight - deleteBtnSize, (SingleBetViewCellHeight - deleteBtnSize) / 5.0f * 3.0, deleteBtnSize, deleteBtnSize);
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:deleteBtnRect];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betDeleteButton.png"]] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betDeleteButton.png"]] forState:UIControlStateHighlighted];
    [deleteBtn setTag:indexPath.row];
    [deleteBtn setHidden:([_selectMatchArray count] == 0)];  
    
    if(![[dic objectForKey:@"selectType"] intValue] == SinglePlayType_upAndDownSingle){
        [deleteBtn addTarget:self action:@selector(deleteBetTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteBtn];
        
    }else if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_upAndDownSingle &&  [self getActualCounts] < 3){
        [deleteBtn addTarget:self action:@selector(deleteBetTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteBtn];
    }
    [deleteBtn release];
    
    return cell;
}

-(void)deleteButton:(UIButton *) button{
    
}

#pragma mark -UITableViewDelegate
//让button被选中
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (indexPath.row < [_selectMatchArray count]) {
        dic = [_selectMatchArray objectAtIndex:indexPath.row];
    }
    UIButton *danBtn = (UIButton *)[cell.contentView viewWithTag:1001];
    if([[dic objectForKey:@"isDan"] boolValue]) {
        [danBtn setSelected:YES];
    } else {
        [danBtn setSelected:NO];
    }

    //被选中比赛的对应按钮的 tag 数组
    if (([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_upAndDownSingle || [[dic objectForKey:@"selectType"] intValue] ==  SinglePlayType_winDogfallLose || [[dic objectForKey:@"selectType"] intValue] == SinglePlayType_totalGoal || [[dic objectForKey:@"selectType"] intValue] ==  SinglePlayType_winlose ) && indexPath.row < [_selectMatchArray count]) {
        NSArray *selectArray = [[_selectMatchArray objectAtIndex:indexPath.row] objectForKey:@"selectArray"];
        for (int i = 0; i < selectArray.count; i++) {
            UIButton *btn = (UIButton *)[cell.contentView viewWithTag:[[selectArray objectAtIndex:i] intValue]];
            [btn setSelected:YES];
        }
    }
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

//tableViewFootView的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    } else {
        return kTableViewFootViewHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectMatchArray count] == 0) {
        return 8.5;
    } else {
        return SingleBetViewCellHeight;
    }
}

//配置footview
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    /********************** adjustment 控件调整 ***************************/
    CGFloat checkBtnMinX = 30.0f;
    CGFloat checkBtnSize = IS_PHONE ? 18.0f : 36.0f;
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
    [footBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"betBottom.png"]] stretchableImageWithLeftCapWidth:15.0f topCapHeight:15.0f]];
    [footView addSubview:footBackImageView];
    [footBackImageView release];
    
    //checkBtn
    CGRect checkBtnRect = CGRectMake(checkBtnMinX, checkBtnMagin, checkBtnSize, checkBtnSize);
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
    [checkBtn setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateNormal];
    [checkBtn setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateHighlighted];
    [checkBtn setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
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
    [clearBtn setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearButton.png"]] forState:UIControlStateNormal];
    [clearBtn setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearButton.png"]] forState:UIControlStateHighlighted];
    [clearBtn setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"clearButton.png"]] forState:UIControlStateSelected];
    [clearBtn addTarget:self action:@selector(clearSelect:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:clearBtn];
    [clearBtn release];
    
    
    return [footView autorelease];
}
    
#pragma mark -UIAlertViewdelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    if (alertView.tag == 2) {
        if(buttonIndex == 1) {
            RechargeViewController *recharge = [[RechargeViewController alloc]init];
            [self.navigationController pushViewController:recharge animated:YES];
            [recharge release];
        }
    }
    
    if (alertView.tag == 76) { //确认付款
        if(buttonIndex == 1) {
            [self payRequest];
            return;
        }
    }
}

#pragma mark -DialogPassWayViewDelegate
- (void)viewDidSelectedPassWay:(NSDictionary *)passWay {
    isSeceltPaly = YES;
    self.passWayArray = [NSMutableArray arrayWithArray:[passWay objectForKey:@"selectPassWay"]];
    self.passWayTagArray = [NSMutableArray arrayWithArray:[passWay objectForKey:@"selectPassTag"]];
    self.selectPassWayType = [[passWay objectForKey:@"selectPassWayType"] intValue];
    
    [self updateBottomView];

    if (_passWayArray.count == 0) {
        [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
        return;
    }
    
    NSString *passWayStr = @"";
    for (NSString *str in _passWayArray) {
        passWayStr = [passWayStr stringByAppendingFormat:@"%@,",str];
    }
    
    passWayStr = [passWayStr substringToIndex:passWayStr.length - 1];
    [_passWayBtn setTitle:passWayStr forState:UIControlStateNormal];
}

#pragma mark -UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [passWayView fadeOut];
    if (_passWayArray.count == 0) {
        [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
        return;
    }
    
    NSString *passWayStr = @"";
    for (NSString *str in _passWayArray) {
        passWayStr = [passWayStr stringByAppendingFormat:@"%@,",str];
    }
    
    passWayStr = [passWayStr substringToIndex:passWayStr.length - 1];
    [_passWayBtn setTitle:passWayStr forState:UIControlStateNormal];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([text length] > 5)
        return NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:_inputField]) {
        if ([_inputField.text integerValue] < 1){
            _inputField.text = @"1";
        }
    }
    if ([textField isEqual:_winningsField]) {
        if ([_winningsField.text integerValue] < 1) {
            _winningsField.text = @"0";
        }
    }
    [self updateBottomView];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"请求竞彩足球的时间：%f",([NSDate timeIntervalSinceReferenceDate] - _startTime));
//    [_progressHud hide:YES];
    [Globals alertWithMessage:@"连接失败"];
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
//    NSLog(@"responseDic == %@",[request responseString]);
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        // 购买成功后，会返回余额和冻结金额，保存起来
        [[UserInfo shareUserInfo] setBalance:[responseDic objectForKey:@"balance"]];
        [[UserInfo shareUserInfo] setFreeze:[responseDic objectForKey:@"freeze"]];
        
        // 保存到NSUserDefaults
        NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
        [userinfo setObject:[responseDic objectForKey:@"balance"] forKey:@"balance"];
        [userinfo setObject:[responseDic objectForKey:@"freeze"] forKey:@"freeze"];
        [[NSUserDefaults standardUserDefaults]setObject:userinfo forKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [_orderDetailDict addEntriesFromDictionary:responseDic];
        [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",(long)45] forKey:@"lotteryId"];
        
        PaySucceedViewController *paySucceedViewController = [[PaySucceedViewController alloc] initWithDict:_orderDetailDict buyType:NORMAL];
        [self.navigationController pushViewController:paySucceedViewController animated:YES];
        [paySucceedViewController release];
        
    } else if (responseDic && [[responseDic objectForKey:@"error"] intValue] == -134) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"] delegate:self tag:2];
    } else if(responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
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
        [lotteryDic setObject:@"45" forKey:@"lotteryid"];
        [lotteryDic setObject:@"-1" forKey:@"isuseId"];
        
        [chippedDic setObject:lotteryDic forKey:@"lotteryDic"];
        [chippedDic setObject:[self getBuyContent] forKey:@"buyContent"];
        [chippedDic setObject:[NSString stringWithFormat:@"%ld",(long)[self getBetCount]] forKey:@"betCount"];
        [chippedDic setObject:_inputField.text forKey:@"multiple"];
        
        LaunchChippedViewController *launchChipped = [[LaunchChippedViewController alloc]initWithBetDictionary:chippedDic];
        [self.navigationController pushViewController:launchChipped animated:YES];
        [launchChipped release];
    }
}

#pragma mark -DialogSelectButtonViewDetegate
- (void)dialogSelectMatch:(NSMutableArray *)selectMatchArray selectMatchText:(NSMutableArray *)selectMatchText dialogType:(DialogType)dialogType indexPath:(NSIndexPath *)indexPath {//目前用于
    NSDictionary *sectionDict = [_selectMatchArray objectAtIndex:indexPath.row];
    NSDictionary *rowDic = [sectionDict objectForKey:@"selectRowDic"];
    NSIndexPath  *originalIndexPath = [sectionDict objectForKey:@"selectIndexPath"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_SinglePlayType == SinglePlayType_totalGoal || _SinglePlayType == SinglePlayType_half || _SinglePlayType == SinglePlayType_score ) {
        
        [dic setObject:rowDic forKey:@"selectRowDic"];
        [dic setObject:selectMatchArray forKey:kSelectedChangInfo];
        [dic setObject:originalIndexPath forKey:@"selectIndexPath"];
        [dic setObject:selectMatchText forKey:@"selectedTextArray"];
        [dic setObject:[NSString stringWithFormat:@"%ld",(long)_SinglePlayType] forKey:@"selectType"];
        
    }
    
    //修改比赛信息
    if ([selectMatchArray count] == 0) {
        // 如果反选时没有选择半全场，则删除该场次
        [_selectMatchArray removeObjectAtIndex:indexPath.row];
    } else {
        [_selectMatchArray replaceObjectAtIndex:indexPath.row withObject:dic];
    }
        
    
    [self updateBottomView];
    [_betTableView reloadData];
}


#pragma mark -
#pragma mark -Customized(Action)
- (void)selectMatchWithMixTouchUpInside:(id)sender {
    CGRect dialogSelectButtonViewRect = IS_PHONE ? CGRectMake(0, 0, 300, kWinSize.height - 70.0f) : CGRectMake(0, 0, 700, kWinSize.height - 200.0f);
    [self showDialogSelectViewWithFrame:dialogSelectButtonViewRect touchBtn:sender dialogType:DialogFootBallMix];
}

//猜比分
- (void)unfoldBetViewTouchUpInside:(id)sender {
    CGRect dialogSelectButtonViewRect = IS_PHONE ? CGRectMake(0, 0, 300, 350) : CGRectMake(0, 0, 700, kWinSize.height - 200.0f);
    [self showDialogSelectViewWithFrame:dialogSelectButtonViewRect touchBtn:sender dialogType:DialogFootBallScore];
    
}

- (void)unfoldTotalGoalViewTouchUpInside:(id)sender {
    CGRect dialogSelectButtonViewRect = IS_PHONE ? CGRectMake(0, 0, 300, 160) : CGRectMake(0, 0, 700, kWinSize.height - 500.0f);
    [self showDialogSelectViewWithFrame:dialogSelectButtonViewRect touchBtn:sender dialogType:DialogFootBallTotalGoal];
}

- (void)unfoldHalfViewTouchUpInside:(id)sender {
    CGRect selectHalfViewRect = IS_PHONE ? CGRectMake(0, 0, 300, 250) : CGRectMake(0, 0, 600, 500);
    [self showDialogSelectViewWithFrame:selectHalfViewRect touchBtn:sender dialogType:DialogFootBallHalf];
    
}

- (void)showDialogSelectViewWithFrame:(CGRect)dialogSelectFrame touchBtn:(id)touchBtn dialogType:(DialogType)dialogType {
    NSIndexPath *betIndexPath = [self findButtonIndexPathWithTheButton:touchBtn];
    NSDictionary *rowDic = [_selectMatchArray objectAtIndex:betIndexPath.row];

    DialogSelectButtonView *dialogSelectButtonView = [[DialogSelectButtonView alloc] initWithFrame:dialogSelectFrame matchDict:[rowDic objectForKey:@"selectRowDic"] playID:45];
    [dialogSelectButtonView setDialogType:dialogType];
    [dialogSelectButtonView setDelegate:self];
    [dialogSelectButtonView setSelectMatchNumberArray:[rowDic objectForKey:kSelectedChangInfo]];
    [dialogSelectButtonView setSelectMatchIndexPath:betIndexPath];
    [dialogSelectButtonView show];
    [dialogSelectButtonView release];
}

- (NSIndexPath *)findButtonIndexPathWithTheButton:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *cell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        cell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)btn.superview.superview;
    }
    NSIndexPath *indexPath = [_betTableView indexPathForCell:cell];
    return indexPath;
}

- (void)deleteBetTouchUpInside:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self.selectMatchArray removeObjectAtIndex:btn.tag];
    [_betTableView reloadData];
    [self updateBottomView];
}

- (void)chippedClick:(id)sender {
    if(_passWayArray == nil || _passWayArray.count == 0) {
        [Globals alertWithMessage:@"未选择过关方式，不能进行合买"];
        return;
    }
    [self loadLaunchChippedProportion];
}

//点击"购彩大厅"  弹出选项框
- (void)backToHome:(id)sender {
    if (_inputField) {
        [_inputField resignFirstResponder];
    }
    if(_selectMatchArray.count > 0) {//如果有数据则弹出，没有则返回
        [Globals alertWithMessage:@"返回购彩大厅将清空所有已选的号码" delegate:self tag:1];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [self dismissViewControllerAnimated:YES completion:nil];//幸运选号的时候是present
    }
}

//继续选择比赛
- (void)goonSelect:(id)sender {
    NSMutableArray *arrSelectMatch = [NSMutableArray array];
    for (NSDictionary *dic in self.selectMatchArray) {
        if ([[dic objectForKey:@"selectArray"] count] > 0) {
            [arrSelectMatch addObject:dic];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    [_betTableView reloadData];
}

//清空
- (void)clearSelect:(id)sender {
    for (int i = 0; i < _selectMatchArray.count; i++) {
        NSMutableArray *array = [[_selectMatchArray objectAtIndex:i] objectForKey:@"selectArray"];
        [array removeAllObjects];
        
        [[_selectMatchArray objectAtIndex:i] setObject:[NSNumber numberWithBool:NO] forKey:@"isDan"];
    }
    [_selectedScoreDic removeAllObjects];
    [_passWayArray removeAllObjects];
    [_bottomView setMatchCount:0 money:0];
    [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
    [self.selectMatchArray removeAllObjects];
    [_betTableView reloadData];
}

//付款
- (void)pay:(id)sender {
    [passWayView fadeOut];
    
    if((_passWayArray == nil || _passWayArray.count == 0) && _SinglePassBarrierType == SinglePassBarrierType_moreMatch) {

        [Globals alertWithMessage:@"未选择过关方式，不能付款"];
        return;
    }
    
    if (_allstr && _allstr.length>0) {
        DuangAlert *duang = [[DuangAlert alloc] initWithTitle:@"发起复制需要填写以下内容" settings:@[@"永久公开",@"开赛后公开"] selected:^(NSInteger index, NSDictionary *backDic) {
            if (index == 1) {
                _secrecyLevel = [[backDic objectForKey:@"index"] integerValue] == 0 ? @"0" : @"2";
                _description = [[backDic objectForKey:@"text"] copy];
                
                NSInteger betCount = [self getBetCount];
                NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
                
                CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)(betCount * multiple * 2)] leftText:@"取消" rightText:@"确定"];
                [customAlert setTag:76];
                [customAlert show];
                [customAlert release];
                
            }
        }];
        [duang show];
        [duang release];
    }else{
        NSInteger betCount = [self getBetCount];
        NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
        
        CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)(betCount * multiple * 2)] leftText:@"取消" rightText:@"确定"];
        [customAlert setTag:76];
        [customAlert show];
        [customAlert release];
    }
}

- (void)payRequest{
    if([UserInfo shareUserInfo].userID) {
        
        NSInteger betCount = [self getBetCount];
        if (betCount < 0) {
            [Globals alertWithMessage:@"计算结果超出范围，请重新选号"];
            return;
        }
        
        
        
        NSInteger mul = [_inputField.text integerValue];
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:@"45" forKey:@"lotteryId"];
        [infoDic setObject:@"-1" forKey:@"isuseId"];
        [infoDic setObject:[NSNumber numberWithInt:mul == 0 ? 1 : (int)mul] forKey:@"multiple"];
        [infoDic setObject:@"1" forKey:@"share"];
        [infoDic setObject:@"1" forKey:@"buyShare"];
        [infoDic setObject:@"0" forKey:@"assureShare"];
        [infoDic setObject:@"0" forKey:@"schemeBonusScale"];
        [infoDic setObject:@"" forKey:@"title"];
        if (_allstr == nil || [_allstr isEqualToString:@""]) {
            
        }else{
            [infoDic setObject:_secrecyLevel forKey:@"secrecyLevel"];
            [infoDic setObject:_description forKey:@"description"];
            [infoDic setObject:_allstr forKey:@"isMayCopy"];
        }
        
        [infoDic setObject:@"0" forKey:@"secrecyLevel"];
        
        [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)(betCount * (mul == 0 ? 1 : mul) * 2)] forKey:@"schemeSumMoney"];
        [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)betCount] forKey:@"schemeSumNum"];
        [infoDic setObject:@"0" forKey:@"chase"];
        [infoDic setObject:[self getBuyContent] forKey:@"buyContent"];
        [_orderDetailDict removeAllObjects];
        [_orderDetailDict setObject:[NSString stringWithFormat:@"%ld",(long)(betCount * (mul == 0 ? 1 : mul) * 2)] forKey:@"consumeMoney"];
        
        if (_httpRequest != nil) {
            [_httpRequest clearDelegatesAndCancel];
            [_httpRequest release];
            _httpRequest = nil;
        }
        _startTime = [NSDate timeIntervalSinceReferenceDate];
        _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_BuyLotteryTicket userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
        [_httpRequest setTimeOutSeconds:60.0f];
        [_httpRequest setDelegate:self];
        [_httpRequest startAsynchronous];
    } else {
        UserLoginViewController *login = [[UserLoginViewController alloc]init];
        XFNavigationViewController *loginNav = [[XFNavigationViewController alloc]initWithRootViewController:login];
        
        [self presentViewController:loginNav animated:YES completion:nil];
        [login release];
        [loginNav release];
        return;
    }

}

//选择过关方式
- (void)selectPassWay:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:![btn isSelected]];
    
    if ([[self getPlayType] integerValue] == 4506) {
        
        if ([self selectMatchCount] < 3) {
            [Globals alertWithMessage:@"请至少选择三场比赛"];
            return;
        }
    }
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat selectBtnHeight = IS_PHONE ? 31.0f : 46.5f;
    CGFloat passViewMaginTopBottom = IS_PHONE ? 10.0f : 14.0f; //整个选择视图与父视图的上下间距
    CGFloat segmentedHeight = IS_PHONE ? 50.0f : 79.5f;
    /********************** adjustment end ***************************/
    
    if (btn.selected) {
        NSInteger counts = [self selectMatchCount];
        
        NSArray *freePassArray = [PassWayUtility getFreePassItemsWithMatchCount:counts danCount:self.selectDanArray.count playID:45 playType:[[self getPlayType] integerValue]];
        NSArray *mixPassArray = [PassWayUtility getMixPassItemsWithMatchCount:counts danCount:self.selectDanArray.count playType:[[self getPlayType] integerValue]];
        
        float freePassHight = freePassArray.count > 4 ? ([self selectMatchCount] == 8 ? freePassArray.count / 4 : ([self selectMatchCount] == 12 ? freePassArray.count / 4 : freePassArray.count / 4 + 1)) * (passViewMaginTopBottom + selectBtnHeight) : (passViewMaginTopBottom + selectBtnHeight);
        float mixPassHight = mixPassArray.count > 4 ? ((mixPassArray.count / 4 + 1) > 8 ? 8 : (mixPassArray.count / 4 + 1)) * (passViewMaginTopBottom + selectBtnHeight) : (passViewMaginTopBottom + selectBtnHeight);
        
        CGRect passWayViewRect = CGRectMake(0, kWinSize.height - CGRectGetHeight(_inputView.frame) - CGRectGetHeight(_bottomView.frame) - (freePassHight + mixPassHight + (mixPassArray.count > 0 ? segmentedHeight * 2 : selectBtnHeight)) + 20, kWinSize.width, (mixPassHight + freePassHight) + (mixPassArray.count > 0 ? segmentedHeight * 2 : selectBtnHeight));
        passWayView = [[DialogPassWayView alloc]initWithFrame:passWayViewRect MatchCount:counts danCount:self.selectDanArray.count playID:45 playType:[[self getPlayType] integerValue]];
        [passWayView setDelegate:self];
        [passWayView setSelectPassWayType:_selectPassWayType];
        [passWayView updateSelectPassWay:_passWayArray];
        [passWayView show];
        
        [btn setTitle:@"收起" forState:UIControlStateNormal];
        
    } else {
        [passWayView fadeOut];
        
        if (_passWayArray.count == 0) {
            [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
            return;
        }
        
        NSString *passWayStr = @"";
        for (NSString *str in _passWayArray) {
            passWayStr = [passWayStr stringByAppendingFormat:@"%@,",str];
        }
        
        passWayStr = [passWayStr substringToIndex:passWayStr.length - 1];
        [_passWayBtn setTitle:passWayStr forState:UIControlStateNormal];
    }
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    }
}

//设胆  
- (void)setDan:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *SingleBetCell;
    if (IOS_VERSION >= 7.0000 && IOS_VERSION < 8.0f) {
        SingleBetCell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        SingleBetCell = (UITableViewCell *)btn.superview.superview;
    }
    NSIndexPath *indexPath = [_betTableView indexPathForCell:SingleBetCell];
    NSMutableDictionary *dic = [_selectMatchArray objectAtIndex:indexPath.row];
    BOOL isDan = NO;
    _selectedDanBtnCount = [self selectDanCount];//获得
    if([btn isSelected]) {
        _selectedDanBtnCount --;
        [btn setSelected:NO];
    } else {
        NSInteger actualCount = [self selectMatchCount];
        // 如果只选了两场，点击无效
        if (actualCount < 3) {
            return;
        }
        
        // 胆的个数比所选场次小1，最多7个胆
        if (_selectedDanBtnCount == actualCount - 1)
            return;
        
        // 该场已被取消,不能点击
        NSArray *selectArray = [dic objectForKey:@"selectArray"];
        if (selectArray.count == 0)
            return;
        
        if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_score) {
            if(_selectedDanBtnCount == 3) {
                return;
            }
        }
        if([[dic objectForKey:@"selectType"] intValue] == SinglePlayType_totalGoal) {
            if(_selectedDanBtnCount == 5) {
                return;
            }
        }
        
        // 最多7个胆，满7个不能点其他的了
        if (_selectedDanBtnCount == 7 && !btn.isSelected) {
            [XYMPromptView defaultShowInfo:@"最多设置7个胆" isCenter:NO];
            return;
        }
        
        // 两场
        NSInteger matchCount = [self selectMatchCount];
        if (matchCount == 3) {
            if (_selectedDanBtnCount >= 2)
                return;
        }
        isDan = YES;
        _selectedDanBtnCount ++;
        [btn setSelected:YES];
        
        for (int i = 0; i < _passWayArray.count; i++) {
            NSString *str = [_passWayArray objectAtIndex:i];

            if ([str integerValue] <= _selectedDanBtnCount) {
                if ([str integerValue] == _selectedDanBtnCount && _passWayArray.count == 1) {
                    [_passWayArray removeObjectAtIndex:i];
                    [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
                } else {
                    if (_selectedDanBtnCount >= 2) {
                        [_passWayArray removeObjectAtIndex:i];
                        NSString *passWayStr = @"";
                        for (NSString *str in _passWayArray) {
                            passWayStr = [passWayStr stringByAppendingFormat:@"%@,",str];
                        }
                        
                        passWayStr = [passWayStr substringToIndex:passWayStr.length - 1];
                        [_passWayBtn setTitle:passWayStr forState:UIControlStateNormal];
                    }
                }
            }
        }
    }
    [dic setObject:[NSNumber numberWithBool:isDan] forKey:@"isDan"];
    
    //刷新注数的显示
    [self updateBottomView];
}

//胜平负  和 总进球
- (void)buttonSelected:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *SingleBetCell;
    if (IS_IOS7 && !IS_IOS8) {
        SingleBetCell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        SingleBetCell = (UITableViewCell *)btn.superview.superview;
    }
    NSIndexPath *indexPath = [_betTableView indexPathForCell:SingleBetCell];
    
    if([btn isSelected]) {
        [self removeItem:[NSString stringWithFormat:@"%ld",(long)btn.tag] WithRowIndex:indexPath.row];
        [self disSelectedDanBtn:SingleBetCell index:indexPath.row];
        [btn setSelected:NO];
    } else {
        [self insertItem:[NSString stringWithFormat:@"%ld",(long)btn.tag] WithRowIndex:indexPath.row];
        
        [btn setSelected:YES];
    }
    
    [self updateBottomView];
    [_betTableView reloadData];
}

- (void)showRuleView:(id)sender {
    BetRuleViewController *betRuleVC = [[BetRuleViewController alloc] init];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:betRuleVC];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [betRuleVC release];
    [nav release];
}

//点击背景让键盘消失
- (void)tapToHideKeyboard:(UITapGestureRecognizer *)gesture {
    for (UIView *view in _inputView.subviews) {
        if([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            
            _inputField.text = field.text;
            [field resignFirstResponder];
        }
    }
    for (UIView *view in _chaseViewHeight.subviews) {
        if([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            
            _winningsField.text = field.text;
            [field resignFirstResponder];
        }
    }
}

//键盘出现的时候响应
- (void)keyboardWillShow:(NSNotification *)notification {
    [_passWayBtn setHidden:YES];
    
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
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [_inputView setFrame:CGRectMake(0, kScreenSize.height - keyBoardRect.size.height - kInputViewHeight - 64.0f, kWinSize.width, kInputViewHeight)];
    
    [UIView commitAnimations];
}

//键盘消失时响应
- (void)keyboardWillHide:(NSNotification *)notification {
    
    [_passWayBtn setHidden:NO];
    
    [_overlayView setHidden:YES];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [_inputView setFrame:CGRectMake(0, kScreenSize.height - kBottomHeight - kInputViewHeight - 64.0f, kWinSize.width, kInputViewHeight)];
    
    [UIView commitAnimations];
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

- (NSInteger)selectDanCount {
    NSInteger danCount = 0;
    for (NSDictionary *dict in _selectMatchArray) {
        if ([dict boolValueForKey:@"isDan"]) {
            danCount++;
        }
    }
    return danCount;
}

- (void)updateSelectMatchArray:(NSMutableArray*)matchArray andScoreDic:(NSMutableDictionary *)scoreDic {
    self.selectMatchArray = matchArray;
    self.selectedScoreDic = scoreDic;
    [_betTableView reloadData];
    [self updatePassway];
    [self updateBottomView];
}

//获取选中比赛的胜平负信息  用于计算注数
- (NSArray *)selectArray {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in _selectMatchArray) {
        if(![[dic objectForKey:@"isDan"] boolValue]) {
            NSArray *matchArray = [dic objectForKey:kSelectedChangInfo];
            if (matchArray.count > 0)
                [array addObject:matchArray];
        }
    }
    return array;
}

//获取比赛的设胆信息
- (NSArray *)selectDanArray {
    NSMutableArray *danArray = [NSMutableArray array];
    for (NSDictionary *dic in _selectMatchArray) {
        if([[dic objectForKey:@"isDan"] boolValue]) {
            NSArray *matchArray = [dic objectForKey:@"selectArray"];
            if (matchArray) {
                [danArray addObject:matchArray];
            }
        }
    }
    return danArray;
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

- (NSArray *)selectDanInfoArray {
    NSMutableArray *danArray = [NSMutableArray array];
    for (NSDictionary *dic in _selectMatchArray) {
        if([[dic objectForKey:@"isDan"] boolValue]) {
            [danArray addObject:dic];
        }
    }
    return danArray;
}

- (NSInteger)getActualCounts {
    NSInteger count = 0;
    for (NSDictionary *dic in _selectMatchArray) {
        NSArray *arr = [dic objectForKey:@"selectArray"];
        if (arr.count > 0)
            count++;
    }
    return count;
}

- (NSArray *)getBuyContent {
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSInteger betCount = [self getBetCount];
    
    NSInteger mul = [_inputField.text integerValue];
    
    [dic setObject:[self getPlayType] forKey:@"playType"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)(betCount * 2 * (mul == 0 ? 1 : mul))] forKey:@"sumMoney"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)betCount] forKey:@"sumNum"];
    [dic setObject:[self getFormatSelectMatchArray] forKey:@"lotteryNumber"];
    [array addObject:dic];

    return array;
}

//获取系统玩法类型
- (NSString *)getPlayType {
    NSString *str = [[_selectMatchArray lastObject] objectForKey:@"selectType"];
    int type = [str intValue];
    NSString *result = @"";
    
    switch (type) {
        case SinglePlayType_upAndDownSingle:
            result = @"4503";
            break;
        case SinglePlayType_winDogfallLose:
            result = @"4501";
            break;
        case SinglePlayType_score:
            result = @"4504";
            break;
        case SinglePlayType_totalGoal:
            result = @"4502";
            break;
        case SinglePlayType_winlose:
            result = @"4506";
            break;
        case SinglePlayType_half:
            result = @"4505";
            
        default:
            break;
    }
    return result;
}

//格式化选择的比赛信息
- (NSString *)getFormatSelectMatchArray {
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"%@;",[self getPlayType]];
    if(self.selectDanArray.count > 0) {
        result = [result stringByAppendingString:@"["];
        for (NSDictionary *dic in self.selectDanInfoArray) {
            NSString *matchId = [[dic objectForKey:@"selectRowDic"] objectForKey:@"matchId"];
            result = [result stringByAppendingFormat:@"%@(",matchId];
            
            if (_SinglePlayType == SinglePlayType_no) {
                NSArray *selectArray = [dic objectForKey:@"selectedTags"];
                for (NSString *str in selectArray) {
                    result = [result stringByAppendingFormat:@"%@,",str];
                }
                
            } else {
                NSArray *selectArray = [dic objectForKey:@"selectArray"];
                for (NSString *str in selectArray) {
                    result = [result stringByAppendingFormat:@"%@,",str];
                }
            }
            //去掉最后一个,号
            result = [result substringToIndex:result.length - 1];
            result = [result stringByAppendingString:@")|"];
        }
        //去掉最后一个“|”号
        result = [result substringToIndex:result.length - 1];
        result = [result stringByAppendingString:@"]"];
    }
    
    result = [result stringByAppendingString:@"["]; // 7202:[
    for (NSDictionary *dic in self.selectNormalArray) {
        NSString *matchId = [[dic objectForKey:@"selectRowDic"] objectForKey:@"matchId"];
        NSArray *selectArray = [dic objectForKey:@"selectArray"];
        if (selectArray.count == 0)
            continue;
        result = [result stringByAppendingFormat:@"%@(",matchId];// 7202:[1745(
        if (_SinglePlayType == SinglePlayType_no) {
            NSArray *selectArray = [dic objectForKey:@"selectedTags"];
            for (NSString *str in selectArray) {
                result = [result stringByAppendingFormat:@"%@,",str];
            }
            
        } else {
            NSArray *selectArray = [dic objectForKey:@"selectArray"];
            for (NSString *str in selectArray) {
                result = [result stringByAppendingFormat:@"%@,",str];
            }
        }
        //去掉最后一个,号
        result = [result substringToIndex:result.length - 1];
        result = [result stringByAppendingString:@")|"];
    }
    result = [result substringToIndex:result.length - 1];
    result = [result stringByAppendingString:@"];["];
    
    for (NSString *str in _passWayArray) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@%@,",[PassWayUtility getPassWayBJDCCodeWithString:str],_inputField.text]];
    }
    result = [result substringToIndex:result.length - 1];
    result = [result stringByAppendingString:@"]"];
    
    if(self.selectDanArray.count > 0) {
        result = [result stringByAppendingFormat:@";[%lu]",(unsigned long)self.selectDanArray.count];
        
    }

    return result;
}

// 获取实际场数
- (NSInteger)selectMatchCount {
    int betCount = 0;
    for (NSDictionary *dic in _selectMatchArray) {
        NSArray *arr = [dic objectForKey:kSelectedChangInfo];
        if (arr.count > 0)
            betCount++;
    }

    return betCount;
}

- (void)updateBottomView {
    [self setMatchDate];
    NSInteger betCount = [self getBetCount];              // 总注数
    NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
    
    if (betCount > 0) {
        NSNumber *sum = [maxNumberArray valueForKeyPath:@"@sum.floatValue"];
        NSNumber *min = [minNumberArray valueForKeyPath:@"@min.floatValue"];
        
        [_bottomView setMatchCount:betCount money:betCount * multiple * 2 winMoney1:[min floatValue] * multiple * 2 * 0.65 winMoney2:[sum floatValue] * multiple * 2 * 0.65];
        
    } else {
        [_bottomView setMatchCount:betCount money:betCount * multiple * 2];
    }
    
    if (betCount == 0) {
        [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
        [self.passWayArray removeAllObjects];
        [self.passWayTagArray removeAllObjects];
    }
}

//计算注数
- (NSInteger)getBetCount {
    NSInteger betCount = 0;
    
    if (_SinglePassBarrierType == SinglePassBarrierType_singleMacth) { //单关
        betCount = [CalculateBetCount getOneMatchCountWithArray:self.selectArray andPlayID:_SinglePlayType];
    } else {
        for (NSString *str in _passWayArray) {
            if ([str isEqualToString:@"单关"]) {
                betCount = [CalculateBetCount getOneMatchCountWithArray:self.selectArray andPlayID:_SinglePlayType];
            } else{
                if(self.selectDanArray.count == 0) {
                    NSArray *numberArray = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"串"]];
                    betCount += [CalculateBetCount getBJDCNG1WithN:[[numberArray objectAtIndex:0] integerValue] m:[[numberArray objectAtIndex:1] integerValue] matchArray:self.selectArray danArray:nil];
                    
                    
                } else {
                    NSArray *numberArray = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"串"]];
                    betCount += [CalculateBetCount getBJDCNG1WithN:[[numberArray objectAtIndex:0] integerValue] m:[[numberArray objectAtIndex:1] integerValue] matchArray:self.selectArray danArray:self.selectDanArray];
                }
            }
        }
    }
    
    return betCount;
}

//猜比分  将数组转换成用","隔开的字符串
- (NSString *)convertArrayToString:(NSArray *)array separator:(NSString *)separator {
    NSString *result = [NSString string];
    for (NSString *text in array) {
        result = [result stringByAppendingFormat:@"%@%@",text,separator];
    }
    NSInteger resultLength = result.length;
    if(resultLength - 1 >= 0) {
        NSRange range = NSMakeRange(0, resultLength - 1);
        result = [result substringWithRange:range];
    }
    
    return result;
}

- (NSString *)convertTotalGoalArrayToString:(NSMutableArray *)array separator:(NSString *)separator {
    
    [Globals sortWithNumberArray:array];
    
    NSString *result = [NSString string];
    for (NSString *text in array) {
        if ([text integerValue] > 7) {
            result = [result stringByAppendingFormat:@"7+%@",separator];
        } else {
            result = [result stringByAppendingFormat:@"%ld%@",(long)([text integerValue] - 1),separator];
        }
    }
    NSInteger resultLength = result.length;
    if(resultLength - 1 >= 0) {
        NSRange range = NSMakeRange(0, resultLength - 1);
        result = [result substringWithRange:range];
    }
    
    return result;
}

- (NSString *)convertHalfArrayToString:(NSArray *)array {
    NSString *result = [NSString string];
    for (NSString *textString in array) {
        result = [result stringByAppendingFormat:@"%@ ",textString];
    }
    return result;
}

- (void)disSelectedDanBtn:(UITableViewCell *)currentCell index:(NSInteger)index {
    
    NSArray *array = [[_selectMatchArray objectAtIndex:index] objectForKey:@"selectArray"];
    if (array.count == 0) {
        // 取消胆按钮的选中状态
        UIButton *danBtn = (UIButton *)[currentCell.contentView viewWithTag:1001];
        if (danBtn.isSelected) {
            [danBtn setSelected:NO];
            _selectedDanBtnCount--;
            
            NSMutableDictionary *dic = [_selectMatchArray objectAtIndex:index];
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isDan"];
            
        }
        // 小于三场，胆全清除
        if ([self selectMatchCount] < 3) {
            for (NSMutableDictionary *dicc in self.selectMatchArray) {
                [dicc setObject:[NSNumber numberWithBool:NO] forKey:@"isDan"];
            }
            _selectedDanBtnCount = 0;
            [_betTableView reloadData];
        }
    }
    
}

//新增元素
- (void)insertItem:(NSString *)item WithRowIndex:(NSInteger)index {
    NSMutableArray *array = [[_selectMatchArray objectAtIndex:index] objectForKey:@"selectArray"];
    [array addObject:item];
}

//删除元素
- (void)removeItem:(NSString *)item WithRowIndex:(NSInteger)index {
    NSInteger oldSelectMatchCount = [self selectMatchCount];
    
    NSMutableArray *array = [[_selectMatchArray objectAtIndex:index] objectForKey:@"selectArray"];
    [array removeObject:item];
    
    // 刷新过关方式
    NSInteger currentSelectMatchCount = [self selectMatchCount];
    
    if (currentSelectMatchCount<oldSelectMatchCount) {
        [self updatePassway];
    }
}

// 刷新过关方式
- (void)updatePassway {
    //移除n(n串m)大于比赛场数的过关方式
    NSMutableArray *mutArr=[NSMutableArray arrayWithArray:self.passWayArray];
    for (NSString *str in mutArr) {
        NSInteger matchCount = [str integerValue];
        if (matchCount > [self selectMatchCount]) {
            NSInteger index = [_passWayArray indexOfObject:str];
            [_passWayTagArray removeObjectAtIndex:index];
            [_passWayArray removeObject:str];
        }
    }
    
    //如果胆码数等于比赛场数，清楚所有的胆码
    if (self.selectDanArray.count == [self selectMatchCount]) {
        _selectedDanBtnCount = 0;
        for (NSMutableDictionary *dic in _selectMatchArray) {
            [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isDan"];
        }
        [_betTableView reloadData];
    }
    if (_passWayArray.count == 0) {
        [_passWayBtn setTitle:@"过关方式(必选)" forState:UIControlStateNormal];
        return;
    }
    
    // 更新过关方式按钮显示
    NSString *passWayStr = @"";
    for (NSString *str in _passWayArray) {
        passWayStr = [passWayStr stringByAppendingFormat:@"%@,",str];
    }
    NSInteger passWayStrLength = passWayStr.length;
    if (passWayStrLength - 1 >= 0) {
        passWayStr = [passWayStr substringToIndex:passWayStrLength - 1];
        [_passWayBtn setTitle:passWayStr forState:UIControlStateNormal];
    }
    
}

@end
