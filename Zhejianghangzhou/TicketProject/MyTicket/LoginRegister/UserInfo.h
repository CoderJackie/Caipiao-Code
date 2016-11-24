//
//  UserInfo.h
//  TicketProject
//
//  Created by sls002 on 13-6-14.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic,copy) NSString *userID;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *realName;
@property (nonatomic,copy) NSString *cardNumber;
@property (nonatomic,copy) NSString *phoneNumber;
@property (nonatomic,copy) NSString *balance;
@property (nonatomic,copy) NSString *handselAmount;  // 彩金
@property (nonatomic,copy) NSString *freeze;
@property (nonatomic,assign) NSInteger isOn;
@property (nonatomic,assign) NSInteger isShaking;
@property (nonatomic,assign) CGFloat rechargeMoney;

@property (nonatomic, assign) NSInteger surplusIntegral;
@property (nonatomic, assign) NSInteger totalIntegral;
@property (nonatomic, assign) NSInteger exchangeIntegral;
@property (nonatomic, assign) CGFloat scoringExchangerate;
@property (nonatomic, assign) NSInteger optScoringOfSelfBuy;

+(UserInfo *)shareUserInfo;

@end
