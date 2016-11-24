//
//  CustomResultParser.m
//  TicketProject
//
//  Created by KAI on 14-7-8.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "CustomResultParser.h"
#import "NSDictionary+custom.h"
#import "Globals.h"

@implementation CustomResultParser

+ (NSString *)parseResult:(id)_result toHomeInfoDict:(NSMutableDictionary *)_infoDict explanationDict:(NSMutableDictionary *)_explanationDict tag:(NSInteger)_tag {
    NSDictionary *resultDictonary = (NSDictionary *)_result;
    NSString *serverTimeStr = [resultDictonary stringForKey:@"serverTime"] != nil ? [resultDictonary stringForKey:@"serverTime"] : @"";
    
    return serverTimeStr;
}

+ (void)parseResult:(id)_result toUserInfoDict:(NSMutableDictionary *)_infoDict {
    NSDictionary *resultDictonary = (NSDictionary *)_result;
    
    NSString *balance = [resultDictonary stringForKey:@"balance"];
    NSString *email = [resultDictonary stringForKey:@"email"];
    NSString *freeze = [resultDictonary stringForKey:@"freeze"];
    NSString *idcardnumber = [resultDictonary stringForKey:@"idcardnumber"];
    NSString *mobile = [resultDictonary stringForKey:@"mobile"];
    NSString *name = [resultDictonary stringForKey:@"name"];
    NSString *realityName = [resultDictonary stringForKey:@"realityName"];
    NSString *scoring = [resultDictonary stringForKey:@"scoring"];
    NSString *serverTime = [resultDictonary stringForKey:@"serverTime"];
    NSString *uid = [resultDictonary stringForKey:@"uid"];
    NSString *handselAmount = [resultDictonary stringForKey:@"handselAmount"];
    
    if (uid.length > 0) {
        [_infoDict setObject:balance == nil ? @"" : balance forKey:@"balance"];
        [_infoDict setObject:email == nil ? @"" : email forKey:@"email"];
        [_infoDict setObject:freeze == nil ? @"" : freeze forKey:@"freeze"];
        [_infoDict setObject:idcardnumber == nil ? @"" : idcardnumber forKey:@"idcardnumber"];
        [_infoDict setObject:mobile == nil ? @"" : mobile forKey:@"mobile"];
        [_infoDict setObject:name == nil ? @"" : name forKey:@"name"];
        [_infoDict setObject:realityName == nil ? @"" : realityName forKey:@"realityName"];
        [_infoDict setObject:scoring == nil ? @"" : scoring forKey:@"scoring"];
        [_infoDict setObject:serverTime == nil ? @"" : serverTime forKey:@"serverTime"];
        [_infoDict setObject:uid == nil ? @"" : uid forKey:@"uid"];
        [_infoDict setObject:handselAmount == nil ? @"" : handselAmount forKey:@"handselAmount"];
    }
}

//订单数据
+ (NSInteger)parseResult:(id)_result withNormalOrderArray:(NSMutableArray *)_normalOrderArray timeInt:(NSInteger)timeInt {
    NSInteger count = 0;
    NSArray * resultArray = (NSArray *)_result;
    
    void (^setOrderStatus)(NSString *, NSInteger, NSString *, NSInteger, NSString *, NSString *, NSMutableDictionary *) = ^(NSString *buyed, NSInteger quashStatus, NSString *isOpened, NSInteger surplusShare, NSString *winMoneyNoWithTax, NSString *schemeStatus ,NSMutableDictionary *dict) {
        NSString *statusStr = nil;
        if(quashStatus == 0) {
            if([isOpened isEqualToString:@"True"]) {
                if ([buyed isEqualToString:@"True"]) {
                    if([winMoneyNoWithTax floatValue] > 0) {
                        
                        statusStr = [NSString stringWithFormat:@"中奖%.2f元",[winMoneyNoWithTax floatValue]];
                    }
                }
                
            }
        }
        
        [dict setObject:statusStr == nil ? (schemeStatus == nil ? @"" : schemeStatus) : statusStr forKey:@"orderMainStatus"];
        [dict setObject:schemeStatus == nil ? @"" : schemeStatus forKey:@"orderStatus"];
    };
    
    void (^setOrderType)(NSInteger, NSString *, NSMutableDictionary *) = ^(NSInteger isChase,NSString *isPurchasing, NSMutableDictionary *dict) {
        
        NSString *orderTypeStr = nil;
        // 订单类型 -1：充值 0: 无  1：普通代购订单 2：合买订单 3：追号订单
        NSInteger orderType = 0;
        NSLog(@"%@",dict[@"isCopy"]);
        if ([isPurchasing isEqualToString:@"True"]) {
            if (isChase == 1) {
                orderTypeStr = @"追号订单";
                orderType = 3;
            } else if (isChase == 0) {
                if ([dict[@"isCopy"] isEqualToString:@"True"]) {
                    orderTypeStr = @"复制订单";
                }else{
                    orderTypeStr = @"普通订单";
                }
                    orderType = 1;
        
            } else {
                orderTypeStr = @"";
                orderType = 0;
            }
        } else {
            orderTypeStr = @"合买订单";
            orderType = 2;
        }
        [dict setObject:orderTypeStr == nil ? @"" : orderTypeStr forKey:@"orderTypeStr"];
        [dict setObject:[NSNumber numberWithInteger:orderType] forKey:@"orderType"];
    };
    
    void (^parseNormalOrderDict)(NSDictionary *, NSMutableArray *) = ^(NSDictionary *resuleDateDetailDict, NSMutableArray *normalDateDetailArray) {
        
        NSString *lotteryName = [[resuleDateDetailDict stringForKey:@"lotteryName"] copy];//彩种名
        NSInteger lotteryID = [resuleDateDetailDict intValueForKey:@"lotteryID"]; //彩种id
        NSString *issueName = nil; //期号名 (接口太多人做的，普通的接口期号字段是isuseName，合买是issuseName，追号是issueName  砸死那些王八蛋)
        if([resuleDateDetailDict stringForKey:@"isuseName"]) {
            issueName = [[resuleDateDetailDict stringForKey:@"isuseName"] copy];
            
        } else if ([resuleDateDetailDict stringForKey:@"issuseName"]) {
            issueName = [[resuleDateDetailDict stringForKey:@"issuseName"] copy];
            
        } else if ([resuleDateDetailDict stringForKey:@"issueName"]) {
            issueName = [[resuleDateDetailDict stringForKey:@"issueName"] copy];
            
        }
        NSString *money = [[resuleDateDetailDict stringForKey:@"money"] copy]; //订单金额
        NSString *detailMoney = [[resuleDateDetailDict stringForKey:@"detailMoney"] copy];      // 消费金额
        NSString *handselMoney = [[resuleDateDetailDict stringForKey:@"handselMoney"] copy];    // 消费彩金
        NSString *isHide = [[resuleDateDetailDict stringForKey:@"isHide"] copy];    // 合买是否可见
        NSString *secretMsg = [[resuleDateDetailDict stringForKey:@"secretMsg"] copy];    // 合买方案是否可见状态
        
        /*********判断部分**********/
        NSString *buyed = [[resuleDateDetailDict stringForKey:@"buyed"] copy]; //是否出票
        NSInteger isChase = [resuleDateDetailDict intValueForKey:@"isChase"];//是否时追号
        NSString *isPurchasing = [[resuleDateDetailDict stringForKey:@"isPurchasing"] copy];//是否非合买
        NSInteger quashStatus = [resuleDateDetailDict intValueForKey:@"quashStatus"]; //订单状态，0为正常，其他为撤单状态
        NSString *schemeIsOpened = [[resuleDateDetailDict stringForKey:@"schemeIsOpened"] copy];//是否开奖
        NSString *schemeStatus = [[resuleDateDetailDict stringForKey:@"schemeStatus"] copy];
        /*******************/
        NSString *winMoneyNoWithTax = [[resuleDateDetailDict stringForKey:@"winMoneyNoWithTax"] copy];//中奖金额
        NSString *winNumber = [[resuleDateDetailDict stringForKey:@"winNumber"] copy];//开奖号码
        NSInteger multiple = [resuleDateDetailDict intValueForKey:@"multiple"]; //订单倍数
        NSArray *buyContent = [resuleDateDetailDict objectForKey:@"buyContent"]; //购买号码数组
        NSString *datetime = [[resuleDateDetailDict stringForKey:@"datetime"] copy]; //下单时间
        NSString *schemeNumber = [[resuleDateDetailDict stringForKey:@"schemeNumber"] copy];//订单编号
        
        // 账户明细
        NSString *description = [[resuleDateDetailDict stringForKey:@"description"] copy];  // 描述
        NSString *orderTime = [[resuleDateDetailDict stringForKey:@"orderTime"] copy];      // 时间(格式：yyyy-MM-dd hh:mm:ss)
        NSString *oType = [[resuleDateDetailDict stringForKey:@"oType"] copy];              // 订单类型
        NSString *type = [[resuleDateDetailDict stringForKey:@"type"] copy];                // 类型 1：投注 2：中奖 3：充值 4：提款
        NSString *isCopy = [[resuleDateDetailDict stringForKey:@"isCopy"] copy];
        if (isCopy == nil) {
            isCopy = [[resuleDateDetailDict stringForKey:@"IsCopy"] copy];
        }
        NSLog(@"%@",isCopy);
        
        NSString *isPreBet = [[resuleDateDetailDict stringForKey:@"isPreBet"] copy];
        NSString *initiateName = [[resuleDateDetailDict stringForKey:@"initiateName"] copy];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        /*******************/
        [dict setObject:buyed == nil ? @"" : buyed forKey:@"buyed"];
        [buyed release];
        [dict setObject:[NSNumber numberWithInteger:isChase] forKey:@"isChase"];
        [dict setObject:isPurchasing == nil ? @"" : isPurchasing forKey:@"isPurchasing"];
        [isPurchasing release];
        [dict setObject:[NSNumber numberWithInteger:quashStatus] forKey:@"quashStatus"];
        [dict setObject:schemeIsOpened == nil ? @"" : schemeIsOpened forKey:@"isOpened"];//schemeIsOpened - >
        [schemeIsOpened release];
        /*******************/
        
        NSInteger ID = [resuleDateDetailDict intValueForKey:@"id"];
        [dict setObject:[NSNumber numberWithInteger:ID] forKey:@"ID"];
        [dict setObject:lotteryName == nil ? @"" : lotteryName forKey:@"lotteryName"];
        [lotteryName release];
        [dict setObject:[NSNumber numberWithInteger:lotteryID] forKey:@"lotteryID"];
        [dict setObject:issueName == nil ? @"" : issueName forKey:@"issueName"];
        [issueName release];
        [dict setObject:isHide == nil ? @"" : isHide forKey:@"isHide"];
        [isHide release];
        [dict setObject:secretMsg == nil ? @"" : secretMsg forKey:@"secretMsg"];
        [secretMsg release];
        [dict setObject:money == nil ? @"" : money forKey:@"money"];
        [money release];
        [dict setObject:detailMoney == nil ? @"" : detailMoney forKey:@"detailMoney"];
        [detailMoney release];
        [dict setObject:handselMoney == nil ? @"" : handselMoney forKey:@"handselMoney"];
        [handselMoney release];
        [dict setObject:winMoneyNoWithTax == nil ? @"" : winMoneyNoWithTax forKey:@"winMoneyNoWithTax"];
        [winMoneyNoWithTax release];
        [dict setObject:winNumber == nil ? @"" : winNumber forKey:@"winNumber"];
        [winNumber release];
        [dict setObject:[NSNumber numberWithInteger:multiple] forKey:@"multiple"];
        [dict setObject:schemeStatus == nil ? @"" : schemeStatus forKey:@"schemeStatus"];
        [schemeStatus release];
        
        [dict setObject:orderTime == nil ? @"" : orderTime forKey:@"orderTime"];
        [orderTime release];
        [dict setObject:description == nil ? @"" : description forKey:@"description"];
        [description release];
        [dict setObject:oType == nil ? @"" : oType forKey:@"oType"];
        [oType release];
        [dict setObject:type == nil ? @"" : type forKey:@"type"];
        [type release];
        [dict setObject:isCopy == nil ? @"" : isCopy forKey:@"isCopy"];
        [isCopy release];
        [dict setObject:initiateName forKey:@"initiateName"];
        [initiateName release];
        
        NSMutableArray *buyContentArray = [[NSMutableArray alloc] init];
        [self parseBuyContent:buyContent buyContentArray:buyContentArray];
        [dict setObject:buyContentArray forKey:@"buyContent"];
        [buyContentArray release];
        [dict setObject:datetime == nil ? @"" : datetime forKey:@"datetime"];
        [datetime release];
        [dict setObject:schemeNumber == nil ? @"" : schemeNumber forKey:@"schemeNumber"];
        [schemeNumber release];
        [dict setObject:isPreBet == nil ? @"" : isPreBet forKey:@"isPreBet"];
        setOrderType(isChase, isPurchasing, dict);
        
        
        NSInteger surplusShare = [resuleDateDetailDict intValueForKey:@"surplusShare"];//方案拆分(合买)
        setOrderStatus(buyed, quashStatus, schemeIsOpened, surplusShare, winMoneyNoWithTax, schemeStatus, dict);
        
        if(![isPurchasing isEqualToString:@"True"]) {
            
            NSString *initiateName = [[resuleDateDetailDict stringForKey:@"initiateName"] copy];//发起人(合买)
            NSString *schemeBonusScale = [[resuleDateDetailDict stringForKey:@"schemeBonusScale"] copy];//佣金比率(合买)
            NSInteger share = [resuleDateDetailDict intValueForKey:@"share"];//方案拆分份数(合买)
            NSString *shareMoney = [[resuleDateDetailDict stringForKey:@"shareMoney"] copy];//方案拆分总金额(合买)
            
            NSString *myBuyMoney = [[resuleDateDetailDict stringForKey:@"myBuyMoney"] copy]; //我购买的金额(合买)
            NSInteger myBuyShare = [resuleDateDetailDict intValueForKey:@"myBuyShare"]; //我购买的份数(合买)
            NSString *title = [[resuleDateDetailDict stringForKey:@"title"] copy];//标题(合买)
            NSString *description = [[resuleDateDetailDict stringForKey:@"description"] copy]; //方案描述（合买）
            NSString *detailMoney = [[resuleDateDetailDict stringForKey:@"detailMoney"] copy];
            NSString *handselMoney = [[resuleDateDetailDict stringForKey:@"handselMoney"] copy];
            
            [dict setObject:initiateName == nil ? @"" : initiateName forKey:@"initiateName"];
            [initiateName release];
            [dict setObject:schemeBonusScale == nil ? @"" : schemeBonusScale forKey:@"schemeBonusScale"];
            [schemeBonusScale release];
            [dict setObject:[NSNumber numberWithInteger:share] forKey:@"share"];
            [dict setObject:shareMoney == nil ? @"" : shareMoney forKey:@"shareMoney"];
            [shareMoney release];
            [dict setObject:[NSNumber numberWithInteger:surplusShare] forKey:@"surplusShare"];
            [dict setObject:myBuyMoney == nil ? @"" : myBuyMoney forKey:@"myBuyMoney"];
            [myBuyMoney release];
            [dict setObject:[NSNumber numberWithInteger:myBuyShare] forKey:@"myBuyShare"];
            [dict setObject:title == nil ? @"" : title forKey:@"title"];
            [title release];
            [dict setObject:description == nil ? @"" : description forKey:@"description"];
            [description release];
            [dict setObject:detailMoney == nil ? @"" : detailMoney forKey:@"detailMoney"];
            [detailMoney release];
            [dict setObject:handselMoney == nil ? @"" : handselMoney forKey:@"handselMoney"];
            [handselMoney release];
        } else if (isChase != 0) {
            NSInteger chaseTaskID = [resuleDateDetailDict intValueForKey:@"chaseTaskID"];
            [dict setObject:[NSNumber numberWithInteger:chaseTaskID] forKey:@"chaseTaskID"];
        }
        
        [normalDateDetailArray addObject:dict];
        [dict release];
    };
    
    if (resultArray && [resultArray isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *resultDateDict in resultArray) {
            if (resultDateDict && [resultDateDict isKindOfClass:[NSDictionary class]]) {
                
                NSString *dateStr = [resultDateDict stringForKey:@"date"];
                NSArray  *dateDetailArray = [resultDateDict objectForKey:@"dateDetail"];

                NSInteger dataTimeInt = [Globals timeConvertToIndegerWithStringWithStringTime:dateStr beforeMonth:0];
                NSLog(@"%ld----%ld",(long)dataTimeInt,(long)timeInt);
                if(dataTimeInt <= timeInt) { //早于传入的日期的数据直接过滤
                    continue;
                }
                
                //获取客户端原有的数据订单某日期的字典
                NSMutableDictionary *normalDateDict = nil;
                for (NSMutableDictionary *normalDict in _normalOrderArray) {
                    if (normalDict && [normalDict isKindOfClass:[NSMutableDictionary class]]) {
                        
                        NSString *normalDateStr = [normalDict stringForKey:@"date"];
                        
                        if ([normalDateStr isEqualToString:dateStr]) {
                            normalDateDict = normalDict;
                            break;
                        }
                    }
                }
                
                //该日期的字典没有则自己重新创建某日期的字典
                if (!normalDateDict) {
                    normalDateDict = [[NSMutableDictionary alloc] init];
                    [_normalOrderArray addObject:normalDateDict];
                    [normalDateDict release];
                    
                    [normalDateDict setObject:dateStr == nil ? @"" : dateStr forKey:@"date"];
                }
                
                //获取某日期内的订单数组
                NSMutableArray *normalDateDetailArray = [normalDateDict objectForKey:@"dateDetail"];
                
                //如果没有该订单数组，则创建并传入
                if (!normalDateDetailArray) {
                    normalDateDetailArray = [[NSMutableArray alloc] init];
                    [normalDateDict setObject:normalDateDetailArray forKey:@"dateDetail"];
                    [normalDateDetailArray release];
                }
                
                for (NSDictionary *resuleDateDetailDict in dateDetailArray) {
                    if (resuleDateDetailDict && [resuleDateDetailDict isKindOfClass:[NSDictionary class]]) {
                        
                        parseNormalOrderDict(resuleDateDetailDict,normalDateDetailArray);
                        count++;
                    }
                }
            }
        }
    }
    return count;
}

+ (NSInteger)parseResult:(id)_result withChaseOrderArray:(NSMutableArray *)_chaseArray timeInt:(NSInteger)timeInt {
    NSInteger count = 0;
    NSArray * resultArray = (NSArray *)_result;
    
    void (^setOrderStatus)(NSInteger, NSString *, NSString *, NSString *, NSMutableDictionary *) = ^(NSInteger quashStatus, NSString *isOpened, NSString *winMoneyNoWithTax, NSString *schemeStatus,NSMutableDictionary *dict) {
        NSString *statusStr = nil;
        if([isOpened isEqualToString:@"True"]) {
            if ([winMoneyNoWithTax floatValue] > 0) {
                statusStr = [NSString stringWithFormat:@"中奖%.2f元",[winMoneyNoWithTax floatValue]];
            }
        }
        
        [dict setObject:statusStr == nil ? (schemeStatus == nil ? @"" : schemeStatus) : statusStr forKey:@"orderMainStatus"];
        [dict setObject:schemeStatus == nil ? @"" : schemeStatus forKey:@"orderStatus"];
    };
    
    void (^parseChaseOrderDict)(NSDictionary *, NSMutableArray *) = ^(NSDictionary *resuleDateDetailDict, NSMutableArray *chaseDateDetailArray) {
        NSString *chaseDateTime = [[resuleDateDetailDict stringForKey:@"chaseDateTime"] copy];
        NSInteger ID = [resuleDateDetailDict intValueForKey:@"id"];
        NSInteger lotteryID = [resuleDateDetailDict intValueForKey:@"lotteryID"];
        NSString *lotteryName = [[resuleDateDetailDict stringForKey:@"lotteryName"] copy];
        NSInteger quashStatus = [resuleDateDetailDict intValueForKey:@"quashStatus"];
        NSString *stopWhenWinMoney = [[resuleDateDetailDict stringForKey:@"stopWhenWinMoney"] copy];
        NSInteger sumChaseCount = [resuleDateDetailDict intValueForKey:@"sumChaseCount"];
        NSString *sumChaseMoney = [[resuleDateDetailDict stringForKey:@"sumChaseMoney"] copy];
        NSString *sumSchemeMoney = [[resuleDateDetailDict stringForKey:@"sumSchemeMoney"] copy];//总金额
        NSInteger userID = [resuleDateDetailDict intValueForKey:@"userID"];
        NSString *userName = [[resuleDateDetailDict stringForKey:@"userName"] copy];
        NSString *winMoneyNoWithTax = [[resuleDateDetailDict stringForKey:@"winMoneyNoWithTax"] copy];
        NSArray  *buyContent = [resuleDateDetailDict objectForKey:@"buyContent"];
        NSString *isOpened = [[resuleDateDetailDict stringForKey:@"isOpened"] copy];
        NSString *schemeStatus = [[resuleDateDetailDict stringForKey:@"schemeStatus"] copy];
        NSString *detailMoney = [[resuleDateDetailDict stringForKey:@"detailMoney"] copy];
        NSString *handselMoney = [[resuleDateDetailDict stringForKey:@"handselMoney"] copy];
        NSString *initiateName = [[resuleDateDetailDict stringForKey:@"initiateName"] copy];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:chaseDateTime == nil ? @"" : chaseDateTime forKey:@"chaseDateTime"];
        [chaseDateTime release];
        [dict setObject:[NSNumber numberWithInteger:ID] forKey:@"ID"];
        [dict setObject:[NSNumber numberWithInteger:lotteryID] forKey:@"lotteryID"];
        [dict setObject:lotteryName == nil ? @"" : lotteryName forKey:@"lotteryName"];
        [lotteryName release];
        [dict setObject:[NSNumber numberWithInteger:quashStatus] forKey:@"quashStatus"];
        [dict setObject:stopWhenWinMoney == nil ? @"" : stopWhenWinMoney forKey:@"stopWhenWinMoney"];
        [stopWhenWinMoney release];
        [dict setObject:[NSNumber numberWithInteger:sumChaseCount] forKey:@"sumChaseCount"];
        [dict setObject:sumChaseMoney == nil ? @"" : sumChaseMoney forKey:@"sumChaseMoney"];
        [sumChaseMoney release];
        [dict setObject:sumSchemeMoney == nil ? @"" : sumSchemeMoney forKey:@"money"];//将sumSchemeMoney－>money
        [sumSchemeMoney release];
        [dict setObject:[NSNumber numberWithInteger:userID] forKey:@"userID"];
        [dict setObject:userName == nil ? @"" : userName forKey:@"userName"];
        [userName release];
        [dict setObject:winMoneyNoWithTax == nil ? @"" : winMoneyNoWithTax forKey:@"winMoneyNoWithTax"];
        [winMoneyNoWithTax release];
        [dict setObject:schemeStatus == nil ? @"" : schemeStatus forKey:@"schemeStatus"];
        [schemeStatus release];
        [dict setObject:detailMoney == nil ? @"" : detailMoney forKey:@"detailMoney"];
        [detailMoney release];
        [dict setObject:handselMoney == nil ? @"" : handselMoney forKey:@"handselMoney"];
        [handselMoney release];
        
        NSMutableArray *buyContentArray = [[NSMutableArray alloc] init];
        [self parseBuyContent:buyContent buyContentArray:buyContentArray];
        [dict setObject:buyContentArray forKey:@"buyContent"];
        [buyContentArray release];
        
        [dict setObject:isOpened == nil ? @"" : isOpened forKey:@"isOpened"];
        [isOpened release];
        
        [dict setObject:@"追号订单" forKey:@"orderTypeStr"];
        [dict setObject:[NSNumber numberWithInteger:3] forKey:@"orderType"];
        [dict setObject:initiateName forKey:@"initiateName"];
        [initiateName release];
        
        setOrderStatus(quashStatus, isOpened, winMoneyNoWithTax, schemeStatus, dict);
        
        [chaseDateDetailArray addObject:dict];
        [dict release];
    };
    
    if (resultArray && [resultArray isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *resultDateDict in resultArray) {
            
            if (resultDateDict && [resultDateDict isKindOfClass:[NSDictionary class]]) {
                
                NSString *dateStr = [resultDateDict stringForKey:@"date"];
                NSArray  *dateDetailArray = [resultDateDict objectForKey:@"chaseTaskDetail"];
                NSString *sumChase = [resultDateDict stringForKey:@"sumChase"];
                
                NSInteger dataTimeInt = [Globals timeConvertToIndegerWithStringWithStringTime:dateStr beforeMonth:0];
                if(dataTimeInt <= timeInt) {
                    continue;
                }
                
                NSMutableDictionary *chaseDateDict = nil;
                for (NSMutableDictionary *chaseDict in _chaseArray) {
                    if (chaseDict && [chaseDict isKindOfClass:[NSMutableDictionary class]]) {
                        
                        NSString *chaseDateStr = [chaseDict stringForKey:@"date"];
                        
                        if ([chaseDateStr isEqualToString:dateStr]) {
                            chaseDateDict = chaseDict;
                            break;
                        }
                    }
                }
                
                if (!chaseDateDict) {
                    chaseDateDict = [NSMutableDictionary dictionary];
                    [_chaseArray addObject:chaseDateDict];
                    [chaseDateDict setObject:dateStr == nil ? @"" : dateStr forKey:@"date"];
                    [chaseDateDict setObject:sumChase == nil ? @"" : sumChase forKey:@"sumChase"];
                }
                
                NSMutableArray *chaseDateDetailArray = [chaseDateDict objectForKey:@"chaseTaskDetail"];
                
                if (!chaseDateDetailArray) {
                    chaseDateDetailArray = [NSMutableArray array];
                    [chaseDateDict setObject:chaseDateDetailArray forKey:@"chaseTaskDetail"];
                    
                }
                
                for (NSDictionary *resuleDateDetailDict in dateDetailArray) {
                    if (resuleDateDetailDict && [resuleDateDetailDict isKindOfClass:[NSDictionary class]]) {
                        
                        parseChaseOrderDict(resuleDateDetailDict,chaseDateDetailArray);
                        count ++;
                    }
                }
            }
        }
    }
    return count;
}

+ (void)parseResult:(id)_result withChaseOrdersDict:(NSMutableDictionary *)_chaseOrdersDict {
    NSDictionary * resultDict = (NSDictionary *)_result;
    
    void (^setOrderStatus)(NSString *, NSInteger, NSString *, NSString * ,NSString * , NSString * , NSMutableDictionary *) = ^(NSString *executed, NSInteger quashStatus, NSString *isOpened, NSString *winMoneyNoWithTax , NSString *buyed ,NSString *schemeStatus , NSMutableDictionary * dict) {
        NSString *statusStr = nil;
        if([isOpened isEqualToString:@"True"]) {
            if([winMoneyNoWithTax floatValue] > 0) {
                statusStr = [NSString stringWithFormat:@"中奖%.2f元",[winMoneyNoWithTax floatValue]];
            }
        }

        [dict setObject:statusStr == nil ? (schemeStatus == nil ? @"" : schemeStatus) : statusStr forKey:@"orderMainStatus"];
        [dict setObject:schemeStatus == nil ? @"" : schemeStatus forKey:@"orderStatus"];
    };
    
    
    
    void (^ parseChaseOrdersChildeDetailArray)(NSArray *, NSMutableArray *) = ^(NSArray *detail, NSMutableArray *parseDetailArray) {
        for(NSDictionary *dict in detail) {
            
            NSInteger chaseTaskID = [dict intValueForKey:@"chaseTaskID"];
            NSString *chaseTaskTime = [[dict stringForKey:@"chaseTaskTime"] copy];
            NSString *datetime = [[dict stringForKey:@"datetime"] copy];
            NSString *executed = [[dict stringForKey:@"executed"] copy];
            NSString *isOpened = [[dict stringForKey:@"isOpened"] copy];
            NSString *issueName = [[dict stringForKey:@"issueName"] copy];
            NSInteger isuseID  = [dict intValueForKey:@"isuseID"];
            NSInteger lotteryID = [dict intValueForKey:@"lotteryID"];
            NSString *lotteryName = [[dict stringForKey:@"lotteryName"] copy];
            NSString *money = [[dict stringForKey:@"money"] copy];
            NSInteger multiple = [dict intValueForKey:@"multiple"];
            NSInteger quashStatus = [dict intValueForKey:@"quashStatus"];
            NSString *schemeDateTime = [[dict stringForKey:@"schemeDateTime"] copy];
            NSInteger schemeID = [dict intValueForKey:@"schemeID"];
            NSString *schemeNumber = [[dict stringForKey:@"schemeNumber"] copy];
            NSString *stopWhenWinMoney = [[dict stringForKey:@"stopWhenWinMoney"] copy];
            NSString *winLotteryNumber = [[dict stringForKey:@"winLotteryNumber"] copy];
            NSString *winMoneyNoWithTax = [[dict stringForKey:@"winMoneyNoWithTax"] copy];
            NSString *buyed = [[dict stringForKey:@"buyed"] copy];  //是否出票
            NSString *schemeStatus = [[dict stringForKey:@"schemeStatus"] copy];
            NSString *isCopy = [[dict stringForKey:@"isCopy"] copy];
            NSArray *buyContent = [dict objectForKey:@"buyContent"];
            
            NSMutableDictionary *parseDetailDict = [[NSMutableDictionary alloc] init];
            [parseDetailDict setObject:[NSNumber numberWithInteger:chaseTaskID] forKey:@"chaseTaskID"];
            [parseDetailDict setObject:chaseTaskTime == nil ? @"" : chaseTaskTime forKey:@"chaseTaskTime"];
            [chaseTaskTime release];
            [parseDetailDict setObject:datetime == nil ? @"" : datetime forKey:@"datetime"];
            [datetime release];
            [parseDetailDict setObject:executed == nil ? @"" : executed forKey:@"executed"];
            [executed release];
            [parseDetailDict setObject:isOpened == nil ? @"" : isOpened forKey:@"isOpened"];
            [isOpened release];
            [parseDetailDict setObject:issueName == nil ? @"" : issueName forKey:@"issueName"];
            [issueName release];
            [parseDetailDict setObject:[NSNumber numberWithInteger:isuseID] forKey:@"isuseID"];
            [parseDetailDict setObject:[NSNumber numberWithInteger:lotteryID] forKey:@"lotteryID"];
            [parseDetailDict setObject:lotteryName == nil ? @"" : lotteryName forKey:@"lotteryName"];
            [lotteryName release];
            [parseDetailDict setObject:money == nil ? @"" : money forKey:@"money"];
            [money release];
            [parseDetailDict setObject:[NSNumber numberWithInteger:multiple] forKey:@"multiple"];
            [parseDetailDict setObject:[NSNumber numberWithInteger:quashStatus] forKey:@"quashStatus"];
            [parseDetailDict setObject:schemeDateTime == nil ? @"" : schemeDateTime forKey:@"schemeDateTime"];
            [schemeDateTime release];
            [parseDetailDict setObject:[NSNumber numberWithInteger:schemeID] forKey:@"schemeID"];
            [parseDetailDict setObject:schemeNumber == nil ? @"" : schemeNumber forKey:@"schemeNumber"];
            [schemeNumber release];
            [parseDetailDict setObject:stopWhenWinMoney == nil ? @"" : stopWhenWinMoney forKey:@"stopWhenWinMoney"];
            [stopWhenWinMoney release];
            [parseDetailDict setObject:winLotteryNumber == nil ? @"" : winLotteryNumber forKey:@"winNumber"];//winLotteryNumber -> winNumber
            [winLotteryNumber release];
            [parseDetailDict setObject:winMoneyNoWithTax == nil ? @"" : winMoneyNoWithTax forKey:@"winMoneyNoWithTax"];
            [winMoneyNoWithTax release];
            [parseDetailDict setObject:buyed == nil ? @"" : buyed forKey:@"buyed"];
            [buyed release];
            [parseDetailDict setObject:schemeStatus == nil ? @"" : schemeStatus forKey:@"schemeStatus"];
            [schemeStatus release];
            [parseDetailDict setObject:isCopy == nil ? @"0" : isCopy forKey:@"isCopy"];
            [isCopy release];
            
//            [parseDetailDict setObject:myCopy == nil ? @"" : myCopy forKey:@"schemeStatus"];
//            [schemeStatus release];
            setOrderStatus(executed, quashStatus, isOpened, winMoneyNoWithTax, buyed, schemeStatus, parseDetailDict);
        
            
            NSMutableArray *buyContentArray = [[NSMutableArray alloc] init];
            [self parseBuyContent:buyContent buyContentArray:buyContentArray];
            [parseDetailDict setObject:buyContentArray forKey:@"buyContent"];
            [buyContentArray release];
            
            
            [parseDetailArray addObject:parseDetailDict];
            [parseDetailDict release];
            
        }
    };
    
    void (^ parseChaseOrdersChildArray)(NSArray *, NSMutableArray *) = ^(NSArray *list, NSMutableArray *listParseArray) {
        if ([list isKindOfClass:[NSArray class]] && [list count] > 0) {
            for (NSDictionary *dict in list) {
                NSString *date = [[dict stringForKey:@"date"] copy];
                NSArray *detail = [dict objectForKey:@"detail"];
                
                NSMutableDictionary *parseDict = [[NSMutableDictionary alloc] init];
                [parseDict setObject:date == nil ? @"" : date forKey:@"date"];
                [date release];
                
                NSMutableArray *parseDetailArray = [[NSMutableArray alloc] init];
                parseChaseOrdersChildeDetailArray(detail, parseDetailArray);
                [parseDict setObject:parseDetailArray forKey:@"detail"];
                [parseDetailArray release];
                
                [listParseArray addObject:parseDict];
                [parseDict release];
            }
        }
    };
    
    void (^ parseChaseOrdersArray)(NSArray *, NSMutableArray *) = ^(NSArray *resultArray, NSMutableArray *parseArray) {
        
        if ([resultArray isKindOfClass:[NSArray class]] && [resultArray count] > 0) {
            NSDictionary *dict = [resultArray objectAtIndex:0];
            
            NSInteger count = [dict intValueForKey:@"count"];
            NSArray *list = [dict objectForKey:@"list"];
            
            NSMutableDictionary *parseDict = [[NSMutableDictionary alloc] init];
            
            [parseDict setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
            
            NSMutableArray *listParseArray = [[NSMutableArray alloc] init];
            parseChaseOrdersChildArray(list, listParseArray);
            [parseDict setObject:listParseArray forKey:@"list"];
            [listParseArray release];
            
            [parseArray addObject:parseDict];
            [parseDict release];
        }
    };
    
    NSInteger error = [resultDict intValueForKey:@"error"];
    NSString *msg = [[resultDict stringForKey:@"msg"] copy];
    NSInteger msgCount = [resultDict intValueForKey:@"msgCount"];
    NSInteger msgCountAll = [resultDict intValueForKey:@"msgCountAll"];
    NSString *serverTime = [[resultDict stringForKey:@"serverTime"] copy];
    NSInteger sumCompletedCount = [resultDict intValueForKey:@"sumCompletedCount"];
    NSInteger sumUnCompletedCount = [resultDict intValueForKey:@"sumUnCompletedCount"];
    
    [_chaseOrdersDict setObject:[NSNumber numberWithInteger:error] forKey:@"error"];
    [_chaseOrdersDict setObject:msg == nil ? @"" : msg forKey:@"msg"];
    [msg release];
    [_chaseOrdersDict setObject:[NSNumber numberWithInteger:msgCount] forKey:@"msgCount"];
    [_chaseOrdersDict setObject:[NSNumber numberWithInteger:msgCountAll] forKey:@"msgCountAll"];
    [_chaseOrdersDict setObject:serverTime == nil ? @"" : serverTime forKey:@"serverTime"];
    [serverTime release];
    [_chaseOrdersDict setObject:[NSNumber numberWithInteger:sumCompletedCount] forKey:@"sumCompletedCount"];
    [_chaseOrdersDict setObject:[NSNumber numberWithInteger:sumUnCompletedCount] forKey:@"sumUnCompletedCount"];
    
    
    
    NSDictionary *chaseTaskDetailsList = [resultDict objectForKey:@"chaseTaskDetailsList"];
    
    
    NSArray *completedResultArray = [chaseTaskDetailsList objectForKey:@"completed"];
    NSArray *unCompletedResultArray = [chaseTaskDetailsList objectForKey:@"unCompleted"];
    
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *completedArray = [[NSMutableArray alloc] init];
    parseChaseOrdersArray(completedResultArray, completedArray);
    [dict setObject:completedArray forKey:@"completed"];
    [completedArray release];
    
    NSMutableArray *unCompletedArray = [[NSMutableArray alloc] init];
    parseChaseOrdersArray(unCompletedResultArray, unCompletedArray);
    [dict setObject:unCompletedArray forKey:@"unCompleted"];
    [unCompletedArray release];
    
    [_chaseOrdersDict setObject:dict forKey:@"chaseTaskDetailsList"];
    [dict release];
}

+ (void)parseBuyContent:(NSArray *)buyContent buyContentArray:(NSMutableArray *)buyContentArray {
    if ([buyContent count] > 0) {
        for (NSArray *buyContentChildArray in buyContent) {
            NSMutableArray *buyContentArrayChildArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in buyContentChildArray) {
                if (![dict isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSString *lotteryNumber = [[dict stringForKey:@"lotteryNumber"] copy];
                NSInteger playType = [dict intValueForKey:@"playType"];
                CGFloat   sumMoney = [dict floatValueForKey:@"sumMoney"];
                NSInteger sumNum = [dict intValueForKey:@"sumNum"];
                
                NSMutableDictionary *buyContentDict = [[NSMutableDictionary alloc] init];
                [buyContentDict setObject:lotteryNumber == nil ? @"" : lotteryNumber forKey:@"lotteryNumber"];
                [lotteryNumber release];
                [buyContentDict setObject:[NSNumber numberWithInteger:playType] forKey:@"playType"];
                [buyContentDict setObject:[NSNumber numberWithFloat:sumMoney] forKey:@"sumMoney"];
                [buyContentDict setObject:[NSNumber numberWithInteger:sumNum] forKey:@"sumNum"];
                [buyContentArrayChildArray addObject:buyContentDict];
                [buyContentDict release];
            }
            
            [buyContentArray addObject:buyContentArrayChildArray];
            [buyContentArrayChildArray release];
        }
        
    }
}

+ (NSInteger)lastCalculateNumberParseResultArray:(NSArray *)resultArray integralDetailArray:(NSMutableArray *)integralDetailArray calculateNumber:(NSInteger)calculateNumber {
    
    NSString * (^ getoperatorTypeString)(NSInteger) = ^(NSInteger operatorType){
        NSString *typeName = @"";
        switch (operatorType) {
            case 1:
                typeName = @"购彩赠送积分";
                break;
            case 2:
                typeName = @"下级购彩赠送积分";
                break;
            case 3:
                typeName = @"系统赠送积分";
                break;
            case 4:
                typeName = @"手工赠加积分";
                break;
            case 101:
                typeName = @"兑换积分";
                break;
            case 201:
                typeName = @"惩罚扣积分";
                break;
                default:
                typeName = @"购彩赠送积分";
                break;
        }
        return typeName;
    };
    
    NSInteger currentCalculateNumber = calculateNumber;
    for (NSDictionary *integralDetailDict in resultArray) {
        if (integralDetailDict && [integralDetailDict isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            NSString *datetime = [integralDetailDict stringForKey:@"dateTime"];
            NSInteger operatorType = [integralDetailDict intValueForKey:@"operatorType"];
            NSInteger scoring = [integralDetailDict intValueForKey:@"scoring"];
            
            if (datetime.length > 15) {
                NSArray *arr = [datetime componentsSeparatedByString:@" "];
                NSString *date = [arr objectAtIndex:0];
                NSString *time = [arr objectAtIndex:1];
                [dict setObject:date == nil ? @"" : date forKey:@"date"];
                [dict setObject:time == nil ? @"" : time forKey:@"time"];
            }
            if (operatorType == 101 || operatorType == 201) {
                scoring = -scoring;
            }
            
            [dict setObject:getoperatorTypeString(operatorType) forKey:@"operatorType"];
            [dict setObject:[NSNumber numberWithInteger:scoring] forKey:@"scoring"];
            [dict setObject:[NSNumber numberWithInteger:currentCalculateNumber] forKey:@"totalScoring"];
            currentCalculateNumber -= scoring;
            [integralDetailArray addObject:dict];
            [dict release];
        }
    }
    return currentCalculateNumber;
}

@end
