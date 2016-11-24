//
//  LuckyPickViewController.m 购彩大厅－幸运选号
//  TicketProject
//
//  Created by sls002 on 13-7-11.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140903 16:22（洪晓彬）：大部分代码修改整理,修改代码规范，改进生命周期，处理各种内存问题
//20140903 16:41（洪晓彬）：进行ipad适配

#import "LuckyPickViewController.h"
#import "DialogPickerView.h"
#import "HomeViewController.h"
#import "XFNavigationViewController.h"
#import "XFTabBarViewController.h"

#import "SSQBetViewController.h"
#import "DLTBetViewController.h"
#import "SDBetViewController.h"
#import "SFCBetViewController.h"
#import "RJXBetViewController.h"

#import "RandomLuckyNumber.h"
#import "Service.h"
#import "InterfaceHelper.h"

#import "Globals.h"

#define NUMBERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define kLuckyNumberCellheight (IS_PHONE ? 25.0f : 30.0f)

@interface LuckyPickViewController ()

@end
#pragma mark -
#pragma mark @implementation LuckyPickViewController
@implementation LuckyPickViewController
#pragma mark Lifecircle

- (id)initWithLotteryDictionary:(NSDictionary *)dic {
    self = [super init];
    if(self) {
        self.oneS=[Service getDefaultService];
        _infoDic = [dic retain];
        [self.xfTabBarController setTabBarHidden:YES];
        [self setTitle:@"幸运选号"];
        
        _lotteryArray = [[NSArray alloc] initWithObjects:@"双色球", @"3D", @"大乐透", nil];
        
        _luckyTypeArray = [[NSArray alloc] initWithObjects:@"幸运星座", @"幸运属相", @"出生日期", @"姓名", @"情侣", nil];
        _selectLotteryIndexDict = [[NSMutableDictionary alloc] init];
        _selectLuckyTypeIndexDict = [[NSMutableDictionary alloc] init];
        _selectDateIndexDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_lotteryArray release];
    _lotteryArray = nil;
    [_luckyTypeArray release];
    _luckyTypeArray = nil;
    [_selectLotteryIndexDict release];
    _selectLotteryIndexDict = nil;
    [_selectLuckyTypeIndexDict release];
    _selectLuckyTypeIndexDict = nil;
    [_selectDateIndexDict release];
    _selectDateIndexDict = nil;
    
    
    [_luckyNumberArray release];
    _luckyNumberArray = nil;
    
    
    [_infoDic release];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    
    UIScrollView *scrolleView = [[UIScrollView alloc] initWithFrame:appRect];
    [self.view addSubview:scrolleView];
    [scrolleView release];
    
    //comeBackBtn 返回按钮
    CGRect comeBackBtnRect = XFIponeIpadNavigationComeBackButtonRect;
    _comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_comeBackBtn setFrame:comeBackBtnRect];
    [_comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateNormal];
    [_comeBackBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"comeback.png"]] forState:UIControlStateHighlighted];
    [_comeBackBtn addTarget:self action:@selector(getBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:_comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    /********************** adjustment 控件调整 ***************************/
    
    CGFloat luckyBackgroundImageViewWidth = IS_PHONE ? 320.0f : 480.0f;
    CGFloat luckyBackgroundImageViewHeight = IS_PHONE ? (IS_IOS7 ? 523.0f : 440) : 784.5;
    
    CGFloat dropBtnMinX = IS_PHONE ? 135.0f : 202.5;
    CGFloat dropBtnMinY = IS_PHONE ? (IS_IOS7 ? 45.0f : 36.0f): 67.5;
    CGFloat dropBtnWidth = IS_PHONE ? 60.0f : 90.0f;
    CGFloat dropBtnHeight = IS_PHONE ? 34.0f : 51.0f;
    CGFloat dropBtnsMaginX = IS_PHONE ? 8.0f : 12.0f;
    
    CGFloat luckyBtnBackViewMinX = IS_PHONE ? 54.0f : 81.0f;//生肖星座等背景图
    CGFloat luckyBtnBackViewMinY = IS_PHONE ? 80.0f : 120.0f;
    CGFloat luckyBtnBackViewWidth = IS_PHONE ? 213.0f : 319.5f;
    CGFloat luckyBtnBackViewHeight = IS_PHONE ? (IS_IOS7 ? 158.0f : 120.0f): 237.0f;
    
    _luckyLineImageViewStartMinX = IS_PHONE ? -26.0f : -39.0f;
    _luckyLineImageViewStartMinY = IS_PHONE ? (IS_IOS7 ? 235.0f : 195.0f): 352.5f;
    _luckyLineImageViewEndMinX = IS_PHONE ? 204.0f : 306.0f;
    _luckyLineImageViewEndMinY = _luckyLineImageViewStartMinY;
    CGFloat luckyLineImageViewWidth = IS_PHONE ? 150.5f : 225.75f;
    CGFloat luckyLineImageViewHeight = IS_PHONE ? 46.0f : 69.0f;
    
    CGFloat selectLuckyNumberBtnMinX = IS_PHONE ? 100.0f : 150.0f;
    CGFloat selectLuckyNumberBtnMinY = IS_PHONE ? (IS_IOS7 ? 250.0f : 200.0f) : 375.0f;
    CGFloat selectLuckyNumberBtnWidth = IS_PHONE ? 120.0f : 180.0f;
    CGFloat selectLuckyNumberBtnHeight = IS_PHONE ? 50.0f : 75.0f;
    
    CGFloat luckyTableViewMinX = IS_PHONE ? 74.5f : 111.75;
    CGFloat luckyTableViewMinY = IS_PHONE ? (IS_IOS7 ? 326.5f : 274.5f) : 489.75f;
    CGFloat luckyTableViewWidth = IS_PHONE ? 174.0f : 261.0f;
    CGFloat luckyTableViewHeight = IS_PHONE ? (IS_IOS7 ? 121.5f : 101.5f) : 182.25f;
    
    CGFloat betBtnMinX = IS_PHONE ? 120.0f : 180.0f;
    CGFloat betBtnMinY = IS_PHONE ? (IS_IOS7 ? 454.0f : 380.0f) : 681.0f;
    CGFloat betBtnWidth = IS_PHONE ? 82.5f : 123.75f;
    CGFloat betBtnHeight = IS_PHONE ? 23.5f : 35.25f;
    /********************** adjustment end ***************************/
    //backImageView
    CGRect backImageViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), appRect.size.height < 520 ? 520 : appRect.size.height);
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
    [backImageView setBackgroundColor:[UIColor clearColor]];
    [backImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"luckybg.gif"]]];
    [scrolleView addSubview:backImageView];
    [backImageView release];
    
    //luckyBackgroundImageView
    CGRect luckyBackgroundImageViewRect  = CGRectMake((kWinSize.width - luckyBackgroundImageViewWidth) / 2.0f, 0, luckyBackgroundImageViewWidth, luckyBackgroundImageViewHeight);
    UIImageView *luckyBackgroundImageView = [[UIImageView alloc] initWithFrame:luckyBackgroundImageViewRect];
    [luckyBackgroundImageView setBackgroundColor:[UIColor clearColor]];
    [luckyBackgroundImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"luckyBackground.png"]]];
    [luckyBackgroundImageView setUserInteractionEnabled:YES];
    [scrolleView addSubview:luckyBackgroundImageView];
    [luckyBackgroundImageView release];
    
    //lotteryDropBtn
    CGRect lotteryDropBtnRect = CGRectMake(dropBtnMinX, dropBtnMinY, dropBtnWidth, dropBtnHeight);
    _lotteryDropBtn = [[UIButton alloc] initWithFrame:lotteryDropBtnRect];
    [_lotteryDropBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize10]];
    [_lotteryDropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_lotteryDropBtn setTitle:[_lotteryArray objectAtIndex:0] forState:UIControlStateNormal];
    [_lotteryDropBtn setAdjustsImageWhenHighlighted:NO];
    [_lotteryDropBtn addTarget:self action:@selector(lotteryDropTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [luckyBackgroundImageView addSubview:_lotteryDropBtn];
    [_lotteryDropBtn release];
    
    //luckyTypeDropBtn
    CGRect luckyTypeDropBtnRect = CGRectMake(CGRectGetMaxX(lotteryDropBtnRect) + dropBtnsMaginX, dropBtnMinY, dropBtnWidth, dropBtnHeight);
    _luckyTypeDropBtn = [[UIButton alloc] initWithFrame:luckyTypeDropBtnRect];
    [_luckyTypeDropBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize10]];
    [_luckyTypeDropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_luckyTypeDropBtn setTitle:[_luckyTypeArray objectAtIndex:0] forState:UIControlStateNormal];
    [_luckyTypeDropBtn setAdjustsImageWhenHighlighted:NO];
    [_luckyTypeDropBtn addTarget:self action:@selector(luckyTypeDropTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [luckyBackgroundImageView addSubview:_luckyTypeDropBtn];
    [_luckyTypeDropBtn release];
    
    //luckyBtnBackView
    CGRect luckyBtnBackViewRect = CGRectMake(luckyBtnBackViewMinX, luckyBtnBackViewMinY, luckyBtnBackViewWidth, luckyBtnBackViewHeight);
    _luckyBtnBackView = [[UIView alloc] initWithFrame:luckyBtnBackViewRect];
    [_luckyBtnBackView setBackgroundColor:[UIColor clearColor]];
    [_luckyBtnBackView setUserInteractionEnabled:YES];
    [luckyBackgroundImageView addSubview:_luckyBtnBackView];
    [_luckyBtnBackView release];
    
    //luckyLineImageView
    CGRect luckyLineImageViewRect = CGRectMake(_luckyLineImageViewStartMinX, _luckyLineImageViewStartMinY, luckyLineImageViewWidth, luckyLineImageViewHeight);
    _luckyLineImageView = [[UIImageView alloc] initWithFrame:luckyLineImageViewRect];
    [_luckyLineImageView setBackgroundColor:[UIColor clearColor]];
    [_luckyLineImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"luckyLine.png"]]];
    [luckyBackgroundImageView addSubview:_luckyLineImageView];
    [_luckyLineImageView release];
    
    //selectLuckyNumberBtn
    CGRect selectLuckyNumberBtnRect = CGRectMake(selectLuckyNumberBtnMinX, selectLuckyNumberBtnMinY, selectLuckyNumberBtnWidth, selectLuckyNumberBtnHeight);
    _selectLuckyNumberBtn = [[UIButton alloc] initWithFrame:selectLuckyNumberBtnRect];
    [_selectLuckyNumberBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
    [_selectLuckyNumberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectLuckyNumberBtn setTitle:@"立即选号" forState:UIControlStateNormal];
    [_selectLuckyNumberBtn setAdjustsImageWhenHighlighted:NO];
    [_selectLuckyNumberBtn addTarget:self action:@selector(selectLuckyNumberTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [luckyBackgroundImageView addSubview:_selectLuckyNumberBtn];
    [_selectLuckyNumberBtn release];
    
    //luckyTableView
    CGRect luckyTableViewRect = CGRectMake(luckyTableViewMinX, luckyTableViewMinY, luckyTableViewWidth, luckyTableViewHeight);
    _luckyTableView = [[UITableView alloc]initWithFrame:luckyTableViewRect];
    [_luckyTableView setBackgroundColor:[UIColor clearColor]];
    [_luckyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_luckyTableView setDataSource:self];
    [_luckyTableView setDelegate:self];
    [luckyBackgroundImageView addSubview:_luckyTableView];
    [_luckyTableView release];
    
    //betBtn
    CGRect betBtnRect = CGRectMake(betBtnMinX, betBtnMinY, betBtnWidth, betBtnHeight);
    _betBtn = [[UIButton alloc] initWithFrame:betBtnRect];
    [_betBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
    [_betBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_betBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"luckyBetBtn.png"]] forState:UIControlStateNormal];
    [_betBtn setAdjustsImageWhenHighlighted:NO];
    [_betBtn addTarget:self action:@selector(betTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [luckyBackgroundImageView addSubview:_betBtn];
    [_betBtn release];
    
    [self makeLuckyTypeViewWithType:0];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    scrolleView.contentSize = CGSizeMake(kWinSize.width, 540);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCurrLotteryDic:[_lotteryArray objectAtIndex:0]];
    
    _luckyNumberArray = [[NSMutableArray alloc] init];
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
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kLuckyNumberCellheight;
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_luckyNumberArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LuckyNumberCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        if (view && [view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    CGFloat lineMaginLeftRight = IS_PHONE ? 10.0f : 15.0f;
    
    CGRect lineRect = CGRectMake(lineMaginLeftRight, kLuckyNumberCellheight - AllLineWidthOrHeight * 2, CGRectGetWidth(tableView.frame) - lineMaginLeftRight * 2, AllLineWidthOrHeight * 2);
    [Globals makeLineWithFrame:lineRect inSuperView:cell.contentView];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *str = [_luckyNumberArray objectAtIndex:indexPath.row];
    NSArray *array = [str componentsSeparatedByString:@"-"];
    
    NSString *text = @"";
    if(array.count > 1) {
        NSString *redNumber = [array objectAtIndex:0];
        NSString *blueNumber = [array objectAtIndex:1];
        
        text = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font><font color=\"%@\">%@</font>",tRedColorText,redNumber,tBlueColorText,blueNumber];
    } else {
        text = [NSString stringWithFormat:@"<font color=\"%@\">%@ </font>",tRedColorText,str];
        
    }
    
    
    if(text.length > 0) {
        MarkupParser *p = [[MarkupParser alloc]init];
        NSAttributedString *attString = [p attrStringFromMarkup:text];
        CGRect attStringRect;
        if (IS_IOS7) {
            attStringRect = [attString boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame), kLuckyNumberCellheight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        } else {
            CGSize textSize = [str sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13] constrainedToSize:CGSizeMake(CGRectGetWidth(tableView.frame), NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
            attStringRect = CGRectMake(0, 0, textSize.width, textSize.height);
        }
        
        CGRect numbersLabelRect = CGRectMake((CGRectGetWidth(tableView.frame) - attStringRect.size.width) / 2.0f, (kLuckyNumberCellheight - attStringRect.size.height - (IS_PHONE ? 2.0f : 4.0f)) / 2.0f, attStringRect.size.width, attStringRect.size.height + (IS_PHONE ? 2.0f : 4.0f));
        CustomLabel *selectedNumberLabel = [[CustomLabel alloc]initWithFrame:numbersLabelRect];
        [selectedNumberLabel setBackgroundColor:[UIColor clearColor]];
        [selectedNumberLabel setAttString:attString];
        [selectedNumberLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
        [cell.contentView addSubview:selectedNumberLabel];
        [selectedNumberLabel release];
        
        [p release];
        
    }
    return cell;
}

#pragma mark -DialogPickerViewDelegate
- (void)pickerView:(DialogPickerView *)pickerView didSelectedDataDictionary:(NSDictionary *)selectData {
    if (pickerView.tag == 10) {
        NSNumber *selectedRowIndex = [_selectLotteryIndexDict objectForKey:@"0"];
        NSInteger index = [selectedRowIndex integerValue];
        [_lotteryDropBtn setTitle:[_lotteryArray objectAtIndex:index] forState:UIControlStateNormal];
        [self setCurrLotteryDic:[_lotteryArray objectAtIndex:index]];
        [_luckyNumberArray removeAllObjects];
        [_luckyTableView reloadData];
        
    } else if (pickerView.tag == 11) {
        NSNumber *selectedRowIndex = [_selectLuckyTypeIndexDict objectForKey:@"0"];
        NSInteger index = [selectedRowIndex integerValue];
        [self makeLuckyTypeViewWithType:index];
        [_luckyTypeDropBtn setTitle:[_luckyTypeArray objectAtIndex:index] forState:UIControlStateNormal];
        [_luckyNumberArray removeAllObjects];
        [_luckyTableView reloadData];
        
    } else if (pickerView.tag == 12) {
        NSNumber *year = [selectData objectForKey:@"0"];
        NSNumber *month = [selectData objectForKey:@"1"];
        NSNumber *day = [selectData objectForKey:@"2"];
        
        [_yearBtn setTitle:[NSString stringWithFormat:@"%@",year] forState:UIControlStateNormal];
        [_monthBtn setTitle:[NSString stringWithFormat:@"%@",month] forState:UIControlStateNormal];
        [_dayBtn setTitle:[NSString stringWithFormat:@"%@",day] forState:UIControlStateNormal];
        
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)lotteryDropTouchUpInside:(id)sender {
    [self hideKeyboard:nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_lotteryArray forKey:@"0"];
    
    //pickerView 滚动选择视图
    CGRect pickerViewRect = IS_PHONE ? CGRectMake(0, 0, 250, 200) : CGRectMake(0, 0, 375, 300);
    DialogPickerView *pickerView = [[DialogPickerView alloc] initWithFrame:pickerViewRect title:@"" selectIndexDict:_selectLotteryIndexDict dataDict:dict dateType:NO];
    [pickerView setTag:10];
    [pickerView setDelegate:self];
    [pickerView show];
    [pickerView release];
}

- (void)makeLuckyTypeViewWithType:(NSInteger)type {
    for (UIView *view in _luckyBtnBackView.subviews) {
        if (view && [view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    /********************** adjustment 控件调整 ***************************/
    CGRect  luckyBtnBackViewRect = _luckyBtnBackView.frame;
    CGFloat luckyBtnBackViewWidth = CGRectGetWidth(luckyBtnBackViewRect);
    CGFloat luckyBtnBackViewHeight = CGRectGetHeight(luckyBtnBackViewRect);
    
    CGFloat shengxiaoOrXingzuoCol = 4;
    CGFloat shengxiaoOrXingzuoRow = 3;
    CGFloat shengxiaoOrXingzuoBtnSize = IS_PHONE ? (IS_IOS7 ? 40.0f : 34.0f) : 60.0f;
    CGFloat shengxiaoOrXingzuoBtnMinX = (luckyBtnBackViewWidth - shengxiaoOrXingzuoBtnSize * shengxiaoOrXingzuoCol) / (shengxiaoOrXingzuoCol + 1);
    CGFloat shengxiaoOrXingzuoBtnMinY = (luckyBtnBackViewHeight - shengxiaoOrXingzuoBtnSize * shengxiaoOrXingzuoRow) / (shengxiaoOrXingzuoRow + 1);
    CGFloat shengxiaoOrXingzuoBtnLandScapeInterval = shengxiaoOrXingzuoBtnMinX;
    CGFloat shengxiaoOrXingzuoBtnVerticalInterval = shengxiaoOrXingzuoBtnMinY;
    
    CGFloat promptLabelMinX = IS_PHONE ? 2.0f : 3.0f;
    CGFloat promptLabelHeight = IS_PHONE ? 38.0f : 57.0f;
    
    CGFloat birthdayBtnWidth = IS_PHONE ? 45.0f : 67.5f;
    CGFloat birthdayBtnHeight = IS_PHONE ? 20.0f : 30.0f;
    CGFloat birthdayLabelWidth = IS_PHONE ? 20.0f : 30.0f;
    
    CGFloat sanjiaoImageViewWidth = IS_PHONE ? 4.5f : 6.75f;
    CGFloat sanjiaoImageViewHeight = IS_PHONE ? 2.5f : 3.75f;
    CGFloat sanjiaoImageViewMaginRight = IS_PHONE ? 6.0f : 9.0f;
    /********************** adjustment end ***************************/
    switch (type) {
        case 0: //星座
        {
            for (NSInteger row = 0; row < shengxiaoOrXingzuoRow; row++) {
                for (NSInteger col = 0; col < shengxiaoOrXingzuoCol; col ++) {
                    NSInteger tag = row * shengxiaoOrXingzuoCol + col + 1;
                    CGRect shengxiaoBtnRect = CGRectMake(shengxiaoOrXingzuoBtnMinX + (shengxiaoOrXingzuoBtnLandScapeInterval + shengxiaoOrXingzuoBtnSize) * col, shengxiaoOrXingzuoBtnMinY + (shengxiaoOrXingzuoBtnVerticalInterval + shengxiaoOrXingzuoBtnSize) * row, shengxiaoOrXingzuoBtnSize, shengxiaoOrXingzuoBtnSize);
                    UIButton *shengxiaoBtn = [[UIButton alloc] initWithFrame:shengxiaoBtnRect];
                    [shengxiaoBtn setBackgroundColor:[UIColor clearColor]];
                    [shengxiaoBtn setAdjustsImageWhenHighlighted:NO];
                    [shengxiaoBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[NSString stringWithFormat:@"xingzuo_%ld_normal.png",(long)tag]]] forState:UIControlStateNormal];
                    [shengxiaoBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[NSString stringWithFormat:@"xingzuo_%ld_select.png",(long)tag]]] forState:UIControlStateSelected];
                    [shengxiaoBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[NSString stringWithFormat:@"xingzuo_%ld_select.png",(long)tag]]] forState:UIControlStateHighlighted | UIControlStateSelected];
                    [shengxiaoBtn setSelected:tag == 1];
                    [shengxiaoBtn addTarget:self action:@selector(shengxiaoBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                    [_luckyBtnBackView addSubview:shengxiaoBtn];
                    [shengxiaoBtn release];
                }
            }
        }
            break;
        case 1://生肖
        {
            for (NSInteger row = 0; row < shengxiaoOrXingzuoRow; row++) {
                for (NSInteger col = 0; col < shengxiaoOrXingzuoCol; col ++) {
                    NSInteger tag = row * shengxiaoOrXingzuoCol + col + 1;
                    CGRect shengxiaoBtnRect = CGRectMake(shengxiaoOrXingzuoBtnMinX + (shengxiaoOrXingzuoBtnLandScapeInterval + shengxiaoOrXingzuoBtnSize) * col, shengxiaoOrXingzuoBtnMinY + (shengxiaoOrXingzuoBtnVerticalInterval + shengxiaoOrXingzuoBtnSize) * row, shengxiaoOrXingzuoBtnSize, shengxiaoOrXingzuoBtnSize);
                    UIButton *shengxiaoBtn = [[UIButton alloc] initWithFrame:shengxiaoBtnRect];
                    [shengxiaoBtn setBackgroundColor:[UIColor clearColor]];
                    [shengxiaoBtn setAdjustsImageWhenHighlighted:NO];
                    [shengxiaoBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[NSString stringWithFormat:@"shengxiao_%ld_normal.png",(long)tag]]] forState:UIControlStateNormal];
                    [shengxiaoBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[NSString stringWithFormat:@"shengxiao_%ld_select.png",(long)tag]]] forState:UIControlStateSelected];
                    [shengxiaoBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:[NSString stringWithFormat:@"shengxiao_%ld_select.png",(long)tag]]] forState:UIControlStateHighlighted | UIControlStateSelected];
                    [shengxiaoBtn setSelected:tag == 1];
                    [shengxiaoBtn addTarget:self action:@selector(shengxiaoBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                    [_luckyBtnBackView addSubview:shengxiaoBtn];
                    [shengxiaoBtn release];
                }
            }
        }
            break;
        case 2://生日
        {
            //promptLabel
            CGRect promptLabelRect = CGRectMake(promptLabelMinX, promptLabelMinY, CGRectGetWidth(_luckyBtnBackView.frame) - promptLabelMinX * 2, promptLabelHeight);
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
            [promptLabel setBackgroundColor:[UIColor clearColor]];
            [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [promptLabel setTextColor:[UIColor whiteColor]];
            [promptLabel setText:@"请选择您的出生年月日？"];
            [_luckyBtnBackView addSubview:promptLabel];
            [promptLabel release];
            
            //yearBtn
            CGRect yearBtnRect = CGRectMake(CGRectGetMinX(promptLabelRect), CGRectGetMaxY(promptLabelRect), birthdayBtnWidth * 1.5, birthdayBtnHeight);
            _yearBtn = [[UIButton alloc] initWithFrame:yearBtnRect];
            [_yearBtn setBackgroundColor:[UIColor whiteColor]];
            [[_yearBtn layer] setCornerRadius:2.0f];
            [[_yearBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_yearBtn setAdjustsImageWhenHighlighted:NO];
            [_yearBtn addTarget:self action:@selector(birthdaySelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [_yearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_luckyBtnBackView addSubview:_yearBtn];
            [_yearBtn release];
            
            //yearImageView
            CGRect yearImageViewRect = CGRectMake(CGRectGetWidth(yearBtnRect) - sanjiaoImageViewWidth - sanjiaoImageViewMaginRight, (CGRectGetHeight(yearBtnRect) - sanjiaoImageViewHeight) / 2.0f, sanjiaoImageViewWidth, sanjiaoImageViewHeight);
            UIImageView *yearImageView = [[UIImageView alloc] initWithFrame:yearImageViewRect];
            [yearImageView setBackgroundColor:[UIColor clearColor]];
            [yearImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"sanjiao.png"]]];
            [_yearBtn addSubview:yearImageView];
            [yearImageView release];
            
            //yearLabel
            CGRect yearLabelRect = CGRectMake(CGRectGetMaxX(yearBtnRect), CGRectGetMinY(yearBtnRect), birthdayLabelWidth, CGRectGetHeight(yearBtnRect));
            UILabel *yearLabel = [[UILabel alloc] initWithFrame:yearLabelRect];
            [yearLabel setBackgroundColor:[UIColor clearColor]];
            [yearLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [yearLabel setTextColor:[UIColor whiteColor]];
            [yearLabel setTextAlignment:NSTextAlignmentCenter];
            [yearLabel setText:@"年"];
            [_luckyBtnBackView addSubview:yearLabel];
            [yearLabel release];
            
            //monthBtn
            CGRect monthBtnRect = CGRectMake(CGRectGetMaxX(yearLabelRect), CGRectGetMinY(yearLabelRect), birthdayBtnWidth, birthdayBtnHeight);
            _monthBtn = [[UIButton alloc] initWithFrame:monthBtnRect];
            [_monthBtn setBackgroundColor:[UIColor whiteColor]];
            [[_monthBtn layer] setCornerRadius:2.0f];
            [[_monthBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_monthBtn setAdjustsImageWhenHighlighted:NO];
            [_monthBtn addTarget:self action:@selector(birthdaySelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [_monthBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_luckyBtnBackView addSubview:_monthBtn];
            [_monthBtn release];
            
            //monthImageView
            CGRect monthImageViewRect = CGRectMake(CGRectGetWidth(monthBtnRect) - sanjiaoImageViewWidth - sanjiaoImageViewMaginRight, (CGRectGetHeight(monthBtnRect) - sanjiaoImageViewHeight) / 2.0f, sanjiaoImageViewWidth, sanjiaoImageViewHeight);
            UIImageView *monthImageView = [[UIImageView alloc] initWithFrame:monthImageViewRect];
            [monthImageView setBackgroundColor:[UIColor clearColor]];
            [monthImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"sanjiao.png"]]];
            [_monthBtn addSubview:monthImageView];
            [monthImageView release];
            
            //monthLabel
            CGRect monthLabelRect = CGRectMake(CGRectGetMaxX(monthBtnRect), CGRectGetMinY(monthBtnRect), birthdayLabelWidth, CGRectGetHeight(monthBtnRect));
            UILabel *monthLabel = [[UILabel alloc] initWithFrame:monthLabelRect];
            [monthLabel setBackgroundColor:[UIColor clearColor]];
            [monthLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [monthLabel setTextColor:[UIColor whiteColor]];
            [monthLabel setTextAlignment:NSTextAlignmentCenter];
            [monthLabel setText:@"月"];
            [_luckyBtnBackView addSubview:monthLabel];
            [monthLabel release];
            
            //dayBtn
            CGRect dayBtnRect = CGRectMake(CGRectGetMaxX(monthLabelRect), CGRectGetMinY(monthBtnRect), birthdayBtnWidth, birthdayBtnHeight);
            _dayBtn = [[UIButton alloc] initWithFrame:dayBtnRect];
            [_dayBtn setBackgroundColor:[UIColor whiteColor]];
            [[_dayBtn layer] setCornerRadius:2.0f];
            [[_dayBtn titleLabel] setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_dayBtn setAdjustsImageWhenHighlighted:NO];
            [_dayBtn addTarget:self action:@selector(birthdaySelectTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [_dayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_luckyBtnBackView addSubview:_dayBtn];
            [_dayBtn release];
            
            //dayImageView
            CGRect dayImageViewRect = CGRectMake(CGRectGetWidth(dayBtnRect) - sanjiaoImageViewWidth - sanjiaoImageViewMaginRight, (CGRectGetHeight(dayBtnRect) - sanjiaoImageViewHeight) / 2.0f, sanjiaoImageViewWidth, sanjiaoImageViewHeight);
            UIImageView *dayImageView = [[UIImageView alloc] initWithFrame:dayImageViewRect];
            [dayImageView setBackgroundColor:[UIColor clearColor]];
            [dayImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"sanjiao.png"]]];
            [_dayBtn addSubview:dayImageView];
            [dayImageView release];
            
            //dayLabel
            CGRect dayLabelRect = CGRectMake(CGRectGetMaxX(dayBtnRect), CGRectGetMinY(dayBtnRect), birthdayLabelWidth, CGRectGetHeight(dayBtnRect));
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:dayLabelRect];
            [dayLabel setBackgroundColor:[UIColor clearColor]];
            [dayLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [dayLabel setTextColor:[UIColor whiteColor]];
            [dayLabel setTextAlignment:NSTextAlignmentCenter];
            [dayLabel setText:@"日"];
            [_luckyBtnBackView addSubview:dayLabel];
            [dayLabel release];
            
        }
            break;
        case 3://姓名
        {
            //promptLabel
            CGRect promptLabelRect = CGRectMake(promptLabelMinX, promptLabelMinY, CGRectGetWidth(_luckyBtnBackView.frame) - promptLabelMinX * 2, promptLabelHeight);
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
            [promptLabel setBackgroundColor:[UIColor clearColor]];
            [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [promptLabel setTextColor:[UIColor whiteColor]];
            [promptLabel setText:@"请输入您的姓名？"];
            [_luckyBtnBackView addSubview:promptLabel];
            [promptLabel release];
            
            //userNameTextField
            CGRect userNameTextFieldRect = CGRectMake(CGRectGetMinX(promptLabelRect), CGRectGetMaxY(promptLabelRect), CGRectGetWidth(promptLabelRect), birthdayBtnHeight);
            _userNameTextField = [[UITextField alloc] initWithFrame:userNameTextFieldRect];
            [_userNameTextField setBackgroundColor:[UIColor whiteColor]];
            [[_userNameTextField layer] setCornerRadius:2.0f];
            [_userNameTextField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [_userNameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [_userNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_luckyBtnBackView addSubview:_userNameTextField];
            [_userNameTextField release];
            
            
        }
            break;
        case 4://情侣
        {
            //promptLabel
            CGRect promptLabelRect = CGRectMake(promptLabelMinX, promptLabelMinY, CGRectGetWidth(_luckyBtnBackView.frame) - promptLabelMinX * 2, promptLabelHeight);
            UILabel *promptLabel = [[UILabel alloc] initWithFrame:promptLabelRect];
            [promptLabel setBackgroundColor:[UIColor clearColor]];
            [promptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [promptLabel setTextColor:[UIColor whiteColor]];
            [promptLabel setText:@"请输入情侣双方的姓名？"];
            [_luckyBtnBackView addSubview:promptLabel];
            [promptLabel release];
            
            //boyNameTextField
            CGRect boyNameTextFieldRect = CGRectMake(CGRectGetMinX(promptLabelRect), CGRectGetMaxY(promptLabelRect), birthdayBtnWidth * 2, birthdayBtnHeight);
            _boyNameTextField = [[UITextField alloc] initWithFrame:boyNameTextFieldRect];
            [_boyNameTextField setBackgroundColor:[UIColor whiteColor]];
            [[_boyNameTextField layer] setCornerRadius:2.0f];
            [_boyNameTextField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [_boyNameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [_boyNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_luckyBtnBackView addSubview:_boyNameTextField];
            [_boyNameTextField release];
            
            //girlNameTextField
            CGRect girlNameTextFieldRect = CGRectMake(CGRectGetMaxX(promptLabelRect) - birthdayBtnWidth * 2, CGRectGetMaxY(promptLabelRect), birthdayBtnWidth * 2, birthdayBtnHeight);
            _girlNameTextField = [[UITextField alloc] initWithFrame:girlNameTextFieldRect];
            [_girlNameTextField setBackgroundColor:[UIColor whiteColor]];
            [[_girlNameTextField layer] setCornerRadius:2.0f];
            [_girlNameTextField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [_girlNameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [_girlNameTextField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
            [_luckyBtnBackView addSubview:_girlNameTextField];
            [_girlNameTextField release];
        }
            break;
        default:
            break;
    }
}

- (void)shengxiaoBtnTouchUpInside:(id)sender {
    for (UIButton *btn in _luckyBtnBackView.subviews) {
        if (btn && [btn isKindOfClass:[UIButton class]]) {
            [btn setSelected:NO];
        }
    }
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:YES];
}

- (void)luckyTypeDropTouchUpInside:(id)sender {
    [self hideKeyboard:nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_luckyTypeArray forKey:@"0"];
    
    //pickerView 滚动选择视图
    CGRect pickerViewRect = IS_PHONE ? CGRectMake(0, 0, 250, 200) : CGRectMake(0, 0, 375, 300);
    DialogPickerView *pickerView = [[DialogPickerView alloc] initWithFrame:pickerViewRect title:@"" selectIndexDict:_selectLuckyTypeIndexDict dataDict:dict dateType:NO];
    [pickerView setTag:11];
    [pickerView setDelegate:self];
    [pickerView show];
    [pickerView release];
}

- (void)birthdaySelectTouchUpInside:(id)sender {
    //pickerView 滚动选择视图
    CGRect pickerViewRect = CGRectMake(0, 0, 320, 250);
    DialogPickerView *pickerView = [[DialogPickerView alloc] initWithFrame:pickerViewRect title:@"" selectIndexDict:_selectDateIndexDict dataDict:nil dateType:YES];
    [pickerView setTag:12];
    [pickerView setDelegate:self];
    [pickerView show];
    [pickerView release];
}

- (void)selectLuckyNumberTouchUpInside:(id)sender {
    [self hideKeyboard:nil];
    
    if ([self asJudge]) {
        [self warningBox];
        return;
    }
    NSInteger type = [[_selectLuckyTypeIndexDict objectForKey:@"0"] integerValue];
    
    if (type == 2) {
        if ([_yearBtn titleLabel].text.length == 0) {
            [Globals alertWithMessage:@"请选择出生年月日"];
            return;
        }
    } else if (type == 3) {
        if ([_userNameTextField text].length == 0) {
            [Globals alertWithMessage:@"请输入自己的姓名"];
            return;
        }
    } else if (type == 4) {
        if ([_boyNameTextField text].length == 0 || [_girlNameTextField text].length == 0) {
            [Globals alertWithMessage:@"请输入情侣双方的姓名"];
            return;
        }
    }
    
    CGRect luckyLineImageViewRect = _luckyLineImageView.frame;
    CGFloat luckyLineImageViewWidth = CGRectGetWidth(luckyLineImageViewRect);
    CGFloat luckyLineImageViewHeight = CGRectGetHeight(luckyLineImageViewRect);
    CGRect startRect = CGRectMake(_luckyLineImageViewStartMinX, _luckyLineImageViewStartMinY, luckyLineImageViewWidth, luckyLineImageViewHeight);
    [_luckyLineImageView setFrame:startRect];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^ {
        
        [_comeBackBtn setEnabled:NO];
        
        [_lotteryDropBtn setEnabled:NO];
        [_luckyTypeDropBtn setEnabled:NO];
        [_luckyBtnBackView setUserInteractionEnabled:NO];
        [_selectLuckyNumberBtn setEnabled:NO];
        [_luckyTableView setUserInteractionEnabled:NO];
        [_betBtn setEnabled:NO];
        
        
        CGRect endRect = CGRectMake(_luckyLineImageViewEndMinX, _luckyLineImageViewEndMinY, luckyLineImageViewWidth, luckyLineImageViewHeight);
        [_luckyLineImageView setFrame:endRect];
        
    } completion:^(BOOL finished) {
        [_luckyLineImageView setFrame:startRect];
        [_comeBackBtn setEnabled:YES];
        
        [_lotteryDropBtn setEnabled:YES];
        [_luckyTypeDropBtn setEnabled:YES];
        [_luckyBtnBackView setUserInteractionEnabled:YES];
        [_selectLuckyNumberBtn setEnabled:YES];
        [_luckyTableView setUserInteractionEnabled:YES];
        [_betBtn setEnabled:YES];
        
        [self getRandomNumber];
    }];
}

- (void)betTouchUpInside:(id)sender {
    [self gotoBetWithLotteryID:[InterfaceHelper getLotteryMessageWithLotteryName:[_lotteryDropBtn titleLabel].text messageType:0]];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)gesture {
    for (UIView *view in _luckyBtnBackView.subviews) {
        if([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            [textField resignFirstResponder];
        }
    }
}

#pragma mark -Customized: Private (General)
- (void)setCurrLotteryDic:(NSString *)lotteryTypeName {
    [_lotteryDic release];
    if ([lotteryTypeName isEqualToString:@"双色球"]) {
        _lotteryDic = [[_infoDic objectForKey:@"5"] retain];
    } else if ([lotteryTypeName isEqualToString:@"3D"]) {
        _lotteryDic = [[_infoDic objectForKey:@"6"] retain];
    } else if ([lotteryTypeName isEqualToString:@"大乐透"]) {
        _lotteryDic = [[_infoDic objectForKey:@"39"] retain];
    } else if ([lotteryTypeName isEqualToString:@"七乐彩"]) {
        _lotteryDic = [[_infoDic objectForKey:@"13"] retain];
    } else if ([lotteryTypeName isEqualToString:@"七星彩"]) {
        _lotteryDic = [[_infoDic objectForKey:@"3"] retain];
    } else if ([lotteryTypeName isEqualToString:@"排列三"]) {
        _lotteryDic = [[_infoDic objectForKey:@"63"] retain];
    } else if ([lotteryTypeName isEqualToString:@"排列五"]) {
        _lotteryDic = [[_infoDic objectForKey:@"64"] retain];
    } else if ([lotteryTypeName isEqualToString:@"重庆时时彩"]) {
        _lotteryDic = [[_infoDic objectForKey:@"28"] retain];
    } else if ([lotteryTypeName isEqualToString:@"十一运夺金"]) {
        _lotteryDic = [[_infoDic objectForKey:@"62"] retain];
    } else if ([lotteryTypeName isEqualToString:@"江苏快三"]) {
        _lotteryDic = [[_infoDic objectForKey:@"83"] retain];
    } else if ([lotteryTypeName isEqualToString:@"江西11选5"]) {
        _lotteryDic = [[_infoDic objectForKey:@"70"] retain];
    } else if ([lotteryTypeName isEqualToString:@"广东11选5"]) {
        _lotteryDic = [[_infoDic objectForKey:@"78"] retain];
    } else if ([lotteryTypeName isEqualToString:@"新疆时时彩"]) {
        _lotteryDic = [[_infoDic objectForKey:@"66"] retain];
    }
}

- (void)showAlertView {
    [Globals alertWithMessage:@"请输入对应的信息"];
}

- (void)getRandomNumber {
    int betCount = 5;
        
    [_luckyNumberArray removeAllObjects];
    
    for (int i = 0; i < betCount; i++) {
        if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"双色球"]) {
            NSString *number = [RandomLuckyNumber getSSQRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"3D"]) {
            NSString *number = [RandomLuckyNumber get3DRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"大乐透"]) {
            NSString *number = [RandomLuckyNumber getDLTRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"七乐彩"]) {
            NSString *number = [RandomLuckyNumber getQLCRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"七星彩"]) {
            NSString *number = [RandomLuckyNumber getQXCRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"排列三"]) {
            NSString *number = [RandomLuckyNumber getPL3RandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"排列五"]) {
            NSString *number = [RandomLuckyNumber getPL5RandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"重庆时时彩"] || [_lotteryDropBtn.titleLabel.text isEqualToString:@"新疆时时彩"]) {
            NSString *number = [RandomLuckyNumber getSSCRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"十一运夺金"]) {
            NSString *number = [RandomLuckyNumber getSYYDJRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"江苏快三"]) {
            NSString *number = [RandomLuckyNumber getGSK3];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"江西11选5"]) {
            NSString *number = [RandomLuckyNumber getSYXWRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"广东11选5"]) {
            NSString *number = [RandomLuckyNumber getSYXWRandomNumber];
            [_luckyNumberArray addObject:number];
        } else if ([_lotteryDropBtn.titleLabel.text isEqualToString:@"江西时时彩"]) {
            NSString *number = [RandomLuckyNumber getSSCRandomNumber];
            [_luckyNumberArray addObject:number];
        }
    }
    [_luckyTableView reloadData];
}

- (BOOL)asJudge {
    //判断时
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDate = [dateFormatter dateFromString:[_lotteryDic objectForKey:@"endtime"]];
    [dateFormatter release];
    
    NSTimeInterval time = [self.oneS.commonHomeViewControl getTimeIntervalWithEndDate:endDate];
    if (time <= 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)warningBox {
    //显示警告框
    [Globals alertWithMessage:@"该彩种奖期已结束，请选择其他彩种"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location >= 10) {
        return NO;
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if(![pred evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}

- (void)gotoBetWithLotteryID:(NSString *)lotteryID {
    if(_lotteryDic == nil) {
        [Globals alertWithMessage:@"无奖期信息，不能进行投注"];
        return;
    } else if ([_luckyNumberArray count] == 0) {
        [Globals alertWithMessage:@"没有投注号码，不能进行投注"];
        return;
    }
    
    BaseBetViewController *betViewController = nil;
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    
    if([lotteryID isEqualToString:@"5"]) {
        for (NSInteger i = 0; i < _luckyNumberArray.count; i++) {
            NSString *number = [_luckyNumberArray objectAtIndex:i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:number forKey:kSelectBalls];
            [dic setObject:@"普通投注" forKey:kBetType];
            [dic setObject:[NSNumber numberWithInteger:501] forKey:kPlayID];
            [dic setObject:[NSNumber numberWithInteger:1] forKey:kBetCount];
            [dic setObject:[NSNumber numberWithBool:YES] forKey:kIsSupportShake];
            
            NSString *redStr = [number substringToIndex:number.length - 4];
            NSString *blueStr = [number substringFromIndex:number.length - 3];
            [dic setObject:[self convertStringToArray:redStr] forKey:kOneViewBalls];
            [dic setObject:[self convertStringToArray:blueStr] forKey:kTwoViewBalls];
            
            [infoDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
            
        }
        betViewController = [[SSQBetViewController alloc]initWithBallsInfoDic:infoDic LotteryDic:_lotteryDic isSupportShake:YES];
    } else if ([lotteryID isEqualToString:@"39"]) {
        for (NSInteger i = 0; i < _luckyNumberArray.count; i++) {
            NSString *number = [_luckyNumberArray objectAtIndex:i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:number forKey:kSelectBalls];
            [dic setObject:@"普通投注" forKey:kBetType];
            [dic setObject:[NSNumber numberWithInteger:1] forKey:kBetCount];
            [dic setObject:[NSNumber numberWithInteger:3901] forKey:kPlayID];
            [dic setObject:[NSNumber numberWithBool:YES] forKey:kIsSupportShake];
            
            NSString *redStr = [number substringToIndex:number.length - 7];
            NSString *blueStr = [number substringFromIndex:number.length - 6];
            [dic setObject:[self convertStringToArray:redStr] forKey:kOneViewBalls];
            [dic setObject:[self convertStringToArray:blueStr] forKey:kTwoViewBalls];
            
            [infoDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
            
        }
        betViewController = [[DLTBetViewController alloc] initWithBallsInfoDic:infoDic LotteryDic:_lotteryDic isSupportShake:YES];
    } else if ([lotteryID isEqualToString:@"6"]) {
        for (NSInteger i = 0; i < _luckyNumberArray.count; i++) {
            NSString *number = [_luckyNumberArray objectAtIndex:i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:number forKey:kSelectBalls];
            [dic setObject:@"直选" forKey:kBetType];
            [dic setObject:[NSNumber numberWithInteger:1] forKey:kBetCount];
            [dic setObject:[NSNumber numberWithInteger:601] forKey:kPlayID];
            [dic setObject:[NSNumber numberWithBool:YES] forKey:kIsSupportShake];
            
            NSString *hundreds = [number substringToIndex:1];
            NSString *decade = [number substringWithRange:NSMakeRange(2, 1)];
            NSString *bits = [number substringFromIndex:number.length - 1];
            [dic setObject:[self convertStringToArray:hundreds] forKey:kOneViewBalls];
            [dic setObject:[self convertStringToArray:decade] forKey:kTwoViewBalls];
            [dic setObject:[self convertStringToArray:bits] forKey:kThreeViewBalls];
            
            [infoDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        
        betViewController = [[SDBetViewController alloc] initWithBallsInfoDic:infoDic LotteryDic:_lotteryDic isSupportShake:YES];
    }
    if(betViewController != nil ) {
        [betViewController setLuckyNumber:YES];
        [self.navigationController pushViewController:betViewController animated:YES];
        [betViewController release];
    }
    
}

- (NSArray *)convertStringToArray:(NSString *)string {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *array = [string componentsSeparatedByString:@" "];
    for (NSString *str in array) {
        if(![str isEqualToString:@""]) {
            [result addObject:[NSNumber numberWithInt:[str intValue]]];
        }
    }
    return result;
}

@end
