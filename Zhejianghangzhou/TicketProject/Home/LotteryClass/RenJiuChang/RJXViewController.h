//
//  RJXViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-4.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBallBottomViewDelegate.h"
#import "SelectBallsDetailViewControllerDelegate.h"


@class SelectBallBottomView;

@interface RJXViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SelectBallBottomViewDelegate> {

    UITableView          *_matchTableView;
    SelectBallBottomView *_bottomView;
    UIView               *_overlayView;
    
    UIViewController *_betViewController;   /**< 投注界面的viewcontroller */
    
    id<SelectBallsDetailViewControllerDelegate> _delegate;
    
    NSDictionary *_selectedBallsDic; /**< 投注页面tableview的详细信息 */
    NSDictionary *_lotteryDic;       /**< 彩票信息 */
    NSArray      *_matchList;        /**< 比赛对阵数组 */
    NSString     *_selectBetType;    /**< 投注方式 */
    NSInteger     _selectRowIndex;   /**< 投注页面的选中行 */
    
    BOOL          _hasChangeColor;      /**< 是否改变灰色颜色 */
    NSInteger     _lotteryID;
}

@property (nonatomic,retain) NSMutableDictionary *selectMatchDic;

@property (nonatomic,assign) id<SelectBallsDetailViewControllerDelegate> delegate;

- (id)initWithInfoData:(NSObject *)infoData;

- (id)initWithSelectedBallsDic:(NSDictionary *)ballsDic LotteryDic:(NSDictionary *)dic;

- (void)clearBalls;

@end
