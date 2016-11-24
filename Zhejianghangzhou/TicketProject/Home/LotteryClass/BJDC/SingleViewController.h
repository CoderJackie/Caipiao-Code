//
//  SingleViewController.h   竞彩足球
//  TicketProject
//
//  Created by sls002 on 13-6-26.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogFilterMatchViewDelegate.h"
#import "DialogSelectButtonViewDetegate.h"
#import "DropDownListViewDelegate.h"


typedef enum {
    SinglePassBarrierType_moreMatch = 0,	  //过关
    SinglePassBarrierType_singleMacth,	  //单关
} SinglePassBarrierType;

typedef enum {
    SinglePlayType_upAndDownSingle = 0,                  //上下单双
    SinglePlayType_winDogfallLose,        //胜平负
    SinglePlayType_score,                 //比分
    SinglePlayType_totalGoal,             //总进球
    SinglePlayType_half,                  //半全场
    SinglePlayType_winlose,               //胜负过关
    SinglePlayType_single,                //猜一场     未开发
    SinglePlayType_no = 101,              //无玩法
} SinglePlayType;

@class CustomBottomView;
@class CustomSegmentedControl;
@class SingleBetViewController;
@class SSQPlayMethodView;
@class ASIFormDataRequest;

@interface SingleViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, DialogFilterMatchViewDelegate, DropDownListViewDelegate, DialogSelectButtonViewDetegate,ASIHTTPRequestDelegate> {
    
    UIButton *_midBtn;
    
    UIScrollView              *_SingleScrollView;
    UITableView               *_matchTableList;    /**< 中间比赛信息选择列表 */
    UITableView               *_singleMatchTableList;/**< 单场过关 */
    
    UILabel                   *_matchPromptLabel;
    UILabel                   *_singleMatchPromptLabel;
    
    CustomBottomView          *_bottomView;        /**< 底部框 */
    SSQPlayMethodView         *_playMethodView;    /**< 点击顶部中间按钮激发用的玩法选择框 */
    SingleBetViewController *_betViewController;
    CustomSegmentedControl    *_matchTypeCustomSegmentedControl;
    
    NSMutableDictionary  *_dropDic;            /**< 记录每个section下拉和收缩状态的字典 */
    NSMutableDictionary  *_singleDropDic;      /**< 同上 单场的 */
    
    NSMutableDictionary  *_selectScoreDic;     /**< 猜比分玩法 选中的比分字典 */
    NSMutableDictionary  *_singleSelectScoreDic;
    
    NSMutableDictionary  *_selectHalfDict;     /**< 半全场玩法 选中的场次字典 */
    NSMutableDictionary  *_singleSelectHalfDict;
    
    NSMutableDictionary  *_filterMatchDic;     /**< 筛选过滤的比赛 */
    NSMutableDictionary  *_singleFilterMatchDic;
    NSMutableArray       *_completeFilterMainMatchArray;
    
    NSDictionary         *_completeMatchDict;
    NSDictionary         *_secmpleteMatchDict;   //胜负过关
    NSDictionary         *_completeSingleMatchDict;
    
    NSMutableDictionary         *_matchDict;
    NSMutableDictionary         *_singleMatchDict;
    
    NSMutableArray       *_selectMatchArray;   /**< 用户选择的多场的比赛彩票信息 */
    NSMutableArray       *_singleSelectMatchArray;
    
    NSMutableArray       *_selectHalfMTArray;
    NSMutableArray       *_singleSelectHalfMTArray;
    
    
    NSMutableArray                 *_betTypeArray;       /**< 投注方式数组(用于初始化下拉列表) */
    NSInteger                _selectType;         /**< 玩法类型  0表示胜平负  1表示总进球  2表示猜比分 */
    NSInteger                _btnIndex;           /**< 玩法按钮的index */
    NSInteger                _selectLetBallType;  /**< 筛选 的让球方式 */
    SinglePassBarrierType  _SinglePassBarrierType;   /**< 过关方式 过关或单关 */
    SinglePlayType         _SinglePlayType;   /**< 选择的玩法类型 */
    NSInteger                _lotteryID;        /**< 彩种ID */
    NSTimeInterval    _startTime;
}

@property (nonatomic,assign) SingleBetViewController *betViewController;

- (id)initWithMatchData:(NSObject *)matchData SinglePassBarrierType:(SinglePassBarrierType)SinglePlayType;

- (void)clearAllTouchUpInside:(id)sender;//清除按钮的点击事件，这里用来在继续投注中清除号码用，因为按钮暂时没用到，so该方法可以直接用

@end
