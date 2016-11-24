//
//  CustomResultParser.h   对数据进行安全解析，同时方便查看
//  TicketProject
//
//  Created by KAI on 14-7-8.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomResultParser : NSObject


+ (NSString *)parseResult:(id)_result toHomeInfoDict:(NSMutableDictionary *)_infoDict explanationDict:(NSMutableDictionary *)_explanationDict tag:(NSInteger)_tag;
/* 用户登录后的解析 */
+ (void)parseResult:(id)_result toUserInfoDict:(NSMutableDictionary *)_infoDict;

//+ (void)parseResult:(NSDictionary *)_result withChaseBetOrderDict:(NSMutableDictionary *)_dict;

+ (NSInteger)parseResult:(id)_result withNormalOrderArray:(NSMutableArray *)_chaseArray timeInt:(NSInteger)timeInt;

+ (NSInteger)parseResult:(id)_result withChaseOrderArray:(NSMutableArray *)_chaseArray timeInt:(NSInteger)timeInt;

+ (void)parseResult:(id)_result withChaseOrdersDict:(NSMutableDictionary *)_chaseOrdersDict;

+ (NSInteger)lastCalculateNumberParseResultArray:(NSArray *)resultArray integralDetailArray:(NSMutableArray *)integralDetailArray calculateNumber:(NSInteger)calculateNumber;

@end
