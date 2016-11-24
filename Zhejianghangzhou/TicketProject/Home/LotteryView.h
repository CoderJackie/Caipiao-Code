//
//  LotteryView.h
//  TicketProject
//
//  Created by KAI on 14-11-20.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryViewDelegate.h"

typedef enum {
    LotteryViewLabelTwoRow,
    LotteryViewLabelThreeRow,
} LotteryViewLabelRowType;


@class TimerLabel;

@interface LotteryView : UIView {
    UIImageView *_lotteryImageView;
    UIImageView *_todayOpenLotteryImageView;
    UILabel     *_lotteryNameLabel;
    UILabel     *_promptLabel;
    UILabel     *_matchLabel;
    TimerLabel  *_timeLabel;
    UIImageView *_bonusImageView;
    UILabel     *_bonusLabel;
    CGRect promptLabelRect;
    
    NSString    *_lotteryImageName;
    NSString    *_lotteryName;
    NSString    *_promptText;
    NSString    *_matchText;
    NSString    *_stopSellTimeStr;
    NSString    *_startSellTimeStr;
    BOOL         _hasBonus;
    BOOL         _isTodayOpen;
    
    NSInteger    _col;
    NSInteger    _row;
    NSString    *_lotteryId;
    id<LotteryViewDelegate> _delegete;
    
    LotteryViewLabelRowType _lotteryViewLabelRowType;
}

@property (nonatomic, assign) LotteryViewLabelRowType lotteryViewLabelRowType;
@property (nonatomic, assign) BOOL hasBonus;
@property (nonatomic, assign) BOOL isTodayOpen;
@property (nonatomic, copy) NSString *lotteryImageName;
@property (nonatomic, copy) NSString *lotteryName;
@property (nonatomic, copy) NSString *promptText;
@property (nonatomic, copy) NSString *matchText;
@property (nonatomic, copy) NSString *stopSellTimeStr; //已经开售的只需要设置截止的时间
@property (nonatomic, copy) NSString *startSellTimeStr;//未开售就只需要设置开售的时间
@property (nonatomic, assign) NSInteger nextStartTimeInterval;

@property (nonatomic, assign) NSInteger col;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy) NSString *lotteryId;
@property (nonatomic, assign) id<LotteryViewDelegate> delegate;




@end
