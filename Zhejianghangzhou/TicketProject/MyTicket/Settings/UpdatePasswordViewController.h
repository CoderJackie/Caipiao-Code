//
//  UpdatePasswordViewController.h
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class Globals;

@interface UpdatePasswordViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, ASIHTTPRequestDelegate>{
    UITextField *_oldPasswordTextField;
    UITextField *_newPasswordTextField;
    
    AppDelegate   *_appDelegate;
    Globals       *_globals;
    
    ASIFormDataRequest *_httpRequest;
    
    UIButton *confirmBtn;
    UILabel *promptLabel;
}

@end
