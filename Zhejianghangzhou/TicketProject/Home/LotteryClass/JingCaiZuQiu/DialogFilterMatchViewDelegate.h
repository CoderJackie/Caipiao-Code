//
//  DialogFilterMatchViewDelegate.h
//  TicketProject
//
//  Created by KAI on 15-1-8.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DialogFilterMatchViewDelegate <NSObject>

-(void)filterMatchesWithType:(NSInteger)type MatchDictionary:(NSDictionary *)matches;

@end
