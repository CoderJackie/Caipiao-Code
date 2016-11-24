//
//  CustomAlertView.m
//  TicketProject
//
//  Created by KAI on 14-11-27.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "CustomAlertView.h"
#import "Globals.h"

#define titleLabelMinX 18.0f

@implementation CustomAlertView
@synthesize secondBackView = _secondBackView;
@synthesize titleLabel = _titleLabel;
@synthesize redLineView = _redLineView;
@synthesize delegate = _delegate;

- (id)initWithTitle:(NSString *)title delegate:(id<CustomAlertViewDelegate>)delegate content:(NSString *)content leftText:(NSString *)leftText rightText:(NSString *)rightText {//宽度和高度是固定的，两个按钮
    self = [super init];
    if (self) {
        _aroundShadowViewWidth = IS_PHONE ? 250.f : 375.0f;
        _aroundShadowViewHeight = IS_PHONE ? 124.0f : 192.0f;
        _title = [title copy];
        _delegate = delegate;
        _content = [content copy];
        _leftBtnText = [leftText copy];
        _rightBtnText = [rightText copy];
        _customView = NO;
        [self makeSubView];
        [self defaultAlertView];
        [self makeTwoButton];
        
    }
    return self;
}

- (id)initWithTitle:(NSString *)title delegate:(id<CustomAlertViewDelegate>)delegate content:(NSString *)content {//宽度和高度是固定的，只有一个按钮
    self = [super init];
    if (self) {
        _aroundShadowViewWidth = IS_PHONE ? 250.0f : 375.0f;
        _aroundShadowViewHeight = IS_PHONE ? 124.0f : 192.0f;
        _title = [title copy];
        _delegate = delegate;
        _content = [content copy];
        _contrastHeight = [self calculateContrastHeight];
        [self makeSubView];
        [self defaultAlertView];
        [self makeOneButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title delegate:(id<CustomAlertViewDelegate>)delegate { //自定义提示框，宽度高度是自定义的
    self = [super initWithFrame:frame];
    if (self) {
        _aroundShadowViewWidth = 268.f;
        _aroundShadowViewHeight = 168.5;
        _title = [title copy];
        _delegate = delegate;
        _customView = YES;
        [self makeSubView];
        [self makeTwoButton];
        
    }
    return self;
}

- (void)dealloc {
    [_overlayView release];
    _overlayView = nil;
    
    [_title release];
    [_content release];
    [_leftBtnText release];
    [_rightBtnText release];
    [super dealloc];
}

- (void)makeSubView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat titleLabelHeight = IS_PHONE ? 34.0f : 50.0f;
    
    CGFloat redLineHeight = IS_PHONE ? 1.0f : 2.0f;
    /********************** adjustment end ***************************/
    //overlayView
    if (!_overlayView) {
        _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:0.5];
    }
    
    
    CGRect selfRect = self.frame;
    
    if (!_customView) {
        
        
        selfRect = CGRectMake(0, 0, _aroundShadowViewWidth, _aroundShadowViewHeight + _contrastHeight);
        [self setFrame:selfRect];
        
    }
    
    [[self layer] setShadowOffset:CGSizeMake(1, 1)];
    [[self layer] setShadowOpacity:1];
    [[self layer] setShadowColor:[UIColor blackColor].CGColor];
    
    //secondBackView
    CGRect secondBackViewRect = CGRectMake(0, 0, CGRectGetWidth(selfRect),CGRectGetHeight(selfRect));
    _secondBackView = [[UIView alloc] initWithFrame:secondBackViewRect];
    [_secondBackView setBackgroundColor:[UIColor whiteColor]];
    [_secondBackView setClipsToBounds:YES];
    [_secondBackView setUserInteractionEnabled:YES];
    [self addSubview:_secondBackView];
    [_secondBackView release];
    
    //titleLabel
    CGRect titleLabelRect = CGRectMake(0, 0, CGRectGetWidth(secondBackViewRect) - titleLabelMinX, titleLabelHeight);
    _titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize15]];
    [_titleLabel setText:_title];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel setTextColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0]];
    [_secondBackView addSubview:_titleLabel];
    [_titleLabel release];
    
    //redLineView
    CGRect redLineViewRect = CGRectMake(0, CGRectGetMaxY(titleLabelRect), CGRectGetWidth(secondBackViewRect), redLineHeight);
    _redLineView = [[UIView alloc] initWithFrame:redLineViewRect];
    [_redLineView setBackgroundColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0]];
    [_secondBackView addSubview:_redLineView];
    [_redLineView release];
}

- (void)makeOneButton {
    /********************** adjustment 控件调整 ***************************/
    CGFloat bottomHeight = IS_PHONE ? 35.0f : 52.5f;
    /********************** adjustment end ***************************/
    //bottomSecondBtn
    CGRect bottomRightBtnRect = CGRectMake(0, CGRectGetHeight(_secondBackView.frame) - bottomHeight, CGRectGetWidth(_secondBackView.frame), bottomHeight);
    _bottomRightBtn = [[UIButton alloc] initWithFrame:bottomRightBtnRect];
    [_bottomRightBtn setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:159.0f/255.0f blue:29.0f/255.0f alpha:1.0f]];
    [_bottomRightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_bottomRightBtn setTitle:@"确定" forState:UIControlStateHighlighted];
    [_bottomRightBtn setTag:0];
    [_bottomRightBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBackView addSubview:_bottomRightBtn];
    [_bottomRightBtn release];
}

- (void)makeTwoButton {
    /********************** adjustment 控件调整 ***************************/
    CGFloat bottomHeight = IS_PHONE ? 35.0f : 52.5f;
    /********************** adjustment end ***************************/
    //bottomLeftBtn
    CGRect bottomLeftBtnRect = CGRectMake(0, CGRectGetHeight(_secondBackView.frame) - bottomHeight, CGRectGetWidth(_secondBackView.frame) / 2.0f, bottomHeight);
    _bottomLeftBtn = [[UIButton alloc] initWithFrame:bottomLeftBtnRect];
    [_bottomLeftBtn setBackgroundColor:[UIColor colorWithRed:138.0/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1.0f]];
    [_bottomLeftBtn setTitle:(_leftBtnText.length == 0 ? @"取消" : _leftBtnText) forState:UIControlStateNormal];
    [_bottomLeftBtn setTitle:(_leftBtnText.length == 0 ? @"取消" : _leftBtnText) forState:UIControlStateHighlighted];
    [_bottomLeftBtn setTag:0];
    [_bottomLeftBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBackView addSubview:_bottomLeftBtn];
    [_bottomLeftBtn release];
    
    //bottomSecondBtn
    CGRect bottomRightBtnRect = CGRectMake(CGRectGetMaxX(bottomLeftBtnRect), CGRectGetHeight(_secondBackView.frame) - bottomHeight, CGRectGetWidth(_secondBackView.frame) / 2.0f, bottomHeight);
    _bottomRightBtn = [[UIButton alloc] initWithFrame:bottomRightBtnRect];
    [_bottomRightBtn setBackgroundColor:[UIColor colorWithRed:251.0f/255.0f green:159.0f/255.0f blue:29.0f/255.0f alpha:1.0f]];
    [_bottomRightBtn setTitle:(_rightBtnText.length == 0 ? @"确定" : _rightBtnText) forState:UIControlStateNormal];
    [_bottomRightBtn setTitle:(_rightBtnText.length == 0 ? @"确定" : _rightBtnText) forState:UIControlStateHighlighted];
    [_bottomRightBtn setTag:1];
    [_bottomRightBtn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    [_secondBackView addSubview:_bottomRightBtn];
    [_bottomRightBtn release];
}

- (void)defaultAlertView {
    /********************** adjustment 控件调整 ***************************/
    CGFloat contentLabelHeight = ( IS_PHONE ? 50.0f : 80.0f) + _contrastHeight;
    /********************** adjustment end ***************************/
    CGRect redLineViewRect = _redLineView.frame;
    CGRect titleLabelRect = _titleLabel.frame;
    
    //contentLabel
    CGRect contentLabelRect = CGRectMake(titleLabelMinX, CGRectGetMaxY(redLineViewRect), CGRectGetWidth(titleLabelRect) - titleLabelMinX * 2, contentLabelHeight);
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:contentLabelRect];
    [contentLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [contentLabel setNumberOfLines:10];
    [contentLabel setText:_content];
    [_secondBackView addSubview:contentLabel];
    [contentLabel release];
}

- (void)selectButton:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (_delegate && [_delegate respondsToSelector:@selector(customAlertView:clickedButtonAtIndex:)]) {
        [_delegate customAlertView:self clickedButtonAtIndex:btn.tag];
    }
    [self fadeOut];
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

- (void)setBtnToFront {
    [_secondBackView bringSubviewToFront:_bottomLeftBtn];
    [_secondBackView bringSubviewToFront:_bottomRightBtn];
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:_overlayView];
    [keyWindow addSubview:self];
    
    [self setCenter:CGPointMake(keyWindow.bounds.size.width / 2, keyWindow.bounds.size.height / 2)];
    if (_customView) {
        [self setBtnToFront];
    }
    [self fadeIn];
}

- (CGFloat)calculateContrastHeight {
    NSString *contrastStr = @"彩色";
    CGSize contrastStrSize = [contrastStr sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]
                                     constrainedToSize:CGSizeMake(_aroundShadowViewWidth - titleLabelMinX * 2, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize contentSize = [_content sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]
                              constrainedToSize:CGSizeMake(_aroundShadowViewWidth - titleLabelMinX * 2, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    return contentSize.height - contrastStrSize.height;
}


@end
