//
//  RechargeViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPPayPluginDelegate.h"
#import "CustomLabel.h"

@interface RechargeViewController : UIViewController<ASIHTTPRequestDelegate, CustomAlertViewDelegate, UPPayPluginDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    UILabel     *_userNameLabel;     /**< 用户名 */
    UITextField *_rechargeTextField; /**< 充值金额 */
    UIAlertView *_mAlert;            /**< 银联弹出等待 */
    CustomLabel *_giftMoneyLabel;    /**< 赠送彩金 */
    
    NSString *_orderString;          /**< 订单字符串 */
    NSString *_signString;           /**< 签名字符串 */
    NSMutableString *_UPPayPluginPayString;
    NSMutableArray      *_activeList;      /**< 彩金奖励规则 */
    NSInteger _giveType;            /**< 彩金赠送方式 0：定额 ；1： 比例 */
    
    ASIFormDataRequest *_httpRequestOfUPPayPlugin;
    ASIFormDataRequest *_httpRequestOfAlixPay;
    ASIFormDataRequest *_httpRequestOfNone;      //微信充值请求
    ASIFormDataRequest *_loadHandselRequest;
    
    NSString *_rechargeMoney;
    BOOL      _naxfTabBarHiddenState;
    
    RechargeType _rechargeType;
    
    NSString *currentHandsel;       // 当前赠送彩金；
    float _numerical;               // 最高充值赠送彩金
    float _conditionHighest;        // 最高充值金额(赠送彩金)
}

- (id)initWithRechargeType:(RechargeType)rechargeType;

- (void)showAlertWait;

- (void)showAlertMessage:(NSString*)msg;

- (void)hideAlert;

@end
