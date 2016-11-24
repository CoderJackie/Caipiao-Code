//
//  NotificationViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-7.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"


@class MarqueeView;
@class Globals;

@interface NotificationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,EGORefreshTableHeaderDelegate> {
    
    MarqueeView               *_lblWinInfoView;         /**< 中奖公告栏 */
    UITableView               *_notificationTableView;  /**< 开奖表格视图 */
    EGORefreshTableHeaderView *_refreshTableHeaderView; /**< 头部刷新控件 */
    
    NSArray *_lotteryNameArray;   /**< 所有彩种的名称 */
    NSArray *_lotteryIDArray;     /**< 所有彩种ID */
    NSArray *_imageArray;         /**< 图片 */
    NSArray *_openInfoArray;      /**< 开奖信息临时数组 */
    NSMutableDictionary *_openDic;/**< 开奖信息 */
    
    BOOL _isLoading;
    
    ASIFormDataRequest *_httpRequest;  /**< 彩种开奖信息 */
    BOOL _isHidden;
    BOOL _isHiddens;
    
    Globals             *_globals;
}

@end
