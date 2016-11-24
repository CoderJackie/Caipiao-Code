//
//  ChaseDetailViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-18.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetRecordViewDelegate.h"



@interface ChaseDetailViewController : UIViewController<ASIHTTPRequestDelegate,UITableViewDataSource,UITableViewDelegate> {
    UIScrollView *_scrollView;        /**< 整个滑动视图 */
    UIImageView  *_logoImageView;     /**< 彩种图标 */
    UILabel      *_lotteryNameLabel;  /**< 彩种名 */
    UILabel      *_sumIssueLabel;
    
    UILabel     *_solutionSumLabel;   /**< 订单金额 */
    UILabel     *_orderStatusLabel;   /**< 订单状态 */
    UILabel     *_betCountLabel;      /**< 奖金 */
    
    UITableView *_detailTableView;
    
    UILabel     *_completedLabel;                 /**< 完成提示分隔label */
    UIImageView *_unCompletedLabelBackImageView;  /**< 未完成提示分隔label背景图 */
    UILabel     *_unCompletedLabel;               /**< 未完成提示分隔label */

    ASIFormDataRequest *_httpRequest;
    
    NSMutableDictionary  *_dropDic;            /**< 记录每个section下拉和收缩状态的字典 */
    NSMutableDictionary *_responseDict;
    NSDictionary *_detailDic;      /**< 追号投注信息 */
    NSArray      *_lotteryIDArray; /**< 彩种id数组 */
    NSArray      *_imageArray;     /**< 各个彩种图标数组 */
    NSInteger     _indexPage;      /**< 上一个页面的页数 */
    NSInteger     _lotteryID;      /**< 彩种id */
    NSInteger     _oneIssueMoney;
    
    NSInteger     _firstSectionNum;
    NSInteger     _secondSectionNum;
    
    BOOL          _originalTabBarState;
}

-(id)initWithInfoDic:(NSDictionary *)infoDic indexPage:(BetRecordType)index;

@end
