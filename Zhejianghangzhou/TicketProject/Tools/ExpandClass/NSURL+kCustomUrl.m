//
//  NSURL+kCustomUrl.m
//  TicketProject
//
//  Created by KAI on 14-9-1.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "NSURL+kCustomUrl.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "ShoveGeneralRestGateway.h"

@implementation NSURL (kCustomUrl)

+ (NSURL *)shoveURLWithOpt:(NSString *)shoveOpt userId:(NSString *)userId infoDict:(NSDictionary *)infoDict {
    NSString *infoStr = [[infoDict JSONString] copy];
    
    NSString *currentDate = [InterfaceHelper getCurrentDateString];
    NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:userId == nil ? @"-1" : userId TimeStamp:currentDate];
    NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:userId == nil ? @"-1" : userId TimeStamp:currentDate];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:shoveOpt == nil ? @"" : shoveOpt forKey:kOpt];
    [dict setObject:auth == nil ? @"" : auth forKey:kAuth];
    [dict setObject:infoStr == nil ? @"" : infoStr forKey:kInfo];
    NSString *shoveBaseUrl = [ShoveGeneralRestGateway buildUrl:kBaseUrl key:kAppHttpKey parameters:dict];
    NSLog(@"\n\ndict:%@\n\n",dict);
    [dict release];
    
    [infoStr release];
    
    
    
    return [NSURL URLWithString:shoveBaseUrl];
}

+ (NSURL *)shoveRechargeURLWithUserId:(NSString *)userId money:(NSString *)money rechargeType:(RechargeType)rechargeType {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:userId == nil ? @"" : userId forKey:@"uid"];
    [dict setObject:money forKey:@"payMoney"];

    NSString *rechargeWebSite = nil;
    if (rechargeType == RechargeTypeOfUPPayPlugin) {
        rechargeWebSite = kUPPayPluginRechargeUrl;
        
    } else if (rechargeType == RechargeTypeOfAlixPay) {
        rechargeWebSite = kAlipayRechargeUrl;
        
    } else {
        rechargeWebSite = @"";
        
    }
    
    [dict release];
    return [NSURL URLWithString:rechargeWebSite];
}

@end
