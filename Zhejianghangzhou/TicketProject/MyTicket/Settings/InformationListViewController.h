//
//  InformationListViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateIsReadedStatusDelegate.h"


@class CustomSegmentedControl;

@interface InformationListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UpdateIsReadedStatusDelegate, UIScrollViewDelegate> {
    
    CustomSegmentedControl    *_matchTypeCustomSegmentedControl;
    UIScrollView              *_messageScrollView;
    
    UITableView               *_systemMessageTableList;  /**< 系统消息表格视图 */
    UITableView               *_pushMessagetableList;    /**< 推送消息表格视图 */
    
    ASIFormDataRequest *_systemMessageRequest;
    ASIFormDataRequest *_pushMessageRequest;
    
    NSMutableArray *_systemMessageArray;         /**< 系统信息数组 */
    NSMutableArray *_pushMessageArray;           /**< 推送信息数组 */
    
    NSIndexPath    *_currIndexPath;              /**< 点击查看的信息下标 */
    
    NSInteger       _systemMessagePageIndex;     /**< 系统消息下拉页数 */
    NSInteger       _pushMessagePageIndex;       /**< 推送消息下拉页数 */
    
    NSInteger       _currentSelectType;          /**< 当前显示页的消息类型 */
    BOOL            _isAddMore;       /**< 是否加载更多 */
    
    BOOL            _systemMessageHasMore;
    BOOL            _pushMessageHasMore;
}

@end
