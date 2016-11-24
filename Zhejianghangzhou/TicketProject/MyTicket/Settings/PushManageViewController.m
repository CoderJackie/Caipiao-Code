//
//  PushManageViewController.m  个人中心－设置－推送管理
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "PushManageViewController.h"
#import "Globals.h"
#import "UserInfo.h"

#define PushManageViewCellHeight (IS_PHONE ? 50.0f : 80.0f)

@interface PushManageViewController ()

@end

#pragma mark -
#pragma mark @implementation PushManageViewController
@implementation PushManageViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"推送管理"];
        _operationing = NO;
        _titleArray = [[NSArray alloc] initWithObjects:@"开奖推送",@"中奖推送", nil];
    }
    return self;
}

- (void)dealloc {
    [_titleArray release];
    _titleArray = nil;
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
    appRect.origin.y = 0;
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
	[baseView release];
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(dismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat tableViewMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat tableViewMinY = IS_PHONE ? 10.0f : 20.0f;
    CGFloat tableViewHeight = PushManageViewCellHeight * [_titleArray count];
    
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
    [_tableListView setScrollEnabled:NO];
    [_tableListView setClipsToBounds:YES];
    [_tableListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableListView];
    [_tableListView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    _operationing = NO;
    [Globals alertWithMessage:@"连接失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    _operationing = NO;
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        
        
    } else if (responseDic) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
    }
}

#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PushManageViewCellHeight;
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PushManageViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        //
        [cell.textLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        
        //backImageView
        CGRect backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), PushManageViewCellHeight);
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
        [backImageView setTag:100];
        [cell.contentView addSubview:backImageView];
        [backImageView release];
    }
    
    /********************** adjustment 控件调整 ***************************/
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
    if (indexPath.row == 0 || indexPath.row == 1) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    
    CGRect selectBtnRect = CGRectMake(CGRectGetWidth(tableView.frame) - selectBtnSign - selectBtnMaginRight, (PushManageViewCellHeight - selectBtnSign) / 2.0f, selectBtnSign, selectBtnSign);
    if(indexPath.row == 0) {//开奖推送
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:selectBtnRect];
        [selectBtn setClipsToBounds:YES];
        [selectBtn setSelected:YES];
        [selectBtn addTarget:self action:@selector(pushOpenSelectValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Normal.png"]] forState:UIControlStateNormal];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateHighlighted];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateSelected];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"]) {
            NSInteger isWin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"] integerValue];
            [selectBtn setSelected:isWin == 1];
        }
        [cell.contentView addSubview:selectBtn];
        [selectBtn release];
    }
    if(indexPath.row == 1) {//中奖推送
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:selectBtnRect];
        [selectBtn setSelected:YES];
        [selectBtn addTarget:self action:@selector(pushWinSelectValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Normal.png"]] forState:UIControlStateNormal];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateHighlighted];
        [selectBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"selectBtn_Select.png"]] forState:UIControlStateSelected];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"]) {
            NSInteger isWin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"] integerValue];
            [selectBtn setSelected:isWin == 1];
        }
        [cell.contentView addSubview:selectBtn];
        [selectBtn release];
    }
    
    
    return cell;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushOpenSelectValueChanged:(id)sender {
    if (_operationing) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.isSelected];
    
    NSInteger isWin = 1;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"]) {
        isWin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsWin"] integerValue];
    }
    _operationing = YES;
    [self pushSettingChangeRequestWithOpen:[btn isSelected] ? 1 : 0 isWin:isWin];
}

- (void)pushWinSelectValueChanged:(id)sender {
    if (_operationing) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.isSelected];
    NSInteger isOpen = 1;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"]) {
        isOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushIsOpen"] integerValue];
    }
    _operationing = YES;
    [self pushSettingChangeRequestWithOpen:isOpen isWin:[btn isSelected] ? 1 : 0];
}

#pragma mark -Customized: Private (General)
- (void)pushSettingChangeRequestWithOpen:(NSInteger)isOpen isWin:(NSInteger)isWin {
    if(_globals.pushBaiDuUserid.length == 0 || _globals.pushBaiDuChannelid.length == 0) {
        _operationing = NO;
        return;
        
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pushIsOpen"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pushIsWin"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:isOpen] forKey:@"pushIsOpen"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:isWin] forKey:@"pushIsWin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    [infoDict setObject:[UserInfo shareUserInfo].userID forKey:@"UserId"];
    [infoDict setObject:_globals.pushBaiDuUserid forKey:@"ClientUserId"];
    [infoDict setObject:_globals.pushBaiDuChannelid forKey:@"ChannelId"];
    [infoDict setObject:@"4" forKey:@"DeviceType"];
    [infoDict setObject:[NSNumber numberWithInteger:isOpen] forKey:@"IsOpen"];
    [infoDict setObject:[NSNumber numberWithInteger:isWin] forKey:@"IsWin"];
    [infoDict setObject:@"1" forKey:@"Status"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_ServerRecordPushParameter userId:@"-1" infoDict:infoDict]];
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


@end
