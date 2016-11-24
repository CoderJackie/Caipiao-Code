//
//  UserPhoneRegisteViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CaptchaCountDownButton;

@interface UserPhoneRegisteViewController : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate, UIGestureRecognizerDelegate> {
    
    UITextField *_userNameField;       /**< 账号输入框 */
    UITextField *_userPhoneNumberField;       /**< 账号输入框 */
    UITextField *_passwordField;       /**< 密码输入框 */
    UITextField *_captchaField;        /**< 确认密码输入框 */
    UITextField *_qqNumberField;       /**< qq输入框 */
    CaptchaCountDownButton    *_getCaptchaButton;    /**< 获取验证码按钮 */
    UIImageView *qqNumberImageView;
    
    ASIFormDataRequest *_httpRequest;
    ASIFormDataRequest *_userRegisteRequest;
    ASIFormDataRequest *_verifyPhoneRequest;
    
    NSString *_phoneNumber;
    NSString *_password;
    NSMutableDictionary *_userInfoDictionary;
    
    UIButton         *registeButton;
    UIButton         *_promptButton;
    UIImageView      *captchaImageView;
    UILabel          *protocolPromptLabel;
    UIButton         *registeProtocolButton;
}

@end
