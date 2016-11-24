//
//  LotteryView.m
//  TicketProject
//
//  Created by KAI on 14-11-20.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "LotteryView.h"
#import "TimerLabel.h"

#import "Globals.h"

#define LineViewBoundSize (IS_PHONE ? 0.5f : 1.0f)

#pragma mark -
#pragma mark @implementation LotteryView
@implementation LotteryView
@synthesize col = _col;
@synthesize row = _row;
@synthesize lotteryId = _lotteryId;
@synthesize delegate = _delegete;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hasBonus = NO;
        _isTodayOpen = YES;
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    _lotteryImageView = nil;
    _lotteryNameLabel = nil;
    _promptLabel = nil;
    _matchLabel = nil;
    _timeLabel = nil;
    _bonusImageView = nil;
    _bonusLabel = nil;
    
    [_lotteryImageName release];
    _lotteryImageName = nil;
    [_lotteryName release];
    _lotteryName = nil;
    [_promptText release];
    _promptText = nil;
    [_matchText release];
    _matchText = nil;
    [_stopSellTimeStr release];
    _stopSellTimeStr = nil;
    
    [_lotteryId release];
    _lotteryId = nil;
    [super dealloc];
}

#pragma mark -MakeUI
- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat lotteryImageViewMinX = IS_PHONE ? 15.0f : 30.0f;
    CGFloat lotteryImageVIewMinY = IS_PHONE ? 15.0f : 20.0f;
    CGFloat lotteryImageViewSize = IS_PHONE ? 49.0f : 75.0f;
    
    
    CGFloat bonusImageViewMaginRight = IS_PHONE ? 4.0f : 15.0f;
    CGFloat bonusImageViewWidth = IS_PHONE ? 35.0f : 60.0f;
    CGFloat bonusImageViewHeight = IS_PHONE ? 35.0f : 60.0f;
    
    CGFloat todayOpenLotteryImageViewSize = IS_PHONE ? 54.0f : 88.0f;
    
    CGFloat labelImageViewLandscapeInterval = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat lotteryNameLabelMinY = IS_PHONE ? 18.0f : 25.0f;
    CGFloat lotteryNameLabelPromptLabelVerticalInterval = IS_PHONE ? 3.0f : 10.0f;
    CGFloat labelHeight = (CGRectGetHeight(self.frame) - lotteryNameLabelMinY * 2 - lotteryNameLabelPromptLabelVerticalInterval) / 3.0f;
    /********************** adjustment end ***************************/
    
    //lotteryImageView  彩种图
    CGRect lotteryImageViewRect = CGRectMake(lotteryImageViewMinX, lotteryImageVIewMinY, lotteryImageViewSize, lotteryImageViewSize);
    _lotteryImageView = [[UIImageView alloc] initWithFrame:lotteryImageViewRect];
    [_lotteryImageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_lotteryImageView];
    [_lotteryImageView release];
    
    //todayOpenLotteryImageView
    CGRect todayOpenLotteryImageViewRect = CGRectMake(CGRectGetMinX(lotteryImageViewRect) - (todayOpenLotteryImageViewSize - lotteryImageViewSize) / 2.0f, CGRectGetMinY(lotteryImageViewRect) + 6.0f, todayOpenLotteryImageViewSize, todayOpenLotteryImageViewSize);
    _todayOpenLotteryImageView = [[UIImageView alloc] initWithFrame:todayOpenLotteryImageViewRect];
    [_todayOpenLotteryImageView setBackgroundColor:[UIColor clearColor]];
    [_todayOpenLotteryImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"todayOpenLottery.png"]]];
    [_todayOpenLotteryImageView setHidden:!_isTodayOpen];
    [self addSubview:_todayOpenLotteryImageView];
    [_todayOpenLotteryImageView release];
    
    //lotteryNameLabel 彩种名
    CGRect lotteryNameLabelRect = CGRectMake(CGRectGetMaxX(_lotteryImageView.frame) + labelImageViewLandscapeInterval, lotteryNameLabelMinY, CGRectGetWidth(self.frame) - CGRectGetMaxX(_lotteryImageView.frame) - labelImageViewLandscapeInterval, labelHeight);
    _lotteryNameLabel = [[UILabel alloc] initWithFrame:lotteryNameLabelRect];
    [_lotteryNameLabel setBackgroundColor:[UIColor clearColor]];
    [_lotteryNameLabel setTextAlignment:NSTextAlignmentLeft];
    [_lotteryNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_lotteryNameLabel setTextColor:[UIColor blackColor]];
    [self addSubview:_lotteryNameLabel];
    [_lotteryNameLabel release];
    
    //promptLabel  彩种提示
    promptLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(lotteryNameLabelRect) + lotteryNameLabelPromptLabelVerticalInterval, CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    _promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [_promptLabel setBackgroundColor:[UIColor clearColor]];
    [_promptLabel setTextAlignment:NSTextAlignmentLeft];
    [_promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_promptLabel setTextColor:[UIColor colorWithRed:0x96/255.0f green:0x96/255.0f blue:0x96/255.0f alpha:1.0f]];
    [_promptLabel setMinimumScaleFactor:0.5];
    [_promptLabel setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:_promptLabel];
    [_promptLabel release];
    
    //matchLabel 对阵信息
    CGRect matchLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(promptLabelRect), CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    _matchLabel = [[UILabel alloc] initWithFrame:matchLabelRect];
    [_matchLabel setBackgroundColor:[UIColor clearColor]];
    [_matchLabel setTextAlignment:NSTextAlignmentLeft];
    [_matchLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_matchLabel setTextColor:[UIColor colorWithRed:0x96/255.0f green:0x96/255.0f blue:0x96/255.0f alpha:1.0f]];
    [self addSubview:_matchLabel];
    [_matchLabel release];
    
    //timeLabel 时间提示
    CGRect timeLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(promptLabelRect), CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    _timeLabel = [[TimerLabel alloc] initWithFrame:timeLabelRect];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel setTextAlignment:NSTextAlignmentLeft];
    [_timeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_timeLabel setTextColor:[UIColor colorWithRed:0x96/255.0f green:0x96/255.0f blue:0x96/255.0f alpha:1.0f]];
    [self addSubview:_timeLabel];
    [_timeLabel release];
    
    //bonusImageView 加奖背景
    CGRect bonusImageViewRect = CGRectMake(CGRectGetWidth(self.frame) - bonusImageViewWidth - bonusImageViewMaginRight, -8.0, bonusImageViewWidth, bonusImageViewHeight);
    _bonusImageView = [[UIImageView alloc] initWithFrame:bonusImageViewRect];
    [_bonusImageView setBackgroundColor:[UIColor clearColor]];
    [_bonusImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"bonusBackImage.png"]]];
    [_bonusImageView setHidden:!_hasBonus];
    [self addSubview:_bonusImageView];
    [_bonusImageView release];
    
    //bonusLabel 加奖文字
    _bonusLabel = [[UILabel alloc] initWithFrame:bonusImageViewRect];
    [_bonusLabel setBackgroundColor:[UIColor clearColor]];
    [_bonusLabel setTextAlignment:NSTextAlignmentCenter];
    [_bonusLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_bonusLabel setTextColor:[UIColor whiteColor]];
    [_bonusLabel setText:@"加奖"];
    [_bonusLabel setHidden:!_hasBonus];
    [self addSubview:_bonusLabel];
    [_bonusLabel release];
    
    //leftSignImageView 箭头图
    CGRect leftSignRect = CGRectMake(self.width-30, self.height/2-10, 10, 10);
    UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignRect];
    [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
    [leftSignImageView setTag:502];
    [self addSubview:leftSignImageView];
    [leftSignImageView release];
    leftSignImageView.hidden = YES;
}

- (void)setThreeRowFrame {
    /********************** adjustment 控件调整 ***************************/
    CGFloat labelImageViewLandscapeInterval = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat lotteryNameLabelMinY = IS_PHONE ? 18.0f : 25.0f;
    CGFloat lotteryNameLabelPromptLabelVerticalInterval = IS_PHONE ? 3.0f : 10.0f;
    CGFloat labelHeight = (CGRectGetHeight(self.frame) - lotteryNameLabelMinY * 2 - lotteryNameLabelPromptLabelVerticalInterval) / 3.0f;
    /********************** adjustment end ***************************/
    CGRect lotteryNameLabelRect = CGRectMake(CGRectGetMaxX(_lotteryImageView.frame) + labelImageViewLandscapeInterval, lotteryNameLabelMinY, CGRectGetWidth(self.frame) - CGRectGetMaxX(_lotteryImageView.frame) - labelImageViewLandscapeInterval, labelHeight);
    [_lotteryNameLabel setFrame:lotteryNameLabelRect];
    
    promptLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(lotteryNameLabelRect) + lotteryNameLabelPromptLabelVerticalInterval, CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    [_promptLabel setFrame:promptLabelRect];
    
    CGRect matchLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(promptLabelRect), CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    [_matchLabel setFrame:matchLabelRect];
    
    CGRect timeLabelRect = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(promptLabelRect), CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    [_timeLabel setFrame:timeLabelRect];
}

- (void)setTwoRowFrame {
    /********************** adjustment 控件调整 ***************************/
    CGFloat labelImageViewLandscapeInterval = IS_PHONE ? 10.0f : 20.0f;
    
    CGFloat lotteryNameLabelMinY = IS_PHONE ? 25.0f : 50.0f;
    CGFloat labelHeight = (CGRectGetHeight(self.frame) - lotteryNameLabelMinY * 2) / 2.0f;
    /********************** adjustment end ***************************/
    CGRect lotteryNameLabelRect = CGRectMake(CGRectGetMaxX(_lotteryImageView.frame) + labelImageViewLandscapeInterval, lotteryNameLabelMinY, CGRectGetWidth(self.frame) - CGRectGetMaxX(_lotteryImageView.frame) - labelImageViewLandscapeInterval, labelHeight);
    [_lotteryNameLabel setFrame:lotteryNameLabelRect];
    
    CGRect promptLabelRect1 = CGRectMake(CGRectGetMinX(lotteryNameLabelRect), CGRectGetMaxY(lotteryNameLabelRect), CGRectGetWidth(lotteryNameLabelRect), labelHeight);
    [_promptLabel setFrame:promptLabelRect1];
}


#pragma mark -AttributeMethod
- (void)setIsTodayOpen:(BOOL)isTodayOpen {
    if (_isTodayOpen != isTodayOpen) {
        _isTodayOpen = isTodayOpen;
        [_todayOpenLotteryImageView setHidden:!_isTodayOpen];
    }
}

- (void)setLotteryViewLabelRowType:(LotteryViewLabelRowType)lotteryViewLabelRowType {
    if (_lotteryViewLabelRowType != lotteryViewLabelRowType) {
        _lotteryViewLabelRowType = lotteryViewLabelRowType;
        if (_lotteryViewLabelRowType == LotteryViewLabelTwoRow) {
            [self setTwoRowFrame];
            
        } else if (lotteryViewLabelRowType == LotteryViewLabelThreeRow) {
            [self setThreeRowFrame];
            
        }
    }
}

- (void)setHasBonus:(BOOL)hasBonus {
    if (_hasBonus != hasBonus) {
        _hasBonus = hasBonus;
        if (_hasBonus == YES) {
            [_bonusImageView setHidden:NO];
            [_bonusLabel setHidden:NO];
        } else {
            [_bonusImageView setHidden:YES];
            [_bonusLabel setHidden:YES];
        }
    }
}

- (void)setLotteryImageName:(NSString *)lotteryImageName {
    if (![_lotteryImageName isEqualToString:lotteryImageName]) {
        [_lotteryImageName release];
        _lotteryImageName = [lotteryImageName copy];
        [_lotteryImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:_lotteryImageName]]];
    }
}

- (void)setLotteryName:(NSString *)lotteryName {
    if (![_lotteryName isEqualToString:lotteryName]) {
        [_lotteryName release];
        _lotteryName = [lotteryName copy];
        [_lotteryNameLabel setText:_lotteryName];
    }
}

- (void)setPromptText:(NSString *)promptText {
    if (![_promptText isEqualToString:promptText]) {
        [_promptText release];
        _promptText = [promptText copy];
        [_promptLabel setText:_promptText];
        
        // 根据状态设备不同的属性
        if ([_promptText isEqualToString:@"暂停销售"]) {
            _promptLabel.backgroundColor = [UIColor redColor];
            [_promptLabel.layer setCornerRadius:6.0];
            [_promptLabel.layer setMasksToBounds:YES];
            _promptLabel.textColor = [UIColor whiteColor];
            _promptLabel.textAlignment = NSTextAlignmentCenter;
            [_promptLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize10]];
            _promptLabel.frame = CGRectMake(promptLabelRect.origin.x, promptLabelRect.origin.y + 2, 48, promptLabelRect.size.height);
        }else {
            _promptLabel.backgroundColor = [UIColor clearColor];
            [_promptLabel setTextColor:[UIColor colorWithRed:0x96/255.0f green:0x96/255.0f blue:0x96/255.0f alpha:1.0f]];
            _promptLabel.frame = promptLabelRect;
            _promptLabel.textAlignment = NSTextAlignmentLeft;
            [_promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
            [_promptLabel.layer setMasksToBounds:NO];
        }
    }
}

- (void)setMatchText:(NSString *)matchText {
    if (![_matchText isEqualToString:matchText]) {
        [_matchText release];
        _matchText = [matchText copy];
        [_matchLabel setText:_matchText];
    }
}

- (void)setStopSellTimeStr:(NSString *)stopSellTimeStr {
    if (![_stopSellTimeStr isEqualToString:stopSellTimeStr]) {
        [_stopSellTimeStr release];
        _stopSellTimeStr = [stopSellTimeStr copy];
        if (_stopSellTimeStr.length == 0) {
            [_timeLabel setHidden:YES];
        } else {
            [_timeLabel setHidden:NO];
            [_timeLabel updateText:_stopSellTimeStr updateTag:[_lotteryId integerValue] isStartSell:YES];
        }
    }
}

- (void)setStartSellTimeStr:(NSString *)startSellTimeStr {
    if (![_startSellTimeStr isEqualToString:startSellTimeStr]) {
        [_startSellTimeStr release];
        _startSellTimeStr = [startSellTimeStr copy];
        if (_startSellTimeStr.length == 0) {
            [_timeLabel setHidden:YES];
        } else {
            [_timeLabel setHidden:NO];
            [_timeLabel updateText:_startSellTimeStr updateTag:[_lotteryId integerValue] isStartSell:NO];
        }
    }
}

- (void)setNextStartTimeInterval:(NSInteger)nextStartTimeInterval {
    [_timeLabel setNextStartTimeInterval:nextStartTimeInterval];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundColor:[UIColor whiteColor]];
    if (_delegete && [_delegete respondsToSelector:@selector(didSelectLotteryViewWithLotteryId:row:col:)]) {
        [_delegete didSelectLotteryViewWithLotteryId:_lotteryId row:_row col:_col];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundColor:[UIColor colorWithRed:0xf2/255.0f green:0xf2/255.0f blue:0xf2/255.0f alpha:1.0f]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundColor:[UIColor whiteColor]];
}

@end
