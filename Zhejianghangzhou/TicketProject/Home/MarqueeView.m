//
//  LED_View.m   中奖框
//  AllFrameWorkTest
//
//  Created by npp on 11-9-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//20140715 10:28（洪晓彬）：修改代码规范，改进生命周期，处理内存

#import "MarqueeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MarqueeView

- (id)initWithFrame:(CGRect)frame withContent:(NSString *)str withFont:(UIFont*)font withColor:(UIColor *)color {
	self = [super initWithFrame:frame];
    if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
        self.clipsToBounds = YES;
		_string = [str copy];
		_font = [font copy];
        _color = [color copy];
        [self createLable];
		[self startAnimation];
    }
    return self;
}

- (void)dealloc {
    [_string release];
    _lable = nil;
    [_font release];
    _font = nil;
    [_color release];
    _color = nil;
    [super dealloc];
}

- (void)createLable {
	_lable = [[UILabel alloc] init];
    [_lable setBackgroundColor:[UIColor clearColor]];
    [_lable setText:_string];
    [_lable setFont:_font];
    [_lable setTextColor:_color];
    [_lable setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_lable];
    [_lable release];
}

- (void)startAnimation {
    CGSize expectedSize = [_string sizeWithFont:_font constrainedToSize:CGSizeMake(NSIntegerMax, 300) lineBreakMode:NSLineBreakByWordWrapping];
    int width = expectedSize.width;
	CGFloat duration = 0.02 * width;
    [_lable setFrame:CGRectMake(self.bounds.size.width, self.bounds.origin.y, width, self.bounds.size.height)];
	if(width > self.bounds.size.width){
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:duration];
		[UIView setAnimationRepeatCount:NSIntegerMax];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [_lable setFrame:CGRectMake(-width, self.bounds.origin.y, width, self.bounds.size.height)];
		[UIView commitAnimations];
	} else {
        [_lable setFrame:self.bounds];
	}
}

- (void)stopAnimation{
    [_lable.layer removeAllAnimations];
}

- (void)updateSelfText {
    [self stopAnimation];
    [_lable setText:_string];
    [self startAnimation];
}

- (void)updateText:(NSString *)str{
    [self stopAnimation];
    [_string release];
    _string = [str copy];
    [_lable setText:_string];
    [self startAnimation];
}

@end
