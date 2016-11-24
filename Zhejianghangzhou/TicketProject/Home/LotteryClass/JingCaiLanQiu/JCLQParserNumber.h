//
//  JCLQParserNumber.h
//  TicketProject
//
//  Created by KAI on 15-1-4.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLQParserNumber : NSObject

+ (NSInteger)firstTypePlayIdWithBetTypeArray:(NSMutableArray *)betTypeArray;

+ (void)customParserJCOrderMatchDeitalWithDict:(NSDictionary *)jcOrderMatchDeitalDict matchDeitalArray:(NSMutableArray *)matchDeitalArray lotteryId:(NSInteger)lotteryId;

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number;

@end
