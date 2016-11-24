//
//  ChippedDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ChippedDetailViewController : UIViewController<ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    UIScrollView *_scrollView;        /**< 整个滑动视图 */
    UIImageView  *_logoImageView;     /**< 彩种图标 */
    UILabel      *_lotteryNameLabel;  /**< 彩种名 */
    UILabel      *_isuseNameLabel;
    
    UILabel     *_solutionSumLabel;   /**< 订单金额 */
    UILabel     *_orderStatusLabel;   /**< 订单状态 */
    UILabel     *_betCountLabel;      /**< 奖金 */
    
    UILabel     *_initiateNameLabel;  /**< 发起人 */
    UILabel     *_betTypeLabel;       /**< 佣金比率 */
    UILabel     *_splitPlanLabel;     /**< 方案拆分 */
    UILabel     *_rengouLabel;        /**< 本次认购 */
    UILabel     *_openNumberLabel;    /**< 开奖号码 */
    
    UITableView  *_lotteryNumberTableView;
    
    UILabel     *_pickDetailsLabel;                 /**< 选号详情 */
    
    UIView      *_bottomContainView;                /**<  */
    UILabel     *_programmeTitleLabel;              /**< 方案标题 */
    UILabel     *_programContentLabel;              /**< 方案内容 */
    UILabel     *_nextSingleTimeLabel;              /**< 下单时间 */
    UILabel     *_orderNumberLabel;                 /**< 订单号 */
    
    NSMutableDictionary  *_dropDic;                 /**< 记录每个section下拉和收缩状态的字典 */
    NSMutableArray       *_matchDeitalArray;
    NSArray              *_promptLabelTitleArray;           /**< 竞彩未优化数据表格头部标签 */
    NSArray              *_optimizationLabelTitleArray;           /**< 竞彩优化后数据表格头部标签 */
    NSMutableDictionary  *_numberDict;              /**< 处理后的投注选号字典 */
    NSDictionary *_detailDic;                       /**< 合买投注信息 */
    NSArray      *_lotteryIDArray;                  /**< 彩种id数组 */
    NSArray      *_imageArray;                      /**< 各个彩种图标数组 */
    NSString     *_lotteryID;                       /**< 彩种ID,追号的时候，进来不一定有彩种ID */
    
    ASIFormDataRequest *_jcRequest;
    ASIFormDataRequest *_httpRequest;               /**< 获取竞彩对阵投注接口 */
    AppDelegate        *_appDelegate;
    Globals            *_globals;
    
    BOOL                _pushView;
    BOOL                _originalTabBarState;
}

- (id)initWithInfoDic:(NSDictionary *)infoDic;

@end
