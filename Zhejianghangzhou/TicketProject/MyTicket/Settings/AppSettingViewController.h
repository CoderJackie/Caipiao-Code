//
//  AppSettingViewController.h
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocialControllerService.h"


@class AppDelegate;
@class Globals;

@interface AppSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,UMSocialUIDelegate,SKStoreProductViewControllerDelegate,CustomAlertViewDelegate> {
    
    UITableView *_tableListView; /**< 中间表格视图 */
    UIImageView *_updateSignImageView;
    
    UISwitch    *_shakeSwitch;   /**< 摇一摇震动按钮 */
    UISwitch    *_switchBtn;     /**< 摇一摇机选按钮 */
    
    AppDelegate *_appDelegate;
    Globals     *_globals;
    ASIFormDataRequest *_httpRequest;
    ASIFormDataRequest *_checkUpdateRequest;
    ASIFormDataRequest *_asiRequest;
    
    NSString *_automaticUpdateAppID;
    NSString *_automaticUpdateUrl;
    NSString *_shareURL;
    
    NSArray    *_titleArray;     /**< 标题列表 */
    NSInteger   _unReadCount;    /**< 未读数目 */
    BOOL        _firstRequestUpdate;
    BOOL        _hasUpdate;
}

@end
