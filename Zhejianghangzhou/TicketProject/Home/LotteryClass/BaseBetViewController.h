//
//  BaseBetViewController.h
//  TicketProject
//
//  Created by Michael on 8/31/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//

#define kTableViewFootViewHeight (IS_PHONE ? 53.0f : 80.0f)
#define tableCellHeihgt (IS_PHONE ? 44.0f : 72.0f)
#define tableCellLabelHeight (IS_PHONE ? 20.0f : 35.0f)
#define tabelCellLabelImageInterval (IS_PHONE ? 5.0f : 10.0f)

#import <UIKit/UIKit.h>
#import "BetButtomViewDelegate.h"
#import "CustomAlertViewDelegate.h"
#import "SelectBallsDetailViewControllerDelegate.h"
#import "UserLoginViewControllerDelegate.h"


@class AppDelegate;
@class BetButtomView;
@class Globals;
@class SetIssueAndTimeView;

@interface BaseBetViewController : UIViewController<UIActionSheetDelegate, UIAlertViewDelegate, BetButtomViewDelegate,UITableViewDataSource, UITableViewDelegate, SelectBallsDetailViewControllerDelegate, ASIHTTPRequestDelegate, UIScrollViewDelegate, UIAlertViewDelegate,UIScrollViewDelegate,CustomAlertViewDelegate> {
    
    UITableView         *_tableViews;        /**< 表格显示所有的所选号码 */
    UIButton            *_autoAddBtn;        /**< 机选按钮 */
    BetButtomView       *_bottomView;        /**< 页面底部试图 */
    SetIssueAndTimeView *_issueView;         /**< 追号倍投视图 */
    
    NSDictionary        *_lotteryDic;        /**< 彩种信息 */
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    ASIFormDataRequest  *_dataRequest;       /**< 购买请求 */
    ASIFormDataRequest  *_launchChippedProportionRequest;
    
    NSMutableDictionary *_orderDetailDict;   /**< 购买成功后该订单的详情 */
    NSInteger            _betCount;          /**< 总注数 */
    NSString            *_playtype;          /**< 玩法名称 */
    NSInteger            _playMethodID;      /**< 玩法ID */
    BOOL                 _isSupportShake;    /**< 是否支持机选功能 */
    BOOL                 _hasChaseView;      /**< 是否有追号视图 */
    BOOL                 _isRecordView;      /**< 是否在选号页面进来的 */
    BOOL                 _requestData;
    BOOL                 _hasWinStopView;
    BOOL                 _pushViewBegin;
    NSInteger            _multiple;
    
    NSString        *_secrecyLevel;     /**< 保密数值 */
    NSString        *_description;      /**< 宣言内容 */

}
@property (nonatomic, assign) NSInteger multiple;

/**
 * 已选的投注的所有号码字典
 */
@property (nonatomic,retain) NSMutableDictionary *betInfoDic;
/**
 *  追期数组，能追多少期
 */
@property (nonatomic,retain) NSArray *chaseList;

@property (nonatomic,assign) BOOL luckyNumber;
/**
 *  初始化类
 *
 *  @param infoDic 彩种信息
 *  @param dic     已选的投注方案
 *  @param flag    是否支持机选
 *
 *  @return id
 */
- (id)initWithBallsInfoDic:(NSMutableDictionary *)infoDic LotteryDic:(NSDictionary *)dic isSupportShake:(BOOL)flag;
/**
 *  初始化类
 *
 *  @param infoDic 彩种信息
 *  @param dic     已选的投注方案
 *  @param flag    是否支持机选
 *  @param isRecordView 是否在选号页面进入
 *
 *  @return id
 */
- (id)initWithBallsInfoDic:(NSMutableDictionary *)infoDic LotteryDic:(NSDictionary *)dic isSupportShake:(BOOL)flag isRecordView:(BOOL)isRecordView;
/**
 *  一个数组
 *
 *  @param sende UIButton
 */
- (void)backToHome:(id)sende;
/**
 *  自选机选按钮事件
 *
 *  @param sender UIButton
 */
- (void)handAddBalls:(id)sender;
- (void)autoAddBalls:(id)sender;
/**
 *  发起付款请求时
 *
 *  @return 购买请求的参数
 */
- (NSDictionary *)combineInfosOfPayoff;

/**
 *  获取追号内容的json字符串
 *
 *  @return 一个数组
 */
- (NSArray *)getChaseListString;
/**
 *  进行合买时组织info
 *
 *  @return 一个数组
 */
- (NSArray *)getBuyContentString;
/**
 *  计算总金额和总注数
 *
 *  @return 注数
 */
- (NSInteger)calculateTotalAmountAndBetCounts;
/**
 *  更新底部试图
 */
- (void)updateBetCountOfBottomView;

- (void)reloadtableViews;


@end
