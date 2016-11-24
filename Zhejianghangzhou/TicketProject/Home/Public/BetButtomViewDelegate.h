//
//  BetButtomViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BetButtomViewDelegate <NSObject>

@optional
- (void)showAlertViewAndClear;
- (void)payMoney;    //付款

@end
