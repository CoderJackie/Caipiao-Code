//
//  WithdrawalTypePopView.m
//  TicketProject
//
//  Created by kiu on 15/7/10.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "WithdrawalTypePopView.h"

#import "Globals.h"
#import "XmlParser.h"

#define kTableViewHeight (IS_PHONE ? 250 : 60)
#define withdrawalTypeTabelCellHeight (IS_PHONE ? 30.0f : 50.0f)

#pragma mark -
#pragma mark @implementation SafeProblemPopView
@implementation WithdrawalTypePopView
#pragma mark Lifecircle
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame SelectIndex:(NSInteger)index {
    CGRect selfFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), 60);
    self = [super initWithFrame:selfFrame];
    if (self) {
        [self setClipsToBounds:YES];
        _selectIndex1 = index;
        
        XmlParser *xmlParser = [[XmlParser alloc] init];
        _questionDic = [[xmlParser getQuestionDictionary] retain];
        [xmlParser release];
        
        [self makeSubView];
    }
    return self;
}

- (void)dealloc {
    [_overlayView release];
    _overlayView = nil;
    _withdrawalTypeTableView = nil;
    
    [_questionDic release];
    _questionDic = nil;
    [_previousSelectBtn release];
    _previousSelectBtn = nil;
    
    [super dealloc];
}

- (void)makeSubView {
    //overlayView 半透明的背景
    _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_overlayView setUserInteractionEnabled:YES];
    [_overlayView setBackgroundColor:[UIColor blackColor]];
    [_overlayView setAlpha:0.5];
    
    //tapGes 半透明视图点击动作
    UITapGestureRecognizer *tapGes =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chickView)];
    [_overlayView addGestureRecognizer:tapGes];
    [tapGes release];
    
    CGFloat height = ((_questionDic.count * withdrawalTypeTabelCellHeight) > kTableViewHeight ? kTableViewHeight : (_questionDic.count * withdrawalTypeTabelCellHeight));
    //safeProblemsTableView  安全问题表
    CGRect withdrawalTypeTableViewRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), height);
    _withdrawalTypeTableView = [[UITableView alloc]initWithFrame:withdrawalTypeTableViewRect];
    _withdrawalTypeTableView.scrollEnabled = NO;
    [_withdrawalTypeTableView setDataSource:self];
    [_withdrawalTypeTableView setDelegate:self];
    [self addSubview:_withdrawalTypeTableView];
    [_withdrawalTypeTableView release];
    
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"金额";
        }else {
            cell.textLabel.text = @"彩金";
        }
        
        /********************** adjustment 控件调整 ***************************/
        CGFloat rightBtnIntervalRight = 40.0f;
        CGFloat rightBtnSize = 20.0f;
        /********************** adjustment end ***************************/
        
        //选择提示按钮
        CGRect rightBtnRect = CGRectMake(CGRectGetWidth(tableView.frame) - rightBtnIntervalRight, (withdrawalTypeTabelCellHeight - rightBtnSize) /2.0f, rightBtnSize, rightBtnSize);
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:rightBtnRect];
        [rightBtn setImage:[UIImage imageNamed:@"problem.png"] forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"problem_select.png"] forState:UIControlStateSelected];
        [rightBtn setTag:indexPath.row];
        [rightBtn addTarget:self action:@selector(selectProblem:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightBtn];
        
        if(_selectIndex1 == indexPath.row) {
            [rightBtn setSelected:YES];
            _previousSelectBtn = [rightBtn retain];
        }
    }
    
    return cell;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return withdrawalTypeTabelCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)[cell viewWithTag:indexPath.row];
    [self selectProblem:button];
}

#pragma mark -
#pragma mark -Customized(Action)
//点击选中按钮
- (void)selectProblem:(id)sender {
    [_previousSelectBtn setSelected:NO]; //将上次选中的button 状态变为未选中
    
    UIButton *btn = sender;
    [btn setSelected:YES];
    
    [self performSelector:@selector(fadeOut) withObject:nil afterDelay:0.2];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    UITableViewCell *cell = [_withdrawalTypeTableView cellForRowAtIndexPath:indexPath];
    if (_delegate && [_delegate respondsToSelector:@selector(listViewDidSelectedText:AtRowIndex:)]) {
        [_delegate withdrawalTypeSelectedText:cell.textLabel.text AtRowIndex:btn.tag];
    }
}

- (void)chickView {
    [_overlayView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark -Customized: Private (General)
//动画进入
- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.alpha = 0;
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.alpha = 1;
    self.transform = CGAffineTransformMakeScale(1, 1);
    [UIView commitAnimations];
}

//消失动画
- (void)fadeOut {
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView commitAnimations];
    
    [_overlayView removeFromSuperview];
    [self removeFromSuperview];
}

//显示视图
- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_overlayView];
    [keyWindow addSubview:self];
    [self setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
    
    [self fadeIn];
}

@end
