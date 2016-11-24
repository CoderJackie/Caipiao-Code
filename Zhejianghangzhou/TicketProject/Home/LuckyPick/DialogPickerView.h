//
//  DialogPickerView.h
//  TicketProject
//
//  Created by KAI on 15-4-27.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogPickerViewDelegate.h"

@interface DialogPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate> {
    UIView       *_overlayView; /**< 半透明背景 */
    UIDatePicker *_datePicker;
    UIPickerView *_pickerView;  /**< 日期滚动框 */
    
    id<DialogPickerViewDelegate> _delegate;
    
    NSMutableDictionary *_selectDateDic; /**< 自己选择的日期字典 */
    NSDictionary        *_selectRowDic;  /**< 外部传入的日期字典 */
    
    
    NSMutableDictionary *_selectIndexDict;
    NSMutableDictionary *_dataDict;
    NSString            *_title;
    BOOL                 _dateType;
}

@property (nonatomic, assign) id<DialogPickerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title selectIndexDict:(NSMutableDictionary *)selectIndexDict dataDict:(NSMutableDictionary *)dataDict dateType:(BOOL)dateType;

- (void)show;

@end
