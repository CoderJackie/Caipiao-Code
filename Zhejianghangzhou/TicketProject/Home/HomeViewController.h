//
//  HomeViewController.h   购彩大厅 1000
//  TicketProject
//
//  Created by sls002 on 13-6-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140710 08:23（洪晓彬）：修改代码规范，改进注释和命名规范

#import <UIKit/UIKit.h>
#import "LotteryViewDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "CycleScrollView.h"


@protocol infoDicDelegate <NSObject>

- (void)infoDicValue:(NSMutableDictionary*)dic andOther:(NSArray*)array;

@end

@class AppDelegate;
@class ASINetworkQueue;
@class LotteryView;
@class MarqueeView;
@class Globals;
@class TimerLabel;

@interface HomeViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, EGORefreshTableHeaderDelegate, ASIHTTPRequestDelegate, LotteryViewDelegate> {
    UIView                    *_overlayView;             /**< 点击cell弹出提示框是否能进入下一页 */
    EGORefreshTableHeaderView *_refreshTableHeaderView;  /**< 刷新控件 */
    MarqueeView               *_lblWinInfoView;          /**< 中奖公告栏 */
    
    ASINetworkQueue     *_queue;             /**< 请求队列（普通彩种、竞彩足球、竞彩篮球三个请求）*/
    ASIFormDataRequest  *_wininfoRequest;    /**< 中奖信息的广播请求 */
    id<infoDicDelegate>  _delegate;
    
    AppDelegate         *_appDelegate;
    Globals             *_globals;
    
    NSMutableArray      *_nameArray;         /**< 彩种名称列表 */
    NSMutableArray      *_imageArray;        /**< 彩种图标列表 */
    NSMutableArray      *_lotterIDArray;     /**< 彩种ID列表 */
    NSMutableDictionary *_explanationDic;    /**< 各彩种的简单介绍（红色字体）*/
    NSMutableDictionary *_againstDic;        /**< 竞彩彩种的对阵 (显示一条在购彩大厅) */
    NSMutableDictionary *_infoDic;           /**< 从服务器获取的奖期信息 */
    NSMutableArray      *_todayOpenLotteryArray;   /**< 今日开奖数组 */
    NSTimer             *_timerWinInfo;      /**< 中奖信息轮播计时器 */
    NSString            *_serverTime;        /**< 服务器返回的系统时间 */
    NSTimeInterval      *timeInterval;
    NSString            *_winString;
    BOOL                 _isLoading;
    BOOL                 _isShowHud;         /**< 是否正在向服务器发送请求，是则显示加载提示视图 */
    BOOL                 _pushViewBegin;
    
    NSInteger            _curLotteryid;         /**< 记录当前点击的彩种ID */
    NSInteger            _curIndex;             /**< 记录当前点击彩种的索引 */
    
    UICollectionView     *_collectionView;   /**< 彩种表格视图 */
    
    NSMutableArray       *urlArray;         /**< 图片数组 */
    NSMutableArray       *openUrlArray;     /**< 图片打开数组 */
}

@property (nonatomic, retain) NSMutableDictionary   *infoDic;
@property (nonatomic, assign) id<infoDicDelegate>   delegate;
@property (nonatomic, retain) CycleScrollView       *mainScorllView;
@property (nonatomic, retain) UIView                *touview;

/** 计算距开奖时间还有多少秒
 @param  endDate   结束时间
 @return 开奖时间差 */
- (NSTimeInterval)getTimeIntervalWithEndDate:(NSDate *)endDate;

- (BOOL)judgeIsCanBetWithIndex:(NSInteger)index andID:(NSInteger)lotteryid;

- (NSInteger)findDetailIndexWithLotteryId:(NSInteger)lotteryId;

- (void)getCompetingData: (NSString *)lotteryId;

@end
