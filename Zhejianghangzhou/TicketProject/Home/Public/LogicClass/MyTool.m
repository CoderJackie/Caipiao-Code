//
//  MyTool.m        投注号码拼接
//  TicketProject
//
//  Created by Michael on 10/11/13.
//  Copyright (c) 2013 sls002. All rights reserved.
//

#import "MyTool.h"

@implementation MyTool

+ (NSArray *)sortArrayFromSmallToLarge:(NSArray *)array {
    NSComparator comparator = ^(id obj1,id obj2){
        if([obj1 integerValue] > [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
            
        } else if ([obj1 integerValue] < [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
            
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    };
    
    return [array sortedArrayUsingComparator:comparator];
}

+ (BOOL)string:(NSString *)oneStr containCharacter:(NSString *)twoStr {
    BOOL has = NO;
    for (int i = 0; i < oneStr.length; i++) {
        NSString *s = [NSString stringWithFormat:@"%c",[oneStr characterAtIndex:i]];
        if ([s isEqualToString:twoStr]) {
            has = YES;
            break;
        }
    }
    return has;
}

#pragma mark - 22选5
// 22选5
+ (NSString *)getESEXWBetNumberStringWithOneArray:(NSArray *)onearr
                                        andPlayID:(NSInteger)playid
                                andPlayMethodName:(NSString *)playname
{
    NSString *numberStr = [NSString string];

    for (NSNumber *perBetNumber in onearr) {
        NSInteger perBetNum = [perBetNumber integerValue];
        NSString *perbetNumStr;
        if (perBetNum < 10) 
            perbetNumStr = [NSString stringWithFormat:@"0%ld",(long)perBetNum];
        else
            perbetNumStr = [NSString stringWithFormat:@"%ld",(long)perBetNum];
        
        numberStr = [[numberStr stringByAppendingFormat:@" %@",perbetNumStr]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    return numberStr;
}

#pragma mark - 11运夺金
// 11运夺金
+ (NSMutableArray *)getSYYDJOrSYXWMethodNameArray {
    NSMutableArray *betTypeArray = [NSMutableArray array];
    [betTypeArray addObject:@"普通-任二"];
    [betTypeArray addObject:@"普通-任三"];
    [betTypeArray addObject:@"普通-任四"];
    [betTypeArray addObject:@"普通-任五"];
    [betTypeArray addObject:@"普通-任六"];
    [betTypeArray addObject:@"普通-任七"];
    [betTypeArray addObject:@"普通-任八"];
    [betTypeArray addObject:@"普通-前一"];
    [betTypeArray addObject:@"普通-前二直"];
    [betTypeArray addObject:@"普通-前二组"];
    [betTypeArray addObject:@"普通-前三直"];
    [betTypeArray addObject:@"普通-前三组"];
    [betTypeArray addObject:@"胆拖-任二"];
    [betTypeArray addObject:@"胆拖-前三"];
    [betTypeArray addObject:@"胆拖-任四"];
    [betTypeArray addObject:@"胆拖-任五"];
    [betTypeArray addObject:@"胆拖-任六"];
    [betTypeArray addObject:@"胆拖-任七"];
    [betTypeArray addObject:@"胆拖-任八"];
    [betTypeArray addObject:@"胆拖-前二"];
    [betTypeArray addObject:@"胆拖-前三"];
    
    return betTypeArray;
}

#pragma mark - 幸运彩

+ (NSString *)getXYCBetNumberStringWithOneArray:(NSArray *)onearr
                                            two:(NSArray *)twoarr
                                          three:(NSArray *)threearr
                                           four:(NSArray *)fourarr
                                           five:(NSArray *)fivearr
                                            six:(NSArray *)sixarr
                                      andPlayID:(NSInteger)playid
                     andFirstViewPlayMethodName:(NSString *)name1
                    andSecondViewPlayMethodName:(NSString *)name2
{
    NSString *numberStr = [NSString string];
    switch (playid) {
        case 8201:  // 01-    (01)1-   -(12)-
        {
            // one
            if (onearr.count > 0) {
                if (onearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in onearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // two
            if (twoarr.count > 0) {
                if (twoarr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in twoarr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // three
            if (threearr.count > 0) {
                if (threearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in threearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
        }
            break;
        case 8202:  // R1,01 02             R4,01 06 09 10          S3,03 08 09 10 , 01 05 07 , 03 10
        {
            if ([name2 isEqualToString:@"任一"]) {
                numberStr = [numberStr stringByAppendingString:@"R1"];
            } else if ([name2 isEqualToString:@"任二"]) {
                numberStr = [numberStr stringByAppendingString:@"R2"];
            } else if ([name2 isEqualToString:@"任三"]) {
                numberStr = [numberStr stringByAppendingString:@"R3"];
            } else if ([name2 isEqualToString:@"任四"]) {
                numberStr = [numberStr stringByAppendingString:@"R4"];
            } else if ([name2 isEqualToString:@"任五"]) {
                numberStr = [numberStr stringByAppendingString:@"R5"];
            } else if ([name2 isEqualToString:@"任六"]) {
                numberStr = [numberStr stringByAppendingString:@"R6"];
            } else if ([name2 isEqualToString:@"任七"]) {
                numberStr = [numberStr stringByAppendingString:@"R7"];
            } else if ([name2 isEqualToString:@"顺一"]) {
                numberStr = [numberStr stringByAppendingString:@"S1"];
            } else if ([name2 isEqualToString:@"顺二"]) {
                numberStr = [numberStr stringByAppendingString:@"S2"];
            } else if ([name2 isEqualToString:@"顺三"]) {
                numberStr = [numberStr stringByAppendingString:@"S3"];
            }
            
            // four
            if (fourarr.count > 0) {
                numberStr = [numberStr stringByAppendingString:@","];
                NSString *fourString = [NSString string];
                for (NSNumber *perBetNumber in fourarr) {
                    if ([perBetNumber integerValue] < 10)
                        fourString = [fourString stringByAppendingFormat:@"0%@ ",perBetNumber];
                    else
                        fourString = [fourString stringByAppendingFormat:@"%@ ",perBetNumber];
                }
                numberStr = [numberStr stringByAppendingString:[fourString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            
            // five
            if (fivearr.count > 0) {
                numberStr = [numberStr stringByAppendingString:@" , "];
                NSString *fiveString = [NSString string];
                for (NSNumber *perBetNumber in fivearr) {
                    if ([perBetNumber integerValue] < 10)
                        fiveString = [fiveString stringByAppendingFormat:@"0%@ ",perBetNumber];
                    else
                        fiveString = [fiveString stringByAppendingFormat:@"%@ ",perBetNumber];
                }
                numberStr = [numberStr stringByAppendingString:[fiveString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            
            // six
            if (sixarr.count > 0) {
                numberStr = [numberStr stringByAppendingString:@" , "];
                NSString *sixString = [NSString string];
                for (NSNumber *perBetNumber in sixarr) {
                    if ([perBetNumber integerValue] < 10)
                        sixString = [sixString stringByAppendingFormat:@"0%@ ",perBetNumber];
                    else
                        sixString = [sixString stringByAppendingFormat:@"%@ ",perBetNumber];
                }
                numberStr = [numberStr stringByAppendingString:[sixString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
            break;
        case 8203:
        {
            // one
            if (onearr.count > 0) {
                if (onearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in onearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // two
            if (twoarr.count > 0) {
                if (twoarr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in twoarr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // three
            if (threearr.count > 0) {
                if (threearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in threearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            numberStr = [numberStr stringByAppendingString:@"|"];
            
            if ([name2 isEqualToString:@"任一"]) {
                numberStr = [numberStr stringByAppendingString:@"R1"];
            } else if ([name2 isEqualToString:@"任二"]) {
                numberStr = [numberStr stringByAppendingString:@"R2"];
            } else if ([name2 isEqualToString:@"任三"]) {
                numberStr = [numberStr stringByAppendingString:@"R3"];
            } else if ([name2 isEqualToString:@"任四"]) {
                numberStr = [numberStr stringByAppendingString:@"R4"];
            } else if ([name2 isEqualToString:@"任五"]) {
                numberStr = [numberStr stringByAppendingString:@"R5"];
            } else if ([name2 isEqualToString:@"任六"]) {
                numberStr = [numberStr stringByAppendingString:@"R6"];
            } else if ([name2 isEqualToString:@"任七"]) {
                numberStr = [numberStr stringByAppendingString:@"R7"];
            } else if ([name2 isEqualToString:@"顺一"]) {
                numberStr = [numberStr stringByAppendingString:@"S1"];
            } else if ([name2 isEqualToString:@"顺二"]) {
                numberStr = [numberStr stringByAppendingString:@"S2"];
            } else if ([name2 isEqualToString:@"顺三"]) {
                numberStr = [numberStr stringByAppendingString:@"S3"];
            }
            
            // four
            if (fourarr.count > 0) {
                numberStr = [numberStr stringByAppendingString:@","];
                NSString *fourString = [NSString string];
                for (NSNumber *perBetNumber in fourarr) {
                    if ([perBetNumber integerValue] < 10)
                        fourString = [fourString stringByAppendingFormat:@"0%@ ",perBetNumber];
                    else
                        fourString = [fourString stringByAppendingFormat:@"%@ ",perBetNumber];
                }
                numberStr = [numberStr stringByAppendingString:[fourString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            
            // five
            if (fivearr.count > 0) {
                numberStr = [numberStr stringByAppendingString:@","];
                NSString *fiveString = [NSString string];
                for (NSNumber *perBetNumber in fivearr) {
                    if ([perBetNumber integerValue] < 10)
                        fiveString = [fiveString stringByAppendingFormat:@"0%@ ",perBetNumber];
                    else
                        fiveString = [fiveString stringByAppendingFormat:@"%@ ",perBetNumber];
                }
                numberStr = [numberStr stringByAppendingString:[fiveString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            
            // six
            if (sixarr.count > 0) {
                numberStr = [numberStr stringByAppendingString:@","];
                NSString *sixString = [NSString string];
                for (NSNumber *perBetNumber in sixarr) {
                    if ([perBetNumber integerValue] < 10)
                        sixString = [sixString stringByAppendingFormat:@"0%@ ",perBetNumber];
                    else
                        sixString = [sixString stringByAppendingFormat:@"%@ ",perBetNumber];
                }
                numberStr = [numberStr stringByAppendingString:[sixString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
            break;
        default:
            break;
    }
    return numberStr;
}

#pragma mark - 快赢481

+ (NSInteger)getKY481PlayIdWithBetTeypName:(NSString *)typeName buttonIndex:(NSInteger)index
{
    NSInteger playid = 0;
    if ([typeName isEqualToString:@"任选"]) {
        playid = 6801 + index;
    } else if ([typeName isEqualToString:@"直选"]) {
        playid = 6806;
    } else if ([typeName isEqualToString:@"组选"]) {
        switch (index) {
            case 0:
                playid = 6807;
                break;
            case 1:
                playid = 6808;
                break;
            case 2:
            case 3:
                playid = 6809;
                break;
            case 4:
                playid = 6810;
                break;
            case 5:
                playid = 6811;
                break;
            case 6:
            case 7:
                playid = 6812;
                break;
            case 8:
                playid = 6813;
                break;
            case 9:
            case 10:
                playid = 6814;
                break;
            case 11:
                playid = 6815;
                break;
            case 12:
                playid = 6816;
                break;
                
            default:
                break;
        }
    }
    return playid;
}

+ (NSString *)getKY481BetNumberStringWithOneArray:(NSArray *)onearr
                                              two:(NSArray *)twoarr
                                            three:(NSArray *)threearr
                                             four:(NSArray *)fourarr
                                        andPlayID:(NSInteger)playid
                                andPlayMethodName:(NSString *)playname
{
    NSString *numberStr = [NSString string];
    switch (playid) {
        case 6801:      // 任选一
        case 6802:      // 任选二
        case 6804:      // 任选三
        {
            // one
            if (onearr.count > 0) {
                if (onearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in onearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // two
            if (twoarr.count > 0) {
                if (twoarr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in twoarr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // three
            if (threearr.count > 0) {
                if (threearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in threearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
            // four
            if (fourarr.count > 0) {
                if (fourarr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in fourarr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[fourarr objectAtIndex:0]];
                }
            } else {
                numberStr = [numberStr stringByAppendingString:@"-"];
            }
            
        }
            break;
        case 6803:      // 任选二全包
        {
            // one
            if (onearr.count > 0) {
                if (onearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in onearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                }
            }
            
            // two
            if (twoarr.count > 0) {
                if (twoarr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in twoarr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
            }
        }
            break;
        case 6805:      // 任选三全包
        {
            // one
            if (onearr.count > 0) {
                if (onearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in onearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                }
            }
            
            // two
            if (twoarr.count > 0) {
                if (twoarr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in twoarr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
            }
            
            // three
            if (threearr.count > 0) {
                if (threearr.count > 1) {
                    NSString *perBetNumStr = [NSString string];
                    for (NSNumber *perBetNumber in threearr) {
                        perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                    }
                    numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                } else {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                }
            }
        }
            break;
        case 6806:  // 直选(单式、复式)
        {
            if ([playname isEqualToString:@"单 式"]) {
                // one
                if (onearr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                } 
                // two
                if (twoarr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
                
                // three
                if (threearr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                }
              
                // four
                if (fourarr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[fourarr objectAtIndex:0]];
                }
            }
            
            if ([playname isEqualToString:@"复 式"]) {
                // one
                if (onearr.count > 0) {
                    if (onearr.count > 1) {
                        NSString *perBetNumStr = [NSString string];
                        for (NSNumber *perBetNumber in onearr) {
                            perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                        }
                        numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                    } else {
                        numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                    }
                }
                
                // two
                if (twoarr.count > 0) {
                    if (twoarr.count > 1) {
                        NSString *perBetNumStr = [NSString string];
                        for (NSNumber *perBetNumber in twoarr) {
                            perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                        }
                        numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                    } else {
                        numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                    }
                }
                
                // three
                if (threearr.count > 0) {
                    if (threearr.count > 1) {
                        NSString *perBetNumStr = [NSString string];
                        for (NSNumber *perBetNumber in threearr) {
                            perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                        }
                        numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                    } else {
                        numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                    }
                }
                
                // four
                if (fourarr.count > 0) {
                    if (fourarr.count > 1) {
                        NSString *perBetNumStr = [NSString string];
                        for (NSNumber *perBetNumber in fourarr) {
                            perBetNumStr = [perBetNumStr stringByAppendingFormat:@"%@",perBetNumber];
                        }
                        numberStr = [numberStr stringByAppendingFormat:@"(%@)",perBetNumStr];
                    } else {
                        numberStr = [numberStr stringByAppendingFormat:@"%@",[fourarr objectAtIndex:0]];
                    }
                }
            }
        }
            break;
        case 6807:      // 组选24(单式、复式)
        case 6809:      // 组选12(单式、复式)
        case 6812:      // 组选6(单式、复式)
        case 6814:      // 组选4(单式、复式)
        {
            if ([playname isEqualToString:@"单 式"]) {
                // one
                if (onearr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[onearr objectAtIndex:0]];
                }
                // two
                if (twoarr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[twoarr objectAtIndex:0]];
                }
                
                // three
                if (threearr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[threearr objectAtIndex:0]];
                }
                
                // four
                if (fourarr.count > 0) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",[fourarr objectAtIndex:0]];
                }
            }
            
            if ([playname isEqualToString:@"复 式"]) {
                for (NSNumber *perBetNumber in onearr) {
                    numberStr = [numberStr stringByAppendingFormat:@"%@",perBetNumber];
                }
                numberStr = [NSString stringWithFormat:@"(%@)",numberStr];
            }
        }
            break;
        case 6808:          // 组选24胆拖
        case 6810:          // 组选12胆拖
        case 6811:          // 组选12重胆拖
        case 6813:          // 组选6胆拖
        case 6815:          // 组选4胆拖
        case 6816:          // 组选4重胆拖
        {
            NSString *dan = [NSString string];
            for (NSNumber *perBetNumber in onearr) {
                dan = [dan stringByAppendingFormat:@"%@",perBetNumber];
            }
            
            NSString *tuo = [NSString string];
            for (NSNumber *perBetNumber in twoarr) {
                tuo = [tuo stringByAppendingFormat:@"%@",perBetNumber];
            }
            numberStr = [NSString stringWithFormat:@"%@,%@",dan,tuo];
        }
            break;
        default:
            break;
    }
    return numberStr;
}

#pragma mark - 双色球
-(NSString *)changeSSQWithRedArray:(NSArray *)red TuoArray:(NSArray *)tuoArray BlueArray:(NSArray *)blue Type:(NSInteger)type
{
    NSString *num = [NSString string];
    NSString *tuoNum = [NSString string];
    NSString *blueNum = [NSString string];
    
    for (NSString *str in red) {
        num = [num stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    
    if(tuoArray != nil)
    {
        for (NSString *str in tuoArray) {
            tuoNum = [tuoNum stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
        }
    }
    
    for (NSString *str in blue  ) {
        blueNum = [blueNum stringByAppendingString:[NSString stringWithFormat:@"%@ ",str]];
    }
    
    if(type == 501)
    {
        //去掉最后一个空格
        NSRange range = NSMakeRange(0, num.length - 1);
        num = [num substringWithRange:range];
        
        num = [num stringByAppendingFormat:@"-%@",blueNum];
    }
    else if (type == 502)
    {
        NSRange range = NSMakeRange(0, tuoNum.length - 1);
        tuoNum = [tuoNum substringWithRange:range];
        
        NSRange range1 = NSMakeRange(0, blueNum.length - 1);
        blueNum = [blueNum substringWithRange:range1];
        
        num = [num stringByAppendingFormat:@", %@-%@",tuoNum,blueNum];
    }
    
    return num;
}

@end
