//
//  JCLQParserNumber.m  73 竞彩篮球
//  TicketProject
//
//  Created by KAI on 15-1-4.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "JCLQParserNumber.h"

@implementation JCLQParserNumber

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray {
    [betTypeArray addObject:@"混合过关"];
    [betTypeArray addObject:@"胜负"];
    [betTypeArray addObject:@"让分胜负"];
    [betTypeArray addObject:@"胜分差"];
    [betTypeArray addObject:@"大小分"];
    return 7306;
}

+ (void)customParserJCOrderMatchDeitalWithDict:(NSDictionary *)jcOrderMatchDeitalDict matchDeitalArray:(NSMutableArray *)matchDeitalArray lotteryId:(NSInteger)lotteryId { //只拿部分自己需要的东西，如果需求有改变，自己添加
    if (!jcOrderMatchDeitalDict) {
        return;
    }
    
    if (lotteryId == 73) {
        
        NSString  *passTypeInfo = [jcOrderMatchDeitalDict objectForKey:@"passTypeInfo"];
        NSString  *serverTime = [jcOrderMatchDeitalDict objectForKey:@"serverTime"];
        NSString  *preBetType = [jcOrderMatchDeitalDict objectForKey:@"preBetType"];
        
        NSMutableDictionary *detDict = [[NSMutableDictionary alloc] init];
        [detDict setObject:passTypeInfo == nil ? @"" : passTypeInfo forKey:@"passTypeInfo"];
        [detDict setObject:serverTime == nil ? @"" : serverTime forKey:@"serverTime"];
        [detDict setObject:preBetType == nil ? @"" : preBetType forKey:@"preBetType"];
        
        NSArray *matchInformationArray = [jcOrderMatchDeitalDict objectForKey:@"informationId"];    // 未优化数据
        NSMutableArray *informationDic = [NSMutableArray array];
        for (NSDictionary *oneMatchDetailDict in matchInformationArray) {
            if (![oneMatchDetailDict isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSString  *endTime = [oneMatchDetailDict stringForKey:@"EndTime"];
            NSString  *game = [oneMatchDetailDict stringForKey:@"Game"];
            NSString  *guestTeam = [oneMatchDetailDict stringForKey:@"GuestTeam"];
            NSInteger matchId = [oneMatchDetailDict intValueForKey:@"ID"];
            NSString  *dan = [oneMatchDetailDict stringForKey:@"LetBile"];
            NSString  *mainTeam = [oneMatchDetailDict stringForKey:@"MaiTeam"];
            NSString  *letScore = [oneMatchDetailDict stringForKey:@"LetScore"];
            NSString  *bigSmallScore = [oneMatchDetailDict stringForKey:@"BigSmallScore"];
            NSString  *matchSelectMessage = [oneMatchDetailDict stringForKey:@"MatchNumber"]; //投注文字的
            NSString  *passType = [oneMatchDetailDict stringForKey:@"PassType"];
            NSInteger  playType = [oneMatchDetailDict intValueForKey:@"PlayType"];
            NSString  *results = [oneMatchDetailDict stringForKey:@"Results"];
            NSInteger  schemeID = [oneMatchDetailDict intValueForKey:@"SchemeID"];
            NSString  *score = [oneMatchDetailDict stringForKey:@"Score"];
            NSInteger  status = [oneMatchDetailDict intValueForKey:@"Status"];
            NSString  *stopSelling = [oneMatchDetailDict stringForKey:@"StopSelling"];
            NSString  *investContent = [oneMatchDetailDict stringForKey:@"investContent"];
            NSString  *issue = [oneMatchDetailDict stringForKey:@"issue"];
            NSString  *matchNumber = [oneMatchDetailDict stringForKey:@"Content"];//投注号码的
            
            
            NSMutableDictionary *detaiDict = [[NSMutableDictionary alloc] init];
            [detaiDict setObject:game == nil ? @"" : game forKey:@"game"];
            [detaiDict setObject:[NSNumber numberWithInteger:matchId] forKey:@"matchId"];
            [detaiDict setObject:dan == nil ? @"" : dan forKey:@"dan"];
            [detaiDict setObject:letScore == nil ? @"" : letScore forKey:@"letBall"];
            [detaiDict setObject:bigSmallScore == nil ? @"" : bigSmallScore forKey:@"bigSmallScore"];
            [detaiDict setObject:passType == nil ? @"" : passType forKey:@"passType"];
            [detaiDict setObject:[NSNumber numberWithInteger:playType] forKey:@"playType"];
            [detaiDict setObject:[NSNumber numberWithInteger:schemeID] forKey:@"schemeID"];
            [detaiDict setObject:score == nil ? @"" : score forKey:@"score"];
            [detaiDict setObject:[NSNumber numberWithInteger:status] forKey:@"status"];
            [detaiDict setObject:stopSelling == nil ? @"" : stopSelling forKey:@"stopSelling"];
            [detaiDict setObject:investContent == nil ? @"" : investContent forKey:@"investContent"];
            [detaiDict setObject:issue == nil ? @"" : issue forKey:@"issue"];
            [detaiDict setObject:endTime == nil ? @"" : endTime forKey:@"endTime"];
            
            [self parserMatchTeamWithMainTeamName:mainTeam guestTeamName:guestTeam detaiDict:detaiDict];
            [self parserMatchTime:matchSelectMessage detaiDict:detaiDict];
            [self parserJCMatchSelectMessage:matchSelectMessage results:results matchNumber:matchNumber detaiDict:detaiDict playType:playType];
            
            [informationDic addObject:detaiDict];
            
            [detaiDict release];
        }
        
        NSArray *matchOptimizationArray = [jcOrderMatchDeitalDict objectForKey:@"optimization"];    // 优化后
        NSMutableArray *optimizationDic = [NSMutableArray array];
        for (NSDictionary *twoMatchDetailDict in matchOptimizationArray) {
            if (![twoMatchDetailDict isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSString  *ggWay = [twoMatchDetailDict stringForKey:@"ggWay"];              // 过关方式
            NSString  *investNum = [twoMatchDetailDict stringForKey:@"investNum"];      // 注数
            
            NSString * buyContent = [twoMatchDetailDict stringForKey:@"buyContent"];
            NSArray  * buyContentArr = [buyContent componentsSeparatedByString:@","];   // 投注内容
            
            NSString * result = [twoMatchDetailDict stringForKey:@"result"];
            NSArray  * resultArr = [result componentsSeparatedByString:@","];           // 赛果
            
            NSString * markRed = [twoMatchDetailDict stringForKey:@"markRed"];
            NSArray  * markRedArr = [markRed componentsSeparatedByString:@","];         // 是否中奖标识 （0：未中奖    1：中奖 < 中奖内容标红 >）
            
            NSMutableDictionary *detaiDict = [[NSMutableDictionary alloc] init];
            [detaiDict setObject:investNum == nil ? @"" : investNum forKey:@"investNum"];
            [detaiDict setObject:ggWay == nil ? @"" : ggWay forKey:@"ggWay"];
            [detaiDict setObject:buyContentArr == nil ? @"" : buyContentArr forKey:@"buyContentArr"];
            [detaiDict setObject:resultArr == nil ? @"" : resultArr forKey:@"resultArr"];
            [detaiDict setObject:markRedArr == nil ? @"" : markRedArr forKey:@"markRedArr"];
            [detaiDict setObject:[NSNumber numberWithInteger:[buyContentArr count]] forKey:@"oneMatchCount"];
            
            [optimizationDic addObject:detaiDict];
            
            [detaiDict release];
        }
        
        [detDict setObject:informationDic forKey:@"informationId"];
        [detDict setObject:optimizationDic forKey:@"optimization"];
        [matchDeitalArray addObject:detDict];
    }
}

+ (void)parserMatchTeamWithMainTeamName:(NSString *)mainTeamName guestTeamName:(NSString *)guestTeamName detaiDict:(NSMutableDictionary *)detaiDict {
    [detaiDict setObject:[NSString stringWithFormat:@"%@\nVS\n%@",mainTeamName,guestTeamName] forKey:@"teamsMessage"];
}

+ (void)parserMatchTime:(NSString *)matchSelectMessage detaiDict:(NSMutableDictionary *)detaiDict {
    if (matchSelectMessage.length > 2) {
        NSString *firstMatchTime = [matchSelectMessage substringWithRange:NSMakeRange(0, 2)];
        NSString *secondMatchTime = [matchSelectMessage substringWithRange:NSMakeRange(2, matchSelectMessage.length - 2)];
        [detaiDict setObject:[NSString stringWithFormat:@"%@\n%@",firstMatchTime,secondMatchTime] forKey:@"matchTime"];
        
    } else {
        [detaiDict setObject:@"" forKey:@"matchTime"];
    }
}

+ (void)parserJCMatchSelectMessage:(NSString *)matchSelectMessage results:(NSString *)results matchNumber:(NSString *)matchNumber detaiDict:(NSMutableDictionary *)detaiDict playType:(NSInteger)playType {
    
    results = [results stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    matchNumber = [matchNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *matchNumberArray = [matchNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSArray *resultArray = [results componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    
    BOOL isFirst = YES;
    NSInteger oneMatchCount = 0;
    
    NSInteger numIndexSign = 0;//判断号码是哪种类型的
    NSInteger resultIndex = 0;
    NSString  *palyTypeName = @"";
    NSString  *isLetWinLose = @"NO";
    NSString  *isBigSmaleSocre = @"NO";
    
    NSMutableArray *playTypesArray = [[NSMutableArray alloc] init]; //存进竞彩各个玩法的号码数组
    NSMutableDictionary *playTypeDict = [[NSMutableDictionary alloc] init]; //单个玩法的信息字典
    NSMutableArray *onePlayTypeNumberArray = [[NSMutableArray alloc] init];//单个玩法内的选号
    for (NSInteger i = 0; i < [matchNumberArray count]; i++) {
        
        NSString *numberOddsStr = [matchNumberArray objectAtIndex:i];
        
        numberOddsStr = [numberOddsStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *numberOddsArray = [numberOddsStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        
        if ([numberOddsArray count] > 1) {
            NSInteger numberInt = [[numberOddsArray objectAtIndex:0] integerValue];
            NSString  *odds = [numberOddsArray objectAtIndex:1];
            
            oneMatchCount++;
            
            if (isFirst) {
                numIndexSign = numberInt / 100;
                isFirst = NO;
            }
            
            if (numIndexSign == numberInt / 100) {//根据号码分组
                
                NSMutableDictionary *numberDict = [self getDictWithNumberInt:numberInt odds:odds playType:playType];
                [onePlayTypeNumberArray addObject:numberDict];
                palyTypeName = [self jcPlayTypeNameWithPlayType:playType numberInt:numberInt];
                isLetWinLose = [self isLetWithNumberInt:numberInt playType:playType];
                isBigSmaleSocre = [self isBigSmallWithNumberInt:numberInt playType:playType];
                
                
            }
            
            if (numIndexSign != numberInt / 100) {
                //添加数据到数组 过到下一组的时候
                NSString *resultStr = [self judgeResultStrWithResultIndex:resultIndex resultArray:resultArray];
                resultIndex++;
                [self setMessageToDict:playTypeDict numberArray:onePlayTypeNumberArray playTypeMatchCount:oneMatchCount - 1 oneMatchResult:resultStr isLetWinLose:isLetWinLose isBigSmall:isBigSmaleSocre palyTypeName:palyTypeName];
                
                [onePlayTypeNumberArray release];
                onePlayTypeNumberArray = [[NSMutableArray alloc] init];
                
                
                [playTypesArray addObject:playTypeDict];
                [playTypeDict release];
                
                //创建新数组存数据
                playTypeDict = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *numberDict = [self getDictWithNumberInt:numberInt odds:odds playType:playType];
                [onePlayTypeNumberArray addObject:numberDict];
                palyTypeName = [self jcPlayTypeNameWithPlayType:playType numberInt:numberInt];
                isBigSmaleSocre = [self isBigSmallWithNumberInt:numberInt playType:playType];
                isLetWinLose = [self isLetWithNumberInt:numberInt playType:playType];
                numIndexSign = numberInt / 100;//重新定数组标识
                oneMatchCount = 1;
                
            }
            
            //最后一个的时候，直接存数组
            if (i == [matchNumberArray count] - 1) {
                NSString *resultStr = [self judgeResultStrWithResultIndex:resultIndex resultArray:resultArray];
                [self setMessageToDict:playTypeDict numberArray:onePlayTypeNumberArray playTypeMatchCount:oneMatchCount oneMatchResult:resultStr isLetWinLose:isLetWinLose isBigSmall:isBigSmaleSocre palyTypeName:palyTypeName];
                
                [onePlayTypeNumberArray release];
                onePlayTypeNumberArray = [[NSMutableArray alloc] init];
                
                
                [playTypesArray addObject:playTypeDict];
                [playTypeDict release];
                playTypeDict = [[NSMutableDictionary alloc] init];
            }
        }
    }
    [detaiDict setObject:[NSNumber numberWithInteger:[matchNumberArray count]] forKey:@"oneMatchCount"];
    [detaiDict setObject:playTypesArray forKey:@"jcPlayTypeDetailNumber"];
    [playTypesArray release];
    [onePlayTypeNumberArray release];
    [playTypeDict release];
}

+ (NSString *)judgeResultStrWithResultIndex:(NSInteger)resultIndex  resultArray:(NSArray *)resultArray {
    if (resultIndex < [resultArray count]) {
        NSString *resultStr = [resultArray objectAtIndex:resultIndex];
        if (resultStr.length == 0) {
            return @"";
        } else {
            return resultStr;
        }
    } else {
        return @"";
    }
}

+ (NSString *)isLetWithNumberInt:(NSInteger)numberInt playType:(NSInteger)playType {
    if (playType == 7302 || (playType == 7306 && numberInt >= 200 && numberInt <= 299)) {
        return @"YES";
    } else {
        return @"NO";
    }
}

+ (NSString *)isBigSmallWithNumberInt:(NSInteger)numberInt playType:(NSInteger)playType {
    if (playType == 7304 || (playType == 7306 && numberInt >= 400 && numberInt <= 499)) {
        return @"YES";
    } else {
        return @"NO";
    }
}

+ (void)setMessageToDict:(NSMutableDictionary *)playTypeDict numberArray:(NSMutableArray *)numberArray playTypeMatchCount:(NSInteger)playTypeMatchCount oneMatchResult:(NSString *)oneMatchResult isLetWinLose:(NSString *)isLetWinLose isBigSmall:(NSString *)isBigSmall palyTypeName:(NSString *)palyTypeName {
    [playTypeDict setObject:numberArray forKey:@"typeNumber"];
    [playTypeDict setObject:[NSNumber numberWithInteger:playTypeMatchCount] forKey:@"playTypeMatchCount"];
    [playTypeDict setObject:oneMatchResult.length == 0 ? @"待定" : oneMatchResult forKey:@"oneMatchResult"];
    [playTypeDict setObject:oneMatchResult.length == 0 ? @"NO" : @"YES" forKey:@"hasResult"];
    [playTypeDict setObject:palyTypeName forKey:@"palyTypeName"];
    [playTypeDict setObject:isLetWinLose forKey:@"isLet"];
    [playTypeDict setObject:isBigSmall forKey:@"isBigSmall"];
}

+ (NSMutableDictionary *)getDictWithNumberInt:(NSInteger)numberInt odds:(NSString *)odds playType:(NSInteger)playType {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:numberInt] forKey:@"number"];
    [dict setObject:odds == nil ? @"" : odds forKey:@"odds"];
    NSString *numberText = [self getJCNumberTextWithNumberInt:numberInt playType:playType];
    [dict setObject:numberText forKey:@"text"];
    
    return [dict autorelease];
}

+ (NSString *)getJCNumberTextWithNumberInt:(NSInteger)numberInt playType:(NSInteger)playType {
    switch (playType) {
        case 7301:
        case 7302:
        case 7303:
        case 7304:
        case 7306:
        {
            NSInteger textType = 0;//提示文字 1为胜负文字类型 2为让分文字类型 3为胜分差文字类型 4为大小分文字类型
            NSInteger judgeNumberIndex = 0;//数字以混合投注为主要依据
            if (playType == 7301) {//胜负
                textType = 1;
                judgeNumberIndex = numberInt + 100;
                
            } else if (playType == 7302) { //让分胜负
                textType = 2;
                judgeNumberIndex = numberInt + 200;
                
            } else if (playType == 7303) { //胜分差
                textType = 3;
                judgeNumberIndex = numberInt + 300;
                
            } else if (playType == 7304) { //大小分
                textType = 4;
                judgeNumberIndex = numberInt + 400;
                
            } else if (playType == 7306) {
                if (numberInt >= 100 && numberInt < 199) {//胜负
                    textType = 1;
                    
                } else if (numberInt >= 200 && numberInt < 299) {//让分胜负
                    textType = 2;
                    
                } else if (numberInt >= 300 && numberInt < 399) {//胜分差
                    textType = 3;
                    
                } else if (numberInt >= 400 && numberInt < 499) {//半全场
                    textType = 4;
                    
                }
                
                judgeNumberIndex = numberInt;
            }
            
            switch (textType) {
                case 1:
                {
                    switch (judgeNumberIndex) {
                        case 101:
                            return @"主负";
                            break;
                        case 102:
                            return @"主胜";
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 2:
                {
                    switch (judgeNumberIndex) {
                        case 201:
                            return @"让主负";
                            break;
                        case 202:
                            return @"让主胜";
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 3:
                {
                    switch (judgeNumberIndex) {//胜分差
                        case 301:
                        case 303:
                        case 305:
                        case 307:
                        case 309:
                        case 311:
                            return [NSString stringWithFormat:@"客胜%@ ",[self numToNumWithTag:judgeNumberIndex % 100 Chase:YES isText:YES]];
                            break;
                        case 302:
                        case 304:
                        case 306:
                        case 308:
                        case 310:
                        case 312:
                            return [NSString stringWithFormat:@"主胜%@ ",[self numToNumWithTag:judgeNumberIndex % 100 Chase:YES isText:YES]];
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 4:
                {
                    switch (judgeNumberIndex) {
                        case 401:
                            return @"大分";
//                            return @"小分";
                            break;
                        case 402:
                            return @"小分";
//                            return @"大分";
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
    return @"";
}

+ (NSString *)numToNumWithTag:(NSInteger)tag Chase:(BOOL)isChase isText:(BOOL)isText { //胜分差
    NSString *numToNumString = @"";
    NSInteger sign = (tag % 100 - 1) / 2;
    numToNumString = [NSString stringWithFormat:@"%@%ld",numToNumString ,(long)(sign * 5 + 1)];
    if (sign < 5) {
        numToNumString = [NSString stringWithFormat:@"%@%@%ld",numToNumString,isText ? @"-" : @"_",(long)((sign + 1) * 5)];
    } else if (isChase) {
        numToNumString = [NSString stringWithFormat:@"%@+",numToNumString];
    }
    return numToNumString;
}

+ (NSString *)jcPlayTypeNameWithPlayType:(NSInteger)playType numberInt:(NSInteger)numberInt {
    switch (playType) {
        case 7301:
            return @"胜负";
            break;
        case 7302:
            return @"让分";
            break;
        case 7303:
            return @"胜分差";
            break;
        case 7304:
            return @"大小分";
            break;
        case 7306:
        {
            if(numberInt >= 100 && numberInt < 199) {
                return @"胜负";
                
            } else if(numberInt >= 200 && numberInt < 299) {
                return @"让分";
                
            } else if(numberInt >= 300 && numberInt < 399) {
                return @"胜分差";
                
            } else if(numberInt >= 400 && numberInt < 499) {
                return @"大小分";
                
            }
        }
            break;
            
        default:
            break;
    }
    return @"";
}

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (playID) {
        case 7301:
            return @"胜负";
            break;
        case 7302:
            return @"让分胜负";
            break;
        case 7303:
            return @"胜分差";
            break;
        case 7304:
            return @"大小分";
            break;
        case 7306:
            return @"混合投注";
            break;
    }

    return @"";
}


@end
