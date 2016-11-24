//
//  AppDelegate.h
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "CustomAlertViewDelegate.h"
#import "WinPopubViewDelegate.h"

@class ASIFormDataRequest;
@class Globals;
@class GlobalsProject;
@class WinPopubView;
@class XFTabBarViewController;
@class XFNavigationViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ASIHTTPRequestDelegate, SKStoreProductViewControllerDelegate, CustomAlertViewDelegate, WinPopubViewDelegate> {
    XFTabBarViewController *_tabBarController;
    XFNavigationViewController *_currentPresentNavigationViewController;
    
    UIWindow *_window;
    WinPopubView *_winPopubView;
    
    Globals *_globals;
    ASIFormDataRequest *_asiRequest;
    ASIFormDataRequest *_autoLoginRequest;
    ASIFormDataRequest *_getUnReadWinMessageRequest;
    ASIFormDataRequest *_getWinDetailMessageRequest;
    ASIFormDataRequest *_recordPushParameterRequest;
    
    
    NSDictionary *_responseDic;
    NSDictionary *_appDelegateLaunchOptions;
    NSMutableDictionary *_winDetailDict;
    NSURLCache *_cache;
    
    NSString *_automaticUpdateAppID;
    NSString *_automaticUpdateUrl;
    
    BOOL      _getWinMessageRequesting;
    BOOL      _recordPushParametering;
    BOOL      _selfDidEnterBackgroundReceivePush;
}
@property (nonatomic,assign) int mycount;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) XFNavigationViewController *currentPresentNavigationViewController;
@property (nonatomic, assign) Globals *globals;

@property (nonatomic,assign) NSString *whichProject;
@property (nonatomic, assign) BOOL isRechargeSuccessful;


@end
