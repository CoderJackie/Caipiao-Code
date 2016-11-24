//
//  CapitalRecordView.h
//  TicketProject
//
//  Created by kiu on 15/7/13.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapitalViewDelegate.h"
#import "MyTool.h"

@interface CapitalRecordView : UIView<UITableViewDataSource, UITableViewDelegate, PullingRefreshTableViewDelegate, ASIHTTPRequestDelegate> {
    
    PullingRefreshTableView *_m_tableView;  /**< 上下刷新用的视图 */
    
    ASIFormDataRequest      *_httpRequest;
    id<CapitalViewDelegate> _delegate;
    
    NSMutableArray      *_schemeList; /**< 自己的订单信息组合 */
    NSArray             *_lotteryIDArray;
    NSArray             *_lotteryNameArray;
    BOOL        _isAddMore;        /**< 是否添加数据 */
    BOOL        _isFirstLoading;
    NSInteger   _m_status;         /**< 订单状态 */
    NSInteger   _indexPage;        /**< 原目前订单页 */
    NSInteger   _page;             /**< 订单页数 */
    NSString       *_searchIndex;         /**< 查询的类型  -1 表示查询全部， 1 投注， 2 中奖， 3 充值， 4 提现 */
    NSString       *_startDate;           /**< 筛选的开始时间 */
    NSString       *_endDate;             /**< 筛选的结束时间 */
}

@property (nonatomic, assign) id <CapitalViewDelegate> delegate;

@property (nonatomic, assign) NSInteger indexPage;

- (id)initWithFrame:(CGRect)frame status:(OrderStatus)status indexPage:(NSInteger)index;

- (void)loadInitData;

- (void)cancleRequest;

- (void)loadDataWithStart:startTime loadDataWithEnd:endDate indexPage:(NSInteger)index;

@end
