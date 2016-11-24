//
//  DialogPickerViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-4-27.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DialogPickerView;
@protocol DialogPickerViewDelegate <NSObject>

- (void)pickerView:(DialogPickerView *)pickerView didSelectedDataDictionary:(NSDictionary *)selectData;

@end
