//
//  NotificationDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-9.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface NotificationDetailViewController : UIViewController<PullingRefreshTableViewDelegate, UITableViewDataSource ,UITableViewDelegate ,ASIHTTPRequestDelegate> {
    PullingRefreshTableView *_detailTableView;  /**< 彩种开奖表格视图 */
    
    NSMutableDictionary *_dropDic;     /**< 记录每个section下拉和收缩状态的字典 */
    NSMutableArray      *_detailArray; /**< 获取每期详细信息开奖详情 */
    NSMutableDictionary *_matchDic;    /**< 比赛字典  count对应tableView的section */
    NSMutableArray      *_datehArray;  /**< 日期数组 */
    
    NSInteger _lotteryId;               /**< 比赛字典  count对应tableView的section 彩种ID */
    NSInteger _pageIndex;               /**< 存储的比赛页数 */
    
    ASIFormDataRequest *_httpRequest;   /**< 普通彩种请求 */
    ASIFormDataRequest *_jcRequest;     /**< 竞技彩种请求 */
    
    
    /*第二隐藏视图部分*/
    UILabel     *_seleCountLabel;       /**< 中部 － 本期销量 */
    UILabel     *_poolCountLabel;       /**< 中部 － 奖池奖金 */
    UIButton    *_touZhuBtn;            /**< 底部 － 投注按钮 */
    
    UIView      *_dateBg;               
    UIView      *_dateView;             /**< 日期筛选视图 */
    NSString    *_selectDateStr;        /**< 筛选时间字符串 */
    
    AppDelegate *_appDelegate; /**< 整个程序的代理 */
    Globals     *_globals;     /**< 全局类 */
    
    NSArray        *_nameArray;            /**< 彩种名称 */
    NSArray        *_lotteryIDArray;       /**< 彩种ID列表 */
    NSArray        *_imageArray;           /**< 彩种logo */
    NSArray        *_commonBonusNames;     /**< 彩种的奖项名列表 */
    NSArray        *_bonusArray;
    NSMutableArray *_sslArray;             /**< 时时乐 */
    NSDictionary   *_detailDic;            /**<  */
    NSInteger       _index;                /**< 根据彩种ID的位置 获取彩种名称和logo */
    NSString       *_bottomBetButtonName;  /**<  */
    NSString       *_lotteryName;
    BOOL            _isQuickLotteryView;
    BOOL            _pushView;
    
    NSMutableArray *_selectArray;
}

- (id)initWithLotteryId:(NSInteger)lotteryID andLotteryName:(NSString *)lotteryname;

@end
