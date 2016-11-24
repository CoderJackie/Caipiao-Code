//
//  AppSettingViewController.m 个人中心－设置
//  TicketProject
//
//  Created by sls002 on 13-6-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140811 14:24（洪晓彬）：修改代码规范，改进生命周期，处理内存
//  20140811 14:34（洪晓彬）：进行ipad适配
//  20150820 08:57（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "AppSettingViewController.h"

#import "AboutUsViewController.h"
#import "FeedbackViewController.h"
#import "InformationListViewController.h"
#import "PushManageViewController.h"
#import "UpdatePasswordViewController.h"
#import "XFTabBarViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "MobClick.h"
#import "UMSocial.h"
#import "UserInfo.h"
#import "UserSettingUtility.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

#define AppSettingViewCellHeight (IS_PHONE ? 45.0f : 65.0f)

@interface AppSettingViewController ()
/** 获取未读信息 数目 */
- (void)loadUnreadInformationCount;
@end

#pragma mark -
#pragma mark @implementation AppSettingViewController
@implementation AppSettingViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"设置"];
        _firstRequestUpdate = YES;
        if ([kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
            _titleArray = [[NSArray alloc]initWithObjects:@"消息中心",@"推送管理",@"分享",@"修改密码",@"反馈建议",@"检查更新",@"摇一摇机选",@"选号震动",@"关于我们", nil];
            [self loadInfo];
        } else {
            _titleArray = [[NSArray alloc]initWithObjects:@"消息中心",@"推送管理",@"分享",@"修改密码",@"反馈建议",@"摇一摇机选",@"选号震动",@"关于我们", nil];
        }
    }
    return self;
}

- (void)dealloc {
    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nil;
    _tableListView = nil;
    _updateSignImageView = nil;
    _shakeSwitch = nil;
    _switchBtn = nil;
    
    [_titleArray release];
    _titleArray = nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
	[baseView release];
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat tableViewMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat tableViewMinY = IS_PHONE ? 10.0f : 20.0f;
    
    NSInteger maxCount = IS_IOS7 ? 9 : 8;
    NSInteger maxCountHeight = ([_titleArray count] > maxCount ? maxCount : [_titleArray count]);
    
    CGFloat tableViewHeight = AppSettingViewCellHeight * maxCountHeight;
    
    CGFloat tableViewMaginBtn = IS_PHONE ? 13.0f : 20.0f;
    CGFloat outBtnHeight = IS_PHONE ? 40.0f : 60.0f;
    /********************** adjustment end ***************************/
    
    CGRect tableListViewRect = CGRectMake(tableViewMinX, tableViewMinY, CGRectGetWidth(appRect) - tableViewMinX * 2, tableViewHeight);
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:tableListViewRect];
    [backImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"setting.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:backImageView];
    [backImageView release];
    
    //tableListView 表格视图
    _tableListView = [[UITableView alloc]initWithFrame:tableListViewRect style:UITableViewStylePlain];
    [_tableListView setBackgroundColor:[UIColor clearColor]];
    [_tableListView setDataSource:self];
    [_tableListView setDelegate:self];
    [_tableListView setScrollEnabled:[_titleArray count] > maxCountHeight];
    [_tableListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableListView];
    [_tableListView release];
    
    //outBtn
    CGRect outBtnRect = CGRectMake(CGRectGetMinX(tableListViewRect), CGRectGetMaxY(tableListViewRect) + tableViewMaginBtn, CGRectGetWidth(tableListViewRect), outBtnHeight);
    UIButton *outBtn = [[UIButton alloc] initWithFrame:outBtnRect];
    [outBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [outBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [outBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [outBtn setTitleColor:[UIColor colorWithRed:64.0f/256.0f green:99.0f/256.0f blue:151.0f/256.0f alpha:1.0f] forState:UIControlStateNormal];
    [outBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [outBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [outBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize13]];
    [outBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:outBtn];
    [outBtn release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    
    _hasUpdate = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:YES];
    [self loadUnreadInformationCount];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _tableListView = nil;
        
        _shakeSwitch = nil;
        _switchBtn = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [self clearCheckUpdateRequest];
    [UMSocialWechatHandler setWXAppId:WXAPPKEY appSecret:WXAPPKEYSECRET url:kWebSite];
    //分享设置  设置qq互联和qq应用appkey
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:TENCENTAPPKEY url:kWebSite];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) {
        InformationListViewController *informationListView = [[InformationListViewController alloc]init];
        [self.navigationController pushViewController:informationListView animated:YES];
        [informationListView release];
        
    } else if (indexPath.row == 1) {
        PushManageViewController *pushManageViewController = [[PushManageViewController alloc] init];
        [self.navigationController pushViewController:pushManageViewController animated:YES];
        [pushManageViewController release];
        
    } else if(indexPath.row == 2) {
        
        NSString *shareText = kWebSite;
        
        if([kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
            [UMSocialWechatHandler setWXAppId:WXAPPKEY appSecret:WXAPPKEYSECRET url:[NSString stringWithFormat:@"%@/clientsoft/download.aspx",kWebSite]];
            //分享设置  设置qq互联和qq应用appkey
            [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:TENCENTAPPKEY url:[NSString stringWithFormat:@"%@/clientsoft/download.aspx",kWebSite]];
            shareText = [NSString stringWithFormat:@"%@/clientsoft/download.aspx",kWebSite];
        }
        
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UMAPPKEY
                                          shareText:[NSString stringWithFormat:@"%@:%@",FenXiangName,shareText]
                                         shareImage:[UIImage imageNamed:@"Icon.png"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToSina,UMShareToRenren,UMShareToDouban,UMShareToSms,UMShareToEmail,nil]
                                           delegate:self];
        
    } else if (indexPath.row == 3) {
        UpdatePasswordViewController *updatePasswordViewController = [[UpdatePasswordViewController alloc] init];
        [self.navigationController pushViewController:updatePasswordViewController animated:YES];
        [updatePasswordViewController release];
        
    } else if (indexPath.row == 4) {
        FeedbackViewController *feedBack = [[FeedbackViewController alloc]init];
        [self.navigationController pushViewController:feedBack animated:YES];
        [feedBack release];
        
    } else if (indexPath.row == 5 && [kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
        [SVProgressHUD showWithStatus:@"正在检测更新"];
        [self loadInfo];
    } else if (indexPath.row == ([_titleArray count] - 1)) {
        AboutUsViewController *aboutUsViewController = [[AboutUsViewController alloc]init];
        [self.navigationController pushViewController:aboutUsViewController animated:YES];
        [aboutUsViewController release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AppSettingViewCellHeight;
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AppSettingViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat promptLabelMinX = IS_PHONE ? 90.0f : 150.0f;
        CGFloat promptLabelWidth = IS_PHONE ? 100.0f : 200.0f;
        /********************** adjustment end ***************************/
        //
        [cell.textLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        
        CGRect promptLabelRect = CGRectMake(promptLabelMinX, 0, promptLabelWidth, AppSettingViewCellHeight);
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
        [promptLabel setBackgroundColor:[UIColor clearColor]];
        [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [promptLabel setTextColor:kGrayColor];
        [promptLabel setTag:101];
        [cell.contentView addSubview:promptLabel];
        [promptLabel release];
        
        //backImageView
        CGRect backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AppSettingViewCellHeight);
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
        [backImageView setTag:100];
        [cell.contentView addSubview:backImageView];
        [backImageView release];
    }
    
    UILabel *promptLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat leftSignImageViewMaginRightX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat leftSignImageViewWidth = IS_PHONE ? 15.0f : 22.5f;
    CGFloat leftSignImageViewHeight = IS_PHONE ? 14.0f : 21.0f;
    
    CGFloat updateSignImageViewSize = IS_PHONE ? 8.0f : 12.0f;
    
    CGFloat selectBtnMaginRight = IS_PHONE ? 10.0f : 20.0f;
    CGFloat selectBtnSign = IS_PHONE ? 25.0f : 40.0f;
    /********************** adjustment end ***************************/
    
    
    if (indexPath.row != 0) {
        //lineView
        CGRect lineViewRect = CGRectMake(0, 0, kWinSize.width, IS_PHONE ? 1.0f : 2.0f);
        UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
        [lineView setBackgroundColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f]];
        [cell addSubview:lineView];
        [lineView release];
    }
    
    if (indexPath.row == _titleArray.count - 2 || indexPath.row == _titleArray.count - 3) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    } else if (indexPath.row == _titleArray.count - 4 && [kCurrentCertificatetType isEqualToString:kEnterpriseCertificateString]) {
        [promptLabel setText:[NSString stringWithFormat:@"当前版本：%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]]];
        CGRect leftSignImageViewRect = CGRectMake(CGRectGetWidth(tableView.frame) - updateSignImageViewSize - leftSignImageViewMaginRightX, (AppSettingViewCellHeight - updateSignImageViewSize) / 2.0f , updateSignImageViewSize, updateSignImageViewSize);
        _updateSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
        [_updateSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"updateRedSign.png"]]];
        [_updateSignImageView setHidden:!_hasUpdate];
        [cell.contentView addSubview:_updateSignImageView];
        [_updateSignImageView release];
        
    } else {
        [promptLabel setText:@""];
        CGRect leftSignImageViewRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignImageViewWidth - leftSignImageViewMaginRightX, (AppSettingViewCellHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
        UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
        [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        [cell.contentView addSubview:leftSignImageView];
        [leftSignImageView release];
        
    }
    
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    if(indexPath.row == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"您有%ld条未读信息",(long)_unReadCount];
    }
    
    
    NSDictionary *def = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    
    CGRect selectBtnRect = CGRectMake(CGRectGetWidth(tableView.frame) - selectBtnSign - selectBtnMaginRight, (AppSettingViewCellHeight - selectBtnSign) / 2.0f, selectBtnSign, selectBtnSign);
    if(indexPath.row == _titleArray.count - 3) {//摇一摇开关
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:selectBtnRect];
        [selectBtn setSelected:([def intValueForKey:kIsShakeToSelect] == 1)];
        [selectBtn addTarget:self action:@selector(autoSelectValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Normal.png"]] forState:UIControlStateNormal];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateHighlighted];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateSelected];
        [cell.contentView addSubview:selectBtn];
        [selectBtn release];
    }
    if(indexPath.row == _titleArray.count - 2) {//震动开关
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:selectBtnRect];
        [selectBtn setSelected:([def intValueForKey:kIsShake] == 1)];
        [selectBtn addTarget:self action:@selector(shakeSwitchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Normal.png"]] forState:UIControlStateNormal];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateHighlighted];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateSelected];
        [cell.contentView addSubview:selectBtn];
        [selectBtn release];
    }
    
    
    return cell;
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    if(responseDic && [[responseDic stringForKey:@"msg"] isEqualToString:@""]) {
        NSArray *array = [responseDic objectForKey:@"stationSMSList"];
        if(array.count > 0) {
            NSDictionary *dic = [array objectAtIndex:0];
            
            _unReadCount = [dic intValueForKey:@"RecordCount"];
            [_shakeSwitch removeFromSuperview];
            [_switchBtn removeFromSuperview];
            [_tableListView reloadData];
        }
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic stringForKey:@"msg"]];
    }
}

- (void)checkNewFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"检测失败"];
}

- (void)checkNewFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"检测成功"];
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    if (responseDic && [[responseDic stringForKey:@"upgrade"] isEqualToString:@"True"]) {
        _automaticUpdateAppID = [[NSString stringWithFormat:@"%@",[responseDic stringForKey:@"appid"]] retain];  //如果是公司或个人的证书，只返回appid，企业的只返回url
        _automaticUpdateUrl = [[NSString stringWithFormat:@"%@",[responseDic stringForKey:@"url"]] retain];
        if (!_firstRequestUpdate) {
            [Globals alertWithMessage:@"有新版本,是否更新!" delegate:self tag:0];
        }
        
        [_updateSignImageView setHidden:NO];
    } else {
        [_updateSignImageView setHidden:YES];
        if (!_firstRequestUpdate) {
            [Globals alertWithMessage:@"暂无版本更新"];
        }
    }
    _firstRequestUpdate = NO;
}

#pragma mark -UMSocialUIDelegate
- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData {
    if([platformName isEqualToString:@"qzone"]) {

    } else {
        
    }
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    
}

#pragma mark -UIAlertViewDelegate
- (void)customAlertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        if ([kCurrentCertificatetType isEqualToString:@"person"] || [kCurrentCertificatetType isEqualToString:@"company"]) {
            [self openAppWithIdentifier:_automaticUpdateAppID == nil ? @"" : _automaticUpdateAppID];
        } else if ([kCurrentCertificatetType isEqualToString:@"enterprise"]) {
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

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBack:(id)sender {
    [self.xfTabBarController setTabBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//退出登陆
- (void)logout:(id)sender {
    [UserInfo shareUserInfo].userID = nil;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kIsStorePassword];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [XYMKeyChain deleteKeyChainItemWithKey:KEY_KEYCHAINITEM];
    
    
    [self dismissViewControllerAnimated:YES completion:^(){
        [self.xfTabBarController setTabBarHidden:NO];
        [self.xfTabBarController setSelectControllerIndex:1];
    }];
}

//摇一摇震动功能开关
- (void)shakeSwitchValueChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:![btn isSelected]];
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:defaults];
    [tmp setObject:[NSNumber numberWithBool:[btn isSelected]] forKey:kIsShake];
    [[NSUserDefaults standardUserDefaults] setObject:tmp forKey:kDefaultSettings];
}

//摇一摇机选功能开关
- (void)autoSelectValueChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:![btn isSelected]];
    _globals.isShake = [btn isSelected];
    
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultSettings];
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:defaults];
    [tmp setObject:[NSNumber numberWithBool:[btn isSelected]] forKey:kIsShakeToSelect];
    [[NSUserDefaults standardUserDefaults] setObject:tmp forKey:kDefaultSettings];
}

//获取版本信息进行判断
- (void)loadInfo {
    [self clearCheckUpdateRequest];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"IOS" forKey:@"identify"];
    [dict setObject:@"1" forKey:@"type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [dict setObject:version == nil ? @"" : version forKey:@"appversion"];
    [dict setObject:kCurrentCertificatetType forKey:kCertificatetType];
    _checkUpdateRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_UpdateAndHide userId:[UserInfo shareUserInfo].userID infoDict:dict]];
    [_checkUpdateRequest setDelegate:self];
    [_checkUpdateRequest setDidFinishSelector:@selector(checkNewFinished:)];
    [_checkUpdateRequest setDidFailSelector:@selector(checkNewFailed:)];
    [_checkUpdateRequest startAsynchronous];
    [dict release];
}

- (void)clearCheckUpdateRequest {
    if (_checkUpdateRequest != nil) {
        [_checkUpdateRequest clearDelegatesAndCancel];
        [_checkUpdateRequest release];
        _checkUpdateRequest = nil;
    }
}

//获取未读信息 数目
- (void)loadUnreadInformationCount {
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"0" forKey:@"typeId"];
    [infoDic setObject:@"1" forKey:@"pageIndex"];
    [infoDic setObject:@"10" forKey:@"pageSize"];
    [infoDic setObject:@"0" forKey:@"isRead"];
    [infoDic setObject:@"0" forKey:@"sortType"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetMessageCenterAndReadState userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    [storeProductViewController setDelegate:self];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductViewController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [self.view.window.rootViewController presentViewController:storeProductViewController animated:YES completion:nil];
        }
    }];
}

@end
