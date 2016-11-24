//
//  PhoneVerificationViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-21.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneVerificationViewControllerDelegate.h"

@class CaptchaCountDownButton;

@interface PhoneVerificationViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, ASIHTTPRequestDelegate> {
    UITextField                  *_phoneNumberField;
    UITextField                  *_captchaField;
    CaptchaCountDownButton       *_getCaptchaButton;
    
    ASIFormDataRequest *_httpRequest;
    ASIFormDataRequest *_verificationRequest;
    
    id<PhoneVerificationViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) id<PhoneVerificationViewControllerDelegate> delegate;

@end
