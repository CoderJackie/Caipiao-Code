//
//  RandomNumber.h
//  TicketProject
//
//  Created by sls002 on 13-5-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomNumber : NSObject

-(NSInteger)randomBallInRect:(NSArray *)array MaxNumber:(NSInteger)maxNum MinNumber:(NSInteger)minNum;

-(NSInteger)randomBallInRectForDLTandSSQ:(NSArray *)array MaxNumber:(NSInteger)maxNum MinNumber:(NSInteger)minNum;

-(NSInteger)getRandomInRect:(NSArray *)array;

-(NSArray *)getRandomListWithMaxNum:(NSInteger)max LoopCount:(NSInteger)loopCount;


+ (NSArray *)getRandomsBetweenMaxNum:(NSInteger)maxNum minNum:(NSInteger)minNum andExpectedRandomCounts:(NSInteger)count;

+ (NSInteger)getAnRandomBetweenMaxNum:(NSInteger)maxNum minNum:(NSInteger)minNum;
@end
