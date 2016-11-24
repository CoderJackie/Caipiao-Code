//
//  AboutUsViewController.m
//  TicketProject
//
//  Created by KAI on 15-4-24.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "AboutUsViewController.h"
#import "ActivImageView.h"

#import "Globals.h"
#import "ImageDownloader.h"
#import "UserInfo.h"

#define kAboutUsDefaultPhotoName @""

#pragma mark -
#pragma mark @implementation AboutUsViewController
@implementation AboutUsViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"关于"];
    }
    return self;
}

- (void)dealloc {
    [_imageDownloaders release];
    _imageDownloaders = nil;
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
    
    //comeBackBtn 返回按钮
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
    CGFloat activImageViewMinX = IS_PHONE ? 30.0f : 80.0f;
    CGFloat activImageViewMinY = 20.0f;
    CGFloat activImageViewHeight = 66.0f;
    CGFloat activImageViewWidth = 244.0f;
    
    CGFloat aboutUsLabelMinX = activImageViewMinX;
    CGFloat aboutUsLabelMaignImageY = 10.0f;
    CGFloat aboutUsLabelHeight = IS_PHONE ? 200.0f : 400.0f;
    
    CGFloat customerServiceLabelMaignBottom = IS_PHONE ? 20.0f : 40.0f;
    CGFloat customerServiceLabelHeight = IS_PHONE ? 21.0f : 30.0f;
    /********************** adjustment end ***************************/
    
    //activImageView
    CGRect activImageViewRect = CGRectMake((CGRectGetWidth(appRect) - activImageViewWidth) / 2, activImageViewMinY, activImageViewWidth, activImageViewHeight);
    _activImageView = [[ActivImageView alloc] initWithFrame:activImageViewRect];
    [_activImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:kAboutUsDefaultPhotoName]]];
    [_activImageView setBackgroundColor:[UIColor clearColor]];
    [_activImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_activImageView];
    [_activImageView release];
    
    CGRect aboutUsLabelRect = CGRectMake(aboutUsLabelMinX, CGRectGetMaxY(activImageViewRect) + aboutUsLabelMaignImageY, CGRectGetWidth(appRect) - aboutUsLabelMinX * 2, aboutUsLabelHeight);
    _aboutUsLabel = [[UILabel alloc] initWithFrame:aboutUsLabelRect];
    [_aboutUsLabel setBackgroundColor:[UIColor clearColor]];
    [_aboutUsLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_aboutUsLabel setText:[NSString stringWithFormat:@"当前版本：%@\n\n版权所有：\n\n官方网站：",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]]];
    [_aboutUsLabel setNumberOfLines:10];
    [self.view addSubview:_aboutUsLabel];
    [_aboutUsLabel release];
    
    //customerServiceLabel
    CGRect customerServiceLabelRect = CGRectMake(0, CGRectGetHeight(appRect) - customerServiceLabelHeight - customerServiceLabelMaignBottom - 44.0f, kWinSize.width, customerServiceLabelHeight);
    _customerServiceLabel = [[UILabel alloc] initWithFrame:customerServiceLabelRect];
    [_customerServiceLabel setBackgroundColor:[UIColor clearColor]];
    [_customerServiceLabel setTextAlignment:NSTextAlignmentCenter];
    [_customerServiceLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_customerServiceLabel setMinimumScaleFactor:0.75];
    [_customerServiceLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0f]];
    [_customerServiceLabel setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:_customerServiceLabel];
    [_customerServiceLabel release];
}

- (void)viewDidLoad {
    _imageDownloaders = [[NSMutableDictionary alloc] init];
    [self customerServiceMessageRequest];
    [super viewDidLoad];
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
        
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearCustomerServiceRequest];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma Delegate
#pragma mark -
#pragma mark -ASIHTTPRequestDelegate
- (void)customerServiceMessageRequestFinish:(ASIHTTPRequest *)request {
    NSDictionary *responseDic = [[request responseString]objectFromJSONString];
    if(responseDic) {
        NSString *siteName = [responseDic stringForKey:@"SiteName"];
        NSString *phone = [responseDic stringForKey:@"Phone"];
        
        NSString *companyName = [responseDic stringForKey:@"CompanyName"];
        NSString *siteURL = [responseDic stringForKey:@"SiteURL"];
        
        [_aboutUsLabel setText:[NSString stringWithFormat:@"当前版本：%@\n\n版权所有：%@\n\n官方网站：%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey],companyName,siteURL]];
        [_customerServiceLabel setText:[NSString stringWithFormat:@"【%@】客服热线：%@",siteName,phone]];
        
        
        NSString *pictureUrl = [responseDic stringForKey:@"SiteImg"];
        [_activImageView startActivityAnimating];
        [_activImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:kAboutUsDefaultPhotoName]]];
        [self startImageDownload:pictureUrl imageKey:@"AboutUsaImage"]; 
    }
}

- (void)customerServiceMessageRequestFail:(ASIHTTPRequest *)request {
    
}

#pragma mark -ImageDownloaderDelegate
- (void)imageDidLoad:(NSObject *)imageKey viewTag:(NSUInteger)viewTag {
    ImageDownloader *imageDownloader = [_imageDownloaders objectForKey:imageKey];
    if (imageDownloader) {
        UIImage *image = [UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:kAboutUsDefaultPhotoName]];
        UIImage *photoImage = ([imageDownloader.downloadImage isKindOfClass:[UIImage class]]? imageDownloader.downloadImage: image);
        
        CGRect originalActivImageViewRect = _activImageView.frame;
        CGFloat activImageViewWidth = photoImage.size.width;
        CGFloat activImageViewHeight = photoImage.size.height;
        
        CGRect activImageViewRect = CGRectMake(CGRectGetMinX(originalActivImageViewRect), CGRectGetMinY(originalActivImageViewRect), activImageViewWidth, activImageViewHeight);
        if (activImageViewWidth > CGRectGetWidth(originalActivImageViewRect)) {
            activImageViewRect = CGRectMake(CGRectGetMinX(originalActivImageViewRect), CGRectGetMinY(originalActivImageViewRect), CGRectGetWidth(originalActivImageViewRect), activImageViewHeight * (activImageViewHeight / CGRectGetWidth(originalActivImageViewRect)));
        }
        [_activImageView setFrame:activImageViewRect];
        
        [_activImageView setImage:photoImage];;
        [_activImageView stopActivityAnimating];
    }
    imageDownloader.delegate = nil;
    [_imageDownloaders removeObjectForKey:imageKey];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Customized: Private (General)
- (void)customerServiceMessageRequest {
    [self clearCustomerServiceRequest];
    
    _customerServiceRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_GetCustomerServiceMessage userId:[UserInfo shareUserInfo].userID infoDict:nil]];
    [_customerServiceRequest setDelegate:self];
    [_customerServiceRequest setDidFinishSelector:@selector(customerServiceMessageRequestFinish:)];
    [_customerServiceRequest setDidFailSelector:@selector(customerServiceMessageRequestFail:)];
    [_customerServiceRequest startAsynchronous];
}

- (void)clearCustomerServiceRequest {
    if (_customerServiceRequest != nil) {
        [_customerServiceRequest clearDelegatesAndCancel];
        [_customerServiceRequest release];
        _customerServiceRequest = nil;
    }
}

- (void)startImageDownload:(NSString *)url imageKey:(NSString *)imageKey {
    NSLog(@"_imageDownloaders == %@",_imageDownloaders);
    ImageDownloader *imageDownloader = [_imageDownloaders objectForKey:imageKey];
    if (imageDownloader == nil) {
        imageDownloader = [[ImageDownloader alloc] init];
        [imageDownloader setImageKey:imageKey];
        [imageDownloader setDelegate:self];
        [imageDownloader setMonitorEnabled:YES];
        [_imageDownloaders setObject:imageDownloader forKey:imageKey];
        [imageDownloader startDownload:url];
        [imageDownloader release];
    }
}

@end
