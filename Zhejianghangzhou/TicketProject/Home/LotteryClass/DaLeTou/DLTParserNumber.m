//
//  DLTParserNumber.m  39大乐透
//  TicketProject
//
//  Created by KAI on 15-1-3.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "DLTParserNumber.h"
#import "CalculateBetCount.h"
#import "CustomParserNumber.h"

@implementation DLTParserNumber

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray {
    [betTypeArray addObject:@"普通投注"];
    [betTypeArray addObject:@"前区胆拖投注"];
    [betTypeArray addObject:@"后区胆拖投注"];
    [betTypeArray addObject:@"双区胆拖投注"];
    return 3901;
}

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict {
    NSArray *buyContentArray = [recordDict objectForKey:@"buyContent"];
    
    NSInteger lotteryID =[[recordDict objectForKey:@"lotteryID"] intValue]; //彩种id
    
    NSString  *winNumber = [recordDict objectForKey:@"winNumber"];
    if (winNumber.length == 0) {
        winNumber = [recordDict objectForKey:@"winLotteryNumber"];
    }
    
    
    NSMutableDictionary * winParserNumberDict = [[NSMutableDictionary alloc] init];
    [CustomParserNumber parserWinNumer_1:winNumber lotteryID:lotteryID winParserDict:winParserNumberDict];
    
    int recordNum = 0;//每单号码
    for (NSArray *lotteryArray in buyContentArray) {
        if (![lotteryArray isKindOfClass:[NSArray class]] || [lotteryArray count] == 0) {
            continue;
        }
        NSDictionary *lotteryDict = [lotteryArray objectAtIndex:0];
        NSInteger playId = [[lotteryDict objectForKey:@"playType"] intValue];//玩法id
        NSString *lotteryNumber = [lotteryDict objectForKey:@"lotteryNumber"];
        
        
        NSString *selectBallsTrimmedString = [lotteryNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (selectBallsTrimmedString.length == 0) {
            continue;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *playTypeName = [self judgeRecordPlayNameWithLotteryID:lotteryID playId:playId number:selectBallsTrimmedString];//根据玩法id或选号判断玩法名称
        [dict setObject:playTypeName forKey:@"betType"];//存入客户端的玩法名，
        
        if (playId == 3902) { //大乐透追号改变为大乐透普通
            playId = 3901;
        } else if (playId == 3904) {
            playId = 3903;
        } else if (playId == 3908) {
            playId = 3906;
        } else if (playId == 3909) {
            playId = 3907;
        }
        
        [dict setObject:[NSNumber numberWithInteger:playId] forKey:@"playId"];//存入玩法id
        
        
        //用来判断的数组是否符合基本要求
        NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];
        if ([numberArray count] == 0 || (lotteryID == 39 && [numberArray count] < 2)) {
            continue;
        }
        
        
        
        BOOL hasBall = NO;//是否有号码
        
        switch (playId) {
            case 3901:
            case 3902:
            case 3903:
            case 3904:
            case 3906:
            case 3907:
            case 3908:
            case 3909:
                hasBall = [CustomParserNumber splitBallViewNumber_1_WithDict:dict selectBallsTrimmedString:selectBallsTrimmedString];
                break;
                
            default:
                break;
        }
        
        if (hasBall == NO) {
            continue;
        }
        
        NSString *selectNumber = [self getDLTBetNumberStringWithOneArray:[dict objectForKey:[CustomParserNumber numberBallViewName:0]]
                                                                     two:[dict objectForKey:[CustomParserNumber numberBallViewName:1]]
                                                                   three:[dict objectForKey:[CustomParserNumber numberBallViewName:2]]
                                                                    four:[dict objectForKey:[CustomParserNumber numberBallViewName:3]]
                                                               andPlayID:playId
                                                       andPlayMethodName:playTypeName];
        
        NSInteger totalBetCount = [self getCountForDLTWithOneArray:[dict objectForKey:[CustomParserNumber numberBallViewName:0]]
                                                               two:[dict objectForKey:[CustomParserNumber numberBallViewName:1]]
                                                             three:[dict objectForKey:[CustomParserNumber numberBallViewName:2]]
                                                              four:[dict objectForKey:[CustomParserNumber numberBallViewName:3]]
                                                       basedRedNum:5
                                                      basedBlueNum:2
                                                         andPlayID:playId
                                                 andPlayMethodName:playTypeName];
        
        [dict setObject:selectNumber forKey:kSelectBalls]; //准备投注的拼接号码
        [dict setObject:[NSNumber numberWithInteger:totalBetCount] forKey:@"betCount"];//该组选号的注数
        NSInteger isShake = [self isSupportShakeWithPalyType:playId];
        [dict setObject:[NSNumber numberWithInteger:isShake] forKey:kIsSupportShake];//该玩法是否支持机选
        NSString *winColorNumber = [self colorTextWithWinParserDict:winParserNumberDict selectDict:dict playId:playId];
        [dict setObject:winColorNumber forKey:@"colorText"];
                
        [numberDict setObject:dict forKey:[NSString stringWithFormat:@"%d",recordNum++]];//第几组选号
    }
    
    
    [winParserNumberDict release];
}

+ (NSString *)colorTextWithWinParserDict:(NSDictionary *)winParserDict selectDict:(NSDictionary *)selectDict playId:(NSInteger)playId {   //完成
    NSString *text = @"";
    NSString *rightText = @"";
    
    switch (playId) {
        case 3901://大乐透普通投注（该部分为红蓝球，所有的数字都是空格分开）
        {
            //前区
            text = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            
            //后区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"1"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:blueTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:YES];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"0"] spaceColor:grayTextColor spaceString:@": "];
        }
            break;
        case 3903://大乐透前区胆拖投注
        {
            //胆前区
            text = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            
            //拖前区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"0"] spaceColor:redTextColor spaceString:@","];
            
            //后区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"1"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:2]] textColor:blueTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:YES];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"0"] spaceColor:grayTextColor spaceString:@": "];
        }
            break;
        case 3906://大乐透后区胆拖
        {
            //前区
            text = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            
            //胆后区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:blueTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"0"] spaceColor:grayTextColor spaceString:@": "];
            
            //拖后区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"1"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:2]] textColor:blueTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:YES];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"1"] spaceColor:blueTextColor spaceString:@","];
        }
            break;
        case 3907://大乐透双区胆拖
        {
            //胆前区
            text = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            
            //拖前区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"0"] spaceColor:redTextColor spaceString:@","];
            
            //胆后区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"1"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:2]] textColor:blueTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:NO];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"0"] spaceColor:grayTextColor spaceString:@": "];
            
            //拖后区
            rightText = [CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"1"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:3]] textColor:blueTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@" " singleIsAddChar:NO numHasZero:YES isLastPart:YES];
            text = [CustomParserNumber joinLeftText:text rightText:rightText winArray:[winParserDict objectForKey:@"1"] spaceColor:blueTextColor spaceString:@","];
        }
            break;
            
        default:
            break;
    }

    return text;
}

/**拼接格式*/
+ (NSString *)getDLTBetNumberStringWithOneArray:(NSArray *)onearr
                                            two:(NSArray *)twoarr
                                          three:(NSArray *)threearr
                                           four:(NSArray *)fourarr
                                      andPlayID:(NSInteger)playid
                              andPlayMethodName:(NSString *)playname
{
    NSString *(^getBallNumString)(NSArray *) = ^ (NSArray *ballNumArray) {
        NSString *ballNumString = @"";
        for (NSNumber *ballNum in ballNumArray) {
            if([ballNum integerValue] >= 10)
                ballNumString = [ballNumString stringByAppendingFormat:@"%@ ",ballNum];
            else
                ballNumString = [ballNumString stringByAppendingFormat:@"0%@ ",ballNum];
        }
        return [ballNumString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    };
    NSString *numberStr = @"";
    switch (playid) {
        case 3901:// 普通投注
        case 3902:
        {
            // 红球
            numberStr = [numberStr stringByAppendingFormat:@"%@-",getBallNumString(onearr)];
            
            // 蓝球
            numberStr = [numberStr stringByAppendingFormat:@"%@",getBallNumString(twoarr)];
        }
            break;
        case 3903:// 胆拖投注
        case 3904:
        {
            // 胆码
            numberStr = [numberStr stringByAppendingFormat:@"%@ , ",getBallNumString(onearr)];
            
            // 拖码
            numberStr = [numberStr stringByAppendingFormat:@"%@-",getBallNumString(twoarr)];
            
            // 蓝球
            numberStr = [numberStr stringByAppendingFormat:@"%@",getBallNumString(threearr)];
            
        }
            break;
        case 3906:
        case 3908:
        {
            // 红球
            numberStr = [numberStr stringByAppendingFormat:@"%@-",getBallNumString(onearr)];
            
            // 后区胆码
            numberStr = [numberStr stringByAppendingFormat:@"%@ , ",getBallNumString(twoarr)];
            
            // 后区拖码
            numberStr = [numberStr stringByAppendingFormat:@"%@",getBallNumString(threearr)];
            
        }
            break;
        case 3907:
        case 3909:
        {
            // 前区胆码
            numberStr = [numberStr stringByAppendingFormat:@"%@ , ",getBallNumString(onearr)];
            
            // 前区拖码
            numberStr = [numberStr stringByAppendingFormat:@"%@ - ",getBallNumString(twoarr)];
            
            // 后区胆码
            numberStr = [numberStr stringByAppendingFormat:@"%@ , ",getBallNumString(threearr)];
            
            // 后区拖码
            numberStr = [numberStr stringByAppendingFormat:@"%@",getBallNumString(fourarr)];
            
        }
            break;
        default:
            break;
    }
    return numberStr;
}

+ (NSInteger)getCountForDLTWithOneArray:(NSArray *)onearr
                                    two:(NSArray *)twoarr
                                  three:(NSArray *)threearr
                                   four:(NSArray *)fourarr
                            basedRedNum:(NSInteger)redCounts
                           basedBlueNum:(NSInteger)blueCounts
                              andPlayID:(NSInteger)playID
                      andPlayMethodName:(NSString *)playMethodName
{
    NSInteger count = 0;
    switch (playID) {
        case 3901:
        case 3902:
        {
            // 不满足基本条件(双色球红球小于6个,蓝球小于1个)
            if (onearr.count < redCounts || twoarr.count < blueCounts)
                count = 0;
            else
                count = [CalculateBetCount combinationWithM:onearr.count N:redCounts] * [CalculateBetCount combinationWithM:twoarr.count N:blueCounts];
        }
            break;
        case 3903:
        case 3904:
        {
            if (onearr.count < 1 || twoarr.count < 2)
                count = 0;
            else if (onearr.count + twoarr.count < (redCounts + 1) || threearr.count < blueCounts)
                count = 0;
            else
                count = [CalculateBetCount combinationWithM:twoarr.count N:redCounts - onearr.count] * [CalculateBetCount combinationWithM:threearr.count N:blueCounts];
        }
            break;
        case 3906:
        case 3908:
        {
            if (onearr.count != 5 || twoarr.count != 1 || threearr.count < 2)
                count = 0;
            else if (threearr.count < blueCounts)
                count = 0;
            else
                count = [CalculateBetCount combinationWithM:onearr.count N:redCounts] * [CalculateBetCount combinationWithM:threearr.count N:blueCounts - 1];
        }
            break;
        case 3907:
        case 3909:
        {
            if (onearr.count < 1 || twoarr.count < 2 || threearr.count != 1 || fourarr.count < 2)
                count = 0;
            else if (onearr.count + twoarr.count < (redCounts + 1) || fourarr.count < blueCounts)
                count = 0;
            else
                count = [CalculateBetCount combinationWithM:twoarr.count N:redCounts - onearr.count] * [CalculateBetCount combinationWithM:fourarr.count N:blueCounts - 1];
        }
            break;
        default:
            break;
    }
    return count;
}

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType {
    switch (palyType) {
        case 3901://大乐透-普通投注
            return YES;
            break;
        case 3903://大乐透-前区胆拖投注
        case 3906://大乐透-后区胆拖投注
        case 3907://大乐透-双区胆拖投注
            return NO;
            break;
        default:
            break;
    }
    return NO;
}

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (lotteryID) {
        case 39://大乐透
        {
            switch (playID) {
                case 3901:
                    return @"普通投注";
                    break;
                case 3902:
                    return @"普通追加";
                    break;
                case 3903:
                    return @"前区胆拖投注";
                    break;
                case 3904:
                    return @"前区胆拖追加";
                    break;
                case 3906:
                    return @"后区胆拖投注";
                    break;
                case 3908:
                    return @"后区胆拖追加";
                    break;
                case 3907:
                    return @"双区胆拖投注";
                    break;
                case 3909:
                    return @"双区胆拖追加";
                    break;
                default:
                    break;
            }
        }
            break;
        
        default:
            break;
    }
    return @"";
}

@end
