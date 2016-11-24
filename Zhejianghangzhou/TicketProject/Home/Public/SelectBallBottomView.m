//
//  BottomView.m  购彩大厅－选号详细－底部视图
//  TicketProject
//
//  Created by sls002 on 13-5-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140912 09:56（洪晓彬）：修改代码规范，处理内存
//20140912 10:00（洪晓彬）：进行ipad适配

#import "SelectBallBottomView.h"

#import "Globals.h"

#define kButtonSize (IS_PHONE ? CGSizeMake(50, 30) : CGSizeMake(80, 40))
#define kMarginLeftRight (IS_PHONE ? 6 : 10)
#define kMarginTopBottom (IS_PHONE ? 6 : 10)

@implementation SelectBallBottomView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setFrame:CGRectMake(0, kWinSize.height - kBottomHeight - kNavigationBarHeight, kWinSize.width, kBottomHeight)];
        [self createSubViews];
    }
    return self;
}

- (id)initWithBackImage:(UIImage *)image{
    self = [super init];
    if(self) {
        _backImage = [image retain];
        [self setFrame:CGRectMake(0, kWinSize.height - kBottomHeight - kNavigationBarHeight, kWinSize.width, kBottomHeight)];
        [self createSubViews];
    }
    return self;
}

- (void)dealloc {
    [_backImage release];
    _backImage = nil;
    
    _betCountLabel = nil;
    
    [super dealloc];
}

//配置view
- (void)createSubViews {
    CGFloat shadeHeight = IS_PHONE ? 3.0f : 6.0f;
    
    CGFloat labelWidht = IS_PHONE ? 90.0f : 150.0f;
    CGFloat LabelHeight = IS_PHONE ? 18.0 : 23.0f;
    
    CGFloat lineImageViewMinX = IS_PHONE ? 60.0f : 100.0f;
    CGFloat lineImageViewMinY = IS_PHONE ? 6.0f : 12.0f;
    CGFloat lineImageViewWidth = IS_PHONE ? 1.0f : 2.0f;
    /********************** adjustment end ***************************/
    
    
    //contentLabel
    CGRect contentLabelRect = CGRectMake((kWinSize.width - labelWidht) / 2.0f + 20.0f, (CGRectGetHeight(self.frame) - LabelHeight) / 2.0f, labelWidht, LabelHeight);
    _betCountLabel = [[CustomLabel alloc]initWithFrame:contentLabelRect];
    [_betCountLabel setTextAlignment:NSTextAlignmentCenter];
    [_betCountLabel setBackgroundColor:[UIColor clearColor]];
    [_betCountLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    _betCountLabel.textColor = [UIColor blackColor];
    [self addSubview:_betCountLabel];
    [_betCountLabel release];
    
    //leftBtn 清空按钮
    CGRect leftBtnRect = CGRectMake(kMarginLeftRight, kMarginTopBottom, kButtonSize.width, kButtonSize.height);
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:leftBtnRect];
    [leftBtn setTitle:@"清空" forState:UIControlStateNormal];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    [leftBtn release];
    
    //shadeImageView
    CGRect shadeImageViewRect = CGRectMake(0, -shadeHeight, kWinSize.width, shadeHeight);
    UIImageView *shadeImageView = [[UIImageView alloc] initWithFrame:shadeImageViewRect];
    [shadeImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shade.png"]]];
    [self addSubview:shadeImageView];
    [shadeImageView release];
    
    
    CGRect lineImageViewRect = CGRectMake(lineImageViewMinX, lineImageViewMinY, lineImageViewWidth, CGRectGetHeight(self.frame) - lineImageViewMinY * 2);
    UIView *lineView = [[UIView alloc] initWithFrame:lineImageViewRect];
    [lineView setBackgroundColor:[UIColor colorWithRed:0xdc/255.0f green:0xdc/255.0f blue:0xdc/255.0f alpha:1.0f]];
    [self addSubview:lineView];
    [lineView release];
    
    //rightBtn 选好了按钮
    CGRect rightBtnRect = CGRectMake(kWinSize.width - kMarginLeftRight - kButtonSize.width, kMarginTopBottom, kButtonSize.width, kButtonSize.height);
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:rightBtnRect];
    [rightBtn setTitle:@"选好了" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    [rightBtn release];
}

//清除
- (void)clear:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(clearBalls)]) {
        [_delegate clearBalls];
    }
}

//确认提交
- (void)submit:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(submitBalls)]) {
        [_delegate submitBalls];
    }
}

- (void)setbetCountLabelText:(NSString *)text {
    [_betCountLabel setText:text];
}

- (void)setbetCountLabelCenterAddX:(CGFloat)x AddY:(CGFloat)y {
    _betCountLabel.center = CGPointMake(_betCountLabel.center.x + x, _betCountLabel.center.y + y);
}

- (void)drawRect:(CGRect)rect {
    if(_backImage) {
        [_backImage drawInRect:rect];
    } else {
        [super drawRect:rect];
    }
}

- (void)setTextWithCount:(NSInteger)matchCount money:(NSInteger)money {
    NSString *text;
    text =[NSString stringWithFormat:@"<font color=\"black\">共</font><font color=\"%@\">%ld</font><font color=\"black\">注 </font><font color=\"%@\">%ld</font><font color=\"black\">元</font>",tRedColorText,(long)matchCount,tRedColorText,(long)money];
    
    MarkupParser *p = [[MarkupParser alloc]init];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    [_betCountLabel setAttString:attString];
    [p release];
    
    CGSize betCountLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize14];
    [_betCountLabel setFrame:CGRectMake((kWinSize.width - betCountLabelSize.width) / 2.0f, CGRectGetMinY(_betCountLabel.frame), betCountLabelSize.width + 10, CGRectGetHeight(_betCountLabel.frame) + 5)];
    [_betCountLabel setNeedsDisplay];
}

@end
