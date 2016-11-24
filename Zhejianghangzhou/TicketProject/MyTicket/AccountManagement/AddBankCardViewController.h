//
//  AddBankCardViewController.h
//  TicketProject
//
//  Created by jsonLuo on 16/9/23.
//  Copyright © 2016年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectSafeProblemViewDelegate.h"
#import "SelectViewControllerDelegate.h"
#import "PhoneVerificationViewControllerDelegate.h"

@interface AddBankCardViewController : UIViewController<ASIHTTPRequestDelegate, SelectSafeProblemViewDelegate, PhoneVerificationViewControllerDelegate, SelectViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CustomAlertViewDelegate>

/**isDetail：是否是详情界面   info：银行卡信息    succeed：成功回调*/
- (instancetype)initWithisDetail:(BOOL)isDetail info:(NSDictionary *)info succeed:(void(^)())succeed;

@end
