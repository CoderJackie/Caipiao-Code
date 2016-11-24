//
//  DLTParserNumber.h
//  TicketProject
//
//  Created by KAI on 15-1-3.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLTParserNumber : NSObject

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray;

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict;

+ (NSString *)getDLTBetNumberStringWithOneArray:(NSArray *)onearr
                                            two:(NSArray *)twoarr
                                          three:(NSArray *)threearr
                                           four:(NSArray *)fourarr
                                      andPlayID:(NSInteger)playid
                              andPlayMethodName:(NSString *)playname;

+ (NSInteger)getCountForDLTWithOneArray:(NSArray *)onearr
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
