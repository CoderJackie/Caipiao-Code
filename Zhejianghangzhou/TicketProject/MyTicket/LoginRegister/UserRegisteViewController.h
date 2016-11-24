//
//  UserRegisteViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CaptchaButton;


@interface UserRegisteViewController : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate, UIGestureRecognizerDelegate> {
    UITextField *_userNameField;       /**< 账号输入框 */
    UITextField *_passwordField;       /**< 密码输入框 */
    UITextField *_confirmationField;   /**< 确认密码输入框 */
    UITextField *_qqNumberField;       /**< QQ号输入框 */
    CaptchaButton    *_getCaptchaButton;     /**< 获取验证码按钮 */
    UILabel          *_promptLable;          /**< 密码强度提示 */
    UIButton         *_promptButton;
    
    UIImageView *confirmationImageView;
    UIImageView *qqNumberImageView;
    UIButton    *registeButton;    //注册按钮
    UILabel     *protocolPromptLabel;
    UIButton    *registeProtocolButton;
    
    ASIFormDataRequest *_httpRequest;
    
    NSMutableDictionary *_userInfoDictionary;
    
    BOOL isHidden;
}


@end
