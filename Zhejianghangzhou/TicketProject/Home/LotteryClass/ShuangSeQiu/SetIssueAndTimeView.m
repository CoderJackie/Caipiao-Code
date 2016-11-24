//
//  SetIssueAndTimeView.m   设置 期号 和 倍数 的视图
//  TicketProject
//
//  Created by sls002 on 13-5-23.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140927 09:21（洪晓彬）：修改代码规范，改进生命周期，处理内存
//20140927 09:38（洪晓彬）：进行ipad适配

#import "SetIssueAndTimeView.h"
#import "BaseBetViewController.h"
#import "Service.h"

#import "Globals.h"

#define backImageViewHeight (CGRectGetHeight(self.frame) / 2.0f)
#define kChaseViewHeight 42 //选择是否追号  的高度

#define kIssueViewHeight 42
#define lineHeight 30.0f

@implementation SetIssueAndTimeView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame superView:(UIView *)view isDLT:(BOOL)flag hasWinStopView:(BOOL)hasWinStopView {
    self = [super initWithFrame:frame];
    if (self) {
        _superView = view;
        _isDLT = flag;
        _hasWinStopView = hasWinStopView;
        self.isZhuiQiStop = YES;
        self.isZhuiHao = NO;
        [self createSubViews];
    }
    return self;
}

- (void)dealloc {
    _chaseView = nil;
    _issueField = nil;
    _timesField = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_listArray release];
    
    [super dealloc];
}

//创建视图
- (void)createSubViews {
    /********************** adjustment 控件调整 ***************************/
    CGFloat maginLeftRight = 25.0f;
    
    CGFloat labelWidth = IS_PHONE ? 14.0f : 60.0f;
    CGFloat textFieldWidth = IS_PHONE ? 75.0f : 150.0f;
    CGFloat labelTextFieldHeight = IS_PHONE ? 28.0f : 40.0f;
    CGFloat labelTextFieldMinY = (kChaseViewHeight - labelTextFieldHeight) / 2.0f;
    /********************** adjustment end ***************************/
    CGRect backImageViewRect = CGRectMake(0, 0, kWinSize.width, kChaseViewHeight);
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewRect];
    [backImageView setBackgroundColor:[UIColor colorWithRed:0xf1/255.0f green:0xf1/255.0f blue:0xf1/255.0f alpha:1.0f]];
    [self addSubview:backImageView];
    [backImageView release];
    
    //shadeLineView
    CGRect shadeLineViewRect = CGRectMake(0, -3, CGRectGetWidth(self.frame), 3);
    UIView *shadeLineView = [[UIView alloc] initWithFrame:shadeLineViewRect];
    [shadeLineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"shade.png"]]]];
    [self addSubview:shadeLineView];
    [shadeLineView release];
    
    //zhuiPromptLabel
    CGRect zhuiPromptLabelRect = CGRectMake(maginLeftRight, labelTextFieldMinY, labelWidth, labelTextFieldHeight);
    UILabel *zhuiPromptLabel = [[UILabel alloc]initWithFrame:zhuiPromptLabelRect];
    [zhuiPromptLabel setText:@"追"];
    [zhuiPromptLabel setTag:23];
    [zhuiPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [zhuiPromptLabel setTextColor:[UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
    [zhuiPromptLabel setBackgroundColor:[UIColor clearColor]];
    [zhuiPromptLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:zhuiPromptLabel];
    [zhuiPromptLabel release];
    
    //qiPromptLabel
    CGRect qiPromptLabelRect = CGRectMake(self.center.x - maginLeftRight - labelWidth, labelTextFieldMinY, labelWidth, labelTextFieldHeight);
    UILabel *qiPromptLabel = [[UILabel alloc]initWithFrame:qiPromptLabelRect];
    [qiPromptLabel setText:@"期"];
    [qiPromptLabel setTag:24];
    [qiPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [qiPromptLabel setTextColor:[UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
    [qiPromptLabel setBackgroundColor:[UIColor clearColor]];
    [qiPromptLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:qiPromptLabel];
    [qiPromptLabel release];
    
    //line
    CGRect lineRect = CGRectMake((CGRectGetWidth(self.frame) - AllLineWidthOrHeight) / 2.0f, (CGRectGetHeight(backImageViewRect) - lineHeight) / 2.0f, AllLineWidthOrHeight, lineHeight);
    [Globals makeLineWithFrame:lineRect inSuperView:self];
    
    //issueField
    CGRect issueFieldRect = CGRectMake(CGRectGetMaxX(zhuiPromptLabelRect) + (CGRectGetMinX(qiPromptLabelRect) - CGRectGetMaxX(zhuiPromptLabelRect) - textFieldWidth) / 2.0f, labelTextFieldMinY, textFieldWidth, labelTextFieldHeight);
    _issueField = [[UITextField alloc]initWithFrame:issueFieldRect];
    [_issueField setText:@"1"];
    [_issueField setTag:25];
    [_issueField setTextAlignment:NSTextAlignmentCenter];
    [_issueField setBackground:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]]];
    [_issueField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_issueField setKeyboardType:UIKeyboardTypeNumberPad];
    [_issueField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_issueField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_issueField setDelegate:self];
    [self addSubview:_issueField];
    [_issueField release];
    
    //touPromptLabel
    CGRect touPromptLabelRect = CGRectMake(self.center.x + maginLeftRight, labelTextFieldMinY, labelWidth, labelTextFieldHeight);
    UILabel *touPromptLabel = [[UILabel alloc]initWithFrame:touPromptLabelRect];
    [touPromptLabel setText:@"投"];
    [touPromptLabel setTag:27];
    [touPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [touPromptLabel setTextColor:[UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
    [touPromptLabel setBackgroundColor:[UIColor clearColor]];
    [touPromptLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:touPromptLabel];
    [touPromptLabel release];
    
    //beiPromptLabel
    CGRect beiPromptLabelRect = CGRectMake(kWinSize.width - maginLeftRight - labelWidth, labelTextFieldMinY, labelWidth, labelTextFieldHeight);
    UILabel *beiPromptLabel = [[UILabel alloc]initWithFrame:beiPromptLabelRect];
    [beiPromptLabel setText:@"倍"];
    [beiPromptLabel setTag:29];
    [beiPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [beiPromptLabel setTextColor:[UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
    [beiPromptLabel setBackgroundColor:[UIColor clearColor]];
    [beiPromptLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:beiPromptLabel];
    [beiPromptLabel release];
    
    //timesField
    CGRect timesFieldRect = CGRectMake(CGRectGetMaxX(touPromptLabelRect) + (CGRectGetMinX(beiPromptLabelRect) - CGRectGetMaxX(touPromptLabelRect) - textFieldWidth) / 2.0f, labelTextFieldMinY, textFieldWidth, labelTextFieldHeight);
    _timesField = [[UITextField alloc]initWithFrame:timesFieldRect];
    [_timesField setText:@"1"];
    [_timesField setTag:28];
    [_timesField setTextAlignment:NSTextAlignmentCenter];
    [_timesField setBackground:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"whiteButton.png"]]];
    [_timesField setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [_timesField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_timesField setKeyboardType:UIKeyboardTypeNumberPad];
    [_timesField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_timesField setDelegate:self];
    [self addSubview:_timesField];
    [_timesField release];
    
    if (_hasWinStopView){
        [self createChaseViewWidthChaseViewHeight:CGRectGetHeight(self.frame) - kChaseViewHeight];
    }
}

- (void)createChaseViewWidthChaseViewHeight:(CGFloat)chaseViewHeight {
    //chaseView
    CGRect chaseViewRect = CGRectMake(0, CGRectGetHeight(self.frame) - chaseViewHeight, kWinSize.width, chaseViewHeight);
    _chaseView = [[UIView alloc]initWithFrame:chaseViewRect];
    [_chaseView setBackgroundColor:[UIColor colorWithRed:0xf1/255.0f green:0xf1/255.0f blue:0xf1/255.0f alpha:1.0f]];
    [self addSubview:_chaseView];
    [_chaseView release];
    
    //line
    CGRect line1Rect = CGRectMake(0, 0, CGRectGetWidth(chaseViewRect), AllLineWidthOrHeight);
    [Globals makeLineWithFrame:line1Rect inSuperView:_chaseView];
    
    //line
    CGRect line2Rect = CGRectMake((CGRectGetWidth(self.frame) - AllLineWidthOrHeight) / 2.0f, (CGRectGetHeight(chaseViewRect) - lineHeight) / 2.0f, AllLineWidthOrHeight, lineHeight);
    [Globals makeLineWithFrame:line2Rect inSuperView:_chaseView];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat checkBtnMinX = IS_PHONE ? 25.0f : 25.0f;
    CGFloat checkBtnSize = IS_PHONE ? 20.0f : 35.0f;
    CGFloat checkBtnMinY = (chaseViewHeight - checkBtnSize) / 2.0f;
    
    CGFloat btnLabelInterval = 5.0f;
    CGFloat labelWidth = kWinSize.width - checkBtnMinX - checkBtnSize - btnLabelInterval;
    /********************** adjustment end ***************************/
    
    //checkBtn
    CGRect checkBtnRect = CGRectMake(checkBtnMinX, checkBtnMinY, checkBtnSize, checkBtnSize);
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:checkBtnRect];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton_Normal.png"]] forState:UIControlStateNormal];
    [checkBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
    [checkBtn addTarget:self action:@selector(zhuiQiSelected:) forControlEvents:UIControlEventTouchUpInside];
    [checkBtn setSelected:self.isZhuiQiStop];
    [_chaseView addSubview:checkBtn];
    [checkBtn release];
    
    //checkPromptLabel
    CGRect checkPromptLabelRect = CGRectMake(CGRectGetMaxX(checkBtnRect) + btnLabelInterval, CGRectGetMinY(checkBtnRect), labelWidth, CGRectGetHeight(checkBtnRect));
    UILabel *checkPromptLabel = [[UILabel alloc]initWithFrame:checkPromptLabelRect];
    [checkPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
    [checkPromptLabel setText:@"中奖后停止追号"];
    [checkPromptLabel setTextColor:[UIColor colorWithRed:156.0f/255.0f green:156.0f/255.0f blue:156.0f/255.0f alpha:1.0f]];
    [checkPromptLabel setBackgroundColor:[UIColor clearColor]];
    [_chaseView addSubview:checkPromptLabel];
    [checkPromptLabel release];
    
    // 增加追号投注按钮
    if(_isDLT){
        //checkDLTBtn
        CGRect checkDLTBtnRect = CGRectMake(kWinSize.width / 2.0f + checkBtnMinX, checkBtnMinY, checkBtnSize, checkBtnSize);
        UIButton *checkDLTBtn = [[UIButton alloc] initWithFrame:checkDLTBtnRect];
        [checkDLTBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton_Normal.png"]] forState:UIControlStateNormal];
        [checkDLTBtn setBackgroundImage:[UIImage imageNamed:[Globals autoAdaptiveIphoneIpadPhotoName:@"agreeButton.png"]] forState:UIControlStateSelected];
        [checkDLTBtn addTarget:self action:@selector(zhuiHaoSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_chaseView addSubview:checkDLTBtn];
        [checkDLTBtn release];
        
        //checkDLTPromptLabel
        CGRect checkDLTPromptLabelRect = CGRectMake(CGRectGetMaxX(checkDLTBtnRect) + btnLabelInterval, CGRectGetMinY(checkDLTBtnRect), labelWidth, CGRectGetHeight(checkDLTBtnRect));
        UILabel *checkDLTPromptLabel = [[UILabel alloc]initWithFrame:checkDLTPromptLabelRect];
        [checkDLTPromptLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize12]];
        [checkDLTPromptLabel setText:@"追加投注"];
        [checkDLTPromptLabel setTextColor:[UIColor colorWithRed:156.0f/255.0f green:156.0f/255.0f blue:156.0f/255.0f alpha:1.0f]];
        [checkDLTPromptLabel setBackgroundColor:[UIColor clearColor]];
        [_chaseView addSubview:checkDLTPromptLabel];
        [checkDLTPromptLabel release];
    }
}

//使键盘消失 view下去
- (void)tapResignKeyboard:(UITapGestureRecognizer *)tapGesture {
    [_timesField resignFirstResponder];
    [_issueField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyBoardRect = [value CGRectValue];
    
    if (!_overlayView) {
        _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        [_overlayView setAlpha:0.5];
        [_superView addSubview:_overlayView];
        [_superView addSubview:self];
        [_overlayView release];
    }
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapResignKeyboard:)];
    [_overlayView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [self setFrame:CGRectMake(0, kWinSize.height - keyBoardRect.size.height - CGRectGetHeight(self.frame) - 44.0f, kWinSize.width, CGRectGetHeight(self.frame))];
    [UIView commitAnimations];
    if (_chaseView)
        [_chaseView setHidden:NO];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_issueField.text integerValue] < 2)
        _issueField.text = @"1";
    if ([_timesField.text integerValue] < 2)
        _timesField.text = @"1";
    self.chase = [_issueField.text integerValue];
    self.multiple = [_timesField.text integerValue];
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateSelect)]) {
        [self.delegate updateSelect];
    }
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [self setFrame:CGRectMake(0, kWinSize.height - kBottomHeight - CGRectGetHeight(self.frame) - 44.0, kWinSize.width, CGRectGetHeight(self.frame))];
    [UIView commitAnimations];
    
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

- (void)zhuiQiSelected:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:![btn isSelected]];
    self.isZhuiQiStop = btn.isSelected;
}

- (void)zhuiHaoSelected:(id)sender {
    UIButton *btn = sender;
    [btn setSelected:![btn isSelected]];
    self.isZhuiHao = [btn isSelected];

    if(_delegate && [_delegate respondsToSelector:@selector(updateSelect)]) {
        [_delegate updateSelect];
    }
    self.isZhuiHao = btn.isSelected;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text integerValue] <= 1) {
        [textField setText:@""];
    }
    
    //监听 键盘出现的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if([textField isEqual:_issueField]) {
        [UIView beginAnimations:@"Curl" context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        float frameY = self.frame.origin.y;
        [self setFrame:CGRectMake(0, frameY, kWinSize.width, CGRectGetHeight(self.frame) )];
        
        [UIView commitAnimations];
    } else if ([textField isEqual:_timesField]) {
        [UIView beginAnimations:@"Curl" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        float frameY = self.frame.origin.y;
        [self setFrame:CGRectMake(0, frameY, kWinSize.width, CGRectGetHeight(self.frame))];
        
        [UIView commitAnimations];
    }
}

- (NSInteger)chase {
    NSString *chaseStr = _issueField.text;
    return [chaseStr intValue];
}

- (void)setMultiple:(NSInteger)multiple {
    [_timesField setText:[NSString stringWithFormat:@"%ld",(long)multiple]];
}

- (NSInteger)multiple {
    NSString *multipleStr = _timesField.text;
    return [multipleStr intValue];
}

//限制输入
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location == 0 && textField.text.length > 1)
        return NO;
    Service *twoSV=[Service getDefaultService];
    BaseBetViewController *baseBetVC=twoSV.baseBetViewController;
    [_listArray release];
    _listArray = [baseBetVC.chaseList retain];
    _totalChaseCount = [_listArray count];
    if (textField == _issueField) {
        _targetText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([_targetText integerValue] > 1 && _totalChaseCount == 0) {
            [XYMPromptView defaultShowInfo:@"最多可追1期" isCenter:YES];
            [self performSelector:@selector(changeIssueFieldToMax:) withObject:[NSNumber numberWithInt:1] afterDelay:0.15];
            return NO;
        } else if ([_targetText integerValue]> _totalChaseCount && _totalChaseCount != 0) {
            NSString *prompt = [NSString stringWithFormat:@"最多能追%ld期",(long)_totalChaseCount];
            [XYMPromptView defaultShowInfo:prompt isCenter:YES];
            [self performSelector:@selector(changeIssueFieldToMax:) withObject:[NSNumber numberWithInteger:_totalChaseCount] afterDelay:0.15];
            return NO;
        } else {
            if ([_issueField.text isEqualToString:@"0"]) {
                _issueField.text=@"";
            }
        }
    }
    
    if (textField == _timesField) {
        if (range.location > 2)
            return NO;
    }
    
    return YES;
}

- (void)textFieldValueChanged:(id)sender {
    UITextField *textField = sender;
    if([textField.text hasPrefix:@"0"] && [textField.text length] > 1) {
        textField.text = [NSString stringWithFormat:@"%ld",(long)[textField.text integerValue]];
    }
}

- (void)changeIssueFieldToMax:(NSNumber *)theMaxIssueNumber {
    _issueField.text = [NSString stringWithFormat:@"%i", theMaxIssueNumber.intValue];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    Service *twoSV=[Service getDefaultService];
    
    if ([textField isEqual:_issueField]) {
        if ([_issueField.text integerValue] > _totalChaseCount) {
            NSString *str = [NSString stringWithFormat:@"%ld",(long)_totalChaseCount];
            if (_totalChaseCount == 0)
                _issueField.text = @"1";
            else
                _issueField.text = str;
            twoSV.ballBei = _totalChaseCount;
        } else {
            twoSV.ballBei = [_issueField.text integerValue];
        }
    }
}

@end
