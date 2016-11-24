//
//  BasketBallViewController.h   竞彩篮球
//  TicketProject
//
//  Created by sls002 on 13-7-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DialogFilterMatchViewDelegate.h"
#import "DialogSelectButtonViewDetegate.h"
#import "DropDownListViewDelegate.h"

typedef enum {
    BasketBallPlayType_winLose = 0,     //胜负
    BasketBallPlayType_letWinLose,      //让分胜负
    BasketBallPlayType_minusScore,      //胜分差
    BasketBallPlayType_BigSmallScore,   //大小分
    BasketBallPlayType_mix,             //混合过关
    BasketBallPlayType_no = 101,        //无
} BasketBallPlayType;

typedef enum {
    BasketBallPassBarrierType_moreMatch = 0,  //过关
    BasketBallPassBarrierType_singleMacth,	  //单关
} BasketBallPassBarrierType;

@class BasketBallBetViewController;
@class CustomBottomView;
@class CustomSegmentedControl;
@class SSQPlayMethodView;

@interface BasketBallViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DropDownListViewDelegate,DialogFilterMatchViewDelegate, DialogSelectButtonViewDetegate, UIScrollViewDelegate> {
    
    UIButton                *_midBtn;
    
    CustomSegmentedControl  *_matchTypeCustomSegmentedControl;
    UIScrollView            *_basketBallScrollView;
    UITableView             *_matchTableList;     /**< */
    UITableView             *_singleMatchTableList;
    
    UILabel                 *_matchPromptLabel;   /**< */
    UILabel                 *_singleMatchPromptLabel;
    
    CustomBottomView        *_bottomView;         /**< */
    SSQPlayMethodView       *_playMethodView;     /**< */
    
    NSMutableDictionary *_dropDict;          /**< 记录过关每个section下拉和收缩状态的字典 */
    NSMutableDictionary *_singleDropDict;    /**< 记录单关每个section下拉和收缩状态的字典 */
    
    NSInteger            _selectType;       /**< 玩法类型  0表示大小分  1表示胜负 */
    NSMutableArray      *_playMethodArray;  /**< 玩法数组 */
    
    NSMutableDictionary *_matchDict;         /**< 过关比赛字典  count对应tableView的section */
    NSMutableDictionary *_singleMatchDict;   /**< 单关比赛字典  count对应tableView的section */
    
    NSDictionary        *_tempDict;          /**< 用于保存比赛信息备份的临时字典 防止过滤后字典内容变化 */
    NSDictionary        *_singleTempDict;
    
    NSDictionary        *_completeMatchDict;
    NSDictionary        *_singleCompleteMatchDict;
    
    NSDictionary        *_filterMatchDict;   /**< 筛选过滤的比赛 */
    NSDictionary        *_singleFilterMatchDict;
    
    NSInteger            _selectLetBallType; /**< 筛选 的让球方式 */
    
    NSMutableArray      *_selectMatchArray;
    NSMutableArray      *_singleSelectMatchArray;
    
    BasketBallPlayType   _basketBallPlayType;
    NSInteger            _lotteryID;        /**< 彩种ID */
    BasketBallPassBarrierType _basketBallPassBarrierType;  /**< 竞技彩篮球过关方式 */
}

@property (nonatomic,assign) BasketBallBetViewController *betViewController;

- (id)initWithMatchData:(NSObject *)matchData;

- (void)clearAllTouchUpInside:(id)sender;//清除按钮的点击事件，这里用来在继续投注中清除号码用，因为按钮暂时没用到，so该方法可以直接用

@end