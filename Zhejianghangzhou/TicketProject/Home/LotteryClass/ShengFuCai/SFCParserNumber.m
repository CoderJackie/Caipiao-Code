//
//  SFCParserNumber.m  74 胜负彩
//  TicketProject
//
//  Created by KAI on 15-1-5.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "SFCParserNumber.h"
#import "CalculateBetCount.h"
#import "CustomParserNumber.h"

@implementation SFCParserNumber

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
        
        if (playId == 7401) {//胜负彩
            hasBall = [CustomParserNumber splitBallViewNumber_5_WithDict:selectMatchDict selectBallsTrimmedString:selectBallsTrimmedString ballNumArrayKeyNameType:BallNumArrayKeyTypeOfNum deleteLine:YES];
            
        }
        
        if (hasBall == NO) {
            continue;
        }
        
        
        NSString *selectNumber = [self getSFCTextWithDict:selectMatchDict];
        
        NSInteger totalBetCount = [self getCountForSFCWithSelectMatchDic:selectMatchDict];
        
        [dict setObject:selectMatchDict forKey:@"selectMatchDic"];
        [dict setObject:selectNumber forKey:kSelectBalls]; //准备投注的拼接号码
        [dict setObject:[NSNumber numberWithInteger:totalBetCount] forKey:kBetCount];//该组选号的注数
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
    if (playId == 7401) {
        for (NSInteger i = 0; i < 14; i++) {
            text = [NSString stringWithFormat:@"%@%@",text,[CustomParserNumber comparisonWinArray:[winParserDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] selectArray:[selectDict objectForKey:[NSString stringWithFormat:@"%ld",(long)i]] textColor:redTextColor enterCharType:EnterTypeBothSides enterChar:@"(" spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:NO]];
        }
    }
    
    return text;
}

+ (NSString *)getSFCTextWithDict:(NSDictionary *)dict {
    NSString *formateSelectBalls = @"";
    for (int i = 0; i < dict.count; i++) {
        NSArray *selectArray = [dict objectForKey:[NSString stringWithFormat:@"%d",i]];
        
        if(selectArray.count > 1) {
            formateSelectBalls = [formateSelectBalls stringByAppendingFormat:@"(%@)",[selectArray componentsJoinedByString:@""]];
        } else {
            formateSelectBalls = [formateSelectBalls stringByAppendingFormat:@"%@",[selectArray componentsJoinedByString:@""]];
        }
    }
    return formateSelectBalls;
}

+ (long)getCountForSFCWithSelectMatchDic:(NSDictionary *)matchDic {
    int count = 0;
    int temp = 1;
    
    if (matchDic.count < 14) {
        count = 0;
    } else {
        for (int i = 0; i < matchDic.count; i++) {
            NSArray *array = [matchDic objectForKey:[NSString stringWithFormat:@"%d",i]];
            
            temp *= array.count;
        }
        count = temp;
    }
    return count;
}

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType {
    return NO;
}

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (lotteryID) {
        case 74:
            return @"胜负彩";
            break;
        default:
            break;
    }
    return @"";
}

@end
