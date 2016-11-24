
//
//  TimerLabel.m   计时器
//  TicketProject
//
//  Created by sls002 on 13-7-17.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140715 14:50（洪晓彬）：修改命名规范
//  20150722 11:00（刘科）：修复时间为负值Bug。

#import "TimerLabel.h"
#import "HomeViewController.h"

#import "Globals.h"
#import "InterfaceHelper.h"

#define kOneDaySeconds 86400 //24 * 60 * 60
#define kOneHourSeconds 3600 //60 * 60
#define kOneMinuteSeconds 60

@implementation TimerLabel

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
        [self setMinimumScaleFactor:0.75];
        [self setAdjustsFontSizeToFitWidth:YES];
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _globals = _appDelegate.globals;
    }
    
    return self;
}

-(NSString *)getIntervalStringWithTimeInterval:(NSTimeInterval)interval {
    
    NSInteger days = (NSInteger)interval / kOneDaySeconds;
    NSInteger hours = ((NSInteger)interval % kOneDaySeconds) / kOneHourSeconds;
    NSInteger minutes = ((NSInteger)interval % kOneHourSeconds) / kOneMinuteSeconds;
    NSInteger seconds = (NSInteger)interval % kOneMinuteSeconds;
    
    NSString *intervalStr;
    if (_isStartSell) {
        // 判断是否时间倒计时的高频彩
        if([InterfaceHelper isTimeQuickLotteryWithLotteryID:_cellTag]){
            
            if( minutes < 0 || seconds < 0 ) {
                //seconds的最大值为-1，最小值为-59.
                
                NSInteger time = _nextStartTimeInterval + interval;
                NSInteger nextStartDays = (NSInteger)time / kOneDaySeconds;
                NSInteger nextStartHours = ((NSInteger)time % kOneDaySeconds) / kOneHourSeconds;
                NSInteger nextStartMinutes = ((NSInteger)time % kOneHourSeconds)/ kOneMinuteSeconds;
                NSInteger nextStartSeconds = (NSInteger)time % kOneMinuteSeconds;
                
                if(time == 0 || time == -1) {
                    if (_globals.isInHomeView) {
                        sleep(3);
                    }
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",(long)_cellTag] forKey:@"cellId"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"selected" object:nil userInfo:dict];
                    intervalStr =  @"已截止";
                } else {
                    
                    
                    if (nextStartDays >= 1) {
                        intervalStr = [NSString stringWithFormat:@"距下期开始:%ld天%ld小时",(long)nextStartDays,(long)nextStartHours];
                        
                    } else if (nextStartHours >= 1) {
                        intervalStr = [NSString stringWithFormat:@"距下期开始:%ld小时%ld分",(long)nextStartHours,(long)nextStartMinutes];
                        
                    } else if (nextStartMinutes >= 1) {
                        intervalStr = [NSString stringWithFormat:@"距下期开始:%ld分%ld秒",(long)nextStartMinutes,(long)nextStartSeconds];
                        
                    } else {
                        
                        if (nextStartSeconds < 0) {
                            nextStartSeconds = 0;
                        }
                        intervalStr = [NSString stringWithFormat:@"距下期开始:%ld秒",(long)nextStartSeconds];
                        
                    }
                    
                    return intervalStr;
                }
                
            } else {
                if(minutes == 0 && seconds == 0) {
                    intervalStr = @"本期结束，请等下一期";
                } else if(minutes == 0) {
                    intervalStr = [NSString stringWithFormat:@"%ld秒后截止", (long)seconds];
                } else {
                    intervalStr = [NSString stringWithFormat:@"%ld分%ld秒后截止", (long)minutes, (long)seconds];
                }
            }
            NSDictionary *dict=[NSDictionary dictionaryWithObject:intervalStr forKey:@"time"]	;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"timeLabel" object:nil userInfo:dict];
            return intervalStr;
        } else {
            if(days < 0 || hours < 0 || minutes < 0 || seconds < 0 ) {
                intervalStr = @"已截止";
                
            } else if (days == 0 && hours == 0 && minutes == 0){
                intervalStr = [NSString stringWithFormat:@"%ld秒后截止", (long)seconds];
            } else if (days == 0 && hours == 0){
                intervalStr = [NSString stringWithFormat:@"%ld分%ld秒后截止", (long)minutes, (long)seconds];
            } else if(days == 0){
                intervalStr = [NSString stringWithFormat:@"%ld小时后截止", (long)hours];
            } else{
                intervalStr = [NSString stringWithFormat:@"%ld天%ld小时后截止", (long)days, (long)hours];
            }
        }
    } else {
        if(days < 0 || hours < 0 || minutes < 0 || seconds < 0 ) {
            intervalStr = @"";
            if (_globals.isInHomeView) {
                sleep(3);
            }
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",(long)_cellTag] forKey:@"cellId"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selected" object:nil userInfo:dict];
            
        } else if (days == 0 && hours == 0 && minutes == 0){
            intervalStr = [NSString stringWithFormat:@"%ld秒后开售", (long)seconds];
        } else if (days == 0 && hours == 0){
            intervalStr = [NSString stringWithFormat:@"%ld分%ld秒后开售", (long)minutes, (long)seconds];
        } else if(days == 0){
            intervalStr = [NSString stringWithFormat:@"%ld小时后开售", (long)hours];
        } else{
            intervalStr = [NSString stringWithFormat:@"%ld天%ld小时后开售", (long)days, (long)hours];
        }
    }
    
    
    return intervalStr;
}
- (void)updateText:(NSString *)text updateTag:(NSInteger)tag isStartSell:(BOOL)isStartSell {
    _isStartSell = isStartSell;
    _cellTag = tag;
    _timeInterval = [text integerValue];
    [_timer1 invalidate];
    _timer1 = nil;
    _timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateLableText:) userInfo:nil repeats:YES];
    [self updateLableText:nil]; 
    [[NSRunLoop currentRunLoop]addTimer:_timer1 forMode:NSRunLoopCommonModes];
}

-(void)updateLableText:(NSTimer *)timer {
    NSTimeInterval nowInterval = [NSDate timeIntervalSinceReferenceDate];
    NSString *timeString = [self getIntervalStringWithTimeInterval:_timeInterval - nowInterval];
    self.text = timeString;
    
}

@end
