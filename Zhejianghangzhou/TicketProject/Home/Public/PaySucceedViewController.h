//
//  PaySucceedViewController.h
//  TicketProject
//
//  Created by KAI on 14-11-28.
//  Copyright (c) 2014年 sls002. All rights reserved.
//
//  20150709 16:00（刘科）：修改界面UI，新增账户余额，彩金余额显示。

#import <UIKit/UIKit.h>
#import "MyTool.h"

typedef enum {
    PaySucceedViewOfNormal,
    PaySucceedViewOfChase,
    PaySucceedViewOfTogether,
} PaySucceedViewType;

@interface PaySucceedViewController : UIViewController {
    CustomLabel *_payMoneyPromptLabel;
    CustomLabel *_residualAmountLabel;       // 剩余金额
    CustomLabel *_residualHandselLabel;      // 剩余彩金
    
    ASIFormDataRequest  *_httpRequest;/**< 请求该订单的详情 */
    
    
    NSMutableDictionary *_originalDict;
    NSMutableDictionary *_orderDetailDict;
    NSMutableArray      *_checkOrderDetailArray;
    
    PaySucceedViewType   _paySucceedViewType;
    OrderStatus          _status;
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    
    NSInteger            _orderId;
    NSInteger            _lotteryId;
    BOOL                 _pushView;
}

- (id)initWithDict:(NSMutableDictionary *)dict buyType:(OrderStatus)buyType;

@property (nonatomic, assign) PaySucceedViewType paySucceedViewType;

@end
