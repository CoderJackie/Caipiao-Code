//
//  UserLoginViewController.m 个人中心－登录
//  TicketProject
//
//  Created by sls002 on 13-5-31.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140809 09:12（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140809 10:58（洪晓彬）：进行ipad适配
//  20150819 10:30（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "UserLoginViewController.h"
#import "ForgetPasswordViewController.h"
#import "MyTicketsViewController.h"
#import "UserRegisteViewController.h"
#import "UserPhoneRegisteViewController.h"
#import "XFTabBarViewController.h"
#import "XFNavigationViewController.h"
#import "SVProgressHUD.h"
#import "PicTableViewCell.h"

#import "AppDelegate.h"
#import "CustomResultParser.h"
#import "InterfaceHelper.h"
#import "InterfaceHeader.h"
#import "Globals.h"
#import "Reachability.h"
#import "SecretUtility.h"
#import "UserInfo.h"


@interface UserLoginViewController (){
    NSInteger _selectedRow;
}

@end

#pragma mark -
#pragma mark @implementation UserLoginViewController
@implementation UserLoginViewController
#pragma mark Lifecircle

@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"登录"];
        _selectedRow = -1;
    }
    return self;
}

//- (void)dealloc {
//    [MyAppDelegate shareAppDelegate].currentPresentNavigationViewController = nil;
//    _userNameField = nil;
//    _passwordField = nil;
//    [_Picarray release];
//    _Picarray = nil;
//    [_Myarray release];
//    _Myarray = nil;
//    [_userInfoDictionary release];
//    _userInfoDictionary = nil;
//    [super dealloc];
//}

- (void)loadView {
    
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
//	[baseView release];
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
//    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat fieldImageViewMinY = IS_PHONE ? 25.0f : 40.0f;
    CGFloat fieldImageViewWidth = IS_PHONE ? 300.0f : 600.0f;
    CGFloat fielfImageViewHeight = IS_PHONE ? 43.0f : 83.0f;
    CGFloat fieldImageViewsVerticalInterval = IS_PHONE ? 15.0f : 25.0f;
    
    CGFloat promptImageViewAddX = IS_PHONE ? 13.0f : 18.0f;
    CGFloat promptImageViewAddY = IS_PHONE ? 10.0f : 25.0f;
    CGFloat promptImageViewSize = IS_PHONE ? 18.0f : 30.0f;
    
    CGFloat lineViewWidth = IS_PHONE ? 1.0f : 2.0f;
    CGFloat lineViewHeight = IS_PHONE ? 18.0f : 30.0f;
    
    CGFloat fieldTextAddX = IS_PHONE ? 14.0f : 20.0f;
    
    CGFloat rememberBtnAddY = IS_PHONE ? 12.5f : 20.0f;
    CGFloat rememberBtnSize = IS_PHONE ? 20.0f : 40.0f;
    
    CGFloat rememberPromptLabelAddX = IS_PHONE ? 5.0f : 15.0f;
    CGFloat rememberLabelHeight = IS_PHONE ? 21.0f : 40.0f;
    
    CGFloat findPasswordBtnWidth = IS_PHONE ? 60.0f : 90.0f;
    CGFloat findPassWordUnderLineViewMinY = IS_PHONE ? 15.0f : 30.0f;
    
    CGFloat loginBtnAddY = IS_PHONE ? 15.0f : 30.0f;
    CGFloat loginBtnHeight = IS_PHONE ? 40.0f : 66.0f;
    
    CGFloat btnsVerticalInterval = IS_PHONE ? 17.0f : 28.0f;
    /********************** adjustment end ***************************/
    
    //userNameImageViewRect 背景图
    CGRect userNameImageViewRect = CGRectMake((CGRectGetWidth(appRect) - fieldImageViewWidth) / 2.0f, fieldImageViewMinY, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *userNameImageView = [[UIImageView alloc] initWithFrame:userNameImageViewRect];
    [userNameImageView setUserInteractionEnabled:YES];
    [userNameImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:userNameImageView];
//    [userNameImageView release];
    
    //userNameImageView
    CGRect userNamePromptImageViewRect = CGRectMake(CGRectGetMinX(userNameImageViewRect) + promptImageViewAddX, CGRectGetMinY(userNameImageViewRect) + promptImageViewAddY, promptImageViewSize, promptImageViewSize);
    UIImageView * userNamePromptImageView = [[UIImageView alloc] initWithFrame:userNamePromptImageViewRect];
    [userNamePromptImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"userNamePrompt.png"]]];
    [self.view addSubview:userNamePromptImageView];
//    [userNamePromptImageView release];
    
    //userNamelLineView
    CGRect userNameLineViewRect = CGRectMake(CGRectGetMaxX(userNamePromptImageViewRect) + promptImageViewAddX, CGRectGetMinY(userNameImageViewRect) + (fielfImageViewHeight - lineViewHeight)/ 2.0f, lineViewWidth, lineViewHeight);
    UIView *userNameLineView = [[UIView alloc] initWithFrame:userNameLineViewRect];
    [userNameLineView setBackgroundColor:[UIColor colorWithRed:0xcc/255.0f green:0xcc/255.0f blue:0xcc/255.0f alpha:1.0f]];
    [self.view addSubview:userNameLineView];
//    [userNameLineView release];
    
    //userNameField 用户名输入框
    CGRect userNameFieldRect = CGRectMake(CGRectGetMaxX(userNameLineViewRect) + fieldTextAddX, CGRectGetMinY(userNameImageViewRect), CGRectGetWidth(appRect) - CGRectGetMaxX(userNameLineViewRect) - CGRectGetMinX(userNameImageViewRect) - fieldTextAddX, CGRectGetHeight(userNameImageViewRect));
    _userNameField = [[UITextField alloc] initWithFrame:userNameFieldRect];
    [_userNameField setPlaceholder:@"用户名"];
    [_userNameField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_userNameField setText:@"老烟枪"];
    [_userNameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:_userNameField];
//    [_userNameField release];
    
    //passwordImageView
    CGRect passwordImageViewRect = CGRectMake(CGRectGetMinX(userNameImageViewRect), CGRectGetMaxY(userNameImageViewRect) + fieldImageViewsVerticalInterval, fieldImageViewWidth, fielfImageViewHeight);
    UIImageView *passwordImageView = [[UIImageView alloc] initWithFrame:passwordImageViewRect];
    [passwordImageView setUserInteractionEnabled:YES];
    [passwordImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
    [self.view addSubview:passwordImageView];
//    [passwordImageView release];
    
    //passwordPromptImageView
    CGRect passwordPromptImageViewRect = CGRectMake(CGRectGetMinX(passwordImageViewRect) + promptImageViewAddX, CGRectGetMinY(passwordImageViewRect) + promptImageViewAddY, promptImageViewSize, promptImageViewSize);
    UIImageView * passwordPromptImageView = [[UIImageView alloc] initWithFrame:passwordPromptImageViewRect];
    [passwordPromptImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"passwordPrompt.png"]]];
    [self.view addSubview:passwordPromptImageView];
//    [passwordPromptImageView release];
    
    //passwordLineView
    CGRect passwordLineViewRect = CGRectMake(CGRectGetMaxX(passwordPromptImageViewRect) + promptImageViewAddX, CGRectGetMinY(passwordImageViewRect) + (fielfImageViewHeight - lineViewHeight)/ 2.0f, lineViewWidth, lineViewHeight);
    UIView *passwordLineView = [[UIView alloc] initWithFrame:passwordLineViewRect];
    [passwordLineView setBackgroundColor:[UIColor colorWithRed:0xcc/255.0f green:0xcc/255.0f blue:0xcc/255.0f alpha:1.0f]];
    [self.view addSubview:passwordLineView];
//    [passwordLineView release];
    
    //passwordField 密码输入框
    CGRect passwordFieldRect = CGRectMake(CGRectGetMinX(passwordLineViewRect) + fieldTextAddX, CGRectGetMinY(passwordImageViewRect), CGRectGetWidth(appRect) - CGRectGetMinX(passwordLineViewRect) - fieldTextAddX - CGRectGetMinX(passwordImageViewRect), CGRectGetHeight(passwordImageViewRect));
    _passwordField = [[UITextField alloc] initWithFrame:passwordFieldRect];
    [_passwordField setPlaceholder:@"密码"];
    [_passwordField setSecureTextEntry:YES];
    [_passwordField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_passwordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:_passwordField];
//    [_passwordField release];
    
    //rememberBtn
    CGRect rememberBtnRect = CGRectMake(CGRectGetMinX(passwordImageViewRect), CGRectGetMaxY(passwordImageViewRect) + rememberBtnAddY, rememberBtnSize, rememberBtnSize);
    _rememberBtn = [[UIButton alloc] initWithFrame:rememberBtnRect];
    [_rememberBtn addTarget:self action:@selector(rememberBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_rememberBtn setSelected:YES];
    [_rememberBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Normal.png"]] forState:UIControlStateNormal];
    [_rememberBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateHighlighted];
    [_rememberBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateSelected];
    [self.view addSubview:_rememberBtn];
//    [_rememberBtn release];
    
    //rememberLabel
    CGRect rememberLabelRect = CGRectMake(CGRectGetMaxX(rememberBtnRect) + rememberPromptLabelAddX, CGRectGetMinY(rememberBtnRect) + (rememberLabelHeight - rememberBtnSize) / 2.0f, CGRectGetWidth(passwordImageViewRect) - CGRectGetMaxX(rememberBtnRect) - rememberPromptLabelAddX, rememberLabelHeight);
    UILabel *rememberLabel = [[UILabel alloc] initWithFrame:rememberLabelRect];
    [rememberLabel setBackgroundColor:[UIColor clearColor]];
    [rememberLabel setText:@"记住密码"];
    [rememberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [self.view addSubview:rememberLabel];
//    [rememberLabel release];
    
    //findPasswordButton
    CGRect findPasswordBtnRect = CGRectMake(CGRectGetMaxX(passwordFieldRect) - findPasswordBtnWidth, CGRectGetMinY(rememberBtnRect), findPasswordBtnWidth, CGRectGetHeight(rememberBtnRect));
    UIButton *findPasswordBtn = [[UIButton alloc] initWithFrame:findPasswordBtnRect];
    [findPasswordBtn setBackgroundColor:[UIColor clearColor]];
    [findPasswordBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize12]];
    [findPasswordBtn.titleLabel setTextColor:[UIColor colorWithRed:23.0f/255.0f green:76.0f/255.0f blue:187.0f/255.0f alpha:1.0f]];
    [findPasswordBtn setTitleColor:[UIColor colorWithRed:23.0f/255.0f green:76.0f/255.0f blue:187.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [findPasswordBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [findPasswordBtn addTarget:self action:@selector(forgetPasswordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findPasswordBtn];
//    [findPasswordBtn release];
    
    //findPassWordUnderLineImageView
    CGRect findPassWordUnderLineViewRect = CGRectMake(0, findPassWordUnderLineViewMinY, CGRectGetWidth(findPasswordBtnRect), AllLineWidthOrHeight);
    UIView *findPassWordUnderLineView = [[UIView alloc] initWithFrame:findPassWordUnderLineViewRect];
    [findPassWordUnderLineView setBackgroundColor:[UIColor colorWithRed:23.0f/255.0f green:76.0f/255.0f blue:187.0f/255.0f alpha:1.0f]];
    [findPasswordBtn addSubview:findPassWordUnderLineView];
//    [findPassWordUnderLineView release];
    
    //loginButton 登录按钮
    CGRect loginButtonRect = CGRectMake(CGRectGetMinX(passwordImageViewRect), CGRectGetMaxY(rememberBtnRect) + loginBtnAddY, CGRectGetWidth(passwordImageViewRect), loginBtnHeight);
    UIButton *loginButton = [[UIButton alloc] initWithFrame:loginButtonRect];
    [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [loginButton.titleLabel setTextColor:[UIColor whiteColor]];
    [loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
//    [loginButton release];
    
    //registeBtn
    CGRect registeBtnRect = CGRectMake(CGRectGetMinX(loginButtonRect), CGRectGetMaxY(loginButtonRect) + btnsVerticalInterval, CGRectGetWidth(loginButtonRect), CGRectGetHeight(loginButtonRect));
    UIButton *registeBtn = [[UIButton alloc] initWithFrame:registeBtnRect];
    [registeBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
    [registeBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [registeBtn setTitleColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    [registeBtn setTitle:@"还没有三亿彩账号？立即注册" forState:UIControlStateNormal];
    [registeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [registeBtn addTarget:self action:@selector(registe:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registeBtn];
//    [registeBtn release];
    
    //tap 用来收回键盘的手势点击动作
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setDelegate:self];
//    [self.view addGestureRecognizer:tap];
//    [tap release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pagecount = 0;
    _Btnarray = [[NSMutableArray alloc]init];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    
    _isStorePassword = YES;
    _userInfoDictionary = [[NSMutableDictionary alloc] init];
    NSUserDefaults *faults = [NSUserDefaults standardUserDefaults];
    if (![faults objectForKey:kIsStorePassword]) {
        [faults setObject:@"0" forKey:kIsStorePassword];
    }
    if (![faults objectForKey:kUsername]) {
        [faults setObject:@"" forKey:kUsername];
    }
    
}
- (void)createBgview
{
    _Myarray = @[@"深圳市宝安金菊花园彩票店",@"北京罗森彩吧",@"杭州千岛湖彩票店",@"成都双流腾龙路体彩店",@"上海市友谊路投注站",@"广州黄石机场路彩票店"];
    _Picarray = @[@"lotteryfacade_1.png",@"lotteryfacade_2.png",@"lotteryfacade_4.png",@"lotteryfacade_5.png",@"lotteryfacade_6.png",@"lotteryfacade_7.png"];
    _Bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _Mytableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _Bgview.frame.size.width, _Bgview.frame.size.height)style:UITableViewStyleGrouped];
    _Mytableview.delegate = self;
    _Mytableview.dataSource = self;
    _Bgview.backgroundColor = [UIColor whiteColor];
    
    [self setTitle:@"彩票站"];
    [_Bgview addSubview:_Mytableview];
    [self.view addSubview:_Bgview];

}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *selecview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(self.view.bounds.size.width/2-60, 10, 120, 40);
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 20;
    [selecview addSubview:btn];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(footerselect) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    return selecview;
}
-(void)footerselect
{
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    if (_userNameField.text.length == 0 || _passwordField.text.length == 0) {
        return;
    }
    [SVProgressHUD show];
    
    NSString *userName = _userNameField.text;
    NSString *password = _passwordField.text;
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:userName forKey:@"name"];
    [infoDic setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",password,kAppKey]] forKey:@"password"];
    
    [self clearHTTPRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_Login userId:@"-1" infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];

}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"picCell";
    PicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[PicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier target:self];
        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.myimage.image = [UIImage imageNamed:_Picarray[indexPath.row]];
        cell.title.text = _Myarray[indexPath.row];
        [cell.btn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell.btn setBackgroundImage:[UIImage imageNamed:@"lotteryfacade_select.png"] forState:UIControlStateSelected];
        cell.btn.tag = 100 +indexPath.row;
        [cell.btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_Btnarray addObject:cell.btn];
        
        if (_selectedRow > -1) {
            [cell.btn setSelected:indexPath.row == _selectedRow];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击cell");
    UIButton *btn = (UIButton *)[self.view viewWithTag:100+indexPath.row];
    for (UIButton *button in _Btnarray) {
        button.selected = NO;
    }
    btn.selected = YES;
    _selectedRow = indexPath.row;
}
-(void)onClick:(UIButton *)sender
{
    for (UIButton *button in _Btnarray) {
        button.selected = NO;
    }
    sender.selected = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _userNameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    _passwordField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lightPassword"];
    
    if (_userNameField.text.length > 0) {
        [_passwordField becomeFirstResponder];
    } else {
        [_userNameField becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self autoLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _userNameField = nil;
        _passwordField = nil;
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    
    [self clearHTTPRequest];
    [self clearRecordPushRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dismissViewController:(id)sender {
    XFNavigationViewController *currentNavigationViewController = (XFNavigationViewController *)self.xfTabBarController.currentController;
    if([currentNavigationViewController.topViewController isKindOfClass:[MyTicketsViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:^ () {
            [self.xfTabBarController setSelectControllerIndex:1];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma Delegate
#pragma mark -
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"登录失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if ([responseDic count] == 0) {
        [SVProgressHUD showErrorWithStatus:@"网络连接失败，请稍后再试"];
        return;
    }
    if([[responseDic objectForKey:@"error"] intValue] == 0) {
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        
        //再解析
        [CustomResultParser parseResult:responseDic toUserInfoDict:_userInfoDictionary];
        //记住密码后 把密码保存在钥匙串中
        if(_isStorePassword) {
            // 保存用户名和密码在钥匙串
            NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
            [itemData setObject:_userNameField.text forKey:KEY_USERNAME];
            [itemData setObject:_passwordField.text forKey:KEY_PASSWORD];
            [XYMKeyChain saveKeyChainItemWithKey:KEY_KEYCHAINITEM item:itemData];
        }
        
        [UserInfo shareUserInfo].userID = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"uid"]];
        [UserInfo shareUserInfo].userName = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"name"]];
        [UserInfo shareUserInfo].password = [InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_passwordField.text,kAppKey]];;
        [_userInfoDictionary setObject:_passwordField.text forKey:@"password"];
        [UserInfo shareUserInfo].realName = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"realityName"]];
        [UserInfo shareUserInfo].cardNumber = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"idcardnumber"]];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"balance"]];
        [UserInfo shareUserInfo].freeze = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"freeze"]];
        [UserInfo shareUserInfo].phoneNumber = [_userInfoDictionary stringForKey:@"mobile"];
        [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[_userInfoDictionary objectForKey:@"handselAmount"]];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lightPassword"];
        [[NSUserDefaults standardUserDefaults] setObject:_userInfoDictionary forKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults] setObject:_userNameField.text forKey:kUsername];
        
        _globals.isStorePassword = _isStorePassword;
        if (_isStorePassword)
        [[NSUserDefaults standardUserDefaults] setObject:_passwordField.text forKey:@"lightPassword"];
        [[NSUserDefaults standardUserDefaults] setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",_passwordField.text,kAppKey]] forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [self selectItemAndRequestRecordPushParameter];
        
    } else {
        [SVProgressHUD showErrorWithStatus:[responseDic objectForKey:@"msg"]];
    }

}

- (void)getAutoFinshed:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];

    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        //再解析
        NSMutableDictionary *autoLoginDict = [[NSMutableDictionary alloc] init];
        
        [CustomResultParser parseResult:responseDic toUserInfoDict:autoLoginDict];
        
        [UserInfo shareUserInfo].userID = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"uid"]];
        [UserInfo shareUserInfo].userName = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"name"]];
        [UserInfo shareUserInfo].realName = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"realityName"]];
        [UserInfo shareUserInfo].cardNumber = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"idcardnumber"]];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"balance"]];
        [UserInfo shareUserInfo].freeze = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"freeze"]];
        [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[autoLoginDict objectForKey:@"handselAmount"]];
        if ([_rememberBtn isSelected]) {
            [[NSUserDefaults standardUserDefaults] setObject:autoLoginDict forKey:@"userinfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
//        [autoLoginDict release];
        
        [self selectItemAndRequestRecordPushParameter];
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }

    [SVProgressHUD dismiss];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
            [self createBgview];
        }
    });
}

- (void)getAutoFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"登录失败"];
}

- (void)recordPushParameterFinshed:(ASIFormDataRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
    }
    
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)recordPushParameterFailed:(ASIFormDataRequest *)request {
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)rememberBtnTouchUpInside:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:![btn isSelected]];
    _isStorePassword = [btn isSelected];
}

- (void)forgetPasswordTouchUpInside:(id)sender {
    ForgetPasswordViewController *forgetPasswordViewController = [[ForgetPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgetPasswordViewController animated:YES];
//    [forgetPasswordViewController release];
}

- (void)loginTouchUpInside:(id)sender {
  AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    if (appDelegate.mycount > 0) {
        [_userNameField resignFirstResponder];
        [_passwordField resignFirstResponder];
        if (_userNameField.text.length == 0 || _passwordField.text.length == 0) {
            return;
        }
        [SVProgressHUD show];
        
        NSString *userName = _userNameField.text;
        NSString *password = _passwordField.text;
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:userName forKey:@"name"];
        [infoDic setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",password,kAppKey]] forKey:@"password"];
        
        [self clearHTTPRequest];
        
        _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_Login userId:@"-1" infoDict:infoDic]];
        [_httpRequest setDelegate:self];
        [_httpRequest startAsynchronous];

    }
    
    appDelegate.mycount ++;

    

}

- (void)registe:(id)sender {
    UserPhoneRegisteViewController *registe = [[UserPhoneRegisteViewController alloc]init];
    [self.navigationController pushViewController:registe animated:YES];
//    [registe release];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

#pragma mark -Customized: Private (General)
- (void)selectItemAndRequestRecordPushParameter {
    [self recordPushParameterRequest];
    
    if (_isNeedDelegate && [_delegate respondsToSelector:@selector(userDidLoginSuccess)])
        [_delegate userDidLoginSuccess];
}

- (void)autoLogin {
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kUsername];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (username.length == 0 || password.length == 0) {
        return;
    }
    
    [_userNameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    
    [SVProgressHUD show];
    
    if (username.length > 0 && password.length > 0) {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:username forKey:@"name"];
        [infoDic setObject:password forKey:@"password"];
        [UserInfo shareUserInfo].password = password;
        [self clearHTTPRequest];
        
        _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_Login userId:@"-1" infoDict:infoDic]];
        [_httpRequest setDelegate:self];
        [_httpRequest setDidFinishSelector:@selector(getAutoFinshed:)];
        [_httpRequest setDidFailSelector:@selector(getAutoFailed:)];
        [_httpRequest startAsynchronous];
    }
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
//        [_httpRequest release];
        _httpRequest = nil;
    }
}
//
- (void)recordPushParameterRequest {
    if (_globals.pushBaiDuAppId.length == 0 || _globals.pushBaiDuChannelid.length == 0 || _globals.pushBaiDuUserid.length == 0 || [UserInfo shareUserInfo].userID.length == 0) {
       
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSInteger isOpen = 1;
    NSInteger isWin = 1;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"]) {
        isOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"] integerValue];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"]) {
        isWin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"] integerValue];
    }
    
    [self clearRecordPushRequest];
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    [infoDict setObject:[UserInfo shareUserInfo].userID forKey:@"UserId"];
    [infoDict setObject:_globals.pushBaiDuUserid forKey:@"ClientUserId"];
    [infoDict setObject:_globals.pushBaiDuChannelid forKey:@"ChannelId"];
    [infoDict setObject:@"4" forKey:@"DeviceType"];
    [infoDict setObject:[NSNumber numberWithInteger:isOpen] forKey:@"IsOpen"];
    [infoDict setObject:[NSNumber numberWithInteger:isWin] forKey:@"IsWin"];
    [infoDict setObject:@"1" forKey:@"Status"];
    
    _recordPushParameterRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_ServerRecordPushParameter userId:[UserInfo shareUserInfo].userID infoDict:infoDict]];
    [_recordPushParameterRequest setDelegate:self];
    [_recordPushParameterRequest setDidFinishSelector:@selector(recordPushParameterFinshed:)];
    [_recordPushParameterRequest setDidFailSelector:@selector(recordPushParameterFailed:)];
    [_recordPushParameterRequest startAsynchronous];
}

- (void)clearRecordPushRequest {
    if (_recordPushParameterRequest != nil) {
        [_recordPushParameterRequest clearDelegatesAndCancel];
//        [_recordPushParameterRequest release];
        _recordPushParameterRequest = nil;
    }
}

@end
