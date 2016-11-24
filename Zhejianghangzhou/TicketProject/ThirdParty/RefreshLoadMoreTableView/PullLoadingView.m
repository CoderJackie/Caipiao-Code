//
//  PullLoadingView.m
//
//
//  Created by Apple on 12-10-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PullLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "Globals.h"


#define kPROffsetY 60.f
#define kPRMargin 5.f
#define kPRLabelHeight 20.f
#define kPRLabelWidth 100.f
#define kPRArrowWidth 38.f  
#define kPRArrowHeight 38.f
#define kTextColor [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define kPRBGColor [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:0.0]
#define kPRAnimationDuration .18f
@implementation PullLoadingView
@synthesize state = _state;
@synthesize loading = _loading;
@synthesize atTop = _atTop;

//程序进行这个
-(void)setState:(PRState)state {
    [self setState:state animated:YES];
}

-(void)setLoading:(BOOL)loading {
    _loading = loading;
}

- (void)setState:(PRState)state animated:(BOOL)animated {
    CGFloat duration = animated ? kPRAnimationDuration : 0.0f;
    if (_state != state) {
        _state = state;
        if (_state == kPRStateLoading) {    //Loading
            [_arrow setHidden:YES];
            [_activityView setHidden:NO];
            [_activityView startAnimating];
            
            _loading = YES;
            if (self.isAtTop) {
                _stateLabel.text = NSLocalizedString(@"正在刷新...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"正在加载...", @"");
            }
            
        } else if (_state == kPRStatePulling && !_loading) {    //Scrolling
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [CATransaction commit];
            
            if (self.isAtTop) {
                _stateLabel.text = NSLocalizedString(@"松开后刷新...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"松开后加载更多...", @"");
            }
            
        } else if (_state == kPRStateNormal && !_loading){    //Reset
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            if (self.isAtTop) {
                _stateLabel.text = @"下拉刷新";
            } else {
                _stateLabel.text = @"上拉加载更多";
            }
        } else if (_state == kPRStateHitTheEnd) {
            if (!self.isAtTop) {
                _arrow.hidden = YES;
                _stateLabel.text = @"没有了哦";
            }
        }
    }
}

- (void)updateRefreshDate:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *formateDate = [dateFormatter stringFromDate:currentDate];
    [dateFormatter release];
    
    _dateLabel.text = formateDate;
}

//第一次打开页面进行初始化
- (id)initWithFrame:(CGRect)frame atTop:(BOOL)top {
    self = [super initWithFrame:frame];
    if (self) {
        self.atTop = top;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = kPRBGColor;
        UIFont *ft = [UIFont systemFontOfSize:XFIponeIpadFontSize12];
        _stateLabel = [[UILabel alloc]init];
        _stateLabel.font = ft;
        _stateLabel.textColor=kTextColor;
        _stateLabel.textAlignment=NSTextAlignmentCenter;
        _stateLabel.backgroundColor=kPRBGColor;
        _stateLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        _stateLabel.text=@"下拉刷新";
        [self addSubview:_stateLabel];
        [_stateLabel release];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = ft;
        _dateLabel.textColor = kTextColor;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = kPRBGColor;
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_dateLabel];
        [_dateLabel release];
        
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        
        _arrow = [CALayer layer];
        _arrow.frame = CGRectMake(0, 0, 20, 20);
        _arrow.contentsGravity = kCAGravityResizeAspect;
        _arrow.contents = (id)[UIImage imageWithCGImage:[UIImage imageNamed:@"blueArrow.png"].CGImage scale:1 orientation:UIImageOrientationDown].CGImage;
        [self.layer addSublayer:_arrow];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        [_activityView release];
        
        [self layouts];
    }
    return self;   
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layouts {
    CGSize size = self.frame.size;
    CGRect stateFrame,dateFrame,arrowFrame;
    
    float x = 0,y,margin;
    //    x = 0;
    margin = (kPROffsetY - 2*kPRLabelHeight)/2;
    if (self.isAtTop) {
        y = size.height - margin - kPRLabelHeight;
        dateFrame = CGRectMake(0,y,size.width,kPRLabelHeight);
        
        y = y - kPRLabelHeight;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        
        x = kPRMargin;
        y = size.height - margin - kPRArrowHeight;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
        UIImage *arrow = [UIImage imageNamed:@"blueArrow"];
        _arrow.contents = (id)arrow.CGImage;
        
    } else {    //at bottom
        y = margin;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight );
        
        y = y + kPRLabelHeight;
        dateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        x = kPRMargin;
        y = margin;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
        UIImage *arrow = [UIImage imageNamed:@"blueArrowDown"];        
        _arrow.contents = (id)arrow.CGImage;
        _stateLabel.text = NSLocalizedString(@"上拉加载", @"");
    }
    
    _stateLabel.frame = stateFrame;
    _dateLabel.frame = dateFrame;
    _arrowView.frame = arrowFrame;
    _activityView.center = _arrowView.center;
    _arrow.frame = arrowFrame;
    _arrow.transform = CATransform3DIdentity;
}

- (void)dealloc {
//    [_arrowView release];
    [super dealloc];
}

@end
