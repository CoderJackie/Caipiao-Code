//
//  SDBetViewController.m 购彩大厅－福彩3D投注
//  TicketProject
//
//  Created by sls002 on 13-5-30.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//
//20141011 08:25（洪晓彬）：修改代码规范，改进生命周期
//20141011 08:36（洪晓彬）：进行ipad适配

#import "SDBetViewController.h"
#import "BetTableViewCell.h"
#import "SDViewController.h"
#import "SetIssueAndTimeView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "CalculateBetCount.h"
#import "RandomNumber.h"
#import "Globals.h"

@interface SDBetViewController ()

@end

#pragma mark -
#pragma mark @implementation SDBetViewController
@implementation SDBetViewController
#pragma mark Lifecircle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"3D投注";

//    [_checkBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -UITableViewDelegate
- (UIViewController *)pushViewCOntrollerWithSelectedBallsDic:(NSDictionary *)ballsDic lotteryDic:(NSDictionary *)dic atRowIndex:(NSInteger)index {
    SDViewController *detailView = [[SDViewController alloc]initWithSelectedBallsDic:ballsDic lotteryDic:dic atRowIndex:index];
    detailView.baseDelegate = self;
    return detailView;
}

#pragma mark -
#pragma mark -Customized(Action)
//点击自选按钮  调用
- (void)handAddBalls:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
    [dic setObject:_playtype forKey:kBetType];
    [dic setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
    if (self.betInfoDic && self.betInfoDic.count > 0)
        [dic setObject:[NSNumber numberWithInteger:23] forKey:@"hasBetDic"];
    else
        [dic setObject:[NSNumber numberWithInteger:20] forKey:@"hasBetDic"];
    SDViewController *sscVC = [[SDViewController alloc]initWithBetViewController:self
                                                                      lotteryDic:_lotteryDic
                                                                     andBallsDic:dic];
    [sscVC setIsPresentView:YES];
    XFNavigationViewController *nav = [[XFNavigationViewController alloc]initWithRootViewController:sscVC];
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nav;
    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    [sscVC release];
    [nav release];
}

//点击机选按钮 调用
- (void)autoAddBalls:(id)sender {
    if ([_playtype isEqualToString:@"直选"]) {
        NSMutableArray *oneArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                                                 minNum:0
                                                                                andExpectedRandomCounts:1]];
        
        NSMutableArray *twoArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                                                 minNum:0
                                                                                andExpectedRandomCounts:1]];
        
        NSMutableArray *threeArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                                                   minNum:0
                                                                                  andExpectedRandomCounts:1]];
        
        NSString *selectBallsStr = [NSString string];
        for (NSNumber *ballNum in oneArray) {
            selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
        }
        selectBallsStr = [selectBallsStr stringByAppendingString:@","];
        
        for (NSNumber *ballNum in twoArray) {
            selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
        }
        selectBallsStr = [selectBallsStr stringByAppendingString:@","];
        
        for (NSNumber *ballNum in threeArray) {
            selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.betInfoDic];
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:selectBallsStr forKey:kSelectBalls];
        [dicInfo setObject:@"直选" forKey:kBetType];
        [dicInfo setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
        [dicInfo setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
        [dicInfo setObject:[NSNumber numberWithInt:1] forKey:kBetCount];
        [dicInfo setObject:oneArray forKey:kOneViewBalls];
        [dicInfo setObject:twoArray forKey:kTwoViewBalls];
        [dicInfo setObject:threeArray forKey:kThreeViewBalls];
        NSInteger count = self.betInfoDic.count;
        [dic setObject:dicInfo forKey:[NSString stringWithFormat:@"%ld",(long)count]];
        
        self.betInfoDic = dic;
    }else if ([_playtype isEqualToString:@"通选"]) {
        NSMutableArray *oneArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                                                 minNum:0
                                                                                andExpectedRandomCounts:1]];
        
        NSMutableArray *twoArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                                                 minNum:0
                                                                                andExpectedRandomCounts:1]];
        
        NSMutableArray *threeArray = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                                                   minNum:0
                                                                                  andExpectedRandomCounts:1]];
        
        NSString *selectBallsStr = [NSString string];
        for (NSNumber *ballNum in oneArray) {
            selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
        }
        selectBallsStr = [selectBallsStr stringByAppendingString:@","];
        
        for (NSNumber *ballNum in twoArray) {
            selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
        }
        selectBallsStr = [selectBallsStr stringByAppendingString:@","];
        
        for (NSNumber *ballNum in threeArray) {
            selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.betInfoDic];
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:selectBallsStr forKey:kSelectBalls];
        [dicInfo setObject:@"通选" forKey:kBetType];
        [dicInfo setObject:[NSNumber numberWithInteger:_playMethodID] forKey:kPlayID];
        [dicInfo setObject:[NSNumber numberWithBool:_isSupportShake] forKey:kIsSupportShake];
        [dicInfo setObject:[NSNumber numberWithInt:1] forKey:kBetCount];
        [dicInfo setObject:oneArray forKey:kOneViewBalls];
        [dicInfo setObject:twoArray forKey:kTwoViewBalls];
        [dicInfo setObject:threeArray forKey:kThreeViewBalls];
        NSInteger count = self.betInfoDic.count;
        [dic setObject:dicInfo forKey:[NSString stringWithFormat:@"%ld",(long)count]];
        
        self.betInfoDic = dic;
    }else {
        [XYMPromptView defaultShowInfo:@"此玩法不支持机选1注" isCenter:YES];
    }
    
    [_tableViews reloadData];
    [self updateBetCountOfBottomView];
}

#pragma mark -Customized: Private (General)
//投注内容的json字符串
- (NSArray *)getBuyContentString {
    ///投注内容
    NSMutableArray *buyContentArray = [NSMutableArray array];//投注内容数组
    
    
    
    NSInteger betCount = self.betInfoDic.count;
    for (NSInteger i = betCount - 1; i >= 0 ; i--) {
        
        // 提交时只能有一个玩法
        NSString *playtypes = @"";         // 玩法ID
        
        NSInteger betCounts = 0;
        NSInteger betAmounts = 0;
        
        NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];//投注内容字典  每一注都是一个字典
        
        
        
        NSDictionary *betDic = [self.betInfoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
        
        NSString *betTypeStr = [betDic objectForKey:kBetType];
        NSString *lotteryNum = [betDic objectForKey:kSelectBalls];
        // 玩法、号码去掉空格
        if([betTypeStr isEqualToString:@"直选"]) {
            playtypes = @"601";
            
        } else if([betTypeStr isEqualToString:@"组三"]) {
            playtypes = @"602";
            
        } else if([betTypeStr isEqualToString:@"组六"]) {
            playtypes = @"603";

        } else if([betTypeStr isEqualToString:@"1D"]) {
            playtypes = @"604";

        } else if([betTypeStr isEqualToString:@"猜1D"]) {
            playtypes = @"605";

        } else if ([betTypeStr isEqualToString:@"2D"]) {
            playtypes = @"606";

        } else if ([betTypeStr isEqualToString:@"猜2D-二同号"]) {
            playtypes = @"607";

        } else if ([betTypeStr isEqualToString:@"猜2D-二不同号"]) {
            playtypes = @"608";

        } else if([betTypeStr isEqualToString:@"通选"]) {
            playtypes = @"609";

        } else if ([betTypeStr isEqualToString:@"和数"]) {
            playtypes = @"610";

        } else if ([betTypeStr isEqualToString:@"包选3"]) {
            playtypes = @"611";

        } else if ([betTypeStr isEqualToString:@"包选6"]) {
            playtypes = @"612";

        } else if ([betTypeStr isEqualToString:@"猜大小"]) {
            playtypes = @"613";

        } else if ([betTypeStr isEqualToString:@"猜奇偶"]) {
            playtypes = @"616";

        } else if ([betTypeStr isEqualToString:@"猜三同"]) {
            playtypes = @"614";

        } else if ([betTypeStr isEqualToString:@"拖拉机"]) {
            playtypes = @"615";

        }
        
        // 注数和金额计算
        NSInteger betcount = [[NSString stringWithFormat:@"%@",[betDic objectForKey:kBetCount]] integerValue];
        betCounts += betcount;          // 注数
        betAmounts += betcount * 2;     // 金额
        
        
        
        NSString *sumNum = [NSString stringWithFormat:@"%ld",(long)betCounts];
        // 追号的时候不乘以倍数，没追号的时候乘以倍数
        NSString *sumMoney = [NSString stringWithFormat:@"%ld",(long)(betAmounts * ([_issueView chase] > 1 ? 1 : [_issueView multiple]))];
        
        [contentDic setObject:playtypes forKey:@"playType"];
        [contentDic setObject:sumMoney forKey:@"sumMoney"];
        [contentDic setObject:sumNum forKey:@"sumNum"];
        [contentDic setObject:lotteryNum forKey:@"lotteryNumber"];
        
        [buyContentArray addObject:contentDic];
    }
    
    return buyContentArray;
}

@end
