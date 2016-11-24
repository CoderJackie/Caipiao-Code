//
//  DLTBetViewController.m 购彩大厅－大乐透投注
//  TicketProject
//
//  Created by sls002 on 13-5-29.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20141009 17:25（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20141009 17:46（洪晓彬）：进行ipad适配

#import "DLTBetViewController.h"
#import "BetTableViewCell.h"
#import "DLTViewController.h"
#import "SetIssueAndTimeView.h"
#import "XFNavigationViewController.h"

#import "CalculateBetCount.h"
#import "Globals.h"
#import "MyTool.h"
#import "RandomNumber.h"

#define kAutoSelectRedBallCount 5
#define kAutoSelectBlueBallCount 2
#define kAutoSelectRedMaxNumber 35
#define kAutoSelectBlueMaxNumber 12

@interface DLTBetViewController ()

@end

#pragma mark -
#pragma mark @implementation DLTBetViewController
@implementation DLTBetViewController
#pragma mark Lifecircle
- (void)loadView {
    _hasChaseView = YES;
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"大乐透投注";
}

- (void)viewWillAppear:(BOOL)animated {
    if (!_isSupportShake)
        _autoAddBtn.hidden = YES;
    
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -UITableViewDelegate
- (UIViewController *)pushViewCOntrollerWithSelectedBallsDic:(NSDictionary *)ballsDic lotteryDic:(NSDictionary *)dic atRowIndex:(NSInteger)index {
    DLTViewController *detailView = [[DLTViewController alloc]initWithSelectedBallsDic:ballsDic lotteryDic:dic atRowIndex:index];
    detailView.baseDelegate = self;
    return detailView;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)handAddBalls:(id)sender { //自选一组号码  点击自选按钮  调用
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
    [dic setObject:_playtype forKey:kBetType];
    [dic setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
    if (self.betInfoDic && self.betInfoDic.count > 0)
        [dic setObject:[NSNumber numberWithInteger:23] forKey:@"hasBetDic"];
    else
        [dic setObject:[NSNumber numberWithInteger:20] forKey:@"hasBetDic"];
    
    DLTViewController *selectBalls = [[DLTViewController alloc]initWithBetViewController:self lotteryDic:_lotteryDic andBallsDic:dic];
    [selectBalls setIsPresentView:YES];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:selectBalls];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [selectBalls release];
    [nav release];
}

- (void)autoAddBalls:(id)sender { //点击机选按钮 调用
    NSMutableArray *redArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:kAutoSelectRedMaxNumber minNum:1 andExpectedRandomCounts:kAutoSelectRedBallCount]];
    
    NSMutableArray *blueArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:kAutoSelectBlueMaxNumber minNum:1 andExpectedRandomCounts:kAutoSelectBlueBallCount]];
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    
    // 显示的时候要给个位数的球前面加0，如号码 （1 2 15 20 10 1 13) ，应该转换为01 02 15 20 10 01 13)
    NSString *selectBallsStr = [cal changeDLTWithRedArray:[cal convertToStringArrayWith:redArray]
                                                 TuoArray:nil
                                                BlueArray:[cal convertToStringArrayWith:blueArray]
                                                     Type:3901];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.betInfoDic];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:selectBallsStr forKey:kSelectBalls];
    [dicInfo setObject:@"普通投注" forKey:kBetType];
    [dicInfo setObject:[NSNumber numberWithInt:1] forKey:kBetCount];
    [dicInfo setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
    [dicInfo setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
    [dicInfo setObject:redArray forKey:kOneViewBalls];
    [dicInfo setObject:blueArray forKey:kTwoViewBalls];
    NSInteger count = self.betInfoDic.count;
    [dic setObject:dicInfo forKey:[NSString stringWithFormat:@"%ld",(long)count]];
    
    self.betInfoDic = dic;
    [_tableViews reloadData];
    
    [self updateBetCountOfBottomView];
}

#pragma mark -Customized: Private (General)
//付款
- (NSDictionary *)combineInfosOfPayoff {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *lotteryID = [_lotteryDic objectForKey:@"lotteryid"];
    NSString *issueID = [_lotteryDic objectForKey:@"isuseId"];
    NSString *multiple = [NSString stringWithFormat:@"%ld",(long)_issueView.multiple];      // 倍数
    
    // schemeSumMoney = 总注数 * 追的期数 * 2
    NSString *schemeSumMoney = [NSString stringWithFormat:@"%ld",(long)([self calculateTotalAmountAndBetCounts] * _issueView.multiple * (_issueView.isZhuiHao == YES ? 3 : 2))];
    // 总注数
    NSString *schemeSumNum = [NSString stringWithFormat:@"%ld",(long)[self calculateTotalAmountAndBetCounts]];
    // 追多少期,如果为1，则为0；
    NSString *chase = [NSString stringWithFormat:@"%ld",(long)_issueView.chase < 2 ? 0 : (long)_issueView.chase];
    // 追期的时候是否中奖后停止追号
    NSString *autoStopAtWinMoney = [NSString stringWithFormat:@"%d",_issueView.isZhuiQiStop];
    // chaseBuyedMoney = 总注数 * 倍数 *  追的期数 * 每注的价钱; （大乐透追加玩法 3元一注）    // 子类重写该方法
    NSString *chaseBuyedMoney = [NSString stringWithFormat:@"%ld",(long)_issueView.chase < 2 ? 0 : (long)([self calculateTotalAmountAndBetCounts] * _issueView.multiple * _issueView.chase * (_issueView.isZhuiHao == YES ? 3 : 2))];
    
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
    [dic setObject:schemeSumMoney forKey:@"sumMoney"];
    [dic setObject:schemeSumNum forKey:@"sumNum"];
    [dic setObject:autoStopAtWinMoney forKey:@"autoStopAtWinMoney"];
    [dic setObject:chase forKey:@"chase"];
    [dic setObject:chaseBuyedMoney forKey:@"chaseBuyedMoney"];
    [dic setObject:buyContent forKey:@"buyContent"];
    [dic setObject:chaseList forKey:@"chaseList"];
    
    [_orderDetailDict removeAllObjects];
    [_orderDetailDict setObject:[chaseBuyedMoney integerValue] > 0 ? chaseBuyedMoney : schemeSumMoney forKey:@"consumeMoney"];
    return dic;
}

// 投注内容的json字符串
- (NSArray *)getBuyContentString {
    //投注内容
    NSMutableArray *buyContentArray = [NSMutableArray array];//投注内容数组
    
    
    NSInteger betCount = self.betInfoDic.count;
    for (NSInteger i = betCount - 1; i >= 0 ; i--) {
        // 提交时只能有一个玩法
        NSString *lotterynumbers = [NSString string];    // 所选的号码组合
        NSString *playtypes = [NSString string];         // 玩法ID     3901,3903
        
        NSInteger betCounts = 0;
        NSInteger betAmounts = 0;
        
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];//投注内容字典  每一注都是一个字典
        
        
        NSDictionary *betDic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];//某个号码
        // 玩法
        NSString *betTypeStr = [betDic objectForKey:kBetType];
        NSInteger playId = [betDic intValueForKey:@"playId"];
        
        if([betTypeStr isEqualToString:@"普通投注"] || playId == 3901 || playId == 3902) {
            playtypes = @"3901";
            if (_issueView.isZhuiHao)
                playtypes = @"3902";
        } else if ([betTypeStr isEqualToString:@"前区胆拖投注"] || playId == 3903 || playId == 3904) {
            playtypes = @"3903";
            if (_issueView.isZhuiHao)
                playtypes = @"3904";
        } else if ([betTypeStr isEqualToString:@"后区胆拖投注"] || playId == 3906 || playId == 3908) {
            playtypes = @"3906";
            if (_issueView.isZhuiHao)
                playtypes = @"3908";
        } else if ([betTypeStr isEqualToString:@"双区胆拖投注"] || playId == 3907 || playId == 3909) {
            playtypes = @"3907";
            if (_issueView.isZhuiHao)
                playtypes = @"3909";
        }
        
        // 注数和金额计算
        NSInteger betcount = [[NSString stringWithFormat:@"%@",[betDic objectForKey:kBetCount]] integerValue];
        betCounts += betcount;          // 注数
        betAmounts += betcount * (_issueView.isZhuiHao == YES ? 3 : 2);     // 金额(追号投注时3元一注)
        
        // 号码组合
        NSString *lotterynum = [NSString stringWithFormat:@"%@",[betDic objectForKey:kSelectBalls]]; // 取得一串号码
        //        lotterynum = [lotterynum substringToIndex:lotterynum.length - 1]; // 去掉最好一个空格
        lotterynum = [lotterynum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];  // 去掉最好一个空格
        lotterynumbers = [lotterynumbers stringByAppendingString:lotterynum];
        
        NSString *sumNum = [NSString stringWithFormat:@"%ld",(long)betCounts];
        // 追号的时候不乘以倍数，没追号的时候乘以倍数
        NSString *sumMoney = [NSString stringWithFormat:@"%ld",(long)(betAmounts * ([_issueView chase] > 1 ? 1 : [_issueView multiple]))];
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
    NSInteger count = _issueView.chase;    // 追多少期
    
    NSArray *chaseList = [_lotteryDic objectForKey:@"dtCanChaseIsuses"]; //  服务器返回能追的期
    if (chaseList.count > 0) {      // 有的话才能进行追期
        
        if (count == 1) {    // 如果输入的为1，则不进行追期
            
        } else if (count >= 2) {
            for (int i = 0; i < count; i++) {
                NSMutableDictionary *chaseDic = [NSMutableDictionary dictionary];
                
                NSString *isuseId = [[chaseList objectAtIndex:i] objectForKey:@"isuseId"];
                // 投多少倍
                NSString *multiple = [NSString stringWithFormat:@"%ld",(long)_issueView.multiple];
                // 所投的注数需要花费的金额
                NSString *money = [NSString stringWithFormat:@"%ld",(long)(_betCount * _issueView.multiple * (_issueView.isZhuiHao == YES ? 3 : 2))];
                
                [chaseDic setObject:isuseId forKey:@"isuseId"];
                [chaseDic setObject:multiple forKey:@"multiple"];
                [chaseDic setObject:money forKey:@"money"];
                
                [chaseArray addObject:chaseDic];
            }
        }
    }
    return chaseArray;
}

- (CGFloat)tableCellHeight:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (self.betInfoDic.count == 0) {
        return 20.0f;
    }
    NSDictionary *infoDic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)(self.betInfoDic.count - indexPath.row - 1)]];
    NSString *betNumber = [infoDic objectForKey:kSelectBalls];
    NSArray *array;
    if ([MyTool string:betNumber containCharacter:@"+"]) {
        array = [betNumber componentsSeparatedByString:@"+"];
    } else if ([MyTool string:betNumber containCharacter:@"-"]) {
        array = [betNumber componentsSeparatedByString:@"-"];
    } else {
        return 0;
    }
    if ([array count] <= 1) {
        return 0;
    }
    NSString *redNumber = [array objectAtIndex:0];
    NSString *blueNumber = [array objectAtIndex:1];
    
    NSString *numbers = [NSString stringWithFormat:@"%@ %@",redNumber,blueNumber];
    CGSize expectedSize = [numbers sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]
                              constrainedToSize:CGSizeMake(CGRectGetWidth(tableView.frame) - betNumberLabelMaginRight - betNumberLabelMinX * 2 + XFIponeIpadFontSize14, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    return (expectedSize.height + tableCellLabelHeight <= tableCellHeihgt ? tableCellHeihgt : expectedSize.height + tableCellLabelHeight + tabelCellLabelImageInterval) + 20.0f;
}

- (BOOL)isDoubleColorText {
    return YES;
}

@end