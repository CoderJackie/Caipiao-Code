//
//  Activity.m
//  TicketProject
//
//  Created by KAI on 15-3-10.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "Activity.h"

@implementation Activity

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Activity *copyActivity = [[[self class] allocWithZone:zone] init];
    return copyActivity;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
}

@end

@implementation LotteryActivity
@synthesize lotteryNumber = _lotteryNumber;
@synthesize playType = _playType;
@synthesize sumMoney = _sumMoney;
@synthesize sumNum = _sumNum;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _lotteryNumber = [[[aDecoder decodeObjectForKey:@"lotteryNumber"] description] copy];
        _playType = [[aDecoder decodeObjectForKey:@"playType"] integerValue];
        _sumMoney = [[aDecoder decodeObjectForKey:@"sumMoney"] floatValue];
        _sumNum   = [[aDecoder decodeObjectForKey:@"sumNum"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_lotteryNumber == nil ? @"" :_lotteryNumber forKey:@"lotteryNumber"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_playType] forKey:@"playType"];
    [aCoder encodeObject:[NSNumber numberWithFloat:_sumMoney] forKey:@"sumMoney"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_sumNum] forKey:@"sumNum"];
}

- (id)copyWithZone:(NSZone *)zone {
    LotteryActivity *copyActivity = [[[self class] allocWithZone:zone] init];
    copyActivity.lotteryNumber = _lotteryNumber;
    copyActivity.playType = _playType;
    copyActivity.sumMoney = _sumMoney;
    copyActivity.sumNum = _sumNum;
    return copyActivity;
}

- (void)setLotteryNumber:(NSString *)lotteryNumber {
    if (![_lotteryNumber isEqualToString:lotteryNumber]) {
        _lotteryNumber = [lotteryNumber copy];
    }
}

- (NSString *)getLotteryNumber {
    if (!_lotteryNumber) {
        return @"";
    }
    return _lotteryNumber;
}

- (void)dealloc {
    [super dealloc];
}

@end


@implementation TicketInformationActivity
@synthesize dateTime = _dateTime;
@synthesize informationId = _informationId;
@synthesize title = _title;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_dateTime release];
    _dateTime = nil;
    [_title release];
    _title = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _dateTime = [[[aDecoder decodeObjectForKey:@"dateTime"] description] copy];
        _informationId = [[aDecoder decodeObjectForKey:@"informationId"] integerValue];
        _title = [[[aDecoder decodeObjectForKey:@"title"] description] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_dateTime == nil ? @"" : _dateTime forKey:@"dateTime"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_informationId] forKey:@"informationId"];
    [aCoder encodeObject:_title == nil ? @"" : _title forKey:@"title"];
}

- (id)copyWithZone:(NSZone *)zone {
    TicketInformationActivity *copyActivity = [[[self class] allocWithZone:zone] init];
    copyActivity.dateTime = _dateTime;
    copyActivity.informationId = _informationId;
    copyActivity.title = _title;
    return copyActivity;
}



@end

@implementation IntegralActivity

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_yearDate release];
    _yearDate = nil;
    [_hourDate release];
    _hourDate = nil;
    [_integral release];
    _integral = nil;
    [_integralType release];
    _integralType = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _yearDate = [[[aDecoder decodeObjectForKey:@"yearDate"] description] copy];
        _hourDate = [[[aDecoder decodeObjectForKey:@"hourDate"] description] copy];
        _integral = [[[aDecoder decodeObjectForKey:@"integral"] description] copy];
        _integralType = [[[aDecoder decodeObjectForKey:@"integralType"] description] copy];
        _totalIntegral = [[aDecoder decodeObjectForKey:@"totalIntegral"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_yearDate == nil ? @"" : _yearDate forKey:@"yearDate"];
    [aCoder encodeObject:_hourDate == nil ? @"" : _hourDate forKey:@"hourDate"];
    [aCoder encodeObject:_integral == nil ? @"" : _integral forKey:@"integral"];
    [aCoder encodeObject:_integralType == nil ? @"" : _integralType forKey:@"integralType"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_totalIntegral] forKey:@"totalIntegral"];
}

- (id)copyWithZone:(NSZone *)zone {
    IntegralActivity *copyActivity = [[[self class] allocWithZone:zone] init];
    copyActivity.yearDate = _yearDate;
    copyActivity.hourDate = _hourDate;
    copyActivity.integral = _integral;
    copyActivity.integralType = _integralType;
    copyActivity.totalIntegral = _totalIntegral;
    return copyActivity;
}

@end
