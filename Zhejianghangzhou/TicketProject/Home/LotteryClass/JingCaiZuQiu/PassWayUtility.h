//
//  PassWayUtility.h
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PassWayUtility : NSObject

+(NSArray *)getFreePassItemsWithMatchCount:(NSInteger)count;
+(NSArray *)getMixPassItemsWithMatchCount:(NSInteger)count;

+(NSArray *)getFreePassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount;
+(NSArray *)getFreePassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount playID:(NSInteger)playID playType:(NSInteger)playType;
+(NSArray *)getMixPassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount;
+(NSArray *)getMixPassItemsWithMatchCount:(NSInteger)count danCount:(NSInteger)danCount playType:(NSInteger)playType;

+(NSString *)getPassWayCodeWithString:(NSString *)string;
+(NSString *)getPassWayBJDCCodeWithString:(NSString *)string;

@end
