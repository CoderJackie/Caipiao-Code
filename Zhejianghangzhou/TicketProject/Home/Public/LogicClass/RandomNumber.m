//
//  RandomNumber.m
//  TicketProject
//
//  Created by sls002 on 13-5-25.
//  Copyright (c) 2013年 sls002. All rights reserved.
//
//生成随机号码

#import "RandomNumber.h"

@implementation RandomNumber

//在一定范围内取随机数   这样可以保证取的随机数不一样
- (NSInteger)randomBallInRect:(NSArray *)array MaxNumber:(NSInteger)maxNum MinNumber:(NSInteger)minNum {
    NSMutableArray *wholeBalls = [NSMutableArray arrayWithCapacity:maxNum];//全部球的数组
    for (NSInteger i = minNum; i <= maxNum; i++) {
        [wholeBalls addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger j = 0; j < array.count; j++) {
        NSInteger index = [(NSNumber *)[array objectAtIndex:j] intValue];
        [wholeBalls replaceObjectAtIndex:(index - 1) withObject:[NSNumber numberWithInt:-1]];//如果已经出现过该数  则从全部球的数组中删除
    }
    
    NSInteger randomBall = 0;
    BOOL boolTemp = YES;
    while (boolTemp) {
        randomBall = arc4random() % maxNum + 1;  //随机数 1~33的随机数
        if([(NSNumber *)[wholeBalls objectAtIndex:(randomBall - 1)]intValue] != -1) {
            boolTemp = NO;
        }
    }
    
    NSInteger result = [(NSNumber *)[wholeBalls objectAtIndex:(randomBall - 1)]intValue];
    return result;
}

- (NSInteger)randomBallInRectForDLTandSSQ:(NSArray *)array MaxNumber:(NSInteger)maxNum MinNumber:(NSInteger)minNum {
    NSMutableArray *wholeBalls = [NSMutableArray arrayWithCapacity:maxNum];//全部球的数组
    for (NSInteger i = minNum; i <= maxNum; i++) {
        // 0 1 2 3 4 5 6 7 8 9
        [wholeBalls addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger j = 0; j < array.count; j++) {
        NSInteger index = [(NSNumber *)[array objectAtIndex:j] intValue];
        [wholeBalls replaceObjectAtIndex:(index - 1) withObject:[NSNumber numberWithInt:-1]];//如果已经出现过该数  则从全部球的数组中删除

    }
    
    NSInteger randomBall = 0;
    BOOL boolTemp = YES;
    while (boolTemp) {
        randomBall = arc4random() % maxNum + 1;  //随机数 1~33的随机数
        if([(NSNumber *)[wholeBalls objectAtIndex:(randomBall - 1)]intValue] != -1) {
            boolTemp = NO;
        }
    }
    
    NSInteger result = [(NSNumber *)[wholeBalls objectAtIndex:(randomBall - 1)]intValue];
    return result;
}

//在一定范围内 取一个随机数 可以有相同的
- (NSInteger)getRandomInRect:(NSArray *)array {
    NSInteger random = arc4random() % array.count;
    
    return [[array objectAtIndex:random] intValue];
}

//获取不相同的一串随机数
- (NSArray *)getRandomListWithMaxNum:(NSInteger)max LoopCount:(NSInteger)loopCount {
    NSMutableArray *randomList = [NSMutableArray array];

    NSInteger random = 0;
    while (randomList.count < loopCount) {
        random = arc4random() % max;
        
        if([randomList containsObject:[NSString stringWithFormat:@"%ld",(long)random]]) {
            continue;
        }
        [randomList addObject:[NSString stringWithFormat:@"%ld",(long)random]];
    }

    return randomList;
}

// 在minNum和maxNum之间取count个不同的随机数
+ (NSArray *)getRandomsBetweenMaxNum:(NSInteger)maxNum minNum:(NSInteger)minNum andExpectedRandomCounts:(NSInteger)count {
    if (maxNum <= minNum)
        return nil;
    
	// 取在这个范围内的所有数
	NSMutableArray *alls = [NSMutableArray array];
	for (NSInteger i = minNum; i <= maxNum; i++) {
		[alls addObject:[NSNumber numberWithInteger:i]];
	}
	
	NSMutableArray *expectedArray = [NSMutableArray array];
    
	// 首先取一个随机数，加入到数组中
    NSInteger firsRandom = [self getAnRandomBetweenMaxNum:maxNum minNum:minNum];
	[expectedArray addObject:[NSNumber numberWithInteger:firsRandom]];
	
	// 遍历区间内所有的数，把其中等于firsRandom的对象删除
	for (NSNumber *tmpObject in alls) {
		if ([tmpObject intValue] == firsRandom) {
			[alls removeObject:tmpObject];
            break;
		}
	}
    
	for (NSInteger i = 0; i < count - 1; i++) {
		// 取一个随机值
        NSInteger tmpRandom = [self getAnRandomBetweenMaxNum:maxNum minNum:minNum];
		// 检查该随机值是否已存在
		for (NSInteger j = 0 ; j < expectedArray.count; j++) {
			NSInteger numberInExpectedArray = [[expectedArray objectAtIndex:j] intValue];
			// 如果已经存在
			if (tmpRandom == numberInExpectedArray) {
				// 因为alls数组中不存在该随机值了（已被删除），则另再alls数组中取出一个任意值赋给tmpRandom
                NSInteger ranomIndexInALls = 0;
                if ([alls count] > 0) {
                    ranomIndexInALls = arc4random() % (alls.count);
                }
				tmpRandom = [[alls objectAtIndex:ranomIndexInALls] intValue];
			}
		}
		NSNumber *aNumber = [NSNumber numberWithInteger:tmpRandom];
		[expectedArray addObject:aNumber];
		// 每加一个随机值，都要把alls中相对应的值删掉，以便下一次遍历的时候不会出现同样的对象
		[alls removeObject:aNumber];
	}
	return expectedArray;
}

// 取一个在min和max之间的随机数
+ (NSInteger)getAnRandomBetweenMaxNum:(NSInteger)maxNum minNum:(NSInteger)minNum {
    NSInteger random;
    if (minNum == 0) {
        random = arc4random() % (maxNum + 1);
    } else {
        random = arc4random() % (maxNum + 1);
        if (random < minNum)
            return random + minNum;
        else
            return random;
    }
    return random;
}

@end
