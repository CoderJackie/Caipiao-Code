//
//  SelectBallsDetailViewControllerDelegate.h
//  TicketProject
//
//  Created by sls002 on 13-5-29.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

//详细页面的委托方法  更新选球后 刷新列表
@protocol SelectBallsDetailViewControllerDelegate <NSObject>

@optional
- (void)updateSelectBallsDic:(NSDictionary *)dic AtRowIndex:(NSInteger)index;
- (void)updateSelect;

@end
