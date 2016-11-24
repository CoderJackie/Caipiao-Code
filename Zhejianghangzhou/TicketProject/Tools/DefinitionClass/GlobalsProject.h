//
//  GlobalsProject.h
//  TicketProject
//
//  Created by KAI on 14-10-16.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalsProject : NSObject

+ (UIViewController *)viewController:(NSInteger)lotteryid initWithInfoData:(NSObject *)obj;

+ (UIViewController *)betViewControllerBallsInfoDict:(NSDictionary *)betsContentDict lotteryDict:(NSDictionary*)lotteryDict lotteryId:(NSInteger)lotteryid initWithPlayType:(NSInteger)playType;

+ (void)parserBetNumberWithRecordDictionart:(NSDictionary *)recordDict numberDictionary:(NSMutableDictionary *)numberDict;

+ (void)customParserJCOrderMatchDeitalWithDict:(NSDictionary *)jcOrderMatchDeitalDict matchDeitalArray:(NSMutableArray *)matchDeitalArray lotteryId:(NSInteger)lotteryId;

+ (BOOL)recordContinueBet:(NSInteger)lotteryid;

+ (NSString *)judgeRecordPlayNameWithLotteryID:(NSInteger)lotteryID playId:(NSInteger)playID number:(NSString *)number;

+ (NSInteger)firstTypePlayIdWithTicketTypeName:(NSString *)ticketTypeName betTypeArray:(NSMutableArray *)betTypeArray;

+ (NSString *)helpTxtNameWithPlayID:(NSInteger)playId;

@end
