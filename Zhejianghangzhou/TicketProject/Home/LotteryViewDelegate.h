//
//  LotteryViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LotteryViewDelegate <NSObject>

- (void)didSelectLotteryViewWithLotteryId:(NSString *)lotteryId row:(NSInteger)row col:(NSInteger)col;

@end
