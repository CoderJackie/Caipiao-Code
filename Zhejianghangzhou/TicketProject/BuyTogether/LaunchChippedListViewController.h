//
//  LaunchChippedListViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-4.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListViewDelegate.h"

#import "EGORefreshTableHeaderView.h"


@class MarqueeView;
@class SelectLotteryNameDialogView;

@interface LaunchChippedListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, DropDownListViewDelegate, EGORefreshTableHeaderDelegate> {
    
    UITableView                 *_tableListView;
    EGORefreshTableHeaderView   *_refreshTableHeaderView;
    SelectLotteryNameDialogView *_dialogView;  /**< 弹出的彩种视图 */
    SelectLotteryNameDialogView *_redlogView;  /**< 弹出的红人名字视图 */
    
    ASIFormDataRequest *_launchChippedRequest;        /**< 请求 */
    ASIFormDataRequest *_copyRequest;        /**< 请求 */
    ASIFormDataRequest *_nameRequest;        /**< 红人名字请求 */
    
    NSMutableArray *_ticketNameArray;      /**< 所有彩种名称 */
    NSMutableArray *_ticketIDArray;        /**< 所有彩种对应的ID */
    NSMutableArray *_schemeArray;          /**< 合买列表 */
    NSInteger       _selectLotteryID;      /**< 选中的彩种ID */
    NSInteger       _sortRule;             /**< 排序规则  0：按方案进度 1：按方案总金额 2：按每份金额 3：按战绩状态 */
    NSInteger       _sortType;             /**< 排序类型  0：从大到小  1：从小到大 */
    NSInteger       _pageIndex;            /**< 第几页数据 */
    NSInteger       _btnIndex;             /**< 彩种按钮的index */
    BOOL            _isAddMore;            /**< 是否增加更多数据 */
    BOOL            _hasMore;              /**< 是否有更多数据 */
    BOOL            _isLoading;
}

- (void)reloadTableViewDataSource;

@end
