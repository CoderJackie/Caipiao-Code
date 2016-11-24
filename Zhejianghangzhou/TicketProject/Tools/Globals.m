//
//  Globals.m
//  TicketProject
//
//  Created by KAI on 14-7-1.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "Globals.h"

@implementation Globals
@synthesize tabBarHidden = _tabBarHidden;
@synthesize isShake = _isShake;
@synthesize homeViewInfoDict = _homeViewInfoDict;

- (id)init {
    self = [super init];
    if (self) {
        if(_homeViewInfoDict) {
            [_homeViewInfoDict release];
            _homeViewInfoDict = nil;
        }
        _homeViewInfoDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_homeViewInfoDict release];
    _homeViewInfoDict = nil;
    
    [_registeRequestPhoneNumber release];
    _registeRequestPhoneNumber = nil;
    
    [_pushBaiDuAppId release];
    _pushBaiDuAppId = nil;
    [_pushBaiDuUserid release];
    _pushBaiDuUserid = nil;
    [_pushBaiDuChannelid release];
    _pushBaiDuChannelid = nil;
    [_pushBaiDuRequestid release];
    _pushBaiDuRequestid = nil;
    [super dealloc];
}


#pragma mark Time
#pragma mark -TimeConvert
+ (NSString *)getConvertDateStringWithDate:(NSString *)date {
    NSArray *array = [date componentsSeparatedByString:@" "];
    NSString *dateStr = [array objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tempDate = [dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateString = [dateFormatter stringFromDate:tempDate];
    [dateFormatter release];
    return dateString;
}

+ (NSString *)getConvertDateStringWithDate_2:(NSString *)date {
    NSArray *array = [date componentsSeparatedByString:@" "];
    NSString *dateStr = [array objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tempDate = [dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:tempDate];
    [dateFormatter release];
    return dateString;
}

+ (NSString *)getWeekDay:(NSString *)date {
    NSArray *array = [date componentsSeparatedByString:@" "];
    NSString *dateStr = [array objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *tempDate = [dateFormatter dateFromString:dateStr];

    NSArray * arrWeek=[NSArray arrayWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:tempDate];
    NSInteger week = [comps weekday];
    NSString *weekDay = [NSString stringWithFormat:@"%@",[arrWeek objectAtIndex:(week - 1) % 7]];
    [calendar release];
    [dateFormatter release];
    
    return weekDay;
}

+ (NSString *)getNowDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *result = [dateFormatter stringFromDate:[NSDate date]];
    result = [result stringByAppendingString:@" 00:00:00"];
    [dateFormatter release];
    
    return result;
}

//判断时间是否过期
+ (BOOL)judgeIsOutOfDate:(NSString *)endtimeStr {
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    // 截止时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *tmpEndDate = [dateFormatter dateFromString:endtimeStr];
    NSTimeInterval endInterval = [zone secondsFromGMTForDate:tmpEndDate];
    NSDate *endDate = [tmpEndDate  dateByAddingTimeInterval: endInterval];
    [dateFormatter release];
    
    // 系统当前时间
    NSDate *tmpCurDate = [NSDate date];
    NSTimeInterval currInterval = [zone secondsFromGMTForDate:tmpCurDate];
    NSDate *currDate = [tmpCurDate  dateByAddingTimeInterval: currInterval];
    // 当前时间和截止时间相比，如果早于截止时间，则表示可以进行投注
    if ([currDate compare:endDate] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (BOOL)isOutOfDate:(NSString *)endtimeStr {
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    // 截止时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *tmpEndDate = [dateFormatter dateFromString:endtimeStr];
    NSTimeInterval endInterval = [zone secondsFromGMTForDate:tmpEndDate];
    NSDate *endDate = [tmpEndDate  dateByAddingTimeInterval: endInterval];
    [dateFormatter release];
    
    // 系统当前时间
    NSDate *tmpCurDate = [NSDate date];
    NSTimeInterval currInterval = [zone secondsFromGMTForDate:tmpCurDate];
    NSDate *currDate = [tmpCurDate  dateByAddingTimeInterval: currInterval];
    // 当前时间和截止时间相比，如果早于截止时间，则表示可以进行投注
    if ([currDate compare:endDate] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (NSTimeInterval)calculateCurrentTimeIntervalWithTime:(NSString *)compareTime {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *sendTime = [NSDate date];
    NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:sendTime]];
    
    NSDate *compareDate = [dateFormatter dateFromString:compareTime];
    
    NSTimeInterval time = [compareDate timeIntervalSinceDate:currentDate];
    return time;
}

+ (NSTimeInterval)getTimeWithIntervalTime:(NSTimeInterval)IntervalTime {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *sendTime = [NSDate date];
    NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:sendTime]];
    
    NSTimeInterval time = [currentDate timeIntervalSince1970] + IntervalTime;
    return time;
}

//将日期转为NSInteger 类型，并可以计算几个月前的大概int类型
+ (NSInteger)timeConvertToIndegerWithStringWithStringTime:(NSString *)stringTime beforeMonth:(NSInteger)beforeMonth {
    NSInteger signCount = 1000;//最大循环次数
    NSInteger sign = 0;
    
    NSArray *timeArray = [stringTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if ([timeArray count] > 0) {
        NSString *timeStr = [timeArray objectAtIndex:0];
        
        NSArray *yearMonthDayArray = [timeStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        if ([yearMonthDayArray count] > 2) {
            NSInteger year = [[yearMonthDayArray objectAtIndex:0] integerValue];
            NSInteger month = [[yearMonthDayArray objectAtIndex:1] integerValue];
            NSInteger day = [[yearMonthDayArray objectAtIndex:2] integerValue];
            
            while (month - beforeMonth <= 0) {
                year -= 1;
                month += 12;
                sign++;
                if (sign > signCount) {
                    break;
                }
            }
            
            month -= beforeMonth;
            
            NSInteger timeInt = year * 10000 + month * 100 + day;
            return timeInt;
        }
    }
    return 0;
}

+ (NSInteger)findDetailIndexWithLotteryId:(NSInteger)lotteryId lotteryIDArray:(NSArray *)lotteryIDArray {
    for (NSInteger index = 0; index < [lotteryIDArray count]; index++) {
        if ([[lotteryIDArray objectAtIndex:index] integerValue] == lotteryId) {
            return index;
        }
    }
    
    return -1;//返回0这样的还有待参详
}

//对一个数组内的数字进行升序排序     快速排序法（次级排序）
+ (void)sortWithNumberArray:(NSMutableArray *)numberArray {
    if ([numberArray count] <= 1) {
        return;
    }
    for (NSInteger i = 0; i < [numberArray count] - 1 ; i++) {
        NSInteger minIndex = i;
        for (NSInteger j = i + 1; j < [numberArray count]; j++) {
            if ([[numberArray objectAtIndex:minIndex] integerValue] > [[numberArray objectAtIndex:j] integerValue]) {
                minIndex = j;
            }
        }
        if (minIndex != i) {
            [numberArray exchangeObjectAtIndex:i withObjectAtIndex:minIndex];
        }
    }
}

+ (NSInteger)getRandomBetweenTheMaxNum:(NSInteger)maxNum minNum:(NSInteger)minNum {
    NSInteger random = arc4random() % (maxNum - minNum) + minNum;
    return random;
}

+ (NSString *)autoAdaptiveIphoneIpadPhotoName:(NSString *)photoName {
    NSArray *photoArray = [photoName componentsSeparatedByString:@"."];
    if ([photoArray count] >= 2) {
        if (IS_PHONE) {
            return [NSString stringWithFormat:@"%@_phone.%@",[photoArray objectAtIndex:0],[photoArray objectAtIndex:1]];
        } else {
            return [NSString stringWithFormat:@"%@_phone.%@",[photoArray objectAtIndex:0],[photoArray objectAtIndex:1]];
        }
    }
    return @"";
}

+ (CGSize)defaultSizeWithString:(NSString *)str fontSize:(CGFloat)fontSize {
   return [str sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(kWinSize.width, kWinSize.height) lineBreakMode:NSLineBreakByWordWrapping];
}

+ (void)createBlackWithImageViewWithFrame:(CGRect)frame inSuperView:(UIView *)superView {
    CGRect blackLineViewRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) / 2.0f);
    UIView *blackLineView = [[UIView alloc] initWithFrame:blackLineViewRect];
    [blackLineView setBackgroundColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:0.5f]];
    [superView addSubview:blackLineView];
    [blackLineView release];
    
    CGRect whiteLineViewRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(blackLineViewRect), CGRectGetWidth(frame), CGRectGetHeight(frame) / 2.0f);
    UIView *whiteLineView = [[UIView alloc] initWithFrame:whiteLineViewRect];
    [whiteLineView setBackgroundColor:[UIColor whiteColor]];
    [superView addSubview:whiteLineView];
    [whiteLineView release];
}

+ (void)makeLineWithFrame:(CGRect)frame inSuperView:(UIView *)superView {
    CGRect blackLineViewRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
    UIView *blackLineView = [[UIView alloc] initWithFrame:blackLineViewRect];
    [blackLineView setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];//e2
    [superView addSubview:blackLineView];
    [blackLineView release];
}

+ (NSAttributedString *)getAttriButedWithText:(NSString *)text fontSize:(CGFloat)fontSize {
    MarkupParser *p = [[MarkupParser alloc] initWithFontSize:fontSize];
    NSAttributedString *attString = [[p attrStringFromMarkup:text] copy];
    [p release];
    return [attString autorelease];
}

+ (NSString *)getCaptcha {
    NSArray *changeArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
                    @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
    NSString *getOneRandomChar = @"";
    
    NSString *captchaString = @"";
    for(NSInteger i = 0; i < 4; i++) {
        NSInteger index = arc4random() % ([changeArray count] - 1);
        getOneRandomChar = [changeArray objectAtIndex:index];
        
        captchaString = [NSString stringWithFormat:@"%@%@",captchaString,getOneRandomChar];
    }
    
    return captchaString;
}

+ (BOOL)isPhoneNumber:(NSString *)phoneNumber {
    NSString *regex = @"^[1][358][0-9]{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject: phoneNumber];
}

+ (void)alertWithMessage:(NSString *)message {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:nil content:message];
    [alert show];
    [alert release];
}

+ (void)alertWithMessage:(NSString *)message delegate:(id<CustomAlertViewDelegate>)delegate tag:(NSInteger)tag {
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"提示" delegate:delegate content:message leftText:@"取消" rightText:@"确定"];
    [alert setTag:tag];
    [alert show];
    [alert release];
}

@end

