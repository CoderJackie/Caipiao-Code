//
//  FCViewController.m 合买普通投注 选号详情
//  TicketProject
//
//  Created by sls002 on 14-7-2.
//  Copyright (c) 2014年 sls002. All rights reserved.
//
//20140725 17:03（洪晓彬）：整理代码，修改代码规范，改进生命周期，处理内存
//20140807 18:10（洪晓彬）：进行ipad适配

#import "FCViewController.h"
#import "CustomParserNumber.h"

#import "Globals.h"

#import "GlobalsProject.h"

@interface FCViewController ()

#define FCViewTableCellHeight (IS_PHONE ? 30.0f : 60.0f)

#define firstLabelWidth 73.0f * kWinSize.width / (73.0f + 187.0f + 51.0f)
#define secondLabelWidth 187.0f * kWinSize.width / (73.0f + 187.0f + 51.0f)
#define threeLabelWidht 51.0f * kWinSize.width / (73.0f + 187.0f + 51.0f)

@end
#pragma mark -
#pragma mark @implementation FCViewController
@implementation FCViewController
#pragma mark Lifecircle

- (id)initWithSchemeDictionary:(NSDictionary *)dic {
    self = [super init];
    if(self) {
        _schemeDic = [dic retain];
        _lotteryID = [dic intValueForKey:@"lotteryId"];
        [self setTitle:@"选号详情"];
    }
    return self;
}

- (void)dealloc {
    [_schemeDic release];
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
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat viewMinX = (kWinSize.width - firstLabelWidth - secondLabelWidth - threeLabelWidht) / 2.0f;
    
    CGFloat firstLabelMinY = IS_PHONE ? 10.0f : 15.0f;
    /********************** adjustment end ***************************/
    
    //modePromptTextField 方式 提示文字
    CGRect modePromptLabelRect = CGRectMake(viewMinX, firstLabelMinY, firstLabelWidth, FCViewTableCellHeight);
    UILabel *modePromptLabel = [[UILabel alloc] initWithFrame:modePromptLabelRect];
    [modePromptLabel.layer setBorderWidth:AllLineWidthOrHeight];
    [modePromptLabel.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe0/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
    [modePromptLabel setText:@"方式"];
    [modePromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [modePromptLabel setTextAlignment:NSTextAlignmentCenter];
    [modePromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
    [modePromptLabel setTextColor:[UIColor colorWithRed:0x91/255.0f green:0x91/255.0f blue:0x91/255.0f alpha:1.0f]];
    [self.view addSubview:modePromptLabel];
    [modePromptLabel release];
    
    //touZhuPromptTextField 投注 提示文字
    CGRect touZhuPromptLabelRect = CGRectMake(CGRectGetMaxX(modePromptLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(modePromptLabelRect), secondLabelWidth, CGRectGetHeight(modePromptLabelRect));
    UILabel *touZhuPromptLabel = [[UILabel alloc] initWithFrame:touZhuPromptLabelRect];
    [touZhuPromptLabel.layer setBorderWidth:AllLineWidthOrHeight];
    [touZhuPromptLabel.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
    [touZhuPromptLabel setText:@"投注号码"];
    [touZhuPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [touZhuPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [touZhuPromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
    [touZhuPromptLabel setTextColor:[UIColor colorWithRed:0x91/255.0f green:0x91/255.0f blue:0x91/255.0f alpha:1.0f]];
    [self.view addSubview:touZhuPromptLabel];
    [touZhuPromptLabel release];
    
    //beiShuPromptTextField 倍数 提示文字
    CGRect beiShuPromptLabelRect = CGRectMake(CGRectGetMaxX(touZhuPromptLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(modePromptLabelRect), threeLabelWidht, CGRectGetHeight(modePromptLabelRect));
    UILabel *beiShuPromptLabel = [[UILabel alloc] initWithFrame:beiShuPromptLabelRect];
    [beiShuPromptLabel.layer setBorderWidth:AllLineWidthOrHeight];
    [beiShuPromptLabel.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
    [beiShuPromptLabel setText:@"倍数"];
    [beiShuPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [beiShuPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [beiShuPromptLabel setBackgroundColor:[UIColor colorWithRed:0xfe/255.0f green:0xfe/255.0f blue:0xf2/255.0f alpha:1.0f]];
    [beiShuPromptLabel setTextColor:[UIColor colorWithRed:0x91/255.0f green:0x91/255.0f blue:0x91/255.0f alpha:1.0f]];
    [self.view addSubview:beiShuPromptLabel];
    [beiShuPromptLabel release];
    
    //detailTableView 投注详情视图
    CGRect detailTableViewRect = CGRectMake(viewMinX, CGRectGetMaxY(modePromptLabelRect), CGRectGetWidth(appRect) - viewMinX * 2, CGRectGetHeight(appRect) - CGRectGetMaxY(modePromptLabelRect) - kNavigationBarHeight);
    UITableView *detailTableView = [[UITableView alloc]initWithFrame:detailTableViewRect style:UITableViewStylePlain];
    [detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [detailTableView setBackgroundColor:[UIColor clearColor]];
    [detailTableView setDataSource:self];
    [detailTableView setDelegate:self];
    [self.view addSubview:detailTableView];
    [detailTableView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ballsArray = [_schemeDic objectForKey:@"buyContent"];
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
        self.view = nil;
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
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_ballsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FCCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CGFloat cellHeight = [self tableCellHeight:indexPath tableView:tableView];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //modeLabel 方式
        CGRect modeLabelRect = CGRectMake(0, -AllLineWidthOrHeight, firstLabelWidth, FCViewTableCellHeight + AllLineWidthOrHeight);
        UILabel *modeLabel = [[UILabel alloc] initWithFrame:modeLabelRect];
        [modeLabel.layer setBorderWidth:AllLineWidthOrHeight];
        [modeLabel.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
        [modeLabel setTag:401];
        [modeLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [modeLabel setTextAlignment:NSTextAlignmentCenter];
        [modeLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:modeLabel];
        [modeLabel release];
        
        //touZhuLabel 单色投注显示
        CGRect touZhuLabelRect = CGRectMake(CGRectGetMaxX(modeLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(modeLabelRect), secondLabelWidth, CGRectGetHeight(modeLabelRect));
        UILabel *touZhuLabel = [[UILabel alloc] initWithFrame:touZhuLabelRect];
        [touZhuLabel.layer setBorderWidth:AllLineWidthOrHeight];
        [touZhuLabel.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
        [touZhuLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [touZhuLabel setTextAlignment:NSTextAlignmentCenter];
        [touZhuLabel setNumberOfLines:5];
        [touZhuLabel setBackgroundColor:[UIColor clearColor]];
        [touZhuLabel setTextColor:[UIColor colorWithRed:187.0/255.0 green:48.0/255.0 blue:65.0/255.0 alpha:1.0]];
        [touZhuLabel setTag:403];
        [cell.contentView addSubview:touZhuLabel];
        [touZhuLabel release];
        
        //lastWinNumLabel 最后获奖或双色球大乐透
        CustomLabel *lastWinNumLabel = [[CustomLabel alloc]init];
        [lastWinNumLabel setTextAlignment:NSTextAlignmentCenter];
        [lastWinNumLabel setBackgroundColor:[UIColor clearColor]];
        [lastWinNumLabel setTag:402];
        [cell.contentView addSubview:lastWinNumLabel];
        [lastWinNumLabel release];
        
        //beiShuPromptLabel 倍数
        UILabel *beiShuLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(touZhuLabelRect) - AllLineWidthOrHeight, CGRectGetMinY(touZhuLabelRect), threeLabelWidht, CGRectGetHeight(modeLabelRect))];
        [beiShuLabel.layer setBorderWidth:AllLineWidthOrHeight];
        [beiShuLabel.layer setBorderColor:[UIColor colorWithRed:0xe2/255.0f green:0xe2/255.0f blue:0xe2/255.0f alpha:1.0f].CGColor];
        [beiShuLabel setTag:404];
        [beiShuLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [beiShuLabel setTextAlignment:NSTextAlignmentCenter];
        [beiShuLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:beiShuLabel];
        [beiShuLabel release];
    }
    
    //modeLabel 方式
    UILabel *modeLabel = (UILabel *)[cell.contentView viewWithTag:401];
    [modeLabel setFrame:CGRectMake(CGRectGetMinX(modeLabel.frame), CGRectGetMinY(modeLabel.frame), CGRectGetWidth(modeLabel.frame), cellHeight + AllLineWidthOrHeight)];
    
    
    //lastWinNumLabel 最后获奖或双色球大乐透
    CustomLabel *lastWinNumLabel = (CustomLabel *)[cell.contentView viewWithTag:402];
    [lastWinNumLabel setFrame:CGRectMake(CGRectGetMinX(lastWinNumLabel.frame), CGRectGetMinY(lastWinNumLabel.frame), CGRectGetWidth(lastWinNumLabel.frame), cellHeight + AllLineWidthOrHeight)];
    
    //touZhuLable 单色投注显示
    UILabel *touZhuLable = (UILabel *)[cell.contentView viewWithTag:403];
    [touZhuLable setFrame:CGRectMake(CGRectGetMinX(touZhuLable.frame), CGRectGetMinY(touZhuLable.frame), CGRectGetWidth(touZhuLable.frame), cellHeight + AllLineWidthOrHeight)];
    
    //beiShuPromptTextField 倍数
    UILabel *beiShuLabel = (UILabel *)[cell.contentView viewWithTag:404];
    [beiShuLabel setFrame:CGRectMake(CGRectGetMinX(beiShuLabel.frame), CGRectGetMinY(beiShuLabel.frame), CGRectGetWidth(beiShuLabel.frame), cellHeight + AllLineWidthOrHeight)];
    
    [beiShuLabel setText:[NSString stringWithFormat:@"%@",[_schemeDic objectForKey:@"multiple"]]];
    
    NSArray *ballArray = [_ballsArray objectAtIndex:indexPath.row];
    
    if (([ballArray isKindOfClass:[NSArray class]] && [ballArray count] > 0) || [ballArray isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict;
        if ([ballArray isKindOfClass:[NSDictionary class]]) {
            dict = (NSDictionary *)ballArray;
        }else{
            dict = [ballArray objectAtIndex:0];
        }
        
        NSString *openNumber = [dict objectForKey:@"lotteryNumber"];
        
        NSInteger playType = [[dict objectForKey:@"playType"] integerValue];
        NSString *playName = [GlobalsProject judgeRecordPlayNameWithLotteryID:[[_schemeDic objectForKey:@"lotteryId"] integerValue] playId:playType number:openNumber];
        [modeLabel setText:[NSString stringWithFormat:@"%@",playName]];
        
        NSRange range1 = [openNumber rangeOfString:@"-"];
        NSRange range2 = [openNumber rangeOfString:@"+"];
        CGSize expectedSize = [openNumber sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12] constrainedToSize:CGSizeMake(CGRectGetWidth(touZhuLable.frame), NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
        //区分红\蓝球
        if ((range1.location != NSNotFound || range2.location != NSNotFound) && _lotteryID != 74 && _lotteryID != 75 && _lotteryID != 28) {
            NSArray *arr = [openNumber componentsSeparatedByString:@"-"];
            if ([arr count] < 2) {
                arr = [openNumber componentsSeparatedByString:@"+"];
            }
            if ([arr count] >= 2) {
                NSString *openRedNumber = [arr objectAtIndex:0];
                NSString *openBlueNumber = [arr objectAtIndex:1];
                
                // 显示上期开奖号码
                NSString *text = [NSString stringWithFormat:@" <font color=\"%@\">%@ </font><font color=\"%@\">%@</font>",tRedColorText,openRedNumber,tBlueColorText,openBlueNumber];
                MarkupParser *p = [[MarkupParser alloc]initWithFontSize:XFIponeIpadFontSize12];
                NSAttributedString *attString = [p attrStringFromMarkup:text];
                [p release];
                [lastWinNumLabel setFrame:CGRectMake((CGRectGetWidth(touZhuLable.frame) - expectedSize.width) / 2 + CGRectGetMinX(touZhuLable.frame), (cellHeight - expectedSize.height) / 2, expectedSize.width + XFIponeIpadFontSize12 / 8.0, expectedSize.height)];
                [lastWinNumLabel setAttString:attString];
            }
            
            
        } else {
            [touZhuLable setText:[NSString stringWithFormat:@"%@",openNumber]];
        }
        
    }
    
    
    return cell;
}

#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableCellHeight:indexPath tableView:tableView];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)getBackTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableCellHeight:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSString *test = @"1";
    
    NSString *str = [_schemeDic objectForKey:@"lotteryNumber"];
    NSArray *arr1 = [str componentsSeparatedByString:@"\n"];
    NSString *openNumber = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:indexPath.row]];
    
    CGSize testSize = [test sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12] constrainedToSize:CGSizeMake(secondLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize expectedSize = [openNumber sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12] constrainedToSize:CGSizeMake(secondLabelWidth, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    
    return FCViewTableCellHeight - testSize.height + expectedSize.height;
}

@end
