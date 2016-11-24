//
//  InformationDetailViewController.m 彩票咨询 详细信息
//  TicketProject
//
//  Created by sls002 on 13-6-22.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140808 14:08（洪晓彬）：大部分代码修改整理,修改代码规范，改进生命周期，处理各种内存问题
//20140808 15:16（洪晓彬）：进行ipad适配

#import "InformationDetailViewController.h"
#import "XFTabBarViewController.h"

#import "Activity.h"
#import "InterfaceHeader.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import "UserInfo.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

#define InformationDetailViewTopViewHeight (IS_PHONE ? 63.0f : 100.0f) //顶部高度
#define kBottomViewHeight (IS_PHONE ? 44.0f : 66.0f) //底部高度

@interface InformationDetailViewController ()

@end
#pragma mark -
#pragma mark @implementation InformationDetailViewController
@implementation InformationDetailViewController
#pragma mark Lifecircle

- (id)initWithInfoType:(NSInteger)type ticketInfoActivity:(NSMutableArray *)ticketInformationArray page:(NSInteger)page curPage:(NSInteger)curPage{
    self = [super init];
    if(self) {
        _ticketInformationArray = ticketInformationArray;
        
        _infoType = type;
        _totalPage = page;
        _curPage = curPage;
        
        [self setTitle:@"资讯详情"];
    }
    return self;
}

- (void)dealloc {
    _titleLabel = nil;
    _publishTimeLabel = nil;
    _tapCountLabel = nil;
    _pageLabel = nil;
    
    _contentWebView = nil;
    
    [_informationTitle release];
    _informationTitle = nil;
    [_shareUrl release];
    _shareUrl = nil;
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
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //shareBtn 分享按钮
    CGRect shareBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setFrame:shareBtnRect];
    [shareBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"informationShare.png"]] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"informationShare.png"]] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(shareTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *shareBtnItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    [self.navigationItem setRightBarButtonItem:shareBtnItem];
    [shareBtnItem release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat titleLabelMinY = IS_PHONE ? 14.0f : 28.0f;
    CGFloat titleLabelHeight = IS_PHONE ? 16.0f : 25.0f;
    
    
    CGFloat topLeftLabelMinX = IS_PHONE ? 5.0f : 20.0f;
    CGFloat topLeftLabelHeight = IS_PHONE ? 15.0f : 25.0f;
    
    CGFloat publishTimeLabelAddY = IS_PHONE ? 7.0f : 10.0f;
    CGFloat publishTimeLabelWidth = IS_PHONE ? 182.0f : 400.0f;//顶部 － 发表时间
    CGFloat tobLabelsLandscapeInterval = IS_PHONE ? 12.0f : 20.0f;
    
    CGFloat lineHeight = IS_PHONE ? 0.5f : 1.0f;
    /********************** adjustment end ***************************/
    
    /************************************ 顶部  ************************************/
    //titleView 顶部视图
    CGRect titleViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), InformationDetailViewTopViewHeight);
    UIView *titleView = [[UIView alloc]initWithFrame:titleViewRect];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:titleView];
    [titleView release];
    
    //titleLabel 顶部 － 新闻标题
    CGRect titleLabelRect = CGRectMake(0, titleLabelMinY, CGRectGetWidth(appRect), titleLabelHeight);
    _titleLabel  = [[UILabel alloc]initWithFrame:titleLabelRect];
    _titleLabel.font = [UIFont boldSystemFontOfSize:XFIponeIpadFontSize14];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:_titleLabel];
    [_titleLabel release];
    
    //publishTimeLabel 顶部 － 发表时间
    CGRect publishTimeLabelRect = CGRectMake(topLeftLabelMinX, CGRectGetMaxY(titleLabelRect) + publishTimeLabelAddY, publishTimeLabelWidth, topLeftLabelHeight);
    _publishTimeLabel = [[UILabel alloc]initWithFrame:publishTimeLabelRect];
    [_publishTimeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_publishTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_publishTimeLabel setTextColor:[UIColor colorWithRed:0x99/255.0f green:0x99/255.0f blue:0x99/255.0f alpha:1.0f]];
    [_publishTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:_publishTimeLabel];
    [_publishTimeLabel release];
    
    //tapCountLabel 顶部 － 点击次数
    CGRect tapCountLabelRect = CGRectMake(CGRectGetMaxX(publishTimeLabelRect) + tobLabelsLandscapeInterval, CGRectGetMinY(publishTimeLabelRect), CGRectGetWidth(titleViewRect) - CGRectGetMaxX(publishTimeLabelRect) - tobLabelsLandscapeInterval, CGRectGetHeight(publishTimeLabelRect));
    _tapCountLabel = [[UILabel alloc]initWithFrame:tapCountLabelRect];
    [_tapCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_tapCountLabel setBackgroundColor:[UIColor clearColor]];
    [_tapCountLabel setTextColor:[UIColor colorWithRed:0x99/255.0f green:0x99/255.0f blue:0x99/255.0f alpha:1.0f]];
    [titleView addSubview:_tapCountLabel];
    [_tapCountLabel release];
    
    //redLineView 顶部 － 分割线
    CGRect redLineViewRect = CGRectMake(0, InformationDetailViewTopViewHeight - lineHeight, CGRectGetWidth(titleViewRect), lineHeight);
    UIView *redLineView = [[UIView alloc] initWithFrame:redLineViewRect];
    [redLineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine2.png"]]]];
    [titleView addSubview:redLineView];
    [redLineView release];
    
    /************************************ 中部  ************************************/
    //contentView 中部视图
    CGRect contentViewRect = CGRectMake(0, CGRectGetMaxY(titleViewRect), CGRectGetWidth(appRect), CGRectGetHeight(appRect) - CGRectGetMaxY(titleViewRect) - 94.0f);
    UIScrollView *contentView = [[UIScrollView alloc]initWithFrame:contentViewRect];
    contentView.backgroundColor = [UIColor yellowColor];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:contentView];
    [contentView release];
    
    //contentWebView 中部 －
    CGRect contentWebViewRect = CGRectMake(0, 0, CGRectGetWidth(contentViewRect), CGRectGetHeight(contentViewRect));
    _contentWebView  =[[UIWebView alloc]initWithFrame:contentWebViewRect];
    [_contentWebView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:_contentWebView];
    [_contentWebView release];
    
    CGRect downViewRect = CGRectMake(0, CGRectGetHeight(appRect) - 94, CGRectGetWidth(appRect), 94);
    UIView *downView = [[UIView alloc] initWithFrame:downViewRect];
    downView.backgroundColor = kBackgroundColor;
    [self.view addSubview:downView];
    
    // 页码标识
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(appRect) - 100) / 2, 10, 100, 34)];
    _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_curPage, (long)_totalPage];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    [downView addSubview:_pageLabel];
    [_pageLabel release];
    
    // 上一页按钮
    _upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _upButton.frame = CGRectMake(20, 15, 60, 24);
    [_upButton setTitle:@"上一页" forState:UIControlStateNormal];
    [_upButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_upButton setTitleColor:[UIColor colorWithRed:0xfd/255.0 green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    _upButton.titleLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize12];
    [_upButton addTarget:self action:@selector(pageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _upButton.tag = 1;
    _upButton.layer.borderWidth = 1;
    _upButton.layer.borderColor = [UIColor redColor].CGColor;
    [downView addSubview:_upButton];

    // 下一页按钮
    _downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _downButton.frame = CGRectMake(CGRectGetWidth(appRect) - 80, 15, 60, 24);
    [_downButton setTitle:@"下一页" forState:UIControlStateNormal];
    [_downButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_downButton setTitleColor:[UIColor colorWithRed:0xfd/255.0 green:0xae/255.0f blue:0x24/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    _downButton.titleLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize12];
    [_downButton addTarget:self action:@selector(pageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _downButton.tag = 2;
    _downButton.layer.borderWidth = 1;
    _downButton.layer.borderColor = [UIColor redColor].CGColor;
    [downView addSubview:_downButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.xfTabBarController setTabBarHidden:YES];
    [self setHidesBottomBarWhenPushed:YES];  //隐藏TabBar
    
    [self loadData];
    [self loadUrl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) {
        _titleLabel = nil;
        _publishTimeLabel = nil;
        _tapCountLabel = nil;
        
        _contentWebView = nil;
        
        self.view = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [self clearInformationRequest];
    [UMSocialWechatHandler setWXAppId:WXAPPKEY appSecret:WXAPPKEYSECRET url:kWebSite];
    //分享设置  设置qq互联和qq应用appkey
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:TENCENTAPPKEY url:kWebSite];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -UMSocialUIDelegate
- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData {
    if([platformName isEqualToString:@"email"]) {
        
    }
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    
}

#pragma mark -
#pragma mark -Customized(Action)
-(void)getBackTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 分享
- (void)shareTouchUpInside:(id)sender {
    if (_shareUrl.length == 0 || _informationId < 0 || _informationTitle.length == 0) {
        [Globals alertWithMessage:@"内容正在加载中"];
        return;
    }
    NSString *shareContent = [NSString stringWithFormat:@"%@: %@",_informationTitle,_shareUrl];
    [UMSocialWechatHandler setWXAppId:WXAPPKEY appSecret:WXAPPKEYSECRET url:_shareUrl];
    //分享设置  设置qq互联和qq应用appkey
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:TENCENTAPPKEY url:_shareUrl];
    
    [UMSocialSnsService presentSnsIconSheetView:[UIApplication sharedApplication].keyWindow.rootViewController
                                         appKey:UMAPPKEY
                                      shareText:shareContent
                                     shareImage:[UIImage imageNamed:@"fenxiang.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToSina,UMShareToRenren,UMShareToDouban,UMShareToSms,UMShareToEmail,nil]
                                       delegate:self];
}

#pragma mark - 获取咨询公告列表或详细信息
-(void)loadData {
    [SVProgressHUD showWithStatus:@"正在加载"];
    [self clearHTTPRequest];
    TicketInformationActivity *activity = (TicketInformationActivity *)[_ticketInformationArray objectAtIndex:_curPage - 1];
    _informationId = activity.informationId;
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%d",2] forKey:@"requestType"];
    [infoDic setObject:[NSNumber numberWithInteger:_infoType] forKey:@"infoType"];
    [infoDic setObject:[NSNumber numberWithInteger:_informationId] forKey:@"informationId"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetAnnouncementDetail userId:@"-1" infoDict:infoDic]];
    [_httpRequest setDelegate:self];
    [_httpRequest startAsynchronous];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -ASIHTTPRequestDelegate
-(void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"数据获取失败"];
}

-(void)requestFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDict = [[request responseString] objectFromJSONString];
    [SVProgressHUD dismiss];

    if(responseDict && [[responseDict objectForKey:@"msg"] isEqualToString:@""]) {
        
        [_informationTitle release];
        _informationTitle = nil;
        _informationTitle = [[responseDict stringForKey:@"title"] copy];
        
        [_titleLabel setText:_informationTitle];
        NSString *strFromto = [responseDict stringForKey:@"fromto"];
        NSArray *strArray = [strFromto componentsSeparatedByString:@"-"];

        [_publishTimeLabel setText:[NSString stringWithFormat:@"发表：%@",[responseDict stringForKey:@"dateTime"]]];
        [_tapCountLabel setText:[NSString stringWithFormat:@"来源：%@",[strArray objectAtIndex:0]]];
        
        NSString *str = [responseDict objectForKey:@"content"];
        NSURL *url = [NSURL URLWithString:[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [_contentWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
        _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_curPage, (long)_totalPage];
    } else if (responseDict) {
        [XYMPromptView defaultShowInfo:[responseDict objectForKey:@"msg"] isCenter:NO];
    }
}

- (void)clearHTTPRequest {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release];
        _httpRequest = nil;
    }
}

#pragma mark - 获取资讯分享地址
-(void)loadUrl {
    [self clearInformationRequest];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSNumber numberWithInteger:_informationId] forKey:@"urlId"];
    [infoDic setObject:[NSNumber numberWithInteger:_infoType] forKey:@"infoType"];
    
    _informationRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetInformationUrl userId:@"-1" infoDict:infoDic]];
    [_informationRequest setDidFinishSelector:@selector(informationFinished:)];
    [_informationRequest setDidFailSelector:@selector(informationFailed:)];
    [_informationRequest setDelegate:self];
    [_informationRequest startAsynchronous];
}

-(void)informationFailed:(ASIHTTPRequest *)request {
    
}

-(void)informationFinished:(ASIHTTPRequest *)request {
    NSDictionary *responseDict = [[request responseString] objectFromJSONString];
    
    if(responseDict && [[responseDict objectForKey:@"msg"] isEqualToString:@""]) {
        [_shareUrl release];
        _shareUrl = nil;
        _shareUrl = [[responseDict objectForKey:@"url"] copy];
    } else if (responseDict) {
        [XYMPromptView defaultShowInfo:[responseDict objectForKey:@"msg"] isCenter:NO];
    }
}

- (void)clearInformationRequest {
    if (_informationRequest != nil) {
        [_informationRequest clearDelegatesAndCancel];
        [_informationRequest release];
        _informationRequest = nil;
    }
}

#pragma mark - 分页按钮点击事件
- (void)pageButtonClick:(UIButton *)btn {
    
    switch (btn.tag) {
        case 1:
        {
            _curPage --;
            _downButton.hidden = NO;
            
            if (_curPage <= 1) {
                _curPage = 1;
                
                // 为第一条时，隐藏上一页按钮
                _upButton.hidden = YES;
            }
        }
            break;
        case 2:
        {
            _curPage ++;
            _upButton.hidden = NO;
            
            if (_curPage >= _totalPage) {
                _curPage = _totalPage;
                
                // 为最后时，隐藏下一页按钮
                _downButton.hidden = YES;
            }
        }
            break;
            
        default:
            break;
    }
    
    [self loadData];
}

@end
