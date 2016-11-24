//
//  ActivImageView.m  带有风火轮的图像控件
//  CarPooling
//
//  Created by KAI on 15-1-31.
//  Copyright (c) 2015年 KAI. All rights reserved.
//

#import "ActivImageView.h"
#import "CustomProgressView.h"

@implementation ActivImageView
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize progressView = _progressView;
@synthesize progressLabel = _progressLabel;

#pragma mark Lifecircle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubView];
    }
    return self;
}

- (void)makeSubView {
    //activityIndicatorView 风火轮，在界面的正中间
    CGRect activityIndicatorViewRect = CGRectMake(CGRectGetWidth(self.frame) / 2 - 10.0f, CGRectGetHeight(self.frame) / 2 - 10.0f, 20.0f, 20.0f);
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:activityIndicatorViewRect];
    [_activityIndicatorView setHidesWhenStopped:YES];
    [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:_activityIndicatorView];
    [_activityIndicatorView release];
    
    //progressView 进度指示
    CGRect progressViewRect = CGRectMake(CGRectGetWidth(self.bounds) / 5, CGRectGetHeight(self.bounds) * 3 / 4, CGRectGetWidth(self.bounds) * 3 / 5, 10.0f);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        _progressView = [[UIProgressView alloc] initWithFrame:progressViewRect];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 12.0f);
        [_progressView setTransform:transform];
        [_progressView setProgressViewStyle:UIProgressViewStyleBar];
        [_progressView setProgressTintColor:[UIColor greenColor]];
        [_progressView setTrackTintColor:[UIColor grayColor]];
    } else {
        _progressView = [[CustomProgressView alloc] initWithFrame:progressViewRect];
        [_progressView setProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTintColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.7f]];
        [[_progressView layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_progressView layer] setBorderWidth:1.0f];
        [[_progressView layer] setCornerRadius:5.0f];
    }
    
    [_progressView setHidden:YES];
    [self addSubview:_progressView];
    [_progressView release];
    
    //progressLabel 进度文字
    CGRect progressLabelRect = CGRectMake(CGRectGetMinX(progressViewRect), CGRectGetMaxY(progressViewRect) + 5.0f, CGRectGetWidth(progressViewRect), 15.0f);
    _progressLabel = [[UILabel alloc] initWithFrame:progressLabelRect];
    [_progressLabel setBackgroundColor:[UIColor clearColor]];
    [_progressLabel setTextColor:[UIColor whiteColor]];
    [_progressLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_progressLabel setTextAlignment:NSTextAlignmentCenter];
    [_progressLabel setHidden:YES];
    [self addSubview:_progressLabel];
    [_progressLabel release];
}

- (void)dealloc {
    _activityIndicatorView = nil;
    _progressView = nil;
    _progressLabel = nil;
    [super dealloc];
}

#pragma mark setters
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect activityIndicatorViewRect = CGRectMake(CGRectGetWidth(frame) / 2 - 10.0f, CGRectGetHeight(frame) / 2 - 10.0f, 20.0f, 20.0f);
    [_activityIndicatorView setFrame:activityIndicatorViewRect];
    
    CGRect progressViewRect = CGRectMake(CGRectGetWidth(self.bounds) / 6, CGRectGetHeight(self.bounds) * 3 / 4, CGRectGetWidth(self.bounds) * 2 / 3, 10.0f);
    [_progressView setFrame:progressViewRect];
    
    CGRect progressLabelRect = CGRectMake(CGRectGetMinX(progressViewRect), CGRectGetMaxY(progressViewRect) + 5.0f, CGRectGetWidth(progressViewRect), 15.0f);
    [_progressLabel setFrame:progressLabelRect];
}

#pragma mark customized: Public (general)
- (void)startActivityAnimating {
    [_activityIndicatorView startAnimating];
}

- (void)stopActivityAnimating {
    [_activityIndicatorView stopAnimating];
}

- (void)setactivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)_style {
    _activityIndicatorView.activityIndicatorViewStyle = _style;
}

- (void)setProgress:(NSInteger)current total:(NSInteger)total {
    if (current > 0 && total > 0) {
        CGFloat progress = (CGFloat)current / (CGFloat)total;
        if (progress > 1) {
            progress = 1;
        }
        _progressView.progress = progress;
        NSString *currentStr = (current <= 1000 ? [NSString stringWithFormat:@"%ld b", (long)current]: [NSString stringWithFormat:@"%.2f k", current / 1000.0f]);
        NSString *totalStr = (total <= 1000 ? [NSString stringWithFormat:@"%ld b", (long)total]: [NSString stringWithFormat:@"%.2f k", total / 1000.0f]);
        _progressLabel.text = [NSString stringWithFormat:@"%@ / %@", currentStr, totalStr];
    } else {
        _progressView.progress = 0.00f;
        _progressLabel.text = @"正在下载";
    }
}

- (void)setProgressHidden:(BOOL)hidden {
    _progressLabel.hidden = hidden;
    _progressView.hidden = hidden;
}
- (void)fakeFromSuperview{
    [_progressLabel removeFromSuperview] ;
    [_progressView removeFromSuperview];
    [_activityIndicatorView removeFromSuperview];
    _progressView = nil;
    _progressLabel = nil;
    _activityIndicatorView = nil;
}

- (void)setProgressLabelText:(NSString *)text {
    _progressLabel.text = text;
}

- (void)setProgressViewRect:(CGRect)progressViewRect {
    _progressView.frame = progressViewRect;
    CGRect progressLabelRect1 = CGRectMake(CGRectGetMinX(progressViewRect), CGRectGetMaxY(progressViewRect) + 5.0f, CGRectGetWidth(progressViewRect), 15.0f);
    _progressLabel.frame = progressLabelRect1;
}

@end