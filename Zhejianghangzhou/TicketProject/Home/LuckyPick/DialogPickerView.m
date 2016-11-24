//
//  DialogPickerView.m
//  TicketProject
//
//  Created by KAI on 15-4-27.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "DialogPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "Globals.h"

@implementation DialogPickerView


- (id)initWithFrame:(CGRect)frame title:(NSString *)title selectIndexDict:(NSMutableDictionary *)selectIndexDict dataDict:(NSMutableDictionary *)dataDict dateType:(BOOL)dateType {
    self = [super initWithFrame:frame];
    if (self) {
        _title = [title copy];
        _selectIndexDict = [selectIndexDict retain];
        _dataDict = [dataDict retain];
        _dateType = dateType;
        
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
    
    [_title release];
    _title = nil;
    [_selectIndexDict release];
    _selectIndexDict = nil;
    [_dataDict release];
    _dataDict = nil;
    
    
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
    promptLabel.text = _title;
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
    if (_dateType) {
        //datePicker 日期选择
        _datePicker = [[UIDatePicker alloc]initWithFrame:pickerViewRect];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_datePicker setMaximumDate:[NSDate date]];
        [_datePicker setCenter:self.center];
        [self addSubview:_datePicker];
        [_datePicker release];
        
        //locale
        NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"Chinese"];
        [_datePicker setLocale:locale];
        [locale release];
        
    } else {
        _pickerView = [[UIPickerView alloc]initWithFrame:pickerViewRect];
        [_pickerView setShowsSelectionIndicator:YES];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [_pickerView setCenter:self.center];
        [self addSubview:_pickerView];
        [_pickerView release];
    }
    
    
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
#pragma mark -UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[[UILabel alloc] init] autorelease];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:XFIponeIpadFontSize13]];
        [pickerLabel setMinimumScaleFactor:0.6];
        [pickerLabel setAdjustsFontSizeToFitWidth:YES];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *array = [_dataDict objectForKey:[NSString stringWithFormat:@"%ld",(long)component]];
    if (array && [array isKindOfClass:[NSArray class]]) {
        if (row < [array count]) {
            return [array objectAtIndex:row];
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_selectIndexDict setObject:[NSNumber numberWithInteger:row] forKey:[NSString stringWithFormat:@"%ld",(long)component]];
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [_dataDict count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *array = [_dataDict objectForKey:[NSString stringWithFormat:@"%ld",(long)component]];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return [array count];
    }
    return 0;
}

#pragma mark -
#pragma mark -Customized(Action)
- (void)okBtnTouchUpInside:(id)sender {
    if (_dateType) {
        NSDate *selectDate = [_datePicker date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit fromDate:selectDate];
        NSInteger year = [components year];
        NSInteger month = [components month];
        NSInteger day = [components day];
        
        [_selectIndexDict setObject:[NSNumber numberWithInteger:year] forKey:@"0"];
        [_selectIndexDict setObject:[NSNumber numberWithInteger:month] forKey:@"1"];
        [_selectIndexDict setObject:[NSNumber numberWithInteger:day] forKey:@"2"];
        
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pickerView:didSelectedDataDictionary:)]) {
            [_delegate pickerView:self didSelectedDataDictionary:_selectIndexDict];
        }
    
    [self fadeOut];
}

- (void)cancleBtnTouchUpInside:(id)sender {
    [self fadeOut];
}

#pragma mark -Customized: Private (General)
- (void)fillPickerViewDate {
    for (NSInteger component = 0; component < [_selectIndexDict count]; component++) {
        NSNumber *selectedRowIndex = [_selectIndexDict objectForKey:[NSString stringWithFormat:@"%ld",(long)component]];
        [_pickerView selectRow:[selectedRowIndex integerValue] inComponent:component animated:YES];
        [self pickerView:_pickerView didSelectRow:[selectedRowIndex integerValue] inComponent:component];
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
