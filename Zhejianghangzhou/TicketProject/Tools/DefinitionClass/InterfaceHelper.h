//
//  InterfaceHelper.h
//  TicketProject
//
//  Created by sls002 on 13-5-31.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InterfaceHelper : NSObject

+ (NSString *)MD5:(NSString *)str;

+ (NSString *)getCurrentDateString;

+ (NSString *)getAuthStrWithCrc:(NSString *)crc UID:(NSString *)uid TimeStamp:(NSString *)timeStamp;

+ (NSString *)getCrcWithInfo:(NSString *)info UID:(NSString *)uid TimeStamp:(NSString *)timeStamp;

+ (NSString *)getLotteryMessageWithLotteryName:(NSString *)lotteryName messageType:(NSInteger)messageType;

+ (NSString *)getNotJCLotteryStr:(NSMutableArray *)nameArray;

+ (BOOL)isQuickLotteryWithLotteryID:(NSInteger)lotteryID;

+ (BOOL)isTimeQuickLotteryWithLotteryID:(NSInteger)lotteryID;

// 获取所有彩种的id串
+ (NSString *)getAllLotteryString;
//// 获取请求彩种id串(不包括竞彩)
//+ (NSString *)getRequestLotteryString;

+ (NSDictionary *)getLotteryIDNameDic;

+(NSDictionary *)getWinLotteryIDNameDic;

+ (NSDictionary *)getLotteryInfoWithID:(NSString *)_lotteryId;

+ (NSString *)replaceString:(NSString *)str InRange:(NSRange)range WithCharacter:(NSString *)character;

@end
