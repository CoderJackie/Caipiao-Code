//
//  AwardInfo.m
//  TicketProject
//
//  Created by sls002 on 13-6-3.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//获取对阵的奖期信息

#import "AwardInfo.h"
#import "InterfaceHelper.h"
#import "InterfaceHeader.h"

@implementation AwardInfo

//获取比赛对阵信息
- (NSArray *)getAwardInfoWithLotteryId:(NSInteger)myId {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)myId] forKey:@"lotteryId"];

    ASIFormDataRequest *httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:@"10" userId:@"-1" infoDict:infoDic]];
    [httpRequest startSynchronous];
    
    NSArray *matchArray = [NSArray array];
    if(![httpRequest error]) {
        NSDictionary *responseDic = [[httpRequest responseString]objectFromJSONString];
        NSArray *array = [responseDic objectForKey:@"isusesInfo"];
        matchArray = [[array objectAtIndex:0] objectForKey:@"dtMatch"];
    }
    [httpRequest release];
    return matchArray;
}

@end
