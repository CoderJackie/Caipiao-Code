//
//  SFCParserNumber.h
//  TicketProject
//
//  Created by KAI on 15-1-5.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFCParserNumber : NSObject

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict;

+ (NSString *)getSFCTextWithDict:(NSDictionary *)dict;

+ (long)getCountForSFCWithSelectMatchDic:(NSDictionary *)matchDic;

+ (BOOL)isSupportShakeWithPalyType:(NSInteger)palyType;

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number;

@end
