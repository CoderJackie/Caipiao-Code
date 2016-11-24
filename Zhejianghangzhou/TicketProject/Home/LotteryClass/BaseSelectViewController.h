//
//  BaseSelectViewController.h
//  TicketProject
//
//  Created by Michael on 10/9/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//

#define kCountPerLine 7  //一行多少球
#define kMaginLeftRight 15  //左右间距
#define kMaginTopBottom 15  //上下间距
#define kBallSize (IS_PHONE ? 35.0f : 55.0f) //球的宽度和高度

#define kPromptMsgLabelX 10  //每个视图的提示label
#define kPromptMsgLabelWidth 160
#define kPromptMsgLabelHeight (IS_PHONE ? 18.0f : 25.0f)

#define kLineX 10   //视图分割线
#define kLineWidth (kWinSize.width - 2 * 10)
#define kLineHeight 1

/********************** adjustment 控件调整 ***************************/
#define promptLabelMinY (IS_PHONE ? 10.0f : 15.0f)
#define firstPromptLabelWidthC (IS_PHONE ? 90.0f : 130.0f)
#define firstPromptLabelWidthA (IS_PHONE ? 90.0f : 130.0f)
#define firstPromptLabelWidthB (IS_PHONE ? 90.0f : 130.0f)
#define lastPromptLabelWidth (IS_PHONE ? 200.0f : 300.0f)

#define AotoSelectViewIntervalRight (IS_PHONE ? 10.0f : 20.0f) //随机选择框与右边屏幕边框的距离
#define AotoSelectViewMinY (IS_PHONE ? 5.0f : 10.0f)
#define AotoSelectViewWidht (IS_PHONE ? 125.0f : 200.0f) //随机选择框的宽度
#define AotoSelectViewHeight (IS_PHONE ? 30.0f : 45.0f) //随机选择框的高度
/********************** adjustment end ***************************/

#import <UIKit/UIKit.h>
#import "SelectBallBottomViewDelegate.h"
#import "SelectBallsDetailViewControllerDelegate.h"
#import "BetTypeDropDownListView.h"


@class AppDelegate;
@class CustomLabel;
@class Globals;
@class SelectBallBottomView;
@class TimerLabel;
@class ASINetworkQueue;

@interface BaseSelectViewController : UIViewController<SelectBallBottomViewDelegate, UIAccelerometerDelegate,DropDownListViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate> {
    
    UIView                  *_header;                           /**< 开奖信息背景 */
    CustomLabel             *_lastWinNumLabel;                  /**< 红蓝色开奖label */
    UILabel                 *_lastWinNumlabels;                 /**< 红色开奖label */
    UILabel                 *_lassWinNumlabels;                 /**< 快三开奖label */
    UIScrollView            *_scrollView;                       /**< 选球界面 */
    SelectBallBottomView    *_bottomView;                       /**< 底部导航试图 */
    
    UIViewController        *_betViewController;                /**< 投注界面的viewcontroller */
    
    Globals                 *_globals;                          /**< 全局控制类 */
    AppDelegate             *_appDelegate;                      /**< app代理 */
    id<SelectBallsDetailViewControllerDelegate> _baseDelegate;
    
    NSInteger               _lotteryID;                         /**< 彩种ID */
    NSInteger               _playMethodID;                      /**< 玩法ID */
    NSInteger               _totalBetCount;                     /**< 每一次的总注数 */
    NSInteger               _specifiedIndex;                    /**< 反选投注，指定的某一条投注内容 */
    NSInteger               _btnIndex;                          /**< 玩法按钮的index */
    NSString                *_selectBetType;                    /**< 所选投注方式 */
    BOOL                    _isSupportShake;                    /**< 是否支持机选 */
    BOOL                    _isPresentView;                     /**< 是否Present视图 */
    BOOL                    _pushViewBegin;
    
    NSMutableArray          *_betTypeArray;                     /**< 投注方式数组(用于初始化下拉列表) */
    
    NSDictionary            *_selectedBallsDic;                 /**< 投注页面tableview的详细内容，用于反选时 */
    NSDictionary            *_zixuanBallsDic;                   /**< 用于自选时 */
    NSDictionary            *_lotteryDic;                       /**< 彩票信息 */
    
    UIView                  *_oneView;
    NSString                *_oneViewPromptString;
    
    UIView                  *_twoView;
    NSString                *_twoViewPromptString;
    
    UIView                  *_threeView;
    NSString                *_threeViewPromptString;
    
    UIView                  *_fourView;
    NSString                *_fourViewPromptString;
    
    UIView                  *_fiveView;
    NSString                *_fiveViewPromptString;
    
    UIView                  *_sixView;
    UIView                  *_sevenView;
    
    NSMutableArray          *_oneArray;
    NSMutableArray          *_twoArray;
    NSMutableArray          *_threeArray;
    NSMutableArray          *_fourArray;
    NSMutableArray          *_fiveArray;
    NSMutableArray          *_sixArray;
    NSMutableArray          *_sevenArray;
    
    BOOL                    _isQuickLotteryView;                //判断高频彩
    BOOL                    _isPlayHalf;
    TimerLabel              *_timeLabel;
    ASINetworkQueue         *_queue;                            /**< 请求队列（普通彩种、竞彩足球、竞彩篮球三个请求）*/
    BetTypeDropDownListView *typeListView;
    NSMutableArray          *missingValuesArray;                //遗漏值
    UITableView             *_notificationTableView;            /**< 开奖表格视图 */
    NSMutableArray          *historyLotteryNumbersArray;        //历史开奖号码
    ASIFormDataRequest      *_historyRequest;                   /**< 历史开奖请求 */
    NSString                *_serverTime;                       /**< 服务器返回的系统时间 */
    NSMutableDictionary     *_infoDic;
    
    UIView                  * _leftView;
    ASIFormDataRequest      *_asiRequest;                       /**< 遗漏值请求 */
}

@property (nonatomic, assign) NSArray     *betTypeArray;
@property (nonatomic, assign) id<SelectBallsDetailViewControllerDelegate> baseDelegate;
@property (nonatomic, assign) UIButton *shakeBtn;
@property (nonatomic, assign) BOOL isPresentView;
@property (nonatomic, assign) UIViewController *betViewController;


/**  初始化(购彩大厅进入)
 *  @param infoData 彩种的信息
 *  @return */
- (id)initWithInfoData:(NSObject *)infoData;

/**  初始化(从购买页自选进入)
 *  @param viewController 当前viewController
 *  @param dic            彩种的信息
 *  @param ballsDic       所选的所有注数方案
 *  @return */
- (id)initWithBetViewController:(UIViewController *)viewController
                     lotteryDic:(NSDictionary *)dic
                    andBallsDic:(NSDictionary *)ballsDic;

/**  初始化(从购买页反选进入)
 *  @param ballsDic 所选的所有注数方案
 *  @param dic      彩种的信息
 *  @param index    某方案的index
 *  @return */
- (id)initWithSelectedBallsDic:(NSDictionary *)ballsDic
                    lotteryDic:(NSDictionary *)dic
                    atRowIndex:(NSInteger)index;

/**  初始化(从开奖公告进入(适应与需要指定玩法))
 *  @param infoData 从购彩大厅获取的彩种的信息
 *  @param playID   玩法ID
 *  @param playName 玩法名称
 *  @param index    选中的玩法按钮的index
 *  @return */
- (id)initWithData:(NSObject *)infoData
        playMethod:(NSInteger)playID
    playMethodName:(NSString *)playName
withPlayMethodButtonIndex:(NSInteger)index;

- (void)getPlayMethods;                 // 获取玩法
- (void)setBallStatus;                  // 反选操作时设置球的选中状态
- (void)createNavMiddleView;            // 创建导航条中间的按钮
- (void)navMiddleBtnSelect:(id)sender;  // 导航条中间按钮事件

/**  选中球的按钮事件
 *  @param sender 球对象 */
- (void)ballSelect:(id)sender;

/**  创建球
 *  @param type             球的类型(红色和蓝色)
 *  @param minNum           球的最小显示的数字
 *  @param maxNum           球的最大显示的数字
 *  @param ballCountPerView 每行显示的球的数量
 *  @param view             球放的view */
- (void)createBallsWithBallsType:(BallsType)type
                      minBallNum:(NSInteger)minNum
                      maxBallNum:(NSInteger)maxNum
                ballCountsPerRow:(NSInteger)ballCountPerView
                          onView:(UIView *)view;

/**  增加球视图之间的分割线
 *  @param y */
- (void)addLineBewteenBallViewWithCoordY:(CGFloat)y;

/**  增加球界面的提示信息
 *  @param frame 提示信息所在的frame
 *  @param msg   提示文字 */
- (void)addPromptMsgInBallView:(CGRect)frame message:(NSString *)msg;

/**  计算view的左下角的y坐标
 *  @param view 某视图
 *  @return view的左下角的y坐标 */
- (CGFloat)getFirstCoordYAfterView:(UIView *)view;

/**  计算球视图的高度(height)
 *  @param viewWidth        球视图的宽度
 *  @param ballCountPerView 当前view中球的总数量
 *  @param countPerRow      每行显示的球的数量
 *  @return 球视图的高度 */
- (CGFloat)calculateBallViewHeightWithViewWidth:(CGFloat)viewWidth
                          andBallCountPerView:(NSInteger)ballCountPerView
                           andBallCountPerRow:(NSInteger)countPerRow
                                       isHidden:(BOOL)ishidden;

/**  计算球视图的高度(height)
 *  @param viewWidth        球视图的宽度
 *  @param ballCountPerView 当前view中球的总数量
 *  @param countPerRow      每行显示的球的数量
 *  @return 球视图的高度 */
- (CGFloat)calculateBallViewHeightWithViewWidth:(CGFloat)viewWidth
                            andBallCountPerView:(NSInteger)ballCountPerView
                             andBallCountPerRow:(NSInteger)countPerRow;

/**  加载球视图索引大于1的球视图
 *  @param y            球视图的y坐标
 *  @param hasLabel     是否需要添加提示信息
 *  @param viewIndex    球视图的索引(oneView为1, twoView为2, ...)
 *  @param counts       需要增加的球的数量
 *  @param countsPerRow 每行显示的球的数量
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param string       提示信息 */
- (void)loadGreaterOneBallViewWithCoordY:(CGFloat)y
                                hasLabel:(BOOL)hasLabel
                               whichView:(NSInteger)viewIndex
                          totalBallCount:(NSInteger)counts
                        ballCountsPerRow:(NSInteger)countsPerRow
                              minBallNum:(NSInteger)minNum
                              maxBallNum:(NSInteger)maxNum
                                     msg:(NSString *)string;

/**  加载指定球视图
 *  @param frame            球视图的位置大小
 *  @param viewIndex        球视图的索引(oneView为1, twoView为2, ...)
 *  @param minNum           球的最小显示的数字
 *  @param maxNum           球的最大显示的数字
 *  @param ballCountPerView 每行显示的球的数量 */
- (void)loadBallViewWithFrame:(CGRect)frame
                    whichView:(NSInteger)viewIndex
                   minBallNum:(NSInteger)minNum
                   maxBallNum:(NSInteger)maxNum
             ballCountsPerRow:(NSInteger)ballCountPerView;

/**  加载第一个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadOneView:(BOOL)hasLabel
         minBallNum:(NSInteger)minNum
         maxBallNum:(NSInteger)maxNum
   ballCountsPerRow:(NSInteger)countsPerRow
    totalBallCounts:(NSInteger)counts;

/**  加载第二个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadTwoView:(BOOL)hasLabel
         minBallNum:(NSInteger)minNum
         maxBallNum:(NSInteger)maxNum
   ballCountsPerRow:(NSInteger)countsPerRow
    totalBallCounts:(NSInteger)counts;

/**  加载第三个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadThreeView:(BOOL)hasLabel
           minBallNum:(NSInteger)minNum
           maxBallNum:(NSInteger)maxNum
     ballCountsPerRow:(NSInteger)countsPerRow
      totalBallCounts:(NSInteger)counts;

/**  加载第四个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadFourView:(BOOL)hasLabel
          minBallNum:(NSInteger)minNum
          maxBallNum:(NSInteger)maxNum
    ballCountsPerRow:(NSInteger)countsPerRow
     totalBallCounts:(NSInteger)counts;

/**  加载第五个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadFiveView:(BOOL)hasLabel
          minBallNum:(NSInteger)minNum
          maxBallNum:(NSInteger)maxNum
    ballCountsPerRow:(NSInteger)countsPerRow
     totalBallCounts:(NSInteger)counts;

/**  加载第六个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadSixView:(BOOL)hasLabel
         minBallNum:(NSInteger)minNum
         maxBallNum:(NSInteger)maxNum
   ballCountsPerRow:(NSInteger)countsPerRow
    totalBallCounts:(NSInteger)counts;

/**  加载第七个球视图
 *  @param hasLabel     是否需要添加提示信息
 *  @param minNum       球的最小显示的数字
 *  @param maxNum       球的最大显示的数字
 *  @param countsPerRow 每行显示的球的数量
 *  @param counts       需要增加的球的数量 */
- (void)loadSevenView:(BOOL)hasLabel
         minBallNum:(NSInteger)minNum
         maxBallNum:(NSInteger)maxNum
   ballCountsPerRow:(NSInteger)countsPerRow
    totalBallCounts:(NSInteger)counts;

- (void)makeShakeBtn;

/**  在baseView中增加tag为ballTag的球
 *  @param ballTag  球的tag
 *  @param baseView 球所在的view */
- (void)addBallInSpecifiedArrayWithTag:(NSInteger)ballTag baseView:(UIView *)baseView;

/**  在baseView中移除tag为ballTag的球
 *  @param ballTag  球的tag
 *  @param baseView 球所在的view */
- (void)removeBallInSpecifiedArrayWithTag:(NSInteger)ballTag baseView:(UIView *)baseView;

/**  判断当前所选的球是否在指定的view中(当前在oneView选了tag为2的球,检测该tag的球是否同样出现在array中,
    也就是检测该tag的球是否在指定的view中)
 *  @param ballNum 球的tag
 *  @param array   目标数组(目标的view:oneView, twoView, ...)
 *  @return 如果是ballNum在array中,返回YES，否则返回NO. */
- (BOOL)isBallInViewWithCurrentBallTag:(NSNumber *)ballNum desArray:(NSArray *)array;

/**  检测view中是否存在已被选中的tag为ballTag的球
 *  @param view    指定的视图
 *  @param ballTag 球的tag值 */
- (void)checkHasSameBallWithView:(UIView *)view ballTag:(NSInteger)ballTag;

/**  清空数组 */
- (void)emptyArrays;

/**  清空球的选中状态 */
- (void)emptySelectedBallInBallViews;

/**  底部视图显示注数和金额 */
- (void)showBetCount;

/**  组合投注内容
 *  @return 投注的内容字典 */
- (NSMutableDictionary *)combineBetContentDic;

/**  检测摇手机的回调 */
- (void)shakePhoneAndSelectBallAutomatic;

/**  随机生成ballCounts个球并放进指定数组
 *  @param ballCounts 期望生成的球的个数
 *  @param maxNum     球最大显示的数字
 *  @param minNum     球最小显示的数字
 *  @param arrayIndex 数组的index(oneArray为1, twoArray为2, ...) */
- (void)getRandomBallAndFillViewWithExpectedCounts:(NSInteger)ballCounts
                                        maxBallNum:(NSInteger)maxNum
                                        minBallNum:(NSInteger)minNum
                                      inWitchArray:(NSInteger)arrayIndex;

/**  消失界面 */
- (void)prepareGotoNextPage;

- (void)clearBalls;

- (void)closeView:(BOOL)close;

- (void)missingValuesRequest:(NSString *)playTypeIds;

@end
