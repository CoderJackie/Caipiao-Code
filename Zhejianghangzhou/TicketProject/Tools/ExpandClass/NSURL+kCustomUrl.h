//
//  NSURL+kCustomUrl.h
//  TicketProject
//
//  Created by KAI on 14-9-1.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RechargeTypeOfNone,
    RechargeTypeOfUPPayPlugin,
    RechargeTypeOfAlixPay,
} RechargeType;


@interface NSURL (kCustomUrl)
/*返回直接用于请求URL地址，
 @param shoveOpt 请求编号
 @param userId 用户id，如果没有可用“－1”
 @param infoDict 服务器需要的数据字典 可以为nil
 @return URL完整请求
 */
+ (NSURL *)shoveURLWithOpt:(NSString *)shoveOpt userId:(NSString *)userId infoDict:(NSDictionary *)infoDict;

/*返回直接用于请求URL地址，充值使用
 @param userId 用户id，如果没有可用“－1”
 @param money 充值金额
 @param rechargeType 充值类型
 @return URL充值完整请求
 */
+ (NSURL *)shoveRechargeURLWithUserId:(NSString *)userId money:(NSString *)money rechargeType:(RechargeType)rechargeType;
@end
