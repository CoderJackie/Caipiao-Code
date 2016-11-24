//
//  SelectMixPassView.m 购彩大厅－竞彩投注－过关方式－选择混合过关方式（多串过关）
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//
//20141014 14:43（洪晓彬）：修改代码规范，改进生命周期
//20141014 15:05（洪晓彬）：进行ipad适配

#import "SelectMixPassView.h"
#import "MatchTypeButton.h"

#pragma mark -
#pragma mark @implementation SelectMixPassView
@implementation SelectMixPassView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = array;

        [self setupView];
    }
    return self;
}

- (void)dealloc {
    _scrollView = nil;
    [_items release];
    [_selectItemTags release];
    [_selectItems release];
    
    [super dealloc];
}

- (void)setupView {
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    [_scrollView release];
    
    /********************** adjustment 控件调整 ***************************/
    NSInteger lineItemCount = 4;//每行btn数量
    
    CGFloat passViewMaginLeftRight = IS_PHONE ? 10.0f : 20.0f;//整个选择视图与父视图的左右距离
    CGFloat passViewMaginTopBottom = IS_PHONE ? 13.0f : 7.0f; //整个选择视图与父视图的上下间距
    
    
    
    CGFloat selectBtnWidth = IS_PHONE ? 65.0 : 112.5f;
    CGFloat selectBtnLandscapeInterval = (CGRectGetWidth(self.frame) - passViewMaginLeftRight * 2 - selectBtnWidth * lineItemCount) / (lineItemCount - 1);
    CGFloat selectBtnVerticalInterval = IS_PHONE ? 7.5f : 15.0f;
    CGFloat selectBtnHeight = IS_PHONE ? 31.0f : 46.5f;
    /********************** adjustment end ***************************/
    
    int temp = 0;
    int lines = 0;
    for (int i = 0; i < _items.count; i++) {
        if(i % lineItemCount == 0 && i > 0) {
            lines ++;
            temp = 0;
        }
        
        //selectBtn
        CGRect selectBtnRect = CGRectMake(passViewMaginLeftRight + temp * (selectBtnLandscapeInterval + selectBtnWidth), passViewMaginTopBottom + lines * (selectBtnVerticalInterval + selectBtnHeight), selectBtnWidth, selectBtnHeight);
        MatchTypeButton *selectBtn = [[MatchTypeButton alloc] initWithFrame:selectBtnRect buttonType:MatchButtonTypeOfGou title:[_items objectAtIndex:i]];
        [selectBtn setTag:i + 1];
        [selectBtn addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:selectBtn];
        
        temp ++;
    }
    
    float height = passViewMaginTopBottom * 2 + (lines + 1.5) * (selectBtnVerticalInterval + selectBtnHeight);
    [_scrollView setContentSize:CGSizeMake(self.bounds.size.width, height)];
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)itemSelected:(id)sender {    
    MatchTypeButton *btn = sender;
    
    if([btn isSelected]) {
        [btn setSelected:NO];
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(mixPassButtonDidSelected)]) {
            [_delegate mixPassButtonDidSelected];
        }
        [btn setSelected:YES];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(mixPassButtonDidSelected)]) {
        [_delegate mixPassButtonDidSelected];
    }
}

#pragma mark -Customized: Private (General)
- (NSArray *)selectItems {
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[MatchTypeButton class]]) {
            MatchTypeButton *subBtn = (MatchTypeButton *)view;
            
            if([subBtn isSelected]) {
                [array addObject:[_items objectAtIndex:subBtn.tag - 1]];
            }
        }
    }
    
    return array;
}

- (NSArray *)selectItemTags {
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[MatchTypeButton class]]) {
            MatchTypeButton *subBtn = (MatchTypeButton *)view;
            
            if([subBtn isSelected]) {
                [array addObject:[NSString stringWithFormat:@"%ld",(long)subBtn.tag]];
            }
        }
    }
    
    return array;
}

- (void)updateSelectPassWay:(NSArray*)arr {
    for (NSString *str in arr) {
        if ([self.items containsObject:str]) {
            NSInteger index = [self.items indexOfObject:str];
            MatchTypeButton *btn = (MatchTypeButton*)[self viewWithTag:index+1];
            [btn setSelected:YES];
        }
    }
}

@end
