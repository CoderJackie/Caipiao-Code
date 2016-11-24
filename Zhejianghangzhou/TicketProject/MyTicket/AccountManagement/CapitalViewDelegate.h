//
//  CapitalViewDelegate.h
//  TicketProject
//
//  Created by kiu on 15/7/13.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CapitalTypeOfAll,
    CapitalTypeOfBet,
    CapitalTypeOfWin,
    CapitalTypeOfRecharge,
    CapitalTypeOfWithdrawals,
} CapitalType;

@protocol CapitalViewDelegate <NSObject>

- (void)selectCapitalCell:(NSDictionary*)dic indexPage:(NSInteger)index;

@end
