//
//  IntegralDetailTableViewCell.m
//  TicketProject
//
//  Created by KAI on 15/5/15.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "IntegralDetailTableViewCell.h"

#import "Globals.h"

#define kFirstLabelMinX (IS_PHONE ? 5.0f : 10.0f)
#define kFirstLabelWidth 65.5f * (kWinSize.width / 320.0f)
#define kSecondLabelWidth 62.5f * (kWinSize.width / 320.0f)
#define kThreeLabelWidth 67.0 * (kWinSize.width / 320.0f)
#define kFourLabelWidth 114.5f * (kWinSize.width / 320.0f)

@implementation IntegralDetailTableViewCell
@synthesize yearMonthDayDateTimeString = _yearMonthDayDateTimeString;
@synthesize hourMinuteSecondDateTimeString = _hourMinuteSecondDateTimeString;
@synthesize integral = _integral;
@synthesize integralType = _integralType;
@synthesize totalIntegral = _totalIntegral;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = cellWidth;
        _cellHeight = cellHeight;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        [[self layer] setBorderWidth:0.0];
        [self setClipsToBounds:YES];
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    [_yearMonthDayDateTimeString release];
    _yearMonthDayDateTimeString = nil;
    [_hourMinuteSecondDateTimeString release];
    _hourMinuteSecondDateTimeString = nil;
    [_integral release];
    _integral = nil;
    [_integralType release];
    _integralType = nil;
    [super dealloc];
}

- (void)makeSubView {
    //verticalLineView1 竖线1
    CGRect verticalLineView1Rect = CGRectMake(kFirstLabelMinX, _cellHeight - AllLineWidthOrHeight, _cellWidth - kFirstLabelMinX * 2, AllLineWidthOrHeight);
    UIView *verticalLineView1 = [[UIView alloc] initWithFrame:verticalLineView1Rect];
    [verticalLineView1 setOpaque:YES];
    [verticalLineView1 setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:verticalLineView1];
    [verticalLineView1 release];
    
    //perpendicularLineView1 竖线1
    CGRect perpendicularLineView1Rect = CGRectMake(kFirstLabelMinX, 0, AllLineWidthOrHeight, _cellHeight);
    UIView *perpendicularLineView1 = [[UIView alloc] initWithFrame:perpendicularLineView1Rect];
    [perpendicularLineView1 setOpaque:YES];
    [perpendicularLineView1 setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:perpendicularLineView1];
    [perpendicularLineView1 release];
    
    //perpendicularLineView2 竖线2
    CGRect perpendicularLineView2Rect = CGRectMake(kFirstLabelMinX + kFirstLabelWidth - AllLineWidthOrHeight, 0, AllLineWidthOrHeight, _cellHeight);
    UIView *perpendicularLineView2 = [[UIView alloc] initWithFrame:perpendicularLineView2Rect];
    [perpendicularLineView2 setOpaque:YES];
    [perpendicularLineView2 setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:perpendicularLineView2];
    [perpendicularLineView2 release];
    
    //perpendicularLineView3 竖线3
    CGRect perpendicularLineView3Rect = CGRectMake(kFirstLabelMinX + kFirstLabelWidth + kSecondLabelWidth - AllLineWidthOrHeight, 0, AllLineWidthOrHeight, _cellHeight);
    UIView *perpendicularLineView3 = [[UIView alloc] initWithFrame:perpendicularLineView3Rect];
    [perpendicularLineView3 setOpaque:YES];
    [perpendicularLineView3 setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:perpendicularLineView3];
    [perpendicularLineView3 release];
    
    //perpendicularLineView4 竖线4
    CGRect perpendicularLineView4Rect = CGRectMake(kFirstLabelMinX + kFirstLabelWidth + kSecondLabelWidth + kThreeLabelWidth - AllLineWidthOrHeight, 0, AllLineWidthOrHeight, _cellHeight);
    UIView *perpendicularLineView4 = [[UIView alloc] initWithFrame:perpendicularLineView4Rect];
    [perpendicularLineView4 setOpaque:YES];
    [perpendicularLineView4 setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:perpendicularLineView4];
    [perpendicularLineView4 release];
    
    //perpendicularLineView5 竖线5
    CGRect perpendicularLineView5Rect = CGRectMake(kFirstLabelMinX + kFirstLabelWidth + kSecondLabelWidth + kThreeLabelWidth + kFourLabelWidth - AllLineWidthOrHeight, 0, AllLineWidthOrHeight, _cellHeight);
    UIView *perpendicularLineView5 = [[UIView alloc] initWithFrame:perpendicularLineView5Rect];
    [perpendicularLineView5 setOpaque:YES];
    [perpendicularLineView5 setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:perpendicularLineView5];
    [perpendicularLineView5 release];
    
    //dateLabel 时间-x年x月x日
    CGRect dateLabelRect = CGRectMake(kFirstLabelMinX, 0, kFirstLabelWidth, _cellHeight / 2.0f);
    _dateLabel = [[UILabel alloc] initWithFrame:dateLabelRect];
    [_dateLabel setBackgroundColor:[UIColor clearColor]];
    [_dateLabel setOpaque:YES];
    [_dateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_dateLabel setTextAlignment:NSTextAlignmentCenter];
    [_dateLabel setTextColor:kGrayColor];
    [self.contentView addSubview:_dateLabel];
    [_dateLabel release];
    
    //timeLabel 时间-x时x分x秒
    CGRect timeLabelRect = CGRectMake(CGRectGetMinX(dateLabelRect), CGRectGetMaxY(dateLabelRect), CGRectGetWidth(dateLabelRect), _cellHeight / 2.0f - AllLineWidthOrHeight);
    _timeLabel = [[UILabel alloc] initWithFrame:timeLabelRect];
    [_timeLabel setOpaque:YES];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [_timeLabel setTextColor:kGrayColor];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel release];
    
    //integralLabel 积分
    CGRect integralLabelRect = CGRectMake(CGRectGetMaxX(dateLabelRect) - AllLineWidthOrHeight, 0, kSecondLabelWidth, _cellHeight - AllLineWidthOrHeight);
    _integralLabel = [[UILabel alloc] initWithFrame:integralLabelRect];
    [_integralLabel setOpaque:YES];
    [_integralLabel setBackgroundColor:[UIColor clearColor]];
    [_integralLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_integralLabel setTextColor:[UIColor colorWithRed:0xe3/255.0 green:0x39/255.0 blue:0x3c/255.0 alpha:1.0]];
    [_integralLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_integralLabel];
    [_integralLabel release];
    
    //integralTypeLabel 类型
    CGRect integralTypeLabelRect = CGRectMake(CGRectGetMaxX(integralLabelRect) - AllLineWidthOrHeight, 0, kThreeLabelWidth, _cellHeight - AllLineWidthOrHeight);
    _integralTypeLabel = [[UILabel alloc] initWithFrame:integralTypeLabelRect];
    [_integralTypeLabel setOpaque:YES];
    [_integralTypeLabel setBackgroundColor:[UIColor clearColor]];
    [_integralTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_integralTypeLabel setTextAlignment:NSTextAlignmentCenter];
    [_integralTypeLabel setTextColor:kGrayColor];
    [self.contentView addSubview:_integralTypeLabel];
    [_integralTypeLabel release];
    
    //totalIntegralLabel 总积分
    CGRect totalIntegralLabelRect = CGRectMake(CGRectGetMaxX(integralTypeLabelRect) - AllLineWidthOrHeight, 0, kFourLabelWidth, _cellHeight - AllLineWidthOrHeight);
    _totalIntegralLabel = [[UILabel alloc] initWithFrame:totalIntegralLabelRect];
    [_totalIntegralLabel setOpaque:YES];
    [_totalIntegralLabel setBackgroundColor:[UIColor clearColor]];
    [_totalIntegralLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_totalIntegralLabel setTextAlignment:NSTextAlignmentCenter];
    [_totalIntegralLabel setTextColor:kGrayColor];
    [self.contentView addSubview:_totalIntegralLabel];
    [_totalIntegralLabel release];
}

- (void)setYearMonthDayDateTimeString:(NSString *)yearMonthDayDateTimeString {
    if (![_yearMonthDayDateTimeString isEqualToString:yearMonthDayDateTimeString]) {
        [_yearMonthDayDateTimeString release];
        _yearMonthDayDateTimeString = nil;
        _yearMonthDayDateTimeString = [yearMonthDayDateTimeString copy];
        [_dateLabel setText:_yearMonthDayDateTimeString];
    }
}

- (void)setHourMinuteSecondDateTimeString:(NSString *)hourMinuteSecondDateTimeString {
    if (![_hourMinuteSecondDateTimeString isEqualToString:hourMinuteSecondDateTimeString]) {
        [_hourMinuteSecondDateTimeString release];
        _hourMinuteSecondDateTimeString = nil;
        _hourMinuteSecondDateTimeString = [hourMinuteSecondDateTimeString copy];
        [_timeLabel setText:_hourMinuteSecondDateTimeString];
    }
}

- (void)setIntegral:(NSString *)integral {
    if (![_integral isEqualToString:integral]) {
        [_integral release];
        _integral = nil;
        _integral = [integral copy];
        if ([_integral integerValue] > 0) {
            [_integralLabel setTextColor:kBlueColor];
        } else {
            [_integralLabel setTextColor:kRedColor];
        }
        [_integralLabel setText:_integral];
    }
}

- (void)setIntegralType:(NSString *)integralType {
    if (![_integralType isEqualToString:integralType]) {
        [_integralType release];
        _integralType = nil;
        _integralType = [integralType copy];
        [_integralTypeLabel setText:_integralType];
    }
}

- (void)setTotalIntegral:(NSInteger)totalIntegral {
    _totalIntegral = totalIntegral;
    [_totalIntegralLabel setText:[NSString stringWithFormat:@"%ld",(long)_totalIntegral]];
}

@end
