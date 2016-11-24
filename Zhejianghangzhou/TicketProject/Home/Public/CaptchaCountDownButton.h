//
//  CaptchaCountDownButton.h
//  TicketProject
//
//  Created by KAI on 15-1-22.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class Globals;

@interface CaptchaCountDownButton : UIButton <ASIHTTPRequestDelegate> {
    
    UILabel     *_timeLabel;
    
    AppDelegate        *_appDelegate;
    Globals            *_globals;
    ASIFormDataRequest *_httpRequest;
    NSTimer            *_timer;
    
    NSTimeInterval      _sendNoteCanUserTime;
    BOOL                _canSendRequest;
    NSString           *_registeRequestPhoneNumber;
}

- (void)requestNoteWithPhoneNumber:(NSString *)phoneNumber;

@end
