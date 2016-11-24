//
//  RJCParserNumber.m  75 任九场
//  TicketProject
//
//  Created by KAI on 15-1-7.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "RJCParserNumber.h"
#import "CalculateBetCount.h"
#import "CustomParserNumber.h"

@implementation RJCParserNumber

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
        
        NSMutableDictionary *selectMatchDict = [NSMutableDictionary dictionary];
        
        if (playId == 7501) {//任九场
            hasBall = [CustomParserNumber splitBallViewNumber_5_WithDict:selectMatchDict selectBallsTrimmedString:selectBallsTrimmedString ballNumArrayKeyNameType:BallNumArrayKeyTypeOfNum deleteLine:NO];
            
        }
        
        if (hasBall == NO) {
            continue;
        }
        
        
        NSString *selectNumber = [self getRJCTextWithDict:selectMatchDict matchCount:14];
        
        NSInteger totalBetCount = [self getCountForRJXWithSelectMatchDic:selectMatchDict];
        
        [dict setObject:selectMatchDict forKey:@"selectMatchDic"];
        [dict setObject:selectNumber forKey:kSelectBalls]; //准备投注的拼接号码
        [dict setObject:[NSNumber numberWithInteger:totalBetCount] forKey:@"betCount"];//该组选号的注数
        NSInteger isShake = [self isSupportShakeWithPalyType:playId];
        [dict setObject:[NSNumber numberWithInteger:isShake] forKey:kIsSupportShake];//该玩法是否支持机选
        NSString *winColorNumber = [self colorTextWithWinParserDict:winParserNumberDict selectDict:selectMatchDict playId:playId];
        [dict setObject:winColorNumber forKey:@"colorText"];
        
        [numberDict setObject:dict forKey:[NSString stringWithFormat:@"%d",recordNum++]];//第几组选号
    }
    
    
    [winParserNumberDict release];
    
}

+ (NSString *)colorTextWithWinParserDict:(NSDictionary *)winParserDict selectDict:(NSDictionary *)selectDict playId:(NSInteger)playId {
    NSString *text = @"";
    if (playId == 7501) {
        for (NSInteger i = 0; i < 14; i++) {
            text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:[winParserDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] selectArray:[selectDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] textColor:redTextColor enterCharType:EnterTypeBothSides enterChar:@"(" spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:NO]];
        }
        text = [text stringByReplacingOccurrencesOfString:@"*" withString:@"-"];
    }
    
    return text;
}

+ (NSString *)getRJCTextWithDict:(NSDictionary *)dict matchCount:(NSInteger)matchCount {
    NSString *formateSelectBalls = @"";
    
    for (int i = 0; i < matchCount; i++) {
        
        NSString *key = [NSString stringWithFormat:@"%d",i];
        NSString *per = [NSString string];
        
        if ([dict.allKeys containsObject:key]) {
            
            NSArray *arr = [dict objectForKey:key];
            if (arr.count == 0) {
                per = [per stringByAppendingString:@"-"];
            } else if (arr.count == 1) {
                per = [per stringByAppendingFormat:@"%@",[arr objectAtIndex:0]];
            } else {
                per = [NSString stringWithFormat:@"(%@)",[arr componentsJoinedByString:@""]];
            }
        } else {
            per = [per stringByAppendingString:@"-"];
        }
        formateSelectBalls = [formateSelectBalls stringByAppendingString:per];
    }
    return formateSelectBalls;
}

+ (long)getCountForRJXWithSelectMatchDic:(NSDictionary *)matchDic {
    int count = 0;
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *keyStr in matchDic.allKeys) {
        NSArray *array1 = [matchDic objectForKey:keyStr];
        [array addObject:array1];
    }

    count += [CalculateBetCount getNG1WithN:9 m:1 matchArray:array danArray:nil];
    
    return count;
}

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType {
    return NO;
}

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (lotteryID) {
        case 75:
            return @"任九场";
            break;
        default:
            break;
    }
    return @"";
}

@end