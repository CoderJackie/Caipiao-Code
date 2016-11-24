//
//  TimerLabel.h
//  TicketProject
//
//  Created by sls002 on 13-7-17.
//  Copyright (c) 2013年 sls002. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface TimerLabel : UILabel {
    NSTimeInterval _timeInterval;
    NSTimer *_timer1;
    NSInteger _cellTag;
    
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    BOOL                 _isStartSell;
}

@property (nonatomic, assign) NSTimeInterval nextStartTimeInterval;

-(void)updateText:(NSString *)text updateTag:(NSInteger)tag isStartSell:(BOOL)isStartSell;

@end
