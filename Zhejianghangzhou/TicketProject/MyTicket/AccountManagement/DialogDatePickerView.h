//
//  DialogDatePickerView.h
//  TicketProject
//
//  Created by sls002 on 13-6-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialogDatePickerViewDelegate.h"

@interface DialogDatePickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate> {
    
    UIView *_overlayView; /**< 半透明背景 */
    UIPickerView *_pickerView; /**< 日期滚动框 */
    
    id<DialogDatePickerViewDelegate> _delegate;
    
    NSMutableDictionary *_selectDateDic; /**< 自己选择的日期字典 */
    NSDictionary        *_selectRowDic;  /**< 外部传入的日期字典 */
}

@property (nonatomic, assign) id<DialogDatePickerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame SelectRowDic:(NSDictionary *)rowDic;

- (void)show;

@end
