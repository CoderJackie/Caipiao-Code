//
//  AccountDetailViewController.h
//  TicketProject
//
//  Created by kiu on 15/7/13.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CapitalViewDelegate.h"
#import "CustomSwitchViewDelegate.h"
#import "MyTool.h"
#import "DialogDatePickerViewDelegate.h"

@class CapitalRecordView;
@class CustomSwitchView;

@interface AccountDetailViewController : UIViewController<DialogDatePickerViewDelegate, ASIHTTPRequestDelegate, CapitalViewDelegate, UIScrollViewDelegate, CustomSwitchViewDelegate>{
    UIScrollView   *_scroll;
    NSMutableArray *_arrCapitalRecordView;  /**< 各个订单视图 */
    NSArray        *_lableTitleArray;   /**< 各个订单标题 */
    CustomSwitchView *_switchView;
    
    NSInteger   _indexPage;   /**< 查看页数 */
    OrderStatus _orderStatus; /**< 彩票订单状态 */
    
    ASIFormDataRequest *_httpRequest;
    
    NSDictionary   *_selectRowDic;        /**< 筛选的日期 */
    NSString       *_selectYear;          /**< 筛选的年 */
    NSString       *_selectMonth;         /**< 筛选的月 */
    NSString       *_startDate;           /**< 筛选的开始时间 */
    NSString       *_endDate;             /**< 筛选的结束时间 */
}

@end
