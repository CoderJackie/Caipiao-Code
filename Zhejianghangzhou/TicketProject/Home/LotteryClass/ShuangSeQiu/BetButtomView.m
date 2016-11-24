//
//  TogetherBuyButtomView.m 购彩大厅－投注－底部视图
//  TicketProject
//
//  Created by sls002 on 13-5-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140925 17:58（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140926 09:03（洪晓彬）：ipad适配

#import "BetButtomView.h"

#import "Globals.h"

@implementation BetButtomView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithBackImage:(UIImage *)image {
    self = [super init];
    if(self) {
        _backImage = [image retain];
        [self setFrame:CGRectMake(0, kWinSize.height - kBottomHeight -44, kWinSize.width, kBottomHeight)];
        [self createSubViews];
    }
    return self;
}

- (void)dealloc {
    [_backImage release];
    
    _betCountLabel = nil;
    
    [super dealloc];
}

- (void)createSubViews {
    /********************** adjustment 控件调整 ***************************/
    CGFloat shadeHeight = 3.0f;
    
    CGFloat btnMarginLeftRight = IS_PHONE ? 6.0f : 10.0f;
    CGFloat leftBtnWidth = IS_PHONE ? 70.0f : 105.0f;
    CGFloat reightBtnWidth = IS_PHONE ? 55.0f :82.5f;
    CGFloat btnHeight = IS_PHONE ? 28.0f : 40.0f;
    CGFloat btnMinY = (CGRectGetHeight(self.frame) - btnHeight) / 2.0f;
    
    CGFloat labelWidth = kWinSize.width - btnMarginLeftRight * 2 - leftBtnWidth - reightBtnWidth;
    CGFloat labelHeihgt = IS_PHONE ? 17.0f : 26.0f;
    CGFloat labelInterval = IS_PHONE ? 2.0f : 4.0f;
    /********************** adjustment end ***************************/
    //shadeImageView
    CGRect shadeImageViewRect = CGRectMake(0, -shadeHeight, kWinSize.width, shadeHeight);
    UIImageView *shadeImageView = [[UIImageView alloc] initWithFrame:shadeImageViewRect];
    [shadeImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shade.png"]]];
    [self addSubview:shadeImageView];
    [shadeImageView release];
    
    //leftBtn 发起合买
    CGRect leftBtnRect = CGRectMake(btnMarginLeftRight, btnMinY, leftBtnWidth, btnHeight);
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:leftBtnRect];
    [leftBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn setTitle:@"发起复制" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    [leftBtn release];
    
    CGRect checkBtnRect = CGRectMake(CGRectGetMaxX(leftBtn.frame)+5, leftBtn.frame.origin.y, leftBtn.frame.size.height,leftBtn.frame.size.height);
    _checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
    [_checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton_Normal.png"]] forState:UIControlStateNormal];
    [_checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
    _checkBtn.tag = 10086;
    [_checkBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
//    [checkBtn setSelected:self.isZhuiQiStop];
    [self addSubview:_checkBtn];
    [_checkBtn release];
    
    
    //betCountLabel
    CGRect betCountLabelRect = CGRectMake(CGRectGetMaxX(leftBtnRect), (CGRectGetHeight(self.frame) - labelHeihgt * 2 - labelInterval) / 2.0f, labelWidth, labelHeihgt);
    _betCountLabel = [[CustomLabel alloc]initWithFrame:betCountLabelRect];
    [_betCountLabel setTextAlignment:NSTextAlignmentCenter];
    [_betCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [_betCountLabel setBackgroundColor:[UIColor clearColor]];
    [_betCountLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:_betCountLabel];
    [_betCountLabel release];
    
    
    //rightBtn 付款按钮
    CGRect rightBtnRect = CGRectMake(kWinSize.width - btnMarginLeftRight - reightBtnWidth, btnMinY, reightBtnWidth, btnHeight);
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:rightBtnRect];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitle:@"付款" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    [rightBtn release];
}
-(void)zhuiQiSelected:(UIButton *)sender
{
    UIButton *btn = (UIButton *)[self viewWithTag:10086];
    btn.selected = !btn.selected;
    NSString *str;
    if (btn.selected == YES) {
        str  = @"true";
    }else{
        str = @"";
    }
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:str,@"textOne", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"tongzhi" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];

}
//清除
- (void)leftBtnTouchUpInside:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(showAlertViewAndClear)]) {
        [_delegate showAlertViewAndClear];
    }
}

//确认付款
- (void)submit:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(payMoney)]) {
        [_delegate payMoney];
    }
}

- (void)setBetCountLabelText:(NSString *)text {
}

- (void)setBetAccountLabelText:(NSString *)text {
}

- (void)setCount:(NSInteger)count money:(NSInteger)money {
    NSString *text = [NSString stringWithFormat:@"<font color=\"black\">共</font><font color=\"%@\">%ld</font><font color=\"black\">注 </font><font color=\"%@\">%ld</font><font color=\"black\">元</font>",tRedColorText,(long)count,tRedColorText,(long)money];
    MarkupParser *p = [[MarkupParser alloc]init];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    [_betCountLabel setAttString:attString];
    [p release];
    
    CGSize betCountLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize14];
    CGRect betCountLabelRect = _betCountLabel.frame;
    
    [_betCountLabel setFrame:CGRectMake((CGRectGetWidth(self.frame) - betCountLabelSize.width) / 2.0f, (CGRectGetHeight(self.frame) - betCountLabelSize.height) / 2.0f, betCountLabelSize.width + 10, CGRectGetHeight(betCountLabelRect) + 5)];
    
    
    [_betCountLabel setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if(_backImage) {
        [_backImage drawInRect:rect];
    } else {
        [super drawRect:rect];
    }
}

- (void)didSelcet_once {
    [self zhuiQiSelected:nil];
}

@end
