//
//  AccountInfoViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectSafeProblemViewDelegate.h"
#import "SelectViewControllerDelegate.h"
#import "PhoneVerificationViewControllerDelegate.h"

@class MSKeyboardScrollView;

@interface AccountInfoViewController : UIViewController<ASIHTTPRequestDelegate, SelectSafeProblemViewDelegate, PhoneVerificationViewControllerDelegate, SelectViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CustomAlertViewDelegate> {
    
    MSKeyboardScrollView *_scrollView;
    
    UILabel      *_phoneLabel;              /**< 电话号码 */
    UIButton     *_phoneCaptchaBtn;         /**< 电话号码 */
    UIImageView  *_phoneCaptchaLeftSignImageView;
    UITextField  *_userNameTextField;       /**< 用户名 */
    UITextField  *_qqTextField;             /**< qq */
    
    UIImageView  *_secondBackImageView;     /**< 第二背景图 */
    
    UITextField  *_realNameTextField;       /**< 真实姓名 */
    UITextField  *_cardNumberTextField;     /**< 身份证号 */
    UILabel      *_bankNameLabel;           /**< 银行名称 */
    UIButton     *_bankNameSelectBtn;
    UIImageView  *_bankNameLeftSignImageView;
    
    NSInteger    securityQuestionId;             //问题编号
    
    UILabel      *_openAccountAddressLabel;     /**< 开户地点 */
    UIButton     *_openAccountAddressBtn;
    UIImageView  *_openAccountAddressLeftSignImageView;
    
    UITextField  *_openAccountFullNameTextField; /**< 开户行全称 */
    
    UITextField  *_bankCardNumberTextField;      /**< 银行卡号 */
    UITextField  *_saftProblemTextField;         /**< 安全问题 */
    
    UITextField  *_answerTextField;              /**< 安全问题答案 */
    
    
    UILabel      *_customerServiceLabel;         /***< 客服信息 */
    UIButton     *_perfectBtn;                   /**< 完善信息按钮 */
    
    
    NSInteger     _selectSafeProblemIndex;
    NSDictionary *_bankDict;
    NSDictionary *_selectBankDict;
    NSDictionary *_selectProvinceCityDic;       /**<  */
    NSDictionary *_provinceDict;
    NSDictionary *_cityDict;
    NSMutableDictionary *_selectPlaceDict;
    NSMutableDictionary *_infoDict;
    NSMutableArray *_selectProvinceCitysArray;
    
    ASIFormDataRequest *_loadBankInfoRequest; /**< 获取个人绑定信息 */
    ASIFormDataRequest *_customerServiceRequest;
    ASIFormDataRequest *_httpRequest;
}

@end
