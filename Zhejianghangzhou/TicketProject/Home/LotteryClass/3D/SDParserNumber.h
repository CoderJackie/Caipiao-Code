//
//  SDParserNumber.h
//  TicketProject
//
//  Created by KAI on 15-1-3.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDParserNumber : NSObject

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray;

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict;

+ (NSString *)get3DBetNumberStringWithOneArray:(NSArray *)onearr
                                           two:(NSArray *)twoarr
                                         three:(NSArray *)threearr
                                     andPlayID:(NSInteger)playid
                             andPlayMethodName:(NSString *)playname;

+ (NSInteger)getCountFor3DWithOneArray:(NSArray *)onearr
                                   two:(NSArray *)twoarr
                                 three:(NSArray *)threearr
                             andPlayID:(NSInteger)playID
                     andPlayMethodName:(NSString *)playMethodName;

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType;

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number;

@end
