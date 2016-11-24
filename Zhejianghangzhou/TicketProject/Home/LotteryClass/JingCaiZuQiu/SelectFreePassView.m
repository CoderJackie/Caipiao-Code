//
//  SelectFreePassView.m 购彩大厅－竞彩投注－过关方式－选择自由过关方式
//  TicketProject
//
//  Created by sls002 on 13-7-2.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//
//20141014 14:23（洪晓彬）：修改代码规范，改进生命周期
//20141014 14:55（洪晓彬）：进行ipad适配

#import "SelectFreePassView.h"
#import "MatchTypeButton.h"

#pragma mark -
#pragma mark @implementation SelectFreePassView
@implementation SelectFreePassView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = array;
        [self setupView];
        [self setClipsToBounds:YES];
        
    }
    return self;
}

- (void)dealloc {
    [_items release];
    [_selectItems release];
    [_selectItemTags release];
    
    [super dealloc];
}

- (void)setupView {
    
    /********************** adjustment 控件调整 ***************************/
    NSInteger lineItemCount = 4;//每行btn数量
    
    CGFloat passViewMaginLeftRight = IS_PHONE ? 10.0f : 20.0f;//整个选择视图与父视图的左右距离
    CGFloat passViewMaginTopBottom = IS_PHONE ? 10.0f : 14.0f; //整个选择视图与父视图的上下间距
    
    CGFloat selectBtnWidth = IS_PHONE ? 65.0 : 112.5f;
    CGFloat selectBtnLandscapeInterval = (CGRectGetWidth(self.frame) - passViewMaginLeftRight * 2 - selectBtnWidth * lineItemCount) / (lineItemCount - 1);
    CGFloat selectBtnVerticalInterval = IS_PHONE ? 7.5f : 15.0f;
    CGFloat selectBtnHeight = IS_PHONE ? 31.0f : 46.5f;
    /********************** adjustment end ***************************/
    int lines = 0;
    int temp = 0;
    for (int i = 0; i < _items.count; i++) {
        if(i % lineItemCount == 0 && i > 0) {
            lines ++;
            temp = 0;
        }
        
        CGRect checkBtnRect = CGRectMake(passViewMaginLeftRight + temp * (selectBtnLandscapeInterval + selectBtnWidth), passViewMaginTopBottom + lines * (selectBtnVerticalInterval + selectBtnHeight), selectBtnWidth, selectBtnHeight);
        MatchTypeButton *btn = [[MatchTypeButton alloc] initWithFrame:checkBtnRect buttonType:MatchButtonTypeOfGou title:[_items objectAtIndex:i]];
        [btn addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:i + 1];
        [self addSubview:btn];
        [btn release];
        
        temp++;
    }
    
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)itemSelected:(id)sender {
    MatchTypeButton *btn = sender;
    
    if([btn isSelected]) {
        [btn setSelected:NO];
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(freePassButtonDidSelected)]) {
            [_delegate freePassButtonDidSelected];
        }
        [btn setSelected:YES];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(freePassButtonDidSelected)]) {
        [_delegate freePassButtonDidSelected];
    }
}

#pragma mark -Customized: Private (General)
- (NSArray *)selectItems {
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if([view isKindOfClass:[MatchTypeButton class]]) {
            MatchTypeButton *btn = (MatchTypeButton *)view;
            if([btn isSelected]) {
                [array addObject:[_items objectAtIndex:btn.tag - 1]];
            }
        }
    }
    
    return array;
}

//选中的过关方式的 按钮tag   用于反选的时候锁定
- (NSArray *)selectItemTags {
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if([view isKindOfClass:[MatchTypeButton class]]) {
            MatchTypeButton *btn = (MatchTypeButton *)view;
            if([btn isSelected]) {
                [array addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
            }
        }
    }
    
    return array;
}

- (void)updateSelectPassWay:(NSArray*)arr {
    for (NSString *str in arr) {
        if ([self.items containsObject:str]) {
            NSInteger index = [self.items indexOfObject:str];
            MatchTypeButton *btn = (MatchTypeButton*)[self viewWithTag:index + 1];
            [btn setSelected:YES];
        }
    }
}

@end
