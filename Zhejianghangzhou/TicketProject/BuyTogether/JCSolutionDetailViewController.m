//
//  JCSolutionDetailViewController.m  合买竞彩投注 选号详情
//  TicketProject
//
//  Created by sls002 on 13-7-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140725 10:24（洪晓彬）：修改代码规范，改进生命周期，处理内存
//  20140807 18:10（洪晓彬）：进行ipad适配
//  20150819 11:22（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "JCSolutionDetailViewController.h"
#import "SVProgressHUD.h"

#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import "GlobalsProject.h"
#import "UserInfo.h"

#define JCFisttLabelMinY (IS_PHONE ? 10.0f : 20.0f)
#define JCFisrtLabelHeight (IS_PHONE ? 30.0f : 45.0f)

#define JCFisrtColLabelWidth 44.0f * (kWinSize.width / 320.0)
#define JCSecondColLabelWidth 85.0f * (kWinSize.width / 320.0)
#define JCThreeColLabelWidth 58.0f * (kWinSize.width / 320.0)
#define JCFourColLabelWidth 72.0f * (kWinSize.width / 320.0)
#define JCFiveColLabelWidth 50.0f * (kWinSize.width / 320.0)
#define JCFisrtColLabelMinX (kWinSize.width - kWinSize.width * (309.0f / 320.0)) / 2.0f

#define JCTableCellOneLineHeight (IS_PHONE ? 30.0f : 45.0f)

@interface JCSolutionDetailViewController ()

@end
#pragma mark -
#pragma mark @implementation JCSolutionDetailViewController
@implementation JCSolutionDetailViewController
#pragma mark Lifecircle

- (id)initWithSchemeDictionary:(NSDictionary *)dic {
    self = [super init];
    if(self) {
        _schemeDic = [dic retain];
        _lotteryID = [dic intValueForKey:@"lotteryId"];
        [self setTitle:@"选号详情"];
    }
    return self;
}

- (void)dealloc {
    _detailTableView = nil;
    [_schemeDic release];
    [_schemeDetailArray release];
    _schemeDetailArray = nil;
    [_matchDeitalArray release];
    _matchDeitalArray = nil;
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
    
    NSArray *promptLabelTitleArray = [NSArray arrayWithObjects:@"场次",@"主队VS客队",@"玩法",@"投注",@"赛果", nil];
    CGFloat promptLabelMinX = JCFisrtColLabelMinX;
    CGFloat promptLabelWidth = JCFisrtColLabelWidth;
    for (NSInteger index = 0; index < [promptLabelTitleArray count]; index++) {
        if (index == 1) {
            promptLabelWidth = JCSecondColLabelWidth;
            
        } else if (index == 2) {
            promptLabelWidth = JCThreeColLabelWidth;
            
        } else if (index == 3) {
            promptLabelWidth = JCFourColLabelWidth;
            
        } else if (index == 4) {
            promptLabelWidth = JCFiveColLabelWidth;
            
        }
        
        //promptLabel
        CGRect promptLabelRect = CGRectMake(promptLabelMinX - AllLineWidthOrHeight, JCFisttLabelMinY, promptLabelWidth + AllLineWidthOrHeight, JCFisrtLabelHeight);
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
        [promptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
        [promptLabel setText:[promptLabelTitleArray objectAtIndex:index]];
        [promptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [promptLabel setTextAlignment:NSTextAlignmentCenter];
        [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [[promptLabel layer] setBorderWidth:AllLineWidthOrHeight];
        [[promptLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
        [self.view addSubview:promptLabel];
        [promptLabel release];
        
        promptLabelMinX = CGRectGetMaxX(promptLabelRect);
    }
    
    
    //detailTable 竞彩合买方案详细视图
    CGRect detailTableViewRect = CGRectMake(0, JCFisttLabelMinY + JCFisrtLabelHeight, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kNavigationBarHeight - JCFisttLabelMinY - JCFisrtLabelHeight);
    _detailTableView = [[UITableView alloc]initWithFrame:detailTableViewRect style:UITableViewStylePlain];
    [_detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_detailTableView setBackgroundColor:kBackgroundColor];
    _detailTableView.dataSource = self;
    _detailTableView.delegate = self;
    [self.view addSubview:_detailTableView];
    [_detailTableView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _schemeDetailArray = [[NSMutableArray alloc] init];
    _matchDeitalArray = [[NSMutableArray alloc] init];
    [self getDetail];
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
        _detailTableView = nil;
        [_schemeDetailArray release];
        _schemeDetailArray = nil;
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
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"数据获取失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    
    NSLog(@"46-------------->%@",[request responseString]);
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        [_schemeDetailArray addObjectsFromArray:[responseDic objectForKey:@"informationId"]];

        [_matchDeitalArray removeAllObjects];
        
        [GlobalsProject customParserJCOrderMatchDeitalWithDict:responseDic matchDeitalArray:_matchDeitalArray lotteryId:_lotteryID];
        
        [_detailTableView reloadData];
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_matchDeitalArray.count != 0) {
        NSArray *arr = [_matchDeitalArray[0] objectForKey:@"informationId"];
        
        return [arr count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"JCMatchDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CGFloat cellHeight = [self tableCellHeightWidthIndexPath:indexPath tableView:tableView];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:kBackgroundColor];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat labelMinX = JCFisrtColLabelMinX;
    /********************** adjustment end ***************************/
    NSArray *arr = nil;
    if (_matchDeitalArray.count != 0) {
        arr = [_matchDeitalArray[0] objectForKey:@"informationId"];
    }
    
    NSMutableDictionary *oneMatchDetailDict = arr[indexPath.row];//该数组的数据都是IOS自己处理过的，不是服务器原始数据
    NSInteger oneMatchCount = [oneMatchDetailDict intValueForKey:@"oneMatchCount"];
    //dateLabel
    CGRect dateLabelRect = CGRectMake(labelMinX - AllLineWidthOrHeight, - AllLineWidthOrHeight, JCFisrtColLabelWidth + AllLineWidthOrHeight, cellHeight + AllLineWidthOrHeight);
    [self makeLabelWithFrame:dateLabelRect title:[oneMatchDetailDict objectForKey:@"matchTime"] superView:cell.contentView];
    
    labelMinX = CGRectGetMaxX(dateLabelRect);
    
    //teamLabel
    CGRect teamLabelRect = CGRectMake(labelMinX - AllLineWidthOrHeight, - AllLineWidthOrHeight, JCSecondColLabelWidth + AllLineWidthOrHeight, cellHeight + AllLineWidthOrHeight);
    [self makeLabelWithFrame:teamLabelRect title:[oneMatchDetailDict objectForKey:@"teamsMessage"] superView:cell.contentView];
    
    labelMinX = CGRectGetMaxX(teamLabelRect);
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat playTypeLabelMinY = 0.0f;
    CGFloat oddLabelMinY = 0.0f;
    /********************** adjustment end ***************************/
    
    NSArray *jcPlayTypeDetailNumberArray = [oneMatchDetailDict objectForKey:@"jcPlayTypeDetailNumber"];
    NSInteger letball = [oneMatchDetailDict intValueForKey:@"letBall"];
    
    for (NSInteger i = 0; i < [jcPlayTypeDetailNumberArray count]; i++) {
        
        NSDictionary *jcPlayTypeDetailNumberDict = [jcPlayTypeDetailNumberArray objectAtIndex:i];
        NSInteger playTypeCount = [jcPlayTypeDetailNumberDict intValueForKey:@"playTypeMatchCount"];
        
        //playTypeLabel
        CGRect playTypeLabelRect = CGRectMake(labelMinX - AllLineWidthOrHeight,playTypeLabelMinY - AllLineWidthOrHeight, JCThreeColLabelWidth + AllLineWidthOrHeight, oneMatchCount < 2 ? (JCTableCellOneLineHeight * 2 + AllLineWidthOrHeight) : (playTypeCount * JCTableCellOneLineHeight + AllLineWidthOrHeight));
        
        NSString *playName = @"";
        if ([[jcPlayTypeDetailNumberDict stringForKey:@"isLet"] isEqualToString:@"YES"]) {
            if (letball > 0) {
                playName = [NSString stringWithFormat:@"%@(+%ld)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],(long)letball];
            } else {
                playName = [NSString stringWithFormat:@"%@(%ld)",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"],(long)letball];
            }
            
        } else {
            playName = [NSString stringWithFormat:@"%@",[jcPlayTypeDetailNumberDict objectForKey:@"palyTypeName"]];
        }
        
        [self makeLabelWithFrame:playTypeLabelRect title:playName superView:cell.contentView];
        
        playTypeLabelMinY = CGRectGetMaxY(playTypeLabelRect);
        
        NSArray *typeNumberArray = [jcPlayTypeDetailNumberDict objectForKey:@"typeNumber"];
        
        for (NSInteger j = 0; j < [typeNumberArray count]; j++) {
            
            NSDictionary *dict = [typeNumberArray objectAtIndex:j];
            
            //oddLabel
            CGRect oddLabelRect = CGRectMake(CGRectGetMaxX(playTypeLabelRect) - AllLineWidthOrHeight, oddLabelMinY - AllLineWidthOrHeight, JCFourColLabelWidth + AllLineWidthOrHeight, oneMatchCount < 2 ? (JCTableCellOneLineHeight * 2 + AllLineWidthOrHeight) : (JCTableCellOneLineHeight + AllLineWidthOrHeight));
            [self makeLabelWithFrame:oddLabelRect title:[NSString stringWithFormat:@"%@%@",[dict stringForKey:@"text"],[dict stringForKey:@"odds"]] superView:cell.contentView];
            
            oddLabelMinY = CGRectGetMaxY(oddLabelRect);
        }
        
        //matchResultLabel
        CGRect matchResultLabelRect = CGRectMake(CGRectGetMaxX(playTypeLabelRect) + JCFourColLabelWidth - AllLineWidthOrHeight, CGRectGetMinY(playTypeLabelRect), JCFiveColLabelWidth + AllLineWidthOrHeight, CGRectGetHeight(playTypeLabelRect));
        [self makeLabelWithFrame:matchResultLabelRect title:[jcPlayTypeDetailNumberDict objectForKey:@"oneMatchResult"] superView:cell.contentView];
    }

    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableCellHeightWidthIndexPath:indexPath tableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getDetail {
    [SVProgressHUD showWithStatus:@"加载中"];
    NSString *schemeId = [_schemeDic objectForKey:@"id"];
    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:schemeId forKey:@"schemeId"];
    
    [self clearHTTPRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetJCOrderDetailMessage userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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

- (CGFloat)tableCellHeightWidthIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSArray *arr = nil;
    if (indexPath.section == 0) {
        // 优化前数据
        arr = [_matchDeitalArray[0] objectForKey:@"informationId"];
    }
    
    NSMutableDictionary *oneMatchDetailDict = arr[indexPath.row];
    NSInteger oneMatchCount = [oneMatchDetailDict intValueForKey:@"oneMatchCount"];
    if (oneMatchCount <= 1) {
        return JCTableCellOneLineHeight * 2;
    } else {
        return JCTableCellOneLineHeight * oneMatchCount;
    }
}

- (CGRect)makeLabelWithFrame:(CGRect)frame title:(NSString *)title superView:(UIView *)superView {//感觉要返回什么，又不知道可以返回啥，随便返回吧
    UILabel *playTypeLabel = [[UILabel alloc] initWithFrame:frame];
    [playTypeLabel setBackgroundColor:[UIColor whiteColor]];
    [playTypeLabel setTextAlignment:NSTextAlignmentCenter];
    [playTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [[playTypeLabel layer] setBorderWidth:AllLineWidthOrHeight];
    [playTypeLabel setNumberOfLines:10];
    [[playTypeLabel layer] setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
    [playTypeLabel setText:title];
    [superView addSubview:playTypeLabel];
    [playTypeLabel release];
    return frame;
}

@end
