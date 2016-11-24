//
//  IntegralExchangeViewController.m  积分兑换 (整体滑动是晓洁要干的)
//  TicketProject
//
//  Created by KAI on 15-4-20.
//  Copyright (c) 2015年 sls002. All rights reserved.
//
//  20150820 10:49（刘科）：优化指示器，更换第三方库。(SVProgressHUD)

#import "IntegralExchangeViewController.h"
#import "CircleBtn.h"
#import "IntegralCenterViewController.h"
#import "IntegralDetailViewController.h"
#import "IntegralExchangeCollectionCell.h"

#import "Globals.h"
#import "UserInfo.h"

#define cellIdentifier @"IntegralExchangeCell"
#define cellHeaderIdentifier @"IntegralExchangeHeaderCell"
#define collectionViewHeadHeight (IS_PHONE ? 180.0f : 400.0f)
#define collectionViewHeight (IS_PHONE ? 135.0f : 200.0f)
#define kCollectionViewLineItem 2

#pragma mark -
#pragma mark @implementation IntegralExchangeViewController
@implementation IntegralExchangeViewController
#pragma mark Lifecircle

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"积分兑换"];
        _itemMoneyArray = [[NSArray alloc] initWithObjects:@"10", @"20", @"50", @"100", nil];
    }
    return self;
}

- (void)dealloc {
    _circleBtn = nil;
    _accumulatePromptLabel = nil;
    _exchangeTextField = nil;
    _collectionView = nil;
    _overlayView = nil;
    
    [_itemMoneyArray release];
    _itemMoneyArray = nil;
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
    
    //comeBackBtn 顶部－返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [comeBackBtn setFrame:comeBackBtnRect];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //changeBtnRect 更改试图
    CGRect changeBtnRect = XFIponeIpadNavigationChangeButtonRect;
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeBtn setFrame:changeBtnRect];
    [[changeBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [changeBtn setTitle:@"积分明细" forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *changeBtnItem = [[UIBarButtonItem alloc]initWithCustomView:changeBtn];
    [self.navigationItem setRightBarButtonItem:changeBtnItem];
    [changeBtnItem release];
    
    //collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGRect collectionViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f);
    _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:flowLayout];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellHeaderIdentifier];
    [_collectionView registerClass:[IntegralExchangeCollectionCell class] forCellWithReuseIdentifier:cellIdentifier];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [self.view addSubview:_collectionView];
    [_collectionView release];
    [flowLayout release];
    
    //给背景添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fillIntegralLabel];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearHTTPRequest];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_itemMoneyArray count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellHeaderIdentifier forIndexPath:indexPath];
    if (header == nil) {
        header = [[[UICollectionReusableView alloc] init] autorelease];
    }
    
    for (UIView *view in header.subviews) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat circleBtnMinY = IS_PHONE ? 5.0f : 10.0f;
    CGSize circleBtnSize = IS_PHONE ? CGSizeMake(80.0f, 80.0f) : CGSizeMake(180.0f, 180.0f);

    CGFloat promptIntegralLabelHeight = IS_PHONE ? 21.0f : 50.0f;
    
    CGFloat accumulatePromptLabelMaginCircleBtnY = 7.0f;
    
    CGFloat exchangePromptLabelMinX = IS_PHONE ? 10.0f : 30.0f;
    CGFloat exchangePromptLabelWidth = IS_PHONE ? 70.0f : 220.0f;
    CGFloat exchangePromptLabelHeight = IS_PHONE ? 25.0f : 40.0f;
    
    CGFloat exchangeTextFieldWidth = IS_PHONE ? 150.0f : 260.0f;
    
    CGFloat exchangeBtnMaignExchangeTextField = IS_PHONE ? 20.0f : 50.0f;
    CGFloat promptExchangeBtnWidth = IS_PHONE ? 65.0f : 100.0f;
    CGFloat exchangePromptLabelMaginTop = IS_PHONE ? 10.0f : 15.0f;
    CGFloat exchangePromptLabelMaginBottom = IS_PHONE ? 18.0f : 25.0f;
    CGFloat exchangeBtnHeight = exchangePromptLabelHeight;
    
    CGFloat lineWidth = IS_PHONE ? 100.0f : 200.0f;
    /********************** adjustment end ***************************/
    //circleBtn
    CGRect circleBtnRect = CGRectMake((CGRectGetWidth(collectionView.frame) - circleBtnSize.width) / 2.0f, circleBtnMinY, circleBtnSize.width, circleBtnSize.height);
    _circleBtn = [[CircleBtn alloc] initWithFrame:circleBtnRect];
    [_circleBtn addTarget:self action:@selector(changeTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:_circleBtn];
    [_circleBtn release];
    
    //accumulatePromptLabel
    CGRect accumulatePromptLabelRect = CGRectMake(0, CGRectGetMaxY(circleBtnRect) + accumulatePromptLabelMaginCircleBtnY, CGRectGetWidth(collectionView.frame), promptIntegralLabelHeight);
    _accumulatePromptLabel = [[UILabel alloc] initWithFrame:accumulatePromptLabelRect];
    [_accumulatePromptLabel setBackgroundColor:[UIColor clearColor]];
    [_accumulatePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize11]];
    [_accumulatePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [_accumulatePromptLabel setTextColor:kGrayColor];
    [_accumulatePromptLabel setMinimumScaleFactor:0.75];
    [_accumulatePromptLabel setAdjustsFontSizeToFitWidth:YES];
    [_accumulatePromptLabel setText:@"累计获得积分：0分     累计兑换积分：0分"];
    [header addSubview:_accumulatePromptLabel];
    [_accumulatePromptLabel release];
    
    //exchangePromptLabel 兑换提示文字
    CGRect exchangePromptLabelRect = CGRectMake(exchangePromptLabelMinX, CGRectGetMaxY(accumulatePromptLabelRect) + exchangePromptLabelMaginTop, exchangePromptLabelWidth, exchangePromptLabelHeight);
    UILabel *exchangePromptLabel = [[UILabel alloc] initWithFrame:exchangePromptLabelRect];
    [exchangePromptLabel setBackgroundColor:[UIColor clearColor]];
    [exchangePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [exchangePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [exchangePromptLabel setText:@"我要兑换"];
    [header addSubview:exchangePromptLabel];
    [exchangePromptLabel release];
    
    //exchangeTextField 兑换输入框
    CGRect exchangeTextFieldRect = CGRectMake(CGRectGetMaxX(exchangePromptLabelRect), CGRectGetMinY(exchangePromptLabelRect), exchangeTextFieldWidth, CGRectGetHeight(exchangePromptLabelRect));
    _exchangeTextField = [[UITextField alloc] initWithFrame:exchangeTextFieldRect];
    [_exchangeTextField setBackgroundColor:[UIColor clearColor]];
    [_exchangeTextField setPlaceholder:@"请输入您要兑换的积分"];
    [_exchangeTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_exchangeTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [[_exchangeTextField layer] setBorderWidth:AllLineWidthOrHeight];
    [[_exchangeTextField layer] setBorderColor:[UIColor blackColor].CGColor];
    _exchangeTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(exchangePromptLabelRect))];
    _exchangeTextField.leftViewMode = UITextFieldViewModeAlways;
    [header addSubview:_exchangeTextField];
    [ _exchangeTextField release];
    
    //exchangeBtn 兑换积分按钮
    CGRect exchangeBtnRect = CGRectMake(CGRectGetMaxX(exchangeTextFieldRect) + exchangeBtnMaignExchangeTextField, CGRectGetMinY(exchangeTextFieldRect), promptExchangeBtnWidth, exchangeBtnHeight);
    UIButton *exchangeBtn = [[UIButton alloc] initWithFrame:exchangeBtnRect];
    [exchangeBtn setBackgroundColor:[UIColor clearColor]];
    [[exchangeBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [exchangeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [exchangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [exchangeBtn setTag:2111];
    [exchangeBtn setTitle:@"兑换" forState:UIControlStateNormal];
    [exchangeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redLineButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [exchangeBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateHighlighted];
    [exchangeBtn addTarget:self action:@selector(exchangeIntegralTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:exchangeBtn];
    [exchangeBtn release];
    
    //lineView1
    CGRect lineView1Rect = CGRectMake(0, CGRectGetMaxY(exchangePromptLabelRect) + exchangePromptLabelMaginBottom, lineWidth, AllLineWidthOrHeight);
    UIView *lineView1 = [[UIView alloc] initWithFrame:lineView1Rect];
    [lineView1 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine3.png"]]]];
    [header addSubview:lineView1];
    [lineView1 release];
    
    //promptLabel
    CGRect promptLabelRect = CGRectMake(CGRectGetMaxX(lineView1Rect), CGRectGetMidY(lineView1Rect) - promptIntegralLabelHeight / 2.0f, CGRectGetWidth(collectionView.frame) - lineWidth * 2, promptIntegralLabelHeight);
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setText:@"快速兑换"];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [header addSubview:promptLabel];
    [promptLabel release];
    
    //lineView2
    CGRect lineView2Rect = CGRectMake(CGRectGetMaxX(promptLabelRect), CGRectGetMinY(lineView1Rect), lineWidth, AllLineWidthOrHeight);
    UIView *lineView2 = [[UIView alloc] initWithFrame:lineView2Rect];
    [lineView2 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"pointLine3.png"]]]];
    [header addSubview:lineView2];
    [lineView2 release];
    
    [self fillIntegralLabel];
    
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IntegralExchangeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[IntegralExchangeCollectionCell alloc] init] autorelease];
    }
    if (!cell.hasMakeSubView) {
        [cell setCellWidth:(kWinSize.width / kCollectionViewLineItem)];
        [cell makeSubView];
    }

    [cell setPhotoImageName:[NSString stringWithFormat:@"caijin%@.png",[_itemMoneyArray objectAtIndex:indexPath.row]]];
    [cell setPrompt:[NSString stringWithFormat:@"所需积分：%ld分",(long)([UserInfo shareUserInfo].scoringExchangerate * [[_itemMoneyArray objectAtIndex:indexPath.row] integerValue])]];
    [cell setBtnTag:indexPath.row];
    [cell addTarget:self action:@selector(exchangeIntegralTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets top = {0, 0, 0, 0};
    return top;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kWinSize.width / kCollectionViewLineItem, collectionViewHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kWinSize.width, collectionViewHeadHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

#pragma mark -ASIHTTPRequestDelegate
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"兑换失败"];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    _exchangeTextField.text = @"";
    
    NSDictionary *responseDic = [[request responseString] objectFromJSONString];
    if(responseDic && [[responseDic objectForKey:@"msg"] integerValue] == 0) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"兑换%ld积分成功",(long)_exchangeIntegral]];
        
        [UserInfo shareUserInfo].balance = [NSString stringWithFormat:@"%.2f",[responseDic floatValueForKey:@"balance"]];
        [UserInfo shareUserInfo].surplusIntegral = [responseDic intValueForKey:@"currentScoring"];
        [UserInfo shareUserInfo].scoringExchangerate = [responseDic intValueForKey:@"scoringExchangerate"];
        [UserInfo shareUserInfo].exchangeIntegral = [responseDic intValueForKey:@"totalConversionScoring"];
        [UserInfo shareUserInfo].totalIntegral = [responseDic intValueForKey:@"totalScoring"];
        [self fillIntegralLabel];
        
    } else if (responseDic) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"兑换%ld积分失败，%@",(long)_exchangeIntegral,[responseDic objectForKey:@"msg"]]];
    }
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    IntegralCenterViewController *integralCenterViewController = (IntegralCenterViewController *)[self.navigationController.viewControllers objectAtIndex:1];
    if (integralCenterViewController && [integralCenterViewController isKindOfClass:[IntegralCenterViewController class]]) {
        [self.navigationController popToViewController:integralCenterViewController animated:YES];
    }
}

- (void)changeTouchUpInside:(id)sender {
    NSArray *viewControllerArray = self.navigationController.viewControllers;
    
    if ([viewControllerArray count] >= 4) {
        IntegralDetailViewController *integralDetailViewController = (IntegralDetailViewController *)[self.navigationController.viewControllers objectAtIndex:2];
        if (integralDetailViewController && [integralDetailViewController isKindOfClass:[IntegralDetailViewController class]]) {
            [self.navigationController popToViewController:integralDetailViewController animated:YES];
        }
    } else {
        IntegralDetailViewController *integralDetailViewController = [[IntegralDetailViewController alloc] init];
        [self.navigationController pushViewController:integralDetailViewController animated:YES];
        [integralDetailViewController release];
    }
}

- (void)exchangeIntegralTouchUpInside:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self hideKeyBoard:nil];
    NSInteger exchangeIntegral = 0;
    if (btn.tag == 2111) {
        exchangeIntegral = [_exchangeTextField.text integerValue];
    } else {
        exchangeIntegral = ([[_itemMoneyArray objectAtIndex:btn.tag] integerValue] * [UserInfo shareUserInfo].scoringExchangerate);
    }
    
    NSInteger oneIntegral = [UserInfo shareUserInfo].scoringExchangerate;
    if (oneIntegral == 0) {
        [self showOverlayViewWithText:@"获取积分失败"];
        
    } else if (exchangeIntegral == 0) {
        [self showOverlayViewWithText:@"积分不能为0"];
        
    } else if (exchangeIntegral % oneIntegral != 0) {
        [self showOverlayViewWithText:[NSString stringWithFormat:@"积分必须为%ld的倍数",(long)oneIntegral]];
        
    } else if (exchangeIntegral > [UserInfo shareUserInfo].surplusIntegral){
        [self showOverlayViewWithText:[NSString stringWithFormat:@"当前积分不足%ld",(long)exchangeIntegral]];
    
    } else {
        [self requestExchangeIntegralWithIntegral:exchangeIntegral];
    }
    
}

- (void)hideKeyBoard:(UITapGestureRecognizer *)gesture {
    [_exchangeTextField resignFirstResponder];
}

- (void)requestExchangeIntegralWithIntegral:(NSInteger)integral {
    [SVProgressHUD showWithStatus:@"正在兑换积分"];
    [self clearHTTPRequest];
    _exchangeIntegral = integral;
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[NSString stringWithFormat:@"%ld",(long)_exchangeIntegral] forKey:@"score"];
    
    _httpRequest = [[ASIFormDataRequest alloc]initWithURL:[NSURL shoveURLWithOpt:HTTP_REQUEST_ExchangeIntegral userId:[UserInfo shareUserInfo].userID infoDict:infoDic]];
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

- (void)showOverlayViewWithText:(NSString *)text  {
    if (_overlayView == nil) {
        /********************** adjustment 控件调整 ***************************/
        CGFloat promptWidth = kWinSize.width;
        
        CGFloat overlayViewHeight = IS_PHONE ? 40.0f : 60.0f;
        
        CGFloat labelHeight = IS_PHONE ? 20.0f : 30.0f;
        /********************** adjustment end ***************************/
        CGRect overlayViewRect = CGRectMake(0, 0, promptWidth, overlayViewHeight);
        CGRect labelRect = CGRectMake(0, 0, promptWidth, labelHeight);
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        _overlayView = [[UIView alloc]initWithFrame:overlayViewRect];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:0.5];
        [keyWindow addSubview:_overlayView];
        [_overlayView release];
        
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:labelRect];
        [promptLabel setBackgroundColor:[UIColor clearColor]];
        [promptLabel setTextAlignment:NSTextAlignmentCenter];
        [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [promptLabel setTextColor:[UIColor whiteColor]];
        [promptLabel setText:text];
        [promptLabel setTag:1];
        [promptLabel setCenter:_overlayView.center];
        [_overlayView addSubview:promptLabel];
        [promptLabel release];
        
        [_overlayView setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
        [self performSelector:@selector(removeOverlayView:) withObject:nil afterDelay:1.0];
    }
}

- (void)removeOverlayView:(UIView *)promptLabel {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

- (void)fillIntegralLabel {
    [_circleBtn setIntegral:[UserInfo shareUserInfo].surplusIntegral];
    [_accumulatePromptLabel setText:[NSString stringWithFormat:@"累计获得积分：%ld分     累计兑换积分：%ld分",(long)[UserInfo shareUserInfo].totalIntegral, (long)[UserInfo shareUserInfo].exchangeIntegral]];
}

@end
