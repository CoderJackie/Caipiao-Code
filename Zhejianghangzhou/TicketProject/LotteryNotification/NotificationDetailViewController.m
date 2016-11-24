//  NotificationDetailViewController.m  开奖详情  显示历史开奖信息
//  TicketProject
//
//  Created by sls002 on 13-6-9.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140804 08:25（洪晓彬）：大部分代码修改整理,修改代码规范，改进生命周期，处理各种内存问题
//  20140805 16:32（洪晓彬）：进行ipad适配
//  20150820 11:03（刘科）：优化指示器，更换第三方库。(SVProgressHUD)
//  20150820 11:03（刘科）：竞彩彩种投注接口

#import "NotificationDetailViewController.h"
#import "HomeViewController.h"
#import "XFTabBarViewController.h"

#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import "GlobalsProject.h"

#define kPageSize 20
#define NotificationDetailViewCellHeight (IS_PHONE ?  65.0f : 100.0f)
#define NotificationDetailViewJCCellHeight (IS_PHONE ?  55.0f : 90.0f)

#define NotificationDetailViewTableViewHeaderHeight (IS_PHONE ?  30.0f : 60.0f)

#define IssueDetailViewTableCellHeight (IS_PHONE ? 25.0f : 50.0f)  //tabelcell的高度
#define IssueDetailViewsVerticalInterval 7.0f

#define middleLabelSize (IS_PHONE ? CGSizeMake(150, 30) : CGSizeMake(300, 50))

@interface NotificationDetailViewController ()
/** 请求普通彩票的历史开奖信息 */
- (void)requestData;
/** 请求竞彩的历史开奖信息 */
- (void)requestJCData;
/** 初始化 下拉状态信息 */
- (void)initDropStatus;
@end
#pragma mark -
#pragma mark @implementation NotificationDetailViewController
@implementation NotificationDetailViewController
#pragma mark Lifecircle

- (id)initWithLotteryId:(NSInteger)lotteryID andLotteryName:(NSString *)lotteryname {
    self = [super init];
    if(self) {
        _lotteryId = lotteryID;
        _lotteryName = [lotteryname copy];
        self.title = [NSString stringWithFormat:@"%@开奖详情",lotteryname];
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _globals = _appDelegate.globals;
    }
    return self;
}

-(void)dealloc {
    [_selectDateStr release];
    [_dateBg release];
    [_dateView release];
    [_lotteryName release];
    _lotteryName = nil;
    _detailTableView = nil;
    [_selectArray release];
    _selectArray = nil;
    [_dropDic release];
    _dropDic = nil;
    [_detailArray release];
    _detailArray = nil;
    [_matchDic release];
    _matchDic = nil;
    
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
    
    if (IS_IOS7) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted]; // calendar_phone@2x
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    
    // 时间筛选按钮
    CGRect timeBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [timeBtn setFrame:timeBtnRect];
    [timeBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"calendar.png"]] forState:UIControlStateNormal];
    [timeBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"calendar.png"]] forState:UIControlStateHighlighted];
    [timeBtn addTarget:self action:@selector(getTimeSelection:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:timeBtn];
    if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
        [self.navigationItem setRightBarButtonItem:rightItem];
    }else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    [rightItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat bottomBtnHeight = (_globals.tabBarHidden ? 0.0f : (IS_PHONE ? 40.0f : 60.0f));
    /********************** adjustment end ***************************/
    
    //detailTableView 彩种开奖表格视图
    CGRect detailTableViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - IncreaseNavHeight + (IS_IOS7 ? 20 : 0) - bottomBtnHeight);
    _detailTableView = [[PullingRefreshTableView alloc]initWithFrame:detailTableViewRect style:UITableViewStylePlain];
    [_detailTableView setBackgroundColor:kBackgroundColor];
    [_detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _detailTableView.dataSource = self;
    _detailTableView.delegate = self;
    [_detailTableView setPullingDelegate:self];
    if(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
        [_detailTableView setReachedTheEnd:YES];
        [_detailTableView setHeaderOnly:YES];
    }
    [_detailTableView setTag:110];
    [self.view addSubview:_detailTableView];
    [_detailTableView release];
    
    //betBtn 投注按钮
    CGRect betBtnRect = CGRectMake(0, CGRectGetMaxY(detailTableViewRect), CGRectGetWidth(appRect), bottomBtnHeight);
    UIButton *betBtn = [[UIButton alloc] initWithFrame:betBtnRect];
    [betBtn setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:159.0f/255.0f blue:29.0f/255.0f alpha:1.0f]];
    [betBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [betBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [betBtn setTitle:[NSString stringWithFormat:@"%@投注",_lotteryName] forState:UIControlStateNormal];
    [betBtn addTarget:self action:@selector(gotoBet:) forControlEvents:UIControlEventTouchUpInside];
    [betBtn setHidden:_globals.tabBarHidden];
    [self.view addSubview:betBtn];
    [betBtn release];
    
    _dateBg = [[UIView alloc] initWithFrame:self.view.bounds];
    _dateBg.backgroundColor = [UIColor blackColor];
    _dateBg.hidden = YES;
    _dateBg.alpha = 0.6;
    [self.view addSubview:_dateBg];
    
    // 日期筛选视图
    _dateView = [[UIView alloc] init];
    _dateView.frame = CGRectMake(0, CGRectGetHeight(appRect), CGRectGetWidth(appRect), 315);
    _dateView.backgroundColor = kRedColor;
    _dateView.hidden = YES;
    [self.view addSubview:_dateView];
    
    //时间选择器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *currentTime  = [NSDate date];
    UIDatePicker *_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(appRect), 216)];
    [_datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [_datePicker setDate:currentTime animated:YES];                             // 设置当前显示
    [_datePicker setDatePickerMode:UIDatePickerModeDate];                       // 显示模式
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];    //设置为中
    _datePicker.locale = locale;
    // 回调的方法由于UIDatePicker 是UIControl的子类 ,可以在UIControl类的通知结构中挂接一个委托
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _datePicker.backgroundColor = [UIColor whiteColor];
    [_dateView addSubview:_datePicker];
    [_datePicker release];
    
    // 时间选择器 -> 确定按钮
    UIButton *yesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    yesBtn.frame = CGRectMake(40, 226, (CGRectGetWidth(appRect) - 120) / 2, 36);
    [yesBtn setTitle:@"确定" forState:UIControlStateNormal];
    yesBtn.backgroundColor = [UIColor colorWithRed:251.0f/255.0f green:159.0f/255.0f blue:29.0f/255.0f alpha:1.0f];
    [yesBtn.layer setMasksToBounds:YES];
    yesBtn.tag = 1;
    [yesBtn.layer setCornerRadius:4.0]; //设置矩形四个圆角半径
    [yesBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dateView addSubview:yesBtn];
    
    // 时间选择器 -> 确定按钮
    UIButton *noBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noBtn.frame = CGRectMake((CGRectGetWidth(appRect) - 120) / 2 + 80, 226, (CGRectGetWidth(appRect) - 120) / 2, 36);
    noBtn.backgroundColor = [UIColor grayColor];
    [noBtn.layer setMasksToBounds:YES];
    [noBtn.layer setCornerRadius:4.0]; //设置矩形四个圆角半径
    noBtn.tag = 2;
    [noBtn setTitle:@"取消" forState:UIControlStateNormal];
    [noBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dateView addSubview:noBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isQuickLotteryView = [InterfaceHelper isQuickLotteryWithLotteryID:_lotteryId];

    _datehArray = [[NSMutableArray alloc] init];
    
    _selectArray = [[NSMutableArray alloc] init];
    if (_dropDic == nil) {
        _dropDic = [[NSMutableDictionary alloc]init];
    }
    if (_detailArray == nil) {//高频彩暂时不显示奖金
        _detailArray = [[NSMutableArray alloc] init];
        if (!_isQuickLotteryView)
            [_selectArray addObject:[NSIndexPath indexPathForRow:0 inSection:0]];//默认打开第一条
    }
    _pageIndex = 1;
    _selectDateStr = @"";
    
    if(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
        [self requestJCData];
    } else {
        [self requestData];
    }
    
    NSDictionary *dic = [InterfaceHelper getLotteryIDNameDic];
    _nameArray = [[dic objectForKey:@"name"] retain];
    _lotteryIDArray = [[dic objectForKey:@"id"] retain];
    _imageArray = [[dic objectForKey:@"image"] retain];
    if (_lotteryId == 28) {
        _sslArray = [[NSMutableArray alloc] init];
    }
    _index = [_lotteryIDArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)_lotteryId]];
    
    // 没有奖项设置时，设置默认的
    [self setCommonBonusNames];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.xfTabBarController setTabBarHidden:YES];
    _pushView = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        [_detailArray release];
        _detailArray = nil;
        [_matchDic release];
        _matchDic = nil;
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [self clearJCRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
//下拉刷新,上拖加载更多
#pragma mark -UIScrollViewDelegate
//会在视图滚动时收到通知。包括一个指向被滚动视图的指针，从中可以读取contentOffset属性以确定其滚动到的位置。
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_detailTableView tableViewDidScroll:scrollView];
}

//当用户抬起拖动的手指时得到通知。还会得到一个布尔值，知名报告滚动视图最后位置之前，是否需要减速。
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_detailTableView tableViewDidEndDragging:scrollView];
}

#pragma mark -PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    _pageIndex = 1;
    [_detailArray removeAllObjects];
    [_detailTableView setReachedTheEnd:NO];
    [_detailTableView setHeaderOnly:NO];
    [self requestData];
    
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    _pageIndex++;
    [self requestData];
}

- (NSDate *)pullingTableViewRefreshingFinishedDate{
    return [NSDate date];
}

- (NSDate *)pullingTableViewLoadingFinishedDate{
    return [NSDate date];
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 110) {
        if (![_selectArray containsObject:indexPath]) {
            if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
                return NotificationDetailViewCellHeight + NotificationDetailViewTableViewHeaderHeight;
            } else {
                return NotificationDetailViewCellHeight;
            }
        }
        
        if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
            return NotificationDetailViewCellHeight + NotificationDetailViewTableViewHeaderHeight;
        } else {
            NSDictionary *dict = nil;
            if (indexPath.row < [_detailArray count]) {
                dict = [_detailArray objectAtIndex:indexPath.row];
            }
            
            NSArray *bonusArray = (NSArray *)[dict objectForKey:@"WinDetail"];
            if (![bonusArray isKindOfClass:[NSArray class]]) {
                bonusArray = nil;
            }
            if([bonusArray isKindOfClass:[NSArray class]] && bonusArray.count > 0) {
                if (_lotteryId == 28) {
                    NSInteger line = [bonusArray count] - 1;
                    
                    return NotificationDetailViewCellHeight + IssueDetailViewsVerticalInterval * 3 + middleLabelSize.height * 2 + IssueDetailViewTableCellHeight * line;
                } else if (_lotteryId == 5 || _lotteryId == 39 || _lotteryId == 3 ){
                    NSInteger line = bonusArray.count + 1;
                    return NotificationDetailViewCellHeight + IssueDetailViewsVerticalInterval * 3 + middleLabelSize.height * 2 + IssueDetailViewTableCellHeight * line;
                } else {
                    NSInteger line = bonusArray.count + 1;
                    return NotificationDetailViewCellHeight + IssueDetailViewsVerticalInterval * 3 + middleLabelSize.height + IssueDetailViewTableCellHeight * line;
                }
            } else {
                NSInteger line = [_commonBonusNames count] + 1;
                if (_lotteryId == 5 || _lotteryId == 39 || _lotteryId == 3) {
                    return NotificationDetailViewCellHeight + IssueDetailViewsVerticalInterval * 3 + middleLabelSize.height * 2 + IssueDetailViewTableCellHeight * line;
                } else {
                    return NotificationDetailViewCellHeight + IssueDetailViewsVerticalInterval * 3 + middleLabelSize.height + IssueDetailViewTableCellHeight * line;
                }
                
            }
        }
        
    } else if (tableView.tag >= 1100) {
        return IssueDetailViewTableCellHeight;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 110) {
        if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
            return NotificationDetailViewTableViewHeaderHeight;
        }
        return 0;
    }
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 110) {
        if(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45 || _isQuickLotteryView)
            return;
        if ([_selectArray containsObject:indexPath]) {
            [_selectArray removeAllObjects];
        } else {
            [_selectArray removeAllObjects];
            [_selectArray addObject:indexPath];
        }
        
        [_detailTableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (tableView.tag == 110) {
        if(!(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45)) {
            [view setHidden:YES];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 110) {
        if(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
            NSArray *sectionArray = [_matchDic objectForKey:[NSString stringWithFormat:@"table%ld",(long)3 - section]];
            NSString *date = [_datehArray objectAtIndex:2 - section];
            NSInteger matchCount = sectionArray.count;
            CGRect headerViewRect = CGRectMake(0, 0, kWinSize.width, NotificationDetailViewTableViewHeaderHeight);
            UIView *headerView = [[UIView alloc]initWithFrame:headerViewRect];
            /********************** adjustment 控件调整 ***************************/
            CGFloat promptLabelMinX = 10.0f;
            /********************** adjustment end ***************************/
            UIButton *dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [dropBtn setFrame:CGRectMake(0, -3, kWinSize.width, NotificationDetailViewTableViewHeaderHeight + 3)];
            [dropBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_select.png"]] forState:UIControlStateNormal];
            [dropBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"header_normal.png"]] forState:UIControlStateSelected];
            [dropBtn setTag:section]; //标示是第几个section
            [dropBtn addTarget:self action:@selector(dropDownListTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
            [headerView addSubview:dropBtn];
            
            CGRect promptLabelRect = CGRectMake(promptLabelMinX, 0, CGRectGetWidth(headerViewRect) - promptLabelMinX, CGRectGetHeight(headerViewRect));
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
            [promptLabel setBackgroundColor:[UIColor clearColor]];
            
            
            if (matchCount == 0) {
                NSString *dateStr = [_datehArray objectAtIndex:2 - section];
                NSString *weekDay = [Globals getWeekDay:dateStr];
                
                [promptLabel setText:[NSString stringWithFormat:@"%@  (%@)    暂无开奖信息",date,weekDay]];
            } else {
                [promptLabel setText:[NSString stringWithFormat:@"%@  (%@)    %ld场比赛已开奖",date,[[sectionArray objectAtIndex:0] objectForKey:@"weekDay"],(long)matchCount]];
            }
            
            [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
            [headerView addSubview:promptLabel];
            [promptLabel release];
            
            NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
            //如果是下拉状态  让button选中
            if([[dic objectForKey:@"isDropDown"] boolValue] == YES) {
                [dropBtn setSelected:YES]; //设置btn的状态  因为在tableview reloadData的时候  isSelected又变为了NO
            }
            
            return [headerView autorelease];
        } else {
            UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWinSize.width, NotificationDetailViewTableViewHeaderHeight)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            return [headerView autorelease];
        }
    } else if (tableView.tag == 1100) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWinSize.width, NotificationDetailViewTableViewHeaderHeight)];
        return [headerView autorelease];
        
    }
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWinSize.width, NotificationDetailViewTableViewHeaderHeight)];
    return [headerView autorelease];
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == 110) {
        if(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
            NSInteger section = 0;
            for (NSInteger i = 1 ;i < [_matchDic count] + 1; i++) {
                section++;
            }
            return section;
        } else {
            return 1;
        }
    } else if (tableView.tag >= 1100) {
        return 1;
    }
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 110) {
        if(_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
            NSArray *rowsArray = [_matchDic objectForKey:[NSString stringWithFormat:@"table%ld",(long)3 - section]];
            NSDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
            BOOL isDropdown = [[dic objectForKey:@"isDropDown"] boolValue];
            NSInteger dropSection = [[dic objectForKey:@"dropSection"] intValue];
            //如果 不是下拉状态 并且选中的section相等 则返回0  实现收缩的效果
            if(!isDropdown && dropSection == section) {
                return 0;
            }
            return rowsArray.count;
        } else {
            return _detailArray.count;
        }
    } else if (tableView.tag >= 1100) {
        NSDictionary *dict = nil;
        if (tableView.tag - 1100 < [_detailArray count]) {
            dict = [_detailArray objectAtIndex:(tableView.tag - 1100)];
        }
        NSArray *bonusArray = (NSArray *)[dict objectForKey:@"WinDetail"];
        if (![bonusArray isKindOfClass:[NSArray class]]) {
            bonusArray = nil;
        }
        if(bonusArray.count > 0) {
            if (_lotteryId == 28) {
                [_sslArray removeAllObjects];
                [_sslArray addObjectsFromArray:bonusArray];
                NSInteger a = _sslArray.count-2;
                return a + 1;
            } else {
                return bonusArray.count + 1;
            }
        } else {
            return [_commonBonusNames count] + 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 110) {
        static NSString *notificationCellIdentifier = @"NotificationDetailCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notificationCellIdentifier] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
            [cell.contentView setClipsToBounds:YES];
            /********************** adjustment 控件调整 ***************************/
            CGFloat cellInterval = 0.0f; //cell之间的间距
            
            CGFloat btnSignMaginRight = IS_PHONE ? 10.0f : 20.0f;
            CGFloat btnSignSize = IS_PHONE ? 14.0f : 21.0f;
            
            /********************** adjustment end ***************************/
            
            //backImageView 背景图案
            CGRect backImageViewRect;
            if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
                backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), NotificationDetailViewCellHeight + NotificationDetailViewTableViewHeaderHeight - cellInterval);
            } else {
                backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), NotificationDetailViewCellHeight - cellInterval);
            }

            UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
            [backImageView setBackgroundColor:[UIColor whiteColor]];
            [backImageView setTag:640];
            [cell.contentView addSubview:backImageView];
            [backImageView release];
            
            //landscapeLine1View
            CGRect landscapeLine1ViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
            UIView *landscapeLine1View = [[UIView alloc] initWithFrame:landscapeLine1ViewRect];
            [landscapeLine1View setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
            [landscapeLine1View setTag:6401];
            [backImageView addSubview:landscapeLine1View];
            [landscapeLine1View release];
            
            //landscapeLine2View
            CGRect landscapeLine2ViewRect = CGRectMake(0, CGRectGetHeight(backImageViewRect) - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
            UIView *landscapeLine2View = [[UIView alloc] initWithFrame:landscapeLine2ViewRect];
            [landscapeLine2View setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
            [landscapeLine2View setTag:6402];
            [backImageView addSubview:landscapeLine2View];
            [landscapeLine2View release];
            
            if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
                /********************** adjustment 控件调整 ***************************/
                CGFloat firstLabelMinY = IS_PHONE ? 10.0f : 15.0f;
                CGFloat firstLabelWidth = IS_PHONE ? 67.0f : 160.0f;
                CGFloat firstColLabelHeight = IS_PHONE ? 21.0f : 30.0f;
                
                CGFloat linePointWidth = IS_PHONE ? 1.0f : 1.5f;
                CGFloat linePointHeight = IS_PHONE ? 42.0f : 75.0f;
                
                CGFloat matchLabelWidth = IS_PHONE ? 97.5 : 180.0f;
                CGFloat spfMessageLabelMinY = IS_PHONE ? 10.0f : 15.0f;
                /********************** adjustment end ***************************/
                //gameTypeLabel 比赛类型
                CGRect gameTypeLabelRect = CGRectMake(0, firstLabelMinY, firstLabelWidth, firstColLabelHeight);
                UILabel *gameTypeLabel = [[UILabel alloc]initWithFrame:gameTypeLabelRect];
                [gameTypeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [gameTypeLabel setTextAlignment:NSTextAlignmentCenter];
                [gameTypeLabel setBackgroundColor:[UIColor clearColor]];
                [gameTypeLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                [gameTypeLabel setTag:601];
                [cell.contentView addSubview:gameTypeLabel];
                [gameTypeLabel release];
                
                //matchNumberLabel 比赛场次或时间
                CGRect matchNumberLabelRect = CGRectMake(0, CGRectGetMaxY(gameTypeLabelRect), firstLabelWidth + 10, firstColLabelHeight);
                UILabel *matchNumberLabel = [[UILabel alloc]initWithFrame:matchNumberLabelRect];
                [matchNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize10]];
                [matchNumberLabel setBackgroundColor:[UIColor clearColor]];
                [matchNumberLabel setTextAlignment:NSTextAlignmentCenter];
                [matchNumberLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                [matchNumberLabel setTag:602];
                [cell.contentView addSubview:matchNumberLabel];
                [matchNumberLabel release];
                
                //lineImageView
                CGRect lineImageViewRect = CGRectMake(CGRectGetMaxX(gameTypeLabelRect), (NotificationDetailViewCellHeight - linePointHeight) / 2.0, linePointWidth, linePointHeight);
                UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:lineImageViewRect];
                [lineImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                [lineImageView setHidden:YES];
                [cell.contentView addSubview:lineImageView];
                [lineImageView release];
                
                //mainTeamMessageLabel 主队信息
                CGRect mainTeamMessageLabelRect = CGRectMake(CGRectGetMaxX(gameTypeLabelRect), 0, matchLabelWidth, NotificationDetailViewCellHeight);
                UILabel *mainTeamMessageLabel = [[UILabel alloc]initWithFrame:mainTeamMessageLabelRect];
                [mainTeamMessageLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [mainTeamMessageLabel setTextAlignment:NSTextAlignmentCenter];
                [mainTeamMessageLabel setBackgroundColor:[UIColor clearColor]];
                [mainTeamMessageLabel setTag:603];
                [cell.contentView addSubview:mainTeamMessageLabel];
                [mainTeamMessageLabel release];
                
                //spfBackView 主vs客的信息背景
                CGRect spfBackViewRect = CGRectMake(CGRectGetMaxX(mainTeamMessageLabelRect), 0, CGRectGetWidth(tableView.frame) - CGRectGetMaxX(lineImageViewRect) - matchLabelWidth * 2, NotificationDetailViewCellHeight - AllLineWidthOrHeight);
                UIView *spfBackView = [[UIView alloc] initWithFrame:spfBackViewRect];
                [spfBackView setBackgroundColor:[UIColor clearColor]];
                [spfBackView setTag:604];
                [cell.contentView addSubview:spfBackView];
                [spfBackView release];
                
                //spfResultLabel
                CGRect spfResultLabelRect = CGRectMake(CGRectGetMaxX(mainTeamMessageLabelRect), spfMessageLabelMinY, CGRectGetWidth(spfBackViewRect), (CGRectGetHeight(spfBackViewRect) - spfMessageLabelMinY * 2) / 2.0f);
                UILabel *spfResultLabel = [[UILabel alloc]initWithFrame:spfResultLabelRect];
                [spfResultLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize15]];
                [spfResultLabel setTextAlignment:NSTextAlignmentCenter];
                [spfResultLabel setBackgroundColor:[UIColor clearColor]];
                [spfResultLabel setTag:605];
                [cell.contentView addSubview:spfResultLabel];
                [spfResultLabel release];
                
                //spfScoreLabel
                CGRect spfScoreLabelRect = CGRectMake(CGRectGetMaxX(mainTeamMessageLabelRect), CGRectGetMaxY(spfResultLabelRect), CGRectGetWidth(spfBackViewRect), CGRectGetHeight(spfResultLabelRect));
                UILabel *spfScoreLabel = [[UILabel alloc]initWithFrame:spfScoreLabelRect];
                [spfScoreLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [spfScoreLabel setTextAlignment:NSTextAlignmentCenter];
                [spfScoreLabel setBackgroundColor:[UIColor clearColor]];
                [spfScoreLabel setTag:606];
                [cell.contentView addSubview:spfScoreLabel];
                [spfScoreLabel release];
                
                
                //guestTeamMessageLabel 客队信息
                CGRect guestTeamMessageLabelRect = CGRectMake(CGRectGetMaxX(spfBackViewRect), 0, matchLabelWidth, CGRectGetHeight(mainTeamMessageLabelRect));
                UILabel *guestTeamMessageLabel = [[UILabel alloc]initWithFrame:guestTeamMessageLabelRect];
                [guestTeamMessageLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                [guestTeamMessageLabel setTextAlignment:NSTextAlignmentCenter];
                [guestTeamMessageLabel setBackgroundColor:[UIColor clearColor]];
                [guestTeamMessageLabel setTag:607];
                [cell.contentView addSubview:guestTeamMessageLabel];
                [guestTeamMessageLabel release];
                
                if (_lotteryId == 72  || _lotteryId == 45) {
                    CGRect spfLableRect = CGRectMake(0, CGRectGetMaxY(spfBackViewRect) - 10, CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *spfLable = [[UILabel alloc] initWithFrame:spfLableRect];
                    [spfLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [spfLable setTextAlignment:NSTextAlignmentCenter];
                    [spfLable setBackgroundColor:[UIColor clearColor]];
                    [spfLable setTag:666];
                    [cell.contentView addSubview:spfLable];
                    [spfLable release];
                    
                    CGRect spfResultLableRect = CGRectMake(0, CGRectGetMaxY(spfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) /2.0f);
                    UILabel *spfResultLable = [[UILabel alloc] initWithFrame:spfResultLableRect];
                    [spfResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [spfResultLable setTextAlignment:NSTextAlignmentCenter];
                    [spfResultLable setBackgroundColor:[UIColor clearColor]];
                    [spfResultLable setTag:6666];
                    [cell.contentView addSubview:spfResultLable];
                    [spfResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect1 = CGRectMake(CGRectGetMaxX(spfLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView1 = [[UIImageView alloc] initWithFrame:lineImageViewRect1];
                    [lineImageView1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView1];
                    [lineImageView1 release];
                    
                    
                    CGRect rqspfLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect1), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *rqspfLable = [[UILabel alloc] initWithFrame:rqspfLableRect];
                    [rqspfLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [rqspfLable setTextAlignment:NSTextAlignmentCenter];
                    [rqspfLable setBackgroundColor:[UIColor clearColor]];
                    [rqspfLable setTag:667];
                    [cell.contentView addSubview:rqspfLable];
                    [rqspfLable release];
                    
                    CGRect rqspfResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect1), CGRectGetMaxY(rqspfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *rqspfResultLable = [[UILabel alloc] initWithFrame:rqspfResultLableRect];
                    [rqspfResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [rqspfResultLable setTextAlignment:NSTextAlignmentCenter];
                    [rqspfResultLable setBackgroundColor:[UIColor clearColor]];
                    [rqspfResultLable setTag:6677];
                    [cell.contentView addSubview:rqspfResultLable];
                    [rqspfResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect2 = CGRectMake(CGRectGetMaxX(rqspfLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView2 = [[UIImageView alloc] initWithFrame:lineImageViewRect2];
                    [lineImageView2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView2];
                    [lineImageView2 release];
                    
                    
                    CGRect bfLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect2), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *bfLable = [[UILabel alloc] initWithFrame:bfLableRect];
                    [bfLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [bfLable setTextAlignment:NSTextAlignmentCenter];
                    [bfLable setBackgroundColor:[UIColor clearColor]];
                    [bfLable setTag:668];
                    [cell.contentView addSubview:bfLable];
                    [bfLable release];
                    
                    CGRect bfResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect2), CGRectGetMaxY(bfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *bfResultLable = [[UILabel alloc] initWithFrame:bfResultLableRect];
                    [bfResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [bfResultLable setTextAlignment:NSTextAlignmentCenter];
                    [bfResultLable setBackgroundColor:[UIColor clearColor]];
                    [bfResultLable setTag:6688];
                    [cell.contentView addSubview:bfResultLable];
                    [bfResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect3 = CGRectMake(CGRectGetMaxX(bfLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView3 = [[UIImageView alloc] initWithFrame:lineImageViewRect3];
                    [lineImageView3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView3];
                    [lineImageView3 release];
                    
                    
                    CGRect zjqLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect3), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *zjqLable = [[UILabel alloc] initWithFrame:zjqLableRect];
                    [zjqLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [zjqLable setTextAlignment:NSTextAlignmentCenter];
                    [zjqLable setBackgroundColor:[UIColor clearColor]];
                    [zjqLable setTag:669];
                    [cell.contentView addSubview:zjqLable];
                    [zjqLable release];
                    
                    CGRect zjqResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect3), CGRectGetMaxY(zjqLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *zjqResultLable = [[UILabel alloc] initWithFrame:zjqResultLableRect];
                    [zjqResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [zjqResultLable setTextAlignment:NSTextAlignmentCenter];
                    [zjqResultLable setBackgroundColor:[UIColor clearColor]];
                    [zjqResultLable setTag:6699];
                    [cell.contentView addSubview:zjqResultLable];
                    [zjqResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect4 = CGRectMake(CGRectGetMaxX(zjqLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView4 = [[UIImageView alloc] initWithFrame:lineImageViewRect4];
                    [lineImageView4 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView4];
                    [lineImageView4 release];
                    
                    
                    CGRect bqcLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect4), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *bqcLable = [[UILabel alloc] initWithFrame:bqcLableRect];
                    [bqcLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [bqcLable setTextAlignment:NSTextAlignmentCenter];
                    [bqcLable setBackgroundColor:[UIColor clearColor]];
                    [bqcLable setTag:670];
                    [cell.contentView addSubview:bqcLable];
                    [bqcLable release];
                    
                    CGRect bqcResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect4), CGRectGetMaxY(bqcLableRect), CGRectGetWidth(backImageViewRect) / 5.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *bqcResultLable = [[UILabel alloc] initWithFrame:bqcResultLableRect];
                    [bqcResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [bqcResultLable setTextAlignment:NSTextAlignmentCenter];
                    [bqcResultLable setBackgroundColor:[UIColor clearColor]];
                    [bqcResultLable setTag:6700];
                    [cell.contentView addSubview:bqcResultLable];
                    [bqcResultLable release];
                    
                } else {
                    CGRect spfLableRect = CGRectMake(0, CGRectGetMaxY(spfBackViewRect) - 10, CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *spfLable = [[UILabel alloc] initWithFrame:spfLableRect];
                    [spfLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [spfLable setTextAlignment:NSTextAlignmentCenter];
                    [spfLable setBackgroundColor:[UIColor clearColor]];
                    [spfLable setTag:666];
                    [cell.contentView addSubview:spfLable];
                    [spfLable release];
                    
                    CGRect spfResultLableRect = CGRectMake(0, CGRectGetMaxY(spfLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) /2.0f);
                    UILabel *spfResultLable = [[UILabel alloc] initWithFrame:spfResultLableRect];
                    [spfResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [spfResultLable setTextAlignment:NSTextAlignmentCenter];
                    [spfResultLable setBackgroundColor:[UIColor clearColor]];
                    [spfResultLable setTag:6666];
                    [cell.contentView addSubview:spfResultLable];
                    [spfResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect1 = CGRectMake(CGRectGetMaxX(spfLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView1 = [[UIImageView alloc] initWithFrame:lineImageViewRect1];
                    [lineImageView1 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView1];
                    [lineImageView1 release];
                    
                    
                    CGRect rqspfLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect1), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *rqspfLable = [[UILabel alloc] initWithFrame:rqspfLableRect];
                    [rqspfLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [rqspfLable setTextAlignment:NSTextAlignmentCenter];
                    [rqspfLable setBackgroundColor:[UIColor clearColor]];
                    [rqspfLable setTag:667];
                    [cell.contentView addSubview:rqspfLable];
                    [rqspfLable release];
                    
                    CGRect rqspfResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect1), CGRectGetMaxY(rqspfLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *rqspfResultLable = [[UILabel alloc] initWithFrame:rqspfResultLableRect];
                    [rqspfResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [rqspfResultLable setTextAlignment:NSTextAlignmentCenter];
                    [rqspfResultLable setBackgroundColor:[UIColor clearColor]];
                    [rqspfResultLable setTag:6677];
                    [cell.contentView addSubview:rqspfResultLable];
                    [rqspfResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect2 = CGRectMake(CGRectGetMaxX(rqspfLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView2 = [[UIImageView alloc] initWithFrame:lineImageViewRect2];
                    [lineImageView2 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView2];
                    [lineImageView2 release];
                    
                    
                    CGRect bfLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect2), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *bfLable = [[UILabel alloc] initWithFrame:bfLableRect];
                    [bfLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [bfLable setTextAlignment:NSTextAlignmentCenter];
                    [bfLable setBackgroundColor:[UIColor clearColor]];
                    [bfLable setTag:668];
                    [cell.contentView addSubview:bfLable];
                    [bfLable release];
                    
                    CGRect bfResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect2), CGRectGetMaxY(bfLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *bfResultLable = [[UILabel alloc] initWithFrame:bfResultLableRect];
                    [bfResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [bfResultLable setTextAlignment:NSTextAlignmentCenter];
                    [bfResultLable setBackgroundColor:[UIColor clearColor]];
                    [bfResultLable setTag:6688];
                    [cell.contentView addSubview:bfResultLable];
                    [bfResultLable release];
                    
                    //lineImageView
                    CGRect lineImageViewRect3 = CGRectMake(CGRectGetMaxX(bfLableRect), NotificationDetailViewCellHeight - 10, linePointWidth, NotificationDetailViewTableViewHeaderHeight + 10);
                    UIImageView *lineImageView3 = [[UIImageView alloc] initWithFrame:lineImageViewRect3];
                    [lineImageView3 setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"verticalPointLine.png"]]];
                    [cell.contentView addSubview:lineImageView3];
                    [lineImageView3 release];
                    
                    
                    CGRect zjqLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect3), CGRectGetMinY(spfLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *zjqLable = [[UILabel alloc] initWithFrame:zjqLableRect];
                    [zjqLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [zjqLable setTextAlignment:NSTextAlignmentCenter];
                    [zjqLable setBackgroundColor:[UIColor clearColor]];
                    [zjqLable setTag:669];
                    [cell.contentView addSubview:zjqLable];
                    [zjqLable release];
                    
                    CGRect zjqResultLableRect = CGRectMake(CGRectGetMaxX(lineImageViewRect3), CGRectGetMaxY(zjqLableRect), CGRectGetWidth(backImageViewRect) / 4.0f, (NotificationDetailViewTableViewHeaderHeight + 10) / 2.0f);
                    UILabel *zjqResultLable = [[UILabel alloc] initWithFrame:zjqResultLableRect];
                    [zjqResultLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    [zjqResultLable setTextAlignment:NSTextAlignmentCenter];
                    [zjqResultLable setBackgroundColor:[UIColor clearColor]];
                    [zjqResultLable setTag:6699];
                    [cell.contentView addSubview:zjqResultLable];
                    [zjqResultLable release];
                }
                
            } else {
                /********************** adjustment 控件调整 ***************************/
                CGFloat allLabelHeight = IS_PHONE ? 21.0f : 30.0f;
                
                CGFloat issueLabelMinX = IS_PHONE ? 20.0f : 40.0f;
                CGFloat issueLabelMinY = IS_PHONE ? 5.0f : 10.0f;
                CGFloat issueLabelWidth = kWinSize.width / 2.0f;
                /********************** adjustment end ***************************/
                
                //backView 用来添加开奖号码的视图
                CGRect backViewRect = backImageViewRect;
                UIView *backView = [[UIView alloc] initWithFrame:backViewRect];
                [backView setTag:601];
                [cell.contentView addSubview:backView];
                [backView release];
            
                //issueLabel 彩种名
                CGRect issueLabelRect = CGRectMake(issueLabelMinX, issueLabelMinY, issueLabelWidth, allLabelHeight);
                UILabel *issueLabel = [[UILabel alloc] initWithFrame:issueLabelRect];
                [issueLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
                [issueLabel setTextAlignment:NSTextAlignmentLeft];
                [issueLabel setBackgroundColor:[UIColor clearColor]];
                [issueLabel setTag:602];
                [cell.contentView addSubview:issueLabel];
                [issueLabel release];
            
                //dateLabel 开奖时间
                CGRect dateLabelRect = CGRectMake(issueLabelWidth, CGRectGetMinY(issueLabelRect), issueLabelWidth, allLabelHeight);
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateLabelRect];
                if (_isQuickLotteryView) {
                    [dateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
                    
                } else {
                    [dateLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                }
                [dateLabel setTextAlignment:NSTextAlignmentCenter];
                [dateLabel setBackgroundColor:[UIColor clearColor]];
                [dateLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
                [dateLabel setTag:603];
                [cell.contentView addSubview:dateLabel];
                [dateLabel release];
                
                //显示开奖号码背景图
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
                [imgView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"HistoryK3Bg.png"]]];
                [imgView setTag:510];
                [cell.contentView addSubview:imgView];
                [imgView release];
                
                //和值
                CGRect andValuesLableRect = CGRectMake(0, 0, 0, 0);
                UILabel *andValuesLable = [[UILabel alloc] initWithFrame:andValuesLableRect];
                [andValuesLable setTag:511];
                [andValuesLable setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
                [cell.contentView addSubview:andValuesLable];
                [andValuesLable release];
            
                //signButton
                CGRect signButtonRect = CGRectMake(CGRectGetWidth(backImageViewRect) - btnSignMaginRight - btnSignSize, (CGRectGetHeight(backImageViewRect) - btnSignSize) / 2.0f, btnSignSize, btnSignSize);
                UIButton *signButton = [[UIButton alloc] initWithFrame:signButtonRect];
                [signButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"bottomSign.png"]] forState:UIControlStateNormal];
                [signButton setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"topSign.png"]] forState:UIControlStateSelected];
                [signButton setHidden:_isQuickLotteryView];
                [signButton setTag:604];
                [cell.contentView addSubview:signButton];
                [signButton release];
                
                //middleView 中部 － 视图
                CGRect middleViewRect = CGRectMake(0, CGRectGetMaxY(backViewRect) + IssueDetailViewsVerticalInterval, CGRectGetWidth(tableView.frame), (_lotteryId == 5 || _lotteryId == 39 || _lotteryId ==  3) ? middleLabelSize.height * 2 : middleLabelSize.height);
                if (_lotteryId == 28 || _lotteryId == 70 || _lotteryId == 62 || _lotteryId == 83) { //高频彩不给高度，相当于不显示
                    middleViewRect = CGRectMake(0, NotificationDetailViewCellHeight + IssueDetailViewsVerticalInterval, CGRectGetWidth(tableView.frame), 0);
                }
                UIView *middleView = [[UIView alloc] initWithFrame:middleViewRect];
                [middleView setBackgroundColor:[UIColor clearColor]];
                [middleView setTag:6200];
                [cell.contentView addSubview:middleView];
                [middleView release];
                
                //seleCountTextLabel 本期销量 提示文字
                CGRect seleCountTextLabelRect = CGRectMake((CGRectGetWidth(tableView.frame) - middleLabelSize.width * 2) / 2 , 0, middleLabelSize.width*2, middleLabelSize.height);
                
                if(_lotteryId != 28 && _lotteryId != 70 && _lotteryId != 62 && _lotteryId != 83) { //非高频彩种 才有本期销量
                    UILabel *seleCountTextLabel = [[UILabel alloc]initWithFrame:seleCountTextLabelRect];
                    [seleCountTextLabel.layer setBorderWidth:AllLineWidthOrHeight];
                    [seleCountTextLabel.layer setBorderColor:[UIColor colorWithRed:194.0/255.0f green:194.0/255.0f blue:194.0/255.0f alpha:1.0f].CGColor];
                    [seleCountTextLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
                    [seleCountTextLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                    [seleCountTextLabel setTextAlignment:NSTextAlignmentCenter];
                    [seleCountTextLabel setText:@"本期销量"];
                    [seleCountTextLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
                    [middleView addSubview:seleCountTextLabel];
                    [seleCountTextLabel release];
                    if (_lotteryId == 5 || _lotteryId == 39 || _lotteryId == 3){
                        
                    }else{
                        seleCountTextLabelRect.size.width /= 2.0;
                        [seleCountTextLabel setFrame:seleCountTextLabelRect];
                    }
                }
                if (_lotteryId == 5 || _lotteryId == 39 || _lotteryId == 3) { //双色球和大乐透   有本期销量和奖池奖金
                    //seleCount 本期销量 显示在销量下面
                    CGRect seleCountLabelRect = CGRectMake(CGRectGetMinX(seleCountTextLabelRect), CGRectGetMaxY(seleCountTextLabelRect) - AllLineWidthOrHeight, CGRectGetWidth(seleCountTextLabelRect), CGRectGetHeight(seleCountTextLabelRect));
                    UILabel *seleCountLabel = [[UILabel alloc]initWithFrame:seleCountLabelRect];
                    [seleCountLabel.layer setBorderWidth:AllLineWidthOrHeight];
                    [seleCountLabel.layer setBorderColor:[UIColor colorWithRed:194.0/255.0f green:194.0/255.0f blue:194.0/255.0f alpha:1.0f].CGColor];
                    [seleCountLabel setBackgroundColor:[UIColor whiteColor]];
                    [seleCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                    [seleCountLabel setTextAlignment:NSTextAlignmentCenter];
                    [seleCountLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
                    [seleCountLabel setText:@"-"];
                    [seleCountLabel setTag:620];
                    [middleView addSubview:seleCountLabel];
                    [seleCountLabel release];
                    
//                    //poolTextLabel 奖池奖金
//                    CGRect poolTextLabelRect = CGRectMake(CGRectGetMaxX(seleCountTextLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(seleCountTextLabelRect), CGRectGetWidth(seleCountTextLabelRect), CGRectGetHeight(seleCountTextLabelRect));
//                    UILabel *poolTextLabel = [[UILabel alloc]initWithFrame:poolTextLabelRect];
//                    [poolTextLabel.layer setBorderWidth:AllLineWidthOrHeight];
//                    [poolTextLabel.layer setBorderColor:[UIColor colorWithRed:194.0/255.0f green:194.0/255.0f blue:194.0/255.0f alpha:1.0f].CGColor];
//                    [poolTextLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
//                    [poolTextLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//                    [poolTextLabel setTextAlignment:NSTextAlignmentCenter];
//                    [poolTextLabel setText:@"奖池奖金"];
//                    [poolTextLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
//                    [middleView addSubview:poolTextLabel];
//                    [poolTextLabel release];
                    
                    //poolTextLabel 奖池奖金 显示在奖金下面
//                    CGRect poolCountLabelRect = CGRectMake(CGRectGetMinX(poolTextLabelRect), CGRectGetMinY(seleCountLabelRect), CGRectGetWidth(seleCountLabelRect), CGRectGetHeight(seleCountLabelRect));
//                    UILabel *poolCountLabel = [[UILabel alloc]initWithFrame:poolCountLabelRect];
//                    [poolCountLabel.layer setBorderWidth:AllLineWidthOrHeight];
//                    [poolCountLabel.layer setBorderColor:[UIColor colorWithRed:194.0/255.0f green:194.0/255.0f blue:194.0/255.0f alpha:1.0f].CGColor];
//                    [poolCountLabel setBackgroundColor:[UIColor whiteColor]];
//                    [poolCountLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
//                    [poolCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
//                    [poolCountLabel setTextAlignment:NSTextAlignmentCenter];
//                    [poolCountLabel setText:@"-"];
//                    [poolCountLabel setTag:621];
//                    [middleView addSubview:poolCountLabel];
//                    [poolCountLabel release];
                } else {
                    if(_lotteryId != 28 && _lotteryId != 70 && _lotteryId != 62 && _lotteryId != 83){
                        //seleCountLabel 本期销量 显示在销量下面
                        CGRect seleCountLabelRect = CGRectMake(CGRectGetMaxX(seleCountTextLabelRect)- AllLineWidthOrHeight, CGRectGetMinY(seleCountTextLabelRect) , CGRectGetWidth(seleCountTextLabelRect), CGRectGetHeight(seleCountTextLabelRect));
                        UILabel *seleCountLabel = [[UILabel alloc]initWithFrame:seleCountLabelRect];
                        [seleCountLabel.layer setBorderWidth:AllLineWidthOrHeight];
                        [seleCountLabel.layer setBorderColor:[UIColor colorWithRed:194.0/255.0f green:194.0/255.0f blue:194.0/255.0f alpha:1.0f].CGColor];
                        [seleCountLabel setBackgroundColor:[UIColor whiteColor]];
                        [seleCountLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
                        [seleCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                        [seleCountLabel setTextAlignment:NSTextAlignmentCenter];
                        [seleCountLabel setText:@"-"];
                        [seleCountLabel setTag:620];
                        [middleView addSubview:seleCountLabel];
                        [seleCountLabel release];
                    }
                }
                
                //middleTableView 奖金列表视图
                CGRect middleTableViewRect = CGRectMake(10, CGRectGetMaxY(middleViewRect) + IssueDetailViewsVerticalInterval, CGRectGetWidth(tableView.frame) - 2 * 10, CGRectGetHeight(tableView.frame) - CGRectGetMaxY(middleViewRect) -44);
                UITableView *middleTableView = [[UITableView alloc]initWithFrame:middleTableViewRect style:UITableViewStylePlain];
                [middleTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                [middleTableView setBackgroundColor:[UIColor colorWithRed:0xf6/255.0f green:0xf6/255.0f blue:0xf6/255.0f alpha:1.0f]];
                [middleTableView setDataSource:self];
                [middleTableView setScrollEnabled:NO];
                [middleTableView setDelegate:self];
                [middleTableView setTag:1100 + indexPath.row];
                [cell.contentView addSubview:middleTableView];
                [middleTableView release];
            }
            
        }
        
        //backView 背景视图 用来添加开奖信息
        UIView *backView = (UIView *)[cell.contentView viewWithTag:601];
        for(UIView *view in backView.subviews) {
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            }
        }
        
        UIImageView *backImageView = (UIImageView *)[cell.contentView viewWithTag:640];
        UIView *landscapeLine1View = (UIView *)[backImageView viewWithTag:6401];
        
        NSIndexPath *newIndexPatch = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        if ([_selectArray containsObject:newIndexPatch]) {
            [landscapeLine1View setHidden:NO];
        } else {
            [landscapeLine1View setHidden:YES];
        }
        
        UITableView *tableTabelView = nil;
        for (UITableView *winTabel in cell.contentView.subviews) {
            if ([winTabel isKindOfClass:[UITableView class]]) {
                [winTabel setTag:1100 + indexPath.row];
                tableTabelView = winTabel;
                
                CGRect originalRect = winTabel.frame;
                NSDictionary *dict = nil;
                if (indexPath.row < [_detailArray count]) {
                    dict = [_detailArray objectAtIndex:indexPath.row];
                }
                
                NSArray *bonusArray = (NSArray *)[dict objectForKey:@"WinDetail"];
                
                CGFloat tableCellCount = 0.0f;
                
                
                if([bonusArray isKindOfClass:[NSArray class]] && bonusArray.count > 0) {
                    if (_lotteryId == 28) {
                        tableCellCount = [bonusArray count] - 1;
                    } else {
                        tableCellCount = bonusArray.count + 1;
                    }
                } else {
                    tableCellCount = [_commonBonusNames count] + 1;
                }
                
                [winTabel setFrame:CGRectMake(CGRectGetMinX(originalRect), CGRectGetMinY(originalRect), CGRectGetWidth(originalRect), IssueDetailViewTableCellHeight * tableCellCount)];
            }
        }
        
        UIView *middleView = (UIView *)[cell.contentView viewWithTag:6200];
        if (![_selectArray containsObject:indexPath]) {
            [tableTabelView setHidden:YES];
            [middleView setHidden:YES];
        } else {
            [tableTabelView setHidden:NO];
            [middleView setHidden:NO];
        }
        
        
        if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
            NSArray *array = [_matchDic objectForKey:[NSString stringWithFormat:@"table%ld",(long)3 - indexPath.section]];
            NSDictionary *dic = [array objectAtIndex:indexPath.row];
            NSString *stopSellTime = [dic objectForKey:@"stopSellTime"];
            NSString *tmpStopTime = [[stopSellTime componentsSeparatedByString:@" "] objectAtIndex:1];
            NSString *stopTime = [tmpStopTime substringToIndex:5];
            
            //gameTypeLabel 比赛类型
            UILabel *gameTypeLabel = (UILabel *)[cell.contentView viewWithTag:601];
            [gameTypeLabel setText:[NSString stringWithFormat:@"%@",[dic objectForKey:@"game"]]];
            
            //matchNumberLabel 比赛场次或时间
            UILabel *matchNumberLabel = (UILabel *)[cell.contentView viewWithTag:602];
            if (_lotteryId == 45) {
                [matchNumberLabel setText:[NSString stringWithFormat:@"%@",[dic objectForKey:@"matchNumber"]]];
                
            } else {
                [matchNumberLabel setText:[NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"matchNumber"],stopTime]];
            }
            
            //mainTeamMessageLabel 主队信息
            UILabel *mainTeamMessageLabel = (UILabel *)[cell.contentView viewWithTag:603];
            
            NSString *color = @"#F8F8F0";
            // 转换成标准16进制数
            color = [color stringByReplacingCharactersInRange:[color rangeOfString:@"#"] withString:@"0x"];
            // 十六进制字符串转成整形。
            long colorLong = strtoul([color cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
            // 通过位与方法获取三色值
            int R = (colorLong & 0xFF0000 )>>16;
            int G = (colorLong & 0x00FF00 )>>8;
            int B =  colorLong & 0x0000FF;
            
            //string转color
            UIColor *wordColor = [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0];
            
            if (_lotteryId == 72) {
                [mainTeamMessageLabel setText:[NSString stringWithFormat:@"%@(主)",[dic objectForKey:@"mainTeam"]]];
                
                UILabel *spfLable = (UILabel *)[cell.contentView viewWithTag:666];
                UILabel *spfResult = (UILabel *)[cell.contentView viewWithTag:6666];
                [spfLable setBackgroundColor:wordColor];
                [spfResult setBackgroundColor:wordColor];
                [spfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [spfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [spfLable setText:[dic objectForKey:@"spfResult"]];
                [spfResult setText:[dic objectForKey:@"spfSp"]];
                
                UILabel *rqspfLable = (UILabel *)[cell.contentView viewWithTag:667];
                UILabel *rqspfResult = (UILabel *)[cell.contentView viewWithTag:6677];
                [rqspfLable setBackgroundColor:wordColor];
                [rqspfResult setBackgroundColor:wordColor];
                [rqspfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [rqspfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [rqspfLable setText:[NSString stringWithFormat:@"(%@)%@",[dic objectForKey:@"mainLoseBall"],[dic objectForKey:@"rqspfResult"]]];
                [rqspfResult setText:[dic objectForKey:@"rqspfSp"]];
                
                UILabel *bfLable = (UILabel *)[cell.contentView viewWithTag:668];
                UILabel *bfResult = (UILabel *)[cell.contentView viewWithTag:6688];
                [bfLable setBackgroundColor:wordColor];
                [bfResult setBackgroundColor:wordColor];
                [bfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bfLable setText:[dic objectForKey:@"bfResult"]];
                [bfResult setText:[dic objectForKey:@"bfSp"]];
                
                UILabel *zjqLable = (UILabel *)[cell.contentView viewWithTag:669];
                UILabel *zjqResult = (UILabel *)[cell.contentView viewWithTag:6699];
                [zjqLable setBackgroundColor:wordColor];
                [zjqResult setBackgroundColor:wordColor];
                [zjqLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [zjqResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [zjqLable setText:[NSString stringWithFormat:@"%@球",[dic objectForKey:@"zjqResult"]]];
                [zjqResult setText:[dic objectForKey:@"zjqSp"]];
                
                UILabel *bqcLable = (UILabel *)[cell.contentView viewWithTag:670];
                UILabel *bqcResult = (UILabel *)[cell.contentView viewWithTag:6700];
                [bqcLable setBackgroundColor:wordColor];
                [bqcResult setBackgroundColor:wordColor];
                [bqcLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bqcResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bqcLable setText:[dic objectForKey:@"bqcResult"]];
                [bqcResult setText:[dic objectForKey:@"bqcSp"]];
                
            } else if (_lotteryId == 45) {
                [mainTeamMessageLabel setText:[NSString stringWithFormat:@"%@(主)",[dic objectForKey:@"mainTeam"]]];
                
                UILabel *spfLable = (UILabel *)[cell.contentView viewWithTag:666];
                UILabel *spfResult = (UILabel *)[cell.contentView viewWithTag:6666];
                [spfLable setBackgroundColor:wordColor];
                [spfResult setBackgroundColor:wordColor];
                [spfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [spfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [spfLable setText:[dic objectForKey:@"sxdsResult"]];
                [spfResult setText:[dic objectForKey:@"sxdsSp"]];
                
                UILabel *rqspfLable = (UILabel *)[cell.contentView viewWithTag:667];
                UILabel *rqspfResult = (UILabel *)[cell.contentView viewWithTag:6677];
                [rqspfLable setBackgroundColor:wordColor];
                [rqspfResult setBackgroundColor:wordColor];
                [rqspfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [rqspfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [rqspfLable setText:[NSString stringWithFormat:@"(%@)%@",[dic objectForKey:@"giveBall"],[dic objectForKey:@"rqspfResult"]]];
                [rqspfResult setText:[dic objectForKey:@"rqspfSp"]];
                
                UILabel *bfLable = (UILabel *)[cell.contentView viewWithTag:668];
                UILabel *bfResult = (UILabel *)[cell.contentView viewWithTag:6688];
                [bfLable setBackgroundColor:wordColor];
                [bfResult setBackgroundColor:wordColor];
                [bfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bfLable setText:[dic objectForKey:@"bfResult"]];
                [bfResult setText:[dic objectForKey:@"bfSp"]];
                
                UILabel *zjqLable = (UILabel *)[cell.contentView viewWithTag:669];
                UILabel *zjqResult = (UILabel *)[cell.contentView viewWithTag:6699];
                [zjqLable setBackgroundColor:wordColor];
                [zjqResult setBackgroundColor:wordColor];
                [zjqLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [zjqResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [zjqLable setText:[NSString stringWithFormat:@"%@球",[dic objectForKey:@"zjqsResult"]]];
                [zjqResult setText:[dic objectForKey:@"zjqsSp"]];
                
                UILabel *bqcLable = (UILabel *)[cell.contentView viewWithTag:670];
                UILabel *bqcResult = (UILabel *)[cell.contentView viewWithTag:6700];
                [bqcLable setBackgroundColor:wordColor];
                [bqcResult setBackgroundColor:wordColor];
                [bqcLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bqcResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bqcLable setText:[dic objectForKey:@"bqcResult"]];
                [bqcResult setText:[dic objectForKey:@"bqcSp"]];
                
            }else {
                // 竞彩篮球 客队在前，主队在后
                [mainTeamMessageLabel setText:[NSString stringWithFormat:@"%@(客)",[dic objectForKey:@"guestTeam"]]];
                
                UILabel *spfLable = (UILabel *)[cell.contentView viewWithTag:666];
                UILabel *spfResult = (UILabel *)[cell.contentView viewWithTag:6666];
                [spfLable setBackgroundColor:wordColor];
                [spfResult setBackgroundColor:wordColor];
                [spfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [spfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [spfLable setText:[NSString stringWithFormat:@"%@分",[dic objectForKey:@"dxfResult"]]];
                [spfResult setText:[dic objectForKey:@"dxfSp"]];
                
                UILabel *rqspfLable = (UILabel *)[cell.contentView viewWithTag:667];
                UILabel *rqspfResult = (UILabel *)[cell.contentView viewWithTag:6677];
                [rqspfLable setBackgroundColor:wordColor];
                [rqspfResult setBackgroundColor:wordColor];
                [rqspfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [rqspfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [rqspfLable setText:[NSString stringWithFormat:@"%@",[dic objectForKey:@"rfsfResult"]]];
                [rqspfResult setText:[dic objectForKey:@"rfsfSp"]];
                
                UILabel *bfLable = (UILabel *)[cell.contentView viewWithTag:668];
                UILabel *bfResult = (UILabel *)[cell.contentView viewWithTag:6688];
                [bfLable setBackgroundColor:wordColor];
                [bfResult setBackgroundColor:wordColor];
                [bfLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bfResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [bfLable setText:[dic objectForKey:@"sfResult"]];
                [bfResult setText:[dic objectForKey:@"sfSp"]];
                
                UILabel *zjqLable = (UILabel *)[cell.contentView viewWithTag:669];
                UILabel *zjqResult = (UILabel *)[cell.contentView viewWithTag:6699];
                [zjqLable setBackgroundColor:wordColor];
                [zjqResult setBackgroundColor:wordColor];
                [zjqLable setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [zjqResult setTextColor:[UIColor colorWithRed:0xb1/255.0f green:0x70/255.0f blue:0x0c/255.0f alpha:1.0f]];
                [zjqLable setText:[NSString stringWithFormat:@"%@",[dic objectForKey:@"sfcResult"]]];
                [zjqResult setText:[dic objectForKey:@"sfcSp"]];
            }
            
            //spFresultLabel 主vs客的信息
            UILabel *spfResultLabel = (UILabel *)[cell.contentView viewWithTag:605];
            
            //spfScoreLabel
            UILabel *spfScoreLabel = (UILabel *)[cell.contentView viewWithTag:606];
            
            
            if (_lotteryId == 72) {
                [spfResultLabel setText:[NSString stringWithFormat:@"%@", [dic objectForKey:@"cbfResult"]]];
                [spfResultLabel setTextColor:[UIColor colorWithRed:0xff/255.0f green:0x00/255.0f blue:0x05/255.0f alpha:1.0f]];
                
                [spfScoreLabel setText:[NSString stringWithFormat:@"半 %@",[dic objectForKey:@"halfResult"]]];
                [spfScoreLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                
            } else if (_lotteryId == 45) {
                [spfResultLabel setText:[NSString stringWithFormat:@"%@", [dic objectForKey:@"fullScore"]]];
                [spfResultLabel setTextColor:[UIColor colorWithRed:0xff/255.0f green:0x00/255.0f blue:0x05/255.0f alpha:1.0f]];
                
                [spfScoreLabel setText:[NSString stringWithFormat:@"半 %@",[dic objectForKey:@"halfCourtScore"]]];
                [spfScoreLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
                
            }else {
                [spfResultLabel setText:[NSString stringWithFormat:@"%@", [dic objectForKey:@"result"]]];
                [spfResultLabel setTextColor:[UIColor colorWithRed:0xff/255.0f green:0x00/255.0f blue:0x05/255.0f alpha:1.0f]];
                
                [spfScoreLabel setText:[NSString stringWithFormat:@"让分 %@",[dic objectForKey:@"giveWinLoseScore"]]];
                [spfScoreLabel setTextColor:[UIColor colorWithRed:0x90/255.0f green:0x90/255.0f blue:0x90/255.0f alpha:1.0f]];
            }
            
            
            //guestTeamMessageLabel 客队信息
            UILabel *guestTeamMessageLabel = (UILabel *)[cell.contentView viewWithTag:607];
            if (_lotteryId == 72 || _lotteryId == 45) {
                [guestTeamMessageLabel setText:[NSString stringWithFormat:@"%@(客)",[dic objectForKey:@"guestTeam"]]];
            } else {
                // 竞彩篮球 客队在前，主队在后
                [guestTeamMessageLabel setText:[NSString stringWithFormat:@"%@(主)",[dic objectForKey:@"mainTeam"]]];
            }
        } else {
            
            NSDictionary *detailDic = nil;
            if (indexPath.row < [_detailArray count]) {
                detailDic = [_detailArray objectAtIndex:indexPath.row];
            }
            
            NSString *winNumStr = [detailDic objectForKey:@"winLotteryNumber"];
            
            //issueLabel 彩种名
            UILabel *issueLabel = (UILabel *)[cell.contentView viewWithTag:602];
            [issueLabel setText:[NSString stringWithFormat:@"第%@期",[detailDic objectForKey:@"name"]]];
            
            //dateLabel 开奖时间
            UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:603];
            
            if (!_isQuickLotteryView) {
                NSString *dateStr = [detailDic objectForKey:@"EndTime"];
                NSString *weekDay = [Globals getWeekDay:dateStr];
                [dateLabel setText:[NSString stringWithFormat:@"%@ (%@)",dateStr,weekDay]];
                
                
            } else {
                [dateLabel setText:[detailDic objectForKey:@"EndTime"]];
            }
            
            //signButton
            UIButton *signButton = (UIButton *)[cell.contentView viewWithTag:604];
            [signButton setSelected:[_selectArray containsObject:indexPath]];
            
            //seleCountLabel 本期销量
            UILabel *seleCountLabel = (UILabel *)[cell.contentView viewWithTag:620];
            [seleCountLabel setText:[detailDic intValueForKey:@"Sales"] != 0 ? [detailDic stringForKey:@"Sales"] : @"-"];
            
            //poolCountLabel 奖池奖金
            UILabel *poolCountLabel = (UILabel *)[cell.contentView viewWithTag:621];
            if(!(_lotteryId != 28 && _lotteryId != 70 && _lotteryId != 62 && _lotteryId != 83)){
                [poolCountLabel setText:[detailDic intValueForKey:@"TotalMoney"] != 0 ? [detailDic stringForKey:@"TotalMoney"] : @"-"];
                
            }
            
            
            //backView 用来添加开奖号码的视图
            UIView *backView = (UIView *)[cell.contentView viewWithTag:601];
            for (UIView *view in backView.subviews) {
                if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[CustomLabel class]]) {
                    [view removeFromSuperview];
                }
            }
            
            CGFloat issueLabelMinX = CGRectGetMinX(issueLabel.frame); //开奖号码的x等于彩种名的x
            CGFloat issueLabelMaxY = CGRectGetMaxY(issueLabel.frame);
            
            /********************** adjustment 控件调整 ***************************/
            CGFloat winNumberMinX = CGRectGetMinX(issueLabel.frame); //获奖号码摆布的x坐标为namelabel的x坐标
            CGFloat winNumberMinY = CGRectGetMaxY(issueLabel.frame);//获奖号码摆布的y坐标为namelabel的MaxY + 5
            
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
            CGRect imgViewRect = CGRectMake(winNumberMinX, winNumberMinY + 3, imgSizeWidth, imgSizeHeight - (IS_PHONE ? 10.0f : 13.0f));
            [imgView setFrame:imgViewRect];
            
            UILabel *andValuesLable = (UILabel *)[cell.contentView viewWithTag:511];
            CGRect andValuesLableRect = CGRectMake(CGRectGetMaxX(imgViewRect) + buttonInterval * 5, CGRectGetMinY(imgViewRect) - (IS_PHONE ? 5.0f : 8.0f), imgSizeHeight + (IS_PHONE ? 20.0f : 23.0f), imgSizeHeight);
            [andValuesLable setFrame:andValuesLableRect];
            
            if (_lotteryId == 83 && indexPath.row == 0) {
                [imgView setHidden:NO];
                [andValuesLable setHidden:NO];
            } else {
                [imgView setHidden:YES];
                [andValuesLable setHidden:YES];
            }
            
            if(_lotteryId == 5 || _lotteryId == 39 || _lotteryId == 13) {   // 双色球和大乐透，有蓝球
                if (indexPath.row == 0) {
                    NSArray *array = [winNumStr componentsSeparatedByString:@"+"];
                    NSString *redNum=[NSString string];
                    NSString *blueNum=[NSString string];
                    
                    if(array.count > 1) {
                        redNum = [array objectAtIndex:0];
                        blueNum = [array objectAtIndex:1];
                    }
                    
                    //winNumberLabel 开奖号码，红蓝球类型
                    CGRect winNumberLabelRect = IS_PHONE ? CGRectMake(winNumberMinX, winNumberMinY + 4, 250, 25) : CGRectMake(winNumberMinX, issueLabelMaxY + 8, 400, 30);
                    CustomLabel *winNumberLabel = [[CustomLabel alloc]initWithFrame:winNumberLabelRect];
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
                    CGRect winNumberLabelRect = IS_PHONE ? CGRectMake(issueLabelMinX, issueLabelMaxY + 4, 250, 25) : CGRectMake(issueLabelMinX, issueLabelMaxY + 8, 400, 30);
                    CustomLabel *winNumberLabel = [[CustomLabel alloc]initWithFrame:winNumberLabelRect];
                    [winNumberLabel setBackgroundColor:[UIColor clearColor]];
                    [backView addSubview:winNumberLabel];
                    [winNumberLabel release];
                    
                    NSArray *array = [winNumStr componentsSeparatedByString:@"+"];
                    NSString *redNum=[NSString string];
                    NSString *blueNum=[NSString string];
                    
                    if(array.count > 1) {
                        redNum = [array objectAtIndex:0];
                        blueNum = [array objectAtIndex:1];
                    }
                    
                    redNum = [redNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    blueNum = [blueNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *text = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font><font color=\"%@\">%@</font>",tRedColorText,redNum,tBlueColorText,blueNum];
                    
                    MarkupParser *p = [[MarkupParser alloc]init];
                    NSAttributedString *attString = [p attrStringFromMarkup:text];
                    [winNumberLabel setAttString:attString];
                    [p release];
                }

            } else {
                if (indexPath.row == 0) {
                    if(_lotteryId == 74 || _lotteryId == 75) {   // 胜负彩、任选九
                        for (NSInteger charIndex = 0 ; charIndex < winNumStr.length; charIndex++) {
                            CGRect labelsRect = CGRectMake(winNumberMinX + (sfLabelWidth + sfLabelLandscapeInterval) * charIndex, winNumberMinY, sfLabelWidth, sfLabelHeight);
                            UILabel *labels = [[UILabel alloc]initWithFrame:labelsRect];
                            [labels setBackgroundColor:[UIColor redColor]];
                            [labels setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
                            [labels setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize16]];
                            [labels setTextColor:[UIColor whiteColor]];
                            [labels setTextAlignment:NSTextAlignmentCenter];
                            [labels setText:[winNumStr substringWithRange:NSMakeRange(charIndex, 1)]];
                            [backView addSubview:labels];
                            [labels release];
                        }
                    } else if (_lotteryId == 62 || _lotteryId == 69 || _lotteryId == 70 || _lotteryId == 78) {  // 11运夺金    03 02 10 05 11
                        NSArray *arr = [winNumStr componentsSeparatedByString:@" "];
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
                        if (_lotteryId == 83) {
                            NSMutableArray *cMutableArray = [[NSMutableArray alloc] init];
                            for(NSInteger i = 0;i < [winNumStr length];i++){
                                unichar c = [winNumStr characterAtIndex:i];
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
                                button.frame = CGRectMake((buttonSize + buttonInterval *4) * i + buttonInterval * 3, 1, buttonSize + (IS_PHONE ? 5 : 16), buttonSize + (IS_PHONE ? 5 : 16));
                                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize16]];
                                [imgView addSubview:button];
                            }
                            NSNumber *sum = [cMutableArray valueForKeyPath:@"@sum.floatValue"];
                            NSString *sumStr = [NSString stringWithFormat:@"%@",sum];
                            [andValuesLable setText:[NSString stringWithFormat:@"和值:%@",sumStr]];
                            [cMutableArray release];
                            
                        } else {
                            for(NSInteger i = 0;i < [winNumStr length];i++){
                                unichar c = [winNumStr characterAtIndex:i];
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
                } else {
                    if(_lotteryId == 74 || _lotteryId == 75) {   // 胜负彩、任选九
                        for (NSInteger charIndex = 0 ; charIndex < winNumStr.length; charIndex++) {
                            CGRect labelsRect = CGRectMake(winNumberMinX + (sfLabelWidth + sfLabelLandscapeInterval) * charIndex, winNumberMinY, sfLabelWidth, sfLabelHeight);
                            UILabel *labels = [[UILabel alloc]initWithFrame:labelsRect];
                            [labels setBackgroundColor:[UIColor clearColor]];
                            [labels setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
                            [labels setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
                            [labels setTextAlignment:NSTextAlignmentCenter];
                            [labels setText:[winNumStr substringWithRange:NSMakeRange(charIndex, 1)]];
                            [backView addSubview:labels];
                            [labels release];
                        }
                    } else if (_lotteryId == 62 || _lotteryId == 70 || _lotteryId == 78) {
                        //winNumerNormalLabel  普通开奖号码，单红色类型
                        CGRect winNumberNormalLabelRect = IS_PHONE ? CGRectMake(winNumberMinX, winNumberMinY + 4, 250, 25) : CGRectMake(winNumberMinX, winNumberMinY + 8, 400, 30);
                        UILabel *winNumerNormalLabel = [[UILabel alloc]initWithFrame:winNumberNormalLabelRect];
                        [winNumerNormalLabel setText:winNumStr];
                        [winNumerNormalLabel setBackgroundColor:[UIColor clearColor]];
                        [winNumerNormalLabel setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
                        [winNumerNormalLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
                        [backView addSubview:winNumerNormalLabel];
                        [winNumerNormalLabel release];
                    } else {
                        if (_lotteryId == 83) {
                            NSMutableArray *cMutableArray = [[NSMutableArray alloc] init];
                            for(NSInteger i = 0;i < [winNumStr length];i++){
                                unichar c = [winNumStr characterAtIndex:i];
                                NSString *str = [NSString stringWithFormat:@"%c",c];
                                UILabel *winNumerNormalLabel = [[UILabel alloc]initWithFrame:CGRectMake((buttonSize + buttonInterval) * i + winNumberMinX, winNumberMinY, buttonSize, buttonSize)];
                                [winNumerNormalLabel setText:str];
                                [cMutableArray addObject:str];
                                [winNumerNormalLabel setBackgroundColor:[UIColor clearColor]];
                                [winNumerNormalLabel setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
                                [winNumerNormalLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
                                [backView addSubview:winNumerNormalLabel];
                                [winNumerNormalLabel release];
                            }
                            NSNumber *sum = [cMutableArray valueForKeyPath:@"@sum.floatValue"];
                            NSString *sumStr = [NSString stringWithFormat:@"%@",sum];
                            [andValuesLable setHidden:NO];
                            [andValuesLable setText:[NSString stringWithFormat:@"和值:%@",sumStr]];
                            [cMutableArray release];
                            
                        } else {
                            for(NSInteger i = 0;i < [winNumStr length];i++){
                                unichar c = [winNumStr characterAtIndex:i];
                                NSString *str = [NSString stringWithFormat:@"%c",c];
                                UILabel *winNumerNormalLabel = [[UILabel alloc]initWithFrame:CGRectMake((buttonSize + buttonInterval) * i + winNumberMinX, winNumberMinY, buttonSize, buttonSize)];
                                [winNumerNormalLabel setText:str];
                                [winNumerNormalLabel setBackgroundColor:[UIColor clearColor]];
                                [winNumerNormalLabel setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
                                [winNumerNormalLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
                                [backView addSubview:winNumerNormalLabel];
                                [winNumerNormalLabel release];
                            }
                        }
                    }
                }
            }
            [tableTabelView reloadData];
        }
        
        return cell;
    } else if (tableView.tag >= 1100){
        static NSString *issueCellIdentifier = @"IssueDetailTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:issueCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:issueCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            CGFloat lineViewRectWidth = AllLineWidthOrHeight;
            if (_lotteryId == 83 || _lotteryId == 28 || _lotteryId == 62 || _lotteryId == 70) {
                //line1View
                CGRect line1ViewRect = IS_PHONE ? CGRectMake(0 , 0, lineViewRectWidth, IssueDetailViewTableCellHeight) : CGRectMake(CGRectGetWidth(tableView.frame) / 2 , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line1ViewRect inSuperView:cell.contentView];
                
                //line2View 第1竖线
                CGRect line2ViewRect = IS_PHONE ? CGRectMake(150 , 0, lineViewRectWidth, IssueDetailViewTableCellHeight) : CGRectMake(CGRectGetWidth(tableView.frame) / 2 , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line2ViewRect inSuperView:cell.contentView];
                
                //line3View
                CGRect line3ViewRect = IS_PHONE ? CGRectMake(CGRectGetWidth(tableView.frame) - AllLineWidthOrHeight , 0, lineViewRectWidth, IssueDetailViewTableCellHeight) : CGRectMake(CGRectGetWidth(tableView.frame) / 2 , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line3ViewRect inSuperView:cell.contentView];

                //verticalLine1View
                CGRect verticalLine1ViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
                UIView *verticalLine1View = [[UIView alloc] initWithFrame:verticalLine1ViewRect];
                [verticalLine1View setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
                [verticalLine1View setTag:630];
                [cell.contentView addSubview:verticalLine1View];
                [verticalLine1View release];
                
                //verticalLine2View
                CGRect verticalLine2ViewRect = CGRectMake(0, IssueDetailViewTableCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
                UIView *verticalLine2View = [[UIView alloc] initWithFrame:verticalLine2ViewRect];
                [verticalLine2View setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
                [verticalLine2View setTag:631];
                [cell.contentView addSubview:verticalLine2View];
                [verticalLine2View release];
                
                CGSize itemSize = IS_PHONE ? CGSizeMake(CGRectGetWidth(tableView.frame) / 2, IssueDetailViewTableCellHeight) : CGSizeMake(CGRectGetWidth(tableView.frame)/2, IssueDetailViewTableCellHeight);
                //bonusNameLabel 奖项名
                UILabel *bonusNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
                [bonusNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                [bonusNameLabel setTextAlignment:NSTextAlignmentCenter];
                [bonusNameLabel setBackgroundColor:[UIColor clearColor]];
                [bonusNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
                [bonusNameLabel setTag:701];
                [cell.contentView addSubview:bonusNameLabel];
                [bonusNameLabel release];
                
                //winningCountLabel 中奖注数
                UILabel *winningCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(itemSize.width, 0, itemSize.width + 50, itemSize.height)];
                [winningCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                [winningCountLabel setTextAlignment:NSTextAlignmentCenter];
                [winningCountLabel setBackgroundColor:[UIColor clearColor]];
                [winningCountLabel setTag:702];
                [cell.contentView addSubview:winningCountLabel];
                [winningCountLabel release];
                
            } else {
                //line1View 第1竖线
                CGRect line1ViewRect = CGRectMake(0 , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line1ViewRect inSuperView:cell.contentView];
                
                //line2View 第2竖线
                CGRect line2ViewRect = CGRectMake(CGRectGetWidth(tableView.frame) / 3 , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line2ViewRect inSuperView:cell.contentView];
                
                //line3View 第3竖线
                CGRect line3ViewRect = CGRectMake(CGRectGetWidth(tableView.frame) / 3 * 2 , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line3ViewRect inSuperView:cell.contentView];
                
                //line4View 第4竖线
                CGRect line4ViewRect = CGRectMake(CGRectGetWidth(tableView.frame) / 3 * 3 - AllLineWidthOrHeight , 0, AllLineWidthOrHeight, IssueDetailViewTableCellHeight);
                [Globals makeLineWithFrame:line4ViewRect inSuperView:cell.contentView];
                
                //verticalLine1View
                CGRect verticalLine1ViewRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
                UIView *verticalLine1View = [[UIView alloc] initWithFrame:verticalLine1ViewRect];
                [verticalLine1View setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
                [verticalLine1View setTag:630];
                [cell.contentView addSubview:verticalLine1View];
                [verticalLine1View release];
                
                //verticalLine2View
                CGRect verticalLine2ViewRect = CGRectMake(0, IssueDetailViewTableCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
                UIView *verticalLine2View = [[UIView alloc] initWithFrame:verticalLine2ViewRect];
                [verticalLine2View setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
                [verticalLine2View setTag:631];
                [cell.contentView addSubview:verticalLine2View];
                [verticalLine2View release];
                
                CGSize itemSize = CGSizeMake(CGRectGetWidth(tableView.frame)/3, IssueDetailViewTableCellHeight);
                //bonusNameLabel 奖项名
                CGRect bonusNameLabelRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
                UILabel *bonusNameLabel = [[UILabel alloc]initWithFrame:bonusNameLabelRect];
                [bonusNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                [bonusNameLabel setTextAlignment:NSTextAlignmentCenter];
                [bonusNameLabel setBackgroundColor:[UIColor clearColor]];
                [bonusNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
                [bonusNameLabel setTag:703];
                [cell.contentView addSubview:bonusNameLabel];
                [bonusNameLabel release];
                
                //winningCountLabel 中奖注数
                UILabel *winningCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(itemSize.width, 0, itemSize.width, itemSize.height)];
                [winningCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                [winningCountLabel setTextAlignment:NSTextAlignmentCenter];
                [winningCountLabel setBackgroundColor:[UIColor clearColor]];
                [winningCountLabel setTag:704];
                [cell.contentView addSubview:winningCountLabel];
                [winningCountLabel release];
                
                //bonusValueLabel 每注金额
                UILabel *bonusValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(2 * itemSize.width, 0, itemSize.width, itemSize.height)];
                [bonusValueLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
                [bonusValueLabel setTextAlignment:NSTextAlignmentCenter];
                [bonusValueLabel setBackgroundColor:[UIColor clearColor]];
                [bonusValueLabel setTextColor:kRedColor];
                [bonusValueLabel setTag:705];
                [cell.contentView addSubview:bonusValueLabel];
                [bonusValueLabel release];
            }
        }
        
        UIView *verticalLine1View = (UIView *)[cell.contentView viewWithTag:630];
        if (indexPath.row == 0) {
            [verticalLine1View setHidden:NO];
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
        } else {
            [verticalLine1View setHidden:YES];
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        }
        
        NSDictionary *dict = nil;
        if (tableView.tag - 1100 < [_detailArray count]) {
            dict =[_detailArray objectAtIndex:tableView.tag - 1100];
        }
        
        NSArray *bonusArray = (NSArray *)[dict objectForKey:@"WinDetail"];
        if (![bonusArray isKindOfClass:[NSArray class]]) {
            bonusArray = nil;
        }
        
        
        if (_lotteryId == 83 || _lotteryId == 28 || _lotteryId == 62 || _lotteryId == 70) {
            //bonusNameLabel 奖项名
            UILabel *bonusNameLabel = (UILabel *)[cell.contentView viewWithTag:701];
            [bonusNameLabel setText:@""];
            //winningCountLabel 中奖注数
            UILabel *winningCountLabel = (UILabel *)[cell.contentView viewWithTag:702];
            [winningCountLabel setText:@""];
            if (bonusArray.count > 0) {
                if(indexPath.row == 0) {
                    [bonusNameLabel setText:@"奖项"];
                    [winningCountLabel setTextColor:[UIColor blackColor]];
                    [winningCountLabel setText:@"奖金"];
                } else {
                    NSDictionary *dic = [bonusArray objectAtIndex:indexPath.row - 1];
                    [bonusNameLabel setText:[dic objectForKey:@"bonusName"]];
                    [winningCountLabel setTextColor:kRedColor];
                    [winningCountLabel setText:[dic stringForKey:@"bonusValue"].length > 0 ? [dic stringForKey:@"bonusValue"] : @"0"];
                    
                }
            } else {
                if(indexPath.row == 0) {
                    [bonusNameLabel setText:@"奖项"];
                    [winningCountLabel setTextColor:[UIColor blackColor]];
                    [winningCountLabel setText:@"奖金"];
                } else {
                    [bonusNameLabel setText:[_commonBonusNames objectAtIndex:indexPath.row-1]];
                    [winningCountLabel setTextColor:kRedColor];
                    [winningCountLabel setText:@"0"];
                }
            }
            
        } else {
            //bonusNameLabel 奖项名
            UILabel *bonusNameLabel = (UILabel *)[cell.contentView viewWithTag:703];
            [bonusNameLabel setText:@""];
            //winningCountLabel 中奖注数
            UILabel *winningCountLabel = (UILabel *)[cell.contentView viewWithTag:704];
            [winningCountLabel setText:@""];
            
            //bonusValueLabel 每注金额
            UILabel *bonusValueLabel = (UILabel *)[cell.contentView viewWithTag:705];
            [bonusValueLabel setText:@""];
            
            if (indexPath.row == 0) {
                [winningCountLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
                [bonusValueLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
            } else {
                [winningCountLabel setTextColor:[UIColor blackColor]];
                [bonusValueLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0f]];
                
            }
            
            
            if (_lotteryId == 28) {
                if (bonusArray.count == 0) {
                    if (bonusArray.count > 0) {
                        if(indexPath.row == 0) {
                            [bonusNameLabel setText:@"奖项"];
                            [winningCountLabel setTextColor:[UIColor blackColor]];
                            [winningCountLabel setText:@"注数"];
                            [bonusValueLabel setTextColor:[UIColor blackColor]];
                            [bonusValueLabel setText:@"单注金额(元)"];
                            
                        } else {
                            NSDictionary *dic = [bonusArray objectAtIndex:indexPath.row - 1];
                            [bonusNameLabel setText:[dic objectForKey:@"bonusName"]];
                            [winningCountLabel setTextColor:kRedColor];
                            [winningCountLabel setText:[dic stringForKey:@"winningCount"].length > 0 ? [dic objectForKey:@"winningCount"] : @"0"];
                            [bonusValueLabel setTextColor:kRedColor];
                            [bonusValueLabel setText:[dic stringForKey:@"bonusValue"].length > 0 ? [dic objectForKey:@"bonusValue"] : @"0"];
                            
                        }
                    } else {
                        if(indexPath.row == 0) {
                            [bonusNameLabel setText:@"奖项"];
                            [winningCountLabel setTextColor:[UIColor blackColor]];
                            [winningCountLabel setText:@"注数"];
                            [bonusValueLabel setTextColor:[UIColor blackColor]];
                            [bonusValueLabel setText:@"单注金额(元)"];
                            
                        } else {
                            [bonusNameLabel setText:[_commonBonusNames objectAtIndex:indexPath.row-1]];
                            [winningCountLabel setTextColor:kRedColor];
                            [winningCountLabel setText:@"0"];
                            [bonusValueLabel setTextColor:kRedColor];
                            [bonusValueLabel setText:@"0"];
                            
                        }
                    }
                } else {
                    [_sslArray removeAllObjects];
                    [_sslArray addObjectsFromArray:bonusArray];
                    [_sslArray removeObjectAtIndex:6];
                    [_sslArray removeObjectAtIndex:9];
                    if (_sslArray.count > 0) {
                        if(indexPath.row == 0) {
                            [bonusNameLabel setText:@"奖项"];
                            [winningCountLabel setTextColor:[UIColor blackColor]];
                            [winningCountLabel setText:@"注数"];
                            [bonusValueLabel setTextColor:[UIColor blackColor]];
                            [bonusValueLabel setText:@"单注金额(元)"];
                            
                        } else {
                            NSDictionary *dic = [_sslArray objectAtIndex:indexPath.row - 1];
                            [bonusNameLabel setText:[dic objectForKey:@"bonusName"]];
                            [winningCountLabel setTextColor:kRedColor];
                            [winningCountLabel setText:[dic stringForKey:@"winningCount"].length > 0 ? [dic stringForKey:@"winningCount"] : @"0"];
                            [bonusValueLabel setTextColor:kRedColor];
                            [bonusValueLabel setText:[dic stringForKey:@"bonusValue"].length > 0 ? [dic stringForKey:@"bonusValue"] : @"0"];
                            
                        }
                    } else {
                        if(indexPath.row == 0) {
                            [bonusNameLabel setText:@"奖项"];
                            [winningCountLabel setTextColor:[UIColor blackColor]];
                            [winningCountLabel setText:@"注数"];
                            [bonusValueLabel setTextColor:[UIColor blackColor]];
                            [bonusValueLabel setText:@"单注金额(元)"];
                            
                        } else {
                            [bonusNameLabel setText:[_commonBonusNames objectAtIndex:indexPath.row - 1]];
                            [winningCountLabel setTextColor:kRedColor];
                            [winningCountLabel setText:@"0"];
                            [bonusValueLabel setTextColor:kRedColor];
                            [bonusValueLabel setText:@"0"];
                            
                        }
                    }
                    
                }
            } else if (bonusArray.count > 0) {
                if(indexPath.row == 0) {
                    [bonusNameLabel setText:@"奖项"];
                    [winningCountLabel setTextColor:[UIColor blackColor]];
                    [winningCountLabel setText:@"注数"];
                    [bonusValueLabel setTextColor:[UIColor blackColor]];
                    [bonusValueLabel setText:@"单注金额(元)"];
                    
                } else {
                    NSDictionary *dic = [bonusArray objectAtIndex:indexPath.row - 1];
                    [bonusNameLabel setText:[dic objectForKey:@"bonusName"]];
                    [winningCountLabel setTextColor:kRedColor];
                    [winningCountLabel setText:[dic stringForKey:@"winningCount"].length > 0 ? [dic stringForKey:@"winningCount"] : @"0"];
                    [bonusValueLabel setTextColor:kRedColor];
                    [bonusValueLabel setText:[dic stringForKey:@"bonusValue"].length > 0 ? [dic stringForKey:@"bonusValue"] : @"0"];
                    
                }
            } else {
                if(indexPath.row == 0) {
                    [bonusNameLabel setText:@"奖项"];
                    [winningCountLabel setTextColor:[UIColor blackColor]];
                    [winningCountLabel setText:@"注数"];
                    [bonusValueLabel setTextColor:[UIColor blackColor]];
                    [bonusValueLabel setText:@"单注金额(元)"];
                    
                } else {
                    [bonusNameLabel setText:[_commonBonusNames objectAtIndex:indexPath.row-1]];
                    [winningCountLabel setTextColor:kRedColor];
                    [winningCountLabel setText:@"0"];
                    [bonusValueLabel setTextColor:kRedColor];
                    [bonusValueLabel setText:@"0"];
                    
                }
            }
        }
        return cell;
    }
    static NSString *emptyCellIdentifier = @"EmptyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:emptyCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCellIdentifier] autorelease];
    }
    
    
    
    return cell;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 投注按钮
- (void)gotoBet:(id)sender {
    if (_pushView) {
        return;
    }
    
    // 由于数据过大，竞彩彩种点击才调用接口请求数据
    if (_lotteryId == 72 || _lotteryId == 73 || _lotteryId == 45) {
        
        // 竞彩彩种需重新调用接口，请求详情数据。
        [self getCompetingData:_lotteryId];
    }else {
        [self gotoView];
    }
    
}

#pragma mark 下拉按钮
- (void)dropDownListTouchUpInside:(id)sender {
    UIButton *btn = sender;
    //获取选中section的 下拉状态字典
    NSMutableDictionary *dic = [_dropDic objectForKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    if(btn.isSelected) {
        //如果已经选中 再次点击  收回
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isDropDown"];
    } else {
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
    }
    [dic setObject:[NSNumber numberWithInteger:btn.tag] forKey:@"dropSection"];
    [_dropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    
    [_detailTableView reloadData];
}

#pragma mark - 获取普通彩种的所有中奖期号
- (void)requestData {
    [self clearHTTPRequest];
    [SVProgressHUD showWithStatus:@"正在加载"];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_lotteryId] forKey:@"lotteryId"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",-1] forKey:@"searchType"];
    [infoDic setObject:@"10" forKey:@"searchTotal"];
    [infoDic setObject:@"" forKey:@"startTime"];
    [infoDic setObject:@"" forKey:@"endTime"];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_pageIndex] forKey:@"pageIndex"];
    [infoDic setObject:[NSString stringWithFormat:@"%d",kPageSize] forKey:@"pageSize"];
    [infoDic setObject:@"1" forKey:@"sort"];
    [infoDic setObject:@"0" forKey:@"sortType"];

    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetWinningNumbersOfALotteryIssue userId:@"-1" infoDict:infoDic]];
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

#pragma mark - ASIHTTPRequestDelegate 普通彩种中奖期号接口返回成功方法
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    NSString *error = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]];
    [SVProgressHUD dismiss];
    
    if (![error isEqualToString:@"0"]) {
        [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
        return;
    }
    NSArray *array = [responseDic objectForKey:@"dtWinNumberInfo"];
    
    if ([array count] < kPageSize) {
        [_detailTableView setReachedTheEnd:YES];
        [_detailTableView setHeaderOnly:YES];
        [XYMPromptView defaultShowInfo:@"已加载全部" isCenter:NO];
    }
    [_detailArray addObjectsFromArray:array];
    
    [_detailTableView reloadData];
    [_detailTableView tableViewDidFinishedLoading];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
}

#pragma mark - 获取竞技足球或竞技篮球的所有中奖期号
- (void)requestJCData {
    [self clearJCRequest];
    [SVProgressHUD showWithStatus:@"正在加载"];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_lotteryId] forKey:@"lotteryId"];
    if ([_selectDateStr isEqualToString:@""]) {
        [infoDic setObject:[Globals getNowDateString] forKey:@"lastDay"];
    }else {
        [infoDic setObject:_selectDateStr forKey:@"lastDay"];
    }
    
    _jcRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetJCWinningNumbersOfALotteryIssue userId:@"-1" infoDict:infoDic]];
    [_jcRequest setDelegate:self];
    [_jcRequest setDidFailSelector:@selector(requestJCDataFailed:)];
    [_jcRequest setDidFinishSelector:@selector(requestJCDataFinished:)];
    [_jcRequest startAsynchronous];
}

- (void)clearJCRequest {
    if (_jcRequest != nil) {
        [_jcRequest clearDelegatesAndCancel];
        [_jcRequest release];
        _jcRequest = nil;
    }
}

//竞彩通信部分
- (void)requestJCDataFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
}

- (void)requestJCDataFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    [SVProgressHUD dismiss];

    if (responseDic) {
        
        NSString *error = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]];
        if (![error isEqualToString:@"0"]) {
            [Globals alertWithMessage:[responseDic objectForKey:@"msg"]];
            return;
        }
        NSArray *array = [responseDic objectForKey:@"dtMatch"];
        if(array.count > 0) {
            [_matchDic release];
            [_datehArray removeAllObjects];
            _matchDic = [[array objectAtIndex:0] retain];
            [_datehArray addObjectsFromArray:[responseDic objectForKey:@"matchDate"]];
        } else {
            [Globals alertWithMessage:@"没有开奖信息"];
            return;
        }
        [self initDropStatus];
        [_detailTableView reloadData];
    }
}


- (void)initDropStatus {
    // 第一次加载  全部展开
    if ([_dropDic count] == 0) {
        for (NSInteger i = 0; i < [_matchDic count]; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isDropDown"];
        [dic setObject:[NSNumber numberWithInt:-1] forKey:@"dropSection"];
        [_dropDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
        }
    }
}

- (void)setCommonBonusNames {
    
    if (_lotteryId == 5 || _lotteryId == 3) {       // 双色球、七星彩
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"一等奖",@"二等奖",@"三等奖",@"四等奖",@"五等奖",@"六等奖", nil];
    } else if (_lotteryId == 63) {     // 排列三
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"直选奖",@"组选三奖",@"组选六奖", nil];
    } else if (_lotteryId == 6) {     // 福彩3D
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"直选",@"组选三",@"组选六",@"1D",@"猜1D-中1",@"猜1D-中2",@"猜1D-中3",@"2D",@"猜2D-同号",@"猜2D-不同号",@"通选1",@"通选2",@"和数0或27",@"和数1或26",@"和数2或25",@"和数3或24",@"和数4或23",@"和数5或22",@"和数6或21",@"和数7或20",@"和数8或19",@"和数9或18",@"和数10或17",@"和数11或16",@"和数12或15",@"和数13或14",@"包选三全中",@"包选三组中",@"包选六全中",@"包选六组中",@"猜大小",@"猜三同",@"猜奇偶",@"拖拉机", nil];
    } else if (_lotteryId == 13) {           // 七乐彩
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"一等奖",@"二等奖",@"三等奖",@"四等奖",@"五等奖",@"六等奖",@"七等奖", nil];
    } else if (_lotteryId == 64) {           // 排列五
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"直选奖", nil];
    } else if (_lotteryId == 74 || _lotteryId == 75) {    // 胜负彩、任选九
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"一等奖",@"二等奖", nil];
    } else if (_lotteryId == 39) {           // 大乐透
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"一等奖",@"追加一等奖",@"二等奖",@"追加二等奖",@"三等奖",@"追加三等奖",@"四等奖",@"追加四等奖",@"五等奖",@"追加五等奖",@"六等奖", nil];//@"12选2一等奖",
    } else if (_lotteryId == 28) {           // 时时彩
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"五星奖", @"三星奖", @"二星奖", @"一星奖", @"猜大小奖",@"二星组选奖",@"二星组选奖(对子号)",@"五星通选一等奖",@"五星通选二等奖",@"五星通选三等奖",@"三星组选3",@"三星组选6奖", nil];
    } else if (_lotteryId == 62 || _lotteryId == 70) {           // 十一运夺金、11选5
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"任选一奖", @"任选二奖", @"任选三奖", @"任选四奖", @"任选五奖", @"任选六奖", @"任选七奖", @"任选八奖", @"直选二奖",@"直选三奖", @"组选二奖", @"组选三奖", nil];
    } else if (_lotteryId == 69) {           // 22选5
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"第一名", @"第二名", @"第三名", nil];
    } else if (_lotteryId == 82) {           // 幸运彩
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"场3中3", @"场2中2", @"场1中1", @"任1中1", @"任2中2", @"任3中3", @"任3中2", @"任4中3", @"5中3", @"6中3", @"7中3", @"顺1中1", @"顺2中2", @"顺2中1", @"顺2中2", @"顺3中3", @"顺3中2", @"顺3中1", @"任1场1", @"任1场2", @"任1场3", @"任2场1", @"任2场2", @"任2场3", @"任3场1中1", @"任3场1中2", @"任3场1中3", @"任3场2中1", @"任3场2中2", @"任3场2中3", @"任3场3中1", @"任3场3中2", @"任3场3中3", @"任4场1", @"任4场2", @"任4场3", @"任5场1", @"任5场2", @"任5场3", @"任6场1", @"任6场2", @"任6场3", @"任7场1", @"任7场2", @"任7场3", @"顺1场1", @"顺1场2", @"顺1场3", @"顺2场1中1", @"顺2场1中2", @"顺2场2中1", @"顺2场2中2", @"顺2场3中1", @"顺2场3中2", @"顺3场1中1", @"顺3场1中2", @"顺3场1中3", @"顺3场2中1", @"顺3场2中2", @"顺3场2中3", @"顺3场3中1", @"顺3场3中2", @"顺3场3中3", nil];
    } else if (_lotteryId == 68) {           // 快赢481
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"任选一", @"任选二", @"任选三", @"直选", @"组 24", @"组 12", @"组 6", @"组 4", nil];
    }
    else if (_lotteryId == 83){
        _commonBonusNames = [[NSArray alloc]initWithObjects:@"和值3",@"和值4",@"和值5",@"和值6",@"和值7",@"和值8",@"和值9",@"和值10",@"和值11",@"和值12",@"和值13",@"和值14",@"和值15",@"和值16",@"和值17",@"和值18",@"三不同号",@"三同号单选",@"二同号单选",@"二不同号",@"三同号通选",@"二同号复选",@"三同号连选", nil];
    }
}

#pragma mark - 进入竞彩投注模块
// 请求竞彩对阵数据
- (void)getCompetingData: (NSInteger)lotteryId {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)lotteryId] forKey:@"lotteryId"];
    [infoDic setObject:@"-1" forKey:@"playType"];
    
    [self clearHttpRequest];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_RRQUEDT_GetLotteryInformation userId:@"-1" infoDict:infoDic]];
    [_httpRequest setTimeOutSeconds:20];
    [_httpRequest setDelegate:self];
    [_httpRequest setDidFinishSelector:@selector(getRequestFinished:)];
    [_httpRequest setDidFailSelector:@selector(getRequestFailed:)];
    [_httpRequest startAsynchronous];
    
    [SVProgressHUD showWithStatus:@"加载中"];
}

- (void)clearHttpRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

#pragma mark - ASIHTTPRequestDelegate 获取竞彩投注对阵
- (void)getRequestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    [SVProgressHUD dismiss];
    
    NSArray *infoArray = nil;
    
    if (_lotteryId == 72) {  // 竞彩足球
        
        infoArray = [responseDic objectForKey:@"dtMatch"];
        NSArray *singleArray = [responseDic objectForKey:@"Singlepass"];
        if([infoArray count] != 0) {
            
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            if ([singleArray count] > 0) {
                [matchDict setObject:[singleArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [singleArray objectAtIndex:0] forKey:@"singleMatch"];
                
            }
            
            [_globals.homeViewInfoDict removeObjectForKey:@"72"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"72"];
            
            [self gotoView];
            
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"竞彩足球数据为空");
#endif
            
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
        
    } else if (_lotteryId == 73) {  // 竞彩篮球
        // 获取对阵信息
        infoArray = [responseDic objectForKey:@"dtMatch"];
        NSArray *singleArray = [responseDic objectForKey:@"Singlepass"];
        
        if(infoArray.count != 0) {
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            if ([singleArray count] > 0) {
                [matchDict setObject:[singleArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [singleArray objectAtIndex:0] forKey:@"singleMatch"];
            }
            
            [_globals.homeViewInfoDict removeObjectForKey:@"73"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"73"];
            
            [self gotoView];
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"竞彩篮球数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
    } else if (_lotteryId == 45) {  // 北京单场
        // 获取对阵信息
        infoArray = [responseDic objectForKey:@"dtMatch"];
        
        if(infoArray.count != 0) {
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            
            [_globals.homeViewInfoDict removeObjectForKey:@"45"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"45"];
            
            [self gotoView];
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"北京单场数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
    }
    responseDic = nil;
}

- (void)getRequestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"获取对阵失败"];
}

#pragma mark 竞彩彩种获取数据成功后，调用此方法
- (void)gotoView {
    
    Service *oneS = [Service getDefaultService];
    [oneS setLotteryTypes:_lotteryId];
    
    HomeViewController *homeCtl = [[HomeViewController alloc] init];
    
    NSInteger lotteryIndex = [homeCtl findDetailIndexWithLotteryId:_lotteryId];
    BOOL isCanBet = [homeCtl judgeIsCanBetWithIndex:lotteryIndex andID:_lotteryId];
    
    if (isCanBet) {
        _pushView = YES;
        NSObject *obj = [_globals.homeViewInfoDict objectForKey:[NSString stringWithFormat:@"%ld",(long)_lotteryId]];
        
        UIViewController *dataVC = [GlobalsProject viewController:_lotteryId initWithInfoData:obj];
        if (dataVC != nil) {
            [self.navigationController pushViewController:dataVC animated:YES];
        }
    }
    [homeCtl release];
}

#pragma mark - getTimeSelection 时间筛选赛果
- (void)getTimeSelection:(id)sender {
    
    // 显示日期筛选视图.(动画效果)
    if (_dateView.hidden) {
        [self ViewAnimation:_dateView willHidden:NO];
    }else {
        [self ViewAnimation:_dateView willHidden:YES];
    }
    
}

- (void)btnClick:(UIButton *)btn {
    [self ViewAnimation:_dateView willHidden:YES];
    
    if (btn.tag == 1) {
        NSLog(@"确定");
        [self requestJCData];
    }else {
        NSLog(@"取消");
    }
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *selectDate = [sender date];
    NSString *selectString = [dateFormatter stringFromDate:selectDate];
    
    // 处理野指针内存泄漏
    [_selectDateStr release];
    _selectDateStr = [selectString retain];

    [dateFormatter release];
}

// 弹出时间选择器动画效果
- (void)ViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.3 animations:^{
        if (hidden) {
            _dateBg.hidden = YES;
            _detailTableView.userInteractionEnabled = YES;
            view.frame = CGRectMake(0, kWinSize.height, self.view.frame.size.width, 315);
        } else {
            [view setHidden:hidden];
            _dateBg.hidden = NO;
            _detailTableView.userInteractionEnabled = NO;
            view.frame = CGRectMake(0, kWinSize.height - 315, self.view.frame.size.width, 315);
        }
    } completion:^(BOOL finished) {
        [view setHidden:hidden];
    }];
}

@end
