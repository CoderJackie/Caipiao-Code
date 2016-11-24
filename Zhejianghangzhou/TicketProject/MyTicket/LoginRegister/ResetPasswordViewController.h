//
//  ResetPasswordViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CaptchaCountDownButton;


@interface ResetPasswordViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate> {
    UITextField *_newPasswordField;         /**< 重置密码输入框 */
    UITextField *_newPasswordConfirmField;  /**< 重置密码确认输入框 */
    UITextField *_captchaField;             /**< 验证码输入框 */
    CaptchaCountDownButton    *_getCaptchaButton;         /**< 获取验证码按钮 */
    
    ASIFormDataRequest *_httpRequest;
    ASIFormDataRequest *_updatePasswordRequest;
    
    AppDelegate        *_appDelegate;
    Globals            *_globals;
    
    NSString *_phoneNumber;
}

- (id)initWithPhoneNumber:(NSString *)phoneNumber;

@end
