//
//  WinPopubView.m
//  TicketProject
//
//  Created by KAI on 15-1-19.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "WinPopubView.h"

#import "Globals.h"

#pragma mark -
#pragma mark @implementation WinPopubView
@implementation WinPopubView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame winMoney:(NSString *)winMoney {
    self = [super initWithFrame:frame];
    if (self) {
        _winMoney = [winMoney copy];
        [self setUserInteractionEnabled:YES];
        [self makeSubView];
        
    }
    return self;
}

- (void)dealloc {
    [_winMoney release];
    _winMoney = nil;
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat winMoneyLabelMinX = 90.0f;
    CGFloat winMoneyLabelMinY = 81.0f;
    CGFloat winMoneyLabelWidth = 102.0f;
    CGFloat winMoneyLabelHeight = 31.0f;
    
    CGFloat closeBtnMinX = 245.0f;
    CGFloat closeBtnMinY = 50.0f;
    CGFloat closeBtnSize = 27.0f;
    
    CGFloat checkButtonMinX = 90.0f;
    CGFloat checkButtonMinY = 120.0f;
    CGFloat checkButtonWidth = 77.0f;
    CGFloat checkButtonHeight = 27.0f;
    /********************** adjustment end ***************************/
    
    if (!_overlayView) {
        _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:0.5];
        
        //tap 用来收回键盘的手势点击动作
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [tap setDelegate:self];
        [_overlayView addGestureRecognizer:tap];
        [tap release];
    }
    
    //winPopubBackImageView
    CGRect winPopubBackImageViewRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    _winPopubBackImageView = [[UIImageView alloc] initWithFrame:winPopubBackImageViewRect];
    [_winPopubBackImageView setUserInteractionEnabled:YES];
    [_winPopubBackImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"winLotteryBackImageView.png"]]];
    [self addSubview:_winPopubBackImageView];
    [_winPopubBackImageView release];
    
    //winMoneyLabel
    CGRect winMoneyLabelRect = CGRectMake(winMoneyLabelMinX, winMoneyLabelMinY, winMoneyLabelWidth, winMoneyLabelHeight);
    _winMoneyLabel = [[UILabel alloc] initWithFrame:winMoneyLabelRect];
    [_winMoneyLabel setBackgroundColor:[UIColor clearColor]];
    [_winMoneyLabel setTextColor:[UIColor colorWithRed:255/255.0f green:233/255.0f blue:154/255.0f alpha:1.0f]];
    [_winMoneyLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_winMoneyLabel setTextAlignment:NSTextAlignmentCenter];
    [_winMoneyLabel setText:[NSString stringWithFormat:@"%@元",_winMoney]];
    [_winPopubBackImageView addSubview:_winMoneyLabel];
    [_winMoneyLabel release];
    
    //closeButton
    CGRect closeButtonRect = CGRectMake(closeBtnMinX, closeBtnMinY, closeBtnSize, closeBtnSize);
    UIButton *closeButton = [[UIButton alloc] initWithFrame:closeButtonRect];
    [closeButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"winLotteryCloseBtn_normal.png"]] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"winLotteryCloseBtn_highlighted.png"]] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_winPopubBackImageView addSubview:closeButton];
    [closeButton release];
    
    //checkButton
    CGRect checkButtonRect = CGRectMake(checkButtonMinX, checkButtonMinY, checkButtonWidth, checkButtonHeight);
    UIButton *checkButton = [[UIButton alloc] initWithFrame:checkButtonRect];
    [checkButton setBackgroundColor:[UIColor clearColor]];
    [checkButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"winLotteryCheckBtn_normal.png"]] forState:UIControlStateNormal];
    [checkButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"winLotteryCheckBtn_highlighted.png"]] forState:UIControlStateHighlighted];
    [checkButton addTarget:self action:@selector(checkTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_winPopubBackImageView addSubview:checkButton];
    [checkButton release];
}

#pragma mark -
#pragma mark -Customized(Action)

- (void)closeTouchUpInside:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(winPopubViewToClose)]) {
        [_delegate winPopubViewToClose];
    }
}

- (void)checkTouchUpInside:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(winPopubViewToClose)]) {
        [_delegate WinPopubViewCheckWinLottery];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(winPopubViewToClose)]) {
        [_delegate winPopubViewToClose];
    }
}

#pragma mark -Customized: Private (General)
- (void)fadeInWithFrame:(CGRect)frame sectionX:(CGFloat)sectionX maxCount:(NSInteger)maxCount {
    if (maxCount <= 0) {
        return;
    }
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setFrame:frame];
    } completion:^(BOOL finished){
        if (finished && CGRectGetMinX(frame) != ((kWinSize.width - CGRectGetWidth(frame)) / 2.0f)) {
            CGRect newFrame;
            if ((kWinSize.width - CGRectGetWidth(frame) - CGRectGetMinX(frame) * 2) > 0) {
                newFrame = CGRectMake(kWinSize.width - CGRectGetWidth(frame) - CGRectGetMinX(frame) - sectionX, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
            } else {
                newFrame = CGRectMake(kWinSize.width - CGRectGetWidth(frame) - CGRectGetMinX(frame) + sectionX, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
            }
            [self fadeInWithFrame:newFrame sectionX:sectionX maxCount:maxCount - 1];
        }
    }];
}

- (void)fadeIn {
    NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    if ([[def objectForKey:kIsShake]integerValue] == 1)
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    [self fadeInWithFrame:CGRectMake(0, CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) sectionX:2.5 maxCount:10];
}

//消失动画
- (void)fadeOut {
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
}

- (void)removeFromSuperview {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
    [super removeFromSuperview];
}

//显示视图
- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_overlayView];
    [_overlayView release];
    [keyWindow addSubview:self];
    [self setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
    
    [self fadeIn];
}

@end
