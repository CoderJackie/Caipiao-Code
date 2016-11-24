//
//  NSString+CustomString.m
//  TicketProject
//
//  Created by KAI on 15-3-14.
//  Copyright (c) 2015年 sls002. All rights reserved.
//

#import "NSString+CustomString.h"

@implementation NSString (CustomString)

+ (NSInteger)characterLength:(NSString *)string {
    NSInteger length = 0;
    for (NSInteger index = 0; index < [string length]; index++) {
        NSString *character = [string substringWithRange:NSMakeRange(index, 1)];
        length += [character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3 ? 2 : 1;
    }
    
    return length;
}

+ (BOOL)checkOnStandardString:(NSString *)string {
    NSString *regex = @"[a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:string];
}

+ (BOOL)ruoCheckString:(NSString *)passwordString {
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i = 0;i < [passwordString length];i++){
        unichar c = [passwordString characterAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%c",c];
        [array addObject:str];
    }
    
    if (array.count > 5) {
        for (int i = 0; i < array.count - 1; i++) {
            NSString *str = [array objectAtIndex:0];
            NSString *str1 = @"[0-9]";
            NSRange range = [str rangeOfString:str1 options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSInteger count = [[array objectAtIndex:i] integerValue] - [[array objectAtIndex:i + 1] integerValue];
                if (count == -1 || count == 1) {
                    continue;
                    
                } else {
                    return YES;
                    
                }
            } else {
                return YES;
            }
        }
        
        return NO;
    }
    
    return NO;
}

+ (BOOL)isContainSpecialString:(NSString *)string {
    NSString *str1 = @"[A-Za-z]";
    NSRange range = [string rangeOfString:str1 options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isContainString:(NSString *)string {
    NSString *str1 = @"[0-9]";
    NSRange range = [string rangeOfString:str1 options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isContainCheckOnString:(NSString *)string {    
    NSString *searchText = @"(\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\(|\\)|\\_|\\-|\\=|\\+|\\\\|\\||\\[|\\]|\\{|\\}|\\;|\\'|\\:|\\\"|\\,|\\.|\\/|\\<|\\>|\\?)";
    NSRange range = [string rangeOfString:searchText options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (NSInteger)checkOmString:(NSString *)string {
    NSMutableArray *array = [NSMutableArray array];
    for(NSInteger i = 0;i < [string length];i++){
        unichar c = [string characterAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%c",c];
        [array addObject:str];
    }
    
    NSSet *set = [NSSet setWithArray:array];
    return [set count];
}

+ (NSMutableString *)encryptionString:(NSString *)string contrastString:(NSString *)contrastString {
    NSMutableString *encryptionStr = [NSMutableString stringWithFormat:@""];
    if ([contrastString isEqualToString:string]) {
        [encryptionStr appendString:string];
    } else {
        if (string.length > 2) {
            [encryptionStr appendString:[string substringWithRange:NSMakeRange(0, 2)]];
            [encryptionStr appendString:@"***"];
        }
    }
    
    return encryptionStr;
}

@end
