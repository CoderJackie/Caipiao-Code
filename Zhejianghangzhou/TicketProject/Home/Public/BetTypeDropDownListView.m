//
//  DropDownListView.m
//  TicketProject
//
//  Created by sls002 on 13-5-20.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//投注方式的下拉列表

#import "BetTypeDropDownListView.h"
#import "Globals.h"

#define kDropItemSize CGSizeMake(100,50)  //下拉列表每个item的尺寸

@implementation BetTypeDropDownListView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithBetTypes:(NSArray *)types {
    self = [super init];
    if (self) {
        // Initialization code
        betTypes = [types retain];
        [self setHidden:YES];
        self.isSeleced = NO;
        [self setFrame:CGRectMake(kWinSize.width - kDropItemSize.width, 0, kDropItemSize.width , AllLineWidthOrHeight + kDropItemSize.height* betTypes.count)];
        
        [self createDropDownListView];
    }
    return self;
}

- (void)dealloc {
    [betTypes release];
    [super dealloc];
}

- (void)createDropDownListView {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:scrollView];
    
    for (int i = 0; i < betTypes.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, i  * kDropItemSize.height + AllLineWidthOrHeight, kDropItemSize.width, kDropItemSize.height - AllLineWidthOrHeight)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [btn setTitle:[betTypes objectAtIndex:i] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"redButton.png"]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [btn setTag:i + 1];
        [btn setSelected:_isSeleced];
        [btn addTarget:self action:@selector(betTypeItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    [scrollView setContentSize:CGSizeMake(self.bounds.size.width, kDropItemSize.height * betTypes.count)];
    [scrollView release];
}

- (void)betTypeItemSelected:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:![btn isSelected]];
    self.isSeleced = btn.isSelected;
    [self.delegate itemSelectedObjects:btn.titleLabel.text AtRowIndexs:btn.tag - 1 isHidden:self.isSeleced];//委托调用
}

@end
