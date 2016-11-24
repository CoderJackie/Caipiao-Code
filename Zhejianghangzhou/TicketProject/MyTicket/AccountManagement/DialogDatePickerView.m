//
//  DialogDatePickerView.m 个人中心－日期选择
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//20140825 13:45（洪晓彬）：大范围的修改，修改代码规范，改进生命周期，处理内存
//20140825 13:54（洪晓彬）：进行ipad适配

#import "DialogDatePickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "Globals.h"

#pragma mark -
#pragma mark @implementation DialogDatePickerView
@implementation DialogDatePickerView
@synthesize delegate = _delegate;
#pragma mark Lifecircle

- (id)initWithFrame:(CGRect)frame SelectRowDic:(NSDictionary *)rowDic {
    self = [super initWithFrame:frame];
    if (self) {
        _selectRowDic = [rowDic copy];
        _selectDateDic = [[NSMutableDictionary alloc]init];
        
        [[self layer] setShadowOffset:CGSizeMake(1, 1)];
        [[self layer] setShadowOpacity:1];
        [[self layer] setShadowColor:[UIColor blackColor].CGColor];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self makeSubView];
        [self fillPickerViewDate];
    }
    return self;
}

- (void)dealloc {
    [_overlayView release];
    _overlayView = nil;
    _pickerView = nil;
    
    [_selectDateDic release];
    _selectDateDic = nil;
    [_selectRowDic release];
    
    [super dealloc];
}

- (void)makeSubView {
    //overlayView 半透明背景
    _overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_overlayView setBackgroundColor:[UIColor blackColor]];
    [_overlayView setAlpha:0.5];
    
    /********************** adjustment 控件调整 ***************************/
    CGFloat firstLabelMinX = IS_PHONE ? 0 : 10.0f;//第一个label的x
    CGFloat firstLabelMinY = IS_PHONE ? 0.0f : 12.0f;//第一个label的y
    CGFloat firstLabelHeight = IS_PHONE ? 30.0f : 45.0f;//第一个label的高
    
    CGFloat pickerViewMinX = IS_PHONE ? 10.0f : 10.0f;//日期滚动框的x
    CGFloat pickerViewAddY = IS_PHONE ? 6.0f : 8.0f;//日期滚动框与label的间距
    
    CGFloat buttonAddY = IS_PHONE ? 15.0f : 50.0f;//button与上一个控件的添加距离
    CGFloat buttonIntervalCenter = 0.0f; //button和view的中心的间距。
    CGFloat buttonWidth = (CGRectGetWidth(self.frame) - buttonIntervalCenter * 2) / 2.0f;
    CGFloat buttonHeight = IS_PHONE ? 35.0f : 45.0f;
    CGFloat buttonIntervalBottom = IS_PHONE ? 10.0f : 20.0f; // button与底部的间距
    /********************** adjustment end ***************************/
    
    //promptLabel 顶部提示label
    CGRect promptLabelRect = CGRectMake(firstLabelMinX, firstLabelMinY, CGRectGetWidth(self.frame), firstLabelHeight);
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:promptLabelRect];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.font = [UIFont systemFontOfSize:XFIponeIpadFontSize18];
    promptLabel.text = @"请选择日期";
    [self addSubview:promptLabel];
    [promptLabel release];
    
    //redLineView
    CGRect redLineViewRect = CGRectMake(0, CGRectGetMaxY(promptLabelRect), CGRectGetWidth(self.frame), AllLineWidthOrHeight * 2);
    UIView *redLineView = [[UIView alloc] initWithFrame:redLineViewRect];
    [redLineView setBackgroundColor:[UIColor colorWithRed:0xe3/255.0f green:0x39/255.0f blue:0x3c/255.0f alpha:1.0]];
    [self addSubview:redLineView];
    [redLineView release];
    
    //日期滚动选择框
    CGRect pickerViewRect = CGRectMake(pickerViewMinX, CGRectGetMaxY(redLineViewRect) + pickerViewAddY, CGRectGetWidth(self.frame) - pickerViewMinX * 2, CGRectGetHeight(self.frame) - CGRectGetMaxY(promptLabelRect) - pickerViewAddY -buttonAddY - buttonHeight - buttonIntervalBottom);
    _pickerView = [[UIPickerView alloc]initWithFrame:pickerViewRect];
    [_pickerView setShowsSelectionIndicator:YES];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [self addSubview:_pickerView];
    [_pickerView release];
    
    //cancleBtn 取消按钮
    CGRect cancleBtnRect = CGRectMake(CGRectGetWidth(self.frame) / 2.0 - buttonIntervalCenter - buttonWidth,CGRectGetHeight(self.frame) - buttonHeight, buttonWidth, buttonHeight);
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setFrame:cancleBtnRect];
    [cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancleBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0x9c/255.0f green:0x9c/255.0f blue:0x9c/255.0f alpha:1.0f]] forState:UIControlStateNormal];
    [cancleBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0x9c/255.0f green:0x9c/255.0f blue:0x9c/255.0f alpha:1.0f]] forState:UIControlStateHighlighted];
    [cancleBtn addTarget:self action:@selector(cancleBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancleBtn];
    
    //okBtn 确定按钮
    CGRect okBtnRect = CGRectMake(CGRectGetWidth(self.frame) / 2.0f + buttonIntervalCenter,CGRectGetMinY(cancleBtnRect), buttonWidth, buttonHeight);
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setFrame:okBtnRect];
    [okBtn.titleLabel setFont:[UIFont systemFontOfSize:XFIponeIpadFontSize13]];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [okBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateNormal];
    [okBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xfd/255.0f green:0xae/255.0f blue:0x24/255.0f alpha:1.0f]] forState:UIControlStateHighlighted];
    [okBtn addTarget:self action:@selector(okBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okBtn];
}

#pragma mark -
#pragma mark Delegate
#pragma mark -UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0) {
        NSMutableArray *yearArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 12; i++) {
            [yearArray addObject:[NSString stringWithFormat:@"%ld",(long)(2015 + i)]];
        }
        return [yearArray objectAtIndex:row];
    } else {
        NSMutableArray *monthArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 12; i++) {
            [monthArray addObject:[NSString stringWithFormat:@"%ld",(long)(i + 1)]];
        }
        return [monthArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component == 0) {
        NSString *year = [self pickerView:picker titleForRow:row forComponent:0];
        NSString *month = [self pickerView:picker titleForRow:0 forComponent:1];
        [_selectDateDic setObject:year forKey:@"selectYear"];
        [_selectDateDic setObject:month forKey:@"selectMonth"];
        [_selectDateDic setObject:[NSString stringWithFormat:@"%ld",(long)row] forKey:@"selectYearRow"];
        [_selectDateDic setObject:[NSString stringWithFormat:@"%d",0] forKey:@"selectMonthRow"];
    }
    if(component == 1) {
        NSString *month = [self pickerView:picker titleForRow:row forComponent:1];
        [_selectDateDic setObject:month forKey:@"selectMonth"];
        [_selectDateDic setObject:[NSString stringWithFormat:@"%ld",(long)row] forKey:@"selectMonthRow"];
    }
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 12;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)okBtnTouchUpInside:(id)sender {
    NSString *year = [self pickerView:_pickerView titleForRow:[_pickerView selectedRowInComponent:0] forComponent:0];
    NSString *month = [self pickerView:_pickerView titleForRow:[_pickerView selectedRowInComponent:1] forComponent:1];
    [_selectDateDic setObject:year forKey:@"selectYear"];
    [_selectDateDic setObject:month forKey:@"selectMonth"];
    if (_delegate && [_delegate respondsToSelector:@selector(pickerViewDidSelectedDateDictionary:)]) {
        [_delegate pickerViewDidSelectedDateDictionary:_selectDateDic];
    }
    
    [self fadeOut];
}

- (void)cancleBtnTouchUpInside:(id)sender {
    [self fadeOut];
}

#pragma mark -Customized: Private (General)
//为日期进行默认选择
- (void)fillPickerViewDate {
    //反选
    if([_selectRowDic objectForKey:@"selectYearRow"]) {
        NSInteger selectedRowIndex = [[_selectRowDic objectForKey:@"selectYearRow"] intValue];
        [_pickerView selectRow:selectedRowIndex inComponent:0 animated:YES];
        [self pickerView:_pickerView didSelectRow:selectedRowIndex inComponent:0];
    }
    if([_selectRowDic objectForKey:@"selectMonthRow"]) {
        NSInteger selectedRowIndex = [[_selectRowDic objectForKey:@"selectMonthRow"] intValue];
        [_pickerView selectRow:selectedRowIndex inComponent:1 animated:YES];
        [self pickerView:_pickerView didSelectRow:selectedRowIndex inComponent:1];
    }
}

//动画进入
- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.alpha = 0;
    
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.alpha = 1;
    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView commitAnimations];
}

//消失动画
- (void)fadeOut {
    [UIView beginAnimations:@"Curl" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView commitAnimations];
    
    [_overlayView removeFromSuperview];
    [self removeFromSuperview];
}

//显示视图
- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:_overlayView];
    [keyWindow addSubview:self];
    
    [self setCenter:CGPointMake(keyWindow.center.x, keyWindow.center.y)];
    
    [self fadeIn];
}

@end
