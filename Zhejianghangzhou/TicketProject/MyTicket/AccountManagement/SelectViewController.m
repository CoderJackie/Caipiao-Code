//
//  SelectViewController.m
//  TicketProject
//
//  Created by KAI on 14-12-1.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "SelectViewController.h"
#import "Globals.h"

#define selectTabelCellHeight (IS_PHONE ? 45.0f : 60.0f)

@interface SelectViewController ()

@end
#pragma mark -
#pragma mark @implementation SelectViewController
@implementation SelectViewController
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithSelectDict:(NSDictionary *)selectDict selectKeyName:(NSString *)selectKeyName selectType:(SelectType)selectType {
    self = [super init];
    if (self) {
        _selectDict = [selectDict retain];
        _selectKeyName = [selectKeyName copy];
        _selectType = selectType;
    }
    return self;
}

- (void)dealloc {
    [_selectDict release];
    [_selectKeyName release];
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
    [comeBackBtn addTarget:self action:@selector(getBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *comeBackItem = [[UIBarButtonItem alloc]initWithCustomView:comeBackBtn];
    [self.navigationItem setLeftBarButtonItem:comeBackItem];
    [comeBackItem release];
    
    //selectTableView
    CGRect selectTableViewRect = CGRectMake(0, 0, CGRectGetWidth(appRect), CGRectGetHeight(appRect) - 44.0f);
    UITableView *selectTableView = [[UITableView alloc]initWithFrame:selectTableViewRect style:UITableViewStylePlain];
    [selectTableView setBackgroundColor:kBackgroundColor];
    [selectTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [selectTableView setDataSource:self];
    [selectTableView setDelegate:self];
    [self.view addSubview:selectTableView];
    [selectTableView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(selectViewAtIndex:selectType:)]) {
        [_delegate selectViewAtIndex:indexPath.row selectType:_selectType];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return selectTabelCellHeight;
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_selectDict count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SelectTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        CGRect selectNameLabelRect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), selectTabelCellHeight);
        UILabel *selectNameLabel = [[UILabel alloc] initWithFrame:selectNameLabelRect];
        [selectNameLabel setBackgroundColor:[UIColor clearColor]];
        [selectNameLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [selectNameLabel setTextColor:[UIColor colorWithRed:0x84/255.0f green:0x84/255.0f blue:0x84/255.0f alpha:1.0]];
        [selectNameLabel setTextAlignment:NSTextAlignmentCenter];
        [selectNameLabel setTag:231];
        [cell.contentView addSubview:selectNameLabel];
        [selectNameLabel release];
        
        CGRect lineRect = CGRectMake(0, selectTabelCellHeight - AllLineWidthOrHeight, CGRectGetWidth(tableView.frame), AllLineWidthOrHeight);
        [Globals makeLineWithFrame:lineRect inSuperView:cell.contentView];
    }
    
    UILabel *selectNameLabel = (UILabel *)[cell.contentView viewWithTag:231];
    if (indexPath.row < [_selectDict count]) {
        NSDictionary *dict = [_selectDict objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        [selectNameLabel setText:[dict objectForKey:_selectKeyName]];
    }
    
    return cell;
}

- (void)getBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
