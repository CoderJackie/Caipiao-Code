//
//  CircleBtn.m
//  TicketProject
//
//  Created by KAI on 15/5/11.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "CircleBtn.h"

#import "Globals.h"

@implementation CircleBtn

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    _integralLabel = nil;
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat circleBtnLayerWidth = IS_PHONE ? 1.0f : 2.0f;
    
    CGFloat promptIntegralLabelMinX = IS_PHONE ? 5.0f : 15.0f;
    CGFloat promptIntegralLabelMinBtnY = IS_PHONE ? 20.0f : 40.0f;
    CGFloat promptIntegralLabelHeight = IS_PHONE ? 21.0f : 50.0f;
    /********************** adjustment end ***************************/
    
    [self setBackgroundColor:[UIColor clearColor]];
    [[self layer] setBorderWidth:circleBtnLayerWidth];
    [[self layer] setBorderColor:[UIColor colorWithRed:0xd2/255.0f green:0xd2/255.0f blue:0xd2/255.0f alpha:1.0].CGColor];
    [[self layer] setCornerRadius:CGRectGetWidth(self.frame) / 2.0f];
    
    //promptIntegralLabel
    CGRect promptIntegralLabelRect = CGRectMake(promptIntegralLabelMinX, promptIntegralLabelMinBtnY, CGRectGetWidth(self.frame) - promptIntegralLabelMinX * 2, promptIntegralLabelHeight);
    UILabel *promptIntegralLabel = [[UILabel alloc] initWithFrame:promptIntegralLabelRect];
    [promptIntegralLabel setBackgroundColor:[UIColor clearColor]];
    [promptIntegralLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [promptIntegralLabel setTextAlignment:NSTextAlignmentCenter];
    [promptIntegralLabel setText:@"当前积分"];
    [self addSubview:promptIntegralLabel];
    [promptIntegralLabel release];
    
    //integralLabel
    CGRect integralLabelRect = CGRectMake(CGRectGetMinX(promptIntegralLabelRect), CGRectGetMaxY(promptIntegralLabelRect), CGRectGetWidth(promptIntegralLabelRect), promptIntegralLabelHeight);
    _integralLabel = [[UILabel alloc] initWithFrame:integralLabelRect];
    [_integralLabel setBackgroundColor:[UIColor clearColor]];
    [_integralLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_integralLabel setTextAlignment:NSTextAlignmentCenter];
    [_integralLabel setTextColor:kRedColor];
    [_integralLabel setMinimumScaleFactor:0.25];
    [_integralLabel setAdjustsFontSizeToFitWidth:YES];
    [_integralLabel setText:@"0分"];
    [self addSubview:_integralLabel];
    [_integralLabel release];
}

- (void)setIntegral:(NSInteger)integral {
    [_integralLabel setText:[NSString stringWithFormat:@"%ld分",(long)integral]];
}



@end
