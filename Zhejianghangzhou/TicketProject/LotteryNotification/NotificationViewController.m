//
//  NotificationViewController.m   开奖公告
//  TicketProject
//
//  Created by sls002 on 13-6-7.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140729 14:58（洪晓彬）：大部分代码修改整理,修改代码规范，改进生命周期，处理各种内存问题
//  20140805 11:22（洪晓彬）：进行ipad适配
//  20150819 10:47（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "NotificationViewController.h"
#import "NotificationDetailViewController.h"
#import "XFTabBarViewController.h"
#import "SVProgressHUD.h"

#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Service.h"
#import "Globals.h"

#define NotificationViewCellHeight (IS_PHONE ? 72.0f : 105.0f)

@interface NotificationViewController ()
/** 构造彩种信息，包含彩种图标，彩种编号，彩种名称 */
- (void)makeArray;
/** 获取所有彩种（除去竞彩）的开奖信息 */
- (void)getAllNotification;
/** 将刷新状态设置为正在刷新中，并发送获取所有彩种（除去竞彩）的开奖信息的申请 */
- (void)reloadTableViewDataSource;
@end
#pragma mark -
#pragma mark @implementation NotificationViewController
@implementation NotificationViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"开奖公告"];
    }
    return self;
}

-(void)dealloc {
    _lblWinInfoView = nil;
    _notificationTableView = nil;
    _refreshTableHeaderView = nil;
    
    [_lotteryNameArray release];
    _lotteryNameArray = nil;
    [_lotteryIDArray release];
    _lotteryIDArray = nil;
    [_imageArray release];
    _imageArray = nil;
    [_openInfoArray release];
    _openInfoArray = nil;
    [_openDic release];
    _openDic =nil;
    
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [baseView setExclusiveTouch:YES];
    [self setView:baseView];
	[baseView release];

    //notificationTableView 各个彩种开奖视图
    CGRect notificationTableViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kTabBarHeight - kNavigationBarHeight);
    _notificationTableView = [[UITableView alloc] initWithFrame:notificationTableViewRect style:UITableViewStylePlain];
    [_notificationTableView setBackgroundColor:[UIColor whiteColor]];
    [_notificationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _notificationTableView.dataSource = self;
    _notificationTableView.delegate = self;
    [self.view addSubview:_notificationTableView];
    [_notificationTableView release];
    
    //refreshTableHeaderView 刷新头部控件
    CGRect refreshTableHeaderViewRect = CGRectMake(0, 0 - CGRectGetHeight(notificationTableViewRect), CGRectGetWidth(appRect), _notificationTableView.bounds.size.height);
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:refreshTableHeaderViewRect];
    [_refreshTableHeaderView setDelegate:self];
    [_notificationTableView addSubview:_refreshTableHeaderView];
    [_refreshTableHeaderView release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _openDic = [[NSMutableDictionary alloc]init];
    [self makeArray];
    [self getAllNotification];

    [_refreshTableHeaderView refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    _isHidden = YES;
    _isHiddens = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _lblWinInfoView = nil;
        _notificationTableView = nil;
        _refreshTableHeaderView = nil;
        
        [_lotteryNameArray release];
        _lotteryNameArray = nil;
        [_lotteryIDArray release];
        _lotteryIDArray = nil;
        [_imageArray release];
        _imageArray = nil;
        [_openInfoArray release];
        _openInfoArray = nil;
        [_openDic release];
        _openDic =nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_lotteryIDArray count]) {
        return [self heightWithLotteryID:[[_lotteryIDArray objectAtIndex:indexPath.row] integerValue]];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Service *service = [Service getDefaultService];
    service.information = indexPath.row;
    
    NSInteger lotteryId = [[_lotteryIDArray objectAtIndex:indexPath.row] intValue];
    
    NotificationDetailViewController *detail = [[NotificationDetailViewController alloc]initWithLotteryId:lotteryId andLotteryName:[_lotteryNameArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_lotteryIDArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomNotificationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *lottery_id = [_lotteryIDArray objectAtIndex:indexPath.row];
    NSString *lottery_name = [_lotteryNameArray objectAtIndex:indexPath.row];
    
    CGFloat cellHeight = [self heightWithLotteryID:[lottery_id integerValue]];
    /********************** adjustment 控件调整 ***************************/
    CGFloat leftSignMaginRight = IS_PHONE ? 15.0f : 30.0f;
    CGFloat leftSignWidth = IS_PHONE ? 15.0f : 22.5f;
    CGFloat leftSignHeight = IS_PHONE ? 14.0f : 21.0f;
    
    CGFloat nameLabelMinX = IS_PHONE ? 15.0f : 30.0f;
    CGFloat nameLabelMinY = IS_PHONE ? 8.0f : 12.0f;
    CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    
    CGFloat promptMaginBottom = IS_PHONE ? 12.0f : 13.0f;
    
    CGFloat issueStrLabelnameLabelLandscapeInterval = IS_PHONE ? 9.0f : 18.0f;
    CGFloat issueStrLabelWidth = IS_PHONE ? 150.0f : 480.0f;
    CGFloat lotteryImageViewSize = IS_PHONE ? 49.0f : 75.0f;
    CGFloat footWith = (IS_3_Inch || IS_4_Inch) ? (IS_PHONE ? 270.0f : 640.0f) : (IS_PHONE ? 320.0f : 640.0f);
    /********************** adjustment end ***************************/
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        //backView 背景视图 用来添加开奖信息
        UIView *backView = [[UIView alloc] init];
        [backView setBackgroundColor:[UIColor clearColor]];
        [backView setTag:501];
        [cell.contentView addSubview:backView];
        [backView release];
        
        //leftSignImageView 箭头图
        CGRect leftSignRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignWidth - leftSignMaginRight, (cellHeight - leftSignHeight) / 2.0f, leftSignWidth, leftSignHeight);
        UIImageView *leftSignImageView = [[UIImageView alloc] initWithFrame:leftSignRect];
        [leftSignImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"leftSign.png"]]];
        [leftSignImageView setTag:502];
        [cell.contentView addSubview:leftSignImageView];
        [leftSignImageView release];
        
        //nameLabel 彩种名称
        CGSize nameLabelSize = [Globals defaultSizeWithString:lottery_name fontSize:XFIponeIpadFontSize15];
        CGRect nameLabelRect = CGRectMake(nameLabelMinX, nameLabelMinY, nameLabelSize.width + 2.0f, allLabelHeight);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTag:503];
        [cell.contentView addSubview:nameLabel];
        [nameLabel release];
        
        //issueStrLabel 彩种期号
        CGRect issueStrLabelRect = CGRectMake(CGRectGetMaxX(nameLabelRect) + issueStrLabelnameLabelLandscapeInterval, CGRectGetMinY(nameLabelRect), issueStrLabelWidth, allLabelHeight);
        UILabel *issueStrLabel = [[UILabel alloc] initWithFrame:issueStrLabelRect];
        [issueStrLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [issueStrLabel setTextAlignment:NSTextAlignmentLeft];
        [issueStrLabel setBackgroundColor:[UIColor clearColor]];
        [issueStrLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [issueStrLabel setTag:504];
        [cell.contentView addSubview:issueStrLabel];
        [issueStrLabel release];
        
        //imageView 彩种图标
        CGRect imageViewRect = CGRectMake(nameLabelMinX, CGRectGetMaxY(nameLabelRect) + (IS_PHONE ? 5.0f : 8.0f), lotteryImageViewSize, lotteryImageViewSize);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
        [imageView setTag:505];
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        //竞彩对阵显示
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [lable setTextColor:[UIColor whiteColor]];
        [lable setBackgroundColor:[UIColor clearColor]];
        [lable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [lable setTextAlignment:NSTextAlignmentCenter];
        [lable setHidden:_isHiddens];
        [lable setTag:520];
        [cell.contentView addSubview:lable];
        [lable release];
        
        //显示开奖号码背景图
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [imgView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK3Bg.png"]]];
        [imgView setTag:510];
        [imgView setHidden:_isHidden];
        [cell.contentView addSubview:imgView];
        [imgView release];
        
        //和值
        CGRect andValuesLableRect = CGRectMake(0, 0, 0, 0);
        UILabel *andValuesLable = [[UILabel alloc] initWithFrame:andValuesLableRect];
        [andValuesLable setTag:511];
        [andValuesLable setHidden:_isHidden];
        [cell.contentView addSubview:andValuesLable];
        [andValuesLable release];
        
        //centerPromptLabel
        CGRect centerPromptLabelRect = CGRectMake(CGRectGetMaxX(imageViewRect), CGRectGetMaxY(nameLabelRect), CGRectGetWidth(tableView.frame) - nameLabelMinX * 2, cellHeight - CGRectGetMaxY(nameLabelRect) - promptMaginBottom);
        UILabel *centerPromptLabel = [[UILabel alloc] initWithFrame:centerPromptLabelRect];
        [centerPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [centerPromptLabel setTextAlignment:NSTextAlignmentLeft];
        [centerPromptLabel setBackgroundColor:[UIColor clearColor]];
        [centerPromptLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
        [centerPromptLabel setTag:507];
        [cell.contentView addSubview:centerPromptLabel];
        [centerPromptLabel release];
        
        //blackLineView 底线
        CGRect blackLineViewRect = CGRectMake(0, cellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        UIView *blackLineView = [[UIView alloc] initWithFrame:blackLineViewRect];
        [blackLineView setBackgroundColor:[UIColor lightGrayColor]];
        [blackLineView setTag:506];
        [cell.contentView addSubview:blackLineView];
        [blackLineView release];
        
    }
    //backView 背景视图 用来添加开奖信息
    UIView *backView = (UIView *)[cell.contentView viewWithTag:501];
    for(UIView *view in backView.subviews) {
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    //leftSignImageView 箭头图
    UIImageView *leftSignImageView = (UIImageView *)[cell.contentView viewWithTag:502];
    CGRect leftSignRect = CGRectMake(CGRectGetWidth(tableView.frame) - leftSignWidth - leftSignMaginRight, (cellHeight - leftSignHeight) / 2.0f, leftSignWidth, leftSignHeight);
    [leftSignImageView setFrame:leftSignRect];
    
    //nameLabel 彩种名称
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:503];
    CGSize nameLabelSize = [Globals defaultSizeWithString:lottery_name fontSize:XFIponeIpadFontSize15];
    CGRect nameLabelRect = CGRectMake(nameLabelMinX, nameLabelMinY, nameLabelSize.width + 2.0f, allLabelHeight);
    [nameLabel setFrame:nameLabelRect];
    [nameLabel setText:lottery_name];
    
    //issueStrLabel 彩种期号
    UILabel *issueStrLabel = (UILabel *)[cell.contentView viewWithTag:504];
    CGRect issueStrLabelRect = CGRectMake(CGRectGetMaxX(nameLabelRect) + issueStrLabelnameLabelLandscapeInterval, CGRectGetMinY(nameLabelRect), issueStrLabelWidth, allLabelHeight);
    [issueStrLabel setFrame:issueStrLabelRect];
    [issueStrLabel setText:@""];
    
    //centerPromptLabel
    UILabel *centerPromptLabel = (UILabel *)[cell.contentView viewWithTag:507];
        
    //blackLineView 底线
    UIView *blackLineView = (UIView *)[cell.contentView viewWithTag:506];
    CGRect blackLineViewRect = CGRectMake(0, cellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
    [blackLineView setFrame:blackLineViewRect];
    
    //imageView 彩种图标
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:505];
    if ([lottery_id isEqualToString:@"72"] || [lottery_id isEqualToString:@"73"] || [lottery_id isEqualToString:@"45"]) {
        CGRect imageViewRect = CGRectMake(nameLabelMinX, CGRectGetMaxY(nameLabelRect) + (IS_PHONE ? 8.0f : 11.0f), footWith, lotteryImageViewSize - (IS_PHONE ? 10 : 20));
        [imageView setFrame:imageViewRect];
    } else {
        CGRect imageViewRect = CGRectMake(nameLabelMinX, CGRectGetMaxY(nameLabelRect) + (IS_PHONE ? 5.0f : 8.0f), lotteryImageViewSize, lotteryImageViewSize);
        [imageView setFrame:imageViewRect];
    }
    
    //竞彩对阵
    UILabel *againstLable = (UILabel *)[cell.contentView viewWithTag:520];
    CGRect againstLableRect = CGRectMake(nameLabelMinX + 10, CGRectGetMaxY(nameLabelRect) + (IS_PHONE ? 8.0f : 11.0f), footWith, lotteryImageViewSize - (IS_PHONE ? 10 : 20));
    [againstLable setFrame:againstLableRect];
    
    if ([lottery_id isEqualToString:@"72"] || [lottery_id isEqualToString:@"73"] || [lottery_id isEqualToString:@"45"]) {
        [againstLable setHidden:NO];
    } else {
        [againstLable setHidden:YES];
    }
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat winNumberMinX = CGRectGetMaxX(imageView.frame) + ((IS_3_Inch || IS_4_Inch) ? (IS_PHONE ? 5.0f : 8.0f) : (IS_PHONE ? 15.0f : 18.0f)); //获奖号码摆布的x坐标为namelabel的x坐标
    CGFloat winNumberMinY = CGRectGetMaxY(nameLabel.frame) + (IS_PHONE ? 15.0f : 18.0f);//获奖号码摆布的y坐标为namelabel的MaxY + 5
    CGFloat winNumberWidth = IS_PHONE ? 280.0f : 460.0f;
    CGFloat winNumberHeight = IS_PHONE ? 28.0f : 50.0f;
    
    CGFloat buttonInterval = IS_PHONE ? 4.0f : 6.0f;//button之间的间距
    CGFloat buttonSize = IS_PHONE ? 27.0f : 50.0f;//button的大小
    
    CGFloat sfLabelWidth = IS_PHONE ? 14.0f : 20.0f;
    CGFloat sfLabelHeight = IS_PHONE ? 27.0f : 40.0f;
    CGFloat sfLabelLandscapeInterval = IS_PHONE ? 4.0f : 10.0f;
    CGFloat imgSizeHeight = IS_PHONE ? 40.0f : 80.0f;
    CGFloat imgSizeWidth = IS_PHONE ? 140.0f : 280.0f;
    /********************** adjustment end ***************************/
    
    //快三显示开奖号码背景图
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:510];
    CGRect imgViewRect = CGRectMake(winNumberMinX, winNumberMinY - (IS_PHONE ? 5.0f : 8.0f), imgSizeWidth, imgSizeHeight);
    [imgView setFrame:imgViewRect];
    
    UILabel *andValuesLable = (UILabel *)[cell.contentView viewWithTag:511];
    CGRect andValuesLableRect = CGRectMake(CGRectGetMaxX(imgViewRect) + buttonInterval, CGRectGetMinY(imgViewRect), imgSizeHeight + (IS_PHONE ? 20.0f : 23.0f), imgSizeHeight);
    [andValuesLable setFrame:andValuesLableRect];
    
    if ([lottery_id isEqualToString:@"83"]) {
        [imgView setHidden:NO];
        [andValuesLable setHidden:NO];
    } else {
        [imgView setHidden:YES];
        [andValuesLable setHidden:YES];
    }
    
    if (![lottery_id isEqualToString:@"72"] && ![lottery_id isEqualToString:@"73"] && ![lottery_id isEqualToString:@"45"]) {
        NSDictionary *dic = [_openDic objectForKey:lottery_id];
        NSString *str = [InterfaceHelper getLotteryMessageWithLotteryName:lottery_name messageType:1];
        [imageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:str]]];
        
        if(dic) {
            if([dic objectForKey:@"name"]) {
                NSString *dateStr = [dic objectForKey:@"EndTime"];
                NSString *weekDay = [Globals getWeekDay:dateStr];
                
                [issueStrLabel setText:[NSString stringWithFormat:@"%@期 (%@)",[dic objectForKey:@"name"],weekDay]];
                
            } else {
                [issueStrLabel setText:@""];
            }
            
            // 开奖号码
            NSString *lotteryNumber;
            if([dic objectForKey:@"winLotteryNumber"]) {
                lotteryNumber = [dic objectForKey:@"winLotteryNumber"];
            } else {
                lotteryNumber = @"";
            }
            
            if (lotteryNumber.length >= 3) {
                [centerPromptLabel setText:@""];
                if([lottery_id isEqualToString:@"5"] || [lottery_id isEqualToString:@"39"] || [lottery_id isEqualToString:@"13"]) {   // 双色球和大乐透和七乐彩，有蓝球
                    NSArray *array = [lotteryNumber componentsSeparatedByString:@"+"];
                    NSString *redNum = [NSString string];
                    NSString *blueNum = [NSString string];
                    
                    if(array.count > 1) {
                        redNum = [array objectAtIndex:0];
                        blueNum = [array objectAtIndex:1];
                    }
                    
                    UILabel *winNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(winNumberMinX, winNumberMinY, winNumberWidth, winNumberHeight)];
                    [winNumberLabel setBackgroundColor:[UIColor clearColor]];
                    redNum = [redNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    blueNum = [blueNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    
                    NSArray *listRed = [redNum componentsSeparatedByString:@" "];
                    NSArray *listBlue = [blueNum componentsSeparatedByString:@" "];
                    for(NSInteger i =0 ;i < [listRed count];i++) {
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        [button setFrame:CGRectMake((buttonSize + buttonInterval) * i, 0, buttonSize, buttonSize)];
                        NSString *str = [listRed objectAtIndex:i];
                        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                        [button setTitle:str forState:UIControlStateNormal];
                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Select.png"]] forState:UIControlStateNormal];
                        [winNumberLabel addSubview:button];
                        
                    }
                    for(NSInteger j = 0;j < [listBlue count];j++) {
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"blueBall_Select.png"]] forState:UIControlStateNormal];
                        [button setFrame:CGRectMake(((buttonSize + buttonInterval) * ([listRed count] + j)), 0, buttonSize, buttonSize)];
                        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                        [button setTitle:[listBlue objectAtIndex:j] forState:UIControlStateNormal];
                        [winNumberLabel addSubview:button];
                    }
                    
                    [backView addSubview:winNumberLabel];
                    [winNumberLabel release];
                } else {
                    if([lottery_id isEqualToString:@"74"] || [lottery_id isEqualToString:@"75"]) {   // 胜负彩、任选九
                        for (NSInteger charIndex = 0 ; charIndex < lotteryNumber.length; charIndex++) {
                            CGRect labelsRect = CGRectMake(winNumberMinX + (sfLabelWidth + sfLabelLandscapeInterval) * charIndex, winNumberMinY, sfLabelWidth, sfLabelHeight);
                            UILabel *labels = [[UILabel alloc]initWithFrame:labelsRect];
                            [labels setBackgroundColor:[UIColor redColor]];
                            [labels setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
                            [labels setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];
                            [labels setTextColor:[UIColor whiteColor]];
                            [labels setTextAlignment:NSTextAlignmentCenter];
                            [labels setText:[lotteryNumber substringWithRange:NSMakeRange(charIndex, 1)]];
                            [backView addSubview:labels];
                            [labels release];
                        }
                        
                        
                        
                    } else if ([lottery_id isEqualToString:@"82"]) {        // 幸运彩      2 1 1 , 02 09 04
                        NSArray *arr = [lotteryNumber componentsSeparatedByString:@" "];
                        for(NSInteger i = 0; i < [arr count]; i++){
                            if (i == 3)
                                continue;
                            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                            button.frame = CGRectMake((buttonSize + buttonInterval) * i + winNumberMinX, winNumberMinY, buttonSize, buttonSize);
                            NSString *str = [arr objectAtIndex:i];
                            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                            [button setTitle:str forState:UIControlStateNormal];
                            [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Select.png"]] forState:UIControlStateNormal];
                            [backView addSubview:button];
                        }
                        
                    } else if ([lottery_id isEqualToString:@"62"] || [lottery_id isEqualToString:@"69"] || [lottery_id isEqualToString:@"70"] || [lottery_id isEqualToString:@"78"]) {  // 11运夺金    03 02 10 05 11
                        
                        NSArray *arr = [lotteryNumber componentsSeparatedByString:@" "];
                        for(NSInteger i = 0; i < [arr count]; i++){
                            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                            button.frame = CGRectMake((buttonSize + buttonInterval) * i + winNumberMinX, winNumberMinY, buttonSize, buttonSize);
                            NSString *str = [arr objectAtIndex:i];
                            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                            [button setTitle:str forState:UIControlStateNormal];
                            [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Select.png"]] forState:UIControlStateNormal];
                            [backView addSubview:button];
                        }
                    } else {
                        if ([lottery_id isEqualToString:@"83"]) {
                            NSMutableArray *cMutableArray = [[NSMutableArray alloc] init];
                            for(NSInteger i = 0;i < [lotteryNumber length];i++){
                                unichar c = [lotteryNumber characterAtIndex:i];
                                NSString *str = [NSString stringWithFormat:@"%c",c];
                                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                                [cMutableArray addObject:str];
                                switch ([str integerValue]) {
                                    case 1:
                                    {
                                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK31.png"]] forState:UIControlStateNormal];
                                    }
                                        break;
                                    case 2:
                                    {
                                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK32.png"]] forState:UIControlStateNormal];
                                    }
                                        break;
                                    case 3:
                                    {
                                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK33.png"]] forState:UIControlStateNormal];
                                    }
                                        break;
                                    case 4:
                                    {
                                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK34.png"]] forState:UIControlStateNormal];
                                    }
                                        break;
                                    case 5:
                                    {
                                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK35.png"]] forState:UIControlStateNormal];
                                    }
                                        break;
                                    case 6:
                                    {
                                        [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK36.png"]] forState:UIControlStateNormal];
                                    }
                                        break;
                                        
                                    default:
                                        break;
                                }
                                button.frame = CGRectMake((buttonSize + buttonInterval *3) * i + buttonInterval * 3.5, 5, buttonSize   + (IS_PHONE ? 8 : 16), buttonSize + (IS_PHONE ? 8 : 16));
                                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                                [imgView addSubview:button];
                            }
                            NSNumber *sum = [cMutableArray valueForKeyPath:@"@sum.floatValue"];
                            NSString *sumStr = [NSString stringWithFormat:@"%@",sum];
                            [andValuesLable setText:[NSString stringWithFormat:@"和值:%@",sumStr]];
                            [cMutableArray release];
                            
                        } else {
                            for(NSInteger i = 0;i < [lotteryNumber length];i++){
                                unichar c = [lotteryNumber characterAtIndex:i];
                                NSString *str = [NSString stringWithFormat:@"%c",c];
                                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                                [button setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redBall_Select.png"]] forState:UIControlStateNormal];
                                button.frame = CGRectMake((buttonSize + buttonInterval) * i + winNumberMinX, winNumberMinY, buttonSize, buttonSize);
                                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                                [button setTitle:str forState:UIControlStateNormal];
                                [backView addSubview:button];
                            }
                        }
                    }
                }
            } else {
                [centerPromptLabel setText:@"暂无开奖信息"];
                [imgView setHidden:YES];
                [andValuesLable setHidden:YES];
            }
        } else {
            [centerPromptLabel setText:@"暂无开奖信息"];
            [imgView setHidden:YES];
            [andValuesLable setHidden:YES];
        }
    } else {            // 竞彩的
        if ([lottery_id isEqualToString:@"72"] || [lottery_id isEqualToString:@"73"] || [lottery_id isEqualToString:@"45"]) {
            NSArray *openArray = [_openDic objectForKey:lottery_id];

            if ([lottery_id isEqualToString:@"72"]) {
                [imageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryFootBallBack.png"]]];
            } else if ([lottery_id isEqualToString:@"45"]) {
                [imageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryDCBack.png"]]];
            } else {
                [imageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryBasketBall.png"]]];
            }
            if ([openArray isKindOfClass:[NSArray class]] && [openArray count] > 0) {
                NSDictionary *dic = [openArray objectAtIndex:0];
                NSString *guestTeam = [dic objectForKey:@"guestTeam"];
                NSString *mainTeam = [dic objectForKey:@"mainTeam"];
                NSString *result = [dic objectForKey:@"result"];
                
                if ([lottery_id isEqualToString:@"72"] || [lottery_id isEqualToString:@"45"]) {
                    [againstLable setText:[NSString stringWithFormat:@"%@    %@     %@",mainTeam,result,guestTeam]];
                    
                } else {
                    [againstLable setText:[NSString stringWithFormat:@"%@    %@     %@",guestTeam,result,mainTeam]];
                }
                
    if([dic objectForKey:@"matchDate"]) {
                    NSString *dateString = [dic objectForKey:@"matchDate"];
                    NSArray *array = [dateString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                    
                    if ([array count] > 0) {
                        NSString *weekDay = [Globals getWeekDay:dateString];
                        
                        [issueStrLabel setText:[NSString stringWithFormat:@"%@（%@）",[array objectAtIndex:0],weekDay]];
                        
                    } else  {
                        [issueStrLabel setText:@""];
                    }
                }
            }
            [centerPromptLabel setText:@""];
        }
        
    }
    return cell;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)deceleratescrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

#pragma mark -EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)httpRequest {
    [SVProgressHUD showSuccessWithStatus:@"加载完成"];
    
    NSDictionary *responseDic = [[httpRequest responseString]objectFromJSONString];

    if (responseDic) {
        [_openInfoArray release];
        _openInfoArray = nil;
        _openInfoArray = [[responseDic objectForKey:@"dtOpenInfo"] retain];
        
        for (NSDictionary *dic in _openInfoArray) {
            NSString *key = [dic objectForKey:@"lotteryId"];
            [_openDic setObject:dic forKey:key];
        }
        if ([responseDic objectForKey:@"dtMatch"])
            [_openDic setObject:[responseDic objectForKey:@"dtMatch"] forKey:@"72"];
        if ([responseDic objectForKey:@"dtMatchBasket"])
            [_openDic setObject:[responseDic objectForKey:@"dtMatchBasket"] forKey:@"73"];
        if ([responseDic objectForKey:@"dtMatchBjSing"])
            [_openDic setObject:[responseDic objectForKey:@"dtMatchBjSing"] forKey:@"45"];
        [_notificationTableView reloadData];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)doneLoadingTableViewData {
    _isLoading = NO;
    
    [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_notificationTableView];
}

#pragma mark -Customized: Private (General)
- (CGFloat)heightWithLotteryID:(NSInteger)lotteryID {
    return (IS_PHONE ? 90.0f : 130.0f);
}

- (void)makeArray {
    NSDictionary *lotteryDict = [InterfaceHelper getWinLotteryIDNameDic];
    _lotteryNameArray = [[lotteryDict objectForKey:@"name"] retain];
    _lotteryIDArray = [[lotteryDict objectForKey:@"id"] retain];
}

- (void)getAllNotification {
    [SVProgressHUD showWithStatus:@"加载中"];
    [self clearHTTPRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[InterfaceHelper getAllLotteryString] forKey:@"lotteryId"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetDrawTheWinningNumbersOfALottery userId:@"-1" infoDict:infoDic]];
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

- (void)reloadTableViewDataSource {
    _isLoading = YES;
    
    [self getAllNotification];
}

@end
