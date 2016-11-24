//
//  SSQTogetherBuyViewController.m 购彩大厅－双色球投注
//  TicketProject
//
//  Created by sls002 on 13-5-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20141009 09:35（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20141009 09:48（洪晓彬）：进行ipad适配

#import "SSQBetViewController.h"
#import "BetTableViewCell.h"
#import "SSQViewController.h"
#import "XFNavigationViewController.h"

#import "CalculateBetCount.h"
#import "Globals.h"
#import "MyTool.h"
#import "RandomNumber.h"


#define kAutoSelectRedBallCount 6
#define kAutoSelectBlueBallCount 1
#define kAutoSelectRedMaxNumber 33
#define kAutoSelectBlueMaxNumber 16


@interface SSQBetViewController ()

@end

#pragma mark -
#pragma mark @implementation SSQBetViewController
@implementation SSQBetViewController
#pragma mark Lifecircle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"双色球投注";
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
    SSQViewController *detailView = [[SSQViewController alloc]initWithSelectedBallsDic:ballsDic lotteryDic:dic atRowIndex:index];
    detailView.baseDelegate = self;
    return detailView;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)handAddBalls:(id)sender { //自选一组号码
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
    [dic setObject:_playtype forKey:kBetType];
    [dic setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
    if (self.betInfoDic && self.betInfoDic.count > 0)
        [dic setObject:[NSNumber numberWithInteger:23] forKey:@"hasBetDic"];
    else
        [dic setObject:[NSNumber numberWithInteger:20] forKey:@"hasBetDic"];
    SSQViewController *selectBalls = [[SSQViewController alloc]initWithBetViewController:self lotteryDic:_lotteryDic andBallsDic:dic];
    [selectBalls setIsPresentView:YES];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:selectBalls];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [selectBalls release];
    [nav release];
}

- (void)autoAddBalls:(id)sender { //机选号码  点击机选按钮 调用
    _playtype = @"普通投注";
    NSMutableArray *oneArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:kAutoSelectRedMaxNumber
                                                                                             minNum:1
                                                                            andExpectedRandomCounts:kAutoSelectRedBallCount]];
    
    NSMutableArray *twoArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:kAutoSelectBlueMaxNumber
                                                                                             minNum:1
                                                                            andExpectedRandomCounts:kAutoSelectBlueBallCount]];
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    NSArray *redArrayStr = [cal convertToStringArrayWith:oneArray];
    NSArray *blueArraySte = (NSMutableArray *)[cal convertToStringArrayWith:twoArray];
    
    NSString *selectBallsStr = [cal changeSSQWithRedArray:redArrayStr TuoArray:nil BlueArray:blueArraySte Type:501];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.betInfoDic];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:selectBallsStr forKey:kSelectBalls];
    [dicInfo setObject:@"普通投注" forKey:kBetType];
    [dicInfo setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
    [dicInfo setObject:[NSNumber numberWithInt:1] forKey:kBetCount];
    [dicInfo setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
    [dicInfo setObject:oneArray forKey:kOneViewBalls];
    [dicInfo setObject:twoArray forKey:kTwoViewBalls];
    NSInteger count = self.betInfoDic.count;
    
    [dic setObject:dicInfo forKey:[NSString stringWithFormat:@"%ld",(long)count]];
    self.betInfoDic = dic;
    [_tableViews reloadData];
    
    [self updateBetCountOfBottomView];
}

#pragma mark -Customized: Private (General)
// 投注内容的json字符串
- (NSArray *)getBuyContentString {
    //投注内容
    NSMutableArray *buyContentArray = [NSMutableArray array];//投注内容数组
    
    NSInteger betCount = self.betInfoDic.count;
    for (NSInteger i = betCount - 1; i >= 0 ; i--) {
        // 提交时只能有一个玩法
        NSString *lotterynumbers = [NSString string];    // 所选的号码组合
        NSString *playtypes = [NSString string];         // 玩法ID     501,502

        NSInteger betCounts = 0;
        NSInteger betAmounts = 0;
        
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];//投注内容字典  每一注都是一个字典
        
        
        NSDictionary *betDic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];//某个号码
        
        // 玩法
        NSString *betTypeStr = [betDic objectForKey:kBetType];
        if([betTypeStr isEqualToString:@"普通投注"]) {
            playtypes = @"501";
        }
        if([betTypeStr isEqualToString:@"胆拖投注"] || [betTypeStr isEqualToString:@"胆拖"]) {
            playtypes = @"502";
        }
        
        // 注数和金额计算
        NSInteger betcount = [[NSString stringWithFormat:@"%@",[betDic objectForKey:kBetCount]] integerValue];
        betCounts += betcount;          // 注数
        betAmounts += betcount * 2;     // 金额
        
        // 号码组合
        NSString *lotterynum = [NSString stringWithFormat:@"%@",[betDic objectForKey:kSelectBalls]]; // 取得一串号码
        lotterynum = [lotterynum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        lotterynumbers = [lotterynumbers stringByAppendingString:lotterynum];
        
        NSString *sumNum = [NSString stringWithFormat:@"%ld",(long)betCounts];
        // 追号的时候不乘以倍数，没追号的时候乘以倍数
        NSString *sumMoney = [NSString stringWithFormat:@"%ld",(long)betAmounts];
        [contentDic setObject:lotterynumbers forKey:@"lotteryNumber"];
        [contentDic setObject:playtypes forKey:@"playType"];
        [contentDic setObject:sumNum forKey:@"sumNum"];
        [contentDic setObject:sumMoney forKey:@"sumMoney"];
        
        [buyContentArray addObject:contentDic];
        
    }
    
    return buyContentArray;
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