//
//  IntegralDetailTableViewCell.h
//  TicketProject
//
//  Created by KAI on 15/5/15.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralDetailTableViewCell : UITableViewCell {
    UILabel *_dateLabel;
    UILabel *_timeLabel;
    UILabel *_integralLabel;
    UILabel *_integralTypeLabel;
    UILabel *_totalIntegralLabel;
    
    NSString *_yearMonthDayDateTimeString;
    NSString *_hourMinuteSecondDateTimeString;
    NSString *_integral;
    NSString *_integralType;
    NSInteger _totalIntegral;
    
    CGFloat _cellWidth;
    CGFloat _cellHeight;
}

@property (nonatomic, copy) NSString *yearMonthDayDateTimeString;
@property (nonatomic, copy) NSString *hourMinuteSecondDateTimeString;
@property (nonatomic, copy) NSString *integral;
@property (nonatomic, copy) NSString *integralType;
@property (nonatomic, assign) NSInteger totalIntegral;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight;

@end
