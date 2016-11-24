//
//  TicketsDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-17.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTool.h"


@interface TicketsDetailViewController : UIViewController<ASIHTTPRequestDelegate ,UITableViewDataSource, UITableViewDelegate> {
    UIScrollView *_scrollView;        /**< 整个滑动视图 */
    
    UIImageView  *_logoImageView;     /**< 彩种图标 */
    UILabel      *_lotteryNameLabel;  /**< 彩种名 */
    UILabel      *_isuseNameLabel;
    
    UILabel      *_solutionSumLabel;   /**< 订单金额 */
    UILabel      *_orderStatusLabel;   /**< 订单状态 */
    UILabel      *_betCountLabel;      /**< 奖金 */
    
    UILabel      *_openNumberLabel;    /**< 开奖号码 */
    
    UITableView  *_lotteryNumberTableView;
    
    UILabel      *_pickDetailsLabel;   /**< 选号详情 */
    UILabel      *_betNumberLabel;     /**< 投注号码 */
    
    UIView       *_bottomContainView;  /**< 底部视图 */
    UILabel      *_nextSingleTimeLabel;/**< 下单时间 */
    UILabel      *_orderNumberLabel;   /**< 订单号 */
    
    ASIFormDataRequest *_httpRequest;                      /**< 获取竞彩对阵投注接口 */
    ASIFormDataRequest *_jcRequest;                      /**< 获取竞彩对阵投注详情接口 */
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    
    NSMutableDictionary  *_dropDic;    /**< 记录每个section下拉和收缩状态的字典 */
    NSMutableArray       *_matchDeitalArray;
    NSArray              *_promptLabelTitleArray;           /**< 竞彩未优化数据表格头部标签 */
    NSArray              *_optimizationLabelTitleArray;           /**< 竞彩优化后数据表格头部标签 */
    NSMutableDictionary  *_numberDict; /**< 处理后的投注选号字典 */
    NSDictionary *_detailDic;          /**< 普通投注信息 */
    NSArray      *_imageArray;         /**< 各个彩种图标数组 */
    NSArray      *_lotteryIDArray;     /**< 彩种id数组 */
    NSString     *_lotteryID;          /**< 彩种ID,追号的时候，进来不一定有彩种ID */

    OrderStatus   _orderStatus;
    
    BOOL          _pushView;
    BOOL          _originalTabBarState;
}

- (id)initWithInfoDic:(NSDictionary *)infoDic withLotteryID:(NSInteger)lotteryid orderStatus:(OrderStatus)status;

- (id)initWithInfoDic_forTicket:(NSDictionary *)infoDic withLotteryID:(NSInteger)lotteryid orderStatus:(OrderStatus)status;

@end
