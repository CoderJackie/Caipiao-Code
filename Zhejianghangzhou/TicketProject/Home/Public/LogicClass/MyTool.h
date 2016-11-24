//
//  MyTool.h
//  TicketProject
//
//  Created by Michael on 10/11/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    NORMAL,
    CHIPPED,
    CHASED
}OrderStatus;


@interface MyTool : NSObject

+ (NSArray *)sortArrayFromSmallToLarge:(NSArray *)array;

+ (BOOL)string:(NSString *)oneStr containCharacter:(NSString *)twoStr;

// 22选5
+ (NSString *)getESEXWBetNumberStringWithOneArray:(NSArray *)onearr
                                        andPlayID:(NSInteger)playid
                                andPlayMethodName:(NSString *)playname;


+ (NSMutableArray *)getSYYDJOrSYXWMethodNameArray;

// 幸运彩
+ (NSString *)getXYCBetNumberStringWithOneArray:(NSArray *)onearr
                                            two:(NSArray *)twoarr
                                          three:(NSArray *)threearr
                                           four:(NSArray *)fourarr
                                           five:(NSArray *)fivearr
                                            six:(NSArray *)sixarr
                                      andPlayID:(NSInteger)playid
                     andFirstViewPlayMethodName:(NSString *)name1
                    andSecondViewPlayMethodName:(NSString *)name2;

// 快赢481
+ (NSInteger)getKY481PlayIdWithBetTeypName:(NSString *)typeName
                               buttonIndex:(NSInteger)index;
+ (NSString *)getKY481BetNumberStringWithOneArray:(NSArray *)onearr
                                              two:(NSArray *)twoarr
                                            three:(NSArray *)threearr
                                             four:(NSArray *)fourarr
                                        andPlayID:(NSInteger)playid
                                andPlayMethodName:(NSString *)playname;

@end
