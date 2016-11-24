//
//  PayOutViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectSafeProblemViewDelegate.h"
#import "PayOutViewControllerDelegate.h"


@class SafeProblemPopView;
@class PayOutViewControllerDelegate;

@interface PayOutViewController : UIViewController<ASIHTTPRequestDelegate, SelectSafeProblemViewDelegate, UITextFieldDelegate, CustomAlertViewDelegate> {
    UILabel *_bankNameLabel;             /**< 银行名称 */
    UILabel *_openAccountAddressLabel;   /**< 开户地点 */
    UILabel *_openAccountFullNameLabel;  /**< 开户行全称 */
    UILabel *_bankCardNumberLabel;       /**< 银行卡号 */
    UILabel *_payeeNameLabel;            /**< 收款人 */
    
    UITextField *_payoutCountTextField;             /**< 提现金额 */
    UITextField *_safeProblemTextField;             /**< 安全问题 */
    UITextField *_answerTextField;                  /**< 答案 */
    
    UILabel *_customerServiceLabel;     /***< 客服信息 */
    UILabel *_payoutCountPromptLabel;   /***< 提款类型文案 */
    NSInteger _isHandselDrawing;        /**< 是否允许彩金提款  0:不允许; 1:允许 */
    
    id<PayOutViewControllerDelegate> _delegate;
    
    CGRect       _editTextFieldRect;
    
    NSInteger    _selectIndex;           /**< 安全问题的索引 */
    NSInteger    _selectIndex1;          /**< 提款类型的索引 */
    BOOL         _withdrawalsing;
    NSMutableDictionary *_questionDict;
    
    ASIFormDataRequest *_loadBankInfoRequest;
    ASIFormDataRequest *_customerServiceRequest;
    ASIFormDataRequest *_httpRequest;
    
    BOOL _controlCanTouch;
}

@property (nonatomic, assign) id<PayOutViewControllerDelegate> delegate;

- (id)initWithDic:(NSDictionary *)cardDic;

@end
