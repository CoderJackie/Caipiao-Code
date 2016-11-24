//
//  CapitalDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogDatePickerViewDelegate.h"


@class DialogDatePickerView;

@interface CapitalDetailViewController : UIViewController<DialogDatePickerViewDelegate, ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, PullingRefreshTableViewDelegate> {
    UILabel *_dateLabel;           /**< 日期 */
    UILabel *_sumIncomeLabel;      /**< 总收入 */
    UILabel *_sumExpendLabel;      /**< 总支出 */
    UILabel *_sumWinningLabel;     /**< 中奖 */
    
    UIButton *_allTypeBtn;         /**< 全部类型按钮 */
    UIButton *_incomeBtn;          /**< 收入按钮 */
    UIButton *_enpendBtn;          /**< 支出按钮 */
    
    UITextField *_amountTextField; /**< 金额 */
    UITextField *_typeTextField;   /**< 类型 */
    UITextField *_timeTextField;   /**< 时间 */
    UITextField *_memoTextField;   /**< 摘要 */
    
    MBProgressHUD           *_progressHud;   /**< 加载过程提示 */
    PullingRefreshTableView *_infoTableView; /**< 上下刷新表格 */
    
    ASIFormDataRequest *_httpRequest;
    
    NSInteger       _pageIndex;           /**< 资金详细请求页数 */
    NSString       *_searchIndex;         /**< 查询的类型  -1 表示查询全部， 1 表示查询收入， 2 表示查询支出 */
    BOOL            _changeTotalAccount;  /**< 改变总收入等，就是第一次请求的时候或者改变日期请求的时候需要改变 */
    NSMutableArray *_recordsArray;        /**< 资金详细数组 */
    NSDictionary   *_detailDic;           /**< 从服务器返回的详情字典 */
    NSDictionary   *_selectRowDic;        /**< 筛选的日期 */
    NSString       *_selectYear;          /**< 筛选的年 */
    NSString       *_selectMonth;         /**< 筛选的月 */
    NSString       *_startDate;           /**< 筛选的开始时间 */
    NSString       *_endDate;             /**< 筛选的结束时间 */
}


@end
