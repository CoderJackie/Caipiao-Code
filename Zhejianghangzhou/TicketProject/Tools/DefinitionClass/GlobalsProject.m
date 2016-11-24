//
//  GlobalsProject.m
//  TicketProject
//
//  Created by KAI on 14-10-16.
//  Copyright (c) 2014年 sls002. All rights reserved.
//
//  20150729 10:35（刘科）：新增奖金优化

#import "GlobalsProject.h"
#import "SSQViewController.h"
#import "DLTViewController.h"
#import "SFCViewController.h"
#import "SDViewController.h"
#import "RJXViewController.h"
#import "FootBallViewController.h"
#import "BasketBallViewController.h"
#import "SingleViewController.h"


#import "SSQBetViewController.h"
#import "DLTBetViewController.h"
#import "SFCBetViewController.h"
#import "SDBetViewController.h"
#import "RJXBetViewController.h"
#import "FootBallBetViewController.h"
#import "BasketBallBetViewController.h"
#import "SingleBetViewController.h"

#import "SSQParserNumber.h"
#import "DLTParserNumber.h"
#import "SDParserNumber.h"
#import "SFCParserNumber.h"
#import "RJCParserNumber.h"

#import "JCZQParserNumber.h"
#import "JCLQParserNumber.h"
#import "BJDCParserNumber.h"

#import "CalculateBetCount.h"
#import "MyTool.h"

#define kSSQRedBallNormalCounts                 6       // 标准红球个数(开奖时)，也就是最少选择的个数
#define kSSQBlueBallNormalCounts                1       // 标准蓝球个数(开奖时)，也就是最少选择的个数

#define kDLTRedBallNormalCounts                 5       // 标准红球个数(开奖时)，也就是最少选择的个数
#define kDLTBlueBallNormalCounts                2       // 标准蓝球个数(开奖时)，也就是最少选择的个数


@implementation GlobalsProject

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

+ (UIViewController *)viewController:(NSInteger)lotteryid initWithInfoData:(NSObject *)obj {
    UIViewController *dataVC = nil;
    switch (lotteryid) {
        case 5://双色球选号
            dataVC = [[SSQViewController alloc] initWithInfoData:obj];
            break;
        case 39://大乐透
            dataVC = [[DLTViewController alloc] initWithInfoData:obj];
            break;
        case 74://胜负彩
            dataVC = [[SFCViewController alloc] initWithInfoData:obj];
            break;
        case 6://3D
            dataVC = [[SDViewController alloc] initWithInfoData:obj];
            break;
        case 75://任九场
            dataVC = [[RJXViewController alloc] initWithInfoData:obj];
            break;
        case 72://竞彩足球
            dataVC = [[FootBallViewController alloc] initWithMatchData:obj footBallPassBarrierType:FootBallPassBarrierType_moreMatch];
            break;
        case 73://竞彩篮球
            dataVC = [[BasketBallViewController alloc] initWithMatchData:obj];
            break;
        case 45://北京单场
            dataVC = [[SingleViewController alloc] initWithMatchData:obj SinglePassBarrierType:SinglePassBarrierType_moreMatch];
            break;
        default:
            break;
    }
    return [dataVC autorelease];
}

//非竞彩
+ (UIViewController *)betViewControllerBallsInfoDict:(NSMutableDictionary *)betsContentDict lotteryDict:(NSDictionary*)lotteryDict lotteryId:(NSInteger)lotteryid initWithPlayType:(NSInteger)playType {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSInteger betsContentDictCount = [betsContentDict count];
    for (NSInteger i = betsContentDictCount - 1; i >= 0; i--) {
        [dict setObject:[betsContentDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] forKey:[NSString stringWithFormat:@"%ld",(long)(betsContentDictCount - i - 1)]];
    }
    
    
    UIViewController *dataVC = nil;
    switch (lotteryid) {
        case 5://双色球投注
            dataVC = [[SSQBetViewController alloc] initWithBallsInfoDic:dict LotteryDic:lotteryDict isSupportShake:[SSQParserNumber isSupportShakeWithPalyType:playType] isRecordView:YES];
            break;
        case 39://大乐透
            dataVC = [[DLTBetViewController alloc] initWithBallsInfoDic:dict LotteryDic:lotteryDict isSupportShake:[DLTParserNumber isSupportShakeWithPalyType:playType] isRecordView:YES];
            break;
        case 6://3D
            dataVC = [[SDBetViewController alloc] initWithBallsInfoDic:dict LotteryDic:lotteryDict isSupportShake:[SDParserNumber isSupportShakeWithPalyType:playType] isRecordView:YES];
            break;
        default:
            break;
    }
    return [dataVC autorelease];
}

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict {
    NSInteger lotteryID =[[recordDict objectForKey:@"lotteryID"] intValue];
    
    switch (lotteryID) {
        case 5:
            [SSQParserNumber parserBetNumberWithRecordDictionart:recordDict numberDictionary:numberDict];
            break;
            
        case 39:
            [DLTParserNumber parserBetNumberWithRecordDictionart:recordDict numberDictionary:numberDict];
            break;
            
        case 6:
            [SDParserNumber parserBetNumberWithRecordDictionart:recordDict numberDictionary:numberDict];
            break;
            
        case 74:
            [SFCParserNumber parserBetNumberWithRecordDictionart:recordDict numberDictionary:numberDict];
            break;
            
        case 75:
            [RJCParserNumber parserBetNumberWithRecordDictionart:recordDict numberDictionary:numberDict];
            break;
            
        default:
            break;
    }
}

+ (void)customParserJCOrderMatchDeitalWithDict:(NSDictionary *)jcOrderMatchDeitalDict matchDeitalArray:(NSMutableArray *)matchDeitalArray lotteryId:(NSInteger)lotteryId {
    if (lotteryId == 72) {
        [JCZQParserNumber customParserJCOrderMatchDeitalWithDict:jcOrderMatchDeitalDict matchDeitalArray:matchDeitalArray lotteryId:lotteryId];
    } else if (lotteryId == 73) {
        [JCLQParserNumber customParserJCOrderMatchDeitalWithDict:jcOrderMatchDeitalDict matchDeitalArray:matchDeitalArray lotteryId:lotteryId];
    } else if (lotteryId == 45) {
        [BJDCParserNumber customParserJCOrderMatchDeitalWithDict:jcOrderMatchDeitalDict matchDeitalArray:matchDeitalArray lotteryId:lotteryId];
    }
}

//订单页面是否能继续投注
+ (BOOL)recordContinueBet:(NSInteger)lotteryid {
    switch (lotteryid) {
        case 5://双色球
        case 39://大乐透
        case 6://3D
            return YES;
            break;
        case 74://胜负彩
        case 75://任九场
        case 72://竞彩足球
        case 73://竞彩篮球
        case 45://北京单场
            return NO;
            break;
        default:
            break;
    }
    return NO;
}

//根据订单的玩法id和号码判断玩法名
+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (lotteryID) {
        case 5://双色球
            return [SSQParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 39://大乐透
            return [DLTParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 6://3D
            return [SDParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 72: //竞彩足球
            return [JCZQParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 73: //竞彩篮球
            return [JCLQParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 74: //胜负彩
            return [SFCParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 75: //任九场
            return [RJCParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        case 45: //北京单场
            return [BJDCParserNumber judgeRecordPlayNameWithLotteryID:lotteryID playId:playID number:number];
            break;
        default:
            break;
    }
    return @"";
}

+ (NSInteger)firstTypePlayIdWithTicketTypeName:(NSString *)ticketTypeName betTypeArray:(NSMutableArray *)betTypeArray {
    [betTypeArray removeAllObjects];
    NSInteger methodID = 0;
    
    if([ticketTypeName isEqualToString:@"双色球"]) {
        methodID = [SSQParserNumber firstTypePlayIdWithBetTypeArray:betTypeArray];
        
    } else if([ticketTypeName isEqualToString:@"3D"]) {
        methodID = [SDParserNumber firstTypePlayIdWithBetTypeArray:betTypeArray];
        
    } else if([ticketTypeName isEqualToString:@"大乐透"]) {
        methodID = [DLTParserNumber firstTypePlayIdWithBetTypeArray:betTypeArray];
        
    } else if([ticketTypeName isEqualToString:@"竞彩篮球"]) {
        methodID = [JCLQParserNumber firstTypePlayIdWithBetTypeArray:betTypeArray];
        
    } else if([ticketTypeName isEqualToString:@"竞彩足球"]) {
        methodID = [JCZQParserNumber firstTypePlayIdWithBetTypeArray:betTypeArray];
        
    } else if ([ticketTypeName isEqualToString:@"北京单场"]) {
        methodID = [BJDCParserNumber firstTypePlayIdWithBetTypeArray:betTypeArray];
        
    }
    return methodID;
}

+ (NSString *)helpTxtNameWithPlayID:(NSInteger)playId {
    switch (playId) {
        case 5:
            return @"ssq.txt";
            break;
        case 39:
            return @"dlt.txt";
            break;
        case 6:
            return @"3d.txt";
            break;
        case 63:
            return @"pl3.txt";
            break;
        case 64:
            return @"pl5.txt";
            break;
        case 83:
            return @"jsks.txt";
            break;
        case 3:
            return @"qxc.txt";
            break;
        case 13:
            return @"qlc.txt";
            break;
        case 74:
            return @"sfc.txt";
            break;
        case 75:
            return @"rxj.txt";
            break;
        case 28:
        case 66:
            return @"ssc.txt";
            break;
        case 62:
            return @"syydj.txt";
            break;
        case 68:
            return @"ky481.txt";
            break;
        case 82:
            return @"xyc.txt";
            break;
        case 69:
            return @"esex5.txt";
            break;
        case 72:
            return @"jczq.txt";
            break;
        case 73:
            return @"jclq.txt";
            break;
        case 70:
        case 78:
            return @"syxw.txt";
            break;
        case 45:
            return @"bjdc.txt";
            break;
        case 1000://合买介绍
            return @"hemai.txt";
            break;
        case 2000://注册协议
            return @"zcxy.txt";
            break;
        case 1111: // 奖金优化玩法说明
            return @"jjyh.txt";
            break;
            
        default:
            break;
    }
    return @"";
}

@end
