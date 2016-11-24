//
//  DialogFilterMatchView.m 竞彩－赛事筛选
//  TicketProject
//
//  Created by sls002 on 13-6-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140920 09:38（洪晓彬）：修改代码规范，处理内存
//20140920 09:54（洪晓彬）：进行ipad适配

#import "DialogFilterMatchView.h"
#import "CustomSelectMatchView.h"

#import "Globals.h"

#pragma mark -
#pragma mark @implementation DialogFilterMatchView
@implementation DialogFilterMatchView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame MatchItems:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        _matchItems = [items retain];
        _selectLetBallType = 0;
    
        [self createSubViews];
    }
    return self;
}

- (void)dealloc {
    [_overlayView release];
    [_matchItems release];
    [_filterMatchDic release];
    
    [super dealloc];
}

-(void)createSubViews {
    /********************** adjustment 控件调整 ***************************/
    CGFloat titleLabelHeight = IS_PHONE ? 34.0f : 50.0f;
    
    CGFloat redLineHeight = IS_PHONE ? 1.0f : 2.0f;
    
    
    CGFloat selectAllOrInvertSelectBtnWidth = IS_PHONE ? 150.0f : 300.0f;
    CGFloat selectAllOrInvertSelectBtnHeight = IS_PHONE ? 30.0f : 50.0f;
    CGFloat selectAllOrInvertSelectBtnMinX = (kWinSize.width - selectAllOrInvertSelectBtnWidth * 2) / 2.0f;
    CGFloat selectAllOrInvertSelectBtnAddY = IS_PHONE ? 11.0f : 20.0f;
    
    CGFloat okCancelBtnInterval = IS_PHONE ? 0 : 10.0f;
    CGFloat okCancelBtnIntervalBottom = IS_PHONE ? 0.0 : 20.0f;
    CGFloat okCancelBtnWidth = IS_PHONE ? 160.0 : 320.0f;
    CGFloat okCancelBtnHeight = IS_PHONE ? 35.0f : 50.0f;
    
    CGFloat selectMatchViewMinX = IS_PHONE ? 0.0f : 10.0f;
    CGFloat selectMatchViewAddY = 4.5f;
    /********************** adjustment end ***************************/
    //overlayView
    _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_overlayView setBackgroundColor:[UIColor blackColor]];
    [_overlayView setAlpha:0.5];
    
    //backView
    UIImageView *backView = [[UIImageView alloc]initWithFrame:self.bounds];
    [backView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:backView];
    [backView release];
    
    //titleLabel
    CGRect titleLabelRect = CGRectMake(0, 0, self.bounds.size.width, titleLabelHeight);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleLabelRect];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize14]];
    [titleLabel setText:@"赛事选择"];
    [titleLabel setTextColor:kRedColor];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:titleLabel];
    [titleLabel release];
    
    //redLineView 红线
    CGRect redLineViewRect = CGRectMake(0, CGRectGetMaxY(titleLabelRect), CGRectGetWidth(self.bounds), redLineHeight);
    UIView *redLineView = [[UIView alloc] initWithFrame:redLineViewRect];
    [redLineView setBackgroundColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0]];
    [self addSubview:redLineView];
    [redLineView release];
    
    //selectAllBtn
    CGRect selectAllBtnRect = CGRectMake(selectAllOrInvertSelectBtnMinX, CGRectGetMaxY(redLineViewRect) + selectAllOrInvertSelectBtnAddY, selectAllOrInvertSelectBtnWidth, selectAllOrInvertSelectBtnHeight);
    UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllBtn setFrame:selectAllBtnRect];
    [selectAllBtn.layer setBorderWidth:AllLineWidthOrHeight];
    [selectAllBtn.layer setBorderColor:[UIColor colorWithRed:0xd5/255.0f green:0xd5/255.0f blue:0xd5/255.0f alpha:1.0f].CGColor];
    [selectAllBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [selectAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectAllBtn setTitleColor:kYellowColor forState:UIControlStateHighlighted];
    [selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllBtn addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:selectAllBtn];
    
    //invertSelectBtn
    CGRect invertSelectBtnRect = CGRectMake(CGRectGetMaxX(selectAllBtnRect) - AllLineWidthOrHeight, CGRectGetMinY(selectAllBtnRect), selectAllOrInvertSelectBtnWidth, selectAllOrInvertSelectBtnHeight);
    UIButton *invertSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [invertSelectBtn setFrame:invertSelectBtnRect];
    [invertSelectBtn.layer setBorderWidth:AllLineWidthOrHeight];
    [invertSelectBtn.layer setBorderColor:[UIColor colorWithRed:0xd5/255.0f green:0xd5/255.0f blue:0xd5/255.0f alpha:1.0f].CGColor];
    [invertSelectBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [invertSelectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [invertSelectBtn setTitleColor:kYellowColor forState:UIControlStateHighlighted];
    [invertSelectBtn setTitle:@"反选" forState:UIControlStateNormal];
    [invertSelectBtn addTarget:self action:@selector(invertSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:invertSelectBtn];
    
    //selectMatchView
    CGRect selectMatchViewRect = CGRectMake(selectMatchViewMinX, CGRectGetMaxY(selectAllBtnRect) + selectMatchViewAddY, self.bounds.size.width - selectMatchViewMinX * 2, CGRectGetHeight(self.frame) - CGRectGetMaxY(selectAllBtnRect) - selectMatchViewAddY - okCancelBtnHeight - okCancelBtnIntervalBottom);
    _selectMatchView = [[CustomSelectMatchView alloc]initWithFrame:selectMatchViewRect MatchItems:_matchItems];
    [self addSubview:_selectMatchView];
    [_selectMatchView release];
    
    
    //cancelBtn
    CGRect cancelBtnRect = CGRectMake(self.center.x - okCancelBtnInterval / 2.0f - okCancelBtnWidth,self.bounds.size.height - okCancelBtnIntervalBottom - okCancelBtnHeight , okCancelBtnWidth, okCancelBtnHeight);
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:cancelBtnRect];
    [cancelBtn setAdjustsImageWhenHighlighted:NO];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xd5/255.0f green:0xd5/255.0f blue:0xd5/255.0f alpha:1.0f]] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xd5/255.0f green:0xd5/255.0f blue:0xd5/255.0f alpha:1.0f]] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    //okBtn
    CGRect okBtnRect = CGRectMake(self.center.x + okCancelBtnInterval, CGRectGetMinY(cancelBtnRect), okCancelBtnWidth, okCancelBtnHeight);
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setFrame:okBtnRect];
    [okBtn setAdjustsImageWhenHighlighted:NO];
    [okBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn setBackgroundImage:[UIImage imageWithColor:kYellowColor] forState:UIControlStateNormal];
    [okBtn setBackgroundImage:[UIImage imageWithColor:kYellowColor] forState:UIControlStateHighlighted];
    [okBtn addTarget:self action:@selector(okClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okBtn];
    
}

#pragma mark -
#pragma mark -Delegate

#pragma mark -
#pragma mark -Customized(Action)
//全选
- (void)selectAll:(id)sender {
    [_selectMatchView selectAllMatch];
}

//反选
- (void)invertSelect:(id)sender {
    [_selectMatchView selectedFan];
}

//确定
- (void)okClick:(id)sender {
    if (!_selectMatchView.selectedMatchesDic || [(NSArray *)[_selectMatchView.selectedMatchesDic objectForKey:@"selectTags"] count] == 0) {
        [XYMPromptView defaultShowInfo:@"请至少选择一场赛事" isCenter:YES];
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(filterMatchesWithType:MatchDictionary:)]) {
        [_delegate filterMatchesWithType:_selectLetBallType MatchDictionary:_selectMatchView.selectedMatchesDic];
    }
    [self fadeOut];
}

//取消
- (void)cancelClick:(id)sender {
    [self fadeOut];
}

#pragma mark -Customized: Private (General)
- (void)setFilterMatchDic:(NSDictionary *)filterMatchDic {
    if(![filterMatchDic isEqualToDictionary:_filterMatchDic]) {
        [_filterMatchDic release];
        _filterMatchDic = [filterMatchDic retain];
        
        [_selectMatchView setSelectedMatches:_filterMatchDic];
    }
}

- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.alpha = 0;
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.transform = CGAffineTransformMakeScale(1, 1);
    self.alpha = 1;
    [UIView commitAnimations];
    
}

- (void)fadeOut {
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.alpha = 0;
    [UIView commitAnimations];
    
    [_overlayView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:_overlayView];
    [keyWindow addSubview:self];
    [self fadeIn];
}

@end
