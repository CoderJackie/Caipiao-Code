//
//  SelectLotteryNameDialogView.m 合买大厅彩种筛选
//  TicketProject
//
//  Created by sls002 on 13-7-29.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140723 16:26（洪晓彬）：少部分修改代码规范，，处理内存
//20140806 14:18（洪晓彬）：进行ipad适配

#import "SelectLotteryNameDialogView.h"
#import "InterfaceHelper.h"
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>

@implementation SelectLotteryNameDialogView
@synthesize nameArray = _nameArray;
@synthesize idArray = _idArray;

- (id)initWithPlayMethodNames:(NSArray *)playNames lottery:(NSString *)lotteryName withIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        [self setHidden:YES];
        [self setFrame:CGRectMake(0, 0, kWinSize.width, kWinSize.height)];
        [self createPlayMethodButtonView:playNames withIndex:index];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [tap setCancelsTouchesInView:NO];
        [self addGestureRecognizer:tap];
        [tap release];
    }
    return self;
}

-(void)dealloc {
    [_nameArray release];
    _nameArray = nil;
    [_idArray release];
    _idArray = nil;
    _overlayView = nil;
    [super dealloc];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self setHidden:YES];
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

- (void)createPlayMethodButtonView:(NSArray *)playMethodNames withIndex:(NSInteger)index {
    /********************** adjustment 控件调整 ***************************/
    CGFloat contentViewMinX = 0.0f;
    CGFloat contentViewWidth = kScreenSize.width - contentViewMinX * 2;
    CGFloat contentViewRawHeight = IS_PHONE ? 40.0f : 60.0f;
    
    CGFloat buttonWidth = contentViewWidth / 3.f + 0.5;
    CGFloat buttonHeight = contentViewRawHeight - 5.0f;
    /********************** adjustment end ***************************/
    NSArray *array = [[InterfaceHelper getLotteryIDNameDic] objectForKey:@"name"];
    _nameArray = [[NSMutableArray alloc]init];
    [_nameArray addObject:@"全部"];
    [_nameArray addObjectsFromArray:array];
    
    _idArray = [[NSMutableArray alloc] init];
    NSArray *array1 = [[InterfaceHelper getLotteryIDNameDic] objectForKey:@"id"];
    [_idArray addObject:@"0"];
    [_idArray addObjectsFromArray:array1];
//
    UIButton *frontButton = nil;
    for (NSInteger buttonTag = 0; buttonTag < [_nameArray count]; buttonTag++) {
        NSInteger row = (buttonTag) / 3;
        NSInteger column = (buttonTag) % 3;
        CGRect btn2Rect = CGRectMake(column * (buttonWidth - AllLineWidthOrHeight), IncreaseNavHeight + row * (buttonHeight - AllLineWidthOrHeight), buttonWidth, buttonHeight);
        
        UIButton *btn2 = [[UIButton alloc] initWithFrame:btn2Rect];
        [btn2 setAdjustsImageWhenHighlighted:NO];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"singleMatchNormalBtn.png"] forState:UIControlStateNormal];
        [btn2 setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [btn2 setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected | UIControlStateHighlighted];
        [btn2.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [btn2.layer setBorderColor:[UIColor colorWithRed:0x99/255.0f green:0x99/255.0 blue:0x99/255.0f alpha:1.0f].CGColor];
        [btn2.layer setBorderWidth:AllLineWidthOrHeight];
        [btn2 setTitle:[_nameArray objectAtIndex:buttonTag] forState:UIControlStateNormal];
        [btn2 setTag:buttonTag];
        if (buttonTag == index) {
            [btn2 setSelected:YES];
            [btn2.layer setBorderWidth:0.0f];
            [frontButton release];
            frontButton = [btn2 retain];
        }
        [btn2 addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn2];
        [btn2 release];
    }
    
    if ([frontButton isKindOfClass:[UIButton class]]) {
        [self bringSubviewToFront:frontButton];
        [frontButton release];
    }
}

- (void)buttonSelect:(UIButton *)btn {
    for (UIView *view in btn.superview.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setSelected:NO];
            [button.layer setBorderWidth:AllLineWidthOrHeight];
        }
    }
    [btn.layer setBorderWidth:0.0];
    [btn setSelected:YES];
    [self bringSubviewToFront:btn];
    if ([self.delegate respondsToSelector:@selector(itemSelectedObject:AtRowIndex:)])
        [self.delegate itemSelectedObject:nil AtRowIndex:btn.tag];
    [self setHidden:YES];
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

-(void)show {
    _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_overlayView setBackgroundColor:[UIColor blackColor]];
    [_overlayView setAlpha:0.5];
    
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    [_keyWindow addSubview:_overlayView];
    [_keyWindow addSubview:self];
    [_overlayView release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [tap setCancelsTouchesInView:NO];
    [_overlayView addGestureRecognizer:tap];
    [tap release];
}

@end
