//
//  CaptchaCountDownButton.m  获取短信验证码倒计时的按钮
//  TicketProject
//
//  Created by KAI on 15-1-22.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "CaptchaCountDownButton.h"
#import "AppDelegate.h"

#import "Globals.h"

#pragma mark -
#pragma mark @implementation CaptchaCountDownButton
@implementation CaptchaCountDownButton
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"greenButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
        _canSendRequest = YES;
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _globals = _appDelegate.globals;
        _sendNoteCanUserTime = _globals.sendNoteCanUserTime;
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    [self clearHTTPRequest];
    [_registeRequestPhoneNumber release];
    _registeRequestPhoneNumber = nil;
    [_timer invalidate];
    _timer = nil;
    [super dealloc];
}

- (void)makeSubView {
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [_timeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [self addSubview:_timeLabel];
    [_timeLabel release];
    
    [self runLoopTime];
}

#pragma mark -
#pragma mark -Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {

}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    
    if(responseDic && [[responseDic stringForKey:@"msg"] isEqualToString:@""]) {
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic stringForKey:@"msg"]];
    }
}

#pragma mark -
#pragma mark -Customized(Action)

#pragma mark -Customized: Private (General)
- (void)requestNoteWithPhoneNumber:(NSString *)phoneNumber {
    if (_canSendRequest) {
        [_registeRequestPhoneNumber release];
        _registeRequestPhoneNumber = nil;
        _registeRequestPhoneNumber = [phoneNumber copy];
        if (_registeRequestPhoneNumber.length != 11) {
            [Globals alertWithMessage:@"请输入正确的手机号码"];
            return;
        }
        NSString *regex = @"^1[0-9]+$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if(![pred evaluateWithObject:_registeRequestPhoneNumber]) {
            [Globals alertWithMessage:@"请输入正确的手机号码"];
            return;
        }
        
        NSTimeInterval nowInterval = [NSDate timeIntervalSinceReferenceDate];
        _globals.sendNoteCanUserTime = nowInterval + 61.0f;
        _sendNoteCanUserTime = _globals.sendNoteCanUserTime;
        
        
        [self clearHTTPRequest];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:_registeRequestPhoneNumber forKey:@"mobile"];
        
        _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetPhoneNumberCaptcha userId:@"-1" infoDict:dict]];
        [_httpRequest setDelegate:self];
        [_httpRequest startAsynchronous];
        
        [self runLoopTime];
    }
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)runLoopTime {
    NSTimeInterval nowInterval = [NSDate timeIntervalSinceReferenceDate];
    if ((_sendNoteCanUserTime - nowInterval) > 0) {
        NSString *timeString = [NSString stringWithFormat:@"%ld秒",(long)(_sendNoteCanUserTime - nowInterval)] ;
        [_timeLabel setText:timeString];
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateNoteRequestText:) userInfo:nil repeats:YES];
        _canSendRequest = NO;
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    } else {
        [_timeLabel setText:@"获取验证码"];
        _canSendRequest = YES;
    }
}

-(void)updateNoteRequestText:(NSTimer *)timer {
    NSTimeInterval nowInterval = [NSDate timeIntervalSinceReferenceDate];
    if ((_sendNoteCanUserTime - nowInterval) > 0) {
        NSString *timeString = [NSString stringWithFormat:@"%ld秒",(long)(_sendNoteCanUserTime - nowInterval)] ;
        [_timeLabel setText:timeString];
        _canSendRequest = NO;
    } else {
        [_timeLabel setText:@"获取验证码"];
        _canSendRequest = YES;
        [_timer invalidate];
        _timer = nil;
    }
}
@end
