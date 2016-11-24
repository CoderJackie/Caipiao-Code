//
//  DropDownListViewDelegate.h
//  TicketProject
//
//  Created by sls002 on 13-5-21.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//下拉列表协议

#import <Foundation/Foundation.h>

@protocol DropDownListViewDelegate <NSObject>
@optional

- (void)itemSelectedObject:(NSObject *)obj AtRowIndex:(NSInteger)index; //投注方式下拉调用的方法

- (void)itemSelectedObjects:(NSObject *)obj AtRowIndexs:(NSInteger)index isHidden:(BOOL)isHidden; //投注方式下拉调用的方法

- (void)tapBackView;

@end
