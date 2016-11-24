//
//  CaptchaButton.h
//  TicketProject
//
//  Created by KAI on 15-1-22.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptchaButton : UIButton {
    UILabel *_captchaLabel;
    
    NSString *_captchaString;
}

@property (nonatomic , copy, readonly) NSString *captchaString;

- (BOOL)verificationCaptchaWithCaptcha:(NSString *)captcha;

@end
