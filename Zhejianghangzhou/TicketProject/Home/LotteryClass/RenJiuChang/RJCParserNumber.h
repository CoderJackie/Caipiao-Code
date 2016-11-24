//
//  RJCParserNumber.h
//  TicketProject
//
//  Created by KAI on 15-1-7.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJCParserNumber : NSObject

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict;

+ (NSString *)getRJCTextWithDict:(NSDictionary *)dict matchCount:(NSInteger)matchCount;

+ (long)getCountForRJXWithSelectMatchDic:(NSDictionary *)matchDic;

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType;

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number;

@end
