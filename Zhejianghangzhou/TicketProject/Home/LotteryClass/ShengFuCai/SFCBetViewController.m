//
//  SFCBetViewController.m
//  TicketProject
//
//  Created by 刘坤 on 16/3/1.
//  Copyright (c) 2016年 sls002. All rights reserved.
//

#import "SFCBetViewController.h"
#import "BetTableViewCell.h"
#import "BetRuleViewController.h"
#import "CustomBetViewCell.h"
#import "CustomBottomView.h"
#import "SVProgressHUD.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "UserInfo.h"
#import "PaySucceedViewController.h"
#import "UserLoginViewController.h"
#import "LaunchChippedViewController.h"

#import "SFCViewController.h"
#import "SelectRechargeTypeViewController.h"

#import "Globals.h"
#import "SFCParserNumber.h"
#import "DuangAlert.h"

#define kInputViewHeight (IS_PHONE ? 45.0f : 60.0f)
#define kFootBallTableViewFootViewHeight (IS_PHONE ? 53.0f : 90.0f)
#define FootBallBetViewCellHeight (IS_PHONE ? 90.0f : 150.0f)


@interface SFCBetViewController ()
@property(nonatomic,copy)NSString *allstr;

@end

@implementation SFCBetViewController

- (id)initWithMatchArray:(NSMutableArray *)matchArray andScoreDic:(NSMutableDictionary *)scoreDic LotteryDic:(NSDictionary *)dic {
    self = [super init];
    if(self) {
        self.selectMatchArray = matchArray;
        self.selectedScoreDic = scoreDic;
        self.lotteryDic = dic;
        self.title = @"胜负彩投注";
    }
    
    return self;
}

- (void)dealloc {
    _betTableView = nil;
    _inputView = nil;
    _inputField = nil;
    _bottomView = nil;
    _overlayView = nil;
    _secrecyLevel = nil;
    _description = nil;
    
    [_launchChippedProportionRequest release];
    _launchChippedProportionRequest = nil;
    
    [_selectMatchArray release];
    [_orderDetailDict release];
    _orderDetailDict = nil;
    
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
    CGFloat topBtnWidht = IS_PHONE ? 300.0f : 600.0f;
    CGFloat topBtnHeight = IS_PHONE ? 32.5f : 50.0f;
    
    CGFloat topBtnBetTableViewLandscapeInterval = IS_PHONE ? 12.0f : 24.0f;
    
    CGFloat inputViewPassWayBtnMinX = 22.0f;
    CGFloat inputViewPassWayBtnHeight = IS_PHONE ? 28.0f : 40.0f;
    
    CGFloat inputViewPromptLabelWidth = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat touPromptLabelInputFieldLandscapeInterval = IS_PHONE ? 10.0f : 20.0f;
    CGFloat inputFieldWidth = IS_PHONE ? 80.0f : 160.0f;
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
    
    //touPromptLabel
    CGRect touPromptLabelRect = CGRectMake(inputViewPassWayBtnMinX, (kInputViewHeight - inputViewPassWayBtnHeight) / 2.0f, inputViewPromptLabelWidth, inputViewPassWayBtnHeight);
    UILabel *touPromptLabel = [[UILabel alloc]initWithFrame:touPromptLabelRect];
    [touPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [touPromptLabel setText:@"投"];
    [touPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_inputView addSubview:touPromptLabel];
    [touPromptLabel release];
    
    //inputField
    CGRect inputFieldRect = CGRectMake(CGRectGetMaxX(touPromptLabelRect) + touPromptLabelInputFieldLandscapeInterval, CGRectGetMinY(touPromptLabelRect), inputFieldWidth, inputViewPassWayBtnHeight);
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
    [_inputField setDelegate:self];
    [_inputView addSubview:_inputField];
    [_inputField release];
    
    //beiPromptLabel
    CGRect beiPromptLabelRect = CGRectMake(CGRectGetMaxX(inputFieldRect) + touPromptLabelInputFieldLandscapeInterval, CGRectGetMinY(touPromptLabelRect), inputViewPromptLabelWidth, inputViewPassWayBtnHeight);
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
    
    _orderDetailDict = [[NSMutableDictionary alloc] init];
    _selectMatchDic = [[NSMutableDictionary alloc]initWithDictionary:[self.selectedScoreDic objectForKey:kSelectMatchDic]];
    
    [self updateBottomView];
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
    
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    _requestData = NO;
    _pushViewBegin = NO;
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([_selectMatchDic count] == 0) {
            return 0;
        } else {
            return [_selectMatchDic count];
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FootBallBetViewCell";
    CustomBetViewCell *cell = (CustomBetViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[CustomBetViewCell alloc] initWithHeihgt:FootBallBetViewCellHeight style:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
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
    
    cell.mainTeamName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"hostTeam"]];
    cell.guestTeamName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questTeam"]];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat oneRowThreeBtnMinY = IS_PHONE ? 36.0f : 58.0f;
    CGFloat oneRowThreeBtnWidth = IS_PHONE ? 70.0f : 140.0f;
    CGFloat oneRowThreeBtnHeight = IS_PHONE ? 32.0f : 60.0f;
    
    CGFloat danBtnMinX = 0;
    CGFloat danBtnMaginX = IS_PHONE ? 5.0 : 20.0f;
    CGFloat danBtnMinY = 0.0;
    CGFloat danBtnHeight = IS_PHONE ? 31.0f : 54.0f;
    
    danBtnMinY = (FootBallBetViewCellHeight - danBtnHeight) / 2.0f;
    CGFloat btnLandscapeInterval = IS_PHONE ? 0.0f : 20.0f;
    /********************** adjustment end ***************************/
    
    cell.letBall = @"VS";
    [cell.oneLabel setHidden:YES];
    [cell.twoLabel setHidden:YES];
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake((kWinSize.width - 210) / 2 + i * (oneRowThreeBtnWidth + btnLandscapeInterval + AllLineWidthOrHeight), oneRowThreeBtnMinY, oneRowThreeBtnWidth, oneRowThreeBtnHeight)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.adjustsImageWhenHighlighted = NO;
        [btn setTitleColor:kDarkGrayColor forState:UIControlStateNormal];
        if(i == 0) {
            [btn setTitle:[NSString stringWithFormat:@"胜%@",[dic objectForKey:@"s"]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleLeftButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
            [btn setTag:3];
            
        } else if(i == 1) {
            [btn setTitle:[NSString stringWithFormat:@"平%@",[dic objectForKey:@"p"]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleCenterButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f  ] forState:UIControlStateSelected];
            [btn setTag:1];
            
        } else if(i == 2) {
            [btn setTitle:[NSString stringWithFormat:@"负%@",[dic objectForKey:@"f"]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"halfAngleRightButton_Select.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateSelected];
            [btn setTag:0];
        }
        
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
    
    return cell;
}

#pragma mark -UITableViewDelegate
//让button被选中
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //被选中比赛的对应按钮的 tag 数组
    if (indexPath.row < [_selectMatchDic count]) {
        NSArray *array = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        for (NSString *str in array) {
            for (UIView *view in cell.contentView.subviews) {
                if([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    if([[NSString stringWithFormat:@"%ld", (long)btn.tag] isEqualToString:str]) {
                        [btn setSelected:YES];
                    }
                }
            }
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
        return kFootBallTableViewFootViewHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectMatchArray count] == 0) {
        return 8.5;
    } else {
        return FootBallBetViewCellHeight;
    }
}

#pragma mark - 配置footview
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    /********************** adjustment 控件调整 ***************************/
    CGFloat checkBtnMinX = 30.0f;
    CGFloat checkBtnSize = IS_PHONE ? 18.0f : 27.0f;
    CGFloat checkBtnMagin = (kFootBallTableViewFootViewHeight - checkBtnSize) / 2.0f - 5.0f;
    
    CGFloat promptLabelAddX = 5.0f;
    CGFloat promptLabelWidth = IS_PHONE ? 80.0f : 120.0f;
    CGFloat ruleBtnWidht = IS_PHONE ? 90.0f : 150.0f;
    /********************** adjustment end ***************************/
    //footView
    CGRect footViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kFootBallTableViewFootViewHeight);
    UIView *footView = [[UIView alloc]initWithFrame:footViewRect];
    [footView setClipsToBounds:YES];
    [footView setBackgroundColor:kBackgroundColor];
    
    //footBackImageView
    CGRect footBackImageViewRect = CGRectMake(0, -1, CGRectGetWidth(tableView.frame), kFootBallTableViewFootViewHeight + 1);
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
    [clearBtn addTarget:self action:@selector(clearSelect:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:clearBtn];
    [clearBtn release];
    
    
    return [footView autorelease];
}

#pragma mark - UIAlertViewdelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    if (alertView.tag == 2) {
        if(buttonIndex == 1) {
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //监听键盘出现和消失的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([text length] > 5)
        return NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0)
        textField.text = @"1";
    [self updateBottomView];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    _requestData = NO;
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"购买失败"];
    
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    _requestData = NO;
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
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
        [chippedDic setObject:_lotteryDic forKey:@"lotteryDic"];
        [chippedDic setObject:[self getBuyContentString] forKey:@"buyContent"];
        [chippedDic setObject:[NSString stringWithFormat:@"%ld",(long)_betCount] forKey:@"betCount"];
        [chippedDic setObject:_inputField.text forKey:@"multiple"];
        
        if (_pushViewBegin) {
            return;
        }
        _pushViewBegin = YES;
        LaunchChippedViewController *chipped = [[LaunchChippedViewController alloc]initWithBetDictionary:chippedDic];
        [self.navigationController pushViewController:chipped animated:YES];
        [chipped release];
    }
}

- (void)chippedClick:(id)sender {
    [self loadLaunchChippedProportion];
}

//点击"购彩大厅"  弹出选项框
- (void)backToHome:(id)sender {
    if (_inputField) {
        [_inputField resignFirstResponder];
    }
    if(_selectMatchDic.count > 0) {//如果有数据则弹出，没有则返回
        [Globals alertWithMessage:@"返回购彩大厅将清空所有已选的号码" delegate:self tag:1];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [self dismissViewControllerAnimated:YES completion:nil];//幸运选号的时候是present
    }
}

//继续选择比赛
- (void)goonSelect:(id)sender {
    UIViewController *detailView = [self pushViewCOntrollerWithSelectedBallsDic:_selectedScoreDic lotteryDic:_lotteryDic];
    [self.navigationController pushViewController:detailView animated:YES];
    [detailView release];
}

- (UIViewController *)pushViewCOntrollerWithSelectedBallsDic:(NSDictionary *)ballsDic lotteryDic:(NSDictionary *)dic {
    SFCViewController *detailView = [[SFCViewController alloc] initWithSelectedBallsDic:ballsDic LotteryDic:dic];
    detailView.delegate = self;
    return detailView;
}

//清空
- (void)clearSelect:(id)sender {
    [_selectMatchDic removeAllObjects];
    
    NSString *formateSelectBalls = [SFCParserNumber getSFCTextWithDict:_selectMatchDic];
    
    NSInteger betCount = [SFCParserNumber getCountForSFCWithSelectMatchDic:_selectMatchDic];
    
    [_selectedScoreDic setObject:formateSelectBalls forKey:kSelectBalls];
    [_selectedScoreDic setObject:[NSNumber numberWithInteger:betCount] forKey:kBetCount];
    [_selectedScoreDic setObject:_selectMatchDic forKey:kSelectMatchDic];
    
    [_bottomView setMatchCount:0 money:0];
    [_betTableView reloadData];
}

//付款
- (void)pay:(id)sender {
    if([UserInfo shareUserInfo].userID) {
        if (_betCount != 0) {
            if (_allstr && _allstr.length>0) {
                DuangAlert *duang = [[DuangAlert alloc] initWithTitle:@"发起复制需要填写以下内容" settings:@[@"永久公开",@"开赛后公开"] selected:^(NSInteger index, NSDictionary *backDic) {
                    if (index == 1) {
                        _secrecyLevel = [[backDic objectForKey:@"index"] integerValue] == 0 ? @"0" : @"2";
                        _description = [[backDic objectForKey:@"text"] copy];
                        
                        NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
                        
                        CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)(_betCount * multiple * 2)] leftText:@"取消" rightText:@"确定"];
                        [customAlert setTag:76];
                        [customAlert show];
                        [customAlert release];
                    }
                }];
                [duang show];
                [duang release];
            }else{
                NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
                
                CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:self content:[NSString stringWithFormat:@"本次支付将从您的账号中扣除%ld元",(long)(_betCount * multiple * 2)] leftText:@"取消" rightText:@"确定"];
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

- (void)paymoneyRequest:(NSDictionary *)infoDic {
    if (_requestData) {
        return;
    }
    _requestData = YES;
    [SVProgressHUD showWithStatus:@"加载中"];
    if (_httpRequest) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
    
    
    /** 就这里的通信没用实验室的验证加密方法，因为后台也没加，这里可能出现大数据量的传输，加密过程会出现丢失情况 */
    NSString *infoStr = [infoDic JSONString];
    NSString *currentDate = [InterfaceHelper getCurrentDateString];
    NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
    NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:[UserInfo shareUserInfo].userID == nil ? @"-1" : [UserInfo shareUserInfo].userID TimeStamp:currentDate];
#if Log_SWITCH_HTTP_FORM
    NSLog(@"infoStr -> %@", infoStr);
    NSLog(@"auth ->  %@", auth);
#endif
    
    _httpRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kBaseUrl]];
    [_httpRequest setNumberOfTimesToRetryOnTimeout:1];
    [_httpRequest setPostValue:infoStr forKey:kInfo];
    [_httpRequest setPostValue:auth == nil ? @"" : auth forKey:kAuth];
    [_httpRequest setPostValue:HTTP_REQUEST_BuyLotteryTicket forKey:kOpt];
    [_httpRequest setPersistentConnectionTimeoutSeconds:60.0f];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

#pragma mark -Customized: Private (General)
//传入服务器的 info 字符串
- (NSDictionary *)combineInfosOfPayoff {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *lotteryID = [_lotteryDic objectForKey:@"lotteryid"];
    NSString *issueID = [_lotteryDic objectForKey:@"isuseId"];
    NSString *multiple = [NSString stringWithFormat:@"%ld",(long)[_inputField.text integerValue]];
//    NSString *schemeSumMoney = [NSString stringWithFormat:@"%ld",(long)_betCount * 2];
    NSString *schemeSumMoney = [NSString stringWithFormat:@"%ld",(long)_betCount * 2 * ([_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue])];
    NSString *schemeSumNum = [NSString stringWithFormat:@"%ld",(long)_betCount];

    NSString *autoStopAtWinMoney = [NSString stringWithFormat:@"%d",1];
    NSString *chaseBuyedMoney = [NSString stringWithFormat:@"%ld",(long)_betCount * 0];
    
    NSArray *buyContent = [self getBuyContentString];
    
    NSArray *chaseList = [self getChaseListString];
    
    [dic setObject:lotteryID forKey:@"lotteryId"];
    [dic setObject:issueID forKey:@"isuseId"];
    [dic setObject:multiple forKey:@"multiple"];
    [dic setObject:@"1" forKey:@"share"];
    [dic setObject:@"1" forKey:@"buyShare"];
    [dic setObject:@"0" forKey:@"assureShare"];
    [dic setObject:@"0" forKey:@"schemeBonusScale"];
    [dic setObject:@"" forKey:@"title"];
    [dic setObject:@"0" forKey:@"secrecyLevel"];
    [dic setObject:schemeSumMoney forKey:@"schemeSumMoney"];
    [dic setObject:schemeSumNum forKey:@"schemeSumNum"];
    [dic setObject:autoStopAtWinMoney forKey:@"autoStopAtWinMoney"];
    [dic setObject:@"0" forKey:@"chase"];
    [dic setObject:chaseBuyedMoney forKey:@"chaseBuyedMoney"];
    [dic setObject:buyContent forKey:@"buyContent"];
    [dic setObject:chaseList forKey:@"chaseList"];
    if (_allstr == nil || [_allstr isEqualToString:@""]) {
        
    }else{
        [dic setObject:_secrecyLevel forKey:@"secrecyLevel"];
        [dic setObject:_description forKey:@"description"];
        [dic setObject:_allstr forKey:@"isMayCopy"];
        
    }
    
    
    NSInteger detailMoney = [chaseBuyedMoney integerValue] > 0 ? [chaseBuyedMoney integerValue] : [schemeSumMoney integerValue];
    [_orderDetailDict removeAllObjects];
    [_orderDetailDict setObject:[NSNumber numberWithInteger:detailMoney] forKey:@"consumeMoney"];
    
    return dic;
}

//投注内容的json字符串
- (NSArray *)getBuyContentString {
    //投注内容
    NSMutableArray *buyContentArray = [NSMutableArray array];//投注内容数组
    
    NSInteger betCount = 1;
    for (NSInteger i = betCount - 1; i >= 0 ; i--) {
        // 提交时只能有一个玩法
        NSString *lotterynumbers = [NSString string];    // 所选的号码组合
        NSString *playtypes = @"7401";                   // 玩法ID
        NSInteger betCounts = 0;
        NSInteger betAmounts = 0;
        
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];//投注内容字典  每一注都是一个字典

        // 注数和金额计算
        NSInteger betcount = [[NSString stringWithFormat:@"%@",[_selectedScoreDic objectForKey:kBetCount]] integerValue];
        betCounts += betcount;          // 注数
        betAmounts += betcount * 2;     // 金额
        
        // 号码组合
        NSString *lotterynum = [NSString stringWithFormat:@"%@",[_selectedScoreDic objectForKey:kSelectBalls]]; // 取得一串号码
        lotterynum = [lotterynum stringByReplacingOccurrencesOfString:@" " withString:@""]; // 去掉空格
        lotterynumbers = [lotterynumbers stringByAppendingString:lotterynum];
        
        NSString *sumNum = [NSString stringWithFormat:@"%ld",(long)betCounts];
        // 追号的时候不乘以倍数，没追号的时候乘以倍数
        NSString *sumMoney = [NSString stringWithFormat:@"%ld",(long)(betAmounts * [_inputField.text integerValue])];
        [contentDic setObject:lotterynumbers forKey:@"lotteryNumber"];
        [contentDic setObject:playtypes forKey:@"playType"];
        [contentDic setObject:sumNum forKey:@"sumNum"];
        [contentDic setObject:sumMoney forKey:@"sumMoney"];
        
        [buyContentArray addObject:contentDic];
    }
    
    
    return buyContentArray;
}

- (NSArray *)getChaseListString {
    NSMutableArray *chaseArray = [NSMutableArray array];
    return chaseArray;
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    }
}


//胜平负  和 总进球
- (void)buttonSelected:(id)sender {
    UIButton *btn = sender;
    UITableViewCell *footBallBetCell;
    if (IS_IOS7 && !IS_IOS8) {
        footBallBetCell = (UITableViewCell *)btn.superview.superview.superview;
    } else {
        footBallBetCell = (UITableViewCell *)btn.superview.superview;
    }
    
    NSInteger selectIndex = [_betTableView indexPathForCell:footBallBetCell].row;
    
    if(btn.isSelected) {
        [self removeSelectedItemWithValue:[NSString stringWithFormat:@"%ld", (long)btn.tag] RowIndex:selectIndex];
        
        NSString *formateSelectBalls = [SFCParserNumber getSFCTextWithDict:_selectMatchDic];
        
        NSInteger betCount = [SFCParserNumber getCountForSFCWithSelectMatchDic:_selectMatchDic];
        
        [_selectedScoreDic setObject:formateSelectBalls forKey:kSelectBalls];
        [_selectedScoreDic setObject:[NSNumber numberWithInteger:betCount] forKey:kBetCount];
        [_selectedScoreDic setObject:_selectMatchDic forKey:kSelectMatchDic];
        
        [btn setSelected:NO];
        
        [self updateBottomView];
        [_betTableView reloadData];
        
        return;
    }
    
    [self addSelectedItemWithValue:[NSString stringWithFormat:@"%ld", (long)btn.tag] RowIndex:selectIndex];
    
    NSString *formateSelectBalls = [SFCParserNumber getSFCTextWithDict:_selectMatchDic];
    
    NSInteger betCount = [SFCParserNumber getCountForSFCWithSelectMatchDic:_selectMatchDic];
    
    [_selectedScoreDic setObject:formateSelectBalls forKey:kSelectBalls];
    [_selectedScoreDic setObject:[NSNumber numberWithInteger:betCount] forKey:kBetCount];
    [_selectedScoreDic setObject:_selectMatchDic forKey:kSelectMatchDic];

    [btn setSelected:YES];
    
//
    [self updateBottomView];
    [_betTableView reloadData];
}

- (void)removeSelectedItemWithValue:(NSString *)value RowIndex:(NSInteger)index {
    NSMutableArray *selectedArray = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if(selectedArray == nil){
        return;
    }
    [selectedArray removeObject:value];
    
    [_selectMatchDic setObject:selectedArray forKey:[NSString stringWithFormat:@"%ld",(long)index]];
}

- (void)addSelectedItemWithValue:(NSString *)value RowIndex:(NSInteger)index {
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    NSMutableArray *arrTemp = [_selectMatchDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    if ([arrTemp count]>0) {
        [selectedArray addObjectsFromArray:arrTemp];
    }
    
    if (value) {
        [selectedArray addObject:value];
    }
    
    [_selectMatchDic setObject:selectedArray forKey:[NSString stringWithFormat:@"%ld",(long)index]];
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
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [_inputView setFrame:CGRectMake(0, kScreenSize.height - keyBoardRect.size.height - kInputViewHeight - 64.0f, kWinSize.width, kInputViewHeight)];
    
    [UIView commitAnimations];
}

//键盘消失时响应
- (void)keyboardWillHide:(NSNotification *)notification {
    [_overlayView setHidden:YES];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [_inputView setFrame:CGRectMake(0, kScreenSize.height - kBottomHeight - kInputViewHeight - 64.0f, kWinSize.width, kInputViewHeight)];
    
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - updateBottomView更新底部注数金额
// 更新底部注数及金额
- (void)updateBottomView {
    _betCount = [SFCParserNumber getCountForSFCWithSelectMatchDic:_selectMatchDic];              // 总注数
    NSInteger multiple = [_inputField.text integerValue] == 0 ? 1 : [_inputField.text integerValue];  // 倍数
    
    [_bottomView setMatchCount:_betCount money:_betCount * multiple * 2];
}

@end
