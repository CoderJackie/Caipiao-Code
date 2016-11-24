//
//  BonusOptimizationViewController.h
//  TicketProject
//
//  Created by kiu on 15/7/29.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FootBallViewController.h"
#import "BasketBallViewController.h"

@class AppDelegate;
@class CustomBottomView;
@class Globals;

@interface BonusOptimizationViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, CustomAlertViewDelegate> {
    
    UIView *_inputView;
    UITextField         *_inputField;
    CustomBottomView    *_bottomView;
    UIView              *_overlayView;
    UIScrollView        *_scrollView;
    UIView              *_lineView;
    UIView              *_bgView;
    
    NSMutableArray      *_resultArray;           /**< 优化拆分对阵 **/
    UITextField         *_moneyField;            /**< 购买金额 **/
    NSInteger           _betCount;               /**< 购买注数 */
    NSInteger           _preBetType;             /**< 优化方案类型   1：平均优化 2：博热优化 3：博冷优化*/
    NSArray             *_promptLabelTitleArray;
    UITableView         *_lotteryNumberTableView;
    
    int                 _heat;                     /**< 博热对阵索引 */
    float               _heatCastMoney;            /**< 博热对阵 */
    int                 _cold;                     /**< 博冷对阵索引 */
    float               _coldCastMoney;            /**< 博冷对阵 */
    int                 _tag;                      /**< 标识: (0: 对阵信息  1: 方案代码) */
    int                 _tbCount;                  /**< 最低注数 */
    NSString            *_lotteryId;                  /**< 优化彩种ID */
    NSString            *_castMoney;               /**< 预测奖金 */
    NSMutableDictionary *_orderDetailDict;         /**< 购买成功后该订单的详情 */
    
    Globals             *_globals;
    AppDelegate         *_appDelegate;
    ASIFormDataRequest  *_httpRequest;                      /**< 付款请求 */
    ASIFormDataRequest  *_launchChippedProportionRequest;   /**< 合买请求 */
    
    // 付款提交参数
    NSString            *_gGWay;                            /**< 串数 */
    BOOL                _isChangeScrollHeight;              /**< 是否改变滚动视图高度 */
    
    NSString        *_secrecyLevel;     /**< 保密数值 */
    NSString        *_description;      /**< 宣言内容 */
}

@property (nonatomic,retain) NSMutableArray *selectMatchArray;          // 投注数据
@property (nonatomic,assign) FootBallPlayType footBallPlayType;         // 竞彩足球玩法类型
@property (nonatomic, retain) NSMutableDictionary *selectedScoreDic;    // 比分玩法下使用
@property (nonatomic,assign) FootBallPassBarrierType footBallPassBarrierType;       // 竞彩足球过关类型
@property (nonatomic,assign) BasketBallPassBarrierType basketBallPassBarrierType;   // 竞彩篮球过关类型
@property (nonatomic,retain) NSMutableArray *passWayArray;              // 选择的过关方式
@property (nonatomic,retain) NSMutableArray *passWayTagArray;           // 几串几的下标
@property (nonatomic,retain) NSString *playType;                        // 系统玩法类型
@property (nonatomic,retain) NSString *codeFormat;                      // 优化前数据
@property (nonatomic,assign) int ballType;                         /**< 优化竞彩彩种标识  0: 足球    1: 篮球*/
//@property (nonatomic,retain) NSArray *selectArray;          //选择比赛的胜平负  用于计算注数
//@property (nonatomic,retain) NSArray *selectNormalArray;    //没有设胆的数组

- (id)initWithMatchArray:(NSMutableArray *)matchArray andScoreDic:(NSMutableDictionary *)scoreDic andBetCount:(NSInteger) betCount lotteryId:(NSString *)lotteryId;

@end
