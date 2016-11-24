//
//  JCZQParserNumber.m  72 竞彩足球
//  TicketProject
//
//  Created by KAI on 15-1-4.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "JCZQParserNumber.h"

@implementation JCZQParserNumber

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray {
    [betTypeArray addObject:@"混合过关"];
    [betTypeArray addObject:@"让球胜平负"];
    [betTypeArray addObject:@"胜平负"];
    [betTypeArray addObject:@"比分"];
    [betTypeArray addObject:@"总进球"];
    [betTypeArray addObject:@"半全场"];
    return 7206;
}

+ (void)customParserJCOrderMatchDeitalWithDict:(NSDictionary *)jcOrderMatchDeitalDict matchDeitalArray:(NSMutableArray *)matchDeitalArray lotteryId:(NSInteger)lotteryId { //只拿部分自己需要的东西，如果需求有改变，自己添加
    if (!jcOrderMatchDeitalDict) {
        return;
    }
    
    if (lotteryId == 72) {
        NSString  *passTypeInfo = [jcOrderMatchDeitalDict objectForKey:@"passTypeInfo"];
        NSString  *serverTime = [jcOrderMatchDeitalDict objectForKey:@"serverTime"];
        NSString  *preBetType = [jcOrderMatchDeitalDict objectForKey:@"preBetType"];
        NSString  *isHide = [jcOrderMatchDeitalDict objectForKey:@"isHide"];
        NSString  *secretMsg = [jcOrderMatchDeitalDict objectForKey:@"secretMsg"];
        
        NSMutableDictionary *detDict = [[NSMutableDictionary alloc] init];
        [detDict setObject:passTypeInfo == nil ? @"" : passTypeInfo forKey:@"passTypeInfo"];
        [detDict setObject:serverTime == nil ? @"" : serverTime forKey:@"serverTime"];
        [detDict setObject:preBetType == nil ? @"" : preBetType forKey:@"preBetType"];
        [detDict setObject:isHide == nil ? @"" : isHide forKey:@"isHide"];
        [detDict setObject:secretMsg == nil ? @"" : secretMsg forKey:@"secretMsg"];
        
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
            NSString  *letBall = [oneMatchDetailDict stringForKey:@"MainLoseball"];
            NSString  *mainTeam = [oneMatchDetailDict stringForKey:@"MaiTeam"];
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
            [detaiDict setObject:letBall == nil ? @"" : letBall forKey:@"letBall"];
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
                
                
            }
            
            if (numIndexSign != numberInt / 100) {
                //添加数据到数组 过到下一组的时候
                NSString *resultStr = [self judgeResultStrWithResultIndex:resultIndex resultArray:resultArray];
                resultIndex++;
                [self setMessageToDict:playTypeDict numberArray:onePlayTypeNumberArray playTypeMatchCount:oneMatchCount - 1 oneMatchResult:resultStr isLetWinLose:isLetWinLose palyTypeName:palyTypeName];
                
                [onePlayTypeNumberArray release];
                onePlayTypeNumberArray = [[NSMutableArray alloc] init];
                
                
                [playTypesArray addObject:playTypeDict];
                [playTypeDict release];
                
                //创建新数组存数据
                playTypeDict = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *numberDict = [self getDictWithNumberInt:numberInt odds:odds playType:playType];
                [onePlayTypeNumberArray addObject:numberDict];
                palyTypeName = [self jcPlayTypeNameWithPlayType:playType numberInt:numberInt];
                isLetWinLose = [self isLetWithNumberInt:numberInt playType:playType];
                numIndexSign = numberInt / 100;//重新定数组标识
                oneMatchCount = 1;
                
            }
            
            //最后一个的时候，直接存数组
            if (i == [matchNumberArray count] - 1) {
                NSString *resultStr = [self judgeResultStrWithResultIndex:resultIndex resultArray:resultArray];
                [self setMessageToDict:playTypeDict numberArray:onePlayTypeNumberArray playTypeMatchCount:oneMatchCount oneMatchResult:resultStr isLetWinLose:isLetWinLose palyTypeName:palyTypeName];
                
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
    if ((numberInt >= 100 && numberInt <= 199 && playType == 7206) || playType == 7201) {
        return @"YES";
    } else {
        return @"NO";
    }
}

+ (void)setMessageToDict:(NSMutableDictionary *)playTypeDict numberArray:(NSMutableArray *)numberArray playTypeMatchCount:(NSInteger)playTypeMatchCount oneMatchResult:(NSString *)oneMatchResult isLetWinLose:(NSString *)isLetWinLose palyTypeName:(NSString *)palyTypeName {
    [playTypeDict setObject:numberArray forKey:@"typeNumber"];
    [playTypeDict setObject:[NSNumber numberWithInteger:playTypeMatchCount] forKey:@"playTypeMatchCount"];
    [playTypeDict setObject:oneMatchResult.length == 0 ? @"待定" : oneMatchResult forKey:@"oneMatchResult"];
    [playTypeDict setObject:oneMatchResult.length == 0 ? @"NO" : @"YES" forKey:@"hasResult"];
    [playTypeDict setObject:palyTypeName forKey:@"palyTypeName"];
    [playTypeDict setObject:isLetWinLose forKey:@"isLet"];
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
        case 7201:
        case 7202:
        case 7203:
        case 7204:
        case 7207:
        case 7206:
        {
            NSInteger textType = 0;//提示文字 1为胜平负文字类型 2为让球文字类型 3为猜比分文字类型 4为总进球文字类型 5为半全场文字类型
            NSInteger judgeNumberIndex = 0;//数字以混合投注为主要依据
            if (playType == 7201) {//让球胜平负
                textType = 2;
                judgeNumberIndex = numberInt + 100;
                
            } else if (playType == 7202) { //猜比分
                textType = 3;
                judgeNumberIndex = numberInt + 300;
                
            } else if (playType == 7203) { //总进球
                textType = 4;
                judgeNumberIndex = numberInt + 200;
                
            } else if (playType == 7204) { //半全场
                textType = 5;
                judgeNumberIndex = numberInt + 400;
                
            } else if (playType == 7207) { //胜平负
                textType = 1;
                judgeNumberIndex = numberInt + 500;
                
            } else if (playType == 7206) {
                if (numberInt >= 500 && numberInt < 599) {//胜平负
                    textType = 1;
                    
                } else if (numberInt >= 200 && numberInt < 299) {//总进球
                    textType = 4;
                    
                } else if (numberInt >= 300 && numberInt < 399) {//猜比分
                    textType = 3;
                    
                } else if (numberInt >= 400 && numberInt < 499) {//半全场
                    textType = 5;
                    
                } else if (numberInt >= 100 && numberInt < 199) {//让球胜平负
                    textType = 2;
                    
                }
                
                judgeNumberIndex = numberInt;
            }
            
            
            switch (textType) {
                case 1://1为胜平负文字类型
                {
                    switch (judgeNumberIndex) {
                        case 501:
                            return @"胜";
                            break;
                        case 502:
                            return @"平";
                            break;
                        case 503:
                            return @"负";
                            break;
                            
                        default:
                            break;
                    }
                }
                case 2://2为让球文字类型
                {
                    switch (judgeNumberIndex) {
                        case 101:
                            return @"让球胜";
                            break;
                        case 102:
                            return @"让球平";
                            break;
                        case 103:
                            return @"让球负";
                            break;
                            
                        default:
                            break;
                    }
                }
                case 3://3为猜比分文字类型
                {
                    switch (judgeNumberIndex) {
                        case 301:
                            return @"1:0";
                            break;
                        case 302:
                            return @"2:0";
                            break;
                        case 303:
                            return @"2:1";
                            break;
                        case 304:
                            return @"3:0";
                            break;
                        case 305:
                            return @"3:1";
                            break;
                        case 306:
                            return @"3:2";
                            break;
                        case 307:
                            return @"4:0";
                            break;
                        case 308:
                            return @"4:1";
                            break;
                        case 309:
                            return @"4:2";
                            break;
                        case 310:
                            return @"5:0";
                            break;
                        case 311:
                            return @"5:1";
                            break;
                        case 312:
                            return @"5:2";
                            break;
                        case 313:
                            return @"胜其他";
                            break;
                        case 314:
                            return @"0:0";
                            break;
                        case 315:
                            return @"1:1";
                            break;
                        case 316:
                            return @"2:2";
                            break;
                        case 317:
                            return @"3:3";
                            break;
                        case 318:
                            return @"平其他";
                            break;
                        case 319:
                            return @"0:1";
                            break;
                        case 320:
                            return @"0:2";
                            break;
                        case 321:
                            return @"1:2";
                            break;
                        case 322:
                            return @"0:3";
                            break;
                        case 323:
                            return @"1:3";
                            break;
                        case 324:
                            return @"2:3";
                            break;
                        case 325:
                            return @"0:4";
                            break;
                        case 326:
                            return @"1:4";
                            break;
                        case 327:
                            return @"2:4";
                            break;
                        case 328:
                            return @"0:5";
                            break;
                        case 329:
                            return @"1:5";
                            break;
                        case 330:
                            return @"2:5";
                            break;
                        case 331:
                            return @"负其他";
                            break;
                            
                        default:
                            break;
                    }
                }
                case 4://4为总进球文字类型
                {
                    if (judgeNumberIndex % 10 >= 8) {
                        return @"7+球";
                    }
                    return [NSString stringWithFormat:@"%ld球",(long)(judgeNumberIndex % 10 - 1)];
                }
                case 5://为半全场文字类型
                {
                    NSInteger indexSign = judgeNumberIndex % 10 - 1;
                    return [NSString stringWithFormat:@"%@%@",[self getTextWithJCIndex:(indexSign / 3)],[self getTextWithJCIndex:(indexSign % 3)]];
                }
                default:
                    break;
            }
            
        }
               default:
            break;
    }
    return @"";
}

+ (NSString *)getTextWithJCIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"胜";
            break;
        case 1:
            return @"平";
            break;
        case 2:
            return @"负";
            break;
            
        default:
            break;
    }
    return @"";
}

+ (NSString *)jcPlayTypeNameWithPlayType:(NSInteger)playType numberInt:(NSInteger)numberInt {
    switch (playType) {
        case 7201:
            return @"让球";
            break;
        case 7202:
            return @"比分";
            break;
        case 7203:
            return @"总进球";
            break;
        case 7204:
            return @"半全场";
            break;
        case 7206:
        {
            if(numberInt >= 500 && numberInt < 599) {
                return @"胜平负";
                
            } else if(numberInt >= 200 && numberInt < 299) {
                return @"总进球";
                
            } else if(numberInt >= 300 && numberInt < 399) {
                return @"比分";
                
            } else if(numberInt >= 400 && numberInt < 499) {
                return @"半全场";
                
            } else if(numberInt >= 100 && numberInt < 199) {
                return @"让球";
                
            }
        }
            break;
        case 7207:
            return @"胜平负";
            break;
            
        default:
            break;
    }
    return @"";
}

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number {
    switch (playID) {
        case 7201:
            return @"让球胜平负";
            break;
        case 7202:
            return @"比分";
            break;
        case 7203:
            return @"总进球";
            break;
        case 7205:
            return @"半全场";
            break;
        case 7206:
            return @"混合投注";
            break;
        case 7207:
            return @"胜平负";
            break;
    }
    return @"";
}

@end
