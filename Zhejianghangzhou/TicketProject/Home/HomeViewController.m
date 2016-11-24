//
//  HomeViewController.m   购彩大厅 1000
//  TicketProject
//
//  Created by sls002 on 13-6-8.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//  20140710 10:11（洪晓彬）：修改代码规范，改进生命周期，处理内存
//  20150721 10:00（刘科）：新增是否开售功能，修复部门彩种信息不显示bug。
//  20150722 11:10（刘科）：添加观察者，侦查程序是否运行。
//  20150819 10:30（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "HomeViewController.h"

#import "BasketBallViewController.h"
#import "DLTViewController.h"
#import "FootBallViewController.h"
#import "LotteryView.h"
#import "LuckyPickViewController.h"
#import "MarqueeView.h"
#import "RJXViewController.h"
#import "SDViewController.h"
#import "SFCViewController.h"
#import "SSQViewController.h"
#import "TimerLabel.h"
#import "XFTabBarViewController.h"
#import "GlobalsProject.h"
#import "SVProgressHUD.h"

#import "ASINetworkQueue.h"
#import "CheckNetWork.h"
#import "Globals.h"
#import "InterfaceHelper.h"
#import "InterfaceHeader.h"
#import "Service.h"
#import "UserInfo.h"

#define HomeViewTableCellHeight (IS_PHONE ? 80.0f : 135.0f) /**< cell的高度*/
//#define HomeViewTableCellHeight (kScreenSize.height-110-64-49)/4.0 /**< cell的高度*/

@interface HomeViewController ()
/** 准备请求登录的方法
 @param  username   用户名
 @param  password   密码 */
- (void)autoLoginWithUserName:(NSString *)username password:(NSString *)password;
/** 向服务器请求各彩种数据 */
- (void)getData;
/** tableview表头刷新控件刷新完毕时执行 将表头收起 */
- (void)doneLoadingTableViewData;
/** 将彩种提示视图移除 */
- (void)removeOverlayView:(UIView *)lb;
/** 判断是否过期 
 @param  endtimeStr   结束时间
 @return 是否过期 */
- (BOOL)isOutOfDate:(NSString *)endtimeStr;
/** 处理或保存从服务器获取的数据
    @param  httpRequest 从服务器返回的数据 */
- (void)processDataWithRequest:(ASIHTTPRequest *)httpRequest;
/** 自动登录 */
- (void)judgeIfLoginAutomatically;
/** 判断是否能够进行投注 
 @param  index   下标
 @param  lotteryid   彩种id
 @return 开奖时间差 */
- (BOOL)judgeIsCanBetWithIndex:(NSInteger)index andID:(NSInteger)lotteryid;
/** 根据点击的Cell弹出不同的投注页面
 @param  lotteryid   彩种id
 @param  index   点击下标 */
- (void)pushViewControllerWithID:(NSInteger)lotteryid index:(NSInteger)index;
@end

#pragma mark -
#pragma mark @implementation HomeViewController
@implementation HomeViewController
@synthesize infoDic  = _infoDic;
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    }
    return self;
}

- (void)dealloc {
    [_winString release];
    _winString = nil;
    [_collectionView release];
    _collectionView = nil;
    [self.mainScorllView release];
    self.mainScorllView = nil;
    _refreshTableHeaderView = nil;
    [_nameArray release];
    _nameArray = nil;
    [_imageArray release];
    _imageArray = nil;
    [_lotterIDArray release];
    _lotterIDArray = nil;
    [urlArray release];
    urlArray = nil;
    _refreshTableHeaderView = nil;
    [_explanationDic release];
    _explanationDic = nil;
    [_againstDic release];
    _againstDic = nil;
    [_timerWinInfo invalidate];
    _timerWinInfo=nil;
    [_infoDic release];
    _infoDic = nil;
    [_todayOpenLotteryArray release];
    _todayOpenLotteryArray = nil;
    SafeClearRequest(_wininfoRequest);
    [super dealloc];
}

- (void)loadView {
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    //baseView 底层
	UIView *baseView = [[UIView alloc] initWithFrame:appRect];
    [baseView setBackgroundColor:kBackgroundColor];
    [self setView:baseView];
    [self.view setExclusiveTouch:YES];
	[baseView release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat prizeBackImageViewMinY = 0.0f;
    /********************** adjustment end ***************************/
    
    //luckyBtn 幸运选号按钮
    UIButton *luckyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [luckyBtn setFrame:XFIponeIpadNavigationLuckButtonRect];
    [luckyBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [luckyBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [luckyBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"luck.png"]] forState:UIControlStateNormal];
    [luckyBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"luck.png"]] forState:UIControlStateHighlighted];
    [luckyBtn addTarget:self action:@selector(selectLuckyNumberTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *luckyItem = [[UIBarButtonItem alloc]initWithCustomView:luckyBtn];
    [self.navigationItem setRightBarButtonItem:luckyItem];
    [luckyItem release];
    
    //homeTableView 中间彩种选择表格视图
    CGRect homeTableViewRect = CGRectMake(0, prizeBackImageViewMinY - AllLineWidthOrHeight, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - kTabBarHeight -44.0f);
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView = [[UICollectionView alloc] initWithFrame:homeTableViewRect collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setCollectionViewLayout:flowLayout animated:YES];
#pragma mark 表头高度设置
    flowLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth(appRect), CGRectGetHeight(appRect) / 4);  //设置head大小
    
    //注册Cell，必须要有
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.view addSubview:_collectionView];
    
    //refreshTableHeaderView 彩种表格顶部的刷新控件
    _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0 - CGRectGetHeight(homeTableViewRect), CGRectGetWidth(appRect), _collectionView.bounds.size.height)];
    [_refreshTableHeaderView setDelegate:self];
    [_collectionView addSubview:_refreshTableHeaderView];
    [_refreshTableHeaderView release];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    [_collectionView addGestureRecognizer:longGesture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _globals = _appDelegate.globals;
    [_refreshTableHeaderView refreshLastUpdatedDate];
    
    _isShowHud = YES;
    
    Service *oneSs = [Service getDefaultService];
    oneSs.commonHomeViewControl = self;
    
    // 获取彩种基本信息
    NSDictionary *dic = [InterfaceHelper getLotteryIDNameDic];
    
    _nameArray = [[NSMutableArray alloc] init];
    _imageArray = [[NSMutableArray alloc] init];
    _lotterIDArray = [[NSMutableArray alloc] init];
    urlArray = [[NSMutableArray alloc] init];
    openUrlArray = [[NSMutableArray alloc] init];
    
    [_nameArray addObjectsFromArray:[dic objectForKey:@"name"]];
    [_imageArray addObjectsFromArray:[dic objectForKey:@"image"]];
    [_lotterIDArray addObjectsFromArray:[dic objectForKey:@"id"]];
    
    if (_infoDic == nil) {
        _infoDic = [[NSMutableDictionary alloc]init];
    }
    
    if (_explanationDic == nil) {
        _explanationDic = [[NSMutableDictionary alloc]init];
    }
    
    if (_againstDic == nil) {
        _againstDic = [[NSMutableDictionary alloc]init];
    }
    
    _todayOpenLotteryArray = [[NSMutableArray alloc] init];
    
    // 获取彩种信息
    [self getData];
    //获取轮播图
    [self loadTabbar];
    
    //增加观察者，当某彩种到了时间的时候刷新数据。（see class TimerLabel）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"selected" object:nil];
    //增加观察者，检测每次回到程序时，刷新购买大厅数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"refresh" object:nil];
}

- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    static NSIndexPath *sourceIndexPath = nil;
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan: {
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[longGesture locationInView:_collectionView]];
            
            if (indexPath == nil) {
                break;
            }
            
            [UIView animateWithDuration:0.5 animations:^{
                
            }];
            
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            cell.alpha = 0.7;
            sourceIndexPath = indexPath;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            NSIndexPath *indexPath = [[_collectionView indexPathForItemAtPoint:[longGesture locationInView:_collectionView]] copy];
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            cell.alpha = 0.7;
            
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                [_collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                NSString *objectToMove1 = [_imageArray objectAtIndex:sourceIndexPath.row];
                [_imageArray removeObjectAtIndex:sourceIndexPath.row];
                [_imageArray insertObject:objectToMove1 atIndex:indexPath.row];
                
                NSString *objectToMove2 = [_lotterIDArray objectAtIndex:sourceIndexPath.row];
                [_lotterIDArray removeObjectAtIndex:sourceIndexPath.row];
                [_lotterIDArray insertObject:objectToMove2 atIndex:indexPath.row];
                
                NSString *objectToMove3 = [_nameArray objectAtIndex:sourceIndexPath.row];
                [_nameArray removeObjectAtIndex:sourceIndexPath.row];
                [_nameArray insertObject:objectToMove3 atIndex:indexPath.row];
                
                sourceIndexPath = indexPath;
            }
            
        }
            
            break;
        case UIGestureRecognizerStateEnded: {
            NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[longGesture locationInView:_collectionView]];
            
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                [_lotterIDArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [_imageArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [_nameArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [_collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                static BOOL isInDuration = NO;
                if (isInDuration) {
                    return;
                }
                isInDuration = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_collectionView reloadData];
                    isInDuration = NO;
                });
            }
            
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            cell.alpha = 1.0;
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.xfTabBarController setTabBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    _globals.isInHomeView = YES;
    
    if (_globals.isNeedRefresh) {
        [self getData];
        
        _globals.isNeedRefresh = NO;
    }
    
    static BOOL isInDuration = NO;
    if (isInDuration) {
        return;
    }
    isInDuration = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
        isInDuration = NO;
    });
    
}

- (void)viewDidAppear:(BOOL)animated {
    _pushViewBegin = NO;
    [self.xfTabBarController setTabBarHidden:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _collectionView = nil;
        _refreshTableHeaderView = nil;
        [_nameArray release];
        _nameArray = nil;
        [_imageArray release];
        _imageArray = nil;
        [_lotterIDArray release];
        _lotterIDArray = nil;
        [urlArray release];
        urlArray = nil;
        [openUrlArray release];
        openUrlArray = nil;
        _refreshTableHeaderView = nil;
        [_explanationDic release];
        _explanationDic = nil;
        [_timerWinInfo invalidate];
        _timerWinInfo=nil;
        [_infoDic release];
        _infoDic = nil;
        [_todayOpenLotteryArray release];
        _todayOpenLotteryArray = nil;
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _globals.isInHomeView = NO;
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma mark Delegate
#pragma mark UITableViewDataSource
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    if(!self.mainScorllView && urlArray.count > 0){
        NSMutableArray *viewsArray = [@[] mutableCopy];
        self.mainScorllView.PageControl.numberOfPages = [urlArray count];
        
        if (urlArray.count == 1) {
            [urlArray addObject:[urlArray objectAtIndex:0]];
            [urlArray addObject:[urlArray objectAtIndex:0]];
            
        } else if (urlArray.count == 2) {
            [urlArray addObject:[urlArray objectAtIndex:0]];
        }
        
        for ( int i=0; i<[urlArray count]; i++) {
            NSDictionary *dic=[urlArray objectAtIndex:i];
            NSString *url = [dic objectForKey:@"picUrl"];
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            UIImageView *img = [[UIImageView alloc] initWithImage:image];
            img.frame = CGRectMake(0, 0, reusableview.bounds.size.width, reusableview.bounds.size.height);
            img.contentMode = UIViewContentModeScaleAspectFill;
            [viewsArray addObject:img];
        }
        
        self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, reusableview.bounds.size.width, reusableview.bounds.size.height) animationDuration:5];
        
        self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return viewsArray[pageIndex];
        };
        
        self.mainScorllView.totalPagesCount = ^NSInteger(void){
            return [urlArray count];
        };
        
        self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
            NSLog(@"点击的是第%ld张",(long)pageIndex);
            NSString *opUrlStirng = nil;
            
            if ([openUrlArray count] > pageIndex) {
                opUrlStirng  = [[openUrlArray objectAtIndex:pageIndex] objectForKey:@"picUrl1"];
                NSRange range = [opUrlStirng rangeOfString:@"http://"];
                if (range.length == 0) {
                    opUrlStirng = [@"http://" stringByAppendingString:opUrlStirng];
                }
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:opUrlStirng]];
        };
        
        [reusableview addSubview:self.mainScorllView];
    }
    
   
    
    return reusableview;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _lotterIDArray.count;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CGRect firstColLotteryViewRect = CGRectMake(-AllLineWidthOrHeight, -AllLineWidthOrHeight, cell.width + AllLineWidthOrHeight, HomeViewTableCellHeight + AllLineWidthOrHeight);
    LotteryView * firstColLotteryView = [[LotteryView alloc] initWithFrame:firstColLotteryViewRect];
    [firstColLotteryView setBackgroundColor:[UIColor whiteColor]];
    [firstColLotteryView setDelegate:self];
    [[firstColLotteryView layer] setBorderWidth:AllLineWidthOrHeight];
    [[firstColLotteryView layer] setBorderColor:[UIColor colorWithRed:0xea/255.0f green:0xea/255.0f blue:0xea/255.0f alpha:1.0f].CGColor];
    [firstColLotteryView setLotteryImageName:[_imageArray objectAtIndex:indexPath.row]];
    [self fillTabelCellWithLotteryView:firstColLotteryView arrayIndex:indexPath.row isClear:NO];
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    [cell.contentView addSubview:firstColLotteryView];
    [firstColLotteryView release];
    
    return cell;
}

//定义每个Item 的大小   定义每个UICollectionView 的大小（返回CGSize：宽度和高度）
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kWinSize.width/2, HomeViewTableCellHeight);
}

//定义每个UICollectionView cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)fillTabelCellWithLotteryView:(LotteryView *)lotteryView arrayIndex:(NSInteger)arrayIndex isClear:(BOOL)isClear {
    [lotteryView setPromptText:@""];
    [lotteryView setMatchText:@""];
    [lotteryView setStopSellTimeStr:@""];
    [lotteryView setLotteryImageName:[_imageArray objectAtIndex:(arrayIndex)]];
    [lotteryView setLotteryName:[_nameArray objectAtIndex:(arrayIndex)]];
    [lotteryView setUserInteractionEnabled:YES];
    [lotteryView setLotteryViewLabelRowType:LotteryViewLabelThreeRow];
    
    NSString *lotteryID = [_lotterIDArray objectAtIndex:arrayIndex];
    [lotteryView setIsTodayOpen:[_todayOpenLotteryArray containsObject:lotteryID]];
    [lotteryView setLotteryId:lotteryID];
    [lotteryView setRow:arrayIndex];
    [lotteryView setCol:arrayIndex];
    
    NSDictionary *dic = nil;
    NSDate *endDate = nil;
    NSTimeInterval intervall = 0;
    
    if(_infoDic) {
        dic = [_infoDic objectForKey:lotteryID];
        // 判断是否开售
        if ([[dic objectForKey:@"isSale"] isEqualToString:@"true"]) {
            if ([[dic objectForKey:@"addaward"] isEqualToString:@"True"]) {
                [lotteryView setHasBonus:YES];
                
            } else {
                [lotteryView setHasBonus:NO];
            }
            
            [lotteryView setPromptText:[dic stringForKey:@"Description"]];
            
            if(dic && [dic objectForKey:@"endtime"]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                endDate = [dateFormatter dateFromString:[dic objectForKey:@"endtime"]];
                [dateFormatter release];
            }
            
            if (endDate) {
                intervall = [self getTimeIntervalWithEndDate:endDate];
            }
            
            if(dic.count != 0 && lotteryID && lotteryID.length > 0) {
                if([lotteryID isEqualToString:@"72"] || [lotteryID isEqualToString:@"73"] || [lotteryID isEqualToString:@"45"]) {
                    // 显示竞彩竞彩近期对阵
                    NSString *matchMsg = [_againstDic objectForKey:lotteryID];
                    if (matchMsg && matchMsg.length > 0) {
                        [lotteryView setMatchText:matchMsg];
                        
                    } else {
                        [lotteryView setMatchText:@""];
                    }
                    
                }else {
                    NSTimeZone *zone = [NSTimeZone localTimeZone];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    // 系统返回时间
                    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[Globals getTimeWithIntervalTime:_globals.serverLocalTimeInterval]];
                    NSTimeInterval currServiceInterval = [zone secondsFromGMTForDate:currentDate];
                    NSDate *serviceDate = [currentDate  dateByAddingTimeInterval: currServiceInterval];
                    // 下一期开始时间
                    NSString *nextstarttimeStr = [dic objectForKey:@"originalTime"];
                    NSDate *tmpNextStartDate = [dateFormatter dateFromString:nextstarttimeStr];
                    NSTimeInterval nextInterval = [zone secondsFromGMTForDate:tmpNextStartDate];
                    NSDate *nextStartDate = [tmpNextStartDate  dateByAddingTimeInterval: nextInterval];
                    [dateFormatter release];
                    
                    NSTimeInterval startTimeInterval = 60.0f;
                    //
                    if (endDate) {
                        startTimeInterval = [tmpNextStartDate timeIntervalSinceNow] - [endDate timeIntervalSinceNow];
                        
                        if (startTimeInterval < 60) {
                            startTimeInterval = 60;
                            
                        }else if (startTimeInterval < 0) {
                            startTimeInterval = 0;
                        }
                    }
                    // 接收 originalTime 值为空，代表没有期号。
                    if ([nextstarttimeStr isEqualToString:@""]) {
                        [lotteryView setMatchText:@"已截止"];
                        
                    }else {
                        // 下一期开始时间早于系统返回时间，则不显示
                        if ([nextStartDate compare:serviceDate] == NSOrderedAscending) {
                            
                        } else {
                            
                            [lotteryView setStopSellTimeStr:[NSString stringWithFormat:@"%f",intervall + [[NSDate date] timeIntervalSinceReferenceDate]]];
                            [lotteryView setNextStartTimeInterval:startTimeInterval];
                            [lotteryView setMatchText:@""];
                        }
                    }
                }
            }
            
        }else {
            [lotteryView setPromptText:@"暂停销售"];
        }
    }
}

#pragma mark -UITableViewDelegate
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark -LotteryViewDelegate
- (void)didSelectLotteryViewWithLotteryId:(NSString *)lotteryId row:(NSInteger)row col:(NSInteger)col {
    if (_pushViewBegin) {
        return;
    }
    _pushViewBegin = YES;
    
    Service *oneS = [Service getDefaultService];
    [oneS setLotteryTypes:lotteryId];
    BOOL isCanBet = [self judgeIsCanBetWithIndex:row andID:[lotteryId integerValue]];
    
    if (!kToDeliverySoftware) {
        isCanBet = YES;//*****************************************试验
    }

    if (isCanBet) {
        _curLotteryid = [lotteryId integerValue];
        _curIndex = row;
        
        if (_curLotteryid == 72 || _curLotteryid == 73 || _curLotteryid == 45) {
            // 当点击的是竞彩彩种时，现请求对阵信息
            [self getCompetingData:[NSString stringWithFormat:@"%ld", (long)_curLotteryid]];
            
        }else {
            [self pushViewControllerWithID:[lotteryId integerValue] index:row];
        }
        
    }
//    else {
//        _pushViewBegin = NO;
//    }
}


#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)deceleratescrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}


//向服务器请求 登录 失败 时的处理方法
- (void)autoLoginFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"登录失败"];
}

//向服务器请求 登录 成功 时的处理方法
- (void)autoLoginFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    
    if (responseDic && [[responseDic objectForKey:@"error"] intValue] == 0) {
        [UserInfo shareUserInfo].userID = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"uid"]];
        [UserInfo shareUserInfo].userName = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"name"]];
        [UserInfo shareUserInfo].realName = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"realityName"]];
        [UserInfo shareUserInfo].cardNumber = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"idcardnumber"]];
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"balance"]];
        [UserInfo shareUserInfo].freeze = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"freeze"]];
        [UserInfo shareUserInfo].handselAmount = [NSString stringWithFormat:@"%@",[responseDic objectForKey:@"handselAmount"]];
        [UserInfo shareUserInfo].phoneNumber = [responseDic stringForKey:@"mobile"];
        [[NSUserDefaults standardUserDefaults]setObject:responseDic forKey:@"userinfo"];
        
        NSMutableDictionary *itemData = (NSMutableDictionary *)[XYMKeyChain loadKeyChainItemWithKey:KEY_KEYCHAINITEM];
        [UserInfo shareUserInfo].password = [NSString stringWithFormat:@"%@",[itemData objectForKey:KEY_PASSWORD]];
        NSString *userName = [itemData objectForKey:KEY_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    responseDic = nil;
}

#pragma mark - 向服务器分别请求 普通彩种，足彩，篮彩  单个失败   时的处理方法
- (void)requestDidFailed:(ASIHTTPRequest *)request {
    _pushViewBegin = NO;
    
    if (request.tag == 1 || request.tag == 2 || request.tag == 3) {
        [SVProgressHUD dismiss];
        
    }else {
        [SVProgressHUD dismiss];
    }
}

//向服务器分别请求 普通彩种，足彩，篮彩  单个成功   时的处理方法
- (void)requestDidFinished:(ASIHTTPRequest *)httpRequest {
    [SVProgressHUD showSuccessWithStatus:@"加载完成"];
    
    _globals.isNeedRefresh = YES;
    // 处理或保存从服务器获取的数据
    [self processDataWithRequest:httpRequest];
    NSDictionary *responseDic = [[httpRequest responseString]objectFromJSONString];
    
    NSLog(@"---home>>---%@",[httpRequest responseString]);
    
    if (responseDic && _queue.requestsCount == 0 && [[responseDic objectForKey:@"error"] intValue] == 0) {
        // 判断是否需要自动登录
        [self judgeIfLoginAutomatically];
    }
    
    if ([_delegate respondsToSelector:@selector(infoDicValue:andOther:)]) {
        [_delegate infoDicValue:_infoDic andOther:_lotterIDArray];
    }
    
    responseDic = nil;
    
}

//向服务器分别请求 普通彩种，足彩，篮彩 都请求完毕后   时的处理方法
- (void)queueDidFinished:(ASIHTTPRequest *)httpRequest {
    if (_queue.requestsCount == 0) {
        static BOOL isInDuration = NO;
        if (isInDuration) {
            return;
        }
        isInDuration = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
            isInDuration = NO;
        });
        
        [self doneLoadingTableViewData];
    }
}

#pragma mark EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    _isLoading = YES;
    [self getData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

#pragma mark -
#pragma mark -Customized(Action)
// 跳转到幸运选号页面
- (void)selectLuckyNumberTouchUpInside:(id)sender {
    if (_pushViewBegin) {
        return;
    }

    LuckyPickViewController *luckyPickView = [[LuckyPickViewController alloc]initWithLotteryDictionary:_infoDic];
    [self.navigationController pushViewController:luckyPickView animated:YES];
    [luckyPickView release];
    _pushViewBegin = YES;
}

//TimerLabel 的刷新通知方法
- (void)refreshTable:(NSNotification *)notification {
    NSString *lotteryId = [NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"cellId"]];
    _globals.isNeedRefresh = YES;
    _isShowHud = NO;
    
    if (_globals.isInHomeView) {
        // 针对某个彩种本期时间截止，刷新数据
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        if ([lotteryId isEqualToString:@"28"] || [lotteryId isEqualToString:@"70"] || [lotteryId isEqualToString:@"78"] || [lotteryId isEqualToString:@"83"] || [lotteryId isEqualToString:@"62"] || [lotteryId isEqualToString:@"66"]) {
            lotteryId = @"28,70,78,83,62,66";
        }
        
        [dic setObject:lotteryId forKey:@"lotteryId"];
        ASIFormDataRequest *httpRequest= [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_RRQUEDT_GetLotteryInformation userId:@"-1" infoDict:dic]];
        [httpRequest setTag:0];
        [httpRequest setTimeOutSeconds:10];
        [_queue addOperation:httpRequest];
        [httpRequest release];
        [dic release];
    }
}

//  监测程序回到前台 调用通知方法
- (void)reloadTable:(NSNotification *)notification {
    _globals.isNeedRefresh = YES;
    _isShowHud = YES;
    
    if (_globals.isInHomeView) {
        [self getData];
    }
}

#pragma mark - 获取轮播图片请求
- (void)loadTabbar {
    ASIFormDataRequest *httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:kBaseUrl]];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    NSString *infoStr = [infoDic JSONString];
    NSString *currentDate = [InterfaceHelper getCurrentDateString];
    NSString *crc = [InterfaceHelper getCrcWithInfo:infoStr UID:@"-1" TimeStamp:currentDate];
    NSString *auth = [InterfaceHelper getAuthStrWithCrc:crc UID:@"-1" TimeStamp:currentDate];
    
    [httpRequest setPostValue:HTTP_REQUEST_PictureAddress forKey:kOpt];
    [httpRequest setPostValue:auth forKey:kAuth];
    [httpRequest setPostValue:infoStr forKey:kInfo];
    [httpRequest setDelegate:self];
    [httpRequest setDidFailSelector:@selector(loadTabbarFailed:)];
    [httpRequest setDidFinishSelector:@selector(loadTabbarFinished:)];
    [httpRequest startAsynchronous];
    
    [httpRequest release];
}

-(void)loadTabbarFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@",request.error);
}

-(void)loadTabbarFinished:(ASIHTTPRequest *)request {
    NSDictionary *dic = [[request responseString]objectFromJSONString];
    //储存图片路径数组
    [urlArray addObjectsFromArray:[dic objectForKey:@"picList"]];
    [openUrlArray addObjectsFromArray:[dic objectForKey:@"picList1"]];
}

#pragma mark -Customized: Private (General)
- (void)autoLoginWithUserName:(NSString *)username password:(NSString *)password {
    if (username && password) {
        // 登录请求
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        [infoDict setObject:username forKey:@"name"];
        [infoDict setObject:[InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",password,kAppKey]]forKey:@"password"];
        [UserInfo shareUserInfo].password = [InterfaceHelper MD5:[NSString stringWithFormat:@"%@%@",password,kAppKey]];
        
        ASIFormDataRequest *httpRequest = [[[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_Login userId:@"-1" infoDict:infoDict]] autorelease];
        [httpRequest setDelegate:self];
        [httpRequest setDidFailSelector:@selector(autoLoginFailed:)];
        [httpRequest setDidFinishSelector:@selector(autoLoginFinished:)];
        [httpRequest startAsynchronous];
        [httpRequest release];
    }
}
//数据请求
- (void)getData {
    _pushViewBegin = YES;
    
    if (![CheckNetWork isNetWorkEnable]) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
        [Globals alertWithMessage:@"找不到可用网络"];
        _pushViewBegin = NO;
        return;
    }
    
    if (_queue) {
        [_queue cancelAllOperations];
        [_queue release];
        _queue = nil;
    }
     
    _queue = [[ASINetworkQueue alloc] init];
    [_queue reset];
    [_queue setDelegate:self];
    [_queue setRequestDidFailSelector:@selector(requestDidFailed:)];
    [_queue setRequestDidFinishSelector:@selector(requestDidFinished:)];
    [_queue setQueueDidFinishSelector:@selector(queueDidFinished:)];
    [_queue setShouldCancelAllRequestsOnFailure:NO];
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[InterfaceHelper getNotJCLotteryStr:_nameArray] forKey:@"lotteryId"]; // 所有彩种

    ASIFormDataRequest *httpRequest= [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_RRQUEDT_GetLotteryInformation userId:@"-1" infoDict:dic]];
    [httpRequest setTag:0];
    [httpRequest setTimeOutSeconds:20];
    [_queue addOperation:httpRequest];
    [httpRequest release];
    [dic release];
    
    [_queue go];
    
    if(_isShowHud) {
        [SVProgressHUD showWithStatus:@"数据加载中"];
    }
    _isShowHud = YES;
}
//停止刷新
- (void)doneLoadingTableViewData {
    _isLoading = NO;
    [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_collectionView];
}

- (void)removeOverlayView:(UIView *)lb {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

- (NSInteger)findDetailIndexWithLotteryId:(NSInteger)lotteryId {
    for (NSInteger index = 0; index < [_lotterIDArray count]; index++) {
        if ([[_lotterIDArray objectAtIndex:index] integerValue] == lotteryId) {
            return index;
        }
    }
    
    return -1;//返回0这样的还有待参详
}

- (NSTimeInterval)getTimeIntervalWithEndDate:(NSDate *)endDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:[Globals getTimeWithIntervalTime:_globals.serverLocalTimeInterval]];
    
    NSTimeInterval interval = [endDate timeIntervalSinceDate:serverDate];
    [dateFormatter release];
    
    return interval;
}

- (BOOL)isOutOfDate:(NSString *)endtimeStr {
    if (endtimeStr == nil) {
        return YES;
    }
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    // 截止时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *tmpEndDate = [dateFormatter dateFromString:endtimeStr];
    NSTimeInterval endInterval = [zone secondsFromGMTForDate:tmpEndDate];
    NSDate *endDate = [tmpEndDate  dateByAddingTimeInterval: endInterval];
    [dateFormatter release];
    // 系统当前时间
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[Globals getTimeWithIntervalTime:_globals.serverLocalTimeInterval]];
    NSTimeInterval currServiceInterval = [zone secondsFromGMTForDate:currentDate];
    NSDate *serviceDate = [currentDate  dateByAddingTimeInterval: currServiceInterval];
    // 当前时间和截止时间相比，如果早于截止时间，则表示可以进行投注
    if ([serviceDate compare:endDate] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

- (void)processDataWithRequest:(ASIHTTPRequest *)httpRequest {
    NSDictionary *responseDic = [[httpRequest responseString] objectFromJSONString];
//    NSLog(@"responseDic == %@",responseDic);
    NSArray *infoArray = nil;
    [_serverTime release];
    _serverTime = nil;
    _serverTime = [[responseDic objectForKey:@"serverTime"] copy];
    _globals.serverLocalTimeInterval = [Globals calculateCurrentTimeIntervalWithTime:_serverTime];
    
    if (httpRequest.tag == 0) {     // 普通彩种
        // 获取全部用户的中奖信息
        infoArray = [responseDic objectForKey:@"isusesInfo"];
       
        for (NSDictionary *dic in infoArray) {
            NSString *key = [dic objectForKey:@"lotteryid"];
            
            if ([key isEqualToString:@"72"] || [key isEqualToString:@"73"] || [key isEqualToString:@"45"]) {
                [_againstDic removeObjectForKey:key];
                NSString *str = [dic objectForKey:@"Against"];
                [_againstDic setObject:str.length > 0 ? str : @"" forKey:key];
            }
            
            [_infoDic removeObjectForKey:key];
            [_globals.homeViewInfoDict removeObjectForKey:key];
            
            [_infoDic setObject:dic forKey:key];
            [_globals.homeViewInfoDict setObject:dic forKey:key];
            
            [_explanationDic removeObjectForKey:key];
            [_explanationDic setObject:[dic objectForKey:@"Description"] forKey:key];
        }
        
        [_todayOpenLotteryArray removeAllObjects];
        NSString *todayOpenLotterysString = [[responseDic stringForKey:@"winToday"] copy];
        NSString *todayOpenLotterysTrimmedString = [todayOpenLotterysString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *todayOpenLotteryArray = [todayOpenLotterysTrimmedString componentsSeparatedByString:@","];
        [_todayOpenLotteryArray addObjectsFromArray:todayOpenLotteryArray];
        [todayOpenLotterysString release];
        
        static BOOL isInDuration = NO;
        if (isInDuration) {
            return;
        }
        isInDuration = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
            isInDuration = NO;
        });
        
    } else if (httpRequest.tag == 1) {  // 竞彩足球
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
            
            NSLog(@"--------tag:72----------%@",[httpRequest responseString]);
            
            [_infoDic removeObjectForKey:@"72"];
            [_infoDic setObject:matchDict forKey:@"72"];
            
            [_globals.homeViewInfoDict removeObjectForKey:@"72"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"72"];
            
            static BOOL isInDuration = NO;
            if (isInDuration) {
                return;
            }
            isInDuration = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                isInDuration = NO;
            });
            
            [self pushViewControllerWithID:_curLotteryid index:_curIndex];
            
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"竞彩足球数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
        
    } else if (httpRequest.tag == 2) {  // 竞彩篮球
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
            
            [_infoDic removeObjectForKey:@"73"];
            [_infoDic setObject:matchDict forKey:@"73"];
            
            [_globals.homeViewInfoDict removeObjectForKey:@"73"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"73"];
            
            static BOOL isInDuration = NO;
            if (isInDuration) {
                return;
            }
            isInDuration = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                isInDuration = NO;
            });
            
            [self pushViewControllerWithID:_curLotteryid index:_curIndex];
            
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"竞彩篮球数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
        
    } else if (httpRequest.tag == 3) {  // 北京单场
        infoArray = [responseDic objectForKey:@"dtMatch"];
        
        if([infoArray count] != 0) {
            NSMutableDictionary *matchDict = [NSMutableDictionary dictionary];
            NSString *addaward = [[responseDic stringForKey:@"addaward"] copy];
            [matchDict setObject:addaward == nil ? @"False" : addaward forKey:@"addaward"];
            [addaward release];
            NSString *isSale = [[responseDic stringForKey:@"isSale"] copy];
            [matchDict setObject:isSale == nil ? @"False" : isSale forKey:@"isSale"];
            [isSale release];
            [matchDict setObject:[infoArray objectAtIndex:0] == nil ? [NSMutableDictionary dictionary] : [infoArray objectAtIndex:0]  forKey:@"dtMatch"];
            [_infoDic removeObjectForKey:@"45"];
            [_infoDic setObject:matchDict forKey:@"45"];
            
            [_globals.homeViewInfoDict removeObjectForKey:@"45"];
            [_globals.homeViewInfoDict setObject:matchDict forKey:@"45"];
            
            static BOOL isInDuration = NO;
            if (isInDuration) {
                return;
            }
            isInDuration = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                isInDuration = NO;
            });
            
            [self pushViewControllerWithID:_curLotteryid index:_curIndex];
            
        } else {
#if LOG_SWITCH_HTTP
            NSLog(@"北京单场数据为空");
#endif
            [XYMPromptView defaultShowInfo:@"没有可投对阵" isCenter:NO];
        }
        
    }
    
    responseDic = nil;
}

- (void)judgeIfLoginAutomatically {
    // 判断登录一次
    NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
    
    if ([users objectForKey:kLoginOnceOnHomeView]) {
        if ([[users objectForKey:kLoginOnceOnHomeView] integerValue] == 23) {
            NSInteger flag = [[users objectForKey:kIsStorePassword] integerValue];
            if (flag == 1) {
                [users removeObjectForKey:kLoginOnceOnHomeView];
                // 获取用户名和密码
                NSMutableDictionary *itemData = (NSMutableDictionary *)[XYMKeyChain loadKeyChainItemWithKey:KEY_KEYCHAINITEM];
                NSString *username = [itemData objectForKey:KEY_USERNAME];
                NSString *password = [itemData objectForKey:KEY_PASSWORD];
                
                if (itemData && username && password) {
                    if (![UserInfo shareUserInfo].userID)
                        [self autoLoginWithUserName:username password:password];
                }
            }
        }
    }
    
    [SVProgressHUD dismiss];
}

- (BOOL)judgeIsCanBetWithIndex:(NSInteger)index andID:(NSInteger)lotteryid {
    AppDelegate *pAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Globals *pGlobals = pAppDelegate.globals;
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat promptWidth = IS_PHONE ? 180.0f : 280.0f;
    
    CGFloat overlayViewHeight = IS_PHONE ? 40.0f : 60.0f;
    
    CGFloat labelHeight = IS_PHONE ? 20.0f : 30.0f;
    /********************** adjustment end ***************************/
    CGRect overlayViewRect = CGRectMake(0, 0, promptWidth, overlayViewHeight);
    CGRect labelRect = CGRectMake(0, 0, promptWidth, labelHeight);
    
    if (lotteryid != 72 && lotteryid != 73 && lotteryid != 45) {
        // 截止时间
        NSString *endtimeStr = [[[pGlobals homeViewInfoDict] objectForKey:[NSString stringWithFormat:@"%ld",(long)lotteryid]] objectForKey:@"endtime"];
        
        if ([self isOutOfDate:endtimeStr]) {
            if (_overlayView == nil) {
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                _overlayView = [[UIView alloc]initWithFrame:overlayViewRect];
                [_overlayView setBackgroundColor:[UIColor blackColor]];
                [_overlayView setAlpha:1];
                [keyWindow addSubview:_overlayView];
                [_overlayView release];
                
                UILabel *lb = [[UILabel alloc]initWithFrame:labelRect];
                lb.backgroundColor = [UIColor clearColor];
                lb.textAlignment = NSTextAlignmentCenter;
                lb.font = [UIFont systemFontOfSize:XFIponeIpadFontSize13];
                lb.text = @"该奖期已结束,请等下一期";
                lb.tag = 1;
                lb.textColor = [UIColor whiteColor];
                [lb setCenter:_overlayView.center];
                [_overlayView addSubview:lb];
                [lb release];
                
                [_overlayView setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
                [self performSelector:@selector(removeOverlayView:) withObject:nil afterDelay:1.0];
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)pushViewControllerWithID:(NSInteger)lotteryid index:(NSInteger)index {
    NSObject *obj = [_infoDic objectForKey:[NSString stringWithFormat:@"%ld",(long)lotteryid]];
    UIViewController *dataVC = [GlobalsProject viewController:lotteryid initWithInfoData:obj];
        if (dataVC != nil) {
        [self.navigationController pushViewController:dataVC animated:YES];
    }
}

#pragma mark - 竞彩彩种网络请求
- (void)getCompetingData: (NSString *)lotteryId {
    _pushViewBegin = YES;
    
    if (![CheckNetWork isNetWorkEnable]) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
        [Globals alertWithMessage:@"找不到可用网络"];
        _pushViewBegin = NO;
        return;
    }
    
    if (_queue) {
        [_queue cancelAllOperations];
        [_queue release];
        _queue = nil;
    }
    
    _queue = [[ASINetworkQueue alloc] init];
    [_queue reset];
    [_queue setDelegate:self];
    [_queue setRequestDidFailSelector:@selector(requestDidFailed:)];
    [_queue setRequestDidFinishSelector:@selector(requestDidFinished:)];
    [_queue setQueueDidFinishSelector:@selector(queueDidFinished:)];
    [_queue setShouldCancelAllRequestsOnFailure:NO];
   
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:lotteryId forKey:@"lotteryId"];
    [dic setObject:@"-1" forKey:@"playType"];
    
    ASIFormDataRequest *httpRequest= [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_RRQUEDT_GetLotteryInformation userId:@"-1" infoDict:dic]];
    
    if ([lotteryId isEqualToString:@"72"]) {
        [httpRequest setTag:1];
        
    }else if ([lotteryId isEqualToString:@"73"]) {
        [httpRequest setTag:2];
        
    } else {
        [httpRequest setTag:3];
    }
    
    [httpRequest setTimeOutSeconds:30];
    [_queue addOperation:httpRequest];
    [httpRequest release];
    [dic release];
    
    [_queue go];
    
    if(_isShowHud) {
        [SVProgressHUD showWithStatus:@"数据加载中"];
    }
    _isShowHud = YES;
}

@end
