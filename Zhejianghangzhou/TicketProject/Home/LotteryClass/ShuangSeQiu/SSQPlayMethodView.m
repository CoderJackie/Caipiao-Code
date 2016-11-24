//
//  SSQPlayMethodView.m 购彩大厅－购彩详细－玩法选择框
//  TicketProject
//
//  Created by eims on 14-7-3.
//  Copyright (c) 2014年 sls002. All rights reserved.
//
//20140913 09:21（洪晓彬）：修改代码规范，改进生命周期
//20140913 09:25（洪晓彬）：进行ipad适配

#import "SSQPlayMethodView.h"

#import "Globals.h"

@implementation SSQPlayMethodView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithPlayMethodNames:(NSArray *)playNames lottery:(NSString *)lotteryName withIndex:(NSInteger)index{
    self = [super init];
    if (self) {
        [self setHidden:YES];
        [self setFrame:CGRectMake(0, 0, kWinSize.width, kWinSize.height - 44)];
        [self createOverlayView];
        [self createPlayMethodButtonView:playNames withIndex:index];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
        [tap release];
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self setHidden:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(tapBackView)]) {
        [_delegate tapBackView];
    }
}

- (void)createOverlayView {
    //overlayView
    _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_overlayView setBackgroundColor:[UIColor blackColor]];
    [_overlayView setAlpha:0.2];
    [self addSubview:_overlayView];
    [_overlayView release];
}

- (void)createPlayMethodButtonView:(NSArray *)playMethodNames withIndex:(NSInteger)index {
    /********************** adjustment 控件调整 ***************************/
    CGFloat contentViewMinX = 0.0f;
    CGFloat contentViewWidth = kScreenSize.width - contentViewMinX * 2;
    CGFloat contentViewRawHeight = IS_PHONE ? 40.0f : 60.0f;
    
    CGFloat buttonWidth = contentViewWidth / 3.f + 0.5;
    CGFloat buttonHeight = contentViewRawHeight - 5.0f;
    /********************** adjustment end ***************************/
    
    CGRect contentViewRect;
    if (playMethodNames.count == 2) {
        buttonWidth = contentViewWidth / 2.f + 0.5;
        contentViewRect = CGRectMake(contentViewMinX, 0, contentViewWidth, (playMethodNames.count / 2 + playMethodNames.count % 2) * contentViewRawHeight);
    } else {
        contentViewRect = CGRectMake(contentViewMinX, 0, contentViewWidth, (playMethodNames.count / 3 + playMethodNames.count % 3) * contentViewRawHeight);
    }
    
    
    _contentView = [[UIView alloc]initWithFrame:contentViewRect];
    [[_contentView layer] setShadowOffset:CGSizeMake(1, 1)];
    [[_contentView layer] setShadowOpacity:1];
    [[_contentView layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [self addSubview:_contentView];
    [_contentView release];
    
    //whiteView
    NSInteger line = playMethodNames.count / 3 + (playMethodNames.count % 3 > 0 ? 1 : 0);
    CGRect whiteViewRect = CGRectMake(0, 0, CGRectGetWidth(_contentView.frame), line * buttonHeight - 0.5 * (line - 1));
    UIView *whiteView = [[UIView alloc] initWithFrame:whiteViewRect];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [_contentView addSubview:whiteView];
    [whiteView release];
    
    //lineView
    CGRect lineViewRect = CGRectMake(0, CGRectGetHeight(whiteViewRect) - AllLineWidthOrHeight, CGRectGetWidth(whiteViewRect), AllLineWidthOrHeight);
    UIView *lineView = [[UIView alloc] initWithFrame:lineViewRect];
    [lineView setBackgroundColor:[UIColor colorWithRed:0x99/255.0f green:0x99/255.0 blue:0x99/255.0f alpha:1.0f]];
    [whiteView addSubview:lineView];
    [lineView release];
    
    UIButton *frontButton = nil;
    for (NSInteger i = 0; i < playMethodNames.count; i++) {
        NSInteger row = i / 3;
        NSInteger column = i % 3;
        
        //button
        CGRect buttonFrame = CGRectMake(column * (buttonWidth - AllLineWidthOrHeight), row * (buttonHeight - AllLineWidthOrHeight), buttonWidth, buttonHeight);
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        [button setTag:i];
        [button setAdjustsImageWhenHighlighted:NO];
        [button.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [button.layer setBorderColor:[UIColor colorWithRed:0x99/255.0f green:0x99/255.0 blue:0x99/255.0f alpha:1.0f].CGColor];
        [button.layer setBorderWidth:AllLineWidthOrHeight];
        [button setTitle:[playMethodNames objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitle:[playMethodNames objectAtIndex:i] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"singleMatchNormalBtn.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected];
        [button setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowLineButton.png"]] stretchableImageWithLeftCapWidth:2.0f topCapHeight:2.0f] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:button];
        [button release];
        if (i == index) {
            frontButton = [button retain];
            [button.layer setBorderWidth:0.0f];
            [button setSelected:YES];
            
        }
    }
    if ([frontButton isKindOfClass:[UIButton class]]) {
        [_contentView bringSubviewToFront:frontButton];
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
    [_contentView bringSubviewToFront:btn];
    
    if (_delegate && [_delegate respondsToSelector:@selector(itemSelectedObject:AtRowIndex:)]) {
        [_delegate itemSelectedObject:nil AtRowIndex:btn.tag];
    }
}


@end
