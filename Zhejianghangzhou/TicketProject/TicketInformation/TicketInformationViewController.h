//
//  TicketInformationViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSwitchViewDelegate.h"


@class CustomSwitchView;
@class TicketInformationModel;

@interface TicketInformationViewController : UIViewController<CustomSwitchViewDelegate,UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,PullingRefreshTableViewDelegate>
{
    
    CustomSwitchView          *_switchView;             /**< 头部选项视图 */
    PullingRefreshTableView   *_infoTableView;          /**< 新闻信息表 */
    
    ASIFormDataRequest *_httpRequest;
    
    NSMutableArray     *_ticketInformationArray;  /**< 信息数组 */
    NSMutableArray     *_colorInformationArray;   /**< 颜色数组 */
    
    NSInteger           _pageIndex;        /**< 请求页码 */
    NSInteger           _messageType;      /**< 请求信息类型 */
    BOOL                _hasMoreMessage;   /**< 是否还有更多信息 */
}

@end
