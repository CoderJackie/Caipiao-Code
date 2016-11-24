//
//  SelectRechargeTypeViewController.m  个人中心－选择充值方式
//  TicketProject
//
//  Created by KAI on 15-1-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "SelectRechargeTypeViewController.h"
#import "RechargeViewController.h"
#import "XFTabBarViewController.h"

#import "Globals.h"
#import "UserInfo.h"

#define SelectRechargeTypeViewTabelCellHeight (IS_PHONE ? 60.0f : 100.0f)
#define SelectRechargeTypeViewSectionFootViewHeight (IS_PHONE ? 10.0f : 20.0f)

@interface SelectRechargeTypeViewController ()

@end

@implementation SelectRechargeTypeViewController

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"选择充值方式"];
    }
    return self;
}

- (void)dealloc {
    [_rechargeTypePictureNameArray release];
    _rechargeTypePictureNameArray = nil;
    [_rechargeTypeArray release];
    _rechargeTypeArray = nil;
    [_rechargeTypePromptArray release];
    _rechargeTypePromptArray = nil;
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
    CGFloat tableViewMinY = IS_PHONE ? 20.0f : 40.0f;
    /********************** adjustment end ***************************/
    
    //tableListView 表格视图
    CGRect tableListViewRect = CGRectMake(tableViewMinX, tableViewMinY, CGRectGetWidth(appRect) - tableViewMinX * 2, CGRectGetHeight(appRect) - tableViewMinY);
    _tableListView = [[UITableView alloc]initWithFrame:tableListViewRect style:UITableViewStylePlain];
    [_tableListView setBackgroundColor:[UIColor clearColor]];
    [_tableListView setDataSource:self];
    [_tableListView setDelegate:self];
    [_tableListView setScrollEnabled:NO];
    [_tableListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableListView];
    [_tableListView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.xfTabBarController setTabBarHidden:YES];

    _recommendIndex = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadBankInfo];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)loadBankInfo {
    [self clearLoadBankInfoRequest];
    
    _loadBankInfoRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_ColoseNumbers userId:[UserInfo shareUserInfo].userID infoDict:nil]];
    [_loadBankInfoRequest setDelegate:self];
    [_loadBankInfoRequest startAsynchronous];
}

- (void)clearLoadBankInfoRequest {
    if (_loadBankInfoRequest != nil) {
        [_loadBankInfoRequest clearDelegatesAndCancel];
        [_loadBankInfoRequest release];
        _loadBankInfoRequest = nil;
    }
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];    
    if ([[responseDic objectForKey:@"Alipay"] isEqualToString:@"True"] && [[responseDic objectForKey:@"UnionPay"] isEqualToString:@"True"]) {
        _rechargeTypePictureNameArray = [[NSMutableArray alloc] initWithObjects:@"payOfUPcash.png", @"payOfAliPay.png", nil];
        _rechargeTypeArray = [[NSMutableArray alloc] initWithObjects:@"银联支付", @"支付宝快捷支付", nil];
        _rechargeTypePromptArray = [[NSMutableArray alloc] initWithObjects:@"无需开通网银，快速支付" ,@"支付宝推荐，安全快捷" , nil];
        
    } else if ([[responseDic objectForKey:@"Alipay"] isEqualToString:@"True"] && [[responseDic objectForKey:@"UnionPay"] isEqualToString:@"False"]) {
        _rechargeTypePictureNameArray = [[NSMutableArray alloc] initWithObjects:@"yinlian.png", nil];
        _rechargeTypeArray = [[NSMutableArray alloc] initWithObjects:@"银联快捷支付", nil];
        _rechargeTypePromptArray = [[NSMutableArray alloc] initWithObjects:@"银联推荐，安全快捷" , nil];
        
    } else if ([[responseDic objectForKey:@"Alipay"] isEqualToString:@"False"] && [[responseDic objectForKey:@"UnionPay"] isEqualToString:@"True"]) {
        _rechargeTypePictureNameArray = [[NSMutableArray alloc] initWithObjects:@"payOfUPcash.png", nil];
        _rechargeTypeArray = [[NSMutableArray alloc] initWithObjects:@"银联支付", nil];
        _rechargeTypePromptArray = [[NSMutableArray alloc] initWithObjects:@"无需开通网银，快速支付" , nil];
    }
    
    //添加微信支付（二维码支付）
    [_rechargeTypePictureNameArray addObject:@"weixin.png"];
    [_rechargeTypeArray addObject:@"微信支付"];
    [_rechargeTypePromptArray addObject:@"微信支付，安全快捷"];
    
    [_tableListView reloadData];
}

#pragma Delegate
#pragma mark -
#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[_rechargeTypeArray objectAtIndex:indexPath.section] isEqualToString:@"微信支付"]) {
        RechargeViewController *rechargeViewController = [[RechargeViewController alloc] initWithRechargeType:RechargeTypeOfNone];
        [self.navigationController pushViewController:rechargeViewController animated:YES];
        [rechargeViewController release];
        return;
    }
    if (_rechargeTypeArray.count == 3) {
        if (indexPath.section == 0) {
            RechargeViewController *rechargeViewController = [[RechargeViewController alloc] initWithRechargeType:RechargeTypeOfUPPayPlugin];
            [self.navigationController pushViewController:rechargeViewController animated:YES];
            [rechargeViewController release];
            
        } else if (indexPath.section == 1) {
            RechargeViewController *rechargeViewController = [[RechargeViewController alloc] initWithRechargeType:RechargeTypeOfAlixPay];
            [self.navigationController pushViewController:rechargeViewController animated:YES];
            [rechargeViewController release];
        }
    } else {
        
        if ([[_rechargeTypeArray objectAtIndex:0] isEqualToString:@"银联支付"]) {
            RechargeViewController *rechargeViewController = [[RechargeViewController alloc] initWithRechargeType:RechargeTypeOfUPPayPlugin];
            [self.navigationController pushViewController:rechargeViewController animated:YES];
            [rechargeViewController release];
        }
        
        if ([[_rechargeTypeArray objectAtIndex:0] isEqualToString:@"银联快捷支付"]) {
            RechargeViewController *rechargeViewController = [[RechargeViewController alloc] initWithRechargeType:RechargeTypeOfAlixPay];
            [self.navigationController pushViewController:rechargeViewController animated:YES];
            [rechargeViewController release];
        }
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SelectRechargeTypeViewTabelCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return SelectRechargeTypeViewSectionFootViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect footerViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), SelectRechargeTypeViewSectionFootViewHeight);
    UIView *footerView = [[UIView alloc] initWithFrame:footerViewRect];
    [footerView setBackgroundColor:[UIColor clearColor]];
    return [footerView autorelease];
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_rechargeTypePictureNameArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SelectRechargeTypeViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /********************** adjustment 控件调整 ***************************/
    CGFloat photoImageViewMinX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat photoIamgeViewWidth = IS_PHONE ? 74.0f : 111.0f;
    CGFloat photoImageViewheight = IS_PHONE ? 31.0f : 46.5f;
    
    CGFloat promptLabelAddX = IS_PHONE ? 5.0f : 10.0f;
    CGFloat promptLabelMinY = IS_PHONE ? 6.0f : 15.0f;
    CGFloat promptLabelWidth = IS_PHONE ? 100.0f : 400.0f;
    CGFloat promptLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    
    CGFloat leftSignImageViewMaginRightX = IS_PHONE ? 10.0f : 20.0f;
    CGFloat leftSignImageViewWidth = IS_PHONE ? 15.0f : 22.5f;
    CGFloat leftSignImageViewHeight = IS_PHONE ? 14.0f : 21.0f;
    /********************** adjustment end ***************************/
    if(cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        //backImageView
        CGRect backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), SelectRechargeTypeViewTabelCellHeight);
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
        [backImageView setBackgroundColor:[UIColor clearColor]];
        [backImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton_2.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f]];
        [cell addSubview:backImageView];
        [cell sendSubviewToBack:backImageView];
        [backImageView release];
        
        //photoImageView
        CGRect photoImageViewRect = CGRectMake(photoImageViewMinX, (SelectRechargeTypeViewTabelCellHeight - photoImageViewheight) / 2.0f, photoIamgeViewWidth, photoImageViewheight);
        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:photoImageViewRect];
        [photoImageView setBackgroundColor:[UIColor clearColor]];
        [photoImageView setTag:1120];
        [cell.contentView addSubview:photoImageView];
        [photoImageView release];
        
        //fisrtRawPromptLabel1
        CGRect firstRawPromptLabel1Rect = CGRectMake(CGRectGetMaxX(photoImageViewRect) + promptLabelAddX, promptLabelMinY, promptLabelWidth, promptLabelHeight);
        UILabel *firstRawPromptLabel1 = [[UILabel alloc] initWithFrame:firstRawPromptLabel1Rect];
        [firstRawPromptLabel1 setBackgroundColor:[UIColor clearColor]];
        [firstRawPromptLabel1 setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [firstRawPromptLabel1 setTag:1121];
        [cell.contentView addSubview:firstRawPromptLabel1];
        [firstRawPromptLabel1 release];
        
        //fisrtRawPromptLabel2
        CGRect firstRawPromptLabel2Rect = CGRectMake(CGRectGetMaxX(firstRawPromptLabel1Rect), promptLabelMinY, promptLabelWidth, promptLabelHeight);
        UILabel *firstRawPromptLabel2 = [[UILabel alloc] initWithFrame:firstRawPromptLabel2Rect];
        [firstRawPromptLabel2 setBackgroundColor:[UIColor clearColor]];
        [firstRawPromptLabel2 setTextColor:[UIColor colorWithRed:251.0f/255.0f green:8.0f/255.0f blue:27.0f/255.0f alpha:1.0f]];
        [firstRawPromptLabel2 setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [firstRawPromptLabel2 setTag:1122];
        [cell.contentView addSubview:firstRawPromptLabel2];
        [firstRawPromptLabel2 release];
        
        //secondRawPromptLabel
        CGRect secondRawPromptLabelRect = CGRectMake(CGRectGetMinX(firstRawPromptLabel1Rect), CGRectGetMaxY(firstRawPromptLabel1Rect), CGRectGetWidth(tableView.frame) - CGRectGetMinX(firstRawPromptLabel1Rect), promptLabelHeight);
        UILabel *secondRawPromptLabel = [[UILabel alloc] initWithFrame:secondRawPromptLabelRect];
        [secondRawPromptLabel setBackgroundColor:[UIColor clearColor]];
        [secondRawPromptLabel setTextColor:kDarkGrayColor];
        [secondRawPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [secondRawPromptLabel setTag:1123];
        [cell.contentView addSubview:secondRawPromptLabel];
        [secondRawPromptLabel release];
        
        //leftSignImageView
        CGRect leftSignImageViewRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignImageViewWidth - leftSignImageViewMaginRightX, (SelectRechargeTypeViewTabelCellHeight - leftSignImageViewHeight) / 2.0f , leftSignImageViewWidth, leftSignImageViewHeight);
        UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignImageViewRect];
        [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        [cell.contentView addSubview:leftSignImageView];
        [leftSignImageView release];
    }
    
    //photoImageView
    UIImageView *photoImageView = (UIImageView *)[cell.contentView viewWithTag:1120];
    [photoImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[_rechargeTypePictureNameArray objectAtIndex:indexPath.section]]]];
    
    //fisrtRawPromptLabel1
    UILabel *firstRawPromptLabel1 = (UILabel *)[cell.contentView viewWithTag:1121];
    CGRect originalFirstRawPromptLabel1Rect = firstRawPromptLabel1.frame;
    NSString *firstPromptString = [_rechargeTypeArray objectAtIndex:indexPath.section];
    CGSize firstPromptSize = [Globals defaultSizeWithString:firstPromptString fontSize:XFIponeIpadFontSize14];
    [firstRawPromptLabel1 setText:firstPromptString];
    [firstRawPromptLabel1 setFrame:CGRectMake(CGRectGetMinX(originalFirstRawPromptLabel1Rect), CGRectGetMinY(originalFirstRawPromptLabel1Rect), firstPromptSize.width, CGRectGetHeight(originalFirstRawPromptLabel1Rect))];
    
    //fisrtRawPromptLabel2
    UILabel *firstRawPromptLabel2 = (UILabel *)[cell.contentView viewWithTag:1122];
    CGRect originalFirstRawPromptLabel2 = firstRawPromptLabel2.frame;
    [firstRawPromptLabel2 setFrame:CGRectMake(CGRectGetMaxX(firstRawPromptLabel1.frame), CGRectGetMinY(originalFirstRawPromptLabel2), CGRectGetWidth(tableView.frame) - CGRectGetMaxX(firstRawPromptLabel1.frame), CGRectGetHeight(originalFirstRawPromptLabel2))];
    if (indexPath.section == _recommendIndex) {
        [firstRawPromptLabel2 setText:@"(推荐)"];
        [firstRawPromptLabel2 setHidden:NO];
    } else {
        [firstRawPromptLabel2 setText:@""];
        [firstRawPromptLabel2 setHidden:YES];
    }
    
    //secondRawPromptLabel
    UILabel *secondRawPromptLabel = (UILabel *)[cell.contentView viewWithTag:1123];
    [secondRawPromptLabel setText:[_rechargeTypePromptArray objectAtIndex:indexPath.section]];
    
    return cell;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)dismissViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Customized: Private (General)

@end
