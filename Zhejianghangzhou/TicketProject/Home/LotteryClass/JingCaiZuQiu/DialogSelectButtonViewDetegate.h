//
//  DialogSelectButtonViewDetegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DialogFootBallDefault = 0,
    DialogFootBallScore,
    DialogFootBallTotalGoal,
    DialogFootBallHalf,
    DialogFootBallMix,
    DialogBasketBallMinusScore,
    DialogBasketBallMix,
} DialogType;

@protocol DialogSelectButtonViewDetegate <NSObject>

- (void)dialogSelectMatch:(NSMutableArray *)selectMatchArray selectMatchText:(NSMutableArray *)selectMatchText dialogType:(DialogType)dialogType indexPath:(NSIndexPath *)indexPath;

@end
