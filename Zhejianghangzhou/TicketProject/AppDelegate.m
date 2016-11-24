//
//  AppDelegate.m
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "AppDelegate.h"
#import <sys/utsname.h>
#import "ChaseDetailViewController.h"
#import "ChippedDetailViewController.h"
#import "DetailInformationViewController.h"
#import "TicketsDetailViewController.h"
#import "HomeViewController.h"
#import "LaunchChippedListViewController.h"
#import "NotificationViewController.h"
#import "MyTicketsViewController.h"
#import "TicketInformationViewController.h"
#import "WinPopubView.h"
#import "XFNavigationViewController.h"
#import "XFTabBarItem.h"
#import "XFTabBarViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import "BPush.h"
#import "CustomResultParser.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import "MobClick.h"
#import "MobClickSocialAnalytics.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UserInfo.h"

#import "TabBarArray.h"
#import "AppDefaultUtil.h"
#import "GuideViewController.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

@implementation AppDelegate
@synthesize window = _window;
@synthesize currentPresentNavigationViewController = _currentPresentNavigationViewController;
@synthesize globals = _globals;
- (void)dealloc {
    if (_asiRequest) {
        [_asiRequest clearDelegatesAndCancel];
        [_asiRequest release];
        _asiRequest = nil;
    }
    
    if (_autoLoginRequest) {
        [_autoLoginRequest clearDelegatesAndCancel];
        [_autoLoginRequest release];
        _autoLoginRequest = nil;
    }
    
    if (_getUnReadWinMessageRequest) {
        [_getUnReadWinMessageRequest clearDelegatesAndCancel];
        [_getUnReadWinMessageRequest release];
        _getUnReadWinMessageRequest = nil;
    }
    
    if (_getWinDetailMessageRequest) {
        [_getWinDetailMessageRequest clearDelegatesAndCancel];
        [_getWinDetailMessageRequest release];
        _getWinDetailMessageRequest = nil;
    }
    
    [_appDelegateLaunchOptions release];
    _appDelegateLaunchOptions = nil;
    
    [_winDetailDict release];
    _winDetailDict = nil;
    [_globals release];
    _globals = nil;
    [_asiRequest release];
    _asiRequest = nil;
    [_tabBarController release];
    _tabBarController = nil;
    [_automaticUpdateAppID release];
    [_automaticUpdateUrl release];
    [_window release];
    _window = nil;
    [_cache release];
    _cache = nil;
    [super dealloc];
}

- (BOOL)isSingleTask {
	struct utsname name;
	uname(&name);
	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
	if (version < 4.0 || strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0) {
		return YES;
        
	} else {
		return NO;
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _mycount = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    _selfDidEnterBackgroundReceivePush = YES;
    NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotificationKey) {
        _appDelegateLaunchOptions = [pushNotificationKey retain];
    }
    
    _globals = [[Globals alloc] init];
    _winDetailDict = [[NSMutableDictionary alloc] init];
    _getWinMessageRequesting = NO;
    
    _cache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:32*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:_cache];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UMSocialData setAppKey:@"52478ab556240b0c130d6760"];
    
    self.whichProject = @"竞彩";
    
    //分享设置  设置微信appID。url为固定友盟连接，url不能修改 appSecret4.1才出现，友盟也没有给解释
    [UMSocialWechatHandler setWXAppId:WXAPPKEY appSecret:WXAPPKEYSECRET url:kWebSite];
    //分享设置  设置qq互联和qq应用appkey
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:TENCENTAPPKEY url:kWebSite];
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialQQHandler setSupportWebView:YES];
    
    [BPush setupChannel:launchOptions]; // 必须
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    } else {
        [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];  
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    // 检测是否有设置摇号震动功能
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultsSetting = [users objectForKey:kDefaultSettings];
    if (defaultsSetting == nil) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        [tmp setObject:@"1" forKey:kIsShake];
        [tmp setObject:@"1" forKey:kIsShakeToSelect];
        [users setObject:tmp forKey:kDefaultSettings];
        _globals.isShake = YES;
    } else {
        _globals.isShake = [defaultsSetting isKindOfClass:[NSDictionary class]] ? [[defaultsSetting objectForKey:kIsShakeToSelect] boolValue] : YES;
    }
    
    // 每次启动程序，进入主页都只需要自动登录一次
    [users setObject:[NSNumber numberWithInteger:23] forKey:kLoginOnceOnHomeView];
    
    // 每次启动程序，把用户信息清除
    NSInteger flag = [users integerForKey:kIsStorePassword];

    if (flag != 1) {
        [UserInfo shareUserInfo].userID = nil;
        [XYMKeyChain deleteKeyChainItemWithKey:KEY_KEYCHAINITEM];
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:kIsStorePassword];
    } else {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userinfo"];
    }
    
    [self autoLogin];
    // 初始化摇号设置
    NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithDictionary:[users objectForKey:kDefaultSettings]];
    if (defaults == nil) {
        [defaults setObject:[NSNumber numberWithBool:0] forKey:kIsShake];
        [defaults setObject:[NSNumber numberWithBool:0] forKey:kIsShakeToSelect];
        _globals.isShake = NO;
    }
    
    /**  苹果审核相关：需要自己写以下的方法接口隐藏跟支付相关的内容 **/
    if (kToDeliverySoftware) {
        if ([kCurrentCertificatetType isEqualToString:@"enterprise"]) {
            [self makeTabBarIsHidden:NO];
        }
        [self loadInfo];
    } else {
        [self makeTabBarIsHidden:NO];
    }
    
    /*
	 *单任务handleURL处理
	 */
	if ([self isSingleTask]) {
		NSURL *url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
		
		if (nil != url) {
			[self parseURL:url application:application];
		}
	}
    
//    NSLog(@"SCREEN_MAX_LENGTH == %f",SCREEN_MAX_LENGTH);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    _selfDidEnterBackgroundReceivePush = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self unReadWinMessageRequest];
    
    NSLog(@"程序回到前台");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (_appDelegateLaunchOptions) {
       [self makeDetailInformationViewWithDict:_appDelegateLaunchOptions];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [BPush registerDeviceToken:deviceToken]; // 必须
    
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [BPush handleNotification:userInfo]; // 可选
    [self makeDetailInformationViewWithDict:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kIsStorePassword];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
#if LOG_SWITCH_HTTP
	NSLog(@"HTTP-AppDelegate-handleOpenURL:%@",[url absoluteString]);
#endif
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processAuth_V2Result:url
                                         standbyCallback:^(NSDictionary *resultDic) {
                                             NSInteger resultStatus = [resultDic intValueForKey:@"resultStatus"];
                                             if (resultStatus == 9000) {
                                                 [Globals alertWithMessage:@"订单支付成功"];
                                                 CGFloat rechargeMoney = [UserInfo shareUserInfo].rechargeMoney;
                                                 CGFloat balance = [[UserInfo shareUserInfo].balance floatValue];
                                                 [[UserInfo shareUserInfo] setBalance:[NSString stringWithFormat:@"%.2f",(rechargeMoney + balance)]];
                                                 
                                                 // 保存到NSUserDefaults
                                                 NSMutableDictionary *userinfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"userinfo"]];
                                                 [userinfo setObject:[UserInfo shareUserInfo].balance forKey:@"balance"];
                                                 [[NSUserDefaults standardUserDefaults]setObject:userinfo forKey:@"userinfo"];
                                                 [[NSUserDefaults standardUserDefaults]synchronize];
                                                 
                                             } else if (resultStatus == 8000) {
                                                 [Globals alertWithMessage:@"正在处理中"];
                                             } else if (resultStatus == 4000) {
                                                 [Globals alertWithMessage:@"订单支付失败"];
                                             } else if (resultStatus == 6001) {
                                                 [Globals alertWithMessage:@"用户中途取消支付"];
                                             } else if (resultStatus == 6002) {
                                                 [Globals alertWithMessage:@"网络连接出错"];
                                             }
                                             
                                         }];
        return YES;
    }
    return  [UMSocialSnsService handleOpenURL:url];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)checkNewFailed:(ASIHTTPRequest *)request {
    if (![kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
        [self makeTabBarIsHidden:YES];
    }
}

- (void)checkNewFinished:(ASIHTTPRequest *)request {
    _responseDic = [[request responseString]objectFromJSONString];

    if (_responseDic && [[_responseDic stringForKey:@"upgrade"]isEqual:@"True"] && [kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
        _automaticUpdateAppID = [[NSString stringWithFormat:@"%@",[_responseDic stringForKey:@"appid"]] retain];  //如果是公司或个人的证书，只返回appid，企业的只返回url
        _automaticUpdateUrl = [[NSString stringWithFormat:@"%@",[_responseDic objectForKey:@"downLoadUrl"]] retain];
        [Globals alertWithMessage:@"有新版本,是否更新!" delegate:self tag:0];
    }
    NSInteger hiddenInt = [_responseDic intValueForKey:@"isHidden"];
    BOOL isHidden = YES;
    /**** 自己处理隐藏，默认是隐藏，避免在无网络的情况通讯而出现 *****/
    isHidden = (hiddenInt == 0 ? YES : NO);
    if (![kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
        [self makeTabBarIsHidden:isHidden];
    }
    /**** 过程自己写 额 *****/
    
}

#pragma mark - 登录成功，保存用户信息
- (void)getAutoFinshed:(ASIHTTPRequest *)request {
    NSDictionary *responseAutoLoginDict = [[request responseString]objectFromJSONString];
    
    if(responseAutoLoginDict && [responseAutoLoginDict intValueForKey:@"error"] == 0) {
        //再解析
        NSMutableDictionary *autoLoginDict = [[NSMutableDictionary alloc] init];
        [CustomResultParser parseResult:responseAutoLoginDict toUserInfoDict:autoLoginDict];
        
        [UserInfo shareUserInfo].userID = [NSString stringWithFormat:@"%@",[autoLoginDict stringForKey:@"uid"]];
        [UserInfo shareUserInfo].userName = [NSString stringWithFormat:@"%@",[autoLoginDict stringForKey:@"name"]];
        [UserInfo shareUserInfo].realName = [NSString stringWithFormat:@"%@",[autoLoginDict stringForKey:@"realityName"]];
        [UserInfo shareUserInfo].cardNumber = [NSString stringWithFormat:@"%@",[autoLoginDict stringForKey:@"idcardnumber"]];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%@",[autoLoginDict stringForKey:@"balance"]];
        [UserInfo shareUserInfo].freeze = [NSString stringWithFormat:@"%@",[autoLoginDict stringForKey:@"freeze"]];
        [UserInfo shareUserInfo].phoneNumber = [autoLoginDict stringForKey:@"mobile"];
        [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"handselAmount"]];
        [[NSUserDefaults standardUserDefaults] setObject:autoLoginDict forKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [autoLoginDict release];
        
        [self unReadWinMessageRequest];
        [self recordPushParameterRequest];
    }
}

- (void)getAutoFailed:(ASIHTTPRequest *)request {
    
}

- (void)recordPushParameterFinshed:(ASIFormDataRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
    }
}

- (void)recordPushParameterFailed:(ASIFormDataRequest *)request {
    
}

#pragma mark - WinPopubViewDelegate
- (void)winPopubViewToClose {
    [_winPopubView removeFromSuperview];
    _winPopubView = nil;
}

- (void)WinPopubViewCheckWinLottery {
    NSArray *tmpSchemeList = [_winDetailDict objectForKey:@"schemeList"];
    
    NSInteger timeInt = [Globals timeConvertToIndegerWithStringWithStringTime:[_winDetailDict stringForKey:@"serverTime"] beforeMonth:6];
    
    NSMutableArray *schemeList = [NSMutableArray array];
    [CustomResultParser parseResult:tmpSchemeList withNormalOrderArray:schemeList timeInt:timeInt];
    
    if([schemeList count] == 0) {
        return;
    }
    
    NSDictionary *dicSection = [schemeList objectAtIndex:0];
    if ([dicSection count] == 0) {
        return;
    }
    NSDictionary *dicRow = [[dicSection objectForKey:@"dateDetail"] objectAtIndex:0];
    
    
    NSInteger ischase = [dicRow intValueForKey:@"isChase"];
    NSString *isPurchasing = [dicRow stringForKey:@"isPurchasing"];
    UIViewController *detailViewController = nil;
    if (ischase == 0) {
        if ([isPurchasing isEqualToString:@"True"]){
            NSInteger lotteryid = [dicRow intValueForKey:@"lotteryID"];
            detailViewController = [[TicketsDetailViewController alloc] initWithInfoDic:dicRow withLotteryID:lotteryid orderStatus:NORMAL];
        } else {
            detailViewController = [[ChippedDetailViewController alloc] initWithInfoDic:dicRow];
        }
    } else {
        detailViewController = [[ChaseDetailViewController alloc] initWithInfoDic:dicRow indexPage:index];
    }
    
    
    UIViewController *applicationViewController = nil;
    if (_currentPresentNavigationViewController) {
        applicationViewController = [_currentPresentNavigationViewController topViewController];
        
    } else {
        XFTabBarViewController *tabBarViewController = (XFTabBarViewController *)self.window.rootViewController;
        XFNavigationViewController *viewController = (XFNavigationViewController *)tabBarViewController.currentController;
        applicationViewController = [viewController topViewController];
    }
    
    [applicationViewController.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    [_winPopubView removeFromSuperview];
    _winPopubView = nil;
}

#pragma mark -BPushDelegate
// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        
        _globals.pushBaiDuAppId = appid;
        _globals.pushBaiDuUserid = userid;
        _globals.pushBaiDuChannelid = channelid;
        _globals.pushBaiDuReturnCode = returnCode;
        _globals.pushBaiDuRequestid = requestid;
        [res release];
        [self recordPushParameterRequest];
    }
}

#pragma mark -UIAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        if ([kCurrentCertificatetType isEqualToString:@"person"] || [kCurrentCertificatetType isEqualToString:@"company"]) {
            [self openAppWithIdentifier:_automaticUpdateAppID == nil ? @"" : _automaticUpdateAppID];
        } else if ([kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
            if (_automaticUpdateUrl != nil) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_automaticUpdateUrl]];
            }
        }
    }
}

#pragma mark -SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        [viewController release];
    }];
}

- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    [storeProductViewController setDelegate:self];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductViewController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [self.window.rootViewController presentViewController:storeProductViewController animated:YES completion:nil];
        }
    }];
}

#pragma mark -
#pragma mark -Customized(Action)



#pragma mark -Customized: Private (General)
- (void)makeTabBarIsHidden:(BOOL)isHiddenTabBar {
    _globals.tabBarHidden = isHiddenTabBar;
    
    TabBarArray *tabBarArr = [[TabBarArray alloc] init];
    tabBarArr.isHiddenTabBar = isHiddenTabBar;
    
    if (_tabBarController) {
        [_tabBarController removeFromParentViewController];
        [_tabBarController release];
        _tabBarController = nil;
    }
    
    _tabBarController = [[XFTabBarViewController alloc]initWithViewControllers:[tabBarArr getTabBarArray]];
    
    [self.window setRootViewController:_tabBarController];
    [self.window makeKeyAndVisible];
}

//获取版本信息进行判断
- (void)loadInfo {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"IOS" forKey:@"identify"];
    [dict setObject:@"1" forKey:@"type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [dict setObject:version == nil ? @"" : version forKey:@"appversion"];
    [dict setObject:kCurrentCertificatetType forKey:kCertificatetType];
    if (_asiRequest) {
        [_asiRequest clearDelegatesAndCancel];
        [_asiRequest release];
        _asiRequest = nil;
    }
    _asiRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_UpdateAndHide userId:[UserInfo shareUserInfo].userID infoDict:dict]];
    [_asiRequest setDelegate:self];
    [_asiRequest setDidFinishSelector:@selector(checkNewFinished:)];
    [_asiRequest setDidFailSelector:@selector(checkNewFailed:)];
    [_asiRequest startAsynchronous];
    [dict release];
}

- (void)appUpdate:(NSDictionary *)appInfo {
    _responseDic = appInfo;
}

- (void)loadPage {
    [MobClick beginLogPageView:UPURL];
}

- (void)parseURL:(NSURL *)url application:(UIApplication *)application {

}

- (void)autoLogin {
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kUsername];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (username.length > 0 && password.length > 0) {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:username forKey:@"name"];
        [infoDic setObject:password forKey:@"password"];
        [UserInfo shareUserInfo].password = password;
        if (_autoLoginRequest) {
            [_autoLoginRequest clearDelegatesAndCancel];
            [_autoLoginRequest release];
            _autoLoginRequest = nil;
        }
        
        
        _autoLoginRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_Login userId:@"-1" infoDict:infoDic]];
        [_autoLoginRequest setDelegate:self];
        [_autoLoginRequest setDidFinishSelector:@selector(getAutoFinshed:)];
        [_autoLoginRequest setDidFailSelector:@selector(getAutoFailed:)];
        [_autoLoginRequest startAsynchronous];
    }
}

#pragma mark - 检测是否有中奖信息
- (void)unReadWinMessageRequest {
    if (_getWinMessageRequesting || [UserInfo shareUserInfo].userID.length == 0) {
        return;
    }
    
    if (_getUnReadWinMessageRequest) {
        [_getUnReadWinMessageRequest clearDelegatesAndCancel];
        [_getUnReadWinMessageRequest release];
        _getUnReadWinMessageRequest = nil;
    }
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[UserInfo shareUserInfo].userID forKey:@"uid"];
    _getWinMessageRequesting = YES;
    _getUnReadWinMessageRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_CheckUnReadWinMessage userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_getUnReadWinMessageRequest setDelegate:self];
    [_getUnReadWinMessageRequest setDidFinishSelector:@selector(getUnReadWinMessageFinshed:)];
    [_getUnReadWinMessageRequest setDidFailSelector:@selector(getUnReadWinMessageFailed:)];
    [_getUnReadWinMessageRequest startAsynchronous];
}

- (void)getUnReadWinMessageFinshed:(ASIFormDataRequest *)request {
    _getWinMessageRequesting = NO;
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    // 中奖信息（0: 无    1：有）
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 1) {
        [self getWinDetailMessage];
    }
}

- (void)getUnReadWinMessageFailed:(ASIFormDataRequest *)request {
    _getWinMessageRequesting = NO;
}

#pragma mark - 获取全部彩票订单
- (void)getWinDetailMessage {
    if (_getWinDetailMessageRequest) {
        [_getWinDetailMessageRequest clearDelegatesAndCancel];
        [_getWinDetailMessageRequest release];
        _getWinDetailMessageRequest = nil;
    }
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    NSString *lottoeryIds = [InterfaceHelper getAllLotteryString];
    [infoDic setObject:lottoeryIds forKey:@"lotteryId"];
    [infoDic setObject:@"1" forKey:@"pageIndex"];
    [infoDic setObject:@"1" forKey:@"pageSize"];
    [infoDic setObject:@"5" forKey:@"sort"];
    [infoDic setObject:@"3" forKey:@"isPurchasing"];
    [infoDic setObject:@"1" forKey:@"status"];
    [infoDic setObject:@"0" forKey:@"sortType"];
    
    _getWinDetailMessageRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetAllOrderTicket userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_getWinDetailMessageRequest setDelegate:self];
    [_getWinDetailMessageRequest setDidFinishSelector:@selector(getWinDetailMessageFinshed:)];
    [_getWinDetailMessageRequest setDidFailSelector:@selector(getWinDetailMessageFailed:)];
    [_getWinDetailMessageRequest startAsynchronous];
}

- (void)getWinDetailMessageFailed:(ASIFormDataRequest *)request {
    
}

- (void)getWinDetailMessageFinshed:(ASIFormDataRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        [_winDetailDict removeAllObjects];
        [_winDetailDict addEntriesFromDictionary:responseDic];
        
        [self makeWinPubView];
    }
}

- (void)makeWinPubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat winPopubViewMinY = 80.0f;
    CGFloat winPopubViewWidth = 270.0f;
    CGFloat winPopubViewHeight = 175.0f;
    /********************** adjustment end ***************************/
    if (_winPopubView) {
        [_winPopubView removeFromSuperview];
        _winPopubView = nil;
    }
    
    NSArray *tmpSchemeList = [_winDetailDict objectForKey:@"schemeList"];
    
    NSInteger timeInt = [Globals timeConvertToIndegerWithStringWithStringTime:[_winDetailDict stringForKey:@"serverTime"] beforeMonth:6];
    
    NSMutableArray *schemeList = [NSMutableArray array];
    [CustomResultParser parseResult:tmpSchemeList withNormalOrderArray:schemeList timeInt:timeInt];
    
    if([schemeList count] == 0) {
        return;
    }
    
    NSDictionary *dicSection = [schemeList objectAtIndex:0];
    if ([dicSection count] == 0) {
        return;
    }
    NSDictionary *dicRow = [[dicSection objectForKey:@"dateDetail"] objectAtIndex:0];
    //winPopubView
    CGRect winPopubViewRect = CGRectMake((kWinSize.width - winPopubViewWidth) / 2, winPopubViewMinY, winPopubViewWidth, winPopubViewHeight);
    
    _winPopubView = [[WinPopubView alloc] initWithFrame:winPopubViewRect winMoney:[dicRow stringForKey:@"winMoneyNoWithTax"]];
    [_winPopubView setDelegate:self];
    [_winPopubView show];
    [_winPopubView release];
}

- (void)recordPushParameterRequest {
    if (_recordPushParametering || _globals.pushBaiDuAppId.length == 0 || _globals.pushBaiDuChannelid.length == 0 || _globals.pushBaiDuUserid.length == 0 || [UserInfo shareUserInfo].userID.length == 0) {
        return;
    }
    if (_recordPushParameterRequest) {
        [_recordPushParameterRequest clearDelegatesAndCancel];
        [_recordPushParameterRequest release];
        _recordPushParameterRequest = nil;
    }
    
    NSInteger isOpen = 1;
    NSInteger isWin = 1;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"]) {
        isOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"] integerValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"]) {
        isWin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"] integerValue];
    }
    
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    [infoDict setObject:[UserInfo shareUserInfo].userID forKey:@"UserId"];
    [infoDict setObject:_globals.pushBaiDuUserid forKey:@"ClientUserId"];
    [infoDict setObject:_globals.pushBaiDuChannelid forKey:@"ChannelId"];
    [infoDict setObject:@"4" forKey:@"DeviceType"];
    [infoDict setObject:[NSNumber numberWithInteger:isOpen] forKey:@"IsOpen"];
    [infoDict setObject:[NSNumber numberWithInteger:isWin] forKey:@"IsWin"];
    [infoDict setObject:@"1" forKey:@"Status"];
    
    _recordPushParametering = YES;
    
    
    _recordPushParameterRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_ServerRecordPushParameter userId:[UserInfo shareUserInfo].userID infoDict:infoDict]];
    [_recordPushParameterRequest setDelegate:self];
    [_recordPushParameterRequest setDidFinishSelector:@selector(recordPushParameterFinshed:)];
    [_recordPushParameterRequest setDidFailSelector:@selector(recordPushParameterFailed:)];
    [_recordPushParameterRequest startAsynchronous];
}

- (void)makeDetailInformationViewWithDict:(NSDictionary *)userInfo {
    if (!_selfDidEnterBackgroundReceivePush) {
        return;
    }
    _selfDidEnterBackgroundReceivePush = NO;
    NSDictionary *titleDetailDict = [userInfo objectForKey:@"aps"];
    NSString *messageContent = [[titleDetailDict stringForKey:@"alert"] copy];
    NSString *title = [[userInfo stringForKey:@"title"] copy];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:title == nil ? @"" : title forKey:@"title"];
    [title release];
    [dict setObject:messageContent == nil ? @"" : messageContent forKey:@"MessageContent"];
    [messageContent release];
    
    
    DetailInformationViewController *detailInformationViewController = [[DetailInformationViewController alloc] initWithDetailDictionary:dict withType:1];
    UIViewController *applicationViewController = nil;
    if (_currentPresentNavigationViewController) {
        applicationViewController = [_currentPresentNavigationViewController topViewController];
        
    } else {
        XFTabBarViewController *tabBarViewController = (XFTabBarViewController *)self.window.rootViewController;
        XFNavigationViewController *viewController = (XFNavigationViewController *)tabBarViewController.currentController;
        applicationViewController = [viewController topViewController];
    }
    
    [applicationViewController.navigationController pushViewController:detailInformationViewController animated:YES];
    [detailInformationViewController release];
    [dict release];
}

@end
