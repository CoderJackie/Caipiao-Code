//
//  SSQParserNumber.h
//  TicketProject
//
//  Created by KAI on 14-12-31.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSQParserNumber : NSObject

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray;

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict;

+ (NSString *)getSSQBetNumberStringWithOneArray:(NSArray *)onearr
                                            two:(NSArray *)twoarr
                                          three:(NSArray *)threearr
                                           four:(NSArray *)fourarr
                                      andPlayID:(NSInteger)playid
                              andPlayMethodName:(NSString *)playname;

+ (NSInteger)getCountForSSQWithOneArray:(NSArray *)onearr
                                    two:(NSArray *)twoarr
                                  three:(NSArray *)threearr
                                   four:(NSArray *)fourarr
                            basedRedNum:(NSInteger)redCounts
                           basedBlueNum:(NSInteger)blueCounts
                              andPlayID:(NSInteger)playID
                      andPlayMethodName:(NSString *)playMethodName;

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType;

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number;

@end
