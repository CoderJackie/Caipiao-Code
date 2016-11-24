//
//  ForgetPasswordViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-19.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CaptchaButton;

@interface ForgetPasswordViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, ASIHTTPRequestDelegate> {
    
    UITextField      *_userNameField;       /**< 账号输入框 */
    UITextField      *_captchaField;        /**< 验证码输入框 */
    CaptchaButton    *_getCaptchaButton;
    
    ASIFormDataRequest *_httpRequest;
    
}

@end
