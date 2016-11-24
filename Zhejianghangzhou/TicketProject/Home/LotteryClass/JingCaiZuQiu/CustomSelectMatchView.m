//
//  CustomSelectMatchView.m 购彩大厅－竞彩－筛选－赛事选择视图
//  TicketProject
//
//  Created by sls002 on 13-6-28.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140920 09:11（洪晓彬）：修改代码规范，处理内存
//20140920 09:17（洪晓彬）：进行ipad适配

#import "CustomSelectMatchView.h"
#import "Globals.h"

#pragma mark -
#pragma mark @implementation CustomSelectMatchView
@implementation CustomSelectMatchView
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame MatchItems:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        _matchItems = [items retain];
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    _scrollView = nil;
    
    [_matchItems release];
    [_selectedMatchesDic release];
    
    [super dealloc];
}

- (void)setupView {
    /********************** adjustment 控件调整 ***************************/
    NSInteger checkBtnLineNumber = 3; //每行个数
    
    CGFloat checkBtnMinX = IS_PHONE ? 10.0f : 60.0f;
    CGFloat checkBtnVerticalMagin = IS_PHONE ? 7.5 : 15.0f;
    CGSize checkBtnSize = IS_PHONE ? CGSizeMake(95.0f, 31.0f) : CGSizeMake(180.0f, 55.0f);
    CGFloat checkBtnLandscapeMagin = (CGRectGetWidth(self.frame) - checkBtnSize.width * 3 - checkBtnMinX * 2) / 2.0f;
    /********************** adjustment end ***************************/
    //scrollView
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    [_scrollView release];
    
    
    int tempX = 0;
    for (int i = 0; i < _matchItems.count; i++) {
        int column = i / checkBtnLineNumber;
        if(i % checkBtnLineNumber == 0 && i > 0) {
            tempX = 0;
        }
        
        //checkBtn
        CGRect checkBtnRect = CGRectMake(checkBtnMinX + tempX * (checkBtnSize.width + checkBtnLandscapeMagin), checkBtnVerticalMagin + column * (checkBtnVerticalMagin + checkBtnSize.height), checkBtnSize.width, checkBtnSize.height);
        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBtn setFrame:checkBtnRect];
        [checkBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"ruleBlackLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateNormal];
        [checkBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateHighlighted];
        [checkBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [checkBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected | UIControlStateHighlighted];
        [checkBtn setTag:i];
        [checkBtn setSelected:YES];
        [checkBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [checkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [checkBtn setTitle:[_matchItems objectAtIndex:i] forState:UIControlStateNormal];
        [checkBtn setTitle:[_matchItems objectAtIndex:i] forState:UIControlStateSelected];
        [checkBtn addTarget:self action:@selector(checkButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:checkBtn];
        
        tempX ++;
    }
    
    NSInteger lines = _matchItems.count / checkBtnLineNumber;
    if(_matchItems.count % checkBtnLineNumber != 0) {
        lines ++;
    }
    float height = (checkBtnVerticalMagin + checkBtnSize.height) * lines + 5.0f;
    
    [_scrollView setContentSize:CGSizeMake(self.bounds.size.width, height)];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)checkButtonSelected:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:![btn isSelected]];
}

#pragma mark -Customized: Private (General)
//获取已选的比赛
- (NSMutableDictionary *)selectedMatchesDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    _selectMatchText = [NSMutableArray array];
    _selectMatchTags = [NSMutableArray array];
    
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if ([btn isSelected]) {
                [_selectMatchText addObject:[_matchItems objectAtIndex:btn.tag]];
                [_selectMatchTags addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag+1]];
            }
        }
    }
    [dic setObject:_selectMatchText forKey:@"selectText"];
    [dic setObject:_selectMatchTags forKey:@"selectTags"];
    return dic;
}

//反选按钮
- (void)selectedFan {
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view ;
            [btn setSelected:![btn isSelected]];
        }
    }
}

//按传入的数组选择
- (void)setSelectedMatches:(NSDictionary *)selectedMatchesDic {
    if ([selectedMatchesDic count] == 0) {
        return;
    }
    NSArray *selectTagArray = [selectedMatchesDic objectForKey:@"selectTags"];
    
    for (NSString *str in selectTagArray) {
        for (UIView *view in _scrollView.subviews) {
            UIButton *btn = (UIButton *)[view viewWithTag:[str intValue] - 1];
            if(btn != nil && [btn isKindOfClass:[UIButton class]])
                [btn setSelected:NO];
        }

    }
    [self selectedFan];
}

//全选
- (void)selectAllMatch {
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setSelected:YES];
        }
    }
}

//全不选
- (void)selectNon {
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            [btn setSelected:NO];
        }
    }
}

@end
