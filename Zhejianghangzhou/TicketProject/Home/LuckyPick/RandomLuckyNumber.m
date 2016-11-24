//
//  RandomLuckyNumber.m
//  TicketProject
//
//  Created by sls002 on 13-7-12.
//  Copyright (c) 2013年 sls002. All rights reserved.
//

#import "RandomLuckyNumber.h"
#import "RandomNumber.h"
#import "CalculateBetCount.h"

@implementation RandomLuckyNumber

+ (NSString *)getSSQRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    NSMutableArray *redArray = [NSMutableArray arrayWithCapacity:6];
    for (NSInteger i = 0; i < 6; i++) {
        NSInteger randomBall = [random randomBallInRect:redArray MaxNumber:33 MinNumber:1];
        [redArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *blueArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:blueArray MaxNumber:16 MinNumber:1];
        [blueArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    NSArray *redArrayStr = [cal convertToStringArrayWith:redArray];
    NSArray *blueArraySte = (NSMutableArray *)[cal convertToStringArrayWith:blueArray];
    
    NSString *selectBallsStr = [cal changeSSQWithRedArray:redArrayStr TuoArray:nil BlueArray:blueArraySte Type:501];
    
    return selectBallsStr;
}

+ (NSString *)getDLTRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *redArray = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger i = 0; i < 5; i++) {
        NSInteger randomBall = [random randomBallInRect:redArray MaxNumber:35 MinNumber:1];
        [redArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *blueArray = [NSMutableArray arrayWithCapacity:2];
    for (NSInteger i = 0; i < 2; i++) {
        NSInteger randomBall = [random randomBallInRect:blueArray MaxNumber:12 MinNumber:1];
        [blueArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    redArray = (NSMutableArray *)[cal convertToStringArrayWith:redArray];
    blueArray = (NSMutableArray *)[cal convertToStringArrayWith:blueArray];
    
    NSString *selectBallsStr = [cal changeSSQWithRedArray:redArray TuoArray:nil BlueArray:blueArray Type:501];
    
    return selectBallsStr;
}

+ (NSString *)get3DRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *hundredsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:hundredsArray MaxNumber:9 MinNumber:0];
        [hundredsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *decadeArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:decadeArray MaxNumber:9 MinNumber:0];
        [decadeArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *bitsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:bitsArray MaxNumber:9 MinNumber:0];
        [bitsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSString *selectBallsStr = [NSString string];
    for (NSNumber *ballNum in hundredsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@","];
    
    for (NSNumber *ballNum in decadeArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@","];
    
    for (NSNumber *ballNum in bitsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }

    return selectBallsStr;
}

+ (NSString *)getQLCRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *redArray = [NSMutableArray arrayWithCapacity:7];
    for (NSInteger i = 0; i < 7; i++) {
        NSInteger randomBall = [random randomBallInRect:redArray MaxNumber:30 MinNumber:1];
        [redArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    redArray = (NSMutableArray *)[cal convertToStringArrayWith:redArray];
    
    NSString *selectBallsStr = [NSString string];
    for (NSString *ballStr in redArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%@ ",ballStr];
    }

    return selectBallsStr;
}

+ (NSString *)getQXCRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *oneArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:oneArray MaxNumber:9 MinNumber:0];
        [oneArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *twoArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:twoArray MaxNumber:9 MinNumber:0];
        [twoArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *threeArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:threeArray MaxNumber:9 MinNumber:0];
        [threeArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    NSMutableArray *fourArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:fourArray MaxNumber:9 MinNumber:0];
        [fourArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    NSMutableArray *fiveArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:fiveArray MaxNumber:9 MinNumber:0];
        [fiveArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    NSMutableArray *sixArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:sixArray MaxNumber:9 MinNumber:0];
        [sixArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    NSMutableArray *sevenArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:sevenArray MaxNumber:9 MinNumber:0];
        [sevenArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSString *selectBallsStr = [NSString string];
    for (NSNumber *ballNum in oneArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in twoArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in threeArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    for (NSNumber *ballNum in fourArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    for (NSNumber *ballNum in fiveArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    for (NSNumber *ballNum in sixArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    for (NSNumber *ballNum in sevenArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }

    return selectBallsStr;
}

+ (NSString *)getPL3RandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *hundredsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:hundredsArray MaxNumber:9 MinNumber:0];
        [hundredsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *decadeArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:decadeArray MaxNumber:9 MinNumber:0];
        [decadeArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *bitsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:bitsArray MaxNumber:9 MinNumber:0];
        [bitsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSString *selectBallsStr = [NSString string];
    for (NSNumber *ballNum in hundredsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in decadeArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in bitsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }

    return selectBallsStr;
}

+ (NSString *)getPL5RandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *tenThousandArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:tenThousandArray MaxNumber:9 MinNumber:0];
        [tenThousandArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *thousandArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:thousandArray MaxNumber:9 MinNumber:0];
        [thousandArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *hundredsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:hundredsArray MaxNumber:9 MinNumber:0];
        [hundredsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *decadeArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:decadeArray MaxNumber:9 MinNumber:0];
        [decadeArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *bitsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:bitsArray MaxNumber:9 MinNumber:0];
        [bitsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSString *selectBallsStr = [NSString string];
    
    for (NSNumber *ballNum in tenThousandArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in thousandArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    for (NSNumber *ballNum in hundredsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in decadeArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in bitsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    
    return selectBallsStr;
}

+ (NSString *)getSSCRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *tenThousandArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:tenThousandArray MaxNumber:9 MinNumber:0];
        [tenThousandArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *thousandArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:thousandArray MaxNumber:9 MinNumber:0];
        [thousandArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *hundredsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:hundredsArray MaxNumber:9 MinNumber:0];
        [hundredsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *decadeArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:decadeArray MaxNumber:9 MinNumber:0];
        [decadeArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSMutableArray *bitsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSInteger i = 0; i < 1; i++) {
        NSInteger randomBall = [random randomBallInRect:bitsArray MaxNumber:9 MinNumber:0];
        [bitsArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    NSString *selectBallsStr = [NSString string];
    
    for (NSNumber *ballNum in tenThousandArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in thousandArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    for (NSNumber *ballNum in hundredsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in decadeArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    selectBallsStr = [selectBallsStr stringByAppendingString:@" "];
    
    for (NSNumber *ballNum in bitsArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%d",[ballNum intValue]];
    }
    
    return selectBallsStr;
}

+ (NSString *)getSYYDJRandomNumber {
    RandomNumber *random = [[[RandomNumber alloc]init]autorelease];
    
    NSMutableArray *redArray = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger i = 0; i < 5; i++) {
        NSInteger randomBall = [random randomBallInRect:redArray MaxNumber:11 MinNumber:1];
        [redArray addObject:[NSNumber numberWithInteger:randomBall]];
    }
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    redArray = (NSMutableArray *)[cal convertToStringArrayWith:redArray];
    
    NSString *selectBallsStr = [NSString string];
    for (NSString *ballStr in redArray) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%@ ",ballStr];
    }
    
    return selectBallsStr;
}

+ (NSString *)getSSLRandomNumber {
    NSArray *array = [NSArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:9
                                                                            minNum:0
                                                           andExpectedRandomCounts:3]];
    NSString *selectBallsStr = [NSString string];
    for (NSNumber *ballNum in array) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%@ ",ballNum];
    }
    return selectBallsStr;
}
//甘肃快3
+ (NSString *)getGSK3 {
    NSArray *array = [NSArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:6
                                                                            minNum:1
                                                           andExpectedRandomCounts:3]];
    NSString *selectBallsStr = [NSString string];
    for (NSNumber *ballNum in array) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%@ ",ballNum];
    }
    return selectBallsStr;
}

+ (NSString *)getSYXWRandomNumber {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[RandomNumber getRandomsBetweenMaxNum:11 minNum:1 andExpectedRandomCounts:5]];
    
    CalculateBetCount *cal = [[[CalculateBetCount alloc]init]autorelease];
    array = (NSMutableArray *)[cal convertToStringArrayWith:array];
    
    NSString *selectBallsStr = [NSString string];
    for (NSString *ballStr in array) {
        selectBallsStr = [selectBallsStr stringByAppendingFormat:@"%@ ",ballStr];
    }
    
    return selectBallsStr;
}

@end
