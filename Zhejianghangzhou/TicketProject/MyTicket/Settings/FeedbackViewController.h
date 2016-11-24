//
//  FeedbackViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface FeedbackViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, ASIHTTPRequestDelegate, UIGestureRecognizerDelegate ,CustomAlertViewDelegate> {
    UITextField *_titleField;          /**< 反馈标题 */
    UITextView  *_suggestionTextView;  /**< 反馈意见栏 */
    UITextField *_phoneField;          /**< 联系号码 */
    UITextField *_emailField;          /**< 联系邮箱 */
    
    CGRect _editTextFieldRect;
    
    ASIFormDataRequest *_httpRequest;
    BOOL _controlCanTouch;
}

@end
