//
//  CustomParserNumber.m
//  TicketProject
//
//  Created by KAI on 14-10-16.
//  Copyright (c) 2014年 sls002. All rights reserved.
//

#import "CustomParserNumber.h"
#import "MyTool.h"

#define kSSQRedBallNormalCounts                 6       // 标准红球个数(开奖时)，也就是最少选择的个数
#define kSSQBlueBallNormalCounts                1       // 标准蓝球个数(开奖时)，也就是最少选择的个数

#define kDLTRedBallNormalCounts                 5       // 标准红球个数(开奖时)，也就是最少选择的个数
#define kDLTBlueBallNormalCounts                2       // 标准蓝球个数(开奖时)，也就是最少选择的个数

@implementation CustomParserNumber


/** 根据号码返回ballView的名字
 @param str  需要判断的字符串
 @return 是否是整数 YES,NO
 */
+ (NSString *)numberBallViewName:(NSInteger)num {
    switch (num) {
        case 0:
            return @"oneViewBalls";
            break;
        case 1:
            return @"twoViewBalls";
            break;
        case 2:
            return @"threeViewBalls";
            break;
        case 3:
            return @"fourViewBalls";
            break;
        case 4:
            return @"fiveViewBalls";
            break;
        case 5:
            return @"sixViewBalls";
            break;
        case 6:
            return @"sevenViewBalls";
            break;
        default:
            break;
    }
    return @"";
}

/** 判断传入的字符串是否是整数  例如001 或 100 都属于整数
 @param str  需要判断的字符串
 @return 是否是整数 YES,NO
 */
+ (BOOL)isNumText:(NSString *)str {
    NSString * regex        = @"^[0-9]*$";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    } else {
        return NO;
    }
}

/** 1将服务器传回的号码拆分成单独的号码存进ballview   可以根据-+,|()这三个特殊符号分组，如果无这些符号则分为一组  号码为数字可以为多位数也可以为个位数，每个号码是用空格分开的情况
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_1_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除分组号码的前后空格
        
        if (onlyRedBlueBallString.length == 0) {
            continue;
        }
        
        NSArray *onlySingleRedBlueBallArray = [onlyRedBlueBallTrimmedString componentsSeparatedByString:@" "];//根据空格分割号码
        NSMutableArray *ballNumArray = [NSMutableArray array];//存ballview的号码
        for (NSString *ballNumString in onlySingleRedBlueBallArray) {
            [ballNumArray addObject:[NSNumber numberWithInteger:[ballNumString integerValue]]];
            hasBall = YES;
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    }
    return hasBall;
}

/** 2将服务器传回的号码拆分成单独的号码存进ballview   可以根据-+,|()特殊符号分组，如果无这些符号则分为一组   可能包含*的情况(*则表示该组无选号)   号码为数字且只有个位数
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_2_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    for (NSString *onlyRedBlueBallString in numberArray) {
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去掉分组号码前后空格
        onlyRedBlueBallTrimmedString = [onlyRedBlueBallTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];//消去该分组号码的所有空格
        if (onlyRedBlueBallTrimmedString.length == 0) {
            continue;
        }
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        for (NSInteger charartInt = 0; charartInt < onlyRedBlueBallTrimmedString.length; charartInt++) {
            
            NSString *singleNum = [onlyRedBlueBallTrimmedString substringWithRange:NSMakeRange(charartInt, 1)];//一个一个字符去取组号码，（因为号码都是个位数且已经消去空格）
            if ([singleNum isEqualToString:@"*"]) {
                break;
            }
            [ballNumArray addObject:[NSNumber numberWithInteger:[singleNum integerValue]]];//存入号码
            
            hasBall = YES;
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    }
    return hasBall;
}

/** 3将服务器传回的号码拆分成单独的号码存进ballview   可以根据-+,|()特殊符号分组，如果无这些符号则分为一组   号码为数字且只有个位数  第一组号码为相同数字，并只取第一组的第一个字符的情况，其他组号码全取
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_3_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        onlyRedBlueBallTrimmedString = [onlyRedBlueBallTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];//消去该分组号码的所有空格
        if (onlyRedBlueBallTrimmedString.length == 0) {
            continue;
        }
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        for (NSInteger charartInt = 0 ;charartInt < onlyRedBlueBallTrimmedString.length;charartInt++) {
            
            NSInteger singleNum = [[onlyRedBlueBallTrimmedString substringWithRange:NSMakeRange(charartInt, 1)] intValue];
            [ballNumArray addObject:[NSNumber numberWithInteger:singleNum]];
            if (ballViewNum == 0) {
                break;
            }
            hasBall = YES;
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    }
    
    return hasBall;
}

/** 4将服务器传回的号码拆分成单独的号码存进ballview   可以根据-+,|()特殊符号分组，如果无这些符号则分为一组   每组号码只取每组的第一个字符   且所有组的号码都拼接为一组，即在第一个view中
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_4_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    
    NSMutableArray *ballNumArray = [NSMutableArray array];
    for(NSString *onlyRedBallString in numberArray) {
        onlyRedBallString = [onlyRedBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (onlyRedBallString.length == 0) {
            continue;
        }
        NSString *ballNum = [onlyRedBallString substringWithRange:NSMakeRange(0, 1)];
        
        [ballNumArray addObject:[NSNumber numberWithInteger:[ballNum integerValue]]];
        
        hasBall = YES;
    }
    [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    return hasBall;
}

+ (BOOL)splitBallViewNumber_44_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString{
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 2;//属于第几个ballview的号码
    
    NSMutableArray *ballNumArray = [NSMutableArray array];
    for(NSString *onlyRedBallString in numberArray) {
        onlyRedBallString = [onlyRedBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (onlyRedBallString.length == 0) {
            continue;
        }
        NSString *ballNum = [onlyRedBallString substringWithRange:NSMakeRange(0, 1)];
        
        [ballNumArray addObject:[NSNumber numberWithInteger:[ballNum integerValue]]];
        
        hasBall = YES;
    }
    [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    return hasBall;
}

/** 5将服务器传回的号码拆分成单独的号码存进ballview  在()括号内为一组，不是在()内的号码每个单独为一组的情况    号码只能为个位数
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @param ballNumArrayKeyNameType 存入的数字类型
 @param deleteLine 是否需要过滤－
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_5_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString ballNumArrayKeyNameType:(BallNumArrayKeyType)ballNumArrayKeyNameType deleteLine:(BOOL)deleteLine {
    if (deleteLine) {
        selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@"-" withString:@""];//去掉-+|,等特殊符号
    }
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@"+" withString:@""];
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@"|" withString:@""];
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@"," withString:@""];
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];//消去该分组号码的所有空格
    
    BOOL rightBracket = YES;
    for(NSInteger charartInt = 0; charartInt < selectBallsTrimmedString.length ;charartInt++) {
        NSString *charSign = [selectBallsTrimmedString substringWithRange:NSMakeRange(charartInt, 1)];
        if ([charSign isEqual:@"("]) {
            rightBracket = NO;
            continue;
        } else if ([charSign isEqual:@")"]) {
            rightBracket = YES;
            continue;
        } else if ([charSign isEqual:@"-"]) {
            NSMutableArray *ballNumArray = [NSMutableArray array];
            [dict setObject:ballNumArray forKey:[NSString stringWithFormat:@"%ld",(long)ballViewNum++]];
            continue;
        }
        
        
        if (rightBracket == YES) {
            NSMutableArray *ballNumArray = [NSMutableArray array];
            [ballNumArray addObject:[NSNumber numberWithInteger:[charSign integerValue]]];
            if (ballNumArrayKeyNameType == BallNumArrayKeyTypeOfName) {
                [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
            } else if (ballNumArrayKeyNameType == BallNumArrayKeyTypeOfNum) {
                [dict setObject:ballNumArray forKey:[NSString stringWithFormat:@"%ld",(long)ballViewNum++]];
            }
            
            hasBall = YES;
        } else {
            NSMutableArray *ballNumArray = [NSMutableArray array];
            for (; charartInt < selectBallsTrimmedString.length; charartInt++) {
                charSign = [selectBallsTrimmedString substringWithRange:NSMakeRange(charartInt, 1)];
                if ([charSign isEqual:@")"]) {
                    
                    rightBracket = YES;
                    break;
                }
                [ballNumArray addObject:[NSNumber numberWithInteger:[charSign integerValue]]];
            }
            if (ballNumArrayKeyNameType == BallNumArrayKeyTypeOfName) {
                [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
            } else if (ballNumArrayKeyNameType == BallNumArrayKeyTypeOfNum) {
                [dict setObject:ballNumArray forKey:[NSString stringWithFormat:@"%ld",(long)ballViewNum++]];
            }
            
            hasBall = YES;
        }
    }
    return hasBall;
}

/** 6将服务器传回的号码拆分成单独的号码存进ballview  每个号码为独立一组的view，且每个号码都是个位数  －－－－(“组三单式”特殊的第二个号码不取，第三个号码为第二个view的)
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @param playTypeName 玩法名
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_6_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString playTypeName:(NSString *)playTypeName {
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];//消去该分组号码的所有空格
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    for (NSString *onlyRedBlueBallString in numberArray) {
        for (NSInteger charartInt = 0 ;charartInt < onlyRedBlueBallString.length;charartInt++) {
            
            NSInteger singleNum = [[onlyRedBlueBallString substringWithRange:NSMakeRange(charartInt, 1)] intValue];
            
            if (charartInt == 1 && [playTypeName isEqualToString:@"组三单式"]) {
                continue;
            }
            
            hasBall = YES;
            
            NSMutableArray *ballNumArray = [NSMutableArray array];
            [ballNumArray addObject:[NSNumber numberWithInteger:singleNum]];
            [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
        }
    }
    
    return hasBall;
}

/** 7将服务器传回的号码拆分成单独的号码存进ballview   根据-+,|()特殊符号分割号码,不包含特殊符号就相当于只有一个号码，所有号码都在第一组
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_7_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    NSMutableArray *ballNumArray = [NSMutableArray array];
    for (NSInteger numInt = 0 ;numInt < [numberArray count];numInt++) {
        
        NSInteger singleNum = [[numberArray objectAtIndex:numInt] integerValue];
        [ballNumArray addObject:[NSNumber numberWithInteger:singleNum]];
        hasBall = YES;
    }
    [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    
    return hasBall;
}

/** 8将服务器传回的号码拆分成单独的号码存进ballview   可以根据-+,|()这三个特殊符号为号码分组 主要大小单双，且存入的是文字非数字，选号页面是根据单个文字选号的情况
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_8_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (onlyRedBlueBallString.length == 0) {
            continue;
        }
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        
        if ([numberArray count] == 1) {//例如大小单双的，如果只有“单单”，只出现一个数组的情况，因为是后台返回
            for (NSInteger i = 0; i < onlyRedBlueBallTrimmedString.length; i++) {
                NSMutableArray *secondNumArray = [NSMutableArray array];
                
                [secondNumArray addObject:[onlyRedBlueBallTrimmedString substringWithRange:NSMakeRange(i,1)]];
                [dict setObject:secondNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
            }
            
        } else { //文字
            for (NSInteger i = 0; i < onlyRedBlueBallTrimmedString.length; i++) {
                [ballNumArray addObject:[onlyRedBlueBallTrimmedString substringWithRange:NSMakeRange(i,1)]];
            }
            [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
        }
        hasBall = YES;
        
        
    }
    return hasBall;
}

/** 9将服务器传回的号码拆分成单独的号码存进ballview   根据-+,|()特殊符号为号码分组，只能是个位数字，第一组只取前一个号码存入第1个view，第二组号码忽略，第三组全取存入第2个view
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_9_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    
    
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (onlyRedBlueBallString.length == 0) {
            continue;
        }
        NSMutableArray *ballNumArray = [NSMutableArray array];
        if (ballViewNum == 0) {
            [ballNumArray addObject:[NSNumber numberWithInteger:[onlyRedBlueBallString integerValue]]];
            hasBall = YES;
            [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:0]];
            
        } else if (ballViewNum == 1) {
            
        } else if (ballViewNum == 2) {
            for (NSInteger charartInt = 0 ;charartInt < onlyRedBlueBallTrimmedString.length;charartInt++) {
                
                NSInteger singleNum = [[onlyRedBlueBallTrimmedString substringWithRange:NSMakeRange(charartInt, 1)] intValue];
                [ballNumArray addObject:[NSNumber numberWithInteger:singleNum]];
                hasBall = YES;
            }
            [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:1]];
        }
        
        ballViewNum++;
    }
    
    return hasBall;
}

/** 10将服务器传回的号码拆分成单独的号码存进ballview   根据-+,|()特殊符号号码为号码分组,如果字符串是“大”“奇”，则存入数字0，其他为数字1
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_10_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (onlyRedBlueBallString.length == 0) {
            continue;
        }
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        if([onlyRedBlueBallTrimmedString isEqualToString:@"大"] || [onlyRedBlueBallTrimmedString isEqualToString:@"奇"]) {
            [ballNumArray addObject:[NSNumber numberWithInteger:0]];
        } else {
            [ballNumArray addObject:[NSNumber numberWithInteger:1]];
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
        hasBall = YES;
    }
    
    return hasBall;
}

+ (BOOL)splitBallViewNumber_101_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    selectBallsTrimmedString = [selectBallsTrimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];//根据-+,|()的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 1;//属于第几个ballview的号码
    
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (onlyRedBlueBallString.length == 0) {
            continue;
        }
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        if([onlyRedBlueBallTrimmedString isEqualToString:@"大"] || [onlyRedBlueBallTrimmedString isEqualToString:@"奇"]) {
            [ballNumArray addObject:[NSNumber numberWithInteger:0]];
        } else {
            [ballNumArray addObject:[NSNumber numberWithInteger:1]];
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
        hasBall = YES;
    }
    
    return hasBall;
}

/** 11将服务器传回的号码拆分成单独的号码存进ballview   可以根据 特殊符号分组，如果分割有@""则该组号码为空 号码为数字且只有个位数
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_11_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];//根据空格分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        if (onlyRedBlueBallString.length == 0) {
            [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
            continue;
        }
        
        for (NSInteger charartInt = 0 ;charartInt < onlyRedBlueBallString.length;charartInt++) {
            NSInteger singleNum = [[onlyRedBlueBallString substringWithRange:NSMakeRange(charartInt, 1)] intValue];
            [ballNumArray addObject:[NSNumber numberWithInteger:singleNum]];
            hasBall = YES;
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
    }
    
    return hasBall;
}

/** 12将服务器传回的号码拆分成单独的号码存进ballview   根据-+,|()特殊符号号码为号码分组,如果字符串是“大”，则存入数字0，其他为数字1   这是专门为趣味二星写的
 @param dict  存入ballViewArray的字典
 @param selectBallsTrimmedString 投注的一组号码，且已经处理掉前后空格的字符串
 @return 是否有号码 YES,NO
 */
+ (BOOL)splitBallViewNumber_12_WithDict:(NSMutableDictionary *)dict selectBallsTrimmedString:(NSString *)selectBallsTrimmedString {
    NSArray *numberArray = [selectBallsTrimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];//根据@" "的特殊字符分组
    BOOL hasBall = NO;
    NSInteger ballViewNum = 0;//属于第几个ballview的号码
    
    for (NSString *onlyRedBlueBallString in numberArray) {
        
        NSString *onlyRedBlueBallTrimmedString = [onlyRedBlueBallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (onlyRedBlueBallTrimmedString.length == 0) {
            continue;
        }
        
        NSMutableArray *ballNumArray = [NSMutableArray array];
        if (ballViewNum == 0) {
            for (NSInteger charartInt = 0 ;charartInt < onlyRedBlueBallTrimmedString.length;charartInt++) {
                NSString *singleText = [onlyRedBlueBallString substringWithRange:NSMakeRange(charartInt, 1)];
                if([singleText isEqualToString:@"大"]) {
                    [ballNumArray addObject:@"大"];
                } else {
                    [ballNumArray addObject:@"小"];
                }
            }
        } else {
            for (NSInteger charartInt = 0 ;charartInt < onlyRedBlueBallTrimmedString.length;charartInt++) {
                NSInteger singleNum = [[onlyRedBlueBallString substringWithRange:NSMakeRange(charartInt, 1)] intValue];
                [ballNumArray addObject:[NSNumber numberWithInteger:singleNum]];
            }
        }
        [dict setObject:ballNumArray forKey:[CustomParserNumber numberBallViewName:ballViewNum++]];
        hasBall = YES;
    }
    
    return hasBall;
}

/** 拆解中奖号码  根据-+,|()进行分组
 @param winNumber 需要进行拆解的号码
 @param lotteryID
 @param winParserDict
 */
+ (void)parserWinNumer_1:(NSString *)winNumber lotteryID:(NSInteger)lotteryID winParserDict:(NSMutableDictionary *)winParserDict {
    NSInteger i = 0;
    NSArray *numberArray = [winNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+,|()"]];
    
    for (NSString *redBlueString in numberArray) {
        
        NSArray *onlySingleRedBlueBallArray = [redBlueString componentsSeparatedByString:@" "];
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *num in onlySingleRedBlueBallArray) {
            if (num.length == 0) {
                continue;
            }
            [array addObject:[NSNumber numberWithInteger:[num integerValue]]];
        }
        [winParserDict setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)i++]];
    }
}

/** 拆解中奖号码 号码都为个位数，且无其他特殊符号分隔
 @param winNumber 需要进行拆解的号码
 @param lotteryID
 @param winParserDict
 */
+ (void)parserWinNumer_2:(NSString *)winNumber lotteryID:(NSInteger)lotteryID winParserDict:(NSMutableDictionary *)winParserDict {
    NSInteger i = 0;
    NSString *onlyRedBallTrimmedString = [winNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for (NSInteger charartInt = 0 ;charartInt < onlyRedBallTrimmedString.length;charartInt++) {
        
        NSInteger singleNum = [[onlyRedBallTrimmedString substringWithRange:NSMakeRange(charartInt, 1)] intValue];
        
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[NSNumber numberWithInteger:singleNum]];
        [winParserDict setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)i++]];
    }
}

/** 拆解中奖号码 根据空格进行分组
 @param winNumber 需要进行拆解的号码
 @param lotteryID
 @param winParserDict
 */
+ (void)parserWinNumer_3:(NSString *)winNumber lotteryID:(NSInteger)lotteryID winParserDict:(NSMutableDictionary *)winParserDict {
    NSInteger i = 0;
    NSArray *numberArray = [winNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    for (NSString *redBlueString in numberArray) {
        NSMutableArray *array = [NSMutableArray array];
        if (redBlueString.length == 0) {
            continue;
        }
        [array addObject:[NSNumber numberWithInteger:[redBlueString integerValue]]];
        [winParserDict setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)i++]];
    }
}

/**拼接可以转化为有颜色的中奖号码   普通类型    自从销售提出这个颜色的需求后，哥总是有种砍人的冲动
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param enterCharType 一个组的数字添加分隔符的方式  不添加 左边 右边 两边
 @param enterChar  一个组的数字需要添加的分隔符
 @param spaceString 该组内的数字之间的分隔符
 @param singleIsAddChar 如果是单个字符串是否添加分隔符
 @param numHasZero      个位数前面是否添加0
 @param isLastPart     是否最后一组的数组
 @return 该组拼接颜色字符串
 */
+ (NSString *)comparisonWinArray:(NSArray *)winArray
                     selectArray:(NSArray *)selectArray
                       textColor:(NSString *)textColor
                   enterCharType:(EnterType)enterCharType
                       enterChar:(NSString *)enterChar
                     spaceString:(NSString *)spaceString
                 singleIsAddChar:(BOOL)singleIsAddChar
                      numHasZero:(BOOL)numHasZero
                      isLastPart:(BOOL)isLastPart {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    
    NSString *text = @"";
    
    BOOL currentIsColorText = NO;//当前号码为有颜色号码
    NSInteger i = 0;
    BOOL firstNumber = YES;//是否该组第一个号码
    for (NSString *num in selectArray) { //开始取号码的判断颜色
        i++;
        NSString *numString = nil;
        if ([num integerValue] < 10 && numHasZero) {
            numString = [NSString stringWithFormat:@"0%ld",(long)[num integerValue]];
        } else {
            numString = [NSString stringWithFormat:@"%ld",(long)[num integerValue]];
        }
        
        BOOL isColorNum = [CustomParserNumber findTheNum:[num integerValue] inArray:winArray];//判断选的数字是否在中奖号码中
        if (firstNumber) {
            //开始的时候需要先给基本颜色
            text = [NSString stringWithFormat:@"<font color=\"%@\">",isColorNum ? textColor : comparisonTextColor];
            currentIsColorText = isColorNum;
        }
        
        if (currentIsColorText == isColorNum) { //当前的号码跟上一个的号码是都是一样颜色的
            
            //添加号码和号码间的分隔符
            if (spaceString.length == 0 || [spaceString isEqualToString:@" "]) { //如果是空格和空字段的分隔符，则直接加入
                text = [NSString stringWithFormat:@"%@%@%@",text,firstNumber ? @"" : firstNumber ? @"" : spaceString,numString];//第一个号码前面不添加分隔符
                
            } else { //如果是其他分隔符，则需要将该分隔符号变为非中奖颜色的
                if (firstNumber) {
                    text = [NSString stringWithFormat:@"%@%@",text,numString];
                } else {
                    text = [NSString stringWithFormat:@"%@</font><font color=\"%@\">%@</font><font color=\"%@\">%@",text,comparisonTextColor,spaceString,isColorNum ? textColor : comparisonTextColor,numString];
                }
                
                
                
                
            }
        } else { //当前号码跟上一个号码不是一样的颜色
            if (spaceString.length == 0 || [spaceString isEqualToString:@" "]) {
                text = [NSString stringWithFormat:@"%@%@</font><font color=\"%@\">%@",text ,firstNumber ? @"" : spaceString, isColorNum ? textColor : comparisonTextColor,numString];
                
            } else {
                text = [NSString stringWithFormat:@"%@</font><font color=\"%@\">%@</font><font color=\"%@\">%@",text,comparisonTextColor, firstNumber ? @"" : spaceString, isColorNum ? textColor : comparisonTextColor,numString];
            }
            
            
            
            
            currentIsColorText = isColorNum;
        }
        firstNumber = NO;
    }
    
    //传进来的号码如果是空数组，就返回一个*
    if (i == 0) {
        text = [NSString stringWithFormat:@"<font color=\"%@\">*",comparisonTextColor];
    }
    
    if (isLastPart || spaceString.length == 0) {//最后一组的数字的最后面就不添加分隔符了
        text = [NSString stringWithFormat:@"%@</font>",text];
    } else {
        if ([spaceString isEqualToString:@" "]) {
            text = [NSString stringWithFormat:@"%@%@</font>",text ,spaceString];
        } else {
            text = [NSString stringWithFormat:@"%@</font><font color=\"%@\">%@</font>",text ,comparisonTextColor ,spaceString];
        }
    }
    
    if ((enterChar.length > 0 && !isLastPart)) { //添加一组的分隔符号
        if (enterCharType == EnterTypeLeft) {  //组之间的分隔符号加在该组左边
            text = [NSString stringWithFormat:@"<font color=\"%@\">%@</font>%@",comparisonTextColor,enterChar,text];
        } else if (enterCharType == EnterTypeBothSides) {//组之间的分隔符号加在该组两边
            
            if ([enterChar isEqualToString:@"("]) { //如果是（左括号，右边则默认是）右括号
                if ([selectArray count] > 1 || singleIsAddChar) {  //左右括号一般是该组有两个以上的数字的时候才使用的
                    text = [NSString stringWithFormat:@"<font color=\"%@\">(</font>%@<font color=\"%@\">)</font>",comparisonTextColor,text,comparisonTextColor];
                }
            } else {
                text = [NSString stringWithFormat:@"<font color=\"%@\">%@</font>%@<font color=\"%@\">%@</font>",comparisonTextColor,enterChar,text,comparisonTextColor,enterChar];
            }
            
        } else if (enterCharType == EnterTypeRight) { //组之间的分隔符号加在该组右边
            text = [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>",text,comparisonTextColor,enterChar];
        } else {
            
        }
    }
    
    return text;
}

/**拼接可以转化为有颜色的中奖号码   例：排列3组三单式（只有一注号码） 如果选223 开奖号码为432，则整组颜色为不中的颜色，如果开奖号码为223，232，322，则为中奖颜色  或 排列3组六单式（只有一注号码） 如果选123 开奖号码为432，则整组颜色为不中的颜色，如果开奖号码为123，132，213，231，312，321，则整组为中奖颜色
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_2:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 3) {
        return @"";
    }
    
    NSString *selectNumberStr = [NSString stringWithFormat:@"%@%@%@",[selectArray objectAtIndex:0],[selectArray objectAtIndex:1],[selectArray objectAtIndex:2]];
    
    BOOL win = NO;//是否中奖，开始为否
    if ([CustomParserNumber judgeCirculationNumberArray:winArray compareNumber:selectNumberStr]) {
        win = YES;
    }
    
    return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",win ? textColor : comparisonTextColor, selectNumberStr];
}

/**拼接可以转化为有颜色的中奖号码   例：排列3组三复式 如果选23 开奖号码为432，则整组颜色为不中的颜色，如果开奖号码为223，232，322，233，323，332则为中奖颜色
 加入选23456789，开奖号码为432，则整组颜色为不中的颜色，如果开奖号码为977，则9和7为有颜色，其他没有
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_3:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 2) {
        return @"";
    }
    
    
    BOOL winType = NO;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        if ((firstWinNumber == secondWinNumber && secondWinNumber != threeWinNumber) || (firstWinNumber == threeWinNumber && secondWinNumber != threeWinNumber) || (secondWinNumber == threeWinNumber && firstWinNumber != secondWinNumber)) {
            winType = YES;
        }
        
    }
    
    
    
    return [CustomParserNumber comparisonWinArray:winArray selectArray:selectArray textColor:winType ? textColor : comparisonTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"," singleIsAddChar:NO numHasZero:NO isLastPart:YES];
}

/**拼接可以转化为有颜色的中奖号码   例：3d的组六   ，保留以后可以用，目前暂未用
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_4:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor {
    if ([selectArray count] < 2) {
        return @"";
    }
    
    
    BOOL winType = NO;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        if (firstWinNumber != secondWinNumber && secondWinNumber != threeWinNumber && firstWinNumber != threeWinNumber) {
            winType = YES;
        }
        
    }
    
    return [CustomParserNumber comparisonWinArray:winArray selectArray:selectArray textColor:winType ? textColor : grayTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"," singleIsAddChar:NO numHasZero:NO isLastPart:YES];
}


/**拼接可以转化为有颜色的中奖号码   例：3d的猜2d，二同号
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_5:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor
                       spaceString:(NSString *)spaceString {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    
    BOOL winType = NO;
    NSMutableArray *newWinArray = [NSMutableArray array];
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        if (firstWinNumber == secondWinNumber) {
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)firstWinNumber]];
            winType = YES;
            
        } else if (secondWinNumber == threeWinNumber){
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)secondWinNumber]];
            winType = YES;
            
        } else if (firstWinNumber == threeWinNumber) {
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)firstWinNumber]];
            winType = YES;
            
        } else {
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)-1]];//没有就给－1啦，就是木有中奖
        }
        
    }
    
    return [CustomParserNumber comparisonWinArray:winArray selectArray:selectArray textColor:winType ? textColor : comparisonTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:spaceString singleIsAddChar:NO numHasZero:NO isLastPart:YES];
}

/**拼接可以转化为有颜色的中奖号码   例：3d的猜2d，二不同号 虽然可以全部丢进去比较，但是可能有需求变化，还是分开为一个方法
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param spaceString 数字之间的分隔符
 */
+ (NSString *)comparisonWinArray_6:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor
                       spaceString:(NSString *)spaceString {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    
    BOOL winType = NO;
    NSMutableArray *newWinArray = [NSMutableArray array];
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)firstWinNumber]];
        if (firstWinNumber != secondWinNumber) {
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)secondWinNumber]];
            
        } else if (secondWinNumber != threeWinNumber && firstWinNumber != threeWinNumber){
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)threeWinNumber]];
            
            
        }
        winType = YES;
    }
    
    return [CustomParserNumber comparisonWinArray:winArray selectArray:selectArray textColor:winType ? textColor : comparisonTextColor enterCharType:EnterTypeNO enterChar:@"" spaceString:spaceString singleIsAddChar:NO numHasZero:NO isLastPart:YES];
}


/**拼接可以转化为有颜色的中奖号码   例：3d的包选3
 @param winArray 中奖号码的数组
 @param selectDict 自选的数组字典
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param enterChar 组与组之间的分隔符号
 */
+ (NSString *)comparisonWinArray_7:(NSArray *)winArray
                        selectDict:(NSDictionary *)selectDict
                         textColor:(NSString *)textColor
                     enterCharType:(EnterType)enterCharType
                         enterChar:(NSString *)enterChar {
    BOOL winType = NO;
    
    NSString *text = @"";
    NSMutableArray *newWinArray = [NSMutableArray array];
    
    NSInteger sameNumber = -1;
    NSInteger noSameNumber = -1;
    
    
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        if ((firstWinNumber == secondWinNumber && secondWinNumber != threeWinNumber)) {
            sameNumber = firstWinNumber;
            noSameNumber = threeWinNumber;
            winType = YES;
            
        } else if (firstWinNumber == threeWinNumber && secondWinNumber != threeWinNumber) {
            sameNumber = firstWinNumber;
            noSameNumber = secondWinNumber;
            winType = YES;
            
        } else if (secondWinNumber == threeWinNumber && firstWinNumber != secondWinNumber) {
            sameNumber = secondWinNumber;
            noSameNumber = firstWinNumber;
            winType = YES;
            
        }
    }
    
    if (winType) {
        [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)sameNumber]];
        text = [NSString stringWithFormat:@"%@%@",text,[self comparisonWinArray:newWinArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:textColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:NO]];
        
        if (![enterChar isEqualToString:@"("]) {
            text = [NSString stringWithFormat:@"%@%@",[self joinText:text winArray:winArray enterCharColor:textColor enterChar:enterChar enterCharType:enterCharType],text];
        } else {
            text = [NSString stringWithFormat:@"%@%@",text,text];
        }
        
        
        text = [self joinText:text winArray:newWinArray enterCharColor:textColor enterChar:enterChar enterCharType:enterCharType];
        
        [newWinArray removeAllObjects];
        [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)noSameNumber]];
        
        NSString *rightText = [self comparisonWinArray:newWinArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:textColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:YES];
        
        if ([enterChar isEqualToString:@"("]) {
            rightText = [self joinText:rightText winArray:newWinArray enterCharColor:textColor enterChar:enterChar enterCharType:enterCharType];
        }
        
        text = [NSString stringWithFormat:@"%@%@",text,rightText];
        
    } else {
        if ([winArray count] != 0)
            [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)-1]];
        
        text = [NSString stringWithFormat:@"%@%@",text,[self comparisonWinArray:newWinArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:textColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:NO]];
        
        if (![enterChar isEqualToString:@"("]) {
            text = [NSString stringWithFormat:@"%@%@%@",text,enterChar,text];
        } else {
            text = [NSString stringWithFormat:@"%@%@",text,text];
        }
        
        
        text = [self joinText:text winArray:newWinArray enterCharColor:textColor enterChar:enterChar enterCharType:enterCharType];
        
        NSString *rightText = [self comparisonWinArray:newWinArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:1]] textColor:textColor enterCharType:EnterTypeNO enterChar:@"" spaceString:@"" singleIsAddChar:NO numHasZero:NO isLastPart:YES];
        
        if ([enterChar isEqualToString:@"("]) {
            rightText = [self joinText:rightText winArray:newWinArray enterCharColor:textColor enterChar:enterChar enterCharType:enterCharType];
        }
        
        text = [NSString stringWithFormat:@"%@%@",text,rightText];
    }
    
    return text;
}

/**拼接可以转化为有颜色的中奖号码   例：时时彩 大小单双   winArray只有一个数字，selectArray也只有一个选号
 @param winArray 中奖号码的数组
 @param selectDict 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_8:(NSArray *)winArray
                       selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    if([winArray count] > 0) {
        NSString *selectNumberStr = [selectArray objectAtIndex:0];
        NSInteger winNumber = [[winArray objectAtIndex:0] integerValue];
        
        if (([selectNumberStr isEqualToString:@"大"] && winNumber >= 5 && winNumber <= 9) || ([selectNumberStr isEqualToString:@"小"] && winNumber >= 0 && winNumber <= 4) || ([selectNumberStr isEqualToString:@"单"] && (winNumber % 2 == 1)) || ([selectNumberStr isEqualToString:@"双"] && (winNumber % 2 == 0))) {
            return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",textColor ,[selectArray objectAtIndex:0]];
            
        } else {
            return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",grayTextColor ,[selectArray objectAtIndex:0]];
        }
        
    }
    
    return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",comparisonTextColor ,[selectArray objectAtIndex:0]];
}


/**拼接可以转化为有颜色的中奖号码   例：3d的和数
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param winNumberCount 求和个数
 */
+ (NSString *)comparisonWinArray_9:(NSArray *)winArray
                        selectDict:(NSDictionary *)selectDict
                         textColor:(NSString *)textColor
                    winNumberCount:(NSInteger)winNumberCount {
    
    NSMutableArray *newWinArray = [NSMutableArray array];
    
    if ([winArray count] >= winNumberCount) {
        NSInteger sum = 0;
        for (NSInteger i = 0; i < winNumberCount; i++) {
            sum += [[winArray objectAtIndex:i] integerValue];
        }
        
        [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)sum]];
    }
    
    return [self comparisonWinArray:newWinArray selectArray:[selectDict objectForKey:[CustomParserNumber numberBallViewName:0]] textColor:textColor enterCharType:EnterTypeRight enterChar:@"" spaceString:@"," singleIsAddChar:NO numHasZero:NO isLastPart:YES];
    
}

/**拼接可以转化为有颜色的中奖号码   例：3d的大小 0到9为小  19到27为大 只有一个选号的情况
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_10:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                         textColor:(NSString *)textColor {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    NSInteger sum = 0;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        
        sum = firstWinNumber + secondWinNumber + threeWinNumber;
    }
    
    NSInteger selectNum = [[selectArray objectAtIndex:0] integerValue];
    NSString *selectString = selectNum == 0 ? @"大" : @"小";
    
    if ((sum >= 0 && sum <= 9 && selectNum == 1) || (sum >= 19 && sum <= 27 && selectNum == 0)) {
        
        return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",textColor,selectString];
    } else {
        
        return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",comparisonTextColor,selectString];
    }
    
}

/**拼接可以转化为有颜色的中奖号码   例：全为奇数则为奇数中奖，全为偶数则偶数中奖 只有一个选号的情况
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_11:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    NSInteger isNumberState = 0; //0为奇偶都有 1为全奇数 2为全偶数
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        if (firstWinNumber % 2 == 1 && secondWinNumber % 2 == 1 && threeWinNumber % 2 == 1) {
            isNumberState = 1;
        } else if (firstWinNumber % 2 == 0 && secondWinNumber % 2 == 0 && threeWinNumber % 2 == 0) {
            isNumberState = 2;
        }
    }
    
    NSInteger selectNum = [[selectArray objectAtIndex:0] integerValue];
    NSString *selectString = selectNum == 0 ? @"奇" : @"偶";
    
    if ((isNumberState == 1 && selectNum == 0) || (isNumberState == 2 && selectNum == 1)) {
        
        return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",textColor,selectString];
    } else {
        
        return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",comparisonTextColor,selectString];
    }
    
}

/**拼接可以转化为有颜色的中奖号码   例：三个数字都相同的情况  3d的三同号 （全）
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_12:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                               text:(NSString *)text {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    BOOL winType = NO;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        if (firstWinNumber == secondWinNumber && secondWinNumber == threeWinNumber) {
            winType = YES;
        }
    }
    
    return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",winType ? textColor : comparisonTextColor,text];
}

/**拼接可以转化为有颜色的中奖号码   例：升序降序连续排列的情况 只有一个选号的情况
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param sortType 排序方式  0为升降序都有  1为升序  2为降序
 */
+ (NSString *)comparisonWinArray_13:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                               text:(NSString *)text
                           sortType:(NSInteger)sortType {
    
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    BOOL winType = NO;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        if ((firstWinNumber == (secondWinNumber + 1)) && (secondWinNumber == (threeWinNumber + 1)) && (sortType == 0 || sortType == 2)) {
            winType = YES;
        } else if ((firstWinNumber == (secondWinNumber - 1)) && (secondWinNumber == (threeWinNumber - 1)) && (sortType == 0 || sortType == 1)) {
            winType = YES;
        }
    }
    
    return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",winType ? textColor : comparisonTextColor,text];
}


/**拼接可以转化为有颜色的中奖号码   例：三个数字都相同的情况  江苏快3的三同号 （单）
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_14:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    NSInteger selectNumber = [[selectArray objectAtIndex:0] integerValue];
    
    BOOL winType = NO;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        if (firstWinNumber == selectNumber && secondWinNumber == selectNumber && threeWinNumber == selectNumber) {
            winType = YES;
        }
    }
    
    return [NSString stringWithFormat:@"<font color=\"%@\">%ld%@%ld%@%ld</font>",winType ? textColor : comparisonTextColor,(long)selectNumber,spaceString,(long)selectNumber,spaceString,(long)selectNumber];
}

/**拼接可以转化为有颜色的中奖号码   例：江苏快3，二同号复选
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_15:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString
                          enterChar:(NSString *)enterChar {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    
    BOOL winType = NO;
    NSInteger sameNum = -1;
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        if (firstWinNumber == secondWinNumber) {
            sameNum = firstWinNumber;
            winType = YES;
            
        } else if (secondWinNumber == threeWinNumber){
            sameNum = secondWinNumber;
            winType = YES;
            
        } else if (firstWinNumber == threeWinNumber) {
            sameNum = threeWinNumber;
            winType = YES;
            
        } else {
            sameNum = -1;//没有就给－1啦，就是木有中奖
        }
        
    }
    NSString *text = @"";
    NSInteger len = 0;
    for (NSString *numberStr in selectArray) {
        NSInteger number = [numberStr integerValue];
        
        if (text.length == 0) {
            text = [NSString stringWithFormat:@"<font color=\"%@\">%ld%@%ld%@*</font>",((winType && (number == sameNum)) ? textColor : comparisonTextColor) ,(long)number ,spaceString ,(long)number ,spaceString];
            
        } else if (enterChar.length == 0 || [enterChar isEqualToString:@" "]) {
            text = [NSString stringWithFormat:@"%@%@<font color=\"%@\">%ld%@%ld%@*</font>",text ,enterChar ,((winType && (number == sameNum)) ? textColor : comparisonTextColor) ,(long)number ,spaceString ,(long)number ,spaceString];
            
        } else {
            text = [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font><font color=\"%@\">%ld%@%ld%@*</font>",text ,comparisonTextColor ,enterChar ,((winType && (number == sameNum)) ? textColor : comparisonTextColor) ,(long)number ,spaceString ,(long)number ,spaceString];
            
        }
        
        len++;
    }
    
    
    return text;
}


/**拼接可以转化为有颜色的中奖号码   混合两种颜色的类型
 @param winRedArray 开奖红色号码的数组
 @param winBlueArray 开奖蓝色号码的数组
 @param selectArray 自选的数组
 @param textRedColor 如果开奖红色号码数组存在该数字，该数字要显示的颜色
 @param textBlueColor 如果开奖蓝色号码数组存在该数字，该数字要显示的颜色
 @param enterCharType 一个组的数字添加分隔符的方式  不添加 左边 右边 两边
 @param enterChar  一个组的数字需要添加的分隔符
 @param spaceString 该组内的数字之间的分隔符
 @param singleIsAddChar 如果是单个字符串是否添加分隔符
 @param numHasZero      个位数前面是否添加0
 @param isLastPart     是否最后一组的数组
 @return 该组拼接颜色字符串
 */
+ (NSString *)comparisonWinRedArray_16:(NSArray *)winRedArray
                          winBlueArray:(NSArray *)winBlueArray
                           selectArray:(NSArray *)selectArray
                          textRedColor:(NSString *)textRedColor
                         textBlueColor:(NSString *)textBlueColor
                         enterCharType:(EnterType)enterCharType
                             enterChar:(NSString *)enterChar
                           spaceString:(NSString *)spaceString
                       singleIsAddChar:(BOOL)singleIsAddChar
                            numHasZero:(BOOL)numHasZero
                            isLastPart:(BOOL)isLastPart {
    NSString *comparisonTextRedColor = nil;
    if ([winRedArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextRedColor = grayTextColor;
    } else {
        comparisonTextRedColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    
    NSString *text = @"";
    
    NSInteger currentColorSign = 0;//0为灰色  1为textRedColor  2为textBlueColor
    NSInteger i = 0;
    BOOL firstNumber = YES;//是否该组第一个号码
    for (NSString *num in selectArray) { //开始取号码的判断颜色
        i++;
        NSString *numString = nil;
        if ([num integerValue] < 10 && numHasZero) {
            numString = [NSString stringWithFormat:@"0%ld",(long)[num integerValue]];
        } else {
            numString = [NSString stringWithFormat:@"%ld",(long)[num integerValue]];
        }
        
        BOOL isRedColorNum = [CustomParserNumber findTheNum:[num integerValue] inArray:winRedArray];//判断选的数字是否在中奖号码中
        BOOL isBlueColorNum = [CustomParserNumber findTheNum:[num integerValue] inArray:winBlueArray];//判断选的数字是否在中奖号码中
        NSInteger isColorNum = isRedColorNum ? 1 : (isBlueColorNum ? 2 : 0);
        NSString *colorsText = isRedColorNum ? textRedColor : (isBlueColorNum ? textBlueColor : comparisonTextRedColor);
        if (firstNumber) {
            //开始的时候需要先给基本颜色
            text = [NSString stringWithFormat:@"<font color=\"%@\">",colorsText];
            currentColorSign = isColorNum;
        }
        
        if (currentColorSign == isColorNum) { //当前的号码跟上一个的号码是都是一样颜色的
            
            //添加号码和号码间的分隔符
            if (spaceString.length == 0 || [spaceString isEqualToString:@" "]) { //如果是空格和空字段的分隔符，则直接加入
                text = [NSString stringWithFormat:@"%@%@%@",text,firstNumber ? @"" : firstNumber ? @"" : spaceString,numString];//第一个号码前面不添加分隔符
                
            } else { //如果是其他分隔符，则需要将该分隔符号变为非中奖颜色的
                if (firstNumber) {
                    text = [NSString stringWithFormat:@"%@%@",text,numString];
                } else {
                    text = [NSString stringWithFormat:@"%@</font><font color=\"%@\">%@</font><font color=\"%@\">%@",text,comparisonTextRedColor,spaceString,colorsText,numString];
                }
                
            }
        } else { //当前号码跟上一个号码不是一样的颜色
            if (spaceString.length == 0 || [spaceString isEqualToString:@" "]) {
                text = [NSString stringWithFormat:@"%@%@</font><font color=\"%@\">%@",text ,firstNumber ? @"" : spaceString, colorsText,numString];
                
            } else {
                text = [NSString stringWithFormat:@"%@</font><font color=\"%@\">%@</font><font color=\"%@\">%@",text,comparisonTextRedColor, firstNumber ? @"" : spaceString, colorsText,numString];
            }
            
            
            
            
            currentColorSign = isColorNum;
        }
        firstNumber = NO;
    }
    
    //传进来的号码如果是空数组，就返回一个*
    if (i == 0) {
        text = [NSString stringWithFormat:@"<font color=\"%@\">*",comparisonTextRedColor];
    }
    
    if (isLastPart || spaceString.length == 0) {//最后一组的数字的最后面就不添加分隔符了
        text = [NSString stringWithFormat:@"%@</font>",text];
    } else {
        if ([spaceString isEqualToString:@" "]) {
            text = [NSString stringWithFormat:@"%@%@</font>",text ,spaceString];
        } else {
            text = [NSString stringWithFormat:@"%@</font><font color=\"%@\">%@</font>",text ,comparisonTextRedColor ,spaceString];
        }
    }
    
    if ((enterChar.length > 0 && !isLastPart)) { //添加一组的分隔符号
        if (enterCharType == EnterTypeLeft) {  //组之间的分隔符号加在该组左边
            text = [NSString stringWithFormat:@"<font color=\"%@\">%@</font>%@",comparisonTextRedColor ,enterChar ,text];
        } else if (enterCharType == EnterTypeBothSides) {//组之间的分隔符号加在该组两边
            
            if ([enterChar isEqualToString:@"("]) { //如果是（左括号，右边则默认是）右括号
                if ([selectArray count] > 1) {  //左右括号一般是该组有两个以上的数字的时候才使用的
                    text = [NSString stringWithFormat:@"<font color=\"%@\">(</font>%@<font color=\"%@\">)</font>",comparisonTextRedColor,text,comparisonTextRedColor];
                }
            } else {
                text = [NSString stringWithFormat:@"<font color=\"%@\">%@</font>%@<font color=\"%@\">%@</font>",comparisonTextRedColor ,enterChar ,text ,comparisonTextRedColor ,enterChar];
            }
            
        } else if (enterCharType == EnterTypeRight) { //组之间的分隔符号加在该组右边
            text = [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>",text ,comparisonTextRedColor ,enterChar];
        } else {
            
        }
    }
    
    return text;
}

/**拼接可以转化为有颜色的中奖号码   例：时时彩 组三
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param enterCharType 添加每组号码的分隔符的方式
 @param enterChar 添加每组号码的分隔符
 */
+ (NSString *)comparisonWinArray_17:(NSArray *)winArray
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString
                      enterCharType:(EnterType)enterCharType
                          enterChar:(NSString *)enterChar {
    BOOL winType = NO;
    NSMutableArray *newWinArray = [NSMutableArray array];
    
    NSInteger sameNumber = -1;
    NSInteger noSameNumber = -1;
    
    
    if ([winArray count] >= 3) {
        NSInteger firstWinNumber = [[winArray objectAtIndex:0] integerValue];
        NSInteger secondWinNumber = [[winArray objectAtIndex:1] integerValue];
        NSInteger threeWinNumber = [[winArray objectAtIndex:2] integerValue];
        
        if ((firstWinNumber == secondWinNumber && secondWinNumber != threeWinNumber)) {
            sameNumber = firstWinNumber;
            noSameNumber = threeWinNumber;
            winType = YES;
            
        } else if (firstWinNumber == threeWinNumber && secondWinNumber != threeWinNumber) {
            sameNumber = firstWinNumber;
            noSameNumber = secondWinNumber;
            winType = YES;
            
        } else if (secondWinNumber == threeWinNumber && firstWinNumber != secondWinNumber) {
            sameNumber = secondWinNumber;
            noSameNumber = firstWinNumber;
            winType = YES;
            
        }
    }
    if (winType) {
        [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)sameNumber]];
        [newWinArray addObject:[NSString stringWithFormat:@"%ld",(long)noSameNumber]];
    } else {
        if ([winArray count] > 0) {
            [newWinArray addObject:@"-1"];
        }
    }
    
    return [self comparisonWinArray:newWinArray selectArray:selectArray textColor:textColor enterCharType:enterCharType enterChar:enterChar spaceString:spaceString singleIsAddChar:NO numHasZero:NO isLastPart:YES];
}

/**拼接可以转化为有颜色的中奖号码   例：大小
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 */
+ (NSString *)comparisonWinArray_18:(NSArray *)winArray
                        minFirstNum:(NSInteger)minFirstNum
                         minLastNum:(NSInteger)minLastLastNum
                            minText:(NSString *)minText
                        maxFirstNum:(NSInteger)maxFirstNum
                         maxLastNum:(NSInteger)maxLastLastNum
                            maxText:(NSString *)maxText
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if ([selectArray count] < 1) {
        return @"";
    }
    
    NSString *text = @"";
    if([winArray count] == 0)
        return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>",comparisonTextColor,[selectArray componentsJoinedByString:@""]];
    
    
    NSInteger sum = 0;
    for (NSInteger i = 0; i < [winArray count]; i++) {
        sum += [[winArray objectAtIndex:i] integerValue];
    }
    
    
    
    for (NSString *selectNum in selectArray) {
        if (sum >= minFirstNum && sum <= minLastLastNum && [minText isEqualToString:selectNum]) {
            text = [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>",text,textColor,selectNum];
        } else if (sum >= maxFirstNum && sum <= maxLastLastNum && [maxText isEqualToString:selectNum]) {
            text = [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>",text,textColor,selectNum];
        } else {
            text = [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>",text,comparisonTextColor,selectNum];
        }
    }
    return text;
}



/**19拼接可以转化为有颜色的中奖号码   例：
 @param winArray 中奖号码的数组
 @param selectArray 自选的数组
 @param textColor 如果数组存在该数字，该数字要显示的颜色
 @param enterCharType 添加每组号码的分隔符的方式
 @param enterChar 添加每组号码的分隔符
 */
+ (NSString *)comparisonWinArray_19:(NSArray *)winArray
                 repetitionSequence:(NSString *)repetitionSequence
                        selectArray:(NSArray *)selectArray
                          textColor:(NSString *)textColor
                        spaceString:(NSString *)spaceString
                      enterCharType:(EnterType)enterCharType
                          enterChar:(NSString *)enterChar {
    
    for(NSInteger charartInt = 0; charartInt < repetitionSequence.length ;charartInt++) {
        NSString *charSign = [repetitionSequence substringWithRange:NSMakeRange(charartInt, 1)];
        
        for (NSInteger i = 0; i < [selectArray count]; i++) {
            NSInteger count = 1;
            for (NSInteger j = 0; j < [selectArray count]; j++) {
                if(i != j && [[selectArray objectAtIndex:i] integerValue] == [[selectArray objectAtIndex:j] integerValue]) {
                    count++;
                }
            }
            if (count == [charSign integerValue]) {
                
            } else {
                
            }
        }
        
        
    }
    
    return [self comparisonWinArray:winArray selectArray:selectArray textColor:textColor enterCharType:enterCharType enterChar:enterChar spaceString:spaceString singleIsAddChar:NO numHasZero:NO isLastPart:YES];
}

/**将某字典中的数字都存在一个数组中返回 按前取
 @param dict
 @param count
 @return
 */
+ (NSMutableArray *)takeAllNumberInOneArrayWithDict:(NSDictionary *)dict count:(NSInteger)count {
    NSMutableArray *winArray = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        NSString *key = [NSString stringWithFormat:@"%ld",(long)i];
        if ([dict objectForKey:key]) {
            [winArray addObjectsFromArray:[dict objectForKey:key]];
        }
    }
    return winArray;
}

/**将某字典中的数字都存在一个数组中返回 按后取
 @param dict
 @param count
 @return
 */
+ (NSMutableArray *)takeAllLastNumberInOneArrayWithDict:(NSDictionary *)dict count:(NSInteger)count {
    NSMutableArray *winArray = [NSMutableArray array];
    NSInteger dictCount = dict.count;
    for (NSInteger i = dictCount - 1; i > (dictCount - 1 - count); i--) {
        NSString *key = [NSString stringWithFormat:@"%ld",(long)i];
        if ([dict objectForKey:key]) {
            [winArray addObjectsFromArray:[dict objectForKey:key]];
        }
    }
    return winArray;
}

/**
 @param selectArray   中奖号码的数组
 @param compareNumber 自选的数组
 @param textColor     如果数组存在该数字，该数字要显示的颜色
 */
+ (BOOL)judgeCirculationNumberArray:(NSArray *)selectArray compareNumber:(NSString *)compareNumber {
    if ([selectArray count] != 3) {
        return NO;
    }
    NSMutableArray *indexArray = [NSMutableArray array];
    [indexArray addObject:@"0"];
    [indexArray addObject:@"1"];
    [indexArray addObject:@"2"];
    
    for (NSInteger i = 0 ; i < 3; i++) {
        for (NSInteger indexSign = 0; indexSign < [indexArray count] - 1; indexSign++) {
            [indexArray exchangeObjectAtIndex:indexSign withObjectAtIndex:indexSign + 1];
            NSInteger firstIndex = [[indexArray objectAtIndex:0] integerValue];
            NSInteger secondIndex = [[indexArray objectAtIndex:1] integerValue];
            NSInteger threeIndex = [[indexArray objectAtIndex:2] integerValue];
            NSString  *selectNum = [NSString stringWithFormat:@"%@%@%@",[selectArray objectAtIndex:firstIndex],[selectArray objectAtIndex:secondIndex],[selectArray objectAtIndex:threeIndex]];
            if ([compareNumber isEqualToString:selectNum]) {
                return YES;
            }
            
        }
    }
    return NO;
}

/**
 @param winArray   需要筛选的数组
 @param occurrencesCount 在数组中出现的次数
 @return     返回出现该次数的数字数组
 */
+ (NSMutableArray *)statisticsNumCountWithWinArray:(NSArray *)winArray occurrencesCount:(NSInteger)occurrencesCount {
    NSMutableArray *occurrencesCountArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [winArray count];i++) {
        NSInteger count = 1;
        for (NSInteger j = 0; j < [winArray count]; j++) {
            if (i != j && [[winArray objectAtIndex:i] integerValue] == [[winArray objectAtIndex:j] integerValue]) {
                count++;
            }
            
        }
        if (count == occurrencesCount) {
            if (![occurrencesCountArray containsObject:[winArray objectAtIndex:i]]) {
                [occurrencesCountArray addObject:[winArray objectAtIndex:i]];
            }
        }
    }
    if ([winArray count] > 0 && [occurrencesCountArray count] == 0) {
        [occurrencesCountArray addObject:[NSNumber numberWithInteger:-1]];
    }
    return occurrencesCountArray;
}

/**连接字符串
 @param leftText 左边的字符串
 @param rightText 右边的字符串
 @param winArray 中奖的号码数组，主要只是用来判断是不是要给分隔符显示颜色
 @param textColor 如果有颜色，分隔符要显示的颜色
 @param spaceString  一个组的数字需要添加的分隔符
 @return 连接完的字符串
 */
+ (NSString *)joinLeftText:(NSString *)leftText
                 rightText:(NSString *)rightText
                  winArray:(NSArray *)winArray
                spaceColor:(NSString *)spaceColor
               spaceString:(NSString *)spaceString {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if (spaceString.length == 0 || [spaceString isEqualToString:@" "]) {
        return [NSString stringWithFormat:@"%@%@%@",leftText,spaceString,rightText];
    } else {
        return [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>%@",leftText ,comparisonTextColor ,spaceString ,rightText];
    }
}


+ (NSString *)joinText:(NSString *)text
              winArray:(NSArray *)winArray
        enterCharColor:(NSString *)enterCharColor
             enterChar:(NSString *)enterChar
         enterCharType:(EnterType)enterCharType {
    NSString *comparisonTextColor = nil;
    if ([winArray count] == 0) {//如果中奖号码为空数组，则默认为未开奖，未开奖的数组都是有颜色的
        comparisonTextColor = grayTextColor;
    } else {
        comparisonTextColor = grayTextColor;
    }
    
    if (enterChar.length == 0 || [enterChar isEqualToString:@" "]) {
        return [NSString stringWithFormat:@"%@%@",text,enterChar];
        
    } else if (enterCharType == EnterTypeLeft) {
        return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>%@",comparisonTextColor ,enterChar ,text];
        
    } else if (enterCharType == EnterTypeBothSides) {
        if ([enterChar isEqualToString:@"("]) {
            return [NSString stringWithFormat:@"<font color=\"%@\">(</font>%@<font color=\"%@\">)</font>",comparisonTextColor ,text ,comparisonTextColor];
        } else {
            return [NSString stringWithFormat:@"<font color=\"%@\">%@</font>%@<font color=\"%@\">%@</font>",comparisonTextColor  ,enterChar ,text ,comparisonTextColor ,enterChar];
        }
        
    } else if (enterCharType == EnterTypeRight){
        return [NSString stringWithFormat:@"%@<font color=\"%@\">%@</font>",text ,comparisonTextColor ,enterChar];
    }
    return @"";
}

+ (BOOL)findTheNum:(NSInteger)num inArray:(NSArray *)numArray {
    for (NSString *str in numArray) {
        if ([str integerValue] == num) {
            return YES;
        }
    }
    return NO;
}


@end
