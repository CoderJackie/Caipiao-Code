//
//  SolutionDetailBottomView.m 合买详情 底部视图
//  TicketProject
//
//  Created by sls002 on 13-6-6.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140729 13:54（洪晓彬）：视图重构,修改代码规范，改进生命周期，处理内存
//20140807 18:10（洪晓彬）：进行ipad适配

#import "SolutionDetailBottomView.h"

#import "Globals.h"

#define kTextFieldWidth (IS_PHONE ? 60 : 100)  //TextField的宽度

@implementation SolutionDetailBottomView
@synthesize delegate = _delegate;

-(id)initWithBaseView:(UIView *)baseview solutionDetailDict:(NSDictionary *)solutionDetailDict {
    self = [super init];
    if(self) {
        [self setUserInteractionEnabled:YES];
        _baseView = [baseview retain];
        _solutionDetailDict = [solutionDetailDict retain];
//        _maxBuyNumber = [[_solutionDetailDict objectForKey:@"surplusShare"] intValue];
//        _shareMoney = [[_solutionDetailDict objectForKey:@"shareMoney"] intValue];
        _maxBuyNumber = 0;
        _shareMoney = 0;
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self createSubViews];
    }
    
    return self;
}

-(void)dealloc {
    [_baseView release];
    [_solutionDetailDict release];
    _maxField = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super dealloc];
}

//创建视图
-(void)createSubViews {
    //tapGesture 给背景视图 添加单击触摸事件  用于使键盘消失
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapResignKeyboard:)];
    tapGesture.delegate = self;
    [_baseView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat shadeHeight = IS_PHONE ? 3.0f : 6.0f;
    
    CGFloat buyTextLabelMinX = IS_PHONE ? 8.0f : 20.0f;
    CGFloat buyTextLabelWidth = IS_PHONE ? 30.0f : 60.0f;
    CGFloat buyTextLabelHeight = IS_PHONE ? 28.0f : 40.0f;
    
    CGFloat fenLabelAddX = IS_PHONE ? 8.0f : 15.0f;
    CGFloat fenLabelWidht = IS_PHONE ? 100.0f : 150.0f;
    
    CGFloat buttonMaginRight = IS_PHONE ? 10.0f : 20.0f;
    CGFloat buttonWidth = IS_PHONE ? 55.0f : 100.0f;
    CGFloat buttonHeight = IS_PHONE ? 28.0f : 45.0f;//确认按钮的高度
    /********************** adjustment end ***************************/
    //shadeImageView
    CGRect shadeImageViewRect = CGRectMake(0, -shadeHeight, kWinSize.width, shadeHeight);
    UIImageView *shadeImageView = [[UIImageView alloc] initWithFrame:shadeImageViewRect];
    [shadeImageView setImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shade.png"]]];
    [self addSubview:shadeImageView];
    [shadeImageView release];
    
    //buyTextLabel 提示文字 “购买”
    CGRect buyTextLabelRect = CGRectMake(buyTextLabelMinX, (LaunchChippedBottomFirstHeight - buyTextLabelHeight) / 2.0f, buyTextLabelWidth, buyTextLabelHeight);
    UILabel *buyTextLabel = [[UILabel alloc]initWithFrame:buyTextLabelRect];
    [buyTextLabel setText:@"购买"];
    [buyTextLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [buyTextLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:buyTextLabel];
    [buyTextLabel release];
    
    //maxField
    CGRect maxFieldBackImageViewRect = CGRectMake(CGRectGetMaxX(buyTextLabelRect) + 1, CGRectGetMinY(buyTextLabelRect), kTextFieldWidth, CGRectGetHeight(buyTextLabelRect));
    UIImageView *maxFieldBackImageView = [[UIImageView alloc] initWithFrame:maxFieldBackImageViewRect];
    [maxFieldBackImageView setImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteBlackLineButton.png"]] stretchableImageWithLeftCapWidth:4.0f topCapHeight:4.0f]];
    [self addSubview:maxFieldBackImageView];
    [maxFieldBackImageView release];
    
    CGRect maxFieldRect = maxFieldBackImageViewRect;
    _maxField = [[UITextField alloc]initWithFrame:maxFieldRect];
    [_maxField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [_maxField setTextAlignment:NSTextAlignmentCenter];
    [_maxField setPlaceholder:@"1份"];
    [_maxField setKeyboardType:UIKeyboardTypeNumberPad];
    [_maxField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_maxField setDelegate:self];
    [self addSubview:_maxField];
    [_maxField release];
    
    //fenshu Parser
    NSString *text = [NSString stringWithFormat:@"<font color=\"black\">剩</font><font color=\"%@\">%ld</font><font color=\"black\">份</font>",tRedColorText,(long)_maxBuyNumber];
    MarkupParser *p = [[MarkupParser alloc]initWithFontSize:XFIponeIpadFontSize13];
    NSAttributedString *attString = [p attrStringFromMarkup:text];
    [p release];
    
    NSString *expectedText = [NSString stringWithFormat:@"剩%ld份",(long)_maxBuyNumber];
    
    CGSize expectedSize = [expectedText sizeWithFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]
                              constrainedToSize:CGSizeMake(fenLabelWidht, NSIntegerMax) lineBreakMode:NSLineBreakByWordWrapping];
    
    //fenshu
    CGRect fenshuRect = CGRectMake(CGRectGetMaxX(maxFieldRect) + fenLabelAddX, (LaunchChippedBottomFirstHeight - expectedSize.height) / 2.0f, fenLabelWidht, expectedSize.height + 10.0);
    CustomLabel *fenshu = [[CustomLabel alloc] initWithFrame:fenshuRect];
    [fenshu setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [fenshu setBackgroundColor:[UIColor clearColor]];
    [fenshu setAttString:attString];
    [fenshu setTextColor:kRedColor];
    [self addSubview:fenshu];
    [fenshu release];
    
    //payBtn 购买按钮
    CGRect payBtnRect = CGRectMake(kWinSize.width - (buttonWidth + buttonMaginRight), (LaunchChippedBottomFirstHeight - buttonHeight) /2.0f, buttonWidth, buttonHeight);
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setFrame:payBtnRect];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [payBtn setTitle:@"付款" forState:UIControlStateNormal];
    [payBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateNormal];
    [payBtn setBackgroundImage:[[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"yellowButton.png"]] stretchableImageWithLeftCapWidth:5.0f topCapHeight:5.0f] forState:UIControlStateHighlighted];
    [payBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize13]];
    [payBtn addTarget:self action:@selector(SolutionPay:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:payBtn];
}

#pragma mark -
#pragma mark Delegate
#pragma mark UITableViewDataSource
//限制输入
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger buyNum = [[textField.text stringByReplacingCharactersInRange:range withString:string] intValue];
    if (buyNum > _maxBuyNumber) {
        [self makeBuyTicketNum:buyNum isEmpty:NO];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //监听 键盘出现的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark -Customized(Action)
//使键盘消失 view下去
-(void)tapResignKeyboard:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self];
    
    if(!CGRectContainsPoint(self.bounds, touchPoint)) {
        for (UIView *view in self.subviews) {
            if([view isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)view;
                [textField resignFirstResponder];
            }
        }
    }
}

//键盘出现
-(void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardRect = [value CGRectValue];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self setFrame:CGRectMake(0, kWinSize.height - keyBoardRect.size.height - 44 - LaunchChippedBottomFirstHeight - LaunchChippedBottomSecondHeight, kWinSize.width, LaunchChippedBottomFirstHeight + LaunchChippedBottomSecondHeight)];
    [UIView commitAnimations];
}

//键盘隐藏
-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self setFrame:CGRectMake(0, kWinSize.height - 44 - LaunchChippedBottomFirstHeight - LaunchChippedBottomSecondHeight, kWinSize.width, LaunchChippedBottomFirstHeight + LaunchChippedBottomSecondHeight)];
    [UIView commitAnimations];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//点击 付款按钮事件
- (void)SolutionPay:(id)sender {
    [_maxField resignFirstResponder];
    if ([_delegate respondsToSelector:@selector(SolutionDetailBottomWillPay:)] && ([_maxField.text intValue] > 0 || _maxField.text.length == 0)) {
        if (_maxField.text.length == 0) {
            [_delegate SolutionDetailBottomWillPay:1];
        } else {
            [_delegate SolutionDetailBottomWillPay:[_maxField.text intValue]];
        }
    }
}

//份数框 值变化事件
-(void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if (textField.text.length == 0) {
        [self makeBuyTicketNum:0 isEmpty:YES];
        return;
    }
    NSInteger buyNum = [textField.text intValue];
    [self makeBuyTicketNum:buyNum isEmpty:NO];
}

#pragma mark -Customized: Private (General)
//判断份数是否在范围内，并修改相应的视图值
- (void)makeBuyTicketNum:(NSInteger)buyNum isEmpty:(BOOL)isEmpty{
    NSInteger buyNumber = 1;
    if (isEmpty) {
        buyNumber = 0;
    } else if (buyNum < 1) {
        buyNumber = 1;
    } else if (buyNum > _maxBuyNumber) {
        buyNumber = _maxBuyNumber;
    } else {
        buyNumber = buyNum;
    }
    [_maxField setText:isEmpty ? @"" : [NSString stringWithFormat:@"%ld",(long)buyNumber]];
}

@end