//
//  CustomFootBallZJQButton.m 购彩大厅－竞彩选号－总进球自定义btn
//  TicketProject
//
//  Created by sls002 on 13-6-27.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20141014 15:06（洪晓彬）：修改代码规范

#import "CustomFootBallZJQButton.h"
#import "Globals.h"


#pragma mark -
#pragma mark @implementation CustomFootBallZJQButton
@implementation CustomFootBallZJQButton
@synthesize lineHide = _lineHide;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:218.0f/255.0f green:33/255.0f blue:46/255.0f alpha:1.0f]] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:218.0f/255.0f green:33/255.0f blue:46/255.0f alpha:1.0f]] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.layer setBorderWidth:AllLineWidthOrHeight];
        [self.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
        _lineHide = NO;
        [self createLabels];
    }
    return self;
}

- (void)dealloc {
    _scoreLabel = nil;
    _oddsLabel = nil;
    
    [super dealloc];
}

- (void)createLabels {
    /********************** adjustment 控件调整 ***************************/
    CGFloat scoreLabelWidth = IS_PHONE ? 15.0f : 30.0f;
    
    CGFloat oddsLabelWidth = IS_PHONE ? 30.0f : 60.0f;
    
    CGFloat verticalPointLineMinY = IS_PHONE ? 2.0f : 4.0f;
    CGFloat verticalPointLineWidth = IS_PHONE ? 1.0f : 2.0f;
    /********************** adjustment end ***************************/
    //scoreLabel
    CGRect scoreLabelRect = CGRectMake(0, 0, scoreLabelWidth - 3, CGRectGetHeight(self.frame));
    _scoreLabel = [[UILabel alloc]initWithFrame:scoreLabelRect];
    [_scoreLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_scoreLabel setTextAlignment:NSTextAlignmentCenter];
    [_scoreLabel setBackgroundColor:[UIColor clearColor]];
    [_scoreLabel setTextColor:[UIColor colorWithRed:218.0f/255.0f green:33/255.0f blue:46/255.0f alpha:1.0f]];
    [self addSubview:_scoreLabel];
    [_scoreLabel release];
    
    //pointLineImageView
    CGRect pointLineImageViewRect = CGRectMake(CGRectGetMaxX(scoreLabelRect), verticalPointLineMinY, verticalPointLineWidth, CGRectGetHeight(self.frame) - verticalPointLineMinY * 2);
    _pointLineImageView = [[UIImageView alloc] initWithFrame:pointLineImageViewRect];
    [_pointLineImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
    [self addSubview:_pointLineImageView];
    [_pointLineImageView release];
    
    //oddsLabel
    CGRect oddsLabelRect = CGRectMake(CGRectGetMaxX(pointLineImageViewRect), 0, oddsLabelWidth, CGRectGetHeight(self.frame));
    _oddsLabel = [[UILabel alloc]initWithFrame:oddsLabelRect];
    [_oddsLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
    [_oddsLabel setTextAlignment:NSTextAlignmentCenter];
    [_oddsLabel setBackgroundColor:[UIColor clearColor]];
    [_oddsLabel setTextColor:[UIColor colorWithRed:95.0f/255.0f green:95.0f/255.0f blue:95.0f/255.0f alpha:1.0f]];
    [self addSubview:_oddsLabel];
    [_oddsLabel release];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [_scoreLabel setTextColor:selected ? [UIColor whiteColor] : [UIColor colorWithRed:218.0f/255.0f green:33/255.0f blue:46/255.0f alpha:1.0f]];
    [_oddsLabel setTextColor:selected ? [UIColor whiteColor] : [UIColor colorWithRed:95.0f/255.0f green:95.0f/255.0f blue:95.0f/255.0f alpha:1.0f]];
}

- (void)setLineHide:(BOOL)lineHide {
    if (_lineHide != lineHide) {
        _lineHide = lineHide;
        [_pointLineImageView setHidden:_lineHide];
    }
}

@end
