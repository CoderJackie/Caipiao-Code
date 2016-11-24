//
//  BetRecordView.h
//  TicketProject
//
//  Created by md005 on 13-9-4.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetRecordViewDelegate.h"
#import "MyTool.h"


@interface BetRecordView : UIView<UITableViewDataSource, UITableViewDelegate, PullingRefreshTableViewDelegate, ASIHTTPRequestDelegate> {
    
    PullingRefreshTableView *_m_tableView;  /**< 上下刷新用的视图 */
    
    ASIFormDataRequest      *_httpRequest;
    id<BetRecordViewDelegate> _delegate;
    
    NSMutableArray      *_schemeList; /**< 自己的订单信息组合 */
    NSArray             *_lotteryIDArray;
    NSArray             *_lotteryNameArray;
    BOOL        _isAddMore;        /**< 是否添加数据 */
    BOOL        _isFirstLoading;
    NSInteger   _m_status;         /**< 订单状态 */
    NSInteger   _indexPage;        /**< 原目前订单页，indexPage为2时，表示是追号订单，需要特殊处理，服务器返回的数据不一样 */
    NSInteger   _page;             /**< 订单页数 */
    
}

@property (nonatomic, assign) id <BetRecordViewDelegate> delegate;

@property (nonatomic, assign) NSInteger indexPage;

- (id)initWithFrame:(CGRect)frame status:(OrderStatus)status indexPage:(NSInteger)index;

- (void)loadInitData;

- (void)cancleRequest;

@end
