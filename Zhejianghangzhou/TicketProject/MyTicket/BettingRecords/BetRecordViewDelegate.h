//
//  BetRecordViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BetRecordTypeOfAll,
    BetRecordTypeOfWin,
    BetRecordTypeOfLose,
    BetRecordTypeOfChase,
    BetRecordTypeOfTogether,
} BetRecordType;

@protocol BetRecordViewDelegate <NSObject>

- (void)selectBetRecordCell:(NSDictionary*)dic indexPage:(NSInteger)index;

@end
