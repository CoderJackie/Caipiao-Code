//
//  Activity.h
//  TicketProject
//
//  Created by KAI on 15-3-10.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject <NSCopying, NSCoding> {
    
}

@end


@interface LotteryActivity : Activity {
    NSString *_lotteryNumber;
    NSInteger _playType;
    CGFloat   _sumMoney;
    NSInteger _sumNum;
}

@property (nonatomic, copy)   NSString *lotteryNumber;
@property (nonatomic, assign) NSInteger playType;
@property (nonatomic, assign) CGFloat   sumMoney;
@property (nonatomic, assign) NSInteger sumNum;




@end


@interface TicketInformationActivity : NSObject <NSCopying, NSCoding> {
    NSString    *_dateTime;
    NSInteger    _informationId;
    NSString    *_title;
}

@property (nonatomic, copy) NSString *dateTime;
@property (nonatomic, assign) NSInteger informationId;
@property (nonatomic, copy) NSString *title;


@end

@interface IntegralActivity : NSObject <NSCopying, NSCoding> {
    NSString    *_yearDate;
    NSString    *_hourDate;
    NSString    *_integral;
    NSString    *_integralType;
    NSInteger    _totalIntegral;
}

@property (nonatomic, copy) NSString *yearDate;
@property (nonatomic, copy) NSString *hourDate;
@property (nonatomic, copy) NSString *integral;
@property (nonatomic, copy) NSString *integralType;
@property (nonatomic, assign) NSInteger totalIntegral;

@end