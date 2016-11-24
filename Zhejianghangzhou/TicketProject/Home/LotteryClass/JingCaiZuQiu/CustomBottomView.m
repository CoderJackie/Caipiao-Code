//
//  CustomBottomView.m 自定义底部视图
//  TicketProject
//
//  Created by sls002 on 13-7-1.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140919 17:15（洪晓彬）：修改代码规范，处理内存
//20140919 17:19（洪晓彬）：进行ipad适配

#import "CustomBottomView.h"

#import "Globals.h"

#define kButtonSize (IS_PHONE ? CGSizeMake(50.0f, 28.0) : CGSizeMake(82.5f, 40.0f))
#define kMarginLeftRight (IS_PHONE ? 10.0f : 20.0f )
#define kContentViewSize (IS_PHONE ? CGSizeMake(100, 27) : CGSizeMake(400, 27))

#pragma mark -
#pragma mark @implementation CustomBottomView
@implementation CustomBottomView
@synthesize backImage = _backImage;
@synthesize contentView = _contentView;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame Type:(NSInteger)type {
    self = [super initWithFrame:frame];
    if (self) {
        if(type == 0) {
            [self createContentView];
        }
        if(type == 1) {
            [self createContentLabel];
        }
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)dealloc {
    [_backImage release];
    [_leftButton release];
    [_rightButton release];
    [_contentString release];
    
    [super dealloc];
}

#pragma mark -Customized: Private (General)
- (void)createContentView {
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(self.center.x - kContentViewSize.width / 2, 0, kContentViewSize.width, kContentViewSize.height)];
    [self addSubview:_contentView];
    [_contentView release];
}

- (void)createContentLabel {
    /********************** adjustment 控件调整 ***************************/
    CGFloat shadeHeight = IS_PHONE ? 3.0f : 6.0f;
    
    CGFloat labelWidht = IS_PHONE ? 120.0f : 210.0f;
    CGFloat labelWidhts = IS_PHONE ? 150.0f : 240.0f;
    CGFloat LabelHeight = IS_PHONE ? 18.0 : 23.0f;
    
    CGFloat lineImageViewMinX = IS_PHONE ? 80.0f : 100.0f;
    CGFloat lineImageViewMinY = IS_PHONE ? 6.0f : 12.0f;
    CGFloat lineImageViewWidth = IS_PHONE ? 1.0f : 2.0f;
    /********************** adjustment end ***************************/
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
    
    //contentLabel
    CGRect contentLabelRect = CGRectMake((kWinSize.width - labelWidht) / 2.0f , (CGRectGetHeight(self.frame) - LabelHeight) / 2.0f - 5, labelWidht, LabelHeight + 10);
    _contentLabel = [[CustomLabel alloc]initWithFrame:contentLabelRect];
    [_contentLabel setTextAlignment:NSTextAlignmentCenter];
    [_contentLabel setBackgroundColor:[UIColor clearColor]];
    [_contentLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize14]];
    _contentLabel.textColor = [UIColor blackColor];
    [self addSubview:_contentLabel];
    [_contentLabel release];
    
    //contentLabel1
    CGRect contentLabelRect1 = CGRectMake((kWinSize.width - labelWidhts) / 2.0f , CGRectGetMaxY(contentLabelRect) - 10, labelWidhts, LabelHeight + 10);
    _contentLabel1 = [[CustomLabel alloc]initWithFrame:contentLabelRect1];
    [_contentLabel1 setTextAlignment:NSTextAlignmentCenter];
    [_contentLabel1 setBackgroundColor:[UIColor clearColor]];
    [_contentLabel1 setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize2]];
    _contentLabel1.textColor = [UIColor blackColor];
    [self addSubview:_contentLabel1];
    [_contentLabel1 release];
    
}

- (void)setContentString:(NSString *)contentString {
    if(![contentString isEqual:_contentString]) {
       [_contentString release];
       _contentString = [contentString copy];
       _contentLabel.text = _contentString;
   }
}

- (void)setLeftButton:(UIButton *)leftButton {
    if(![leftButton isEqual:_leftButton]) {
        /********************** adjustment 控件调整 ***************************/
        CGFloat leftBtnWidth = IS_PHONE ? 70.0f : 105.0f;
        /********************** adjustment end ***************************/
        [_leftButton release];
        _leftButton = [leftButton retain];
        [_leftButton setFrame:CGRectMake(kMarginLeftRight, (CGRectGetHeight(self.frame) - kButtonSize.height) / 2.0f, leftBtnWidth, kButtonSize.height)];
        [self addSubview:leftButton];
    }
}

- (void)setRightButton:(UIButton *)rightButton {
    if(![rightButton isEqual:_rightButton]) {
        [_rightButton release];
        _rightButton = [rightButton retain];
        [rightButton setFrame:CGRectMake(self.bounds.size.width - kMarginLeftRight - kButtonSize.width, (CGRectGetHeight(self.frame) - kButtonSize.height) / 2.0f, kButtonSize.width, kButtonSize.height)];
        [self addSubview:rightButton];
    }
}

- (void)setBackImage:(UIImage *)backImage {
    if(![backImage isEqual:_backImage]) {
        [_backImage release];
        _backImage = [backImage copy];
    }
}

- (void)setTextWithMatchCount:(NSInteger)matchCount hasMatch:(BOOL)hasMatch {
    NSString *text;
    if (!hasMatch) {
        text =[NSString stringWithFormat:@"<font color=\"black\">请至少选择</font><font color=\"%@\">%ld</font><font color=\"black\">场比赛</font>",tRedColorText,(long)matchCount];
    } else {
        text =[NSString stringWithFormat:@"<font color=\"black\">你已经选择了</font><font color=\"%@\">%ld</font><font color=\"black\">场</font>",tRedColorText,(long)matchCount];
    }
    
    MarkupParser *p = [[MarkupParser alloc]init];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    [_contentLabel setAttString:attString];
    [p release];
    [_contentLabel setNeedsDisplay];
    
}

- (void)setMatchCount:(NSInteger)matchCount money:(NSInteger)money {
    [_contentLabel1 setHidden:YES];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">共</font><font color=\"%@\">%ld</font><font color=\"black\">注</font><font color=\"%@\">%ld</font><font color=\"black\">元</font>",tRedColorText,(long)matchCount,tRedColorText,(long)money];
    MarkupParser *p = [[MarkupParser alloc]init];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    [_contentLabel setAttString:attString];
    [p release];
    [_contentLabel setNeedsDisplay];
    
    CGSize betCountLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize14];
    [_contentLabel setFrame:CGRectMake((kWinSize.width - betCountLabelSize.width) / 2.0f, CGRectGetMinY(_contentLabel.frame), betCountLabelSize.width + 2.0f, CGRectGetHeight(_contentLabel.frame))];
    [_contentLabel setNeedsDisplay];
}

- (void)setMatchCount:(NSInteger)matchCount money:(NSInteger)money winMoney1:(float)winMoney1 winMoney2:(float)winMoney2 {
    [_contentLabel1 setHidden:NO];
    
    NSString *text =[NSString stringWithFormat:@"<font color=\"black\">共</font><font color=\"%@\">%ld</font><font color=\"black\">注</font><font color=\"%@\">%ld</font><font color=\"black\">元</font>",tRedColorText,(long)matchCount,tRedColorText,(long)money];
    MarkupParser *p = [[MarkupParser alloc]init];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    [_contentLabel setAttString:attString];
    [p release];
    [_contentLabel setNeedsDisplay];
    
    CGSize betCountLabelSize = [Globals defaultSizeWithString:attString.string fontSize:XFIponeIpadFontSize14];
    [_contentLabel setFrame:CGRectMake((kWinSize.width - betCountLabelSize.width) / 2.0f, CGRectGetMinY(_contentLabel.frame), betCountLabelSize.width + 2.0f, CGRectGetHeight(_contentLabel.frame))];
    [_contentLabel setNeedsDisplay];
    
    NSString *texts =[NSString stringWithFormat:@"<font color=\"black\">预计奖金</font><font color=\"%@\">%.2f</font><font color=\"red\">~</font><font color=\"%@\">%.2f</font><font color=\"black\">元</font>",tRedColorText,winMoney1,tRedColorText,winMoney2];
    MarkupParser *ps = [[MarkupParser alloc]init];
    NSAttributedString *attStrings = [ps attrStringFromMarkup:texts];
    [_contentLabel1 setAttString:attStrings];
    [ps release];
    [_contentLabel1 setNeedsDisplay];
    
    CGSize betCountLabelSizes = [Globals defaultSizeWithString:attStrings.string fontSize:XFIponeIpadFontSize14];
    [_contentLabel1 setFrame:CGRectMake((kWinSize.width - betCountLabelSizes.width) / 2.0f, CGRectGetMinY(_contentLabel1.frame), betCountLabelSizes.width + 2.0f, CGRectGetHeight(_contentLabel1.frame))];
    [_contentLabel1 setNeedsDisplay];
}

@end
