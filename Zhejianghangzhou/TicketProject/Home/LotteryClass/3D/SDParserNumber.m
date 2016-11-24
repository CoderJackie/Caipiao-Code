//
//  SDParserNumber.m  6 3D
//  TicketProject
//
//  Created by KAI on 15-1-3.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "SDParserNumber.h"
#import "CalculateBetCount.h"
#import "CustomParserNumber.h"

@implementation SDParserNumber

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray {
    [betTypeArray addObject:@"直选"];
    [betTypeArray addObject:@"组三"];
    [betTypeArray addObject:@"组六"];
    [betTypeArray addObject:@"和数"];
    [betTypeArray addObject:@"1D"];
    [betTypeArray addObject:@"猜1D"];
    [betTypeArray addObject:@"2D"];
    [betTypeArray addObject:@"猜2D-二同号"];
    [betTypeArray addObject:@"猜2D-二不同号"];
    [betTypeArray addObject:@"通选"];
    [betTypeArray addObject:@"包选3"];
    [betTypeArray addObject:@"包选6"];
    [betTypeArray addObject:@"猜大小"];
    [betTypeArray addObject:@"猜三同"];
    [betTypeArray addObject:@"猜奇偶"];
    [betTypeArray addObject:@"拖拉机"];
    return 601;
}

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict {
    NSArray *buyContentArray = [recordDict objectForKey:@"buyContent"];
    
    NSInteger lotteryID =[[recordDict objectForKey:@"lotteryID"] intValue]; //彩种id
    
    NSString  *winNumber = [recordDict objectForKey:@"winNumber"];
    if (winNumber.length == 0) {
        winNumber = [recordDict objectForKey:@"winLotteryNumber"];
    }
    
    NSMutableDictionary * winParserNumberDict = [[NSMutableDictionary alloc] init];
    [CustomParserNumber parserWinNumer_2:winNumber lotteryID:lotteryID winParserDict:winParserNumberDict];
    
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
        

        [dict setObject:[NSNumber numberWithInteger:playId] forKey:@"playId"];//存入玩法id
        
        
        //用来判断的数组是否符合基本要求
        NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];
        if ([numberArray count] == 0) {
            continue;
        }
        
        
        
        BOOL hasBall = NO;//是否有号码
        
        switch (playId) {
            case 601:
            case 604:
            case 606:
            case 609:
            case 611:
            case 612:
                hasBall = [CustomParserNumber splitBallViewNumber_2_WithDict:dict selectBallsTrimmedString:selectBallsTrimmedString];
                break;
            case 602:
            case 603:
            case 605:
            case 607:
            case 608:
            case 610:
                hasBall = [CustomParserNumber splitBallViewNumber_7_WithDict:dict selectBallsTrimmedString:selectBallsTrimmedString];
                break;
            case 613:
            case 614:
            case 615:
            case 616:
                hasBall = [CustomParserNumber splitBallViewNumber_10_WithDict:dict selectBallsTrimmedString:selectBallsTrimmedString];
                break;
                
            default:
                break;
        }
        
        
        
        if (hasBall == NO) {
            continue;
        }
        
        NSString *selectNumber = [self get3DBetNumberStringWithOneArray:[dict objectForKey:[CustomParserNumber numberBallViewName:0]]
                                                                    two:[dict objectForKey:[CustomParserNumber numberBallViewName:1]]
                                                                  three:[dict objectForKey:[CustomParserNumber numberBallViewName:2]]
                                                              andPlayID:playId
                                                      andPlayMethodName:playTypeName];
        
        NSInteger totalBetCount = [self getCountFor3DWithOneArray:[dict objectForKey:[CustomParserNumber numberBallViewName:0]]
                                                              two:[dict objectForKey:[CustomParserNumber numberBallViewName:1]]
                                                            three:[dict objectForKey:[CustomParserNumber numberBallViewName:2]]
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
    switch (playId) {
        case 601://直选 通选
        case 609://通选
        case 611://包选3
        {
            NSInteger count = 3;
            for (NSInteger i = 0; i < count; i++) {
                text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:[winParserDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:i]] textColor:redTextColor enterCharType:EnterTypeRight enterChar:@"," spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:i == (count - 1)]];
            }
        }
            break;
        case 602://组三
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
        
            text = [CustomParserNumber comparisonWinArray_3:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor];
        }
            break;
        case 603://组六
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
        
            text = [CustomParserNumber comparisonWinArray:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"," singleIsAddChar:NO numHasZero:NO isLastPart:YES];
        }
            break;
        case 604://1d
        case 606://2d
        {
            text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"0"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeRight enterChar:@"," spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:NO]];
            text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"1"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:redTextColor enterCharType:EnterTypeRight enterChar:@"," spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:NO]];
            text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:[winParserDict objectForKey:@"2"] selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:2]] textColor:redTextColor enterCharType:EnterTypeRight enterChar:@"," spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:YES]];
        }
            break;
        case 605://猜1d
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
        
            text = [CustomParserNumber comparisonWinArray:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor enterCharType:EnterTypeRight enterChar:@"" spaceString:@"," singleIsAddChar:NO numHasZero:NO isLastPart:YES];
        }
            break;
        case 607://猜2d－二同号
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
        
            text = [CustomParserNumber comparisonWinArray_5:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor spaceString:@","];
        }
            break;
        case 608://猜2d－二不同号
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
        
            text = [CustomParserNumber comparisonWinArray_6:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor spaceString:@","];
        }
            break;
        case 610://和值
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
            text = [CustomParserNumber comparisonWinArray_9:winArray selectDict:selectDict textColor:redTextColor winNumberCount:3];
        }
            break;
        case 612://包选6
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
        
            NSInteger count = 3;
            for (NSInteger i = 0 ; i < count; i++) {
                text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:i]] textColor:redTextColor enterCharType:EnterTypeRight enterChar:@"," spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:i == (count - 1)]];
            }
        }
            break;
        case 613:
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
            text = [CustomParserNumber comparisonWinArray_10:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor];
        }
            break;
        case 614:
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
            text = [CustomParserNumber comparisonWinArray_12:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor text:@"三同号"];
        }
            break;
        case 615:
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
            text = [CustomParserNumber comparisonWinArray_13:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor text:@"拖拉机" sortType:0];
        }
            break;
        case 616:
        {
            NSMutableArray *winArray = [CustomParserNumber takeAllNumberInOneArrayWithDict:winParserDict count:3];
            text = [CustomParserNumber comparisonWinArray_11:winArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:redTextColor];
        }
            break;
            
        default:
            break;
    }
    
    
    return text;
}

+ (NSString *)get3DBetNumberStringWithOneArray:(NSArray *)onearr
                                           two:(NSArray *)twoarr
                                         three:(NSArray *)threearr
                                     andPlayID:(NSInteger)playid
                             andPlayMethodName:(NSString *)playname
{
    NSString * (^getBallNumString)(NSArray *) = ^(NSArray *ballNumArray) {
        NSString *ballNumString = [ballNumArray componentsJoinedByString:@""];
        if (ballNumString.length == 0) {
            return @"*";
        }
        return ballNumString;
    };
    NSString *numberStr = @"";
    switch (playid) {
        case 601://直选
        case 609://通选
        case 604://1D
        case 606://2D
        case 612://包选6
        case 611:
        {
            numberStr = [NSString stringWithFormat:@"%@,%@,%@",getBallNumString(onearr),getBallNumString(twoarr),getBallNumString(threearr)];
        }
            break;
        case 602://组三复式
        case 603://组六复式
        case 605://猜1D
        case 607://猜2D-二同号
        case 608://猜2D-二不同号
        case 610:     // 和数
        {
            numberStr = [onearr componentsJoinedByString:@","];
        }
            break;
        case 614:
        {
            numberStr = @"三同号";
        }
            break;
        case 615:
        {
            numberStr = @"拖拉机";
        }
            break;
        case 613:
        {
            NSInteger firstNum = [[onearr firstObject] integerValue];
            numberStr = (firstNum == 0 ? @"大" : @"小");
        }
            break;
        case 616:
        {
            NSInteger firstNum = [[onearr firstObject] integerValue];
            numberStr = (firstNum == 0 ? @"奇" : @"偶");
        }
            break;
            
        default:
            break;
    }
    return numberStr;
}

+ (NSInteger)getCountFor3DWithOneArray:(NSArray *)onearr
                                   two:(NSArray *)twoarr
                                 three:(NSArray *)threearr
                             andPlayID:(NSInteger)playID
                     andPlayMethodName:(NSString *)playMethodName
{
    NSInteger count = 0;
    switch (playID) {
        case 601:
        case 609:     //通选
        case 612:      //包选6
            count = onearr.count * twoarr.count * threearr.count;
            break;
        case 610:      // 和数
        case 613:   //猜大小
        case 614:   //猜三同
        case 615:   //拖拉机
        case 616:   //猜奇偶
            count = onearr.count;
            break;
        case 604:      // 1D
        {
            count = onearr.count + twoarr.count + threearr.count;
        }
            break;
        case 605:      // 猜1D
        case 607:     // 猜2D-二同号
        {
            count = onearr.count;
        }
            break;
        case 611:     // 包选3
        {
            NSInteger (^ getCountWithArray)(NSArray*, NSArray*, NSArray*) = ^(NSArray *array1, NSArray *array2, NSArray *array3){
                NSInteger counts = 0;
                if ([array1 count] != 1 && [array2 count] != 1) {
                    return counts;
                }
                if ([array3 containsObject:[array1 firstObject]]) {
                    return counts;
                }
                if ([array1 isEqual:array2]) {
                    counts = array1.count * array3.count;
                }
                
                return counts;
            };
            
            count = getCountWithArray(onearr,twoarr,threearr);
            if (count == 0) {
                count = getCountWithArray(onearr,threearr,twoarr);
            }
            if (count == 0) {
                count = getCountWithArray(twoarr,threearr,onearr);
            }
            
        }
            break;
        case 606:      // 2D
        {
            count = onearr.count * twoarr.count + twoarr.count * threearr.count + threearr.count * onearr.count;
        }
            break;
        case 608:      // 猜2D-二不同号
        {
            count = [CalculateBetCount combinationWithM:onearr.count N:2];
        }
            break;
        case 602:   // 组三复式
        {
            if (onearr.count >= 2) {
                count = [CalculateBetCount permutationWithM:onearr.count N:2];
            }
        }
            break;
        case 603:   // 3d组六
        {
            if (onearr.count >= 3) {
                count = [CalculateBetCount combinationWithM:onearr.count N:3];
            }
        }
            break;
    }
    return count;
}

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType {
    switch (palyType) {
        case 601://3D-直选
        case 610://3D-通选
            return YES;
            break;
        case 602://3D-组三
        case 603://3D-组六
        case 604://3D-和数
        case 605://3D-1D
        case 606://3D-猜1D
        case 607://3D-2D
        case 608://3D-猜2D-二同号
        case 609://3D-猜2D-二不同号
        case 611://3D-包选3
        case 612://3D-包选6
        case 613://3D-猜大小
        case 614://3D-猜三同
        case 616://3D-猜奇偶
        case 615://3D-拖拉机
            return NO;
            break;
        default:
            break;
    }
    return NO;
}

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (lotteryID) {
        case 6://3D
        {
            switch (playID) {
                case 601:
                    return @"直选";
                    break;
                case 602:
                    return @"组三";
                    break;
                case 603:
                    return @"组六";
                    break;
                case 604:
                    return @"1D";
                    break;
                case 605:
                    return @"猜1D";
                    break;
                case 606:
                    return @"2D";
                    break;
                case 607:
                    return @"猜2D-二同号";
                    break;
                case 608:
                    return @"猜2D-二不同号";
                    break;
                case 609:
                    return @"通选";
                    break;
                case 610:
                    return @"和数";
                    break;
                case 611:
                    return @"包选3";
                    break;
                case 612:
                    return @"包选6";
                    break;
                case 613:
                    return @"猜大小";
                    break;
                case 616:
                    return @"猜奇偶";
                    break;
                case 614:
                    return @"猜三同";
                    break;
                case 615:
                    return @"拖拉机";
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
