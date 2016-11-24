//
//  MyTicketsViewController.h
//  SSQDemo
//
//  Created by sls002 on 13-5-16.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayOutViewControllerDelegate.h"
#import "EGORefreshTableHeaderView.h"

@class PayOutViewController;

@interface MyTicketsViewController : UIViewController<ASIHTTPRequestDelegate,PayOutViewControllerDelegate,UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate> {
    UITableView *_listTabelView;
    UILabel *_userNameLabel;       /**< 用户名 */
    UILabel *_accountBalanceLabel; /**< 账户余额 */
    UILabel *_handselLabel;        /**< 彩金 */
    UILabel *_accountFrostLabel;   /**< 账户冻结 */
    EGORefreshTableHeaderView *_refreshTableHeaderView;  /**< 刷新控件 */
    
    ASIFormDataRequest *_bindingRequest; /**< 判断是否绑定身份证信息请求 */
    ASIFormDataRequest *_httpRequest;
    
    NSArray *_imageArray;
    NSArray *_nameArray;
    
    BOOL _controlCanTouch;
    BOOL _isLoading;
}

@end
