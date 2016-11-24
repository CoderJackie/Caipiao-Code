//
//  UserLoginViewController.h
//  TicketProject
//
//  Created by sls002 on 13-5-31.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLoginViewControllerDelegate.h"

@class AppDelegate;
@class Globals;

@interface UserLoginViewController : UIViewController<ASIHTTPRequestDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource> {
    
    UITextField   *_userNameField;   /**< 用户名输入框 */
    UITextField   *_passwordField;   /**< 密码输入框 */
    UIButton      *_rememberBtn;
    UIView        *_Bgview;
    NSArray       *_Myarray;
    NSArray       *_Picarray;
    UITableView   *_Mytableview;
    NSInteger      _pagecount;
    NSMutableArray       *_Btnarray;
    id<UserLoginViewControllerDelegate> __delegate;
    ASIFormDataRequest *_httpRequest;
    ASIFormDataRequest *_recordPushParameterRequest;
    
    AppDelegate   *_appDelegate;
    Globals       *_globals;
    
    NSMutableDictionary *_userInfoDictionary;
    
    BOOL _isStorePassword;        /**< 是否保存密码 */
    BOOL _isNeedDelegate;         /**< 是否需要代理 */
}

@property (nonatomic, assign) id<UserLoginViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isNeedDelegate;

- (void)selectItemAndRequestRecordPushParameter;


@end
